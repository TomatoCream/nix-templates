const std = @import("std");
const lib = @import("lib.zig");

pub fn main() !void {
    std.debug.print("Hello from Zig!\n", .{});
    try lib.runExample();
}

test "basic test" {
    try std.testing.expectEqual(true, true);
}
