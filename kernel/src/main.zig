const builtin = @import("builtin");
const limine = @import("limine");

export var start_marker: limine.RequestsStartMarker linksection(".limine_requests_start") = .{};
export var end_marker: limine.RequestsEndMarker linksection(".limine_requests_end") = .{};

export var base_revision: limine.BaseRevision linksection(".limine_requests") = .init(3);
export var framebuffer_request: limine.FramebufferRequest linksection(".limine_requests") = .{};

fn hcf() noreturn {
    while (true) {
        switch (builtin.cpu.arch) {
            .x86_64 => asm volatile ("hlt"),
            .aarch64 => asm volatile ("wfi"),
            .riscv64 => asm volatile ("wfi"),
            .loongarch64 => asm volatile ("idle 0"),
            else => unreachable,
        }
    }
}

export fn _start() noreturn {
    if (!base_revision.isSupported()) {
        @panic("Base revision not supported");
    }

    if (framebuffer_request.response) |framebuffer_response| {
        const framebuffer = framebuffer_response.getFramebuffers()[0];
        for (0..100) |i| {
            const fb_ptr: [*]volatile u32 = @ptrCast(@alignCast(framebuffer.address));
            fb_ptr[i * (framebuffer.pitch / 4) + i] = 0xffffff;
        }
    } else {
        @panic("Framebuffer response not present");
    }

    hcf();
}
