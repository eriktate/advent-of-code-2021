const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const ArrayList = std.ArrayList;
const io = std.io;

const Cell = struct {
    val: u32,
    marked: bool,
};

const Board = struct {
    cells: [5][5]Cell,
    won: bool,

    pub fn fromReader(reader: anytype) !Board {
        var row: usize = 0;
        var board = Board{
            .cells = undefined,
            .won = false,
        };

        var row_buf: [100]u8 = undefined;
        var digit_buf: [3]u8 = undefined;
        while (row < 5) {
            var col: usize = 0;
            const row_slice = (try reader.readUntilDelimiterOrEof(&row_buf, '\n')).?;
            var row_reader = io.fixedBufferStream(row_slice[0..]).reader();
            while (col < 5) {
                const digit = (try row_reader.readUntilDelimiterOrEof(&digit_buf, ' ')).?;
                if (digit.len == 0) {
                    continue;
                }
                board.cells[row][col] = Cell{
                    .val = try std.fmt.parseUnsigned(u32, digit, 10),
                    .marked = false,
                };
                col += 1;
            }
            row += 1;
        }

        return board;
    }

    pub fn checkWin(self: *Board, row: usize, col: usize) bool {
        var idx: usize = 0;
        var no_row = false;
        var no_col = false;

        while (idx < 5) {
            if (!no_row and !self.cells[row][idx].marked) {
                no_row = true;
            }

            if (!no_col and !self.cells[idx][col].marked) {
                no_col = true;
            }

            if (no_row and no_col) {
                return false;
            }
            idx += 1;
        }

        self.won = true;
        return true;
    }

    pub fn addDraw(self: *Board, draw: u32) bool {
        if (self.won) {
            return false;
        }

        var found = false;
        for (self.cells) |*row, row_idx| {
            for (row) |*cell, col_idx| {
                if (cell.val == draw) {
                    cell.marked = true;
                    if (self.checkWin(row_idx, col_idx)) {
                        return true;
                    }
                    found = true;
                    break;
                }
            }
            if (found) {
                break;
            }
        }

        return false;
    }

    pub fn getScore(self: Board) u32 {
        var sum: u32 = 0;
        for (self.cells) |row| {
            for (row) |cell| {
                if (!cell.marked) {
                    sum += cell.val;
                }
            }
        }

        return sum;
    }
};

fn problemOne() !u32 {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const input = @embedFile("../input");
    var fb = io.fixedBufferStream(input[0..]);
    var draws: [500]u32 = undefined;
    var line_buffer: [1024]u8 = undefined;
    var boards = try ArrayList(Board).initCapacity(&gpa.allocator, 500);
    defer boards.deinit();

    // read the game input
    const line = try fb.reader().readUntilDelimiter(&line_buffer, '\n');
    var line_reader = io.fixedBufferStream(line[0..]);
    var draw_len: usize = 0;
    while (line_reader.pos < try line_reader.getEndPos()) {
        var digit_buf: [3]u8 = undefined;
        const digit = try line_reader.reader().readUntilDelimiterOrEof(&digit_buf, ',');
        draws[draw_len] = try std.fmt.parseUnsigned(u32, digit.?, 10);
        draw_len += 1;
    }

    while (fb.pos < try fb.getEndPos()) {
        fb.pos += 1;
        var board = try Board.fromReader(fb.reader());
        try boards.append(board);
    }

    for (draws[0..draw_len]) |draw| {
        for (boards.items) |*board| {
            if (board.addDraw(draw)) {
                return draw * board.getScore();
            }
        }
    }

    return 0;
}

fn problemTwo() !u32 {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const input = @embedFile("../input");
    var fb = io.fixedBufferStream(input[0..]);
    var draws: [500]u32 = undefined;
    var line_buffer: [1024]u8 = undefined;
    var boards = try ArrayList(Board).initCapacity(&gpa.allocator, 500);
    defer boards.deinit();

    // read the game input
    const line = try fb.reader().readUntilDelimiter(&line_buffer, '\n');
    var line_reader = io.fixedBufferStream(line[0..]);
    var draw_len: usize = 0;
    while (line_reader.pos < try line_reader.getEndPos()) {
        var digit_buf: [3]u8 = undefined;
        const digit = try line_reader.reader().readUntilDelimiterOrEof(&digit_buf, ',');
        draws[draw_len] = try std.fmt.parseUnsigned(u32, digit.?, 10);
        draw_len += 1;
    }

    while (fb.pos < try fb.getEndPos()) {
        fb.pos += 1;
        var board = try Board.fromReader(fb.reader());
        try boards.append(board);
    }

    var last_winning_board: *Board = undefined;
    var last_draw: u32 = 0;
    for (draws[0..draw_len]) |draw| {
        for (boards.items) |*board| {
            if (board.addDraw(draw)) {
                last_winning_board = board;
                last_draw = draw;
            }
        }
    }

    return last_draw * last_winning_board.getScore();
}

pub fn main() anyerror!void {
    const answer_1 = try problemOne();
    std.debug.print("Answer 1: {d}\n", .{answer_1});

    const answer_2 = try problemTwo();
    std.debug.print("Answer 2: {d}\n", .{answer_2});
}
