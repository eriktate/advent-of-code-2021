const std = @import("std");
const SplitIterator = std.mem.SplitIterator;

// define possible segments
const tl = 0b1000000;
const t = 0b0100000;
const tr = 0b0010000;
const m = 0b0001000;
const bl = 0b0000100;
const b = 0b0000010;
const br = 0b0000001;

// define digits encoded as segments
const zero = tl | t | tr | br | b | bl;
const one = tr | br;
const two = t | tr | m | bl | b;
const three = t | tr | m | br | b;
const four = tl | m | tr | br;
const five = t | tl | m | br | b;
const six = t | tl | m | bl | b | br;
const seven = t | tr | br;
const eight = 0b1111111;
const nine = t | tl | tr | m | b | br;

const Pair = struct {
    items: [2]u8,

    fn other(self: Pair, idx: usize) u8 {
        if (idx == 1) {
            return self.items[0];
        }

        return self.items[1];
    }
};

fn contains(el: u8, set: []const u8) ?usize {
    return std.mem.indexOfScalar(u8, set, el);
}

fn findDiff(left: []const u8, right: []const u8) Pair {
    var pair: Pair = undefined;
    var idx: usize = 0;
    for (left) |leftSegment| {
        if (contains(leftSegment, right) == null) {
            pair.items[idx] = leftSegment;
            idx += 1;
        }
    }

    return pair;
}

fn findRightSegments(it: *SplitIterator(u8)) Pair {
    var pair: Pair = undefined;
    while (it.next()) |digit| {
        if (digit.len == 2) {
            it.index = 0;
            std.mem.copy(u8, &pair.items, digit);
            return pair;
        }
    }
    unreachable;
}

fn findTopSegment(it: *SplitIterator(u8), right: Pair) u8 {
    while (it.next()) |digit| {
        if (digit.len == 3) {
            it.index = 0;
            return findDiff(digit, &right.items).items[0];
        }
    }
    unreachable;
}

fn findTLM(it: *SplitIterator(u8), right: Pair) Pair {
    while (it.next()) |digit| {
        if (digit.len == 4) {
            it.index = 0;
            return findDiff(digit, &right.items);
        }
    }
    unreachable;
}

fn findAll(it: *SplitIterator(u8)) [7]u8 {
    while (it.next()) |digit| {
        if (digit.len == 7) {
            it.index = 0;
            return digit[0..7].*;
        }
    }
    unreachable;
}

fn findBLB(all: [7]u8, right: Pair, tlm: Pair, top: u8) Pair {
    // collect all of the other guesses to compare against what's left
    var others: [5]u8 = undefined;
    std.mem.copy(u8, others[0..], &right.items);
    std.mem.copy(u8, others[2..], &tlm.items);
    others[4] = top;

    return findDiff(&all, &others);
}

fn makeKey(it: *SplitIterator(u8), key: []u7, all: [7]u8, right: Pair, tlm: Pair, blb: Pair, top: u8) void {
    key[top - 'a'] = t;

    var diff: Pair = undefined;
    while (it.next()) |digit| {
        if (digit.len == 6) {
            diff = findDiff(&all, digit);
            if (contains(diff.items[0], &right.items)) |idx| {
                key[diff.items[0] - 'a'] = tr;
                key[right.other(idx) - 'a'] = br;
                continue;
            }

            if (contains(diff.items[0], &tlm.items)) |idx| {
                key[diff.items[0] - 'a'] = m;
                key[tlm.other(idx) - 'a'] = tl;
                continue;
            }

            if (contains(diff.items[0], &blb.items)) |idx| {
                key[diff.items[0] - 'a'] = bl;
                key[blb.other(idx) - 'a'] = b;
                continue;
            }
        }
    }
}

fn parse(segments: []const u8, key: [7]u7) u32 {
    var sum: u7 = 0;
    for (segments) |seg| {
        const val = key[seg - 'a'];
        sum |= val;
    }

    return switch (sum) {
        zero => 0,
        one => 1,
        two => 2,
        three => 3,
        four => 4,
        five => 5,
        six => 6,
        seven => 7,
        eight => 8,
        nine => 9,
        else => unreachable,
    };
}

fn problemTwo() !void {
    const input = @embedFile("../sample");
    var lines = std.mem.split(u8, input, "\n");

    var sum: u32 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var halves = std.mem.split(u8, line, "|");
        var encoding = std.mem.split(u8, halves.next().?, " ");

        // order is important here
        const right = findRightSegments(&encoding);
        const top = findTopSegment(&encoding, right);
        const tlm = findTLM(&encoding, right);
        const all = findAll(&encoding);
        const blb = findBLB(all, right, tlm, top);
        var key: [7]u7 = undefined;
        makeKey(&encoding, &key, all, right, tlm, blb, top);

        var digits = std.mem.split(u8, halves.next().?, " ");
        var num: u32 = 0;
        while (digits.next()) |segments| {
            if (segments.len == 0) {
                continue;
            }

            num *= 10;
            num += parse(segments, key);
        }
        sum += num;
    }

    std.debug.print("Answer: {}\n", .{sum});
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
