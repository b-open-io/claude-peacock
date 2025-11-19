---
version: 0.0.1
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash(jq:*)
description: Set project color from your favorites
tags: peacock, colors, favorites
---

# Favorite Color

Choose a Peacock color from your saved favorites. Matches VSCode Peacock extension's `changeColorToFavorite` command.

## Usage

```
/peacock:favorite-color
```

---

<instructions>
Set project color by selecting from saved favorites.

## Step 1: Load Favorites

Check for favorites file:
```bash
ls ~/.claude/.peacock-favorites.json 2>/dev/null || echo "not found"
```

If not found or empty:
```
❌ No favorite colors saved yet

Save your first favorite:
  /peacock:change-color #8d0756
  /peacock:save-favorite

Or add recommended favorites:
  /peacock:add-favorites
```
Stop execution.

Read favorites:
```bash
jq -c . ~/.claude/.peacock-favorites.json
```

If array is empty, show same error above.

## Step 2: Ask User to Select Favorite

Use AskUserQuestion tool:

**Question**:
- header: "Favorite Color"
- question: "Which favorite color would you like to apply?"
- multiSelect: false
- options: Build from favorites array
  - For each favorite:
    - label: "<name>"
    - description: "<hex_color>"

Maximum 4 options shown. If more than 4 favorites, show most recent 4.

## Step 3: Apply Selected Color

Take selected color and apply to project using same logic as `/peacock:change-color`:

1. Calculate variants (lighter, text, complementary)
2. Create or update `.vscode/settings.json`
3. Merge with existing settings

## Step 4: Confirm

Output:
```
✅ Applied favorite: <name> (<hex>)

Applied to:
  • Title Bar: <hex>
  • Status Bar: <hex>
  • Activity Bar: <lighter_hex>

Reload VSCode window:
  Cmd+Shift+P → "Developer: Reload Window"
```
</instructions>
