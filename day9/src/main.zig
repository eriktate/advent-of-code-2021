const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const ArrayList = std.ArrayList;

pub fn problemOne() anyerror!void {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var alloc = &gpa.allocator;

    var rows = try ArrayList([]const u8).initCapacity(alloc, 1024);
    defer rows.deinit();
    const input = @embedFile("../input");
    var lines = std.mem.split(u8, input, "\n");
    while (lines.next()) |line| {
        if (line.len != 0) {
            try rows.append(line);
        }
    }

    var risk_level: u32 = 0;
    for (rows.items) |row, row_idx| {
        for (row) |cell, col_idx| {
            const up = if (row_idx == 0) 0 else row_idx - 1;
            const down = row_idx + 1;
            const left = if (col_idx == 0) 0 else col_idx - 1;
            const right = col_idx + 1;

            if (up != row_idx and rows.items[up][col_idx] <= cell) {
                continue;
            }

            if (down < rows.items.len and rows.items[down][col_idx] <= cell) {
                continue;
            }

            if (left != col_idx and row[left] <= cell) {
                continue;
            }

            if (right < row.len and row[right] <= cell) {
                continue;
            }

            risk_level += (cell - '0' + 1);
        }
    }

    std.debug.print("Risk Level: {}\n", .{risk_level});
}

const Cell = struct {
    val: u8,
    visited: bool,
};

const Grid = struct {
    cells: []Cell,
    grid: [][]Cell,
    width: usize,

    fn print(self: Grid) void {
        for (self.grid) |row| {
            for (row) |cell| {
                if (cell.visited) {
                    std.debug.print("* ", .{});
                } else {
                    std.debug.print("{} ", .{cell.val});
                }
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }
};

const Pos = struct {
    row: usize,
    col: usize,
};

fn fillBasin(grid: *Grid, row: usize, col: usize) u32 {
    const current = &grid.grid[row][col];
    if (current.val == 9) {
        return 0;
    }

    current.visited = true;

    const neighbors = [4]Pos{
        // up
        Pos{ .row = if (row == 0) 0 else row - 1, .col = col },
        // down
        Pos{ .row = if (row + 1 == grid.grid.len) 0 else row + 1, .col = col },
        // left
        Pos{ .row = row, .col = if (col == 0) 0 else col - 1 },
        // right
        Pos{ .row = row, .col = if (col + 1 == grid.width) col else col + 1 },
    };

    var sum: u32 = 1;
    for (neighbors) |pos| {
        if (pos.row == row and pos.col == col) {
            continue;
        }

        const neighbor = grid.grid[pos.row][pos.col];
        if (neighbor.val > current.val and !neighbor.visited) {
            sum += fillBasin(grid, pos.row, pos.col);
        }
    }

    return sum;
}

fn generateGrid(alloc: *std.mem.Allocator, input: []const u8) !Grid {
    var lines = std.mem.split(u8, input, "\n");

    const width = lines.next().?.len;
    var height: usize = 1;
    while (lines.next()) |line| {
        if (line.len != 0) {
            height += 1;
        }
    }
    lines.index = 0;

    // allocate space for the cells
    var cells = try alloc.alloc(Cell, height * width);
    // allocate space for the slices into cells (2D slice)
    var grid = try alloc.alloc([]Cell, height);
    var row: usize = 0;
    var idx: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        for (line) |digit| {
            cells[idx] = Cell{
                .val = digit - '0',
                .visited = false,
            };
            idx += 1;
        }
        grid[row] = cells[row * width .. (row + 1) * width];
        row += 1;
    }

    return Grid{
        .cells = cells,
        .grid = grid[0..],
        .width = width,
    };
}

fn recordSize(sizes: []u32, size: u32) void {
    var size_cp = size;
    var idx: usize = 0;
    while (idx < sizes.len) : (idx += 1) {
        if (sizes[idx] < size_cp) {
            var temp = sizes[idx];
            sizes[idx] = size_cp;
            size_cp = temp;
        }
    }
}

pub fn problemTwo() anyerror!void {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var alloc = &gpa.allocator;

    const input = @embedFile("../input");
    var grid = try generateGrid(alloc, input);
    defer alloc.free(grid.grid);
    defer alloc.free(grid.cells);

    var risk_level: u32 = 1;
    var sizes = [3]u32{ 0, 0, 0 };
    for (grid.grid) |row, row_idx| {
        for (row) |cell, col_idx| {
            const neighbors = [4]Pos{
                // up
                Pos{ .row = if (row_idx == 0) 0 else row_idx - 1, .col = col_idx },
                // down
                Pos{ .row = if (row_idx + 1 == grid.grid.len) 0 else row_idx + 1, .col = col_idx },
                // left
                Pos{ .row = row_idx, .col = if (col_idx == 0) 0 else col_idx - 1 },
                // right
                Pos{ .row = row_idx, .col = if (col_idx + 1 == grid.width) col_idx else col_idx + 1 },
            };

            var low_point = true;
            for (neighbors) |pos| {
                const neighbor = grid.grid[pos.row][pos.col];
                if (pos.row == row_idx and pos.col == col_idx) {
                    continue;
                }

                if (neighbor.val <= cell.val) {
                    low_point = false;
                }
            }

            if (low_point) {
                const size: u32 = fillBasin(&grid, row_idx, col_idx);
                recordSize(&sizes, size);
            }
        }
    }

    for (sizes) |size| {
        risk_level *= size;
    }

    std.debug.print("Risk Level: {}\n", .{risk_level});
}

pub fn main() anyerror!void {
    try problemOne();
    try problemTwo();
}
