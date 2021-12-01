const std = @import("std");
const input = @import("input.zig").input;

// both solutions assume an input large enough for at least one comparison

fn problemOne() void {
    var prev_reading: u32 = input[0];
    var counter: u32 = 0;

    for (input[1..]) |reading| {
        if (reading > prev_reading) {
            counter += 1;
        }
        prev_reading = reading;
    }

    std.debug.print("P1 - Increased readings: {d}\n", .{counter});
}

fn problemTwo() void {
    var prev_reading: u32 = input[0] + input[1] + input[2];
    var counter: u32 = 0;
    for (input) |reading, idx| {
        if (idx < 3) {
            continue;
        }
        const new_reading = prev_reading + reading - input[idx - 3];
        if (new_reading > prev_reading) {
            counter += 1;
        }
        prev_reading = new_reading;
    }

    std.debug.print("P2 - Increased readings: {d}\n", .{counter});
}

pub fn main() anyerror!void {
    problemOne();
    problemTwo();
}
