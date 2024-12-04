// https://adventofcode.com/2024/day/3
// p1: 161289189
// p2: 83595109
const std = @import("std");

const puzzle_data = @embedFile("day03_data.txt");
const test_data = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
const test_data2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

pub fn main() !void {
    std.log.info("Day 03", .{});

    const p1 = try part_one(puzzle_data);
    std.log.info("Answer (p1): {}", .{p1});

    const p2 = try part_two(puzzle_data);
    std.log.info("Answer (p2): {}", .{p2});
}

fn part_one(input: []const u8) !usize {
    var idx: usize = 0;
    var answer: usize = 0;
    outer: while (idx < input.len) {
        if (idx < input.len - 4 and std.mem.eql(u8, "mul(", input[idx .. idx + 4])) {
            idx += 4;
            var m = idx;
            while (idx < input.len and std.ascii.isDigit(input[idx])) {
                idx += 1;
            }
            if (idx == m) continue :outer;
            const lhs = try std.fmt.parseInt(usize, input[m..idx], 10);
            if (input[idx] != ',') continue :outer;
            idx += 1;
            m = idx;
            while (idx < input.len and std.ascii.isDigit(input[idx])) {
                idx += 1;
            }
            if (idx == m) continue :outer;
            const rhs = try std.fmt.parseInt(usize, input[m..idx], 10);
            if (input[idx] != ')') continue :outer;
            idx += 1;
            // std.debug.print("{} x {}\n", .{ lhs, rhs });
            answer += lhs * rhs;
        } else {
            idx += 1;
        }
    }
    return answer;
}

// const test_data2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

fn part_two(input: []const u8) !usize {
    var idx: usize = 0;
    var answer: usize = 0;
    var enabled = true;
    outer: while (idx < input.len) {
        if (idx < input.len - 7 and std.mem.eql(u8, "don't()", input[idx .. idx + 7])) {
            idx += 7;
            enabled = false;
        } else if (idx < input.len - 4 and std.mem.eql(u8, "do()", input[idx .. idx + 4])) {
            idx += 4;
            enabled = true;
        } else if (idx < input.len - 4 and std.mem.eql(u8, "mul(", input[idx .. idx + 4])) {
            idx += 4;
            var m = idx;
            while (idx < input.len and std.ascii.isDigit(input[idx])) {
                idx += 1;
            }
            if (idx == m) continue :outer;
            const lhs = try std.fmt.parseInt(usize, input[m..idx], 10);
            if (input[idx] != ',') continue :outer;
            idx += 1;
            m = idx;
            while (idx < input.len and std.ascii.isDigit(input[idx])) {
                idx += 1;
            }
            if (idx == m) continue :outer;
            const rhs = try std.fmt.parseInt(usize, input[m..idx], 10);
            if (input[idx] != ')') continue :outer;
            idx += 1;
            // std.debug.print("{} x {}\n", .{ lhs, rhs });
            if (enabled) answer += lhs * rhs;
        } else {
            idx += 1;
        }
    }
    return answer;
}

test "part one test" {
    const expected = 161;
    const actual = try part_one(test_data);
    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("p1: FAILED.  expected {} got {}\n", .{ expected, actual });
        return err;
    };
    std.debug.print("p1: PASSED\n", .{});
}

test "part one on test 2" {
    const expected = 161;
    const actual = try part_one(test_data2);
    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("p1.1: FAILED.  expected {} got {}\n", .{ expected, actual });
        return err;
    };
    std.debug.print("p1.1: PASSED\n", .{});
}

test "part two test" {
    const expected = 48;
    const actual = try part_two(test_data2);
    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("p2: FAILED.  expected {} got {}\n", .{ expected, actual });
        return err;
    };
    std.debug.print("p2: PASSED\n", .{});
}
