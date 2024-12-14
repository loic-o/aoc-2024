const std = @import("std");

// answers:
// part 1: 175006
// part 2: ?

// const test_input = "0 1 10 99 999";
const test_input = "125 17";
const puzzle_input = "64554 35 906 6 6960985 5755 975820 0";

const PuzzleList = struct {
    allocator: std.mem.Allocator,
    llist: ListType,

    const Self = @This();
    const ListType = std.DoublyLinkedList(usize);
    const ListNodeType = ListType.Node;

    fn init(allocator: std.mem.Allocator, input: []const u8) !Self {
        const llist = ListType{};
        var tokenizer = std.mem.tokenizeScalar(u8, input, ' ');
        var self = Self{
            .allocator = allocator,
            .llist = llist,
        };
        while (tokenizer.next()) |tok| {
            const node = try self.new_node(try std.fmt.parseInt(usize, tok, 10));
            self.llist.append(node);
        }
        return self;
    }

    fn deinit(self: *Self) void {
        while (self.llist.pop()) |node| {
            self.allocator.destroy(node);
        }
    }

    fn first(self: Self) ?*ListNodeType {
        return self.llist.first;
    }

    fn new_node(self: Self, data: usize) !*ListNodeType {
        var node = try self.allocator.create(ListNodeType);
        node.data = data;
        return node;
    }

    fn dump(self: Self) void {
        var current = self.llist.first;
        while (current) |node| {
            std.debug.print("{} ", .{node.data});
            current = node.next;
        }
        std.debug.print("\n", .{});
    }
};

fn part_one(allocator: std.mem.Allocator, input: []const u8, blinks: usize) !usize {
    var buffer = [_]u8{' '} ** 24;

    var list = try PuzzleList.init(allocator, input);
    defer list.deinit();

    for (0..blinks) |_| {
        var current = list.first();

        while (current) |node| {
            if (node.data == 0) {
                node.data = 1;
                current = node.next;
            } else {
                const slc = try std.fmt.bufPrint(&buffer, "{}", .{node.data});
                if (slc.len % 2 == 0) {
                    // 012345
                    // 975820
                    node.data = try std.fmt.parseInt(usize, slc[0 .. slc.len / 2], 10);
                    const new_node = try list.new_node(try std.fmt.parseInt(usize, slc[slc.len / 2 ..], 10));
                    list.llist.insertAfter(node, new_node);
                    current = new_node.next;
                } else {
                    node.data = node.data * 2024;
                    current = node.next;
                }
            }
        }
    }

    return list.llist.len;
}

fn part_two(allocator: std.mem.Allocator, input: []const u8) !usize {
    _ = allocator;
    _ = input;
    // this wont finish
    // return try part_one(allocator, input, 75);
    //
    // dave's answer was to do 1 stone a time, and memoize
    // the number of stones that result such that the same
    // numbered stone isn't calc'd more than once.
    //
    // note: p1 - my orig method completed in 1080.342 ms
    //
    // if i do implement memoization - will be interesting
    // to see what is in there (along w/ hit counts) so i
    // can understand why this works so well...must break
    // down into a very common set of numbers ... guessing
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    std.debug.print("Day 11 ----\n", .{});

    var start = try std.time.Instant.now();
    const p1 = try part_one(allocator, puzzle_input, 25);
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
    const expected: usize = 55312;
    const actual = try part_one(std.testing.allocator, test_input, 25);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED {} = {}.\n", .{ expected, actual });

    // const answer = try part_one(std.testing.allocator, "125 17", 6);
    // std.debug.print("answer: {}\n", .{answer});
}
