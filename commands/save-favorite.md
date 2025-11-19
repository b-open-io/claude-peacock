---
version: 0.0.1
allowed-tools: Read, Write, Bash(jq:*)
description: Save current project color to favorites
tags: peacock, colors, favorites
---

# Save Favorite

Save the current project's Peacock color to your favorites list. Matches VSCode Peacock extension's `saveColorToFavorites` command.

## Usage

```
/peacock:save-favorite
```

Optional with custom name:
```
/peacock:save-favorite magenta theme
```

---

<instructions>
Save the current project's Peacock color to favorites.

## Step 1: Read Current Project Color

Check for `.vscode/settings.json`:
```bash
ls .vscode/settings.json 2>/dev/null || echo "not found"
```

If not found:
```
❌ No Peacock color set for this project

Set a color first:
  /peacock:change-color #8d0756
  /peacock:random-color
```
Stop execution.

Extract current color:
```bash
jq -r '.["peacock.color"] // empty' .vscode/settings.json
```

Store as CURRENT_COLOR.

## Step 2: Get Favorite Name

If arguments provided, use as favorite name.
Otherwise, prompt for name or use color hex as name.

## Step 3: Load or Create Favorites File

Check for `~/.claude/.peacock-favorites.json`:
```bash
ls ~/.claude/.peacock-favorites.json 2>/dev/null || echo "not found"
```

If not found, create with empty array:
```bash
echo '[]' > ~/.claude/.peacock-favorites.json
```

## Step 4: Add to Favorites

Read existing favorites:
```bash
jq -c . ~/.claude/.peacock-favorites.json
```

Add new favorite (check for duplicates first):
```bash
jq --arg color "$CURRENT_COLOR" --arg name "$FAV_NAME" \
   '. |
    if any(.[]; .color == $color) then
      .
    else
      . + [{name: $name, color: $color, added: now}]
    end' \
   ~/.claude/.peacock-favorites.json > ~/.claude/.peacock-favorites.json.tmp
mv ~/.claude/.peacock-favorites.json.tmp ~/.claude/.peacock-favorites.json
```

## Step 5: Confirm

Output:
```
✅ Saved to favorites: <color> (<name>)

Total favorites: <count>

Use your favorites:
  /peacock:favorite-color
```
</instructions>
