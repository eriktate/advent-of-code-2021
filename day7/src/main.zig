const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const ArrayList = std.ArrayList;

fn getFuelCost(steps: u32) u32 {
    return (steps * (steps + 1)) / 2;
}

pub fn main() anyerror!void {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = &gpa.allocator;

    const input = @embedFile("../input");

    var raw_digits = std.mem.tokenize(u8, input, ",\n");
    var digits = try ArrayList(u32).initCapacity(alloc, 1000);
    defer digits.deinit();

    var largest: u32 = 0;
    while (raw_digits.next()) |raw| {
        const digit = try std.fmt.parseInt(u32, raw, 10);
        if (digit > largest) {
            largest = digit;
        }
        try digits.append(digit);
    }

    var cheapest: u32 = std.math.maxInt(u32);
    var idx: u32 = 0;
    while (idx < largest) : (idx += 1) {
        var fuel_cost: u32 = 0;
        for (digits.items) |digit| {
            var diff: i32 = @intCast(i32, digit) - @intCast(i32, idx);
            fuel_cost += getFuelCost(@intCast(u32, try std.math.absInt(diff)));
        }

        if (fuel_cost < cheapest) {
            cheapest = fuel_cost;
        }
    }

    std.debug.print("Answer: {}\n", .{cheapest});
}
