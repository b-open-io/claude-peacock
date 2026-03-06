# Peacock Simplification Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Strip peacock down to project color theming only — iTerm2 tab color on session start, color management commands, test harness to prove it works.

**Architecture:** SessionStart hook reads `.vscode/settings.json`, extracts peacock color, sets iTerm2 tab via OSC 6 sequences. Shared scripts in `scripts/` for color utilities and terminal-specific logic. Test harness verifies all logic outside of Claude Code.

**Tech Stack:** Bash, jq, iTerm2 OSC 6 escape sequences

---

### Task 1: Create shared color utilities

**Files:**
- Create: `scripts/color.sh`

**Step 1: Write test/test-colors.sh with color utility tests**

Create the test harness first. It sources `scripts/color.sh` and verifies core functions.

```bash
#!/bin/bash
# Test harness for peacock color utilities
# Run outside Claude Code: bash test/test-colors.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    echo "  PASS: $label"
    ((PASS++))
  else
    echo "  FAIL: $label — expected '$expected', got '$actual'"
    ((FAIL++))
  fi
}

# Source the color utilities
source "$SCRIPT_DIR/scripts/color.sh"

echo "=== hex_to_rgb ==="
assert_eq "black" "0 0 0" "$(hex_to_rgb '#000000')"
assert_eq "white" "255 255 255" "$(hex_to_rgb '#ffffff')"
assert_eq "red" "255 0 0" "$(hex_to_rgb '#ff0000')"
assert_eq "peacock purple" "141 7 86" "$(hex_to_rgb '#8d0756')"
assert_eq "no hash prefix" "141 7 86" "$(hex_to_rgb '8d0756')"

echo ""
echo "=== read_peacock_color ==="

# Create temp fixture
FIXTURE_DIR=$(mktemp -d)
mkdir -p "$FIXTURE_DIR/.vscode"

# Test: peacock.color present
cat > "$FIXTURE_DIR/.vscode/settings.json" << 'FIXTURE'
{
  "peacock.color": "#8d0756",
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#8d0756"
  }
}
FIXTURE
assert_eq "reads peacock.color" "#8d0756" "$(read_peacock_color "$FIXTURE_DIR")"

# Test: only titleBar.activeBackground
cat > "$FIXTURE_DIR/.vscode/settings.json" << 'FIXTURE'
{
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#007acc"
  }
}
FIXTURE
assert_eq "falls back to titleBar" "#007acc" "$(read_peacock_color "$FIXTURE_DIR")"

# Test: no peacock color at all
cat > "$FIXTURE_DIR/.vscode/settings.json" << 'FIXTURE'
{
  "editor.fontSize": 14
}
FIXTURE
assert_eq "no color returns empty" "" "$(read_peacock_color "$FIXTURE_DIR")"

# Test: no settings file
rm -rf "$FIXTURE_DIR/.vscode"
assert_eq "no file returns empty" "" "$(read_peacock_color "$FIXTURE_DIR")"

echo ""
echo "=== find_project_root ==="

# Create nested project fixture
PROJECT_DIR=$(mktemp -d)
mkdir -p "$PROJECT_DIR/myproject/.git"
mkdir -p "$PROJECT_DIR/myproject/src/components/ui"

assert_eq "finds .git root" "$PROJECT_DIR/myproject" "$(find_project_root "$PROJECT_DIR/myproject/src/components/ui")"
assert_eq "at root already" "$PROJECT_DIR/myproject" "$(find_project_root "$PROJECT_DIR/myproject")"

# Cleanup
rm -rf "$FIXTURE_DIR" "$PROJECT_DIR"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
```

**Step 2: Write scripts/color.sh**

```bash
#!/bin/bash
# Shared color utilities for peacock plugin

# Convert hex color to space-separated R G B
# Usage: hex_to_rgb "#8d0756" -> "141 7 86"
hex_to_rgb() {
  local hex="${1#\#}"
  echo "$((16#${hex:0:2})) $((16#${hex:2:2})) $((16#${hex:4:2}))"
}

# Read peacock base color from project's .vscode/settings.json
# Usage: read_peacock_color "/path/to/project" -> "#8d0756" or ""
read_peacock_color() {
  local project_dir="$1"
  local settings="$project_dir/.vscode/settings.json"

  if [[ ! -f "$settings" ]]; then
    return
  fi

  local color
  color=$(jq -r '.["peacock.color"] // .["workbench.colorCustomizations"]["titleBar.activeBackground"] // empty' "$settings" 2>/dev/null)

  if [[ -n "$color" && "$color" != "null" ]]; then
    echo "$color"
  fi
}

# Find project root by walking up directory tree
# Usage: find_project_root "/path/to/nested/dir" -> "/path/to/project"
find_project_root() {
  local current="$1"

  while [[ "$current" != "/" && "$current" != "$HOME" ]]; do
    if [[ -d "$current/.git" ]] || \
       [[ -f "$current/package.json" ]] || \
       [[ -f "$current/go.mod" ]] || \
       [[ -f "$current/Cargo.toml" ]] || \
       [[ -f "$current/pyproject.toml" ]] || \
       [[ -f "$current/composer.json" ]] || \
       [[ -f "$current/build.gradle" ]] || \
       [[ -f "$current/pom.xml" ]]; then
      echo "$current"
      return 0
    fi
    current=$(dirname "$current")
  done

  echo "$1"
}
```

