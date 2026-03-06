#!/bin/bash
# Hook: Set terminal tab color on session start based on project's Peacock theme
set -e

# Only iTerm2 for now (future: tmux, kitty)
if [[ "$TERM_PROGRAM" != "iTerm.app" ]]; then
  exit 0
fi

# Read hook input from stdin
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
if [[ -z "$CWD" ]]; then
  exit 0
fi

# Source shared utilities
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$PLUGIN_DIR/scripts/color.sh"
source "$PLUGIN_DIR/scripts/iterm2.sh"

# Find project and read its color
PROJECT_ROOT=$(find_project_root "$CWD")
COLOR=$(read_peacock_color "$PROJECT_ROOT")
if [[ -z "$COLOR" ]]; then
  exit 0
fi

# Apply tab color
read -r R G B <<< "$(hex_to_rgb "$COLOR")"
set_iterm2_tab_color "$R" "$G" "$B"

exit 0
