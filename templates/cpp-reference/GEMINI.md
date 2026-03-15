# Project Context: cpp-reference

This repository is a modern C++ development environment and reference project, optimized for a Clang-based workflow within a Nix Flake.

## Architecture & Tooling
- **Nix Flake**: Uses `pkgs.clangStdenv` to provide a pure Clang/LLVM environment (v21+) instead of GCC.
- **Language Standard**: Controlled via `CMakeLists.txt` (currently C++23). To upgrade or downgrade the C++ version, modify `set(CMAKE_CXX_STANDARD ...)` in `CMakeLists.txt` rather than changing the Nix Flake.
- **Compiler**: Clang 21.
- **LSP**: `clangd` (provided by `clang-tools`).
- **Debugger**: `lldb`.
- **Build System**: CMake + Ninja, configured to export `compile_commands.json` for LSP intelligence.
- **Libraries**: Boost 1.89 (integrated via Nix `buildInputs` and CMake `find_package`).
- **Linker**: `mold` (high-performance linker, configured in `CMakeLists.txt`).
- **Inspection Tools**: `llvm` (for `llvm-dis`, `llvm-nm`, `llvm-readelf`, `llvm-size`) and `elfutils` (for ELF inspection).
- **Command Runner**: `just` (see `justfile` for common tasks like `setup`, `run`, `fmt`, and the new inspection recipes).
- **Formatting**: Project-wide formatting via `nix fmt` (using `treefmt-nix` with `alejandra`, `clang-format`, and `cmake-format`).

## Compiler Internals & Inspection
This environment is specifically configured to allow deep inspection of the compilation pipeline:
- **Frontend (AST)**: Use `just ast` to view how Clang parses C++ source code.
- **Middle-end (IR)**: Use `just ir` (textual IR) or `just bitcode` (binary bitcode) to see the platform-independent representation.
- **Optimizer**: Use `just passes` to see the IR transformation after every single LLVM optimization pass (saved to `build/passes.log`).
- **Backend (Object/ELF)**: Use `just compile` to generate object files without linking, and `just inspect-elf`, `just inspect-symbols`, or `just size` to analyze the resulting binary.
- **Disassembly**: Use `just disasm` to see the final machine code interleaved with the original C++ source.

## Development Workflow
1. **Environment**: `direnv allow` or `nix develop`.
2. **Setup**: `just setup` (generates `build/compile_commands.json` for LSP).
3. **Build/Run**: `just run`.
4. **Inspect**: Use the `just` inspection recipes to debug or learn about the compiler's behavior.
5. **Packaging**: `nix build` (installs binary to `./result/bin/app`).

## Update Checklist
When updating the C++ standard, libraries, or environment, verify:
- **`CMakeLists.txt`**: Ensure `set(CMAKE_CXX_STANDARD ...)` matches the intended version.
- **Compilation Database**: Run `just setup` after changing build flags or adding files to refresh `build/compile_commands.json` for the LSP.
- **No Conflict Files**: Avoid creating or committing a `.clangd` file unless it's strictly necessary for non-standard paths. It can override `compile_commands.json` and cause "missing header" or "wrong standard" errors in the editor.
- **Standard Library**: Verify `USE_LIBCXX` in `CMakeLists.txt` if switching between LLVM's `libc++` and GNU's `libstdc++`.
- **Git Tracking**: Always `git add` new files before running `nix build`, as Flakes cannot see untracked files.

## Editor Integration (Doom Emacs)
Ensure the following modules are enabled in `~/.doom.d/init.el`:
- `:tools lsp`
- `:lang (cc +lsp)`
- `:lang (nix +lsp)`

## Key Nix Concepts in this Repo
- **`nativeBuildInputs`**: Build-time tools (CMake, Ninja).
- **`buildInputs`**: Runtime libraries (Boost).
- **`inputsFrom`**: Used in `devShell` to inherit all package dependencies automatically.
- **Git Tracking**: Reminder that Nix Flakes only see files tracked by Git (always `git add` new files before building).
