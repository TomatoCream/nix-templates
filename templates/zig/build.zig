const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the library
    const lib = b.addStaticLibrary(.{
        .name = "lib",
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Create the executable
    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Link the library to the executable
    exe.linkLibrary(lib);

    // Install artifacts
    b.installArtifact(lib);
    b.installArtifact(exe);

    // Create and run tests
    const lib_tests = b.addTest(.{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&lib_tests.step);
    test_step.dependOn(&main_tests.step);
}
