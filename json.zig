const std = @import("std");
const zigstr = @import("zigstr");

const walloc = std.heap.wasm_allocator;

const Person = struct {
    id: i32,
    name: []u8,
};

export fn reverseNames(s: [*]u8, length: usize, capacity: usize) i32 {
    const input = s[0..length];
    var parsed = std.json.parseFromSlice([]Person, walloc, input, .{}) catch return -1;
    defer parsed.deinit();
    const people = parsed.value;

    var str = zigstr.fromConstBytes(walloc, "") catch return -2;
    defer str.deinit();
    for (people) |x| {
        str.reset(x.name) catch return -3;
        str.reverse() catch return -4;
        @memcpy(x.name, str.bytes());
    }

    var output = std.ArrayList(u8).init(walloc);
    defer output.deinit();
    std.json.stringify(people, .{}, output.writer()) catch return -5;

    const outputLength = output.items.len;
    if (outputLength > capacity) {
        return -6;
    }
    @memcpy(s[0..outputLength], output.items);
    return @as(i32, @intCast(outputLength));
}
