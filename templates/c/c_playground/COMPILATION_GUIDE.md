# Manual Compilation Guide

## Understanding `buf[0]` vs `buf`

- **`buf`** - Array name that decays to a pointer to the first element (address)
- **`buf[0]`** - The actual char value stored at index 0 (NOT an address!)
- **`&buf[0]`** - Address of the first element (same as `buf`)

## Viewing Assembly Code

### Method 1: Generate assembly file
```bash
# Generate assembly with Intel syntax (more readable)
clang -S -masm=intel src/main.c -o build/main.s

# Or with AT&T syntax (GNU default)
clang -S src/main.c -o build/main.s

# With optimization
clang -S -O2 -masm=intel src/main.c -o build/main.s
```

### Method 2: View assembly of compiled object
```bash
# Compile to object file
clang -c src/main.c -o build/main.o

# Disassemble with objdump
objdump -d -M intel build/main.o

# Or with llvm-objdump
llvm-objdump -d --x86-asm-syntax=intel build/main.o
```

### Method 3: View inline assembly in source
```bash
# Compile with -save-temps to keep intermediate files
clang -save-temps -masm=intel src/main.c -o build/main
# This creates: main.i (preprocessed), main.s (assembly), main.o (object)
```

## Manual Step-by-Step Compilation

### Step 1: Preprocessing (`.c` → `.i`)
Expands macros, includes headers, removes comments:
```bash
clang -E src/main.c -o build/main.i
# View it: less build/main.i (it's huge because stdio.h is included!)
```

### Step 2: Compilation (`.i` → `.s`)
Converts C to assembly:
```bash
clang -S build/main.i -o build/main.s -masm=intel
# Or directly: clang -S src/main.c -o build/main.s -masm=intel
```

### Step 3: Assembly (`.s` → `.o`)
Assembles assembly to object file:
```bash
clang -c build/main.s -o build/main.o
# Or use the assembler directly: as build/main.s -o build/main.o
```

### Step 4: Linking (`.o` → executable)
Links object file with libraries:
```bash
# Manual linking (you need to specify libraries)
clang build/main.o -o build/main -lc

# Or use ld directly (more complex, need to specify paths)
ld build/main.o -o build/main \
  -dynamic-linker /lib64/ld-linux-x86-64.so.2 \
  -lc \
  /usr/lib/x86_64-linux-gnu/crt1.o \
  /usr/lib/x86_64-linux-gnu/crti.o \
  /usr/lib/x86_64-linux-gnu/crtn.o
```

## Complete Manual Workflow

```bash
# Clean start
rm -rf build/*

# Step 1: Preprocess
clang -E src/main.c -o build/main.i

# Step 2: Compile to assembly
clang -S build/main.i -o build/main.s -masm=intel

# Step 3: Assemble to object
clang -c build/main.s -o build/main.o

# Step 4: Link
clang build/main.o -o build/main

# Run it
./build/main
```

## Quick Commands

```bash
# See all intermediate files at once
clang -save-temps -masm=intel src/main.c -o build/main

# View assembly with syntax highlighting
clang -S -masm=intel src/main.c -o build/main.s && bat build/main.s

# Compare assembly with different optimizations
clang -S -O0 -masm=intel src/main.c -o build/main-O0.s
clang -S -O2 -masm=intel src/main.c -o build/main-O2.s
diff build/main-O0.s build/main-O2.s
```

## Debugging Assembly

```bash
# Compile with debug symbols
clang -g -S -masm=intel src/main.c -o build/main.s

# Use gdb to step through assembly
gdb build/main
(gdb) disassemble main
(gdb) layout asm
(gdb) stepi  # Step one instruction
```

