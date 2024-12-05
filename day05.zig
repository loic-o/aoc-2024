const std = @import("std");

// answers:
// p1: 6951
// p2: 4121

const puzzle_input = @embedFile("day05_data.txt");
const test_input =
    \\47|53
    \\97|13
    \\97|61
    \\97|47
    \\75|29
    \\61|13
    \\75|53
    \\29|13
    \\97|29
    \\53|29
    \\61|53
    \\97|53
    \\61|29
    \\47|13
    \\75|47
    \\97|75
    \\47|61
    \\75|61
    \\47|29
    \\75|13
    \\53|13
    \\
    \\75,47,61,53,29
    \\97,61,53,29,13
    \\75,29,13
    \\75,97,47,61,53
    \\61,13,29
    \\97,13,75,29,47
;

const Allocator = std.mem.Allocator;
const UsizeList = std.ArrayList(usize);

const Puzzle = struct {
    rules: std.AutoHashMap(usize, UsizeList),
    updates: std.ArrayList(UsizeList),

    pub fn parse(allocator: Allocator, input: []const u8) !Puzzle {
        var rules = std.AutoHashMap(usize, UsizeList).init(allocator);
        var updates = std.ArrayList(UsizeList).init(allocator);

        var it = std.mem.splitScalar(u8, input, '\n');
        while (it.next()) |raw_line| {
            const line = std.mem.trim(u8, raw_line, " ");
            if (line.len == 0) break;

            const p = std.mem.indexOfScalar(u8, line, '|') orelse return error.InvalidRuleFormat;
            const p1 = try std.fmt.parseInt(usize, line[0..p], 10);
            const p2 = try std.fmt.parseInt(usize, line[p + 1 ..], 10);

            var entry = try rules.getOrPut(p1);
            if (entry.found_existing) {
                try entry.value_ptr.append(p2);
            } else {
                entry.value_ptr.* = UsizeList.init(allocator);
                try entry.value_ptr.append(p2);
            }
        }

        while (it.next()) |raw_line| {
            const line = std.mem.trim(u8, raw_line, " ");
            if (line.len == 0) break;

            var pgs = UsizeList.init(allocator);
            var pgit = std.mem.tokenizeScalar(u8, line, ',');
            while (pgit.next()) |p| {
                const pg = try std.fmt.parseInt(usize, p, 10);
                try pgs.append(pg);
            }
            try updates.append(pgs);
        }

        return .{
            .rules = rules,
            .updates = updates,
        };
    }

    pub fn deinit(self: *Puzzle) void {
        var rit = self.rules.iterator();
        while (rit.next()) |entry| {
            entry.value_ptr.deinit();
        }
        self.rules.deinit();
        for (self.updates.items) |u| {
            u.deinit();
        }
        self.updates.deinit();
    }

    pub fn dump(self: Puzzle) void {
        var rule_it = self.rules.iterator();
        std.debug.print("rules:\n", .{});
        while (rule_it.next()) |entry| {
            std.debug.print("k: {}: ", .{entry.key_ptr.*});
            for (entry.value_ptr.*.items) |p| {
                std.debug.print("{},", .{p});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("updates:\n", .{});
        for (self.updates.items, 0..) |u, i| {
            std.debug.print("{} : ", .{i});
            for (u.items) |p| {
                std.debug.print("{},", .{p});
            }
            std.debug.print("\n", .{});
        }
    }
};

fn part_one(input: []const u8) !usize {
    var answer: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var puzzle = try Puzzle.parse(allocator, input);
    defer puzzle.deinit();

    // puzzle.dump();

    for (puzzle.updates.items) |update| {
        var valid = true;
        upd: for (1..update.items.len) |i| {
            if (puzzle.rules.get(update.items[i])) |entry| {
                for (update.items[0..i]) |p| {
                    if (std.mem.indexOfScalar(usize, entry.items, p) != null) {
                        valid = false;
                        break :upd;
                    }
                }
            }
        }
        if (valid) {
            const middle = update.items.len / 2;
            answer += update.items[middle];
        }
    }

    return answer;
}

fn part_two(input: []const u8) !usize {
    var answer: usize = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var puzzle = try Puzzle.parse(allocator, input);
    defer puzzle.deinit();

    // puzzle.dump();

    for (puzzle.updates.items) |update| {
        var valid = true;
        upd: for (1..update.items.len) |i| {
            if (puzzle.rules.get(update.items[i])) |entry| {
                for (update.items[0..i]) |p| {
                    if (std.mem.indexOfScalar(usize, entry.items, p) != null) {
                        valid = false;
                        break :upd;
                    }
                }
            }
        }
        if (valid) {
            // const middle = update.items.len / 2;
            // answer += update.items[middle];
        } else {
            // re-sort: update.items
            std.mem.sort(usize, update.items, puzzle, lessThan);
            const middle = update.items.len / 2;
            answer += update.items[middle];
        }
    }

    return answer;
}

fn lessThan(puzzle: Puzzle, first: usize, second: usize) bool {
    if (puzzle.rules.get(second)) |rule| {
        if (std.mem.indexOfScalar(usize, rule.items, first)) |_| {
            return true;
        }
    }
    return false;
}

pub fn main() !void {
    std.debug.print("Day 05 ----\n", .{});

    const p1 = try part_one(puzzle_input);
    std.debug.print("part one: {}\n", .{p1});

    const p2 = try part_two(puzzle_input);
    std.debug.print("part two: {}\n", .{p2});
}

test "part one" {
    const expected: usize = 143;
    const actual = try part_one(test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED.\n", .{});
}

test "part two" {
    const expected: usize = 123;
    const actual = try part_two(test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED.\n", .{});
}
