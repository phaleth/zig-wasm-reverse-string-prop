const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });
    const optimize = .ReleaseSmall;

    const exe = b.addExecutable(.{
        .name = "json",
        .root_source_file = b.path("json.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.entry = .disabled;
    exe.rdynamic = true;
    exe.initial_memory = std.math.pow(u32, 2, 16) * 35;

    const zigstr = b.dependency("zigstr", .{
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("zigstr", zigstr.module("zigstr"));

    b.installArtifact(exe);
}
