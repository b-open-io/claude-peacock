---
version: 0.0.6
allowed-tools: Read, Bash
description: Remove Peacock statusline and linting configuration - run before uninstalling plugin
tags: uninstall, cleanup, statusline, linting
---

# Peacock Unsetup

Remove the Peacock statusline configuration.

**Run this before uninstalling the plugin:**
```
/peacock:unsetup
```

---

<instructions>
Remove the Peacock statusline by deleting the script and cleaning up settings.json.

## Step 1: Check for jq

Verify jq is installed (required for JSON manipulation):

```bash
command -v jq
```

If jq is not found, output:
```
⚠️  jq is not installed - can't automatically clean settings.json

Manual cleanup required:
1. Delete ~/.claude/statusline.sh
2. Edit ~/.claude/settings.json and remove the "statusLine" entry

Or install jq and run /peacock:unsetup again:
  macOS:  brew install jq
  Ubuntu: sudo apt install jq
```

And stop execution.

## Step 2: Remove Config File (If Exists)

Remove the Peacock config file if it exists (stores editor preferences and linting configuration):

```bash
if [[ -f ~/.claude/.peacock-config ]]; then
  rm ~/.claude/.peacock-config
  echo "  • Removed ~/.claude/.peacock-config"
fi
```

## Step 3: Remove Lint State Files (If Exists)

Remove lint state directory if it exists:

```bash
if [[ -d ~/.claude/lint-state ]]; then
  rm -rf ~/.claude/lint-state
  echo "  • Removed ~/.claude/lint-state/"
fi
```

## Step 4: Remove Statusline Script

Check if ~/.claude/statusline.sh exists:
```bash
ls ~/.claude/statusline.sh
```

If it exists, verify it's the Peacock statusline by checking the first few lines for "Peacock" or "peacock":
```bash
head -5 ~/.claude/statusline.sh | grep -i peacock
```

If it matches (contains "peacock"), remove it:
```bash
rm ~/.claude/statusline.sh
```

If it doesn't match, output a warning:
```
⚠️  Warning: ~/.claude/statusline.sh doesn't appear to be the Peacock statusline

Not removing it automatically. If you want to remove it, delete it manually:
  rm ~/.claude/statusline.sh
```

## Step 5: Remove statusLine from settings.json

Check if settings.json exists:
```bash
ls ~/.claude/settings.json
```

If it exists, remove the statusLine entry:
```bash
jq 'del(.statusLine)' ~/.claude/settings.json > ~/.claude/settings.json.tmp
mv ~/.claude/settings.json.tmp ~/.claude/settings.json
```

Validate the result is valid JSON:
```bash
jq . ~/.claude/settings.json
```

If validation fails, output error and restore from backup.

## Step 6: Confirm Success

Output:
```
✅ Peacock statusline configuration removed successfully!

What was done:
  • Removed ~/.claude/.peacock-config (if it existed)
  • Removed ~/.claude/lint-state/ (if it existed)
  • Removed ~/.claude/statusline.sh
  • Removed statusLine entry from ~/.claude/settings.json

Note: Lint hooks and iTerm2 color hooks will be automatically removed when you uninstall the plugin.

Next steps:
  1. Restart Claude Code (statusline will no longer appear)
  2. Uninstall the plugin: /plugin
     (This will also remove lint hooks automatically)

To reinstall later:
  /plugin install peacock@b-open-io
  /peacock:setup

Features you'll get back:
  • Automatic project root detection (works with ~/code, ~/Source, ~/projects)
  • Peacock theme color integration
  • Git branch, lint status, and token usage display
  • Automatic linting (TypeScript/JavaScript, Go)
  • Clickable file paths
```

## Edge Cases

- If statusline.sh doesn't exist: Just clean settings.json and note it
- If settings.json doesn't exist: Note that there's nothing to clean
- If statusLine entry doesn't exist in settings: Note that it's already clean
- If both are already gone: Confirm that cleanup is complete (idempotent)
</instructions>
