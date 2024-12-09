const std = @import("std");

// answers:
// p1: 465126289353
// p2: 70597497486371

const puzzle_input = @embedFile("day07_data.txt");
const test_input =
    \\190: 10 19
    \\3267: 81 40 27
    \\83: 17 5
    \\156: 15 6
    \\7290: 6 8 6 15
    \\161011: 16 10 13
    \\192: 17 8 14
    \\21037: 9 7 18 13
    \\292: 11 6 16 20
;

const NEW_LINE = '\n';
const COLON = ':';
const SPACE = ' ';

const Equation = struct {
    result: usize,
    operands: []usize,
};

fn parse_equations(allocator: std.mem.Allocator, input: []const u8) !std.ArrayList(Equation) {
    var eq_list = std.ArrayList(Equation).init(allocator);

    var opnd_list = std.ArrayList(usize).init(allocator);
    defer opnd_list.deinit();

    var line_it = std.mem.tokenizeScalar(u8, input, NEW_LINE);
    while (line_it.next()) |line| {
        const p = std.mem.indexOfScalar(u8, line, COLON) orelse return error.InvalidFormat;
        const result = try std.fmt.parseInt(usize, line[0..p], 10);

        var opnd_it = std.mem.tokenizeScalar(u8, line[p + 2 ..], SPACE);
        while (opnd_it.next()) |o| {
            const v = try std.fmt.parseInt(usize, o, 10);
            try opnd_list.append(v);
        }

        const opnds = try opnd_list.toOwnedSlice();

        try eq_list.append(Equation{ .result = result, .operands = opnds });
    }

    return eq_list;
}

fn free_equations(allocator: std.mem.Allocator, equations: std.ArrayList(Equation)) void {
    for (equations.items) |eq| {
        allocator.free(eq.operands);
    }
    equations.deinit();
}

fn dump_equations(equations: []const Equation) void {
    for (equations) |eq| {
        std.debug.print("{}: {any}\n", .{ eq.result, eq.operands });
    }
}

fn part_one(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;

    const equations = try parse_equations(allocator, input);
    defer free_equations(allocator, equations);

    for (equations.items) |eq| {
        // std.debug.print("EQ: {} {any} ?= {}\n", .{ ei, eq.operands, eq.result });
        // loop through all the possible combos
        combo: for (0..std.math.pow(usize, 2, eq.operands.len - 1)) |combo_code| {
            // loop through all the ops in this combo
            var res: usize = eq.operands[0];
            var acc: usize = 0;
            for (0..eq.operands.len - 1) |ri| {
                const i = eq.operands.len - ri - 2;
                const pos_val = std.math.pow(usize, 2, i);
                if ((combo_code - acc) >= pos_val) {
                    // std.debug.print("* ", .{});
                    res *= eq.operands[ri + 1];
                    acc += pos_val;
                } else {
                    // std.debug.print("+ ", .{});
                    res += eq.operands[ri + 1];
                }
            }
            // std.debug.print(" = {}", .{res});
            if (res == eq.result) {
                // std.debug.print(" <-- WINNER\n", .{});
                answer += res;
                break :combo;
            }
            // std.debug.print("\n", .{});
        }
    }

    return answer;
}

fn part_two(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;

    const equations = try parse_equations(allocator, input);
    defer free_equations(allocator, equations);

    var concat_buff: [128]u8 = undefined;

    for (equations.items, 0..) |eq, j| {
        // loop through all the possible combos
        std.debug.print("{s}", .{if (j % 100 == 0) "|" else if (j % 10 == 0) "^" else "."});

        combo: for (0..std.math.pow(usize, 3, eq.operands.len - 1)) |combo| {
            // loop through all the ops in this combo
            var res: usize = eq.operands[0];
            var combo_code = combo;

            inner: for (0..eq.operands.len - 1) |ri| {
                const i = eq.operands.len - ri - 2;
                const pos_val = std.math.pow(usize, 3, i);

                if (res > eq.result) break :inner;

                if (combo_code >= pos_val) {
                    const op_code = combo_code / pos_val;
                    if (op_code == 1) {
                        // std.debug.print("* ", .{});
                        res *= eq.operands[ri + 1];
                    } else if (op_code == 2) {
                        // std.debug.print("c ", .{});
                        // prob for another day
                        const sv = try std.fmt.bufPrint(&concat_buff, "{}{}", .{ res, eq.operands[ri + 1] });
                        res = try std.fmt.parseInt(usize, sv, 10);
                    } else {
                        std.debug.print("WEIRD: {}/{}={}\n", .{ combo_code, pos_val, op_code });
                        unreachable;
                    }
                    combo_code -= (op_code * pos_val);
                } else {
                    // std.debug.print("+ ", .{});
                    res += eq.operands[ri + 1];
                }
            }

            // std.debug.print("\n", .{});
            if (res == eq.result) {
                answer += res;
                // got a working combination, so we can move to the next equation
                break :combo;
            }
        }
    }
    std.debug.print(".done.\n", .{});

    return answer;
}

pub fn main() !void {
    std.debug.print("Day 07 ----\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        if (gpa.deinit() == .leak) {
            std.debug.print("LEAKS DETECTED.\n", .{});
        }
    }
    const allocator = gpa.allocator();

    const p1 = try part_one(allocator, puzzle_input);
    std.debug.print("part one: {}\n", .{p1});

    const p2 = try part_two(allocator, puzzle_input);
    std.debug.print("part two: {}\n", .{p2});
}

test "part one" {
    const expected: usize = 3749;
    const actual = try part_one(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED.\n", .{});
}

test "part two" {
    const expected: usize = 11387;
    const actual = try part_two(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED.\n", .{});
}
