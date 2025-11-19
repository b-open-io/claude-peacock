---
version: 0.0.1
allowed-tools: Read, Write, Bash(rm:*), Bash(jq:*)
description: Remove ALL Peacock colors and settings
tags: peacock, colors, reset, cleanup
---

# Remove All Colors

Complete removal of all Peacock color customizations and settings. More thorough than reset. Matches VSCode Peacock extension's `removeAllPeacockColors` command.

## Usage

```
/peacock:remove-all-colors
```

---

<instructions>
Completely remove all Peacock-related files, settings, and configurations.

## Step 1: Remove Project Colors

Check for `.vscode/settings.json`:
```bash
ls .vscode/settings.json 2>/dev/null || echo "not found"
```

If exists, remove all Peacock properties:
```bash
jq 'del(.["peacock.color"]) |
    del(.workbench.colorCustomizations)' \
   .vscode/settings.json > .vscode/settings.json.tmp
mv .vscode/settings.json.tmp .vscode/settings.json

# Remove if empty
if jq -e '. == {}' .vscode/settings.json 2>/dev/null; then
  rm .vscode/settings.json
  rmdir .vscode 2>/dev/null || true
fi
```

## Step 2: Remove Favorites

Remove favorites file:
```bash
rm ~/.claude/.peacock-favorites.json 2>/dev/null || true
```

## Step 3: Remove Config

Remove config file if exists:
```bash
rm ~/.claude/.peacock-config 2>/dev/null || true
```

## Step 4: Confirm

Output:
```
✅ All Peacock colors and settings removed

Removed:
  • Project colors (.vscode/settings.json)
  • Favorites (~/.claude/.peacock-favorites.json)
  • Configuration (~/.claude/.peacock-config)

The statusline will show default colors.
iTerm2 tab color will reset to default.

To start fresh:
  /peacock:change-color #8d0756
  /peacock:add-recommended
```
</instructions>
