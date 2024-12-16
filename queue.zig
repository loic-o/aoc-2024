const std = @import("std");

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        const ListType = std.DoublyLinkedList(T);
        const ListNodeType = ListType.Node;
        const MemPoolType = std.heap.MemoryPool(ListNodeType);

        allocator: std.mem.Allocator,
        list: ListType,
        pool: MemPoolType,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .list = ListType{},
                .pool = MemPoolType.init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.pool.deinit();
        }

        /// add new item to the end of this list
        pub fn enqueue(self: *Self, data: T) !void {
            var node = try self.pool.create();
            node.data = data;
            self.list.append(node);
        }

        /// remove and return the first item in the list
        pub fn dequeue(self: *Self) ?T {
            const maybe_node = self.list.popFirst();
            if (maybe_node) |node| {
                const data = node.data;
                self.pool.destroy(node);
                return data;
            }
            return null;
        }

        pub fn clear(self: *Self) void {
            while (self.list.pop()) |node| {
                self.pool.destroy(node);
            }
            std.debug.assert(self.list.len == 0);
        }
    };
}

fn report_equal(comptime T: type, expected: T, actual: T, msg: []const u8) bool {
    if (actual == expected) return true;
    std.debug.print("{s}.  expected: {}, got: {}\n", .{ msg, expected, actual });
    return false;
}

fn report_notnull(comptime T: type, actual: ?T, msg: []const u8) bool {
    if (actual != null) return true;
    std.debug.print("{s} is NULL\n", .{msg});
    return false;
}

fn report_null(comptime T: type, actual: ?T, msg: []const u8) bool {
    if (actual == null) return true;
    std.debug.print("{s} is NOT NULL\n", .{msg});
    return false;
}

test "basic operations" {
    var queue = Queue(usize).init(std.testing.allocator);
    defer queue.deinit();

    try queue.enqueue(1);
    try queue.enqueue(2);
    try queue.enqueue(3);

    const n = queue.dequeue();
    try std.testing.expect(report_notnull(usize, n, "n"));
    try std.testing.expect(report_equal(usize, 1, n.?, "n"));

    try std.testing.expect(report_notnull(usize, queue.dequeue(), "deq"));
    try std.testing.expect(report_notnull(usize, queue.dequeue(), "deq"));
    try std.testing.expect(report_null(usize, queue.dequeue(), "deq"));
}
