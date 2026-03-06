# Peacock Simplification Design

## Problem

The peacock plugin tries to do too much — statusline theming, auto-linting, color management, terminal titles, clickable links, token usage. It breaks things and the core feature (iTerm2 tab color matching project theme) has never worked reliably.

## Goal

Strip peacock down to one job: **show your project's color in your terminal**. Start with iTerm2 tab color. Expand to tmux and other contexts once the foundation is proven solid.

## What Gets Removed

- `statusline.sh`, `statusline-demo.sh`, `test-demo.sh`, `DEMO-GUIDE.md`
- `hooks/lint-on-save.sh`, `hooks/lint-on-start.sh`
- Commands: `setup.md`, `unsetup.md`, `enable-linting.md`, `disable-linting.md`
- `~/.claude/.peacock-config` concept
- All statusline references in plugin.json

## What Stays

- 13 color management commands (change-color, random-color, peacock-green, darken, lighten, save-favorite, favorite-color, add-recommended, show-current, reset-colors, remove-all-colors)
- `skills/peacock-colors/SKILL.md`
- SessionStart hook (rewritten)

## New File Structure

```
claude-peacock/
├── .claude-plugin/plugin.json
├── commands/              (13 color management commands)
├── hooks/
│   ├── hooks.json         (SessionStart only)
│   └── session-start.sh
├── scripts/
│   ├── color.sh           (hex_to_rgb, read_peacock_color)
│   └── iterm2.sh          (set_tab_color, clear_tab_color)
├── skills/peacock-colors/SKILL.md
├── test/test-colors.sh
└── README.md
```

## hooks.json

```json
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh"
      }]
    }]
  }
}
```

No PostToolUse hooks. No lint hooks.

## Color-Setting Logic

### scripts/color.sh

Shared utilities sourced by hooks and test harness.

- `hex_to_rgb(hex)` — convert `#RRGGBB` to space-separated `R G B`
- `read_peacock_color(project_dir)` — read base color from `$project_dir/.vscode/settings.json`, checking `peacock.color` then `workbench.colorCustomizations["titleBar.activeBackground"]`. Returns hex string or empty.
- `find_project_root(dir)` — walk up from dir looking for `.git`, `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`, `composer.json`, `build.gradle`, `pom.xml`. Returns path or original dir.

Requires `jq` for JSON parsing.

### scripts/iterm2.sh

iTerm2-specific escape sequences.

- `set_iterm2_tab_color(R, G, B)` — emit three OSC 6 sequences to stderr:
  ```
  \033]6;1;bg;red;brightness;R\007
  \033]6;1;bg;green;brightness;G\007
  \033]6;1;bg;blue;brightness;B\007
  ```
- `clear_iterm2_tab_color()` — reset tab to default (empty OSC 6)

### hooks/session-start.sh

The main entry point. Linear flow, no complexity:

1. Check `TERM_PROGRAM == iTerm.app`, exit 0 if not
2. Source `${CLAUDE_PLUGIN_ROOT}/scripts/color.sh`
3. Find project root from `$PWD`
4. Read peacock color from project
5. If no color found, exit 0 silently
6. Convert hex to RGB
7. Source `${CLAUDE_PLUGIN_ROOT}/scripts/iterm2.sh`
8. Set tab color

## Test Harness

`test/test-colors.sh` — runs outside Claude Code to verify:

1. **hex_to_rgb conversion** — known inputs produce correct R G B outputs
2. **read_peacock_color** — reads from a sample `.vscode/settings.json` fixture
3. **find_project_root** — finds root from nested directory
4. **escape sequence output** — captures OSC 6 output to a file, verifies format
5. **iTerm2 detection** — correct behavior when TERM_PROGRAM is/isn't iTerm.app

Test uses sample fixture files, not real project directories.

## Color Commands

The 13 color commands stay as-is. They write to `.vscode/settings.json` which the session-start hook reads. The feedback loop is: change color via command -> next session start picks it up. Commands may also call the iterm2 set function directly for immediate feedback.

Commands will be reviewed via skill-reviewer for alignment with the simplified plugin.

## Future Expansion

Once iTerm2 tab color is proven solid:
- `scripts/tmux.sh` — tmux window/pane/status bar coloring
- `scripts/kitty.sh` — Kitty terminal coloring
- `hooks/session-start.sh` detects environment and calls the right module
- Each module follows the same pattern: detect -> read color -> apply

## plugin.json

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

Version bumped to 2.0.0 — this is a breaking change (statusline removed).
