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
    ((PASS++)) || true
  else
    echo "  FAIL: $label — expected '$expected', got '$actual'"
    ((FAIL++)) || true
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
