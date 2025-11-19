---
version: 0.0.6
allowed-tools: Read, Write, AskUserQuestion, Bash(command:*), Bash(ls:*), Bash(cp:*), Bash(chmod:*), Bash(jq:*), Bash(mv:*), Bash(echo:*), Bash(cat:*)
description: Configure Peacock statusline and linting - run after plugin installation
tags: setup, installation, statusline, linting
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

**Question 1:**
- header: "Editor Setup"
- question: "How should clickable file paths open?"
- multiSelect: false
- options:
  - label: "Auto-detect", description: "Automatically detect cursor/vscode/sublime (recommended)"
  - label: "cursor", description: "Always use Cursor AI editor"
  - label: "vscode", description: "Always use Visual Studio Code"
  - label: "sublime", description: "Always use Sublime Text"
  - label: "file", description: "Use system default application"

Store the selected value as EDITOR_CHOICE.

## Step 2b: Ask User About Linting

Ask the user if they want automatic linting enabled:

**Question 2:**
- header: "Linting"
- question: "Enable automatic linting on file save?"
- multiSelect: false
- options:
  - label: "Yes", description: "Run linters automatically when files are saved (recommended)"
  - label: "No", description: "Disable automatic linting"

Store the selected value as LINT_ENABLED.

**If user selected "Yes", ask which languages:**

**Question 3:**
- header: "Languages"
- question: "Which languages should be linted?"
- multiSelect: true
- options:
  - label: "TypeScript/JavaScript", description: "Lint .ts/.js files using Biome or ESLint"
  - label: "Go", description: "Lint .go files using golangci-lint"

Store the selected values as LINT_LANGUAGES (will be an array).

## Step 3: Create Config File

Always create the config file to store linting preferences.

Build the config file content based on user selections:

```bash
cat > ~/.claude/.peacock-config << 'EOF'
# Peacock configuration
# This file is sourced by statusline.sh and lint hooks

# Editor configuration
EDITOR_SCHEME="$EDITOR_SCHEME"

# Linting configuration
LINT_ENABLED="$LINT_ENABLED"
LINT_TYPESCRIPT="$LINT_TYPESCRIPT"
LINT_GO="$LINT_GO"
EOF
```

**Variable values:**
- `EDITOR_SCHEME`:
  - If user selected "Auto-detect" → leave empty or set to "auto"
  - Otherwise → set to the selected editor ("cursor", "vscode", "sublime", "file")
- `LINT_ENABLED`:
  - If user selected "Yes" → "true"
  - If user selected "No" → "false"
- `LINT_TYPESCRIPT`:
  - If "TypeScript/JavaScript" was selected → "true"
  - Otherwise → "false"
- `LINT_GO`:
  - If "Go" was selected → "true"
  - Otherwise → "false"

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

**Note:** Lint hooks are automatically installed via the plugin system - no manual setup needed!

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

Build the success message based on user configuration:

```
✅ Peacock statusline configured successfully!

Configuration:
  • Editor: $EDITOR_DISPLAY
  • Statusline: ~/.claude/statusline.sh
  • Settings: ~/.claude/settings.json
  • Config: ~/.claude/.peacock-config
  • Linting: $LINT_STATUS

Next step:
  Restart Claude Code to see your new statusline and activate lint hooks

Features:
  ✓ Automatic project root detection (finds .git, package.json, etc.)
  ✓ Works with any code directory (~/code, ~/Source, ~/projects)
  ✓ Shows Peacock theme colors from .vscode/settings.json
  ✓ Displays git branch, lint status, and token usage
  ✓ Clickable file paths that open in your editor
  ✓ Separate visual segments for project and working folder
  $LINT_FEATURES

Set project colors:
  /peacock:change-color dark forest green
  /peacock:change-color #8d0756

Need to change settings?
  Run /peacock:setup again (safe to re-run)

Need to uninstall later?
  Run /peacock:unsetup before uninstalling the plugin
```

**Variable values:**
- `EDITOR_DISPLAY`:
  - If auto-detect: "Auto-detect (cursor → vscode → sublime → file)"
  - Otherwise: the selected editor name
- `LINT_STATUS`:
  - If enabled: "Enabled for $LANGUAGES" (e.g., "Enabled for TypeScript/JavaScript, Go")
  - If disabled: "Disabled"
- `LINT_FEATURES`:
  - If TypeScript enabled: "✓ Automatic linting on save (TypeScript/JavaScript via Biome/ESLint)"
  - If Go enabled: "✓ Automatic linting on save (Go via golangci-lint)"
  - If both: show both lines
  - If disabled: don't show any linting features

## Error Handling

- If any step fails, show clear error message
- Don't modify settings.json if copy fails
- Don't leave settings.json in invalid state
- Validate JSON after modification
</instructions>
