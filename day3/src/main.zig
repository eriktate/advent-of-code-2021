const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const ArrayList = std.ArrayList;
const io = std.io;

pub fn problemOne() anyerror!void {
    const input = @embedFile("../input");
    var fb = io.fixedBufferStream(input[0..]);
    var bit_counts = [_]u32{0} ** 12;
    var line_count: u32 = 0;
    var buffer: [12]u8 = undefined;
    while (fb.pos < try fb.getEndPos()) {
        _ = try fb.reader().readUntilDelimiterOrEof(&buffer, '\n');

        for (buffer) |bit, idx| {
            bit_counts[idx] += bit - '0';
        }
        line_count += 1;
    }

    var gamma: u32 = 0;
    var epsilon: u32 = 0;
    for (bit_counts) |bit, idx| {
        if (idx > 0) {
            gamma *= 2;
            epsilon *= 2;
        }

        // most common
        if (bit > line_count / 2) {
            gamma += 1;
        } else {
            epsilon += 1;
        }
    }

    std.debug.print("lines: {d}\n", .{line_count});
    std.debug.print("{any}\n", .{bit_counts});
    std.debug.print("gamma: {d}, epsilon: {d}, power output: {d}\n", .{ gamma, epsilon, gamma * epsilon });
}

fn findMostCommon(lines: [][]u8, pos: usize) u1 {
    var sum: u32 = 0;
    for (lines) |line| {
        sum += line[pos] - '0';
    }

    if (sum > lines.len / 2) {
        return 1;
    }

    return 0;
}

pub fn problemTwo() anyerror!void {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var leading_1_lines = try ArrayList([]u8).initCapacity(&gpa.allocator, 100);
    defer leading_1_lines.deinit();

    var leading_0_lines = try ArrayList([]u8).initCapacity(&gpa.allocator, 100);
    defer leading_1_lines.deinit();

    const input = @embedFile("../input");
    var fb = io.fixedBufferStream(input[0..]);
    var buffer: [12]u8 = undefined;
    var first_sum: u32 = 0;
    while (fb.pos < try fb.getEndPos()) {
        const line = try fb.reader().readUntilDelimiterOrEof(&buffer, '\n');
        if (line.?[0] - '0' == 1) {
            try leading_1_lines.append(line.?);
            first_sum += 1;
        } else {
            try leading_0_lines.append(line.?);
        }
    }

    var lines: *ArrayList([]u8) = &leading_0_lines;
    var initial_one = first_sum > (leading_1_lines.items.len + leading_0_lines.items.len) / 2;
    if (initial_one) {
        lines = &leading_1_lines;
    }

    var pos: usize = 0;
    while (pos < 12) {
        const most_common = findMostCommon(lines.items, pos);
        var idx: usize = 0;
        for (leading_1_lines.items) |line| {
            if (line[pos] - '0' == most_common) {
                lines.items[idx] = line;
                idx += 1;
            }
        }

        if (idx == 1) {
            break;
        }

        lines.items.len = idx;
        pos += 1;
    }
    var oxygen = try std.fmt.parseUnsigned(u32, lines.items[0], 2);

    // pick the other list
    if (initial_one) {
        lines = &leading_0_lines;
    } else {
        lines = &leading_1_lines;
    }

    pos = 0;
    while (pos < 12) {
        const most_common = findMostCommon(lines.items, pos);
        var idx: usize = 0;
        for (lines.items) |line| {
            if (line[pos] - '0' != most_common) {
                lines.items[idx] = line;
                idx += 1;
            }
        }

        if (idx == 1) {
            break;
        }

        lines.items.len = idx;
        pos += 1;
    }
    var co2 = try std.fmt.parseUnsigned(u32, lines.items[0], 2);
    std.debug.print("oxygen: {d}, co2: {d}\n", .{ oxygen, co2 });
}

pub fn main() !void {
    try problemOne();
    try problemTwo();
}
