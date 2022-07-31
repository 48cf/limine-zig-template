const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    // Define a freestanding x86_64 cross-compilation target.
    var target: std.zig.CrossTarget = .{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
        .abi = .none,
    };

    // Disable CPU features that require additional initialization
    // like MMX, SSE/2 and AVX. That requires us to enable the soft-float feature.
    const Features = std.Target.x86.Feature;
    target.cpu_features_sub.addFeature(@enumToInt(Features.mmx));
    target.cpu_features_sub.addFeature(@enumToInt(Features.sse));
    target.cpu_features_sub.addFeature(@enumToInt(Features.sse2));
    target.cpu_features_sub.addFeature(@enumToInt(Features.avx));
    target.cpu_features_sub.addFeature(@enumToInt(Features.avx2));
    target.cpu_features_add.addFeature(@enumToInt(Features.soft_float));

    // Build the kernel itself.
    const mode = b.standardReleaseOptions();
    const kernel = b.addExecutable("kernel", "src/main.zig");
    kernel.code_model = .kernel;
    kernel.setBuildMode(mode);
    kernel.addPackagePath("limine", "limine-zig/limine.zig");
    kernel.setLinkerScriptPath(.{ .path = "linker-x86_64.ld" });
    kernel.setTarget(target);
    kernel.install();
}
