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

    std.debug.print("gamma: {d}, epsilon: {d}, power output: {d}\n", .{ gamma, epsilon, gamma * epsilon });
}

fn findMostCommon(lines: [][]const u8, pos: usize) u1 {
    var sum: u32 = 0;
    for (lines) |line| {
        sum += line[pos] - '0';
    }

    const threshold = lines.len / 2 + @mod(lines.len, 2);
    if (sum >= threshold) {
        return 1;
    }

    return 0;
}

fn findLeastCommon(lines: [][]const u8, pos: usize) u1 {
    var sum: u32 = 0;
    for (lines) |line| {
        sum += line[pos] - '0';
    }

    const threshold = lines.len / 2 + @mod(lines.len, 2);
    if (sum < threshold) {
        return 1;
    }

    return 0;
}

pub fn problemTwo() anyerror!void {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // const input = @embedFile("../input");
    const input = @embedFile("../input");
    var fb = io.fixedBufferStream(input[0..]);

    var o2_lines = try ArrayList([]const u8).initCapacity(&gpa.allocator, 100);
    defer o2_lines.deinit();

    var co2_lines = try ArrayList([]const u8).initCapacity(&gpa.allocator, 100);
    defer co2_lines.deinit();

    while (fb.pos < try fb.getEndPos()) {
        const prev_pos = fb.pos;
        _ = try fb.reader().skipUntilDelimiterOrEof('\n');
        // can't read into array list because it's a list of slices,
        // so we need to slice the source data at the appropriate positions
        try o2_lines.append(input[prev_pos .. fb.pos - 1]);
        try co2_lines.append(input[prev_pos .. fb.pos - 1]);
    }

    var pos: usize = 0;
    while (pos < o2_lines.items[0].len) {
        const most_common = findMostCommon(o2_lines.items, pos);
        var idx: usize = 0;
        for (o2_lines.items) |line| {
            if (line[pos] - '0' == most_common) {
                o2_lines.items[idx] = line;
                idx += 1;
            }
        }

        if (idx == 1) {
            break;
        }

        o2_lines.items.len = idx;
        pos += 1;
    }
    var oxygen = try std.fmt.parseUnsigned(u32, o2_lines.items[0], 2);

    pos = 0;
    while (pos < co2_lines.items[0].len) {
        const least_common = findLeastCommon(co2_lines.items, pos);
        var idx: usize = 0;
        for (co2_lines.items) |line| {
            if (line[pos] - '0' == least_common) {
                co2_lines.items[idx] = line;
                idx += 1;
            }
        }

        if (idx == 1) {
            break;
        }

        co2_lines.items.len = idx;
        pos += 1;
    }
    var co2 = try std.fmt.parseUnsigned(u32, co2_lines.items[0], 2);

    std.debug.print("oxygen: {d}, co2: {d}, answer: {d}\n", .{ oxygen, co2, oxygen * co2 });
}

pub fn main() !void {
    try problemOne();
    try problemTwo();
}
