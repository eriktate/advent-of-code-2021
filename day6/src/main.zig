const std = @import("std");
const io = std.io;
const mem = std.mem;
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const ArrayList = std.ArrayList;

const days = 256;

fn problemOne() !void {
    var digits: [9]u64 = std.mem.zeroes([9]u64);

    const input = @embedFile("../input");

    var input_digits = mem.split(u8, input[0..], ",");
    while (input_digits.next()) |digit| {
        digits[digit[0] - '0'] += 1;
    }

    var day: usize = 0;
    while (day < days) : (day += 1) {
        const reproductions = digits[0];

        for (digits) |digit, idx| {
            if (idx == 0) {
                digits[8] += digit;
                digits[6] += digit;
                digits[0] = 0;
                continue;
            }

            if (idx == 6 or idx == 8) {
                digits[idx - 1] += digit - reproductions;
                digits[idx] = reproductions;
                continue;
            }

            digits[idx - 1] += digit;
            digits[idx] = 0;
        }
    }

    var sum: u64 = 0;
    for (digits) |digit| {
        sum += digit;
    }

    std.debug.print("Answer: {}\n", .{sum});
}

pub fn main() anyerror!void {
    try problemOne();
}
