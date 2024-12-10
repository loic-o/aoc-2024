const std = @import("std");
// answers:
// part 1: 6201130364722
// part 2: 6221662795602

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

const FileBlock = struct {
    id: usize,
    sz: usize,
};

const BlockTypeTag = enum {
    file,
    empty,
};

const Block = union(BlockTypeTag) {
    file: FileBlock,
    empty: usize,
};

const BlockNode = std.DoublyLinkedList(Block).Node;

fn dump_blocks(head: ?*BlockNode) void {
    var maybe_node = head;
    while (maybe_node) |node| {
        switch (node.data) {
            .file => |fb| {
                for (0..fb.sz) |_| {
                    std.debug.print("{}", .{fb.id});
                }
            },
            .empty => |sz| {
                for (0..sz) |_| {
                    std.debug.print("{s}", .{"."});
                }
            },
        }
        maybe_node = node.next;
    }
    std.debug.print("\n", .{});
}

fn part_two(allocator: std.mem.Allocator, input: []const u8) !usize {
    var blocks = std.DoublyLinkedList(Block){};

    defer {
        while (blocks.popFirst()) |n| {
            allocator.destroy(n);
        }
    }

    for (0..input.len) |i| {
        if (input[i] < '0') continue;
        const size = std.fmt.parseInt(usize, input[i .. i + 1], 10) catch |err| {
            std.debug.print("tried to parseInt on [{}]\n", .{input[i]});
            return err;
        };

        var node = try allocator.create(BlockNode);

        node.data = if (i % 2 == 0) Block{
            .file = FileBlock{
                .id = i / 2,
                .sz = size,
            },
        } else Block{
            .empty = size,
        };

        blocks.append(node);
    }

    var maybe_move_block = blocks.last;

    while (maybe_move_block) |move_block| {
        if (move_block.prev == null) {
            // this is the first file, so we are done.
            break;
        }
        maybe_move_block = move_block.prev;

        switch (move_block.data) {
            .empty => {}, // not a file
            .file => |move_file| {
                // std.debug.print("({}) ", .{move_file.id});
                // dump_blocks(blocks.first);

                var maybe_free_block = blocks.first;

                while (maybe_free_block) |free_block| {
                    maybe_free_block = free_block.next;

                    switch (free_block.data) {
                        .file => |file| {
                            if (file.id == move_file.id) {
                                // we have reached ourselves
                                break;
                            }
                        },
                        .empty => |free_space| {
                            if (move_file.sz <= free_space) {
                                var replacement_node = try allocator.create(BlockNode);
                                replacement_node.data = Block{ .empty = move_file.sz };

                                blocks.insertAfter(move_block, replacement_node);
                                blocks.remove(move_block);
                                blocks.insertBefore(free_block, move_block);

                                free_block.data = Block{ .empty = free_space - move_file.sz };

                                break;
                            }
                        },
                    }
                }
            },
        }
    }

    var block_num: usize = 0;
    var checksum: usize = 0;
    var maybe_node = blocks.first;

    while (maybe_node) |node| {
        switch (node.data) {
            .file => |fb| {
                for (0..fb.sz) |_| {
                    checksum += (block_num * fb.id);
                    block_num += 1;
                }
            },
            .empty => |sz| {
                block_num += sz;
            },
        }
        maybe_node = node.next;
    }

    return checksum;
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
