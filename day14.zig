// answers:
// part 1: 226236192
// part 2: 8168
//
const std = @import("std");
const builtin = @import("builtin");

const puzzle_input = @embedFile("day14_data.txt");
const test_input =
    \\p=0,4 v=3,-3
    \\p=6,3 v=-1,-3
    \\p=10,3 v=-1,2
    \\p=2,0 v=2,-1
    \\p=0,0 v=1,3
    \\p=3,0 v=-2,-2
    \\p=7,6 v=-1,-3
    \\p=3,0 v=-1,-2
    \\p=9,3 v=2,3
    \\p=7,3 v=-1,2
    \\p=2,4 v=2,-3
    \\p=9,5 v=-3,-3
;

const Robot = struct {
    sx: isize = undefined,
    sy: isize = undefined,
    vx: isize = undefined,
    vy: isize = undefined,
};

const Loc = struct {
    x: usize,
    y: usize,
};

fn parse_input(input: []const u8, array_list: *std.ArrayList(Robot)) !void {
    var tokenizer = std.mem.tokenizeScalar(u8, input, '\n');
    while (tokenizer.next()) |line| {
        var robot = Robot{};

        var p1 = std.mem.indexOfScalar(u8, line, ',') orelse unreachable;
        robot.sx = try std.fmt.parseInt(isize, line[2..p1], 10);

        const p2 = std.mem.indexOfScalarPos(u8, line, p1 + 1, ' ') orelse unreachable;
        robot.sy = try std.fmt.parseInt(isize, line[p1 + 1 .. p2], 10);

        p1 = std.mem.indexOfScalarPos(u8, line, p2 + 3, ',') orelse unreachable;
        robot.vx = try std.fmt.parseInt(isize, line[p2 + 3 .. p1], 10);

        robot.vy = try std.fmt.parseInt(isize, line[p1 + 1 ..], 10);

        try array_list.append(robot);
    }
}

fn dump_input(robots: []Robot) void {
    for (robots) |robot| {
        std.debug.print("pos: {},{}  vel: {},{}\n", .{ robot.sx, robot.sy, robot.vx, robot.vy });
    }
}

fn print_board(board: []u8, locs: []Loc, width: usize, height: usize) void {
    @memset(board, 0);

    for (locs) |loc| {
        const i = (loc.y * width) + loc.x;
        board[i] += 1;
    }

    for (0..height) |y| {
        for (0..width) |x| {
            const i = (y * width) + x;
            if (board[i] == 0) {
                std.debug.print(".", .{});
            } else {
                std.debug.print("{}", .{board[i]});
            }
        }
        std.debug.print("\n", .{});
    }
}

fn advance(robots: []Robot, duration: usize, width: usize, height: usize, locs: *std.ArrayList(Loc)) !void {
    for (robots) |*robot| {
        var px = @rem(
            robot.sx + (robot.vx * @as(isize, @intCast(duration))),
            @as(isize, @intCast(width)),
        );
        var py = @rem(
            robot.sy + (robot.vy * @as(isize, @intCast(duration))),
            @as(isize, @intCast(height)),
        );

        if (px < 0) px = @as(isize, @intCast(width)) + px;
        if (py < 0) py = @as(isize, @intCast(height)) + py;

        try locs.append(Loc{ .x = @as(usize, @intCast(px)), .y = @as(usize, @intCast(py)) });
    }
}

fn part_one(allocator: std.mem.Allocator, input: []const u8, width: usize, height: usize, duration: usize) !usize {
    var answer: usize = 0;

    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();

    var locs = std.ArrayList(Loc).init(allocator);
    defer locs.deinit();

    try parse_input(input, &robots);
    // dump_input(robots.items);

    var quad_ttls = [_]usize{ 0, 0, 0, 0 };

    try advance(robots.items, duration, width, height, &locs);
    for (locs.items) |loc| {
        if (loc.x < width / 2) {
            if (loc.y < height / 2) {
                quad_ttls[0] += 1;
            } else if (loc.y > height / 2) {
                quad_ttls[2] += 1;
            }
        } else if (loc.x > width / 2) {
            if (loc.y < height / 2) {
                quad_ttls[1] += 1;
            } else if (loc.y > height / 2) {
                quad_ttls[3] += 1;
            }
        }
    }

    const board = try allocator.alloc(u8, width * height);
    defer allocator.free(board);
    print_board(board, locs.items, width, height);
    //
    // std.debug.print("{any}\n", .{quad_ttls});
    answer = 1;
    for (quad_ttls) |t| {
        answer *= t;
    }

    // 500 too low
    return answer;
}

