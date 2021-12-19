const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;
const AutoHashMap = std.AutoHashMap;

fn buildPolymer(pair_lookup: StringHashMap(u8), freq_map: *AutoHashMap(u8, u32), src: *ArrayList(u8), dst: *ArrayList(u8)) !void {
    std.debug.print("\n", .{});
    freq_map.clearRetainingCapacity();
    for (src.items) |el, idx| {
        if (idx > 0) {
            const pair = src.items[idx - 1 .. idx + 1];
            if (pair_lookup.get(pair)) |insertion| {
                var freq: u32 = 1;
                if (freq_map.get(insertion)) |existing| {
                    freq += existing;
                }
                try freq_map.put(insertion, freq);
                try dst.append(insertion);
            }
        }

        var freq: u32 = 1;
        if (freq_map.get(el)) |existing| {
            freq += existing;
        }
        try freq_map.put(el, freq);
        try dst.append(el);
    }

    var it = freq_map.iterator();
    while (it.next()) |entry| {
        std.debug.print("{c}: {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
}

const steps: u32 = 40;

pub fn problemOne() anyerror!void {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var alloc = &gpa.allocator;

    var pair_lookup = StringHashMap(u8).init(alloc);
    defer pair_lookup.deinit();

    var freq_map = AutoHashMap(u8, u32).init(alloc);
    defer freq_map.deinit();

    var polymer1 = try ArrayList(u8).initCapacity(alloc, 1024 * 1024 * 1024 * 2);
    defer polymer1.deinit();

    var polymer2 = try ArrayList(u8).initCapacity(alloc, 1024 * 1024 * 1024 * 2);
    defer polymer2.deinit();

    const input = @embedFile("../sample");
    var lines = std.mem.split(u8, input, "\n");
    try polymer1.appendSlice(lines.next().?);
    _ = lines.next();

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var map_it = std.mem.split(u8, line, " -> ");
        try pair_lookup.put(map_it.next().?, map_it.next().?[0]);
    }

    var idx: u32 = 0;
    var src = &polymer2;
    var dst = &polymer1;
    while (idx < steps) : (idx += 1) {
        std.debug.print("Step: {}\n", .{idx});
        var tmp = src;
        src = dst;
        dst = tmp;
        dst.items.len = 0;

        try buildPolymer(pair_lookup, &freq_map, src, dst);
    }

    var it = freq_map.iterator();
    var high_element: u8 = undefined;
    var low_element: u8 = undefined;
    var high_freq: u32 = 0;
    var low_freq: u32 = std.math.maxInt(u32);
    while (it.next()) |entry| {
        const freq = entry.value_ptr.*;
        if (freq > high_freq) {
            high_freq = freq;
            high_element = entry.key_ptr.*;
        }

        if (freq < low_freq) {
            low_freq = freq;
            low_element = entry.key_ptr.*;
        }
    }

    std.debug.print("Polymer: {s}\n", .{dst.items});
    std.debug.print("High: {c}={} Low: {c}={}\n", .{ high_element, high_freq, low_element, low_freq });
    std.debug.print("Answer: {}\n", .{high_freq - low_freq});
}

pub fn main() anyerror!void {
    try problemOne();
}
