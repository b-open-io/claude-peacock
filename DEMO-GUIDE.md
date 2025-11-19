# Peacock Statusline Demo Guide

## What's New

### 1. Project Root Detection
No more `CODE_DIR` configuration needed! The statusline automatically finds project roots by walking up the directory tree looking for:
- `.git/`
- `package.json`
- `go.mod`
- `Cargo.toml`
- `pyproject.toml`
- `composer.json`
- `build.gradle`
- `pom.xml`

### 2. Separated Token Usage
Token count now appears in its own dark gray box with no powerline arrows bleeding into it.

### 3. Clear Terminology
- **⌂ project**: Where Claude Code started (CWD)
- **✎ working folder**: What you're currently editing

## Visual Examples

### Scenario 1: Simple case
```
⌂ claude-peacock ▶ ✓ ▶ ⎇ master
└─ cyan ────┘       └─ lighter cyan ─┘
```

### Scenario 2: With token usage
```
⌂ claude-peacock ▶ ✓ ▶ ⎇ master  [48.5k] commands/setup.md
└─ cyan ────┘       └─ lighter ─┘  └gray─┘ └── gray text ──┘
                                   separate
                                    segment
```

### Scenario 3: Deep nested file
```
⌂ claude-peacock ▶ ✓ ▶ ⎇ master  [89k]
                                  ^^^^
File: commands/integrations/stripe/config.ts
Shows "claude-peacock" as root (not "stripe")
```

### Scenario 4: Two different projects
```
⌂ claude-peacock ▶ ✓ ▶ ⎇ master  ✎ my-project ▶ ✓  [125k]
└─ cyan ────────────────────┘    └─ purple ────┘    └gray┘
    (project where started)        (currently editing)
```

### Scenario 5: ~/Source user (no config needed!)
```
⌂ test-project ▶ ✓  [67k] index.ts
└─ cyan ──┘         └gray┘ └ gray ─┘

Works automatically even though code is in ~/Source instead of ~/code!
```

## Key Improvements

### Before (OLD)
❌ Required `CODE_DIR` configuration
❌ Token usage had powerline bleed
❌ Nested projects showed wrong name (e.g., "stripe" instead of "my-app")
❌ ~/Source users had to manually configure
❌ Deep directories confused the detection

### After (NEW)
✅ Automatic project root detection
✅ Token usage in clean, separate gray box
✅ Correct project name even for nested files
✅ Works with ~/code, ~/Source, ~/projects, etc.
✅ Deep directories work correctly (walks up to find root)
✅ No CODE_DIR configuration needed

## How to Test

### Option 1: Try the demo script
```bash
cd /Users/satchmo/code/claude-peacock
./test-demo.sh
```

### Option 2: Replace your current statusline
```bash
# Backup current
cp ~/.claude/statusline.sh ~/.claude/statusline.sh.backup

# Install demo
cp /Users/satchmo/code/claude-peacock/statusline-demo.sh ~/.claude/statusline.sh

# Restart Claude Code
```

### Option 3: Test manually with different projects
```bash
# Test with your actual transcript
cat <<EOF | /Users/satchmo/code/claude-peacock/statusline-demo.sh
{
  "cwd": "$(pwd)",
  "transcript_path": "$HOME/.claude/sessions/latest/transcript.json"
}
EOF
```

## What Each Color Means

- **Cyan segments** = CWD project (⌂ where you started)
- **Purple segments** = Edited project (✎ what you're working on)
- **Dark gray box** = Token usage (neutral, doesn't belong to any project)
- **Light gray text** = File path (clickable link)

## Next Steps

Once you're happy with the demo:
1. Update the main `statusline.sh` with these changes
2. Update `commands/setup.md` to remove CODE_DIR questions (optional)
3. Bump plugin version to 0.0.9
4. Publish to marketplace
