const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const ArrayList = std.ArrayList;

fn isOpen(char: u8) bool {
    return switch (char) {
        '[', '(', '{', '<' => true,
        else => false,
    };
}

fn isPair(opening: u8, closing: u8) bool {
    return switch (opening) {
        '[' => closing == ']',
        '(' => closing == ')',
        '{' => closing == '}',
        '<' => closing == '>',
        else => unreachable,
    };
}

fn getClosing(opening: u8) u8 {
    return switch (opening) {
        '[' => ']',
        '(' => ')',
        '{' => '}',
        '<' => '>',
        else => unreachable,
    };
}

fn getScore(char: u8) u32 {
    return switch (char) {
        ']' => 57,
        ')' => 3,
        '}' => 1197,
        '>' => 25137,
        else => unreachable,
    };
}

fn getACScore(char: u8) u32 {
    return switch (char) {
        ')' => 1,
        ']' => 2,
        '}' => 3,
        '>' => 4,
        else => unreachable,
    };
}

fn insert(src: *ArrayList(u64), el: u64) !void {
    var new_el = el;
    for (src.items) |*existing| {
        if (el < existing.*) {
            const temp = existing.*;
            existing.* = new_el;
            new_el = temp;
        }
    }

    try src.append(new_el);
}

pub fn problemOne() anyerror!void {
    // split on lines
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = &gpa.allocator;

    const input = @embedFile("../sample");
    var lines = std.mem.split(u8, input, "\n");
    var stack = try ArrayList(u8).initCapacity(alloc, 1024);
    defer stack.deinit();
    // var corrupted_list = try ArrayList(u8).initCapacity(1024);

    var sum: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        for (line) |char| {
            if (isOpen(char)) {
                try stack.append(char);
                continue;
            }

            if (!isPair(stack.pop(), char)) {
                sum += getScore(char);
                break;
            }
        }

        stack.items.len = 0;
        // try corrupted_list.append(corrupted);
    }

    std.debug.print("Corrupted Score: {}\n", .{sum});
}

pub fn problemTwo() anyerror!void {
    // split on lines
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = &gpa.allocator;

    const input = @embedFile("../input");
    var lines = std.mem.split(u8, input, "\n");
    var stack = try ArrayList(u8).initCapacity(alloc, 1024);
    defer stack.deinit();

    var scores = try ArrayList(u64).initCapacity(alloc, 1024);
    defer scores.deinit();

    var sum: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var found_corrupted = false;
        for (line) |char| {
            if (isOpen(char)) {
                try stack.append(char);
                continue;
            }

            if (!isPair(stack.pop(), char)) {
                sum += getScore(char);
                found_corrupted = true;
                break;
            }
        }

        if (found_corrupted) {
            stack.items.len = 0;
            continue;
        }

        var score: u64 = 0;
        while (stack.popOrNull()) |opening| {
            score = (score * 5) + getACScore(getClosing(opening));
        }

        try insert(&scores, score);
        stack.items.len = 0;
    }

    std.debug.print("Corrupted Score: {}\n", .{sum});
    std.debug.print("Autocomplete score: {}\n", .{scores.items[scores.items.len / 2]});
}

pub fn main() anyerror!void {
    try problemOne();
    try problemTwo();
}
