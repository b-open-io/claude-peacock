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
assert_eq "uppercase hex" "255 0 0" "$(hex_to_rgb '#FF0000')"

# Test invalid inputs (should fail with return code 1)
if hex_to_rgb "#f00" 2>/dev/null; then
  echo "  FAIL: shorthand hex should fail"
  ((FAIL++)) || true
else
  echo "  PASS: shorthand hex rejected"
  ((PASS++)) || true
fi

if hex_to_rgb "" 2>/dev/null; then
  echo "  FAIL: empty string should fail"
  ((FAIL++)) || true
else
  echo "  PASS: empty string rejected"
  ((PASS++)) || true
fi

if hex_to_rgb "nothex" 2>/dev/null; then
  echo "  FAIL: non-hex string should fail"
  ((FAIL++)) || true
else
  echo "  PASS: non-hex string rejected"
  ((PASS++)) || true
fi

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

# Test: find_project_root with package.json marker (no .git)
PKG_DIR=$(mktemp -d)
mkdir -p "$PKG_DIR/myapp/src/lib"
touch "$PKG_DIR/myapp/package.json"
assert_eq "finds package.json root" "$PKG_DIR/myapp" "$(find_project_root "$PKG_DIR/myapp/src/lib")"
rm -rf "$PKG_DIR"

# Test: find_project_root with no project markers returns original path
NOMARKER_DIR=$(mktemp -d)
mkdir -p "$NOMARKER_DIR/a/b/c"
assert_eq "no markers returns original" "$NOMARKER_DIR/a/b/c" "$(find_project_root "$NOMARKER_DIR/a/b/c")"
rm -rf "$NOMARKER_DIR"

# Cleanup
rm -rf "$FIXTURE_DIR" "$PROJECT_DIR"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
