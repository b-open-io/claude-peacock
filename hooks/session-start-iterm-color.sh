#!/bin/bash
# Hook: Set iTerm2 tab color on session start based on Peacock theme
# Provides immediate visual feedback when starting a new Claude session

set -e

# Read hook input from stdin
INPUT=$(cat)

# Get cwd from session start
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)

if [[ -z "$CWD" ]]; then
  exit 0
fi

# Check if Peacock settings exist
PEACOCK_SETTINGS="$CWD/.vscode/settings.json"
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
