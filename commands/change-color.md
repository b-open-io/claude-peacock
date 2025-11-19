---
version: 0.0.1
allowed-tools: Read, Write, Edit, Bash(jq:*)
description: Set project Peacock color (hex, natural language, or random)
argument-hint: [#hexcode | color name | (empty for random)]
tags: peacock, colors, vscode, workspace
---

# Change Color

Set your project's Peacock color theme. Supports hex codes, natural language color names, or random selection.

## Usage

**Random vibrant color:**
```
/peacock:change-color
```

**Hex color:**
```
/peacock:change-color #8d0756
/peacock:change-color #2e7d32
```

**Natural language:**
```
/peacock:change-color dark forest green
/peacock:change-color ocean blue
/peacock:change-color deep magenta
```

---

<instructions>
Set VSCode Peacock color for the current project. Matches VSCode Peacock extension's `enterColor` and `changeColorToRandom` commands.

## Step 1: Determine Working Directory

Get current working directory to find the project root:
```bash
pwd
```

Store this as PROJECT_DIR.

## Step 2: Parse Color Input

### If Arguments Start with #
Extract hex color directly (e.g., "#8d0756")

### If Arguments Contain Color Words
Map natural language to hex colors using this palette:

**Favorites (vibrant):**
- red → #FF6B6B
- orange → #FF8C42
- yellow → #FFD700
- green → #4CAF50
- teal → #20B2AA
- cyan → #00CED1
- blue → #4A90E2
- purple → #9370DB
- magenta → #FF1493

**Dark variants:**
- dark red → #8B0000
- dark orange → #CC5500
- dark green, forest green → #2D5016
- dark blue, navy → #003E80
- dark purple, indigo → #4B0082
- dark magenta → #8D0756

**Light variants:**
- light red, pink → #FFB6C1
- light orange, peach → #FFCC99
- light green, mint → #90EE90
- light blue, sky blue → #ADD8E6
- light purple, lavender → #DDA0DD

### If No Arguments (Random)
Randomly select from favorites palette above.

## Step 3: Calculate Complementary Colors

Convert hex to RGB, then calculate variants:

**Activity Bar (lighter):**
Add 40 to each RGB component, cap at 255

**Badge (complementary):**
Find color wheel opposite - rotate hue by 180°
Simple approximation: swap max/min RGB channels

**Text color:**
```bash
# Calculate luminance
L = (0.2126*R + 0.7152*G + 0.0722*B) / 255

# Choose text color
if L < 0.5 then "#e7e7e7" else "#15202b"
```

## Step 4: Create or Update .vscode/settings.json

Check if `.vscode/settings.json` exists:
```bash
ls .vscode/settings.json 2>/dev/null || echo "not found"
```

**If exists:**
- Read current settings
- Use jq to merge Peacock colors:
```bash
jq --arg color "$BASE_COLOR" \
   '.["peacock.color"] = $color |
    .workbench.colorCustomizations.titleBar.activeBackground = $color |
    ...' \
   .vscode/settings.json > .vscode/settings.json.tmp
mv .vscode/settings.json.tmp .vscode/settings.json
```

**If not exists:**
Create new file with Peacock configuration:
```json
{
  "peacock.color": "<base_color>",
  "workbench.colorCustomizations": {
    "activityBar.background": "<lighter>",
    "activityBar.foreground": "<text_color>",
    "activityBarBadge.background": "<complementary>",
    "activityBarBadge.foreground": "#e7e7e7",
    "statusBar.background": "<base_color>",
    "statusBar.foreground": "<text_color>",
    "titleBar.activeBackground": "<base_color>",
    "titleBar.activeForeground": "<text_color>"
  }
}
```

## Step 5: Confirm Success

Output:
```
✅ Peacock color changed to <hex>

Applied to:
  • Title Bar: <base_hex>
  • Status Bar: <base_hex>
  • Activity Bar: <lighter_hex>
  • Badges: <complementary_hex>

Reload VSCode to see changes:
  Cmd+Shift+P → "Developer: Reload Window"

The Claude Code statusline will update automatically on next refresh.
```

## Error Handling

- If not in a project directory: Show error
- If invalid hex: Show format error
- If .vscode/ directory doesn't exist: Create it first
- Preserve all existing settings when merging
</instructions>
