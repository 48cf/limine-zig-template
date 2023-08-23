# Nuke built-in rules and variables.
override MAKEFLAGS += -rR

override ZIGFLAGS += \
    -Doptimize=ReleaseSafe

.PHONY: all
all: kernel

.PHONY: kernel
kernel:
	zig build $(ZIGFLAGS)
	cp zig-out/bin/kernel kernel.elf

.PHONY: clean
clean:
	rm -rf zig-cache zig-out kernel.elf

.PHONY: distclean
distclean: clean
	rm -rf limine-zig
