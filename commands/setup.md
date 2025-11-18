---
version: 0.0.1
allowed-tools: Read, Write, Bash(cp:*), Bash(chmod:*), Bash(jq:*)
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

## Step 2: Find Plugin Directory

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

## Step 3: Copy Statusline Script

Copy the statusline script from the plugin directory to ~/.claude/:

```bash
cp ~/.claude/plugins/cache/peacock/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

## Step 4: Configure settings.json

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

## Step 5: Confirm Success

Output:
```
✅ Peacock statusline configured successfully!

What was done:
  • Copied statusline.sh to ~/.claude/statusline.sh
  • Updated ~/.claude/settings.json with statusLine configuration

Next step:
  Restart Claude Code to see your new statusline

Features:
  • Auto-detects code directory (~/code, ~/projects, ~/dev, etc.)
  • Auto-detects editor (cursor, vscode, sublime)
  • Shows Peacock theme colors from .vscode/settings.json
  • Displays git branch, lint status, and clickable file paths

Set project colors:
  /peacock:project-color dark forest green
  /peacock:project-color #8d0756

Need to uninstall later?
  Run /peacock:unsetup before uninstalling the plugin
```

## Error Handling

- If any step fails, show clear error message
- Don't modify settings.json if copy fails
- Don't leave settings.json in invalid state
- Validate JSON after modification
</instructions>
