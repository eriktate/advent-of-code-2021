const std = @import("std");
const io = std.io;

// all commands start with a different char, so we can know which it is
// by only evaluating one char

// based on the command, we can determine the byte offset to the value
fn getOffset(char: u8) usize {
    switch (char) {
        'f' => return 7,
        'd' => return 4,
        'u' => return 2,
        else => return 0,
    }
}

// a fixedBufferStream advances an internal index after each read, so we're basically "popping"
// a char off the front
fn readChar(fb: anytype) u8 {
    var buffer: [1]u8 = undefined;
    _ = fb.read(buffer[0..]) catch unreachable;
    return buffer[0];
}

fn problemOne() void {
    const input = @embedFile("../input");
    var fb = io.fixedBufferStream(input[0..]);

    var horizontal: u32 = 0;
    var depth: u32 = 0;

    // grab first character
    while (fb.pos < try fb.getEndPos()) {
        const first_char = readChar(&fb);
        const offset = getOffset(first_char);
        fb.pos = fb.pos + offset; // advance to digit
        const val = readChar(&fb) - '0'; // ascii -> decimal conversion
        fb.pos += 1; // skip newline
        switch (first_char) {
            'f' => horizontal += val,
            'd' => depth += val,
            'u' => depth -= val,
            else => undefined,
        }
    }
    std.debug.print("Horizontal: {d}, Depth: {d}, Answer: {d}\n", .{ horizontal, depth, horizontal * depth });
}

fn problemTwo() void {
    const input = @embedFile("../input");
    var fb = io.fixedBufferStream(input[0..]);

    var horizontal: u32 = 0;
    var depth: u32 = 0;
    var aim: u32 = 0;

    // grab first character
    while (fb.pos < try fb.getEndPos()) {
        const first_char = readChar(&fb);
        const offset = getOffset(first_char);
        fb.pos = fb.pos + offset; // advance to digit
        const val = readChar(&fb) - '0'; // ascii -> decimal conversion
        fb.pos += 1; // skip newline
        switch (first_char) {
            'f' => {
                horizontal += val;
                depth += val * aim;
            },
            'd' => aim += val,
            'u' => aim -= val,
            else => undefined,
        }
    }
    std.debug.print("Horizontal: {d}, Depth: {d}, Answer: {d}\n", .{ horizontal, depth, horizontal * depth });
}

pub fn main() anyerror!void {
    problemOne();
    problemTwo();
}
