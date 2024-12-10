const std = @import("std");
// answers:
// part 1: 6201130364722
// part 2: ?

const puzzle_input = @embedFile("day09_data.txt");
const test_input = "2333133121414131402";

fn part_one(allocator: std.mem.Allocator, input: []const u8) !usize {
    _ = allocator;

    var checksum: usize = 0;
    var block_num: usize = 0;

    var i: usize = 0;
    var j: usize = input.len - 1;

    var mt_rem: usize = 0;
    var mv_rem: usize = 0;

    while (i < j) {
        if (i % 2 == 0) {
            std.debug.assert(mt_rem == 0);
            // if i gets to it, its not moving, so fill in the blocks for this file
            const file_size = try std.fmt.parseInt(usize, input[i .. i + 1], 10);

            for (0..file_size) |_| {
                // std.debug.print("{}", .{i / 2});
                checksum += (block_num * (i / 2));
                block_num += 1;
            }
            i += 1;
            mt_rem = try std.fmt.parseInt(usize, input[i .. i + 1], 10);
        }
        if (j % 2 == 1) {
            std.debug.assert(mv_rem == 0);
            j -= 1;
        }
        if (mv_rem == 0) {
            mv_rem = try std.fmt.parseInt(usize, input[j .. j + 1], 10);
        }
        std.debug.assert(i % 2 == 1);
        std.debug.assert(j % 2 == 0);
        while (mv_rem > 0 and mt_rem > 0) {
            // std.debug.print("{}", .{j / 2});
            checksum += (block_num * (j / 2));
            block_num += 1;
            mv_rem -= 1;
            mt_rem -= 1;
        }
        if (mt_rem == 0) i += 1;
        if (mv_rem == 0) j -= 1;
    }

    while (mv_rem > 0) {
        // std.debug.print("{}", .{j / 2});
        checksum += (block_num * (j / 2));
        block_num += 1;
        mv_rem -= 1;
    }

    // std.debug.print("\n", .{});

    return checksum;
}

fn part_two(allocator: std.mem.Allocator, input: []const u8) !usize {
    _ = allocator;
    _ = input;
    return 0;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    std.debug.print("Day 09 ----\n", .{});

    var start = try std.time.Instant.now();
    const p1 = try part_one(allocator, puzzle_input);
    var end = try std.time.Instant.now();

    var elps: f64 = @as(f64, @floatFromInt(end.since(start))) / std.time.ns_per_ms;

    std.debug.print("part one: {} ... {d:.3}ms\n", .{ p1, elps });

    start = try std.time.Instant.now();
    const p2 = try part_two(allocator, puzzle_input);
    end = try std.time.Instant.now();

    elps = @as(f64, @floatFromInt(end.since(start))) / std.time.ns_per_ms;

    std.debug.print("part two: {} ... {d:.3}ms\n", .{ p2, elps });
}

test "part one" {
    const expected: usize = 1928;
    const actual = try part_one(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED {} = {}.\n", .{ expected, actual });
}

test "part two" {
    const expected: usize = 2858;
    const actual = try part_two(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED {} = {}.\n", .{ expected, actual });
}
