---
version: 0.0.3
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

## Step 2: Ask User for Code Directory

Ask the user where their code projects are located. Use AskUserQuestion with these options:

**Question:**
- header: "Code Directory"
- question: "Where are your code projects located?"
- multiSelect: false
- options:
  - label: "~/code", description: "Standard location (most common)"
  - label: "~/Source", description: "macOS/Apple convention"
  - label: "~/projects", description: "Alternative common location"
  - label: "~/dev", description: "Developer folder"
  - label: "~/workspace", description: "IDE workspace folder"
  - label: "Other", description: "Specify custom path"

If user selects "Other", they can type a custom path.

Store the selected CODE_DIR value for later.

## Step 3: Ask User for Editor

Ask which editor they use for clickable file links:

**Question:**
- header: "Editor"
- question: "Which editor should open when you click file paths?"
- multiSelect: false
- options:
  - label: "cursor", description: "Cursor AI editor (default)"
  - label: "vscode", description: "Visual Studio Code"
  - label: "sublime", description: "Sublime Text"
  - label: "file", description: "System default application"

Store the selected EDITOR_SCHEME value.

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

## Step 5: Create Config File

Create `~/.claude/.peacock-config` with the user's settings:

```bash
cat > ~/.claude/.peacock-config << EOF
# Peacock statusline configuration
# This file is sourced by statusline.sh

CODE_DIR="$CODE_DIR"
EDITOR_SCHEME="$EDITOR_SCHEME"
EOF
```

## Step 6: Copy Statusline Script

Copy the statusline script from the plugin directory to ~/.claude/:

```bash
cp ~/.claude/plugins/cache/peacock/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

## Step 7: Configure settings.json

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

## Step 8: Confirm Success

Output:
```
✅ Peacock statusline configured successfully!

Configuration:
  • Code directory: $CODE_DIR
  • Editor: $EDITOR_SCHEME
  • Config saved to: ~/.claude/.peacock-config
  • Statusline: ~/.claude/statusline.sh
  • Settings: ~/.claude/settings.json

Next step:
  Restart Claude Code to see your new statusline

Features:
  • Shows Peacock theme colors from .vscode/settings.json
  • Displays git branch, lint status, and clickable file paths
  • Tracks current and edited projects

Set project colors:
  /peacock:project-color dark forest green
  /peacock:project-color #8d0756

Need to change settings?
  Run /peacock:setup again (safe to re-run)

Need to uninstall later?
  Run /peacock:unsetup before uninstalling the plugin
```

## Error Handling

- If any step fails, show clear error message
- Don't modify settings.json if copy fails
- Don't leave settings.json in invalid state
- Validate JSON after modification
</instructions>
