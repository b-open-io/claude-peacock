---
name: peacock-colors
version: 1.0.0
description: Project color theming for VS Code and iTerm2. Use when the user asks to set, change, darken, lighten, or reset project colors, save favorite colors, or mentions Peacock color theming.
---

# Peacock Colors

Manage VS Code project colors with Peacock-style theming. This skill provides comprehensive color management for VS Code workspaces, similar to the popular Peacock extension.

## Core Capabilities

1. **Set Project Color** - Apply a color to the current project using hex codes, natural language, or random generation
2. **Adjust Color** - Darken or lighten the current color by percentage
3. **Save Favorites** - Store frequently used colors for quick access
4. **Reset/Remove** - Clear project coloring or completely remove all color settings
5. **Show Current** - Display and copy the current project color

## Usage Examples

### Set Project Color

**With hex code:**
```
Set my project color to #FF5733
```

**With natural language:**
```
Set my project color to dark forest green
Set my project color to vibrant ocean blue
Set my project color to deep magenta
```

**Random vibrant color:**
```
Set a random project color
```

### Adjust Color

```
Darken my project color by 10%
Lighten my project color by 20%
```

### Save Favorite

```
Save this as my favorite "production" color
Save current color to favorites
```

### Apply Favorite

```
Apply my favorite color
Set project color from favorites
```

### Show Current Color

```
Show my project color
What color is this project?
```

### Reset/Remove

```
Reset my project colors
Remove all color settings
```

## Implementation Details

### File Locations

- **Project colors**: `.vscode/settings.json` under `peacock.color` and `workbench.colorCustomizations`
- **Favorites**: `~/.claude/.peacock-favorites.json`

### Color Format Support

- **Hex colors**: `#RRGGBB` format (e.g., `#8d0756`)
- **Natural language**: "dark forest green", "vibrant ocean blue", "light purple"
- **Random generation**: Vibrant colors from curated palette

### Color Adjustments

Adjustments use RGB color space:

**Darken by 10%:**
```
new_r = current_r * 0.9
new_g = current_g * 0.9
new_b = current_b * 0.9
```

**Lighten by 10%:**
```
new_r = current_r + (255 - current_r) * 0.1
new_g = current_g + (255 - current_g) * 0.1
new_b = current_b + (255 - current_b) * 0.1
```

### VS Code Color Customizations

When setting a project color, these VS Code settings are configured:

```json
{
  "peacock.color": "<base_color>",
  "workbench.colorCustomizations": {
    "activityBar.activeBorder": "<complementary_color>",
    "activityBar.background": "<lighter_variant>",
    "activityBar.foreground": "<text_color>",
    "activityBar.inactiveForeground": "<text_color_50%_opacity>",
    "activityBarBadge.background": "<complementary_color>",
    "activityBarBadge.foreground": "#e7e7e7",
    "editorGroup.border": "<base_color>",
    "panel.border": "<base_color>",
    "sash.hoverBorder": "<base_color>",
    "sideBar.border": "<base_color>",
    "statusBar.background": "<base_color>",
    "statusBar.foreground": "<text_color>",
    "statusBarItem.hoverBackground": "<lighter_variant>",
    "statusBarItem.remoteBackground": "<base_color>",
    "statusBarItem.remoteForeground": "<text_color>",
    "tab.activeBorder": "<complementary_color>",
    "titleBar.activeBackground": "<base_color>",
    "titleBar.activeForeground": "<text_color>",
    "titleBar.inactiveBackground": "<base_color_90%_opacity>",
    "titleBar.inactiveForeground": "<text_color_60%_opacity>"
  }
}
```

### Color Calculations

**Lighter Variant (for activity bar):**
Add approximately 30% brightness to RGB values, cap at 255:
```
lighter_r = min(base_r + 77, 255)
lighter_g = min(base_g + 77, 255)
lighter_b = min(base_b + 77, 255)
```

**Complementary Color (for badges):**
Rotate hue by 180 degrees:
1. Convert RGB to HSL
2. Add 180 to hue (wrap if > 360)
3. Convert back to RGB

**Text Contrast Color:**
Calculate relative luminance: `L = 0.2126*R + 0.7152*G + 0.0722*B`
- Use `#e7e7e7` (light text) if L < 0.5
- Use `#15202b` (dark text) if L >= 0.5

### Natural Language Color Mapping

#### Base Hue Mappings

