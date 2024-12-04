const std = @import("std");

// Answers:
// p1: 2662
// p2: 2034

const puzzle_data = @embedFile("day04_data.txt");
const test_data =
    \\MMMSXXMASM
    \\MSAMXMSMSA
    \\AMXSXMAAMM
    \\MSAMASMSMX
    \\XMASAMXAMM
    \\XXAMMXXAMA
    \\SMSMSASXSS
    \\SAXAMASAAA
    \\MAMMMXMMMM
    \\MXMXAXMASX
;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    std.debug.print("Day 04\n", .{});
    const p1answer = try part_one(allocator, puzzle_data);
    std.debug.print("part one: {}\n", .{p1answer});

    _ = gpa.detectLeaks();
    std.debug.print("Day 04\n", .{});
    const p2answer = try part_two(allocator, puzzle_data);
    std.debug.print("part two: {}\n", .{p2answer});

    _ = gpa.detectLeaks();
}

fn part_one(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var line_tokenzier = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_tokenzier.next()) |line| {
        try lines.append(line);
    }
    const board = lines.items;
    const width = board[0].len;
    const height = board.len;

    for (0..height) |j| {
        for (0..width) |i| {
            if (board[j][i] == 'X') {
                if (i <= width - 4 and std.mem.eql(u8, "XMAS", board[j][i .. i + 4])) {
                    answer += 1;
                }
                if (i >= 3 and std.mem.eql(u8, "SAMX", board[j][i - 3 .. i + 1])) {
                    answer += 1;
                }
                if (j <= height - 4) {
                    // can check down
                    if (board[j + 1][i] == 'M' and board[j + 2][i] == 'A' and board[j + 3][i] == 'S') {
                        answer += 1;
                    }
                    if (i <= width - 4) {
                        // can check diag right
                        if (board[j + 1][i + 1] == 'M' and board[j + 2][i + 2] == 'A' and board[j + 3][i + 3] == 'S') {
                            answer += 1;
                        }
                    }
                    if (i >= 3) {
                        // can check diag left
                        if (board[j + 1][i - 1] == 'M' and board[j + 2][i - 2] == 'A' and board[j + 3][i - 3] == 'S') {
                            answer += 1;
                        }
                    }
                }
                if (j >= 3) {
                    // can check up
                    if (board[j - 1][i] == 'M' and board[j - 2][i] == 'A' and board[j - 3][i] == 'S') {
                        answer += 1;
                    }
                    if (i <= width - 4) {
                        // can check diag right
                        if (board[j - 1][i + 1] == 'M' and board[j - 2][i + 2] == 'A' and board[j - 3][i + 3] == 'S') {
                            answer += 1;
                        }
                    }
                    if (i >= 3) {
                        // can check diag left
                        if (board[j - 1][i - 1] == 'M' and board[j - 2][i - 2] == 'A' and board[j - 3][i - 3] == 'S') {
                            answer += 1;
                        }
                    }
                }
            }
        }
    }

    return answer;
}

fn part_two(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;

    var lines = std.ArrayList([]const u8).init(allocator);
    defer lines.deinit();

    var line_tokenzier = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_tokenzier.next()) |line| {
        try lines.append(line);
    }
    const board = lines.items;
    const width = board[0].len;
    const height = board.len;

    for (1..height - 1) |j| {
        for (1..width - 1) |i| {
            if (board[j][i] == 'A') {
                if ((board[j - 1][i - 1] == 'M' and board[j + 1][i + 1] == 'S') or
                    (board[j - 1][i - 1] == 'S' and board[j + 1][i + 1] == 'M'))
                {
                    if ((board[j - 1][i + 1] == 'M' and board[j + 1][i - 1] == 'S') or
                        (board[j - 1][i + 1] == 'S' and board[j + 1][i - 1] == 'M'))
                    {
                        answer += 1;
                    }
                }
            }
        }
    }

    return answer;
}

test "part one" {
    const expected: usize = 18;
    const actual = try part_one(std.testing.allocator, test_data);
    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part ONE test FAIL - expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };
    std.debug.print("part ONE test PASSED.\n", .{});
}

test "part two" {
    const expected: usize = 9;
    const actual = try part_two(std.testing.allocator, test_data);
    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part TWO test FAIL - expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };
    std.debug.print("part TWO test PASSED.\n", .{});
}
