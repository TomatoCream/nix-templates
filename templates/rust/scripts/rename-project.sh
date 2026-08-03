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

# Helper function to convert to PascalCase
to_pascal_case() {
  echo "$1" | sed -E 's/(^|[-_])([a-z])/\U\2/g'
}

# Convert to various formats
OLD_NAME_SNAKE="${OLD_NAME//-/_}"            # rrrr -> rrrr
NEW_NAME_SNAKE="${NEW_NAME//-/_}"            # my-cli -> my_cli
OLD_NAME_LIB="${OLD_NAME_SNAKE}_lib"         # rrrr_lib
NEW_NAME_LIB="${NEW_NAME_SNAKE}_lib"         # my_cli_lib
OLD_NAME_PASCAL=$(to_pascal_case "$OLD_NAME") # rrrr -> Rrrr
NEW_NAME_PASCAL=$(to_pascal_case "$NEW_NAME") # my-cli -> MyCli

echo "Renaming project: $OLD_NAME -> $NEW_NAME"
echo "  Snake case:  $OLD_NAME_SNAKE -> $NEW_NAME_SNAKE"
echo "  PascalCase:  $OLD_NAME_PASCAL -> $NEW_NAME_PASCAL"
echo "  Lib name:    $OLD_NAME_LIB -> $NEW_NAME_LIB"
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

# File extensions to process
EXTENSIONS=("nix" "toml" "rs" "md" "sh" "yaml" "yml" "json")
EXT_ARGS=""
for ext in "${EXTENSIONS[@]}"; do
  EXT_ARGS="$EXT_ARGS -e $ext"
done

# Replace PascalCase versions first (most specific, e.g., RrrrError)
echo "  - PascalCase: ${OLD_NAME_PASCAL}* -> ${NEW_NAME_PASCAL}*"
fd -t f $EXT_ARGS . -x sd "$OLD_NAME_PASCAL" "$NEW_NAME_PASCAL" {} 2>/dev/null || true

# Replace lib name (snake_case with _lib suffix)
echo "  - Lib snake:  $OLD_NAME_LIB -> $NEW_NAME_LIB"
fd -t f $EXT_ARGS . -x sd "$OLD_NAME_LIB" "$NEW_NAME_LIB" {} 2>/dev/null || true

# Replace lib name (kebab-case with -lib suffix)
echo "  - Lib kebab:  ${OLD_NAME}-lib -> ${NEW_NAME}-lib"
fd -t f $EXT_ARGS . -x sd "${OLD_NAME}-lib" "${NEW_NAME}-lib" {} 2>/dev/null || true

# Replace snake_case versions
echo "  - Snake case: $OLD_NAME_SNAKE -> $NEW_NAME_SNAKE"
fd -t f $EXT_ARGS . -x sd "$OLD_NAME_SNAKE" "$NEW_NAME_SNAKE" {} 2>/dev/null || true

# Replace kebab-case (base name) last
echo "  - Kebab case: $OLD_NAME -> $NEW_NAME"
fd -t f $EXT_ARGS . -x sd "$OLD_NAME" "$NEW_NAME" {} 2>/dev/null || true

# 2. Rename directories
echo ""
echo "Renaming directories..."
if [[ -d "crates/$OLD_NAME" ]]; then
  echo "  - crates/$OLD_NAME -> crates/$NEW_NAME"
  mv "crates/$OLD_NAME" "crates/$NEW_NAME"
fi

if [[ -d "crates/${OLD_NAME}-lib" ]]; then
  echo "  - crates/${OLD_NAME}-lib -> crates/${NEW_NAME}-lib"
  mv "crates/${OLD_NAME}-lib" "crates/${NEW_NAME}-lib"
fi

# 3. Update this script itself with new OLD_NAME
echo ""
echo "Updating rename script for future use..."
sd "^OLD_NAME=\".*\"$" "OLD_NAME=\"$NEW_NAME\"" scripts/rename-project.sh 2>/dev/null || true

# 4. Regenerate Cargo.lock
echo ""
echo "Regenerating Cargo.lock..."
rm -f Cargo.lock
cargo generate-lockfile 2>/dev/null || echo "Note: Run 'cargo generate-lockfile' in nix develop shell"

echo ""
echo "✅ Project renamed to: $NEW_NAME"
echo ""
echo "Patterns replaced:"
echo "  - $OLD_NAME -> $NEW_NAME (kebab-case)"
echo "  - $OLD_NAME_SNAKE -> $NEW_NAME_SNAKE (snake_case)"
echo "  - $OLD_NAME_PASCAL -> $NEW_NAME_PASCAL (PascalCase)"
echo "  - ${OLD_NAME}-lib -> ${NEW_NAME}-lib"
echo "  - $OLD_NAME_LIB -> $NEW_NAME_LIB"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git diff"
echo "  2. Rename project directory: cd .. && mv ${OLD_NAME} ${NEW_NAME}"
echo "  3. Update git remote if needed"
echo "  4. Commit: git add -A && git commit -m 'Rename project to $NEW_NAME'"