**Step 3: Run tests**

Run: `bash test/test-colors.sh`
Expected: All PASS, exit 0

**Step 4: Commit**

```bash
git add scripts/color.sh test/test-colors.sh
git commit -m "Add shared color utilities with test harness"
```

---

### Task 2: Create iTerm2 module

**Files:**
- Create: `scripts/iterm2.sh`
- Modify: `test/test-colors.sh` (add iTerm2 tests)

**Step 1: Add iTerm2 escape sequence tests to test harness**

Append to `test/test-colors.sh` before the Results section:

```bash
echo ""
echo "=== iterm2 escape sequences ==="

source "$SCRIPT_DIR/scripts/iterm2.sh"

# Capture output to verify format (redirect stderr to file)
ITERM_OUT=$(mktemp)
set_iterm2_tab_color 141 7 86 2>"$ITERM_OUT"

# Check that the file contains the expected OSC 6 sequences
# Using grep -c to count matches
RED_COUNT=$(grep -c 'red;brightness;141' "$ITERM_OUT" || true)
GREEN_COUNT=$(grep -c 'green;brightness;7' "$ITERM_OUT" || true)
BLUE_COUNT=$(grep -c 'blue;brightness;86' "$ITERM_OUT" || true)

assert_eq "red channel present" "1" "$RED_COUNT"
assert_eq "green channel present" "1" "$GREEN_COUNT"
assert_eq "blue channel present" "1" "$BLUE_COUNT"

rm -f "$ITERM_OUT"
```

**Step 2: Write scripts/iterm2.sh**

```bash
#!/bin/bash
# iTerm2 tab color management

# Set iTerm2 tab color via OSC 6 escape sequences
# Usage: set_iterm2_tab_color R G B (0-255 each)
set_iterm2_tab_color() {
  local r="$1" g="$2" b="$3"
  printf "\033]6;1;bg;red;brightness;%s\007" "$r" >&2
  printf "\033]6;1;bg;green;brightness;%s\007" "$g" >&2
  printf "\033]6;1;bg;blue;brightness;%s\007" "$b" >&2
}

# Reset iTerm2 tab color to default
clear_iterm2_tab_color() {
  printf "\033]6;1;bg;*;default\007" >&2
}
```

**Step 3: Run tests**

Run: `bash test/test-colors.sh`
Expected: All PASS including iTerm2 sequence tests

**Step 4: Commit**

```bash
git add scripts/iterm2.sh test/test-colors.sh
git commit -m "Add iTerm2 tab color module with tests"
```

---

### Task 3: Rewrite session-start hook

**Files:**
- Create: `hooks/session-start.sh` (new, replaces session-start-iterm-color.sh)
- Modify: `hooks/hooks.json`

**Step 1: Write hooks/session-start.sh**

```bash
#!/bin/bash
# Hook: Set terminal tab color on session start based on project's Peacock theme
set -e

# Only iTerm2 for now (future: tmux, kitty)
if [[ "$TERM_PROGRAM" != "iTerm.app" ]]; then
  exit 0
fi

# Read hook input from stdin
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)
if [[ -z "$CWD" ]]; then
  exit 0
fi

# Source shared utilities
PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$PLUGIN_DIR/scripts/color.sh"
source "$PLUGIN_DIR/scripts/iterm2.sh"

# Find project and read its color
PROJECT_ROOT=$(find_project_root "$CWD")
COLOR=$(read_peacock_color "$PROJECT_ROOT")
if [[ -z "$COLOR" ]]; then
  exit 0
fi

# Apply tab color
read -r R G B <<< "$(hex_to_rgb "$COLOR")"
set_iterm2_tab_color "$R" "$G" "$B"

exit 0
```

