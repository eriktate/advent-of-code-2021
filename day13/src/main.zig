const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const AutoHashMap = std.AutoHashMap;
const ArrayList = std.ArrayList;

const Dot = struct {
    x: u32,
    y: u32,
};

const Axis = enum {
    X,
    Y,
};

const Instruction = struct {
    axis: Axis,
    pos: u32,
};

fn foldDot(dot: Dot, fold: Instruction) Dot {
    switch (fold.axis) {
        Axis.Y => {
            if (dot.y < fold.pos) {
                return dot;
            }

            return Dot{
                .x = dot.x,
                .y = fold.pos - (dot.y - fold.pos),
            };
        },
        Axis.X => {
            if (dot.x < fold.pos) {
                return dot;
            }

            return Dot{
                .x = fold.pos - (dot.x - fold.pos),
                .y = dot.y,
            };
        },
    }
}

pub fn main() anyerror!void {
    var gpa = GeneralPurposeAllocator(.{}){};
    // defer _ = gpa.deinit();
    var alloc = &gpa.allocator;

    var dots = AutoHashMap(Dot, void).init(alloc);
    // defer dots.deinit();
    var instructions = try ArrayList(Instruction).initCapacity(alloc, 16);
    // defer dots.deinit();

    const input = @embedFile("../input");
    var lines = std.mem.split(u8, input, "\n");

    // read dots
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var dot_raw = std.mem.split(u8, line, ",");
        var dot = Dot{
            .x = try std.fmt.parseInt(u32, dot_raw.next().?, 10),
            .y = try std.fmt.parseInt(u32, dot_raw.next().?, 10),
        };
        try dots.put(dot, {});
    }

    // read instructions
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var ins_line = std.mem.split(u8, line, " ");
        _ = ins_line.next();
        _ = ins_line.next();
        const ins = ins_line.next().?;
        try instructions.append(Instruction{
            .axis = switch (ins[0]) {
                'y' => Axis.Y,
                'x' => Axis.X,
                else => unreachable,
            },
            .pos = try std.fmt.parseInt(u32, ins[2..], 10),
        });
    }

    for (instructions.items[0..1]) |instruction| {
        var it = dots.iterator();
        while (it.next()) |entry| {
            const dot = foldDot(entry.key_ptr.*, instruction);
            _ = dots.remove(entry.key_ptr.*);
            try dots.put(dot, {});
        }
    }

    std.debug.print("Answer: {}\n", .{dots.count()});
}
