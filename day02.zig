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

fn part_one_solve(allocator: std.mem.Allocator, data: []const u8) !usize {
    var safe_count: usize = 0;

    const Dir = enum {
        incr,
        decr,
        unkn,
    };

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

        var dir = Dir.unkn;
        var safe = true;

        for (0..levels.items.len - 1) |i| {
            const diff: i32 = @as(i32, @intCast(levels.items[i + 1])) - @as(i32, @intCast(levels.items[i]));

            if (diff == 0 or @abs(diff) > 3) {
                safe = false;
                break;
            }

            switch (dir) {
                .unkn => if (diff > 0) {
                    dir = .incr;
                } else {
                    dir = .decr;
                },
                .incr => if (diff < 0) {
                    safe = false;
                    break;
                },
                .decr => if (diff > 0) {
                    safe = false;
                    break;
                },
            }
        }

        if (safe) {
            safe_count += 1;
        }

        // std.log.debug("[{s}...{any}...{}]", .{ record, levels.items, safe });
    } else |err| {
        // expecting EOF, otherwise fail
        std.debug.assert(err == parse.LineReaderError.EOF);
    }

    return safe_count;
}

fn part_two_solve(allocator: std.mem.Allocator, data: []const u8) !usize {
    _ = allocator;
    _ = data;
    return 0;
}

test "part one test" {
    const answer = try part_one_solve(std.testing.allocator, test_data);
    try std.testing.expect(answer == 2);
}

test "part two test" {
    const answer = try part_two_solve(std.testing.allocator, test_data);
    try std.testing.expect(answer == 0);
}
