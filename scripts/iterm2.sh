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
