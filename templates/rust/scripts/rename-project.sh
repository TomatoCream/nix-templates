#!/usr/bin/env bash
# Renames the "rust_template" placeholder throughout the project to a
# real crate name. Run from anywhere; it locates the repo root itself.
set -euo pipefail

old_name="rust_template"

usage() {
  echo "Usage: $0 <new_name>" >&2
  echo "  <new_name> must be a valid snake_case Rust crate name (e.g. my_project)" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
new_name="$1"

if ! [[ "$new_name" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "error: '$new_name' is not a valid snake_case crate name" >&2
  exit 1
fi

if [[ "$new_name" == "$old_name" ]]; then
  echo "already named '$old_name', nothing to do"
  exit 0
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

files=(
  Cargo.toml
  flake.nix
  nix/rust.nix
  src/main.rs
  benches/greet.rs
  tests/greet.rs
)

for f in "${files[@]}"; do
  [[ -f "$f" ]] || continue
  sed -i.bak "s/${old_name}/${new_name}/g" "$f"
  rm -f "${f}.bak"
done

if command -v cargo >/dev/null 2>&1; then
  cargo generate-lockfile
else
  echo "warning: cargo not on PATH — run 'cargo generate-lockfile' yourself (e.g. inside 'nix develop')" >&2
fi

# Renaming can reorder `use` statements alphabetically (e.g. "acme_widget"
# now sorts before "criterion"), which rustfmt/treefmt will otherwise flag
# as unformatted on the next check. Reformat immediately so the tree is
# clean right after renaming.
if command -v cargo >/dev/null 2>&1 && cargo fmt --version >/dev/null 2>&1; then
  cargo fmt
elif command -v nix >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  nix fmt >/dev/null 2>&1 || echo "warning: 'nix fmt' failed — run it yourself once files are committed" >&2
else
  echo "warning: could not auto-format — run 'cargo fmt' or 'nix fmt' yourself" >&2
fi

echo "Renamed '${old_name}' -> '${new_name}'."
echo
echo "Review the diff (git diff), then optionally rename the project directory:"
echo "  cd .. && mv $(basename "$root") ${new_name}"
echo
echo "If this tree isn't committed to git yet, run 'git add -A' before any"
echo "'nix' command — Nix flakes only see git-tracked files."
