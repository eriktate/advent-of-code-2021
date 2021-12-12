const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const StringHashMap = std.StringHashMap;
const ArrayList = std.ArrayList;

const CaveMap = StringHashMap(ArrayList([]const u8));
const Set = StringHashMap(u8);

fn isSmall(name: []const u8) bool {
    return std.ascii.isLower(name[0]);
}

fn addConnection(caves: *CaveMap, start: []const u8, end: []const u8) !void {
    var existing = caves.getPtr(start);
    if (existing) |cave| {
        try cave.append(end);
        return;
    }

    var connections = try ArrayList([]const u8).initCapacity(caves.allocator, 16);
    try connections.append(end);
    try caves.put(start, connections);
}

fn canVisit(visited: *Set, route: []const u8) bool {
    if (!isSmall(route)) {
        return true;
    }

    if (std.mem.eql(u8, route, "start")) {
        return false;
    }

    if (visited.contains(route)) {
        var it = visited.iterator();
        return while (it.next()) |cave| {
            if (cave.value_ptr.* == 2) {
                break false;
            }
        } else true;
    }

    return true;
}

fn visit(visited: *Set, key: []const u8) !void {
    if (!isSmall(key)) {
        return;
    }

    var val: u8 = 1;
    if (visited.get(key)) |existing| {
        val += existing;
    }

    try visited.put(key, val);
}

fn removeVisit(visited: *Set, key: []const u8) !void {
    if (!isSmall(key)) {
        return;
    }

    if (visited.get(key)) |existing| {
        if (existing > 1) {
            try visited.put(key, existing - 1);
            return;
        }
    }

    _ = visited.remove(key);
}

fn traverse(caves: *CaveMap, visited: *Set, start_key: []const u8) anyerror!u32 {
    // std.debug.print("Visiting: {s}\n", .{start_key});
    const start = caves.get(start_key).?;
    try visit(visited, start_key);

    var paths: u32 = 0;
    for (start.items) |route| {
        if (std.mem.eql(u8, route, "end")) {
            paths += 1;
            continue;
        }

        if (!canVisit(visited, route)) {
            // std.debug.print("Skipping double visit: {s}\n", .{route});
            continue;
        }

        paths += try traverse(caves, visited, route);
    }

    try removeVisit(visited, start_key);
    return paths;
}

// pub fn problemOne() anyerror!void {
//     var gpa = GeneralPurposeAllocator(.{}){};
//     defer _ = gpa.deinit();
//     var alloc = &gpa.allocator;

//     var caves = CaveMap.init(alloc);
//     defer caves.deinit();

//     const input = @embedFile("../input");
//     var lines = std.mem.split(u8, input, "\n");

//     while (lines.next()) |line| {
//         if (line.len == 0) {
//             continue;
//         }

//         var caves_it = std.mem.split(u8, line, "-");
//         const start = caves_it.next().?;
//         const end = caves_it.next().?;

//         try addConnection(&caves, start, end);
//         try addConnection(&caves, end, start);
//     }

//     var visited = Set.init(alloc);
//     defer visited.deinit();
//     const paths = try traverse(&caves, &visited, "start");
//     var it = caves.iterator();
//     while (it.next()) |cave| {
//         // std.debug.print("{s}: ", .{cave.key_ptr.*});
//         // for (cave.value_ptr.items) |route| {
//         //     std.debug.print("{s} ", .{route});
//         // }
//         // std.debug.print("\n", .{});
//         cave.value_ptr.deinit();
//     }

//     std.debug.print("Paths: {}\n", .{paths});
// }

pub fn problemTwo() anyerror!void {
    var gpa = GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = &gpa.allocator;

    var caves = CaveMap.init(alloc);
    defer caves.deinit();

    const input = @embedFile("../input");
    var lines = std.mem.split(u8, input, "\n");

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var caves_it = std.mem.split(u8, line, "-");
        const start = caves_it.next().?;
        const end = caves_it.next().?;

        try addConnection(&caves, start, end);
        try addConnection(&caves, end, start);
    }

    var visited = Set.init(alloc);
    defer visited.deinit();
    const paths = try traverse(&caves, &visited, "start");
    var it = caves.iterator();
    while (it.next()) |cave| {
        cave.value_ptr.deinit();
    }

    std.debug.print("Paths: {}\n", .{paths});
}

pub fn main() anyerror!void {
    // try problemOne();
    try problemTwo();
}
