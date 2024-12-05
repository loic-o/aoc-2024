const std = @import("std");

const puzzle_input = @embedFile("day05_data.txt");
const test_input = "";

pub fn main() !void {
    std.debug.print("Day 05 ----\n", .{});

    const p1 = try part_one(puzzle_input);
    std.debug.print("part one: {}\n", .{p1});

    const p2 = try part_two(puzzle_input);
    std.debug.print("part two: {}\n", .{p2});
}

fn part_one(input: []const u8) !usize {
    _ = input;
    return 0;
}

fn part_two(input: []const u8) !usize {
    _ = input;
    return 0;
}

test "part one" {
    const expected: usize = 0;
    const actual = try part_one(test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED.\n", .{});
}

test "part two" {
    const expected: usize = 0;
    const actual = try part_two(test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED.\n", .{});
}
