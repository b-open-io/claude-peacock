---
version: 0.0.1
allowed-tools: Read, Write, Edit
description: Set VSCode project colors with hex codes or natural language (e.g. "dark forest green")
argument-hint: [color description] | --help
tags: design, vscode, peacock, colors, workspace
---

# Project Color

Set VSCode workspace colors using hex codes or natural language color descriptions.

## Usage

**Random vibrant color:**
```
/project-color
```

**Hex color:**
```
/project-color #8d0756
/project-color #2e7d32
```

**Natural language:**
```
/project-color dark forest green
/project-color vibrant ocean blue
/project-color muted coral
/project-color deep magenta
```

---

<instructions>
Set VSCode workspace colors for the current project directory.

## Step 1: Parse Color Input

Check if user provided `--help` in arguments. If so, show usage above and stop.

Parse the color from arguments:

### If Arguments Start with #
Extract hex color directly (e.g., "#8d0756")

### If Arguments Contain Color Words
Map natural language to hex colors:

**Red family:**
- dark red, deep red → #8B0000
- red, bright red → #FF6B6B
- light red, pink → #FFB6C1

**Orange family:**
- dark orange, burnt orange → #CC5500
- orange, bright orange → #FF8C42
- light orange, peach → #FFCC99

**Yellow family:**
- dark yellow, gold → #B8860B
- yellow, bright yellow → #FFD700
- light yellow, cream → #FFEB99

**Green family:**
- dark green, forest green → #2D5016
- green, bright green → #4CAF50
- light green, mint → #90EE90

**Teal family:**
- dark teal → #123323
- teal, bright teal → #20B2AA
- light teal, aqua → #AFEEEE

**Cyan family:**
- dark cyan → #006B7D
- cyan, bright cyan → #00CED1
- light cyan, ice → #E0FFFF

**Blue family:**
- dark blue, navy → #003E80
- blue, ocean blue → #4A90E2
- light blue, sky blue → #ADD8E6

**Purple family:**
- dark purple, indigo → #4B0082
- purple, bright purple → #9370DB
- light purple, lavender → #DDA0DD

**Magenta family:**
- dark magenta, maroon → #8D0756
- magenta, hot pink → #FF1493
- light magenta, pink → #FFB6E5

**Brown family:**
- dark brown, chocolate → #654321
- brown, sienna → #A0522D
- light brown, tan, beige → #D2B48C

**Gray family:**
- dark gray, charcoal → #2C2C2C
- gray, grey, slate → #808080
- light gray, silver → #D3D3D3

**Modifiers:**
- "vibrant", "bright" → use bright variant
- "light", "pale" → use light variant
- "dark", "deep" → use dark variant
- "muted" → reduce saturation

### If No Arguments
Randomly select from these vibrant colors:
- #FF6B6B (red)
- #FF8C42 (orange)
- #FFD700 (yellow)
- #4CAF50 (green)
- #20B2AA (teal)
- #00CED1 (cyan)
- #4A90E2 (blue)
- #9370DB (purple)
- #FF1493 (magenta)

## Step 2: Calculate Color Variants

From the base hex color, calculate:

**Lighter variant (for activity bar):**
Add 77 to each RGB component, cap at 255

**Complementary color (for badges):**
For a rough complementary:
- If R is dominant → swap R with G or B
- If G is dominant → swap G with R or B
- If B is dominant → swap B with R or G

**Text color:**
Calculate luminance: L = (0.2126*R + 0.7152*G + 0.0722*B) / 255
- Use #e7e7e7 (light) if L < 0.5
- Use #15202b (dark) if L >= 0.5

## Step 3: Create Settings JSON

Create `.vscode/` directory if it doesn't exist (you can't use mkdir - just proceed).

Use Read tool to check for existing `.vscode/settings.json`.

Create settings object:
```json
{
  "peacock.color": "<base_color>",
  "workbench.colorCustomizations": {
    "activityBar.activeBorder": "<complementary>",
    "activityBar.background": "<lighter>",
    "activityBar.foreground": "<text_color>",
    "activityBar.inactiveForeground": "<text_color_with_opacity>",
    "activityBarBadge.background": "<complementary>",
    "activityBarBadge.foreground": "#e7e7e7",
    "editorGroup.border": "<base_color>",
    "panel.border": "<base_color>",
    "sash.hoverBorder": "<base_color>",
    "sideBar.border": "<base_color>",
    "statusBar.background": "<base_color>",
    "statusBar.foreground": "<text_color>",
    "statusBarItem.hoverBackground": "<lighter>",
    "statusBarItem.remoteBackground": "<base_color>",
    "statusBarItem.remoteForeground": "<text_color>",
    "tab.activeBorder": "<complementary>",
    "titleBar.activeBackground": "<base_color>",
    "titleBar.activeForeground": "<text_color>",
    "titleBar.inactiveBackground": "<base_color_with_opacity>",
    "titleBar.inactiveForeground": "<text_color_with_opacity>"
  }
}
```

## Step 4: Write Settings File

If `.vscode/settings.json` exists:
- Read it
- Merge new colors with existing settings (preserve other settings)
- Use Edit tool to update

If it doesn't exist:
- Use Write tool to create it with the color settings

## Step 5: Confirm Success

Display:
```
✅ Project color set to <hex> (<description>)

Interpreted: "<user_input>" → <hex>

Colors applied to:
- Activity Bar: <lighter_hex> (lighter variant)
- Status Bar: <base_hex> (base color)
- Title Bar: <base_hex> (base color)
- Badges: <complementary_hex> (complementary)

Reload VSCode window to see changes:
Cmd+Shift+P → "Developer: Reload Window"
```

## Important Notes

- Only use Read, Write, Edit tools
- NO bash commands allowed
- Preserve all existing VSCode settings when merging
- Calculate colors yourself - don't delegate to external tools
</instructions>
