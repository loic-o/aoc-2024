/// https://adventofcode.com/2024/day/2
const std = @import("std");

const parse = @import("parse.zig");

const test_data =
    \\7 6 4 2 1
    \\1 2 7 8 9
    \\9 7 6 2 1
    \\1 3 2 4 5
    \\8 6 4 4 1
    \\1 3 6 7 9
;

const puzzle_data = @import("day02_data.zig").data;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    std.log.info("Day 02", .{});

    var answer = try part_one_solve(allocator, puzzle_data);
    std.log.info("Answer (p1): {}", .{answer});

    answer = try part_two_solve(allocator, puzzle_data);
    std.log.info("Answer (p2): {}", .{answer});
}

const Dir = enum {
    incr,
    decr,
    unkn,
};

const LevelError = error{ Constant, TooLarge, DirFlip };

fn check_pair(first: u32, second: u32, dir: Dir) LevelError!Dir {
    const diff: i32 = @as(i32, @intCast(second)) - @as(i32, @intCast(first));
    const new_dir: Dir = if (diff > 0) .incr else .decr;

    if (diff == 0) return LevelError.Constant;
    if (@abs(diff) > 3) return LevelError.TooLarge;
    if (dir != .unkn and new_dir != dir) return LevelError.DirFlip;

    return new_dir;
}

const ReportResult = struct {
    safe: bool = true,
    fail_idx: ?usize = null,
    fail_err: ?LevelError = null,
};

fn check_report(levels: []const u32) ReportResult {
    var dir = Dir.unkn;
    for (0..levels.len - 1) |i| {
        dir = check_pair(levels[i], levels[i + 1], dir) catch |err| {
            return .{
                .safe = false,
                .fail_idx = i,
                .fail_err = err,
            };
        };
    }
    return .{ .safe = true };
}

fn part_one_solve(allocator: std.mem.Allocator, data: []const u8) !usize {
    var safe_count: usize = 0;

    var reader = parse.LineReader.init(data);

    var levels = std.ArrayList(u32).init(allocator);
    defer levels.deinit();

    while (reader.next()) |record| {
        levels.clearRetainingCapacity();

        var parser = parse.IntParser(u32).init(record);

        while (parser.next()) |level| {
            if (level) |l| {
                try levels.append(l);
            } else {
                break;
            }
        } else |err| {
            // this is likely i parsing error
            std.debug.panic("parse err {} on [{s}]...so far {any}", .{ err, record, levels.items });
            return err;
        }

        const result = check_report(levels.items);
        if (result.safe) safe_count += 1;
    } else |err| {
        // expecting EOF, otherwise fail
        std.debug.assert(err == parse.LineReaderError.EOF);
    }

    return safe_count;
}

fn part_two_solve(allocator: std.mem.Allocator, data: []const u8) !usize {
    var safe_count: usize = 0;

    var reader = parse.LineReader.init(data);

    var levels = std.ArrayList(u32).init(allocator);
    defer levels.deinit();

    while (reader.next()) |record| {
        levels.clearRetainingCapacity();

        var parser = parse.IntParser(u32).init(record);

        while (parser.next()) |maybe_level| {
            if (maybe_level) |level| {
                try levels.append(level);
            } else {
                break;
            }
        } else |err| {
            // this is likely i parsing error
            std.debug.panic("parse err {} on [{s}]...so far {any}", .{ err, record, levels.items });
            return err;
        }

        const result = check_report(levels.items);
        if (result.safe) {
            safe_count += 1;
        } else {
            inner: for (0..levels.items.len) |i| {
                const damp = try std.mem.concat(allocator, u32, &[_][]const u32{
                    levels.items[0..i],
                    levels.items[i + 1 ..],
                });
                defer allocator.free(damp);
                const r2 = check_report(damp);
                if (r2.safe) {
                    safe_count += 1;
                    break :inner;
                }
            }
        }
    } else |err| {
        // expecting EOF, otherwise fail
        std.debug.assert(err == parse.LineReaderError.EOF);
    }

    return safe_count;
}

test "part one test" {
    const expected = 2;
    const actual = try part_one_solve(std.testing.allocator, test_data);
    std.testing.expect(actual == expected) catch |err| {
        std.debug.print("expected {}, got {}\n", .{ expected, actual });
        return err;
    };
    std.debug.print("part one test PASSED.\n", .{});
}

test "part two test" {
    const expected = 4;
    const actual = try part_two_solve(std.testing.allocator, test_data);
    std.testing.expect(actual == expected) catch |err| {
        std.debug.print("expected {}, got {}\n", .{ expected, actual });
        return err;
    };
    std.debug.print("part one test PASSED.\n", .{});
}
