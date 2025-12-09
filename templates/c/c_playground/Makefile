# Simple C Makefile for learning
# Switch compiler: make CC=gcc  or  make CC=clang

CC      ?= clang
LINKER  ?= mold
TARGET  := main
SRC     := src/main.c
BUILD   := build

# Basic flags - keep it simple for learning
CFLAGS  := -Wall -g

# ============================================================================
# LEARNING NOTES: Compiler Flags
# ============================================================================
#
# WARNINGS (pick what you want):
#   -Wall              common warnings (recommended)
#   -Wextra            extra warnings
#   -Werror            treat warnings as errors (strict!)
#   -Wpedantic         strict ISO C compliance
#   -Wno-unused        disable unused variable warnings
#
# DEBUG vs RELEASE:
#   -g                 include debug symbols (for gdb)
#   -O0                no optimization (easiest to debug)
#   -O2                optimize for speed
#   -O3                aggressive optimization
#   -Os                optimize for size
#
# STATIC LINKING (no shared libraries at runtime):
#   -static            link everything statically
#
# FREESTANDING (no standard library - OS/embedded dev):
#   -ffreestanding     don't assume standard library exists
#   -nostdlib          don't link standard library
#   -nodefaultlibs     don't link default libraries
#   -nostartfiles      don't use standard startup files
#   -fno-builtin       don't use compiler built-in functions
#
#   Example freestanding build:
#   CFLAGS := -ffreestanding -nostdlib -fno-builtin
#   You'll need to provide your own _start, write your own syscalls, etc.
#
# LINKER:
#   -fuse-ld=mold      use mold linker (faster)
#   -fuse-ld=lld       use LLVM's lld linker
#   -fuse-ld=gold      use gold linker
#
# SANITIZERS (debug helpers):
#   -fsanitize=address    catch memory bugs (use with -g)
#   -fsanitize=undefined  catch undefined behavior
#
# ============================================================================

LDFLAGS := -fuse-ld=$(LINKER)

.PHONY: all run clean watch bear

all: $(BUILD)/$(TARGET)

$(BUILD)/$(TARGET): $(SRC) | $(BUILD)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SRC)

$(BUILD):
	mkdir -p $(BUILD)

run: $(BUILD)/$(TARGET)
	./$(BUILD)/$(TARGET)

# Auto-rebuild on file changes: make watch
watch:
	fd -e c -e h | entr -c make run

# Generate compile_commands.json for clangd LSP
bear: clean
	bear -- make

clean:
	rm -rf $(BUILD) compile_commands.json

