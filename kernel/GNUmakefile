# Nuke built-in rules and variables.
override MAKEFLAGS += -rR

override ZIGFLAGS += \
    -Doptimize=ReleaseSafe

.PHONY: all
all: kernel

.PHONY: kernel
kernel: limine-zig
	zig build $(ZIGFLAGS)

limine-zig:
	git clone https://github.com/limine-bootloader/limine-zig.git --depth=1

.PHONY: clean
clean:
	rm -rf zig-cache zig-out

.PHONY: distclean
distclean: clean
	rm -rf limine-zig
