# C++ Development Environment (Clang + Nix)

This is a modern C++23 development environment powered by Nix Flakes and Clang.

## Features
- **Compiler**: Clang (LLVM 18)
- **LSP**: `clangd`
- **Debugger**: `lldb`
- **Build System**: CMake + Ninja
- **Formatting**: `clang-format` (project-wide via `treefmt`)
- **Nix Support**: `nil` LSP for Nix files

## Quick Start

1. **Enable Direnv**:
   ```bash
   direnv allow
   ```
   *If you don't have `direnv`, run `nix develop` instead.*

2. **Generate Compile Commands (for LSP)**:
   ```bash
   cmake -B build -G Ninja
   ```
   This creates `build/compile_commands.json`, which `clangd` will use for full code intelligence.

3. **Build**:
   ```bash
   cmake --build build
   ```

## Doom Emacs Configuration

To get the best experience in Doom Emacs, ensure your `~/.doom.d/init.el` has these modules enabled:

```elisp
;; in ~/.doom.d/init.el
:tools
lsp

:lang
(cc +lsp) ; Enable C/C++ with LSP support
(nix +lsp) ; Optional: Enable Nix with LSP support
```

### Tips for LSP
- **LSP-mode** should automatically pick up `clangd` from the Nix shell.
- If `clangd` doesn't find your headers, ensure `compile_commands.json` is in the root directory or in a `build/` subdirectory. Doom's `lsp-mode` is usually smart enough to find it.
- Use `M-x lsp-workspace-restart` if you change your build configuration.

## Formatting
Run `treefmt` or `just fmt` to format the entire project (C++ and Nix files).

## Compiler Internals & Inspection

This project is configured with a rich set of tools to explore the C++ compilation pipeline from source to machine code.

### The Compilation Flow

1.  **AST (Abstract Syntax Tree)**: Clang parses C++ into a logical tree.
    - Run: `just ast`
2.  **LLVM IR (Intermediate Representation)**: High-level, platform-independent assembly.
    - Run: `just ir` (text) or `just bitcode` (binary)
3.  **Optimization Passes**: The middle-end transforms the IR to make it faster/smaller.
    - Run: `just passes` (logs every transformation to `build/passes.log`)
4.  **Backend (Object Files)**: IR is converted to machine code (ELF on Linux).
    - Run: `just compile` to generate `.o` files.
    - Run: `just inspect-elf` or `just size` to view binary metadata.
5.  **Linker (mold)**: High-performance linker combines objects into an executable.
    - Run: `just build` or `just run`

### Inspection Toolbox

| Task | Command | Description |
| :--- | :--- | :--- |
| **Parsing** | `just ast` | Dump the Clang AST |
| **Middle-end** | `just ir` / `bitcode` | View the LLVM Intermediate Representation |
| **Optimizer** | `just passes` | Trace every optimization pass step-by-step |
| **Assembly** | `just disasm` | View assembly interleaved with C++ source |
| **ELF Header** | `just inspect-elf` | View ELF sections and headers |
| **Symbols** | `just inspect-symbols` | View demangled global symbols in the binary |
| **Temp Files** | `just dump` | Save all intermediate files (`.i`, `.bc`, `.s`, `.o`) |
