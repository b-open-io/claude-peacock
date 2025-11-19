---
version: 0.0.4
allowed-tools: Read, Write, AskUserQuestion, Bash(command:*), Bash(ls:*), Bash(cp:*), Bash(chmod:*), Bash(jq:*), Bash(mv:*), Bash(echo:*), Bash(cat:*)
description: Configure Peacock statusline - run after plugin installation
tags: setup, installation, statusline
---

# Peacock Setup

Configure the Peacock statusline for Claude Code.

**Run this after installing the plugin:**
```
/peacock:setup
```

---

<instructions>
Configure the Peacock statusline by copying the script and updating settings.json.

## Step 1: Check for jq

First, verify jq is installed (required for JSON manipulation):

```bash
command -v jq
```

If jq is not found, output:
```
❌ Error: jq is required but not installed

Please install jq first:
  macOS:  brew install jq
  Ubuntu: sudo apt install jq

After installing jq, run /peacock:setup again.
```

And stop execution.

## Step 2: Ask User for Editor (Optional)

The statusline will auto-detect your editor, but you can override it.

Ask the user if they want to configure the editor manually:

**Question:**
- header: "Editor Setup"
- question: "How should clickable file paths open?"
- multiSelect: false
- options:
  - label: "Auto-detect", description: "Automatically detect cursor/vscode/sublime (recommended)"
  - label: "cursor", description: "Always use Cursor AI editor"
  - label: "vscode", description: "Always use Visual Studio Code"
  - label: "sublime", description: "Always use Sublime Text"
  - label: "file", description: "Use system default application"

Store the selected value.

## Step 3: Create Config File (If Needed)

Only create config if user chose a specific editor (not "Auto-detect").

If user selected a specific editor:
```bash
cat > ~/.claude/.peacock-config << EOF
# Peacock statusline configuration
# This file is sourced by statusline.sh

EDITOR_SCHEME="$EDITOR_SCHEME"
EOF
```

If user selected "Auto-detect", skip config file creation entirely.

## Step 4: Find Plugin Directory

The plugin should be installed at `~/.claude/plugins/cache/peacock/statusline.sh`.

Check if this file exists:
```bash
ls ~/.claude/plugins/cache/peacock/statusline.sh
```

If it doesn't exist, output:
```
❌ Error: Peacock plugin not found

The statusline.sh file should be at:
  ~/.claude/plugins/cache/peacock/statusline.sh

Make sure you've installed the plugin first:
  /plugin install peacock@b-open-io
```

And stop execution.

## Step 5: Copy Statusline Script

Copy the statusline script from the plugin directory to ~/.claude/:

```bash
cp ~/.claude/plugins/cache/peacock/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

## Step 6: Configure settings.json

Create or update `~/.claude/settings.json` with the statusLine configuration.

**If settings.json doesn't exist:**
```bash
echo '{"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' | jq . > ~/.claude/settings.json
```

**If settings.json exists:**

First read it to check if statusLine is already configured:
```bash
jq -e '.statusLine' ~/.claude/settings.json
```

If statusLine already exists, check if it points to our script:
- If it points to `~/.claude/statusline.sh`, output a note that it's already configured
- If it points somewhere else, warn the user and ask if they want to overwrite

If statusLine doesn't exist, add it:
```bash
jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' ~/.claude/settings.json > ~/.claude/settings.json.tmp
mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```

## Step 7: Confirm Success

If user chose auto-detect:
```
✅ Peacock statusline configured successfully!

Configuration:
  • Editor: Auto-detect (cursor → vscode → sublime → file)
  • Statusline: ~/.claude/statusline.sh
  • Settings: ~/.claude/settings.json

Next step:
  Restart Claude Code to see your new statusline

Features:
  ✓ Automatic project root detection (finds .git, package.json, etc.)
  ✓ Works with any code directory (~/code, ~/Source, ~/projects)
  ✓ Shows Peacock theme colors from .vscode/settings.json
  ✓ Displays git branch, lint status, and token usage
  ✓ Clickable file paths that open in your editor
  ✓ Separate visual segments for project and working folder

Set project colors:
  /peacock:project-color dark forest green
  /peacock:project-color #8d0756

Need to change settings?
  Run /peacock:setup again (safe to re-run)

Need to uninstall later?
  Run /peacock:unsetup before uninstalling the plugin
```

If user chose a specific editor, also include:
```
  • Editor: $EDITOR_SCHEME
  • Config: ~/.claude/.peacock-config
```

## Error Handling

- If any step fails, show clear error message
- Don't modify settings.json if copy fails
- Don't leave settings.json in invalid state
- Validate JSON after modification
</instructions>
