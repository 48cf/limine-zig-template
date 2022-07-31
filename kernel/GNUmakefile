override INTERNALZIGFLAGS := \
	-fno-stage1              \
	-Drelease-safe=true

.PHONY: all
all: kernel

.PHONY: kernel
kernel: limine-zig
	zig build $(INTERNALZIGFLAGS) $(ZIGFLAGS)

limine-zig:
	git clone https://github.com/limine-bootloader/limine-zig.git --depth=1

.PHONY: clean
clean:
	rm -rf zig-cache zig-out

.PHONY: distclean
distclean: clean
	rm -rf limine-zig
