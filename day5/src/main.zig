const std = @import("std");
const io = std.io;

const GRID_SIZE: u32 = 1000;

const Grid = struct {
    cells: [GRID_SIZE][GRID_SIZE]u32,
    danger_points: u32,

    fn init() Grid {
        return Grid{
            .cells = std.mem.zeroes([GRID_SIZE][GRID_SIZE]u32),
            .danger_points = 0,
        };
    }

    fn fillLine(self: *Grid, x1: u32, y1: u32, x2: u32, y2: u32) void {
        // assume horizontal or vertical lines

        // vertical
        if (x1 == x2) {
            const min = std.math.min(y1, y2);
            const max = std.math.max(y1, y2) + 1;

            for (self.cells[min..max]) |*row| {
                row[x1] += 1;
                if (row[x1] == 2) {
                    self.danger_points += 1;
                }
            }

            return;
        }

        // horizontal
        if (y1 == y2) {
            const min = std.math.min(x1, x2);
            const max = std.math.max(x1, x2) + 1;

            for (self.cells[y1][min..max]) |*cell| {
                cell.* += 1;
                if (cell.* == 2) {
                    self.danger_points += 1;
                }
            }

            return;
        }

        // NOTE: to make problem 1 work again, comment out all of this diagonal handling
        // diagonal
        const x_min = std.math.min(x1, x2);
        const x_max = std.math.max(x1, x2);
        const distance = x_max - x_min;
        var idx: i32 = 0;
        var x_sign: i32 = 1;
        var y_sign: i32 = 1;
        if (x1 > x2) {
            x_sign = -1;
        }

        if (y1 > y2) {
            y_sign = -1;
        }

        while (idx < distance + 1) {
            const x_pos = @intCast(usize, @intCast(i32, x1) + (idx * x_sign));
            const y_pos = @intCast(usize, @intCast(i32, y1) + (idx * y_sign));

            self.cells[y_pos][x_pos] += 1;
            if (self.cells[y_pos][x_pos] == 2) {
                self.danger_points += 1;
            }
            idx += 1;
        }
    }

    fn getDangerPoints(self: Grid) u32 {
        var sum: u32 = 0;
        for (self.cells) |row| {
            for (row) |cell| {
                if (cell >= 2) {
                    sum += 1;
                }
            }
        }

        return sum;
    }

    fn print(self: Grid) void {
        for (self.cells) |row| {
            std.debug.print("{any}\n", .{row});
        }
    }
};

fn problemTwo() !void {
    const input = @embedFile("../input");

    var grid = Grid.init();
    var lines = std.mem.split(u8, input, "\n");

    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var parts = std.mem.split(u8, line, " -> ");
        var first = parts.next().?;
        var second = parts.next().?;

        var point_1 = std.mem.split(u8, first, ",");
        var point_2 = std.mem.split(u8, second, ",");

        const x1 = try std.fmt.parseInt(u32, point_1.next().?, 10);
        const y1 = try std.fmt.parseInt(u32, point_1.next().?, 10);
        const x2 = try std.fmt.parseInt(u32, point_2.next().?, 10);
        const y2 = try std.fmt.parseInt(u32, point_2.next().?, 10);

        grid.fillLine(x1, y1, x2, y2);
    }

    std.debug.print("Danger points: {d}\n", .{grid.danger_points});
}

pub fn main() anyerror!void {
    try problemTwo();
}
