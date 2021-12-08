const std = @import("std");
const SplitIterator = std.mem.SplitIterator;

const SSD = struct {
    tl: u8,
    t: u8,
    tr: u8,
    m: u8,
    bl: u8,
    b: u8,
    br: u8,

    fn parse(self: SSD, input: []const u8) SSD {
        var ssd: SSD = std.mem.zeroes(SSD);

        for (input) |char| {
            if (char == self.tl) {
                ssd.tl = 1;
            }

            if (char == self.tr) {
                ssd.tr = 1;
            }

            if (char == self.t) {
                ssd.t = 1;
            }

            if (char == self.m) {
                ssd.m = 1;
            }

            if (char == self.br) {
                ssd.br = 1;
            }

            if (char == self.b) {
                ssd.b = 1;
            }

            if (char == self.bl) {
                ssd.bl = 1;
            }
        }

        return ssd;
    }

    fn isZero(self: SSD) bool {
        return self.tr != 0 and self.tl != 0 and self.t != 0 and self.br != 0 and self.bl != 0 and self.b != 0;
    }

    fn isOne(self: SSD) bool {
        return self.tr != 0 and self.br != 0;
    }

    fn isTwo(self: SSD) bool {
        return self.m != 0 and self.t != 0 and self.br != 0 and self.tl != 0 and self.b != 0;
    }

    fn isThree(self: SSD) bool {
        return self.m != 0 and self.t != 0 and self.br != 0 and self.tr != 0 and self.b != 0;
    }

    fn isFour(self: SSD) bool {
        return self.m != 0 and self.tl != 0 and self.br != 0 and self.tr != 0;
    }

    fn isFive(self: SSD) bool {
        return self.m != 0 and self.tl != 0 and self.t != 0 and self.br != 0 and self.b != 0;
    }

    fn isSix(self: SSD) bool {
        return self.m != 0 and self.tl != 0 and self.t != 0 and self.br != 0 and self.bl != 0 and self.b != 0;
    }

    fn isSeven(self: SSD) bool {
        return self.isOne() and self.t != 0;
    }

    fn isEight(self: SSD) bool {
        return isZero(self) and self.m != 0;
    }

    fn isNine(self: SSD) bool {
        return self.tr != 0 and self.tl != 0 and self.t != 0 and self.bl != 0 and self.b != 0 and self.m != 0;
    }

    fn getInt(self: SSD) u32 {
        if (self.isEight()) {
            return 8;
        }

        if (self.isZero()) {
            return 0;
        }

        if (self.isNine()) {
            return 9;
        }

        if (self.isSix()) {
            return 6;
        }

        if (self.isFive()) {
            return 5;
        }

        if (self.isFour()) {
            return 4;
        }

        if (self.isThree()) {
            return 3;
        }

        if (self.isTwo()) {
            return 2;
        }

        if (self.isOne()) {
            return 1;
        }

        unreachable;
    }

    fn print(self: SSD) void {
        std.debug.print("TL={c}, T={c}, TR={c}, M={c}, BL={c}, B={c}, BR={c}\n", .{ self.tl, self.t, self.tr, self.m, self.bl, self.b, self.br });
    }
};

fn findDiff(left: []const u8, right: []const u8) u8 {
    for (left) |leftSegment| {
        var found = false;
        for (right) |rightSegment| {
            if (leftSegment == rightSegment) {
                found = true;
                break;
            }
        }

        if (!found) {
            return leftSegment;
        }
    }

    unreachable;
}

fn contains(el: u8, set: []const u8) bool {
    return std.mem.indexOfScalar(u8, set, el) != null;
}

fn findRightSegments(it: *SplitIterator(u8)) [2]u8 {
    while (it.next()) |digit| {
        if (digit.len == 2) {
            it.index = 0;
            return digit[0..2].*;
        }
    }

    unreachable;
}

fn findTopSegment(it: *SplitIterator(u8), right: [2]u8) u8 {
    while (it.next()) |digit| {
        if (digit.len == 3) {
            it.index = 0;
            return findDiff(digit, right[0..2]);
        }
    }
    unreachable;
}

