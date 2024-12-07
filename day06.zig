const std = @import("std");
// answers:
// p1: 5086
// p2: ????

const puzzle_input = @embedFile("day06_data.txt");
const test_input =
    \\....#.....
    \\.........#
    \\..........
    \\..#.......
    \\.......#..
    \\..........
    \\.#..^.....
    \\........#.
    \\#.........
    \\......#...
;

pub fn main() !void {
    std.debug.print("Day 06 ----\n", .{});

    const p1 = try part_one(puzzle_input);
    std.debug.print("part one: {}\n", .{p1});

    const p2 = try part_two(puzzle_input);
    std.debug.print("part two: {}\n", .{p2});
}

const Direction = enum(u8) {
    up = 1,
    down = 2,
    left = 4,
    right = 8,
};

fn turnRight(direction: Direction) Direction {
    return switch (direction) {
        .up => .right,
        .down => .left,
        .left => .up,
        .right => .down,
    };
}

fn reverse(direction: Direction) Direction {
    return switch (direction) {
        .up => .down,
        .down => .up,
        .left => .right,
        .right => .left,
    };
}

const Board = struct {
    allocator: std.mem.Allocator,
    lines: [][]u8,
    width: usize,
    height: usize,
    row: usize,
    col: usize,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, input: []const u8) !Self {
        var line_list = std.ArrayList([]u8).init(allocator);
        defer line_list.deinit();

        var line_reader = std.mem.tokenizeScalar(u8, input, '\n');
        while (line_reader.next()) |line| {
            try line_list.append(@constCast(line));
        }

        const my_lines = try line_list.toOwnedSlice();
        return Self{
            .allocator = allocator,
            .lines = my_lines,
            .width = my_lines[0].len,
            .height = my_lines.len,
            .col = 0,
            .row = 0,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.lines);
    }

    pub fn index(self: Self) usize {
        return (self.row * self.width) + self.width;
    }

    pub fn moveToChar(self: *Self, needle: u8) !void {
        for (self.lines, 0..) |line, row| {
            if (std.mem.indexOfScalar(u8, line, needle)) |c| {
                self.row = row;
                self.col = c;
                return;
            }
        }
        return error.UnableToLocatorChar;
    }

    pub fn peek(self: Self, direction: Direction) ?u8 {
        switch (direction) {
            .up => {
                if (self.row > 0) {
                    return self.lines[self.row - 1][self.col];
                }
                return null;
            },
            .down => {
                if (self.row < self.height - 1) {
                    return self.lines[self.row + 1][self.col];
                }
                return null;
            },
            .left => {
                if (self.col > 0) {
                    return self.lines[self.row][self.col - 1];
                }
                return null;
            },
            .right => {
                if (self.col < self.width - 1) {
                    return self.lines[self.row][self.col + 1];
                }
                return null;
            },
        }
    }

    pub fn move(self: *Self, direction: Direction) ?u8 {
        switch (direction) {
            .up => {
                if (self.row > 0) {
                    self.row -= 1;
                    return self.lines[self.row][self.col];
                }
                return null;
            },
            .down => {
                if (self.row < self.height - 1) {
                    self.row += 1;
                    return self.lines[self.row][self.col];
                }
                return null;
            },
            .left => {
                if (self.col > 0) {
                    self.col -= 1;
                    return self.lines[self.row][self.col];
                }
                return null;
            },
            .right => {
                if (self.col < self.width - 1) {
                    self.col += 1;
                    return self.lines[self.row][self.col];
                }
                return null;
            },
        }
    }

    pub fn dump(self: Self) void {
        for (self.lines) |line| {
            std.debug.print("{s}\n", .{line});
        }
    }
};

fn part_one(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var board = try Board.init(allocator, input);
    defer board.deinit();
    try board.moveToChar('^');

    std.debug.print("board: ({}x{}) st: ({}, {})\n", .{ board.width, board.height, board.col, board.row });

    var bitset = try std.DynamicBitSet.initEmpty(allocator, board.width * board.height);
    defer bitset.deinit();
    bitset.set(board.row * board.width + board.col);

    var dir = Direction.up;

    while (board.move(dir)) |c| {
        if (c == '#') {
            _ = board.move(reverse(dir));
            std.debug.print("(#<{},{}),", .{ board.col, board.row });
            dir = turnRight(dir);
        } else {
            std.debug.print("({},{}),", .{ board.col, board.row });
            bitset.set(board.row * board.width + board.col);
        }
    }
    std.debug.print("\n", .{});

    return bitset.count();
}

fn part_two(input: []const u8) !usize {
    _ = input;
    const answer: usize = 0;

    // 421 too low

    return answer;
}

test "part one" {
    const expected: usize = 41;
    const actual = try part_one(test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED.\n", .{});
}

test "part two" {
    const expected: usize = 6;
    const actual = try part_two(test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED.\n", .{});
}

// test "bitwise tests" {
//     const val: u8 = '@' + (1 | 2);
//     try std.testing.expect(val == 'C');

//     try std.testing.expect((val - '@') & 2 == 2);
// }
