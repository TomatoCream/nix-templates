const std = @import("std");

pub fn runExample() !void {
    std.debug.print("Hello from the library!\n", .{});
}

test "library test" {
    try std.testing.expectEqual(true, true);
}
