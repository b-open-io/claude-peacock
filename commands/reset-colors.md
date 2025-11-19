---
version: 0.0.1
allowed-tools: Read, Write, Edit, Bash(jq:*)
description: Remove Peacock colors from current project
tags: peacock, colors, reset
---

# Reset Colors

Remove Peacock color customizations from the current project. Matches VSCode Peacock extension's `resetWorkspaceColors` command.

## Usage

```
/peacock:reset-colors
```

---

<instructions>
Remove Peacock color customizations from the current project's `.vscode/settings.json`.

## Step 1: Check for Settings File

```bash
ls .vscode/settings.json 2>/dev/null || echo "not found"
```

If not found:
```
ℹ️  No Peacock colors to reset

This project doesn't have a .vscode/settings.json file.
```
Stop execution.

## Step 2: Read Current Settings

```bash
jq -c . .vscode/settings.json
```

Check if Peacock colors exist:
```bash
jq -e '.["peacock.color"]' .vscode/settings.json 2>/dev/null || echo "not found"
```

If not found:
```
ℹ️  No Peacock colors configured for this project

The project doesn't have Peacock customizations.
```
Stop execution.

## Step 3: Remove Peacock Properties

Remove Peacock-specific properties:
```bash
jq 'del(.["peacock.color"]) |
    del(.workbench.colorCustomizations.titleBar) |
    del(.workbench.colorCustomizations.statusBar) |
    del(.workbench.colorCustomizations.activityBar) |
    del(.workbench.colorCustomizations.activityBarBadge) |
    # Clean up empty objects
    if (.workbench.colorCustomizations | length) == 0 then
      del(.workbench.colorCustomizations)
    else
      .
    end' \
   .vscode/settings.json > .vscode/settings.json.tmp
mv .vscode/settings.json.tmp .vscode/settings.json
```

## Step 4: Clean Up Empty Files

If settings.json is now empty or only has empty objects:
```bash
if jq -e '. == {}' .vscode/settings.json 2>/dev/null; then
  rm .vscode/settings.json
  rmdir .vscode 2>/dev/null || true
fi
```

## Step 5: Confirm

Output:
```
✅ Peacock colors removed

Removed from .vscode/settings.json:
  • peacock.color
  • workbench.colorCustomizations (Peacock entries)

Reload VSCode window to see changes:
  Cmd+Shift+P → "Developer: Reload Window"

The Claude Code statusline will show default colors.
```
</instructions>
