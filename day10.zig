const std = @import("std");

//answers:
//part 1: 825
//part 2: 1805

const gr = @import("grid.zig");
const Grid = gr.Grid;
const Dir = gr.Dir;
const Loc = gr.Loc;

const puzzle_input = @embedFile("day10_data.txt");
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

fn clear_list(comptime T: type, allocator: std.mem.Allocator, list: *T) !void {
    while (list.len > 0) {
        const n = list.pop() orelse unreachable;
        allocator.destroy(n);
    }
}

fn charToInt(char: ?u8) ?u8 {
    if (char) |c| {
        return c - '0';
    }
    return null;
}

fn part_one(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;

    const grid = Grid.fromInput(input);

    const LocListType = std.DoublyLinkedList(Loc);
    const LocListNodeType = LocListType.Node;

    var loc_list = LocListType{};
    defer clear_list(LocListType, allocator, &loc_list) catch {};

    var th_bits = try std.DynamicBitSet.initEmpty(allocator, input.len);
    defer th_bits.deinit();

    var p = std.mem.indexOfScalar(u8, input, '0');

    while (p) |th_idx| {
        var th_score: usize = 0;

        th_bits.setRangeValue(.{ .start = 0, .end = input.len }, false);

        std.debug.assert(th_bits.count() == 0);
        std.debug.assert(loc_list.len == 0);

        {
            const loc = grid.locOfIndexRaw(th_idx) orelse unreachable;
            var node = try allocator.create(LocListNodeType);
            node.data = loc;
            loc_list.append(node);
        }

        while (loc_list.popFirst()) |ln| {
            const curr_loc = ln.data;
            const curr_elv = charToInt(grid.get(curr_loc)) orelse unreachable;

            // std.debug.print("({},{}) = {}  ({})\n", .{ curr_loc.col, curr_loc.row, curr_elv, loc_list.len });

            for (0..4) |di| {
                const dir = @as(Dir, @enumFromInt(di));

                if (grid.move(curr_loc, dir)) |neighbor_loc| {
                    const neigh_elv = charToInt(grid.get(neighbor_loc)) orelse unreachable;
                    if (neigh_elv == curr_elv + 1) {
                        if (neigh_elv == 9) {
                            const i = grid.indexRawOfLoc(neighbor_loc) orelse unreachable;
                            if (th_bits.isSet(i) == false) {
                                th_score += 1;
                                th_bits.set(i);
                            }
                        } else {
                            var node = try allocator.create(LocListNodeType);
                            node.data = neighbor_loc;
                            loc_list.append(node);
                        }
                    }
                }
            }

            allocator.destroy(ln);
        }

        answer += th_score;

        p = std.mem.indexOfScalarPos(u8, input, th_idx + 1, '0');
    }

    return answer;
}

fn part_two(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;

    const grid = Grid.fromInput(input);

    const LocListType = std.DoublyLinkedList(Loc);
    const LocListNodeType = LocListType.Node;

    var loc_list = LocListType{};
    defer clear_list(LocListType, allocator, &loc_list) catch {};

    var p = std.mem.indexOfScalar(u8, input, '0');

    while (p) |th_idx| {
        var th_score: usize = 0;

        std.debug.assert(loc_list.len == 0);

        {
            const loc = grid.locOfIndexRaw(th_idx) orelse unreachable;
            var node = try allocator.create(LocListNodeType);
            node.data = loc;
            loc_list.append(node);
        }

        while (loc_list.popFirst()) |ln| {
            const curr_loc = ln.data;
            const curr_elv = charToInt(grid.get(curr_loc)) orelse unreachable;

            // std.debug.print("({},{}) = {}  ({})\n", .{ curr_loc.col, curr_loc.row, curr_elv, loc_list.len });

            for (0..4) |di| {
                const dir = @as(Dir, @enumFromInt(di));

                if (grid.move(curr_loc, dir)) |neighbor_loc| {
                    const neigh_elv = charToInt(grid.get(neighbor_loc)) orelse unreachable;
                    if (neigh_elv == curr_elv + 1) {
                        if (neigh_elv == 9) {
                            th_score += 1;
                        } else {
                            var node = try allocator.create(LocListNodeType);
                            node.data = neighbor_loc;
                            loc_list.append(node);
                        }
                    }
                }
            }

            allocator.destroy(ln);
        }

        answer += th_score;

        p = std.mem.indexOfScalarPos(u8, input, th_idx + 1, '0');
    }

    return answer;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    std.debug.print("Day 10 ----\n", .{});

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
    const expected: usize = 36;
    const actual = try part_one(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED {} = {}.\n", .{ expected, actual });
}

test "part two" {
    const expected: usize = 81;
    const actual = try part_two(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED {} = {}.\n", .{ expected, actual });
}