| Hue | Keywords | Dark | Vibrant | Light |
|-----|----------|------|---------|-------|
| **Red** | red, crimson, ruby, cherry, rose | #8B0000 | #FF6B6B | #FFB6C1 |
| **Orange** | orange, rust, amber, tangerine, coral | #CC5500 | #FF8C42 | #FFCC99 |
| **Yellow** | yellow, gold, lemon, mustard | #B8860B | #FFD700 | #FFEB99 |
| **Green** | green, forest, emerald, lime, olive | #2D5016 | #4CAF50 | #90EE90 |
| **Teal** | teal, turquoise, aquamarine | #123323 | #20B2AA | #AFEEEE |
| **Cyan** | cyan, sky, aqua | #006B7D | #00CED1 | #E0FFFF |
| **Blue** | blue, navy, ocean, azure, sapphire | #003E80 | #4A90E2 | #ADD8E6 |
| **Purple** | purple, violet, lavender, plum | #4B0082 | #9370DB | #DDA0DD |
| **Magenta** | magenta, fuchsia, hot pink | #8D0756 | #FF1493 | #FFB6E5 |
| **Brown** | brown, chocolate, coffee, tan, beige | #654321 | #A0522D | #D2B48C |
| **Gray** | gray, grey, silver, slate, charcoal | #2C2C2C | #808080 | #D3D3D3 |

#### Modifier Keywords

- **"dark", "deep", "darker"** → use dark variant
- **"vibrant", "bright", "vivid", "intense", "saturated"** → use vibrant variant
- **"light", "lighter", "pale", "pastel", "soft"** → use light variant
- **"muted", "subtle", "desaturated"** → reduce saturation by 30%

### Random Vibrant Colors

When generating random colors, select from:
- #FF6B6B (vibrant red)
- #FF8C42 (vibrant orange)
- #FFD700 (vibrant yellow)
- #4CAF50 (vibrant green)
- #20B2AA (vibrant teal)
- #00CED1 (vibrant cyan)
- #4A90E2 (vibrant blue)
- #9370DB (vibrant purple)
- #FF1493 (vibrant magenta)

## Requirements

- **jq** command-line JSON processor
  - macOS: `brew install jq`
  - Ubuntu/Debian: `apt install jq`
- Write access to `.vscode/settings.json` in the project directory

## Workflow

### Setting a Project Color

1. Parse user input (hex, natural language, or empty for random)
2. Convert natural language to hex using mapping tables
3. Calculate lighter variant and complementary colors
4. Determine optimal text contrast color
5. Ensure `.vscode` directory exists
6. Read existing `.vscode/settings.json` (or treat as empty `{}`)
7. Generate complete color settings object
8. Merge new color settings with existing settings (preserving non-color keys)
9. Write updated settings back to `.vscode/settings.json`
10. Display success message with color details and reload instructions

### Adjusting Colors

1. Read current color from `.vscode/settings.json` (`peacock.color`)
2. Apply darken/lighten calculation to RGB values
3. Use same workflow as "Setting a Project Color" to apply new color
4. Display before/after comparison

### Managing Favorites

**Saving:**
1. Read current color from project settings
2. Load existing favorites from `~/.claude/.peacock-favorites.json`
3. Add new favorite with name, color, and timestamp
4. Avoid duplicates (check by color value)
5. Save updated favorites list

**Applying:**
1. Load favorites list
2. Present user with selection (if multiple)
3. Apply selected color using standard project color workflow

### Resetting/Removing

**Reset (project only):**
1. Remove `peacock.color` property
2. Remove color-related entries from `workbench.colorCustomizations`
3. Clean up empty objects
4. Remove `.vscode/settings.json` if now empty

**Remove All (complete cleanup):**
1. Remove project colors from `.vscode/settings.json`
2. Delete `~/.claude/.peacock-favorites.json`

## Example Output

### Setting Color
```
✅ Project color set to #8d0756 (dark magenta)

Interpreted: "dark magenta" → #8d0756

Color applied to:
- Activity Bar: #A87BAB (lighter variant)
- Status Bar: #8d0756 (base color)
- Title Bar: #8d0756 (base color)
- Badges: #07568D (complementary - blue)

Reload VSCode window to see changes:
Cmd+Shift+P → "Developer: Reload Window"
```

### Adjusting Color
```
Color darkened by 10%

Before: #8d0756
After:  #7f064d

Applied to:
  Title Bar: #7f064d
  Status Bar: #7f064d
  Activity Bar: #976b99

Reload VSCode window:
  Cmd+Shift+P → "Developer: Reload Window"

Too dark? Lighten the color
```

### Showing Current Color
```
Current Project Color

Base Color: #8d0756
RGB: (141, 7, 86)

Applied to:
  Title Bar: #8d0756
  Status Bar: #8d0756
  Activity Bar: #A87BAB

Color copied to clipboard!

Modify:
  Darken color      - Make darker
  Lighten color     - Make lighter
  Save to favorites - Save for later

Reset:
  Reset colors
```

## Notes

- Colors persist in `.vscode/settings.json` (typically committed to git)
- Safe to run multiple times - preserves other VSCode settings
- Works with or without the Peacock extension installed
- Natural language parsing understands intensity modifiers and color names
- Favorites are stored per-user in `~/.claude/.peacock-favorites.json`
- After changing colors, reload VS Code window to see changes
