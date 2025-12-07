# rrrr

A blazing fast CLI application built with Rust and Nix.

## Features

- Comprehensive Nix development environment with flake-parts
- Fenix for Rust toolchain management
- Crane for incremental Rust builds
- Full CI pipeline with clippy, tests, audit, and coverage
- Docker/OCI image builds
- Automatic code formatting with treefmt
- Pre-commit hooks

## Quick Start

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (optional, for automatic shell activation)

### Enter Development Shell

```bash
# With direnv (recommended)
direnv allow

# Without direnv
nix develop
```

### Build and Run

```bash
# Build the project
cargo build

# Run the CLI
cargo run -- --help
cargo run -- greet --name "World"
cargo run -- demo

# Or use just
just build
just run -- demo
```

## Available Commands

### Cargo Commands

| Command | Description |
|---------|-------------|
| `cargo build` | Build the project |
| `cargo test` | Run tests |
| `cargo nextest run` | Run tests with nextest |
| `cargo clippy` | Run linter |
| `cargo doc --open` | Generate and view documentation |
| `cargo audit` | Security audit |
| `cargo llvm-cov --html` | Generate coverage report |
| `cargo flamegraph` | Generate flame graph |
| `cargo criterion` | Run benchmarks |

### Development Tools

| Tool | Description |
|------|-------------|
| `bacon` | Background code checker |
| `evcxr` | Rust REPL |
| `tokio-console` | Async debugger (run with `--console` flag) |
| `treefmt` | Format all code |

### Just Commands

```bash
just              # Show available commands
just build        # Build the project
just test         # Run tests
just clippy       # Run clippy
just fmt          # Format code
just coverage     # Generate coverage report
just bench        # Run benchmarks
just ci           # Run all CI checks
just watch        # Start bacon
```

## Nix Commands

### Build

```bash
# Build default package (binary)
nix build

# Build specific packages
nix build .#rrrr      # Binary
nix build .#rrrr-lib  # Library
nix build .#doc       # Documentation
nix build .#docker    # Docker image
```

### Checks

```bash
# Run all checks
nix flake check

# Individual checks are run automatically:
# - clippy
# - cargo-audit
# - cargo-deny
# - nextest
# - coverage
# - formatting
```

### Docker

```bash
# Build Docker image
nix build .#docker

# Load into Docker
docker load < result

# Run
docker run --rm rrrr:latest --help
```

## Project Structure

```
rrrr/
├── flake.nix                 # Nix flake entry point
├── nix/
│   ├── rust.nix              # Rust toolchain (fenix + crane)
│   ├── packages.nix          # Package derivations
│   ├── checks.nix            # CI checks
│   ├── devshell.nix          # Development shell
│   ├── docker.nix            # Docker image
│   └── treefmt.nix           # Code formatting
├── crates/
│   ├── rrrr/                 # Binary crate
│   │   └── src/main.rs
│   └── rrrr-lib/             # Library crate
│       ├── src/lib.rs
│       └── benches/bench.rs
├── Cargo.toml                # Workspace manifest
├── rustfmt.toml              # Rust formatting
├── deny.toml                 # cargo-deny config
├── bacon.toml                # bacon config
├── treefmt.toml              # treefmt config
└── justfile                  # Task runner
```

## Development Workflow

1. Make changes to the code
1. Run `bacon` for continuous feedback
1. Format with `treefmt` (or it runs on commit)
1. Run `just ci` before pushing

## Tokio Console

For async debugging, run the application with the `--console` flag:

```bash
# Terminal 1: Start the app with console support
cargo run -- --console demo

# Terminal 2: Connect with tokio-console
tokio-console
```

## Coverage Reports

```bash
# Generate HTML report
cargo llvm-cov --html

# Open in browser
cargo llvm-cov --html --open

# View: target/llvm-cov/html/index.html
```

## Flame Graphs

```bash
# Generate flame graph (requires perf on Linux)
cargo flamegraph --bin rrrr -- demo

# View: flamegraph.svg
```

## Using as a Template

This project can be used as a template for new Rust projects.

### Option 1: Nix Flake Template (Quick)

```bash
# Clone and rename
git clone https://github.com/yourusername/rrrr my-project
cd my-project
./scripts/rename-project.sh my-project
```

### Option 2: Copier Template (Interactive)

```bash
# Install copier
nix-shell -p copier

# Create new project from template
copier copy gh:yourusername/rrrr my-project
```

### Option 3: GitHub Template

Click "Use this template" on GitHub to create a new repository, then run:

```bash
git clone https://github.com/you/my-project
cd my-project
./scripts/rename-project.sh my-project
```

### Manual Renaming

If you prefer manual control:

```bash
# Replace all occurrences
fd -t f -e nix -e toml -e rs -e md . -x sd 'rrrr' 'my-project' {}
fd -t f -e rs . -x sd 'rrrr_lib' 'my_project_lib' {}

# Rename directories
mv crates/rrrr crates/my-project
mv crates/rrrr-lib crates/my-project-lib

# Regenerate lock
rm Cargo.lock && cargo generate-lockfile
```

## License

MIT
