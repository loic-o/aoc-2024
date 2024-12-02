// https://adventofcode.com/2024/day/1
const std = @import("std");

const test_data =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
;

const puzzle_data = @import("day01_data.zig").data;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    std.log.info("Day 01", .{});

    var answer = try part_one_solve(allocator, puzzle_data);
    std.log.info("Answer (p1): {}", .{answer});

    answer = try part_two_solve(allocator, puzzle_data);
    std.log.info("Answer (p2): {}", .{answer});
}

fn parse(allocator: std.mem.Allocator, data: []const u8) !struct {
    left: std.ArrayList(usize),
    right: std.ArrayList(usize),
} {
    var left = std.ArrayList(usize).init(allocator);
    var right = std.ArrayList(usize).init(allocator);

    var next_start: usize = 0;
    while (next_start < data.len) {
        const pos = std.mem.indexOf(u8, data, "\n");
        const line = blk: {
            const this_start = next_start;
            if (pos) |p| {
                next_start += p + 1;
                break :blk data[this_start .. this_start + p];
            } else {
                next_start = data.len;
                break :blk data[this_start..];
            }
        };
        const pos1 = std.mem.indexOf(u8, line, " ").?;
        const pos2 = std.mem.lastIndexOf(u8, line, " ").?;

        const lval = try std.fmt.parseInt(usize, line[0..pos1], 10);
        const rval = try std.fmt.parseInt(usize, line[pos2 + 1 ..], 10);

        try left.append(lval);
        try right.append(rval);
    }
    std.debug.assert(left.items.len == right.items.len);

    std.mem.sort(usize, left.items, {}, std.sort.asc(usize));
    std.mem.sort(usize, right.items, {}, std.sort.asc(usize));

    return .{ .left = left, .right = right };
}

fn part_one_solve(allocator: std.mem.Allocator, data: []const u8) !usize {
    var answer: usize = 0;

    const lists = try parse(allocator, data);
    defer lists.left.deinit();
    defer lists.right.deinit();

    for (lists.left.items, lists.right.items) |l, r| {
        if (l < r) {
            answer += (r - l);
        } else {
            answer += (l - r);
        }
    }

    return answer;
}

fn part_two_solve(allocator: std.mem.Allocator, data: []const u8) !usize {
    var answer: usize = 0;

    const lists = try parse(allocator, data);
    defer lists.left.deinit();
    defer lists.right.deinit();

    for (lists.left.items) |i| {
        const cnt = std.mem.count(usize, lists.right.items, &[_]usize{i});
        answer += (i * cnt);
    }

    return answer;
}

test "part one test" {
    const answer = try part_one_solve(std.testing.allocator, test_data);
    try std.testing.expect(answer == 11);
}

test "part two test" {
    const answer = try part_two_solve(std.testing.allocator, test_data);
    try std.testing.expect(answer == 31);
}