**Step 2: Update hooks/hooks.json**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
          }
        ]
      }
    ]
  }
}
```

**Step 3: Make executable**

Run: `chmod +x hooks/session-start.sh`

**Step 4: Commit**

```bash
git add hooks/session-start.sh hooks/hooks.json
git commit -m "Rewrite session-start hook using shared modules"
```

---

### Task 4: Remove statusline and linting

**Files:**
- Delete: `statusline.sh`, `statusline-demo.sh`, `test-demo.sh`, `DEMO-GUIDE.md`
- Delete: `hooks/lint-on-save.sh`, `hooks/lint-on-start.sh`, `hooks/session-start-iterm-color.sh`
- Delete: `commands/setup.md`, `commands/unsetup.md`, `commands/enable-linting.md`, `commands/disable-linting.md`

**Step 1: Remove files**

```bash
git rm statusline.sh statusline-demo.sh test-demo.sh DEMO-GUIDE.md
git rm hooks/lint-on-save.sh hooks/lint-on-start.sh hooks/session-start-iterm-color.sh
git rm commands/setup.md commands/unsetup.md commands/enable-linting.md commands/disable-linting.md
```

**Step 2: Verify nothing references removed files**

Run: `grep -r "statusline\|lint-on-save\|lint-on-start\|session-start-iterm\|enable-linting\|disable-linting\|setup\.md\|unsetup\.md\|peacock-config" --include="*.sh" --include="*.json" --include="*.md" .`

Fix any remaining references.

**Step 3: Commit**

```bash
git add -A
git commit -m "Remove statusline, linting hooks, and setup commands"
```

---

### Task 5: Update plugin.json and SKILL.md

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `skills/peacock-colors/SKILL.md`

**Step 1: Update plugin.json**

```json
{
  "name": "peacock",
  "description": "Project color theming for your terminal. Sets iTerm2 tab colors to match VSCode Peacock themes.",
  "version": "2.0.0",
  "author": {
    "name": "b-open-io",
    "url": "https://github.com/b-open-io"
  },
  "repository": "b-open-io/claude-peacock",
  "keywords": ["peacock", "vscode", "colors", "theme", "iterm2", "color-management"],
  "hooks": "../hooks/hooks.json"
}
```

**Step 2: Update SKILL.md frontmatter**

Ensure the skill uses only standard frontmatter fields. Update description to reflect simplified scope. Remove any references to statusline or linting.

**Step 3: Run skill-reviewer agent on the updated SKILL.md**

Use `plugin-dev:skill-reviewer` agent to validate the skill.

**Step 4: Commit**

```bash
git add .claude-plugin/plugin.json skills/peacock-colors/SKILL.md
git commit -m "Update plugin manifest and skill for v2.0.0"
```

---

### Task 6: Review color commands for alignment

**Files:**
- Review all 13 commands in `commands/`

**Step 1: Run skill-reviewer on each command that references statusline or linting**

Check each command for references to removed features (statusline, linting, setup, peacock-config). Fix any that mention them.

**Step 2: Verify commands still work**

Each color command writes to `.vscode/settings.json`. Verify the change-color command also calls `set_iterm2_tab_color` for immediate feedback (so you don't have to restart to see the color change).

**Step 3: Commit any fixes**

```bash
git add commands/
git commit -m "Align color commands with simplified plugin"
```

---

### Task 7: Update README

**Files:**
- Modify: `README.md`

**Step 1: Rewrite README**

- New tagline: "Project color theming for your terminal"
- Focus on iTerm2 tab color as the primary feature
- Document color management commands
- Remove all statusline, linting, token usage documentation
- Keep troubleshooting section (simplified)
- Note future expansion (tmux, kitty)

**Step 2: Commit**

```bash
git add README.md
git commit -m "Rewrite README for v2.0.0"
```

---

### Task 8: End-to-end verification

**Step 1: Run test harness**

Run: `bash test/test-colors.sh`
Expected: All PASS

**Step 2: Manual iTerm2 test**

From a regular terminal (not inside Claude Code), run:

```bash
cd /Users/satchmo/code/claude-peacock
# Simulate what the hook does
source scripts/color.sh
source scripts/iterm2.sh
COLOR=$(read_peacock_color "$(find_project_root "$PWD")")
if [[ -n "$COLOR" ]]; then
  read -r R G B <<< "$(hex_to_rgb "$COLOR")"
  set_iterm2_tab_color "$R" "$G" "$B"
  echo "Set tab to $COLOR (RGB: $R $G $B)"
else
  echo "No peacock color found"
fi
```

Verify: iTerm2 tab actually changes color.

**Step 3: Test with a project that has peacock colors**

Pick a project with `.vscode/settings.json` containing `peacock.color`. Run the manual test from that directory.

**Step 4: Test with a project without peacock colors**

Run from a directory with no `.vscode/settings.json`. Verify: no errors, no color change.

**Step 5: Commit test results/notes if any fixes needed**

---

### Task 9: Update marketplace entry

**Files:**
- Modify: `/Users/satchmo/code/claude-plugins/.claude-plugin/marketplace.json`
- Modify: `/Users/satchmo/code/claude-plugins/README.md`

**Step 1: Update marketplace description**

Update the peacock entry description to match the new plugin focus.

**Step 2: Update README detail section**

Update the peacock section in the marketplace README.

**Step 3: Commit in claude-plugins repo**

```bash
cd /Users/satchmo/code/claude-plugins
git add .claude-plugin/marketplace.json README.md
git commit -m "Update peacock marketplace entry for v2.0.0"
```
