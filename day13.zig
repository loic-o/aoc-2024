// answers:
// part 1: 36571
// part 2: ?
//
const std = @import("std");

const puzzle_input = @embedFile("day13_data.txt");
const test_input =
    \\Button A: X+94, Y+34
    \\Button B: X+22, Y+67
    \\Prize: X=8400, Y=5400
    \\
    \\Button A: X+26, Y+66
    \\Button B: X+67, Y+21
    \\Prize: X=12748, Y=12176
    \\
    \\Button A: X+17, Y+86
    \\Button B: X+84, Y+37
    \\Prize: X=7870, Y=6450
    \\
    \\Button A: X+69, Y+23
    \\Button B: X+27, Y+71
    \\Prize: X=18641, Y=10279
;

const MachineConfig = struct {
    ax: usize = undefined,
    ay: usize = undefined,
    bx: usize = undefined,
    by: usize = undefined,
    px: usize = undefined,
    py: usize = undefined,
};

fn parse_input(input: []const u8, array_list: *std.ArrayList(MachineConfig)) !void {
    var tokenizer = std.mem.tokenizeScalar(u8, input, '\n');

    while (tokenizer.peek() != null) {
        var machine = MachineConfig{};

        var line = tokenizer.next() orelse unreachable;
        std.debug.assert(line[7] == 'A');
        var p1 = std.mem.indexOfScalarPos(u8, line, 9, '+') orelse unreachable;
        var p2 = std.mem.indexOfScalarPos(u8, line, p1, ',') orelse unreachable;
        machine.ax = try std.fmt.parseInt(usize, line[p1 + 1 .. p2], 10);
        p1 = std.mem.indexOfScalarPos(u8, line, p2 + 2, '+') orelse unreachable;
        machine.ay = try std.fmt.parseInt(usize, line[p1 + 1 ..], 10);

        line = tokenizer.next() orelse unreachable;
        std.debug.assert(line[7] == 'B');
        p1 = std.mem.indexOfScalarPos(u8, line, 9, '+') orelse unreachable;
        p2 = std.mem.indexOfScalarPos(u8, line, p1, ',') orelse unreachable;
        machine.bx = try std.fmt.parseInt(usize, line[p1 + 1 .. p2], 10);
        p1 = std.mem.indexOfScalarPos(u8, line, p2 + 2, '+') orelse unreachable;
        machine.by = try std.fmt.parseInt(usize, line[p1 + 1 ..], 10);

        line = tokenizer.next() orelse unreachable;
        std.debug.assert(line[8] == '=');
        p1 = std.mem.indexOfScalarPos(u8, line, 9, ',') orelse unreachable;
        machine.px = try std.fmt.parseInt(usize, line[9..p1], 10);
        p1 = std.mem.indexOfScalarPos(u8, line, p1 + 2, '=') orelse unreachable;
        machine.py = try std.fmt.parseInt(usize, line[p1 + 1 ..], 10);

        try array_list.append(machine);
    }
}

fn dump_machines(machines: []MachineConfig) void {
    for (machines) |machine| {
        std.debug.print("ax: {}, ay: {}\nbx: {} by: {}\npx: {} py: {}\n\n", .{
            machine.ax, machine.ay,
            machine.bx, machine.by,
            machine.px, machine.py,
        });
    }
}

fn part_one(allocator: std.mem.Allocator, input: []const u8) !usize {
    var answer: usize = 0;
    answer += 0;

    var machines = std.ArrayList(MachineConfig).init(allocator);
    defer machines.deinit();

    try parse_input(input, &machines);
    // dump_machines(machines.items);

    for (machines.items) |machine| {
        const det = @as(isize, @intCast(machine.ax * machine.by)) - @as(isize, @intCast(machine.ay * machine.bx));
        if (det == 0) continue;

        const da = @as(isize, @intCast(machine.px * machine.by)) - @as(isize, @intCast(machine.bx * machine.py));
        const db = @as(isize, @intCast(machine.ax * machine.py)) - @as(isize, @intCast(machine.px * machine.ay));

        if (@mod(da, det) != 0 or @mod(db, det) != 0) continue;

        const a_pushes = @divFloor(da, det);
        const b_pushes = @divFloor(db, det);

        answer += @as(usize, @intCast((a_pushes * 3) + b_pushes));
    }

    return answer;
}

fn part_two(allocator: std.mem.Allocator, input: []const u8) !usize {
    // 10_000_000_000_000
    var answer: usize = 0;
    answer += 0;

    var machines = std.ArrayList(MachineConfig).init(allocator);
    defer machines.deinit();

    try parse_input(input, &machines);
    // dump_machines(machines.items);

    for (machines.items) |*machine| {
        machine.px += 10000000000000;
        machine.py += 10000000000000;

        const det = @as(isize, @intCast(machine.ax * machine.by)) - @as(isize, @intCast(machine.ay * machine.bx));
        if (det == 0) continue;

        const da = @as(isize, @intCast(machine.px * machine.by)) - @as(isize, @intCast(machine.bx * machine.py));
        const db = @as(isize, @intCast(machine.ax * machine.py)) - @as(isize, @intCast(machine.px * machine.ay));

        if (@mod(da, det) != 0 or @mod(db, det) != 0) continue;

        const a_pushes = @divFloor(da, det);
        const b_pushes = @divFloor(db, det);

        answer += @as(usize, @intCast((a_pushes * 3) + b_pushes));
    }

    return answer;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    std.debug.print("Day 13 ----\n", .{});

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
    const expected: usize = 480;
    const actual = try part_one(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED {} = {}.\n", .{ expected, actual });
}

test "part two" {
    const expected: usize = 0;
    const actual = try part_two(std.testing.allocator, test_input);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED {} = {}.\n", .{ expected, actual });
}
