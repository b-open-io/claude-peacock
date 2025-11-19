#!/bin/bash
# Hook: Set iTerm2 tab color on session start based on Peacock theme
# Provides immediate visual feedback when starting a new Claude session

set -e

# Only run in iTerm2
if [[ "$TERM_PROGRAM" != "iTerm.app" ]]; then
  exit 0
fi

# Read hook input from stdin
INPUT=$(cat)

# Get cwd from session start
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)

if [[ -z "$CWD" ]]; then
  exit 0
fi

# Find project root by walking up directory tree
# Looks for: .git, package.json, go.mod, Cargo.toml, pyproject.toml, composer.json
find_project_root() {
  local path="$1"
  local current="$path"

  while [[ "$current" != "/" && "$current" != "$HOME" ]]; do
    if [[ -d "$current/.git" ]] || \
       [[ -f "$current/package.json" ]] || \
       [[ -f "$current/go.mod" ]] || \
       [[ -f "$current/Cargo.toml" ]] || \
       [[ -f "$current/pyproject.toml" ]] || \
       [[ -f "$current/composer.json" ]]; then
      echo "$current"
      return 0
    fi
    current=$(dirname "$current")
  done

  # Fallback to original path
  echo "$path"
}

# Find project root from CWD
PROJECT_ROOT=$(find_project_root "$CWD")

# Check if Peacock settings exist in project root
PEACOCK_SETTINGS="$PROJECT_ROOT/.vscode/settings.json"
if [[ ! -f "$PEACOCK_SETTINGS" ]]; then
  exit 0
fi

# Extract Peacock color (try peacock.color first, fallback to titleBar.activeBackground)
PEACOCK_COLOR=$(jq -r '.["peacock.color"] // .["workbench.colorCustomizations"]["titleBar.activeBackground"] // empty' "$PEACOCK_SETTINGS" 2>/dev/null)

if [[ -z "$PEACOCK_COLOR" || "$PEACOCK_COLOR" == "null" ]]; then
  exit 0
fi

# Remove # prefix if present
PEACOCK_COLOR="${PEACOCK_COLOR#\#}"

# Convert hex to RGB
R=$((16#${PEACOCK_COLOR:0:2}))
G=$((16#${PEACOCK_COLOR:2:2}))
B=$((16#${PEACOCK_COLOR:4:2}))

# Set iTerm2 tab color using OSC 6 sequences
echo -ne "\033]6;1;bg;red;brightness;${R}\007" >&2
echo -ne "\033]6;1;bg;green;brightness;${G}\007" >&2
echo -ne "\033]6;1;bg;blue;brightness;${B}\007" >&2

exit 0
