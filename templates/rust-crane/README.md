# Rust + Crane + rust-overlay Template

A Nix flake template for Rust projects with optimal development and build setup.

## Features

- **rust-overlay**: Latest stable Rust toolchain with rust-analyzer
- **crane**: Fast incremental builds with dependency caching
- **Development tools**: cargo-watch, cargo-expand, cargo-edit, cargo-udeps
- **direnv support**: Automatic environment loading
- **Multi-platform**: Works on Linux (x86_64/aarch64) and macOS (Intel/Apple Silicon)

## Quick Start

1. Initialize a new project:
   ```bash
   git init my-project
   cd my-project
   nix flake init -t github:USERNAME/rust-aeron#rust-crane
   ```

2. Stage files and generate Cargo.lock:
   ```bash
   git add .
   cargo build
   git add Cargo.lock
   ```

3. Enable direnv (optional):
   ```bash
   direnv allow
   ```
   Or manually enter dev shell:
   ```bash
   nix develop
   ```

4. Start developing:
   ```bash
   cargo watch -x run    # Auto-rebuild on changes
   cargo expand          # View macro expansions
   ```

5. Build with Nix:
   ```bash
   nix build
   ./result/bin/my-project
   ```

## Customization

- Change project name in `Cargo.toml` and `flake.nix` (search for "my-project")
- Add dependencies with `cargo add <crate>`
- Add system dependencies in `flake.nix` buildInputs if needed
- Switch to nightly: `pkgs.rust-bin.nightly.latest.default`

## How Dependency Caching Works

Crane builds dependencies separately from your code:
- First build: Compiles all dependencies (~slower)
- Code changes: Only rebuilds your code (~fast)
- Dependency changes: Rebuilds dependencies, then code

This dramatically speeds up iteration during development.
