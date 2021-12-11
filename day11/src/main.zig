const std = @import("std");

const Octopus = struct {
    energy: u8,
    flashed: bool,
};

const Pos = struct {
    row: usize,
    col: usize,

    fn init(row: usize, col: usize) Pos {
        return Pos{
            .row = row,
            .col = col,
        };
    }
};

fn printOctopi(octopi: [10][10]Octopus) void {
    for (octopi) |row| {
        for (row) |octopus| {
            if (octopus.flashed) {
                std.debug.print("* ", .{});
                continue;
            }
            std.debug.print("{} ", .{octopus.energy});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

fn simulate(octopi: *[10][10]Octopus, row: usize, col: usize) void {
    if (row >= 10 or col >= 10) {
        return;
    }

    var octopus = &octopi[row][col];

    if (octopus.flashed) {
        return;
    }

    octopus.energy += 1;

    if (octopus.energy > 9) {
        octopus.flashed = true;
        octopus.energy = 0;
        const neighbors = [8]?Pos{
            // tl
            if (row > 0 and col > 0) Pos.init(row - 1, col - 1) else null,

            // l
            if (col > 0) Pos.init(row, col - 1) else null,

            // bl
            if (col > 0) Pos.init(row + 1, col - 1) else null,

            // b
            Pos.init(row + 1, col),

            // br
            Pos.init(row + 1, col + 1),

            // r
            Pos.init(row, col + 1),

            // tr
            if (row > 0) Pos.init(row - 1, col + 1) else null,

            // tr
            if (row > 0) Pos.init(row - 1, col) else null,
        };

        for (neighbors) |opt_neighbor| {
            if (opt_neighbor) |neighbor| {
                simulate(octopi, neighbor.row, neighbor.col);
            }
        }
    }
}

fn step(octopi: *[10][10]Octopus) u32 {
    for (octopi) |row, row_idx| {
        for (row) |_, col_idx| {
            simulate(octopi, row_idx, col_idx);
        }
    }

    var sum: u32 = 0;
    for (octopi) |*row| {
        for (row) |*octopus| {
            if (octopus.flashed) {
                octopus.flashed = false;
                sum += 1;
            }
        }
    }

    return sum;
}

const steps: u32 = 100;
fn problemOne() !void {
    const input = @embedFile("../input");

    var octopi: [10][10]Octopus = std.mem.zeroes([10][10]Octopus);
    var lines = std.mem.split(u8, input, "\n");
    var row: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        for (line) |val, col| {
            octopi[row][col] = Octopus{
                .energy = val - '0',
                .flashed = false,
            };
        }

        row += 1;
    }

    var flashes: u32 = 0;
    // simulate steps
    var idx: u32 = 0;
    while (idx < steps) : (idx += 1) {
        flashes += step(&octopi);
    }

    std.debug.print("Answer: {}\n", .{flashes});
}

fn problemTwo() !void {
    const input = @embedFile("../input");

    var octopi: [10][10]Octopus = std.mem.zeroes([10][10]Octopus);
    var lines = std.mem.split(u8, input, "\n");
    var row: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        for (line) |val, col| {
            octopi[row][col] = Octopus{
                .energy = val - '0',
                .flashed = false,
            };
        }

        row += 1;
    }

    var count: u32 = 0;
    var flashes: u32 = 0;
    while (true) {
        count += 1;
        flashes = step(&octopi);
        if (flashes == 100) {
            break;
        }
    }

    std.debug.print("Answer: {}\n", .{count});
}
pub fn main() anyerror!void {
    try problemOne();
    try problemTwo();
}
