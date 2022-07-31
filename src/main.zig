const limine = @import("limine");
const std = @import("std");

// The Limine requests can be placed anywhere, but it is important that
// the compiler does not optimise them away, so, usually, they should
// be made volatile or equivalent. In Zig, `export var` is what we use.
pub export var terminal_request: limine.TerminalRequest = .{};

inline fn done() noreturn {
    while (true) {
        asm volatile ("hlt");
    }
}

// The following will be our kernel's entry point.
export fn _start() callconv(.C) noreturn {
    // Ensure we got a terminal
    if (terminal_request.response) |terminal_response| {
        if (terminal_response.terminal_count < 1) {
            done();
        }

        // We should now be able to call the Limine terminal to print out
        // a simple "Hello World" to screen.
        terminal_response.write(null, "Hello World");
    }

    // We're done, just hang...
    done();
}
