---
version: 0.0.1
allowed-tools: Read, Write, Edit, Bash(jq:*)
description: Set project to a random vibrant Peacock color
tags: peacock, colors, vscode, random
---

# Random Color

Quickly set your project to a random vibrant Peacock color. Matches VSCode Peacock extension's `changeColorToRandom` command.

## Usage

```
/peacock:random-color
```

---

<instructions>
Set a random vibrant Peacock color for the current project.

## Step 1: Select Random Color

Choose randomly from this vibrant palette:
- #FF6B6B (red)
- #FF8C42 (orange)
- #FFD700 (yellow)
- #4CAF50 (green)
- #20B2AA (teal)
- #00CED1 (cyan)
- #4A90E2 (blue)
- #9370DB (purple)
- #FF1493 (magenta)

Store selected color as BASE_COLOR.

## Step 2: Calculate Variants

**Activity Bar (lighter):**
Convert hex to RGB, add 40 to each component, cap at 255

**Text color:**
Calculate luminance: L = (0.2126*R + 0.7152*G + 0.0722*B) / 255
Use #e7e7e7 if L < 0.5, else #15202b

**Badge (complementary):**
Simple complementary: swap dominant RGB channel

## Step 3: Apply to .vscode/settings.json

Check if file exists:
```bash
ls .vscode/settings.json 2>/dev/null || echo "not found"
```

Create or update with Peacock colors (same format as /peacock:change-color).

## Step 4: Confirm

Output:
```
✅ Random Peacock color applied: <hex> (<color_name>)

Applied to:
  • Title Bar: <base_hex>
  • Status Bar: <base_hex>
  • Activity Bar: <lighter_hex>

Reload VSCode window:
  Cmd+Shift+P → "Developer: Reload Window"
```
</instructions>
