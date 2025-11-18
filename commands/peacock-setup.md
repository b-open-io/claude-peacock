---
version: 1.0.0
allowed-tools: Bash(cp:*), Bash(chmod:*), Read
description: Install the Peacock statusline to ~/.claude/statusline.sh
tags: setup, installation, peacock, statusline
---

# Peacock Setup

Install the Peacock-themed statusline to your Claude Code configuration.

## What it does

This command installs the Peacock statusline script that:
- Automatically detects VSCode Peacock colors from `.vscode/settings.json`
- Uses 24-bit true color for exact color matching
- Shows current working directory and last edited project with distinct colors
- Displays git branch, lint status, and token usage
- Adapts text colors from your Peacock theme for perfect contrast

## Usage

```
/peacock-setup
```

After installation, restart Claude Code or start a new session to see the statusline.

---

<instructions>
You are installing the Peacock statusline for Claude Code.

**Step 1: Locate the plugin statusline script**

The statusline.sh file should be in the plugin directory. First, determine the plugin installation location:

```bash
# Plugin is typically installed in ~/.claude/plugins/claude-peacock/
PLUGIN_DIR="$HOME/.claude/plugins/claude-peacock"
```

**Step 2: Verify the statusline file exists**

Check if the statusline.sh file exists in the plugin directory:

```bash
if [[ ! -f "$PLUGIN_DIR/statusline.sh" ]]; then
  echo "❌ Error: statusline.sh not found in plugin directory"
  echo "Expected location: $PLUGIN_DIR/statusline.sh"
  exit 1
fi
```

**Step 3: Copy to Claude Code config**

```bash
cp "$PLUGIN_DIR/statusline.sh" "$HOME/.claude/statusline.sh"
chmod +x "$HOME/.claude/statusline.sh"
```

**Step 4: Confirm installation**

Display success message:

```
✅ Peacock statusline installed to ~/.claude/statusline.sh

Features:
• Automatic Peacock theme detection from .vscode/settings.json
• 24-bit true color support for exact color matching
• Project-aware with CWD (⌂) and edited project (✎) display
• Git branch tracking with dirty state indicator
• Lint status with theme-matched badge colors
• Token usage and clickable file paths

Next steps:
1. Restart Claude Code or start a new session
2. Use /project-color to set colors for projects without Peacock themes
3. Your statusline will automatically match your VSCode window colors!

Configuration:
• CODE_DIR: Set via environment variable (default: ~/code)
• EDITOR_SCHEME: Set via environment variable (default: cursor)
```

**Important Notes:**
- The statusline runs on every prompt, reading project colors from `.vscode/settings.json`
- Supports both `peacock.color` and `workbench.colorCustomizations`
- Falls back to default cyan/purple themes if no project colors found
- Requires jq for JSON parsing (install with: brew install jq)
</instructions>
