#!/bin/bash
# Auto-setup script for claude-peacock plugin
# Runs on SessionStart - idempotent (safe to run multiple times)

SETUP_MARKER="$HOME/.claude/.peacock-installed"

# Only run full setup if not already done
if [ ! -f "$SETUP_MARKER" ]; then
  # Copy statusline script
  cp "${CLAUDE_PLUGIN_ROOT}/statusline.sh" "$HOME/.claude/statusline.sh"
  chmod +x "$HOME/.claude/statusline.sh"

  # Configure settings.json
  SETTINGS_FILE="$HOME/.claude/settings.json"

  # Create settings.json if it doesn't exist
  if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
  fi

  # Add statusline configuration using jq
  if command -v jq &> /dev/null; then
    # Use jq to merge statusline config
    TEMP_FILE=$(mktemp)
    jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$SETTINGS_FILE" > "$TEMP_FILE"
    mv "$TEMP_FILE" "$SETTINGS_FILE"
  fi

  # Mark as installed
  touch "$SETUP_MARKER"
fi
