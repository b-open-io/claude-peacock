---
version: 0.0.1
allowed-tools: Read, Write, Edit, Bash(jq:*)
description: Lighten the current project color
tags: peacock, colors, adjust
---

# Lighten

Lighten the current project's Peacock color by 10%. Matches VSCode Peacock extension's `lighten` command.

## Usage

```
/peacock:lighten
```

---

<instructions>
Lighten the current project color and apply the result.

## Step 1: Read Current Color

Check for `.vscode/settings.json`:
```bash
ls .vscode/settings.json 2>/dev/null || echo "not found"
```

If not found:
```
❌ No Peacock color set

Set a color first:
  /peacock:change-color #8d0756
  /peacock:random-color
```
Stop execution.

Extract current color:
```bash
jq -r '.["peacock.color"] // empty' .vscode/settings.json
```

If empty, show same error above.

Store as CURRENT_COLOR.

## Step 2: Lighten Color

Convert hex to RGB.

Lighten by 10% (move 10% closer to white):
```
new_r = current_r + (255 - current_r) * 0.1
new_g = current_g + (255 - current_g) * 0.1
new_b = current_b + (255 - current_b) * 0.1
```

Round to integers, cap at 255.
Convert back to hex.

Store as LIGHTENED_COLOR.

## Step 3: Apply Lightened Color

Use same logic as `/peacock:change-color`:
1. Calculate variants (lighter, text, complementary)
2. Update `.vscode/settings.json`
3. Merge with existing settings

## Step 4: Confirm

Output:
```
✅ Color lightened by 10%

Before: <current_hex>
After:  <lightened_hex>

Applied to:
  • Title Bar: <lightened_hex>
  • Status Bar: <lightened_hex>
  • Activity Bar: <lighter_hex>

Reload VSCode window:
  Cmd+Shift+P → "Developer: Reload Window"

Too light? Use /peacock:darken
```
</instructions>
