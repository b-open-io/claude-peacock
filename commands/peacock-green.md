---
version: 0.0.1
allowed-tools: Read, Write, Edit, Bash(jq:*)
description: Set project to signature Peacock Green color
tags: peacock, colors, green
---

# Peacock Green

Set your project to the signature Peacock Green color. Matches VSCode Peacock extension's `changeColorToPeacockGreen` command.

## Usage

```
/peacock:peacock-green
```

---

<instructions>
Apply the signature Peacock Green color to the current project.

## Step 1: Define Peacock Green

Use the signature Peacock Green color:
```
#42b883
```

This is the iconic Peacock brand color.

## Step 2: Apply Color

Use same logic as `/peacock:change-color` with this specific color:

1. Convert #42b883 to RGB: (66, 184, 131)
2. Calculate variants:
   - Lighter (activity bar): Add 40 to each → (106, 224, 171)
   - Text color: Luminance check → Use #15202b (dark) since it's a light green
   - Complementary: Rotate hue 180° for badges

## Step 3: Update .vscode/settings.json

Create or update settings file with Peacock Green configuration.

Check if exists:
```bash
ls .vscode/settings.json 2>/dev/null || echo "not found"
```

Apply color (same merge logic as change-color command).

## Step 4: Confirm

Output:
```
✅ Peacock Green applied (#42b883)

The signature Peacock color!

Applied to:
  • Title Bar: #42b883
  • Status Bar: #42b883
  • Activity Bar: #6ae0ab (lighter)

Reload VSCode window:
  Cmd+Shift+P → "Developer: Reload Window"
```
</instructions>