fn part_two(allocator: std.mem.Allocator, input: []const u8, width: usize, height: usize) !usize {
    if (builtin.is_test) {
        return 0;
    }
    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();

    try parse_input(input, &robots);

    const board = try allocator.alloc(u8, width * height);
    defer allocator.free(board);

    var locs = std.ArrayList(Loc).init(allocator);
    defer locs.deinit();

    const stdin = std.io.getStdIn().reader();
    var user_input: [16]u8 = undefined;

    // var quad_ttls = [_]usize{ 0, 0, 0, 0 };

    var time: usize = 0;

    while (true) {
        locs.clearRetainingCapacity();

        if (time > 10000) break;

        try advance(robots.items, time, width, height, &locs);

        // for (locs.items) |loc| {
        //     if (loc.x < width / 2) {
        //         if (loc.y < height / 2) {
        //             quad_ttls[0] += 1;
        //         } else if (loc.y > height / 2) {
        //             quad_ttls[2] += 1;
        //         }
        //     } else if (loc.x > width / 2) {
        //         if (loc.y < height / 2) {
        //             quad_ttls[1] += 1;
        //         } else if (loc.y > height / 2) {
        //             quad_ttls[3] += 1;
        //         }
        //     }
        // }

        // if (quad_ttls[0] == quad_ttls[1] and quad_ttls[2] == quad_ttls[3]) {
        print_board(board, locs.items, width, height);
        std.debug.print("time: {}\n", .{time});

        const inp = try stdin.readUntilDelimiter(&user_input, '\n');
        if (inp.len == 1 and inp[0] == 'q') {
            break;
        }
        if (inp.len == 1 and inp[0] == 'b') {
            time -= 1;
            continue;
        }
        if (inp.len > 0) {
            const fr: usize = blk: {
                const n = std.fmt.parseInt(usize, inp, 10) catch {
                    break :blk 0;
                };
                std.time.sleep(16 * std.time.ns_per_ms);
                break :blk n;
            };
            if (fr > 0) {
                time = fr;
            }
        }
        // }

        time += 1;

        // const inp = try stdin.readUntilDelimiter(&user_input, '\n');
        // if (inp.len == 1 and inp[0] == 'q') {
        //     break;
        // }
        // if (inp.len > 0) {
        //     const fr: usize = blk: {
        //         const n = std.fmt.parseInt(usize, inp, 10) catch {
        //             break :blk 0;
        //         };
        //         break :blk n;
        //     };
        //     if (fr > 0) {
        //         time = fr;
        //     }
        // }
    }

    return 0;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    std.debug.print("Day 14 ----\n", .{});

    var start = try std.time.Instant.now();
    const p1 = try part_one(allocator, puzzle_input, 101, 103, 100);
    var end = try std.time.Instant.now();

    var elps: f64 = @as(f64, @floatFromInt(end.since(start))) / std.time.ns_per_ms;

    std.debug.print("part one: {} ... {d:.3}ms\n", .{ p1, elps });

    start = try std.time.Instant.now();
    const p2 = try part_two(allocator, puzzle_input, 101, 103);
    end = try std.time.Instant.now();

    elps = @as(f64, @floatFromInt(end.since(start))) / std.time.ns_per_ms;

    std.debug.print("part two: {} ... {d:.3}ms\n", .{ p2, elps });
}

test "example" {
    const robot = Robot{
        .sx = 2,
        .sy = 4,
        .vx = 2,
        .vy = -3,
    };
    const duration: usize = 5;
    const width: usize = 11;
    const height: usize = 7;

    var px = @rem(
        robot.sx + (robot.vx * @as(isize, @intCast(duration))),
        @as(isize, @intCast(width)),
    );
    var py = @rem(
        robot.sy + (robot.vy * @as(isize, @intCast(duration))),
        @as(isize, @intCast(height)),
    );

    if (px < 0) px = @as(isize, @intCast(width)) + px;
    if (py < 0) py = @as(isize, @intCast(height)) + py;

    try std.testing.expect(px == 1);
    try std.testing.expect(py == 3);
}

test "part one" {
    const expected: usize = 12;
    const actual = try part_one(std.testing.allocator, test_input, 11, 7, 100);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part one FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part one PASSED {} = {}.\n", .{ expected, actual });
}

test "part two" {
    const expected: usize = 0;
    const actual = try part_two(std.testing.allocator, test_input, 11, 7);

    std.testing.expect(expected == actual) catch |err| {
        std.debug.print("part two FAIL.  expected: {}, got: {}\n", .{ expected, actual });
        return err;
    };

    std.debug.print("part two PASSED {} = {}.\n", .{ expected, actual });
}