fn findTLM(it: *SplitIterator(u8), right: [2]u8) [2]u8 {
    var idx: usize = 0;
    var result: [2]u8 = undefined;
    while (it.next()) |digit| {
        if (digit.len == 4) {
            it.index = 0;
            for (digit) |char| {
                if (!contains(char, right[0..])) {
                    result[idx] = char;
                    if (idx == 1) {
                        return result;
                    }
                    idx += 1;
                }
            }
        }
    }
    unreachable;
}

fn findEight(it: *SplitIterator(u8)) [7]u8 {
    while (it.next()) |digit| {
        if (digit.len == 7) {
            it.index = 0;
            return digit[0..7].*;
        }
    }
    unreachable;
}

fn findBLB(eight: [7]u8, right: [2]u8, tlm: [2]u8, top: u8) [2]u8 {
    var idx: usize = 0;
    var result: [2]u8 = undefined;

    var others: [5]u8 = undefined;
    std.mem.copy(u8, others[0..], right[0..]);
    std.mem.copy(u8, others[2..], tlm[0..]);
    others[4] = top;

    for (eight) |seg| {
        if (!contains(seg, others[0..])) {
            result[idx] = seg;
            if (idx == 1) {
                return result;
            }
            idx += 1;
        }
    }
    unreachable;
}

fn makeKey(it: *SplitIterator(u8), eight: [7]u8, right: [2]u8, tlm: [2]u8, blb: [2]u8, top: u8) SSD {
    var key: SSD = undefined;
    key.t = top;

    while (it.next()) |digit| {
        if (digit.len == 6) {
            const diff = findDiff(&eight, digit);
            if (contains(diff, &right)) {
                key.tr = diff;
                key.br = findDiff(&right, &[1]u8{diff});
                continue;
            }

            if (contains(diff, &tlm)) {
                key.m = diff;
                key.tl = findDiff(&tlm, &[1]u8{diff});
                continue;
            }

            if (contains(diff, &blb)) {
                key.bl = diff;
                key.b = findDiff(&blb, &[1]u8{diff});
                continue;
            }
        }
    }

    return key;
}

// we know the two right segments (not sure which is which)
// we know the top segment (from 7)
// we know the tl and middle segment
// we know the bl and bottom segment
// we know the middle segment (from 8 - 0)
fn problemTwo() !void {
    const input = @embedFile("../sample");
    var lines = std.mem.split(u8, input, "\n");

    var count: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var halves = std.mem.split(u8, line, "|");
        var key = std.mem.split(u8, halves.next().?, " ");
        const right = findRightSegments(&key);
        std.debug.print("Right segment: {s}\n", .{right});
        const top = findTopSegment(&key, right);
        std.debug.print("Top segment: {c}\n", .{top});
        const tlm = findTLM(&key, right);
        std.debug.print("TLM: {s}\n", .{tlm});
        const eight = findEight(&key);
        std.debug.print("Eight: {s}\n", .{eight});
        const blb = findBLB(eight, right, tlm, top);
        std.debug.print("BLB: {s}\n", .{blb});
        const ssd_key = makeKey(&key, eight, right, tlm, blb, top);
        ssd_key.print();

        var digits = std.mem.split(u8, halves.next().?, " ");
        while (digits.next()) |digit| {
            const ssd = ssd_key.parse(digit);
            std.debug.print("{}\n", .{ssd.getInt()});
        }
    }

    std.debug.print("Answer: {}\n", .{count});
}

fn problemOne() !void {
    const input = @embedFile("../input");
    var lines = std.mem.split(u8, input, "\n");

    var count: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var halves = std.mem.split(u8, line, "|");
        _ = halves.next();
        var digits = std.mem.split(u8, halves.next().?, " ");
        while (digits.next()) |digit| {
            switch (digit.len) {
                2, 3, 4, 7 => count += 1,
                else => undefined,
            }
        }
    }

    std.debug.print("Answer: {}\n", .{count});
}

pub fn main() anyerror!void {
    try problemOne();
    try problemTwo();
}
