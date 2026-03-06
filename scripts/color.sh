#!/bin/bash
# Shared color utilities for peacock plugin

# Convert hex color to space-separated R G B
# Usage: hex_to_rgb "#8d0756" -> "141 7 86"
hex_to_rgb() {
  local hex="${1#\#}"
  if [[ ${#hex} -ne 6 || ! "$hex" =~ ^[0-9a-fA-F]{6}$ ]]; then
    echo "Error: invalid hex color '$1'" >&2
    return 1
  fi
  echo "$((16#${hex:0:2})) $((16#${hex:2:2})) $((16#${hex:4:2}))"
}

# Read peacock base color from project's .vscode/settings.json
# Usage: read_peacock_color "/path/to/project" -> "#8d0756" or ""
read_peacock_color() {
  if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed" >&2
    return 1
  fi

  local project_dir="$1"
  local settings="$project_dir/.vscode/settings.json"

  if [[ ! -f "$settings" ]]; then
    return
  fi

  local color
  color=$(jq -r '.["peacock.color"] // .["workbench.colorCustomizations"]["titleBar.activeBackground"] // empty' "$settings" 2>/dev/null)

  if [[ -n "$color" && "$color" != "null" ]]; then
    echo "$color"
  fi
}

# Find project root by walking up directory tree
# Usage: find_project_root "/path/to/nested/dir" -> "/path/to/project"
find_project_root() {
  local current="$1"

  while [[ "$current" != "/" && "$current" != "$HOME" ]]; do
    if [[ -d "$current/.git" ]] || \
       [[ -f "$current/package.json" ]] || \
       [[ -f "$current/go.mod" ]] || \
       [[ -f "$current/Cargo.toml" ]] || \
       [[ -f "$current/pyproject.toml" ]] || \
       [[ -f "$current/composer.json" ]] || \
       [[ -f "$current/build.gradle" ]] || \
       [[ -f "$current/pom.xml" ]]; then
      echo "$current"
      return 0
    fi
    current=$(dirname "$current")
  done

  echo "$1"
}
