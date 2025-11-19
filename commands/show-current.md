---
version: 0.0.1
allowed-tools: Read, Bash(jq:*), Bash(echo:*), Bash(pbcopy:*)
description: Show and copy current project color
tags: peacock, colors, info
---

# Show Current Color

Display the current project's Peacock color and copy it to clipboard. Matches VSCode Peacock extension's `showAndCopyCurrentColor` command.

## Usage

```
/peacock:show-current
```

---

<instructions>
Display current Peacock color and copy to clipboard.

## Step 1: Read Current Color

Check for `.vscode/settings.json`:
```bash
ls .vscode/settings.json 2>/dev/null || echo "not found"
```

If not found:
```
ℹ️  No Peacock color set

This project doesn't have a Peacock color configured.

Set one:
  /peacock:change-color #8d0756
  /peacock:random-color
```
Stop execution.

Extract color:
```bash
jq -r '.["peacock.color"] // empty' .vscode/settings.json
```

If empty, show same message above.

Store as CURRENT_COLOR.

## Step 2: Extract Additional Info

Get complementary colors if they exist:
```bash
jq -r '.workbench.colorCustomizations.titleBar.activeBackground // empty' .vscode/settings.json
jq -r '.workbench.colorCustomizations.activityBar.background // empty' .vscode/settings.json
jq -r '.workbench.colorCustomizations.statusBar.background // empty' .vscode/settings.json
```

## Step 3: Copy to Clipboard

Copy the base color to clipboard:
```bash
echo -n "$CURRENT_COLOR" | pbcopy
```

(On non-macOS, this command may fail gracefully)

## Step 4: Display Info

Output:
```
🎨 Current Peacock Color

Base Color: <hex>
RGB: (<r>, <g>, <b>)

Applied to:
  • Title Bar: <hex>
  • Status Bar: <hex>
  • Activity Bar: <lighter_hex>

✅ Color copied to clipboard!

Modify:
  /peacock:darken      - Make darker
  /peacock:lighten     - Make lighter
  /peacock:save-favorite - Save to favorites

Reset:
  /peacock:reset-colors
```

If copy failed (non-macOS):
```
🎨 Current Peacock Color

Base Color: <hex>
RGB: (<r>, <g>, <b>)

Applied to:
  • Title Bar: <hex>
  • Status Bar: <hex>
  • Activity Bar: <lighter_hex>

Copy this color: <hex>
```
</instructions>
