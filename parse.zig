const std = @import("std");

pub const LineReaderError = error{EOF};

pub const LineReader = struct {
    const Self = @This();

    data: []const u8,
    line_start: usize = 0,

    pub fn init(data: []const u8) Self {
        return Self{
            .data = data,
        };
    }

    pub fn next(self: *Self) ![]const u8 {
        if (self.line_start >= self.data.len) {
            return LineReaderError.EOF;
        }

        const pos = std.mem.indexOf(u8, self.data[self.line_start..], "\n");

        const ln = blk: {
            const st = self.line_start;
            if (pos) |p| {
                self.line_start += p + 1;
                break :blk self.data[st .. st + p];
            } else {
                self.line_start = self.data.len;
                break :blk self.data[st..];
            }
        };

        return ln;
    }
};

pub fn IntParser(comptime T: type) type {
    return struct {
        const Self = @This();
        buf: []const u8,
        next_st: usize = 0,

        pub fn init(buf: []const u8) Self {
            return Self{
                .buf = buf,
            };
        }

        pub fn next(self: *Self) !?T {
            if (self.next_st >= self.buf.len) {
                return null;
            }
            const pos = std.mem.indexOf(u8, self.buf[self.next_st..], " ");
            const tok = blk: {
                const st = self.next_st;
                if (pos) |p| {
                    self.next_st += p + 1;
                    break :blk self.buf[st .. st + p];
                } else {
                    self.next_st = self.buf.len;
                    break :blk self.buf[st..];
                }
            };
            return std.fmt.parseInt(T, tok, 10) catch |err| {
                std.log.debug("parse err on pos {any}", .{pos});
                return err;
            };
        }
    };
}

const test_data =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\5 6 5 8 10 12 17
;

test "read lines" {
    var reader = LineReader.init(test_data);

    var line = try reader.next();
    try std.testing.expect(std.mem.eql(u8, line, "7 6 4 2 1"));

    line = try reader.next();
    try std.testing.expect(std.mem.eql(u8, line, "1 2 7 8 9"));

    line = try reader.next(); // 9 7 ...
    line = try reader.next(); // 1 3 ...
    line = try reader.next(); // 8 6 ...

    line = try reader.next();
    std.testing.expect(std.mem.eql(u8, line, "5 6 5 8 10 12 17")) catch |err| {
        std.log.err("got: {s}", .{line});
        return err;
    };

    const eof = reader.next();
    try std.testing.expect(eof == LineReaderError.EOF);
}

test "parse line" {
    var parser = IntParser(usize).init("5 6 5 8 10 12 17");

    var val = try parser.next();
    if (val) |v| {
        return std.testing.expect(v == 5);
    } else {
        return error.ValueWasNull;
    }

    val = try parser.next();
    if (val) |v| {
        return std.testing.expect(v == 6);
    } else {
        return error.ValueWasNull;
    }

    val = try parser.next(); // 5;
    val = try parser.next(); // 8;

    val = try parser.next();
    if (val) |v| {
        return std.testing.expect(v == 10);
    } else {
        return error.ValueWasNull;
    }

    val = try parser.next(); // 12;
    val = try parser.next(); // 17;

    val = try parser.next();
    std.testing.expect(val == null);
}
