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

            std.debug.print("Found low point {} at {}, {}\n", .{ cell - '0', row_idx, col_idx });
            risk_level += (cell - '0' + 1);
        }
    }

    std.debug.print("Risk Level: {}\n", .{risk_level});
}

fn fillBasin(grid: [][]u8, row: usize, col: usize, from_row: usize, from_col: usize) u32 {
    const up = if (row_idx == 0) 0 else row_idx - 1;
    const down = row_idx + 1;
    const left = if (col_idx == 0) 0 else col_idx - 1;
    const right = col_idx + 1;
}

// assumption: all basins are surrounded by 9s
pub fn problemTwo() anyerror!void {
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

            std.debug.print("Found low point {} at {}, {}\n", .{ cell - '0', row_idx, col_idx });
            risk_level += (cell - '0' + 1);
        }
    }

    std.debug.print("Risk Level: {}\n", .{risk_level});
}

pub fn main() anyerror!void {
    try problemOne();
    try problemTwo();
}
