const std = @import("std");
// answers:
// p1: 398
// p2: 1333

const puzzle_input = @embedFile("day08_data.txt");
const test_input =
    \\............
    \\........0...
    \\.....0......
    \\.......0....
    \\....0.......
    \\......A.....
    \\............
    \\............
    \\........A...
    \\.........A..
    \\............
    \\............
;

const Loc = struct {
    x: isize,
    y: isize,
};

const LocList = std.ArrayList(Loc);

fn part_one(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;

    var line_toks = std.mem.tokenizeScalar(u8, input, '\n');

    var line_count: usize = 0;
    var line_len: usize = 0;

    var antennae = std.AutoHashMap(u8, LocList).init(allocator);
    defer {
        var values = antennae.valueIterator();
        while (values.next()) |ll| {
            ll.deinit();
        }
        antennae.deinit();
    }

    while (line_toks.next()) |line| {
        if (line_count == 0) {
            line_len = line.len;
        }
        std.debug.assert(line.len == line_len);

        for (line, 0..) |ch, x| {
            if (ch < '0' or ch > 'z') continue;

            const loc = Loc{ .x = @as(isize, @intCast(x)), .y = @as(isize, @intCast(line_count)) };

            const gp_result = try antennae.getOrPut(ch);
            if (gp_result.found_existing) {
                try gp_result.value_ptr.*.append(loc);
            } else {
                gp_result.value_ptr.* = LocList.init(allocator);
                try gp_result.value_ptr.append(loc);
            }
        }

        line_count += 1;
    }

    var antinodes = try std.DynamicBitSet.initEmpty(allocator, line_count * line_len);
    defer antinodes.deinit();

    var antenna = antennae.valueIterator();
    while (antenna.next()) |locs| {
        for (0..locs.items.len - 1) |i| {
            for (i + 1..locs.items.len) |j| {
                const l1 = locs.items[i];
                const l2 = locs.items[j];

                const dx = l1.x - l2.x;
                const dy = l1.y - l2.y;

                var ax = l1.x + dx;
                var ay = l1.y + dy;

                if (ax >= 0 and ax < line_len and ay >= 0 and ay < line_count) {
                    const b = @as(usize, @intCast(ay * @as(isize, @intCast(line_len)) + ax));
                    antinodes.set(b);
                }

                ax = l2.x - dx;
                ay = l2.y - dy;

                if (ax >= 0 and ax < line_len and ay >= 0 and ay < line_count) {
                    const b = @as(usize, @intCast(ay * @as(isize, @intCast(line_len)) + ax));
                    antinodes.set(b);
                }
            }
        }
    }

    answer = antinodes.count();
    return answer;
}

fn part_two(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;

    var line_toks = std.mem.tokenizeScalar(u8, input, '\n');

    var line_count: usize = 0;
    var line_len: usize = 0;

    var antennae = std.AutoHashMap(u8, LocList).init(allocator);
    defer {
        var values = antennae.valueIterator();
        while (values.next()) |ll| {
            ll.deinit();
        }
        antennae.deinit();
    }

    while (line_toks.next()) |line| {
        if (line_count == 0) {
            line_len = line.len;
        }
        std.debug.assert(line.len == line_len);

        for (line, 0..) |ch, x| {
            if (ch < '0' or ch > 'z') continue;

            const loc = Loc{ .x = @as(isize, @intCast(x)), .y = @as(isize, @intCast(line_count)) };

            const gp_result = try antennae.getOrPut(ch);
            if (gp_result.found_existing) {
                try gp_result.value_ptr.*.append(loc);
            } else {
                gp_result.value_ptr.* = LocList.init(allocator);
                try gp_result.value_ptr.append(loc);
            }
        }

        line_count += 1;
    }

    var antinodes = try std.DynamicBitSet.initEmpty(allocator, line_count * line_len);
    defer antinodes.deinit();

    var antenna = antennae.valueIterator();
    while (antenna.next()) |locs| {
        for (0..locs.items.len - 1) |i| {
            for (i + 1..locs.items.len) |j| {
                const l1 = locs.items[i];
                const l2 = locs.items[j];

                const dx = l1.x - l2.x;
                const dy = l1.y - l2.y;

                var ax = l1.x;
                var ay = l1.y;

                while (true) {
                    if (ax >= 0 and ax < line_len and ay >= 0 and ay < line_count) {
                        const b = @as(usize, @intCast(ay * @as(isize, @intCast(line_len)) + ax));
                        antinodes.set(b);
                    } else break;
                    ax += dx;
                    ay += dy;
                }

                ax = l2.x;
                ay = l2.y;

                while (true) {
                    if (ax >= 0 and ax < line_len and ay >= 0 and ay < line_count) {
                        const b = @as(usize, @intCast(ay * @as(isize, @intCast(line_len)) + ax));
                        antinodes.set(b);
                    } else break;
                    ax -= dx;
                    ay -= dy;
                }
            }
        }
    }

    answer = antinodes.count();
    return answer;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    std.debug.print("Day 08 ----\n", .{});

    const p1 = try part_one(allocator, puzzle_input);
    std.debug.print("part one: {}\n", .{p1});

    const p2 = try part_two(allocator, puzzle_input);
    std.debug.print("part two: {}\n", .{p2});
}

test "part one" {
    const expected: usize = 14;
    const actual = try part_one(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED.\n", .{});
}

test "part two" {
    const expected: usize = 34;
    const actual = try part_two(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED.\n", .{});
}
