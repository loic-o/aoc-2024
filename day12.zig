// https://adventofcode.com/2024/day/12
// answers:
// part 1: 1477924
// part 2:
//
const std = @import("std");

const Grid = @import("grid.zig").Grid;
const Dir = @import("grid.zig").Dir;
const Loc = @import("grid.zig").Loc;

const Queue = @import("queue.zig").Queue;

const puzzle_input = @embedFile("day12_data.txt");
const test_input =
    \\RRRRIICCFF
    \\RRRRIICCCF
    \\VVRRRCCFFF
    \\VVRCCCJFFF
    \\VVVVCJJCFE
    \\VVIVCCJJEE
    \\VVIIICJJEE
    \\MIIIIIJJEE
    \\MIIISIJEEE
    \\MMMISSJEEE
;

fn part_one(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;

    const grid = Grid.fromInput(input);

    var mask = try std.DynamicBitSet.initFull(allocator, grid.width * grid.height);
    defer mask.deinit();

    var queue = Queue(Loc).init(allocator);
    defer queue.deinit();

    while (mask.findFirstSet()) |idx| {
        queue.clear();

        // find first non-filled index
        const plant = blk: {
            const loc = grid.locOfIndex(idx) orelse unreachable;
            try queue.enqueue(loc);
            break :blk grid.get(loc) orelse unreachable;
        };

        var area: usize = 0;
        var perim: usize = 0;

        while (queue.dequeue()) |loc| {
            if (!mask.isSet(grid.indexOfLoc(loc).?)) continue;

            area += 1;
            mask.unset(grid.indexOfLoc(loc).?);

            var neighbor_cnt: usize = 0;

            for (0..4) |di| {
                const dir = @as(Dir, @enumFromInt(di));

                if (grid.move(loc, dir)) |neighbor| {
                    if (grid.get(neighbor).? == plant) {
                        const ni = grid.indexOfLoc(neighbor).?;
                        neighbor_cnt += 1;
                        if (mask.isSet(ni)) {
                            try queue.enqueue(neighbor);
                        }
                    }
                }
            }
            perim += (4 - neighbor_cnt);
        }

        answer += (area * perim);
    }

    return answer;
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

    std.debug.print("Day 12 ----\n", .{});

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
    const expected: usize = 1930;
    const actual = try part_one(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED {} = {}.\n", .{ expected, actual });
}

test "part two" {
    const expected: usize = 1206;
    const actual = try part_two(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED {} = {}.\n", .{ expected, actual });
}
