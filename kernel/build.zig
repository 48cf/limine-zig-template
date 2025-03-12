const std = @import("std");

/// A list of architectures supported by the kernel.
const Arch = enum {
    x86_64,
    aarch64,
    riscv64,
    loongarch64,

    /// Convert the architecture to an std.Target.Cpu.Arch.
    fn toStd(self: @This()) std.Target.Cpu.Arch {
        return switch (self) {
            .x86_64 => .x86_64,
            .aarch64 => .aarch64,
            .riscv64 => .riscv64,
            .loongarch64 => .loongarch64,
        };
    }
};

/// Create a target query for the given architecture.
/// The target needs to disable some features that are not supported
/// in a bare-metal environment, such as SSE or AVX on x86_64.
fn targetQueryForArch(arch: Arch) std.Target.Query {
    var query: std.Target.Query = .{
        .cpu_arch = arch.toStd(),
        .os_tag = .freestanding,
        .abi = .none,
    };

    switch (arch) {
        .x86_64 => {
            const Target = std.Target.x86;

            query.cpu_features_add = Target.featureSet(&.{ .popcnt, .soft_float });
            query.cpu_features_sub = Target.featureSet(&.{ .avx, .avx2, .sse, .sse2, .mmx });
        },
        .aarch64 => {
            const Target = std.Target.aarch64;

            query.cpu_features_add = Target.featureSet(&.{});
            query.cpu_features_sub = Target.featureSet(&.{ .fp_armv8, .crypto, .neon });
        },
        .riscv64 => {
            const Target = std.Target.riscv;

            query.cpu_features_add = Target.featureSet(&.{});
            query.cpu_features_sub = Target.featureSet(&.{.d});
        },
        .loongarch64 => {},
    }

    return query;
}

pub fn build(b: *std.Build) void {
    const arch = b.option(Arch, "arch", "Architectue to build the kernel for") orelse .x86_64;

    // We depend on the limine_zig package, which provides a module for
    // interacting with the Limine bootloader. For more information about
    // the Limine boot protocol, see:
    // - https://github.com/limine-bootloader/limine/blob/trunk/PROTOCOL.md
    // - https://github.com/limine-bootloader/limine/blob/trunk/limine.h
    const limine_zig = b.dependency("limine_zig", .{ .api_revision = 3 });
    const limine_module = limine_zig.module("limine");

    const query = targetQueryForArch(arch);

    // Resolve the target query and the standard optimization options.
    // The optimization options can be overriden on the command line
    // by passing the `-Doptimize=<option>` flag to the build command.
    const target = b.resolveTargetQuery(query);
    const optimize = b.standardOptimizeOption(.{});

    // Create a module for the kernel.
    const kernel_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Specify the code model and other target-specific options.
    switch (arch) {
        .x86_64 => {
            kernel_module.red_zone = false;
            kernel_module.code_model = .kernel;
        },
        .aarch64, .riscv64, .loongarch64 => {},
    }

    // Add the limine module as an import to the kernel module.
    kernel_module.addImport("limine", limine_module);

    // Create an executable for the kernel using the kernel module.
    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_module = kernel_module,
    });

    // Set the linker script for the kernel based on the architecture.
    kernel.setLinkerScript(b.path(b.fmt("linker-{s}.lds", .{@tagName(arch)})));

    // I am not sure whether it is the best way to override exe_dir, but it seems
    // to work just fine - if you have a better idea, please let me know!
    b.resolveInstallPrefix(null, .{ .exe_dir = b.fmt("bin-{s}", .{@tagName(arch)}) });
    b.installArtifact(kernel);
}
