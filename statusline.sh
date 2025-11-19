#!/bin/bash
# Claude Code Status Line - DEMO VERSION
# Testing: Project root detection + separated token usage segment

set -e

# Base colors
export WHITE='\033[38;5;255m'
export BLACK='\033[38;5;232m'
export GRAY='\033[38;5;245m'
export BOLD='\033[1m'
export RESET='\033[0m'

# Convert hex color to RGB
hex_to_rgb() {
  local hex="$1"
  hex="${hex#\#}"
  local r=$((16#${hex:0:2}))
  local g=$((16#${hex:2:2}))
  local b=$((16#${hex:4:2}))
  echo "$r $g $b"
}

# Convert RGB to 24-bit true color escape sequence (for background)
rgb_to_bg_true() {
  echo "48;2;$1;$2;$3"
}

# Convert RGB to 24-bit true color escape sequence (for foreground)
rgb_to_fg_true() {
  echo "38;2;$1;$2;$3"
}

# Calculate relative luminance (WCAG formula)
calculate_luminance() {
  local r=$1 g=$2 b=$3
  local rf
  local gf
  local bf
  rf=$(awk "BEGIN {printf \"%.4f\", $r / 255}")
  gf=$(awk "BEGIN {printf \"%.4f\", $g / 255}")
  bf=$(awk "BEGIN {printf \"%.4f\", $b / 255}")

  rf=$(awk "BEGIN {if ($rf <= 0.03928) print $rf / 12.92; else print ((($rf + 0.055) / 1.055) ^ 2.4)}")
  gf=$(awk "BEGIN {if ($gf <= 0.03928) print $gf / 12.92; else print ((($gf + 0.055) / 1.055) ^ 2.4)}")
  bf=$(awk "BEGIN {if ($bf <= 0.03928) print $bf / 12.92; else print ((($bf + 0.055) / 1.055) ^ 2.4)}")

  awk "BEGIN {printf \"%.4f\", 0.2126 * $rf + 0.7152 * $gf + 0.0722 * $bf}"
}

# Get contrasting text color
get_contrast_text() {
  local r=$1 g=$2 b=$3
  local lum
  lum=$(calculate_luminance "$r" "$g" "$b")

  if (( $(awk "BEGIN {print ($lum > 0.4)}") )); then
    echo "232"
  else
    echo "255"
  fi
}

# Generate color family with +40 RGB steps
generate_color_family() {
  local r=$1 g=$2 b=$3

  local r2=$(( r + 40 > 255 ? 255 : r + 40 ))
  local g2=$(( g + 40 > 255 ? 255 : g + 40 ))
  local b2=$(( b + 40 > 255 ? 255 : b + 40 ))

  local r3=$(( r + 80 > 255 ? 255 : r + 80 ))
  local g3=$(( g + 80 > 255 ? 255 : g + 80 ))
  local b3=$(( b + 80 > 255 ? 255 : b + 80 ))

  local text_code
  local text_r text_g text_b
  text_code=$(get_contrast_text "$r" "$g" "$b")
  if [[ "$text_code" == "232" ]]; then
    text_r=40; text_g=40; text_b=40
  else
    text_r=255; text_g=255; text_b=255
  fi

  echo "$r $g $b $r2 $g2 $b2 $r3 $g3 $b3 $text_r $text_g $text_b"
}

# NEW: Find project root by walking up directory tree
# Looks for: .git, package.json, go.mod, Cargo.toml, pyproject.toml, composer.json
find_project_root() {
  local path="$1"

  # Start from file's directory
  if [[ -f "$path" ]]; then
    path=$(dirname "$path")
  fi

  # Walk up until we find a project marker or hit root
  local current="$path"
  while [[ "$current" != "/" && "$current" != "$HOME" ]]; do
    # Check for common project markers
    if [[ -d "$current/.git" ]] || \
       [[ -f "$current/package.json" ]] || \
       [[ -f "$current/go.mod" ]] || \
       [[ -f "$current/Cargo.toml" ]] || \
       [[ -f "$current/pyproject.toml" ]] || \
       [[ -f "$current/composer.json" ]] || \
       [[ -f "$current/build.gradle" ]] || \
       [[ -f "$current/pom.xml" ]]; then
      echo "$current"
      return
    fi
    current=$(dirname "$current")
  done

  # No project root found, return original path
  echo "$path"
}

# Load project colors from .vscode/settings.json
load_project_colors() {
  local proj_dir="$1"
  local settings_file="$proj_dir/.vscode/settings.json"

  if [[ ! -f "$settings_file" ]]; then
    return
  fi

  local base
  local light_fg
  local dark_fg
  local badge
  base=$(jq -r '.["peacock.color"] // .workbench.colorCustomizations["titleBar.activeBackground"] // empty' "$settings_file" 2>/dev/null)
  light_fg=$(jq -r '.workbench.colorCustomizations["activityBar.foreground"] // empty' "$settings_file" 2>/dev/null)
  dark_fg=$(jq -r '.workbench.colorCustomizations["activityBarBadge.foreground"] // empty' "$settings_file" 2>/dev/null)
  badge=$(jq -r '.workbench.colorCustomizations["activityBarBadge.background"] // empty' "$settings_file" 2>/dev/null)

  echo "$base $light_fg $dark_fg $badge"
}

# Default color families
DEFAULT_P_RGB="95 0 95 135 40 135 175 80 175 255 255 255"
DEFAULT_C_RGB="0 95 95 40 135 135 80 175 175 255 255 255"

# Read JSON input
INPUT=$(cat)

# Extract session info
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)

# Load config
if [[ -f "$HOME/.claude/.peacock-config" ]]; then
  source "$HOME/.claude/.peacock-config"
fi

# Auto-detect editor
if [[ -z "$EDITOR_SCHEME" ]]; then
  if command -v cursor &> /dev/null; then
    EDITOR_SCHEME="cursor"
  elif command -v code &> /dev/null; then
    EDITOR_SCHEME="vscode"
  elif command -v subl &> /dev/null; then
    EDITOR_SCHEME="sublime"
  else
    EDITOR_SCHEME="file"
  fi
fi

# Verify transcript exists
if [[ -n "$TRANSCRIPT" && ! -f "$TRANSCRIPT" ]]; then
  TRANSCRIPT=""
fi

# NEW: Get CWD project root using project detection
CWD_PROJECT_ROOT=""
CWD_PROJECT_NAME=""
if [[ -n "$CWD" ]]; then
  CWD_PROJECT_ROOT=$(find_project_root "$CWD")
  CWD_PROJECT_NAME=$(basename "$CWD_PROJECT_ROOT")
fi

# NEW: Get last edited file and its project root
LAST_FILE=""
EDITED_PROJECT_ROOT=""
EDITED_PROJECT_NAME=""
if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
  # Extract path from last tool use
  RECENT_TOOLS=$(tail -200 "$TRANSCRIPT" 2>/dev/null)

  # Try file_path parameter
  DETECTED_PATH=$(echo "$RECENT_TOOLS" | \
    grep -o '"file_path":"[^"]*"' | \
    tail -1 | \
    sed 's/"file_path":"//; s/"$//')

  # Try notebook_path
  if [[ -z "$DETECTED_PATH" ]]; then
    DETECTED_PATH=$(echo "$RECENT_TOOLS" | \
      grep -o '"notebook_path":"[^"]*"' | \
      tail -1 | \
      sed 's/"notebook_path":"//; s/"$//')
  fi

  # Try path parameter
  if [[ -z "$DETECTED_PATH" ]]; then
    DETECTED_PATH=$(echo "$RECENT_TOOLS" | \
      grep -o '"path":"[^"]*"' | \
      tail -1 | \
      sed 's/"path":"//; s/"$//')
  fi

  if [[ -n "$DETECTED_PATH" ]]; then
    # Expand ~ to $HOME
    DETECTED_PATH="${DETECTED_PATH/#\~/$HOME}"
    # Remove glob patterns
    DETECTED_PATH="${DETECTED_PATH%%\**}"

    LAST_FILE="$DETECTED_PATH"

    # NEW: Find project root for this file
    EDITED_PROJECT_ROOT=$(find_project_root "$DETECTED_PATH")
    EDITED_PROJECT_NAME=$(basename "$EDITED_PROJECT_ROOT")
  fi
fi

# Get token usage
TOKEN_USAGE=""
if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
  TOKEN_USAGE=$(tail -50 "$TRANSCRIPT" 2>/dev/null | \
    jq -r 'select(.usage) | "\(.usage.input_tokens // 0 + .usage.output_tokens // 0)"' 2>/dev/null | \
    tail -1)
fi

# Load CWD project colors
if [[ -n "$CWD_PROJECT_ROOT" && -d "$CWD_PROJECT_ROOT" ]]; then
  read -r CWD_BASE CWD_LIGHT_FG CWD_DARK_FG CWD_BADGE <<< "$(load_project_colors "$CWD_PROJECT_ROOT")"
  if [[ -n "$CWD_BASE" ]]; then
    read -r CWD_R CWD_G CWD_B <<< "$(hex_to_rgb "$CWD_BASE")"
    read -r C_R1 C_G1 C_B1 C_R2 C_G2 C_B2 C_R3 C_G3 C_B3 C_TR C_TG C_TB <<< "$(generate_color_family "$CWD_R" "$CWD_G" "$CWD_B")"

    if [[ -n "$CWD_LIGHT_FG" ]]; then
      read -r C_TR C_TG C_TB <<< "$(hex_to_rgb "$CWD_LIGHT_FG")"
    fi

    if [[ -n "$CWD_DARK_FG" ]]; then
      read -r C_DARK_R C_DARK_G C_DARK_B <<< "$(hex_to_rgb "$CWD_DARK_FG")"
    else
      C_DARK_R=40; C_DARK_G=40; C_DARK_B=40
    fi

    if [[ -n "$CWD_BADGE" ]]; then
      read -r C_BADGE_R C_BADGE_G C_BADGE_B <<< "$(hex_to_rgb "$CWD_BADGE")"
    else
      C_BADGE_R=$C_R3; C_BADGE_G=$C_G3; C_BADGE_B=$C_B3
    fi
  else
    read -r C_R1 C_G1 C_B1 C_R2 C_G2 C_B2 C_R3 C_G3 C_B3 C_TR C_TG C_TB <<< "$DEFAULT_C_RGB"
    C_BADGE_R=$C_R3; C_BADGE_G=$C_G3; C_BADGE_B=$C_B3
    C_DARK_R=40; C_DARK_G=40; C_DARK_B=40
  fi
else
  read -r C_R1 C_G1 C_B1 C_R2 C_G2 C_B2 C_R3 C_G3 C_B3 C_TR C_TG C_TB <<< "$DEFAULT_C_RGB"
  C_BADGE_R=$C_R3; C_BADGE_G=$C_G3; C_BADGE_B=$C_B3
  C_DARK_R=40; C_DARK_G=40; C_DARK_B=40
fi

# Set CWD color variables
BG_C1="\033[48;2;${C_R1};${C_G1};${C_B1}m"
BG_C2="\033[48;2;${C_R2};${C_G2};${C_B2}m"
BG_C3="\033[48;2;${C_R3};${C_G3};${C_B3}m"
FG_C1="\033[38;2;${C_R1};${C_G1};${C_B1}m"
FG_C2="\033[38;2;${C_R2};${C_G2};${C_B2}m"
TEXT_C="\033[38;2;${C_TR};${C_TG};${C_TB}m"
DARK_TEXT_C="\033[38;2;${C_DARK_R};${C_DARK_G};${C_DARK_B}m"
BADGE_C="\033[38;2;${C_BADGE_R};${C_BADGE_G};${C_BADGE_B}m"

# Load edited project colors
if [[ -n "$EDITED_PROJECT_ROOT" && -d "$EDITED_PROJECT_ROOT" && "$EDITED_PROJECT_ROOT" != "$CWD_PROJECT_ROOT" ]]; then
  read -r PROJ_BASE PROJ_LIGHT_FG PROJ_DARK_FG PROJ_BADGE <<< "$(load_project_colors "$EDITED_PROJECT_ROOT")"
  if [[ -n "$PROJ_BASE" ]]; then
    read -r PROJ_R PROJ_G PROJ_B <<< "$(hex_to_rgb "$PROJ_BASE")"
    read -r P_R1 P_G1 P_B1 P_R2 P_G2 P_B2 P_R3 P_G3 P_B3 P_TR P_TG P_TB <<< "$(generate_color_family "$PROJ_R" "$PROJ_G" "$PROJ_B")"

    if [[ -n "$PROJ_LIGHT_FG" ]]; then
      read -r P_TR P_TG P_TB <<< "$(hex_to_rgb "$PROJ_LIGHT_FG")"
    fi

    if [[ -n "$PROJ_DARK_FG" ]]; then
      read -r P_DARK_R P_DARK_G P_DARK_B <<< "$(hex_to_rgb "$PROJ_DARK_FG")"
    else
      P_DARK_R=40; P_DARK_G=40; P_DARK_B=40
    fi

    if [[ -n "$PROJ_BADGE" ]]; then
      read -r P_BADGE_R P_BADGE_G P_BADGE_B <<< "$(hex_to_rgb "$PROJ_BADGE")"
    else
      P_BADGE_R=$P_R3; P_BADGE_G=$P_G3; P_BADGE_B=$P_B3
    fi
  else
    read -r P_R1 P_G1 P_B1 P_R2 P_G2 P_B2 P_R3 P_G3 P_B3 P_TR P_TG P_TB <<< "$DEFAULT_P_RGB"
    P_BADGE_R=$P_R3; P_BADGE_G=$P_G3; P_BADGE_B=$P_B3
    P_DARK_R=40; P_DARK_G=40; P_DARK_B=40
  fi
else
  read -r P_R1 P_G1 P_B1 P_R2 P_G2 P_B2 P_R3 P_G3 P_B3 P_TR P_TG P_TB <<< "$DEFAULT_P_RGB"
  P_BADGE_R=$P_R3; P_BADGE_G=$P_G3; P_BADGE_B=$P_B3
  P_DARK_R=40; P_DARK_G=40; P_DARK_B=40
fi

# Set edited project color variables
BG_P1="\033[48;2;${P_R1};${P_G1};${P_B1}m"
BG_P2="\033[48;2;${P_R2};${P_G2};${P_B2}m"
BG_P3="\033[48;2;${P_R3};${P_G3};${P_B3}m"
FG_P1="\033[38;2;${P_R1};${P_G1};${P_B1}m"
FG_P2="\033[38;2;${P_R2};${P_G2};${P_B2}m"
TEXT_P="\033[38;2;${P_TR};${P_TG};${P_TB}m"
DARK_TEXT_P="\033[38;2;${P_DARK_R};${P_DARK_G};${P_DARK_B}m"
BADGE_P="\033[38;2;${P_BADGE_R};${P_BADGE_G};${P_BADGE_B}m"

# Get git branch for a project
get_git_branch() {
  local proj_root="$1"

  if [[ -d "$proj_root/.git" ]]; then
    local branch
    local dirty=""
    branch=$(git -C "$proj_root" rev-parse --abbrev-ref HEAD 2>/dev/null)

    if ! git -C "$proj_root" diff --quiet HEAD 2>/dev/null; then
      dirty="*"
    fi

    echo "${branch}${dirty}"
  fi
}

# Get lint counts (using project name as key for now)
get_lint_counts() {
  local proj_name="$1"
  local state_file="$HOME/.claude/lint-state/$proj_name.json"

  if [[ ! -f "$state_file" ]]; then
    echo "0 0"
    return
  fi

  local errors
  local warnings
  errors=$(jq -r '.errors // 0' "$state_file" 2>/dev/null || echo "0")
  warnings=$(jq -r '.warnings // 0' "$state_file" 2>/dev/null || echo "0")

  [[ -z "$errors" || ! "$errors" =~ ^[0-9]+$ ]] && errors=0
  [[ -z "$warnings" || ! "$warnings" =~ ^[0-9]+$ ]] && warnings=0

  echo "$errors $warnings"
}

# Build statusline
OUTPUT=""

# CWD project segment (⌂ = "project" where Claude started)
if [[ -n "$CWD_PROJECT_NAME" ]]; then
  OUTPUT="${BG_C1}${TEXT_C}${BOLD} ⌂ $CWD_PROJECT_NAME ${RESET}"

  # Lint status
  read -r CWD_ERRORS CWD_WARNINGS <<< "$(get_lint_counts "$CWD_PROJECT_NAME")"

  OUTPUT="${OUTPUT}${FG_C1}${BG_C2}▶"

  if [[ "$CWD_ERRORS" -gt 0 ]]; then
    OUTPUT="${OUTPUT}${BADGE_C}${BOLD} ✗$CWD_ERRORS"
  fi

  if [[ "$CWD_WARNINGS" -gt 0 ]]; then
    OUTPUT="${OUTPUT}${BADGE_C}${BOLD} △$CWD_WARNINGS"
  fi

  if [[ "$CWD_ERRORS" -eq 0 && "$CWD_WARNINGS" -eq 0 ]]; then
    OUTPUT="${OUTPUT}${BADGE_C}${BOLD} ✓"
  fi

  OUTPUT="${OUTPUT} ${RESET}"

  # Git branch
  CWD_BRANCH=$(get_git_branch "$CWD_PROJECT_ROOT")
  if [[ -n "$CWD_BRANCH" ]]; then
    OUTPUT="${OUTPUT}${FG_C2}${BG_C3}▶${DARK_TEXT_C} ⎇ ${CWD_BRANCH} ${RESET}"
  fi
fi

# Edited project segment (✎ = "working folder" currently editing)
if [[ -n "$EDITED_PROJECT_NAME" && "$EDITED_PROJECT_ROOT" != "$CWD_PROJECT_ROOT" ]]; then
  OUTPUT="${OUTPUT}${BG_P1}${TEXT_P} ✎ $EDITED_PROJECT_NAME ${RESET}"

  # Lint status
  read -r ERRORS WARNINGS <<< "$(get_lint_counts "$EDITED_PROJECT_NAME")"

  OUTPUT="${OUTPUT}${FG_P1}${BG_P2}▶"

  if [[ "$ERRORS" -gt 0 ]]; then
    OUTPUT="${OUTPUT}${BADGE_P}${BOLD} ✗$ERRORS"
  fi

  if [[ "$WARNINGS" -gt 0 ]]; then
    OUTPUT="${OUTPUT}${BADGE_P}${BOLD} △$WARNINGS"
  fi

  if [[ "$ERRORS" -eq 0 && "$WARNINGS" -eq 0 ]]; then
    OUTPUT="${OUTPUT}${BADGE_P}${BOLD} ✓"
  fi

  OUTPUT="${OUTPUT} ${RESET}"

  # Git branch
  PROJECT_BRANCH=$(get_git_branch "$EDITED_PROJECT_ROOT")
  if [[ -n "$PROJECT_BRANCH" ]]; then
    OUTPUT="${OUTPUT}${FG_P2}${BG_P3}▶${DARK_TEXT_P} ⎇ ${PROJECT_BRANCH} ${RESET}"
  fi
fi

# NEW: Separated token usage segment (dark gray box, no powerline)
if [[ -n "$TOKEN_USAGE" && "$TOKEN_USAGE" =~ ^[0-9]+$ && "$TOKEN_USAGE" -gt 0 ]]; then
  # Format as K (thousands)
  if [[ "$TOKEN_USAGE" -ge 1000 ]]; then
    TOKEN_K=$((TOKEN_USAGE / 1000))
    TOKEN_DISPLAY="${TOKEN_K}k"
  else
    TOKEN_DISPLAY="$TOKEN_USAGE"
  fi

  # Dark gray background (45,45,45), white text
  TOKEN_BG="\033[48;2;45;45;45m"
  TOKEN_FG="\033[38;2;200;200;200m"

  OUTPUT="${OUTPUT} ${TOKEN_BG}${TOKEN_FG} ${TOKEN_DISPLAY} ${RESET}"
fi

# Last edited file (clickable, no background)
if [[ -n "$LAST_FILE" && -f "$LAST_FILE" ]]; then
  # Make path relative to edited project root
  RELATIVE_FILE="$LAST_FILE"
  if [[ -n "$EDITED_PROJECT_ROOT" ]]; then
    RELATIVE_FILE="${LAST_FILE#"$EDITED_PROJECT_ROOT"/}"
  elif [[ -n "$CWD_PROJECT_ROOT" ]]; then
    RELATIVE_FILE="${LAST_FILE#"$CWD_PROJECT_ROOT"/}"
  fi

  # Build URL based on editor scheme
  case "$EDITOR_SCHEME" in
    cursor)  FILE_URL="cursor://file${LAST_FILE}" ;;
    vscode)  FILE_URL="vscode://file${LAST_FILE}" ;;
    sublime) FILE_URL="subl://open?url=file://${LAST_FILE}" ;;
    *)       FILE_URL="file://${LAST_FILE}" ;;
  esac

  # OSC 8 hyperlink
  OUTPUT="${OUTPUT} ${GRAY}\033]8;;${FILE_URL}\a${RELATIVE_FILE}\033]8;;\a${RESET}"
fi

# Set terminal title to project root
# Uses OSC 0 sequence: \033]0;TITLE\007
TERMINAL_TITLE=""
if [[ -n "$EDITED_PROJECT_NAME" && "$EDITED_PROJECT_ROOT" != "$CWD_PROJECT_ROOT" ]]; then
  # Editing different project - show both
  TERMINAL_TITLE="${CWD_PROJECT_NAME} | ${EDITED_PROJECT_NAME}"
elif [[ -n "$CWD_PROJECT_NAME" ]]; then
  # Just show CWD project
  TERMINAL_TITLE="$CWD_PROJECT_NAME"
fi

if [[ -n "$TERMINAL_TITLE" ]]; then
  # Set terminal title (OSC 0 sequence)
  echo -ne "\033]0;${TERMINAL_TITLE}\007" >&2
fi

# Set iTerm2 tab color to match Peacock theme (if available)
# Uses OSC 6 sequence for tab color
# Only set if we have a project with Peacock colors
if [[ -n "$CWD_R" && -n "$CWD_G" && -n "$CWD_B" ]]; then
  # Set tab color to CWD project's Peacock color
  echo -ne "\033]6;1;bg;red;brightness;${CWD_R}\007" >&2
  echo -ne "\033]6;1;bg;green;brightness;${CWD_G}\007" >&2
  echo -ne "\033]6;1;bg;blue;brightness;${CWD_B}\007" >&2
fi

echo -e "$OUTPUT"
