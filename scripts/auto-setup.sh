#!/bin/bash
# Auto-setup script for Peacock plugin
# Runs on SessionStart - configures settings.json to use plugin's statusline

SETTINGS_FILE="$HOME/.claude/settings.json"

# Create settings.json if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
fi

# Only configure if not already set up
if command -v jq &> /dev/null; then
  # Check if statusLine already points to our plugin
  CURRENT_STATUSLINE=$(jq -r '.statusLine.command // empty' "$SETTINGS_FILE")

  # Only update if not already pointing to peacock plugin
  if [[ ! "$CURRENT_STATUSLINE" =~ peacock/statusline\.sh$ ]]; then
    # Configure to use plugin's statusline directly (no copying)
    TEMP_FILE=$(mktemp)
    jq --arg cmd "${CLAUDE_PLUGIN_ROOT}/statusline.sh" \
       '.statusLine = {"type": "command", "command": $cmd}' \
       "$SETTINGS_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$SETTINGS_FILE"
  fi
fi
