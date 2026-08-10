# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A minimal Rust project template: a `clap`-based CLI (`src/main.rs`) backed by a library crate
(`src/lib.rs`), with unit tests, an integration test, and a `criterion` benchmark already wired
up. It also carries a full Nix flake (crane + fenix) so the same build/test/lint pipeline runs
identically with plain `cargo` or with `nix`. The intent is to eventually turn this into a `nix
flake init` template.

**Workflow for someone starting a new project from this template:** copy/clone the repo, run
`scripts/rename-project.sh <your_snake_case_name>` to replace the `rust_template` placeholder
everywhere, `mv` the directory itself (the script prints the exact command), confirm with
`nix flake check` (or `cargo test`), then build whatever you actually came here to build —
replace `greet` in `src/lib.rs`, extend the CLI in `src/main.rs`, add real tests/benches as you go.

## Two ways to work in this repo

**Cargo way** — fastest inner loop, needs Rust installed locally (or run inside `nix develop`):
```bash
cargo run -- Zeke        # build + run the CLI, arg is the name to greet (default: "world")
cargo build               # debug build
cargo build --release
cargo test                 # unit test (src/lib.rs) + integration test (tests/greet.rs)
cargo bench                 # criterion benchmark (benches/greet.rs)
cargo clippy --all-targets -- --deny warnings
cargo fmt
```
To run a single test: `cargo test greets_by_name` (matches both the unit and integration test by
name; scope to one with `cargo test --test greet` for just the integration test, or
`cargo test --lib` for just the unit test).

**Nix way** — reproducible, pins the exact toolchain via fenix, no local Rust install required:
```bash
nix develop              # drops into a shell with the same toolchain/tools as CI, then use cargo as above
nix build                 # produces ./result/bin/rust_template
nix run                    # build + run the CLI
nix flake check             # runs every check below in parallel, each cached separately by crane
nix fmt                      # formats Rust (rustfmt), Nix (nixfmt), and TOML (taplo) via treefmt
```
`nix flake check` runs: `clippy` (deny warnings, all targets), `fmt` (rustfmt), `doc` (cargo doc,
deny warnings), `audit` (cargo-audit against the RustSec advisory DB), `nextest` (unit +
integration tests), and `formatting` (treefmt check). These are the same derivations
`nix develop`'s dev shell inherits, so a passing `nix flake check` is a reliable signal before
pushing.

Both paths are meant to converge on the same result — the Nix devShell and the Nix package build
are built from one shared toolchain/build-args definition (see Architecture below), so what
compiles under `nix build` should also compile under plain `cargo build` inside `nix develop`.

`justfile` wraps the commands above (`just build`, `just test`, `just ci`, `just nix-check`, ...;
run `just` with no args to list them) — available inside `nix develop`. `.envrc` (`use flake`) lets
direnv users skip typing `nix develop` entirely.

## IDE / LSP support

`rust-analyzer` is included in the fenix toolchain (`nix/rust.nix`), and `nix develop`'s
`shellHook` exports `RUST_SRC_PATH` so `rust-analyzer` can resolve std-library sources. Point your
editor's rust-analyzer at the toolchain from inside `nix develop` (e.g. via `direnv` + `use flake`,
or by launching your editor from within `nix develop`) rather than relying on a system-wide Rust
install, so the LSP sees the same compiler version as the build.

## Architecture

- **`nix/rust.nix`** is the single source of truth for the Rust build environment: the fenix
  toolchain, `craneLib`, `commonArgs` (source filtering, `strictDeps`, native/build inputs), and
  the cached `cargoArtifacts` (deps built once via `craneLib.buildDepsOnly`, then reused by the
  package build, clippy, doc, and nextest checks — this is what makes `nix build` incremental
  instead of recompiling all dependencies on every source change). `packages.default` and
  `devShells.default` both derive from this file's output, which is why they stay close to
  identical.
- **`nix/devshell.nix`** builds the dev shell from that same `craneLib`/toolchain via
  `craneLib.devShell`, adding dev-only tools (`cargo-nextest`, `cargo-criterion`, `cargo-audit`,
  `cargo-expand`, `taplo`, `bacon`, `mold` on Linux) that aren't part of the package build itself.
- **`nix/treefmt.nix`** is a flake-parts module enabling rustfmt/nixfmt/deadnix/statix/taplo under
  treefmt-nix, wired into both `nix fmt` and the `formatting` check in `flake.nix`.
- **`flake.nix`** ties it together with `flake-parts`: it imports the treefmt module, evaluates
  `nix/rust.nix` per-system, and exposes `packages.default`, `checks`, `apps.default`, and
  `devShells.default` from its outputs. It also declares `flake.templates.default`, so once this
  repo is published, `nix flake init -t <url>` scaffolds a new project straight from it.
- **`src/lib.rs`** holds the actual logic (currently just `greet`); `src/main.rs` is a thin `clap`
  wrapper around it. Keep new functionality in the lib crate, not `main.rs`, so it stays reachable
  from `tests/` and `benches/` (both depend on the `rust_template` lib crate by name, not on the
  binary).
- **`tests/greet.rs`** is the example integration test (tests the public lib API from outside the
  crate); `src/lib.rs`'s `#[cfg(test)] mod tests` is the example unit test (tests internals
  in-crate). Follow whichever pattern fits: internal/private logic → unit test in the same file;
  public API surface → integration test in `tests/`.
- **`benches/greet.rs`** is a `criterion` benchmark against the lib crate; `Cargo.toml` disables
  the default libtest harness for it (`harness = false`) since criterion supplies its own.

## Renaming the template

`scripts/rename-project.sh <new_snake_case_name>` replaces every `rust_template` occurrence
(crate name in `Cargo.toml`, the `pname`/binary name in `nix/rust.nix` and `flake.nix`, and the
`use rust_template::...` imports in `src/main.rs`, `tests/greet.rs`, `benches/greet.rs`), then
regenerates `Cargo.lock` and reformats (`cargo fmt`/`nix fmt`) — the rename can flip `use`
statements out of alphabetical order (e.g. renaming to something that sorts before `criterion`),
which would otherwise fail the `treefmt` check on the next `nix flake check`. It does not rename
the project directory itself — that's a manual `mv` afterward (the script prints the exact
command). If the tree isn't git-tracked yet (e.g. straight after `nix flake init -t`), run
`git add -A` before *any* `nix` command, including the rename script's own `nix fmt` fallback —
flakes only see git-tracked files.

## Keeping this file current

This file describes the template in its current, minimal state. As real functionality gets added
(more crates, workspace layout, new checks, CI, actual product logic replacing `greet`), update
this file to match — stale architecture notes are worse than none. Don't let it drift from what
`scripts/rename-project.sh` actually touches, either, if the file list it edits changes.
