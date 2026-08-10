# rust_template

A minimal Rust project template: a `clap` CLI backed by a library crate, with unit tests, an
integration test, a `criterion` benchmark, and a Nix flake (crane + fenix) — so it builds the same
way with plain `cargo` or with `nix`.

## Using this template

1. Copy/clone this repo, or scaffold fresh with `nix flake init -t <this-repo-url>`.
2. If you used `nix flake init` (no `.git` yet), run `git init && git add -A` —
   Nix flakes only see git-tracked files, so every `nix` command below needs this first.
3. Rename the placeholder crate name:
   ```bash
   ./scripts/rename-project.sh my_project
   cd .. && mv rust_template my_project && cd my_project
   git add -A   # stage the rename before running any nix command again
   ```
4. Build whatever you actually came here for — replace `greet` in `src/lib.rs`, extend the CLI in
   `src/main.rs`, add your own tests and benchmarks.

## Building and running

**With Cargo** (needs Rust installed, or run inside `nix develop`):
```bash
cargo run -- Zeke        # build + run, prints "Hello, Zeke!"
cargo build --release
cargo test                 # unit + integration tests
cargo bench                 # criterion benchmark
```

**With Nix** (no local Rust install needed):
```bash
nix develop              # dev shell with the pinned toolchain + tools
nix build                 # produces ./result/bin/rust_template
nix run -- Zeke             # build + run
nix flake check              # clippy, fmt, doc, audit, tests — all in one go
nix fmt                       # format Rust, Nix, and TOML files
```

If you have [direnv](https://direnv.net/) installed, `direnv allow` activates the dev shell
automatically on `cd` (see `.envrc`).

`just` (available inside `nix develop`) wraps the common commands above — run `just` to list them.

See `CLAUDE.md` for more detail on the project layout and how the pieces fit together.
