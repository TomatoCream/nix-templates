#!/usr/bin/env bash
# Rename the project from 'rrrr' to a new name
# Usage: ./scripts/rename-project.sh <new-name>

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <new-name>"
  echo "Example: $0 my-awesome-cli"
  exit 1
fi

OLD_NAME="rrrr"
NEW_NAME="$1"

# Validate new name (must be valid Rust crate name)
if ! [[ $NEW_NAME =~ ^[a-z][a-z0-9_-]*$ ]]; then
  echo "Error: Invalid project name '$NEW_NAME'"
  echo "Name must start with lowercase letter and contain only [a-z0-9_-]"
  exit 1
fi

# Convert to various formats
OLD_NAME_SNAKE="${OLD_NAME//-/_}"    # rrrr -> rrrr (for Rust module names)
NEW_NAME_SNAKE="${NEW_NAME//-/_}"    # my-cli -> my_cli
OLD_NAME_LIB="${OLD_NAME_SNAKE}_lib" # rrrr_lib
NEW_NAME_LIB="${NEW_NAME_SNAKE}_lib" # my_cli_lib

echo "Renaming project: $OLD_NAME -> $NEW_NAME"
echo "  Snake case: $OLD_NAME_SNAKE -> $NEW_NAME_SNAKE"
echo "  Lib name: $OLD_NAME_LIB -> $NEW_NAME_LIB"
echo ""

# Check if fd and sd are available
if ! command -v fd &>/dev/null; then
  echo "Error: 'fd' is required. Install with: nix-shell -p fd"
  exit 1
fi

if ! command -v sd &>/dev/null; then
  echo "Error: 'sd' is required. Install with: nix-shell -p sd"
  exit 1
fi

# 1. Replace content in files (order matters - do specific patterns first)
echo "Replacing content in files..."

# Replace lib name first (more specific)
fd -t f -e nix -e toml -e rs -e md -e sh . \
  -x sd "$OLD_NAME_LIB" "$NEW_NAME_LIB" {}

fd -t f -e nix -e toml -e rs -e md -e sh . \
  -x sd "${OLD_NAME}-lib" "${NEW_NAME}-lib" {}

# Then replace the base name
fd -t f -e nix -e toml -e rs -e md -e sh . \
  -x sd "$OLD_NAME" "$NEW_NAME" {}

# Replace snake_case versions in Rust files
fd -t f -e rs . \
  -x sd "$OLD_NAME_SNAKE" "$NEW_NAME_SNAKE" {}

# 2. Rename directories
echo "Renaming directories..."
if [[ -d "crates/$OLD_NAME" ]]; then
  mv "crates/$OLD_NAME" "crates/$NEW_NAME"
fi

if [[ -d "crates/${OLD_NAME}-lib" ]]; then
  mv "crates/${OLD_NAME}-lib" "crates/${NEW_NAME}-lib"
fi

# 3. Regenerate Cargo.lock
echo "Regenerating Cargo.lock..."
rm -f Cargo.lock
cargo generate-lockfile 2>/dev/null || echo "Note: Run 'cargo generate-lockfile' in nix develop shell"

echo ""
echo "✅ Project renamed to: $NEW_NAME"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Update git remote if needed"
echo "  3. Commit: git add -A && git commit -m 'Rename project to $NEW_NAME'"
