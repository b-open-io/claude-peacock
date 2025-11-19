---
version: 0.0.1
allowed-tools: Read, Write, Bash(jq:*)
description: Add recommended Peacock colors to favorites
tags: peacock, colors, favorites, recommended
---

# Add Recommended Favorites

Add a curated set of recommended Peacock colors to your favorites. Matches VSCode Peacock extension's `addRecommendedFavorites` command.

## Usage

```
/peacock:add-recommended
```

---

<instructions>
Add recommended color palette to user's favorites.

## Step 1: Define Recommended Colors

Use this curated palette (matching popular framework/brand colors):

```json
[
  {"name": "Angular Red", "color": "#b52e31"},
  {"name": "Azure Blue", "color": "#007fff"},
  {"name": "JavaScript Yellow", "color": "#f9e64f"},
  {"name": "Gatsby Purple", "color": "#639"},
  {"name": "Go Cyan", "color": "#5dc9e2"},
  {"name": "Java Orange", "color": "#ea8220"},
  {"name": "Node Green", "color": "#215732"},
  {"name": "Peacock Green", "color": "#42b883"},
  {"name": "Python Blue", "color": "#4584b6"},
  {"name": "React Blue", "color": "#00b3e6"},
  {"name": "Ruby Red", "color": "#cc0000"},
  {"name": "TypeScript Blue", "color": "#007acc"},
  {"name": "Rust Orange", "color": "#ce422b"},
  {"name": "Vue Green", "color": "#42b983"}
]
```

## Step 2: Load Existing Favorites

Check for existing favorites:
```bash
ls ~/.claude/.peacock-favorites.json 2>/dev/null || echo "not found"
```

If not found, create empty array:
```bash
echo '[]' > ~/.claude/.peacock-favorites.json
```

Read existing:
```bash
jq -c . ~/.claude/.peacock-favorites.json
```

## Step 3: Merge Recommended with Existing

For each recommended color, check if it already exists (by color hex):
```bash
jq --argjson recommended '[
  {"name": "Angular Red", "color": "#b52e31"},
  {"name": "Azure Blue", "color": "#007fff"},
  {"name": "JavaScript Yellow", "color": "#f9e64f"},
  {"name": "Gatsby Purple", "color": "#639"},
  {"name": "Go Cyan", "color": "#5dc9e2"},
  {"name": "Java Orange", "color": "#ea8220"},
  {"name": "Node Green", "color": "#215732"},
  {"name": "Peacock Green", "color": "#42b883"},
  {"name": "Python Blue", "color": "#4584b6"},
  {"name": "React Blue", "color": "#00b3e6"},
  {"name": "Ruby Red", "color": "#cc0000"},
  {"name": "TypeScript Blue", "color": "#007acc"},
  {"name": "Rust Orange", "color": "#ce422b"},
  {"name": "Vue Green", "color": "#42b983"}
]' \
'reduce $recommended[] as $rec (.;
  if any(.[]; .color == $rec.color) then
    .
  else
    . + [$rec]
  end
)' \
~/.claude/.peacock-favorites.json > ~/.claude/.peacock-favorites.json.tmp
mv ~/.claude/.peacock-favorites.json.tmp ~/.claude/.peacock-favorites.json
```

## Step 4: Count New Additions

Count how many were actually added (diff between before and after).

## Step 5: Confirm

Output:
```
✅ Recommended favorites added

Added <count> new colors:
  • Angular Red (#b52e31)
  • Azure Blue (#007fff)
  • JavaScript Yellow (#f9e64f)
  • Gatsby Purple (#639)
  • Go Cyan (#5dc9e2)
  • Java Orange (#ea8220)
  • Node Green (#215732)
  • Peacock Green (#42b883)
  • Python Blue (#4584b6)
  • React Blue (#00b3e6)
  • Ruby Red (#cc0000)
  • TypeScript Blue (#007acc)
  • Rust Orange (#ce422b)
  • Vue Green (#42b983)

Total favorites: <total>

Use them:
  /peacock:favorite-color
```

If all already exist:
```
ℹ️  All recommended favorites already added

Total favorites: <total>

Use them:
  /peacock:favorite-color
```
</instructions>
