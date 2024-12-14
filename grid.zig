const std = @import("std");

pub const Loc = struct {
    col: usize = 0,
    row: usize = 0,
};

pub const Dir = enum {
    north,
    east,
    south,
    west,
};

pub const Grid = struct {
    data: []const u8,

    width: usize,
    height: usize,

    const Self = @This();

    pub fn fromInput(input: []const u8) Self {
        const w = if (std.mem.indexOfScalar(u8, input, '\n')) |p| p else input.len;
        var h = std.mem.count(u8, input, "\n");

        if (h == 0) {
            h += 1;
        } else {
            const lnl = std.mem.lastIndexOfScalar(u8, input, '\n') orelse 1;
            if (lnl < input.len - 1) h += 1;
        }

        return Self{
            .data = input,
            .width = w,
            .height = h,
        };
    }

    pub fn locOfIndex(self: Self, idx: usize) ?Loc {
        if (idx >= self.data.len) return null;
        const r = idx / (self.width + 1);
        const c = idx - ((self.width + 1) * r);
        return Loc{
            .row = r,
            .col = c,
        };
    }

    pub fn indexOfLoc(self: Self, loc: Loc) ?usize {
        if (!self.isLocValid(loc)) return null;
        const idx = loc.row * (self.width + 1) + loc.col;
        return idx;
    }

    pub fn locOfScalar(self: Self, value: u8) ?Loc {
        if (std.mem.indexOfScalar(u8, self.data, value)) |p| {
            return self.locOfIndex(p);
        } else {
            return null;
        }
    }

    pub fn isLocValid(self: Self, loc: Loc) bool {
        if (loc.row > self.height) return false;
        if (loc.col > self.width) return false;
        return true;
    }

    pub fn get(self: Self, loc: Loc) ?u8 {
        if (!self.isLocValid(loc)) return null;
        const idx = self.indexOfLoc(loc) orelse return null;
        return self.data[idx];
    }

    pub fn move(self: Self, loc: Loc, dir: Dir) ?Loc {
        var new_loc = loc;
        switch (dir) {
            .north => {
                if (new_loc.row > 0) {
                    new_loc.row -= 1;
                } else {
                    return null;
                }
            },
            .east => {
                if (new_loc.col < self.width - 1) {
                    new_loc.col += 1;
                } else {
                    return null;
                }
            },
            .south => {
                if (new_loc.row < self.height - 1) {
                    new_loc.row += 1;
                } else {
                    return null;
                }
            },
            .west => {
                if (new_loc.col > 0) {
                    new_loc.col -= 1;
                } else {
                    return null;
                }
            },
        }
        return new_loc;
    }
};

fn assert_equal(comptime T: type, expected: T, actual: T, msg: []const u8) !void {
    std.testing.expect(actual == expected) catch |err| {
        std.debug.print("{s} => expected: {}, got: {}\n", .{ msg, expected, actual });
        return err;
    };
}

test "dims" {
    const test_input =
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
    ;

    const grid = Grid.fromInput(test_input);
    try assert_equal(usize, 8, grid.width, "grid width");
    try assert_equal(usize, 8, grid.height, "grid height");
}

test "placement" {
    const test_input =
        \\123
        \\456
        \\789
    ;
    const grid = Grid.fromInput(test_input);
    const loc = grid.locOfScalar('5') orelse return error.TestUnexpectedResult;

    try assert_equal(usize, 1, loc.row, "loc.row");
    try assert_equal(usize, 1, loc.col, "loc.col");
}

test "get and move" {
    const test_input =
        \\123
        \\456
        \\789
    ;

    const grid = Grid.fromInput(test_input);
    var loc = Loc{ .row = 1, .col = 1 };

    try assert_equal(u8, '5', grid.get(loc).?, "get initial");

    loc = grid.move(loc, Dir.north).?;
    try assert_equal(u8, '2', grid.get(loc).?, "get post move N");

    loc = grid.move(loc, Dir.west).?;
    try assert_equal(u8, '1', grid.get(loc).?, "get post move W");

    loc = grid.move(loc, Dir.south).?;
    try assert_equal(u8, '4', grid.get(loc).?, "get post move S");

    loc = grid.move(loc, Dir.east).?;
    try assert_equal(u8, '5', grid.get(loc).?, "get post move E");

    loc.col = 2;
    try std.testing.expect(grid.move(loc, .east) == null);

    loc.row = 0;
    try std.testing.expect(grid.move(loc, .north) == null);

    loc.row = 2;
    try std.testing.expect(grid.move(loc, .south) == null);

    loc.col = 0;
    try std.testing.expect(grid.move(loc, .west) == null);
}
