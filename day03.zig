// https://adventofcode.com/2024/day/3
// p1: 161289189
const std = @import("std");

const puzzle_data = @embedFile("day03_data.txt");
const test_data = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

pub fn main() !void {
    std.log.info("Day 03", .{});

    const p1 = try part_one(puzzle_data);
    std.log.info("Answer (p1): {}", .{p1});

    // const p2 = try part_two(puzzle_data);
    // std.log.info("Answer (p2): {}", .{p2});
}

const ParserReader = struct {
    text: []const u8,
    started: bool = false,
    idx: usize = undefined,

    pub fn init(text: []const u8) ParserReader {
        return .{ .text = text };
    }

    pub fn pos(self: ParserReader) usize {
        return if (self.started) self.idx else 0;
    }

    pub fn eof(self: ParserReader) bool {
        return self.started and (self.idx >= self.text.len);
    }

    pub fn peek(self: *ParserReader) ?u8 {
        const i = if (self.started) self.idx else 0;
        if (i >= self.text.len) return null;
        return self.text[i];
    }

    pub fn next(self: *ParserReader) ?u8 {
        if (!self.started) {
            self.started = true;
            self.idx = 0;
        } else {
            self.idx += 1;
        }
        if (self.idx >= self.text.len) {
            return null;
        } else {
            return self.text[self.idx];
        }
    }

    pub fn back(self: *ParserReader) void {
        if (self.idx > 0) self.idx -= 1;
    }
};

fn parseSeq(reader: *ParserReader, seq: []const u8) ?struct { start: usize, len: usize } {
    var len: usize = 0;
    var st: usize = undefined;
    for (seq) |x| {
        if (reader.next()) |a| {
            if (x != a) {
                if (len > 0) {
                    reader.back();
                }
                return null;
            }
            if (len == 0) st = reader.pos();
            len += 1;
        } else return null;
    }
    return .{ .start = st, .len = len };
}

fn parseAny(reader: *ParserReader, vals: []const u8) ?struct { start: usize, len: usize } {
    var st: usize = undefined;
    var len: usize = 0;
    while (reader.next()) |a| {
        if (std.mem.indexOfScalar(u8, vals, a)) |_| {
            if (len == 0) st = reader.pos();
            len += 1;
        } else {
            if (len > 0) {
                reader.back();
            }
            break;
        }
    }
    if (len == 0) return null;
    return .{ .start = st, .len = len };
}

fn parseScalar(reader: *ParserReader, exp: u8) ?usize {
    if (reader.next()) |a| {
        if (exp == a) {
            return reader.pos();
        } else {
            reader.back();
            return null;
        }
    } else {
        return null;
    }
}

fn part_one(input: []const u8) !usize {
    var tokenizer = std.mem.tokenizeScalar(u8, input, '\n');
    var answer: usize = 0;
    while (tokenizer.next()) |line| {
        var reader = ParserReader.init(line);
        while (!reader.eof()) {
            if (parseSeq(&reader, "mul")) |_| {
                if (parseScalar(&reader, '(')) |_| {
                    if (parseAny(&reader, "0123456789")) |tlhs| {
                        const ltxt = line[tlhs.start .. tlhs.start + tlhs.len];
                        const lhs = try std.fmt.parseInt(u32, ltxt, 10);
                        if (parseScalar(&reader, ',')) |_| {
                            if (parseAny(&reader, "0123456789")) |trhs| {
                                const rtxt = line[trhs.start .. trhs.start + trhs.len];
                                const rhs = try std.fmt.parseInt(u32, rtxt, 10);
                                if (parseScalar(&reader, ')')) |_| {
                                    answer += (lhs * rhs);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return answer;
}

test "test reader" {
    const expected = "ABCDEF";
    var reader = ParserReader.init(expected);
    var res = std.ArrayList(u8).init(std.testing.allocator);
    defer res.deinit();
    while (reader.next()) |c| {
        try res.append(c);
    }
    const actual = res.items;
    std.testing.expect(std.mem.eql(u8, expected, actual)) catch |err| {
        std.debug.print("READER test FAILED.  expected {s} got {s}.\n", .{ expected, actual });
        return err;
    };
    std.debug.print("READER test PASSED.\n", .{});
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
