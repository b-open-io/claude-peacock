# Peacock

> Complete Claude Code workspace integration

A comprehensive Claude Code plugin that brings together visual theming, automatic linting, and intelligent project management. Matches your VSCode Peacock colors with 24-bit true color support, sets terminal titles and iTerm2 tab colors, runs linting automatically, and keeps you informed with real-time project status.

## Features

- 🎨 **Automatic Peacock Detection** - Reads colors from `.vscode/settings.json`
- 🌈 **24-bit True Color** - Exact hex color matching (no ANSI 256 approximations)
- 🎯 **Automatic Project Root Detection** - Walks up directory tree to find `.git`, `package.json`, etc.
- 📁 **Works Everywhere** - No configuration needed for `~/code`, `~/Source`, `~/projects`, or any code directory
- 🏠 **Project Awareness** - Shows both CWD (⌂ project) and working folder (✎ currently editing)
- 🔀 **Git Integration** - Branch name with dirty state indicator
- ✓ **Automatic Linting** - Runs lint on save and displays error/warning counts (TypeScript/JavaScript via Biome/ESLint, Go via golangci-lint)
- 🎨 **Smart Text Contrast** - Uses Peacock's foreground colors for perfect readability
- 🔗 **Clickable Paths** - Last edited file as clickable link (Cursor/VSCode/Sublime)
- 📊 **Token Usage** - Real-time tracking in separate visual segment
- 🪟 **Terminal Title** - Automatically sets terminal title to current project name(s)
- 🎨 **iTerm2 Tab Colors** - Matches tab color to your Peacock theme (iTerm2 only)

## Installation

Works with Claude Code, Cursor, Codex, and other AI coding agents:

```bash
npx add-skill b-open-io/claude-peacock
```

Or via Claude Code marketplace:

```bash
/plugin marketplace add b-open-io/claude-plugins
/plugin install peacock@b-open-io
```

**After installing:** Run setup

```shell
/peacock:setup
```

**Step 3:** Restart Claude Code

That's it! Your statusline will now show with Peacock theme colors.

## Uninstallation

**Step 1:** Remove configuration

```shell
/peacock:unsetup
```

**Step 2:** Uninstall plugin

```shell
/plugin
# Select peacock and uninstall
```

Simple, explicit, no surprises.

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/b-open-io/claude-peacock.git
   ```

2. Copy the statusline script:
   ```bash
   cp claude-peacock/statusline.sh ~/.claude/statusline.sh
   chmod +x ~/.claude/statusline.sh
   ```

3. Add to your `~/.claude/settings.json`:
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "~/.claude/statusline.sh"
     }
   }
   ```

4. Restart Claude Code

## Usage

### Statusline

The statusline activates automatically and shows:

```
⌂ project-name ▶ ✓ ▶ ⎇ main  ✎ other-project ▶ ✗2 △1 ▶ ⎇ feature*  [125k] statusline.sh
```

**Segments:**
- `⌂ project-name` - Project where Claude started (cyan/theme color)
- `✓` or `✗N △M` - Lint status (✓ clean, ✗ errors, △ warnings)
- `⎇ main` - Git branch (clean) or `⎇ feature*` (dirty)
- `✎ other-project` - Working folder currently editing if different (purple/theme color)
- `[125k]` - Token usage in separate dark gray box
- `statusline.sh` - Last edited file (clickable, relative to project root)

### Color Management Commands

Complete command suite matching the [VSCode Peacock extension](https://github.com/johnpapa/vscode-peacock) API:

#### Setting Colors

| Command | Description |
|---------|-------------|
| `/peacock:change-color [color]` | Set color (hex, natural language, or random if no arg) |
| `/peacock:random-color` | Quick random vibrant color |
| `/peacock:peacock-green` | Apply signature Peacock Green (#42b883) |

**Examples:**
```bash
/peacock:change-color #8d0756         # Hex code
/peacock:change-color deep magenta    # Natural language
/peacock:change-color                 # Random vibrant
/peacock:random-color                 # Quick random
/peacock:peacock-green                # Signature color
```

#### Adjusting Colors

| Command | Description |
|---------|-------------|
| `/peacock:lighten` | Lighten current color by 10% |
| `/peacock:darken` | Darken current color by 10% |

**Examples:**
```bash
/peacock:lighten    # Make current color lighter
/peacock:darken     # Make current color darker
```

#### Managing Favorites

| Command | Description |
|---------|-------------|
| `/peacock:save-favorite [name]` | Save current color to favorites |
| `/peacock:favorite-color` | Apply color from favorites (interactive) |
| `/peacock:add-recommended` | Add 14 curated colors to favorites |

**Examples:**
```bash
/peacock:save-favorite magenta theme  # Save with custom name
/peacock:favorite-color               # Pick from favorites
/peacock:add-recommended              # Add Angular, React, Vue, etc.
```

Favorites stored in `~/.claude/.peacock-favorites.json` - syncs across all projects.

**Recommended Colors Include:**
Angular Red, Azure Blue, JavaScript Yellow, Gatsby Purple, Go Cyan, Java Orange, Node Green, Peacock Green, Python Blue, React Blue, Ruby Red, TypeScript Blue, Rust Orange, Vue Green

#### Viewing & Resetting

| Command | Description |
|---------|-------------|
| `/peacock:show-current` | Display current color and copy to clipboard |
| `/peacock:reset-colors` | Remove Peacock customizations from project |
| `/peacock:remove-all-colors` | Complete removal (project + favorites + config) |

**Examples:**
```bash
/peacock:show-current       # See what's applied
/peacock:reset-colors       # Remove project colors
/peacock:remove-all-colors  # Nuclear option
```

### Natural Language Color Support

**Vibrant:** red, orange, yellow, green, teal, cyan, blue, purple, magenta
**Dark:** dark red, forest green, navy, indigo, dark magenta
**Light:** pink, peach, mint, sky blue, lavender

**Examples:**
```bash
/peacock:change-color vibrant ocean blue
/peacock:change-color dark forest green
/peacock:change-color light purple
```

### Linting Configuration

The plugin includes automatic linting with configurable language support. During setup, you choose which languages to lint:

| Command | Description |
|---------|-------------|
| `/peacock:enable-linting` | Enable linting and select languages |
| `/peacock:disable-linting` | Disable automatic linting |

**Supported Languages:**
- **TypeScript/JavaScript** - Uses Biome or ESLint (auto-detects from package.json)
- **Go** - Uses golangci-lint (must be installed separately)

**Configuration:**
Linting preferences are stored in `~/.claude/.peacock-config`:
```bash
LINT_ENABLED="true"        # Master switch
LINT_TYPESCRIPT="true"     # Enable TS/JS linting
LINT_GO="true"            # Enable Go linting
```

**How it works:**
- Runs automatically on file save (60-second cooldown)
- Runs on session start for immediate feedback
- Stores results in `~/.claude/lint-state/{project}.json`
- Displays error/warning counts in statusline

## How It Works

### Color Detection

1. Reads `.vscode/settings.json` in project directory
2. Extracts `peacock.color` or `titleBar.activeBackground`
3. Loads theme text colors (`activityBar.foreground`, `activityBarBadge.foreground`)
4. Uses complementary badge colors for lint indicators
5. Falls back to default cyan/purple if no theme found

### Project Root Detection

**Automatic detection** - No configuration needed! The statusline:

1. **Monitors ALL Claude operations** to detect files being edited:
   - ✅ Read/Write/Edit - `file_path` parameter
   - ✅ Grep - `path` parameter
   - ✅ Glob - `pattern` if it contains a path
   - ✅ Bash cd - directory changes
   - ✅ Any Bash command - with file paths

2. **Walks up directory tree** from detected file to find project root:
   - Looks for `.git/` directory
   - Looks for `package.json`, `go.mod`, `Cargo.toml`, `pyproject.toml`
   - Looks for `composer.json`, `build.gradle`, `pom.xml`

3. **Shows correct project name** even for deeply nested files:
   - File: `~/code/my-app/src/components/ui/Button.tsx`
   - Shows: `my-app` (not `ui` or `components`)

4. **Works with any code directory structure**:
   - `~/code/` - Standard location
   - `~/Source/` - macOS/Apple convention
   - `~/projects/`, `~/dev/`, `~/workspace/` - Alternative locations
   - Nested projects like `~/code/clients/acme/website` work perfectly

Uses **most recent** operation to determine active working folder.

### Color Rendering

- Base color from Peacock
- +40 RGB for medium shade
- +80 RGB for light shade
- Theme's `activityBar.foreground` (#e7e7e7) for main text
- Theme's `activityBarBadge.foreground` (#15202b) for dark text (git branch)
- Theme's `activityBarBadge.background` for lint indicators

### Automatic Linting

The plugin includes hooks that automatically run linting:

**On Save (PostToolUse hook):**
- Triggers after Edit/Write operations
- Runs appropriate linter for project type
- Stores error/warning counts in `~/.claude/lint-state/`
- 60-second cooldown to avoid excessive runs

**On Session Start:**
- Runs linting when Claude Code starts
- Updates statusline with current project status

**Supported Linters:**
- **TypeScript/JavaScript**: Looks for `lint` or `lint:fix` scripts in `package.json`, runs with `bun`
- **Go**: Uses `golangci-lint run` if installed

The hooks are automatically installed via the plugin system - no manual setup needed!

### Terminal Title Management

The statusline automatically sets your terminal window title to show which project(s) you're working on:

**Single Project:**
- Terminal title: `my-project`
- Shows the project you're currently working in

**Multiple Projects:**
- Terminal title: `main-project | editing-project`
- Left side: Project where Claude started (CWD)
- Right side: Project you're currently editing

**How It Works:**
- Uses ANSI OSC 0 escape sequence (`\033]0;TITLE\007`)
- Updates automatically as you work across projects
- Compatible with most modern terminals (iTerm2, Terminal.app, Warp, etc.)
- Helps identify Claude sessions when running multiple instances

This makes it easy to distinguish between multiple Claude Code windows at a glance!

### iTerm2 Tab Color Integration

**iTerm2 users get an extra bonus feature** - the tab color automatically matches your Peacock theme!

**How It Works:**
- Uses iTerm2's proprietary OSC 6 escape sequences
- Sets tab background color to your CWD project's Peacock color
- Updates automatically as you switch projects
- Only activates if:
  1. You're using iTerm2 (other terminals ignore the sequence)
  2. Your project has a Peacock color configured

**Visual Example:**
```
Project A (Peacock color: #8d0756) → iTerm2 tab turns deep magenta
Project B (Peacock color: #007acc) → iTerm2 tab turns blue
```

**Configuration:**
- Zero setup required!
- Works automatically if you have `.vscode/settings.json` with Peacock colors
- Falls back gracefully on other terminals (no errors, just no tab color)

This feature is particularly useful when running multiple Claude Code sessions - each project gets its own color-coded tab!

## Configuration

**Zero configuration required!** The statusline automatically:

- **Finds project roots** - Walks up directory tree to find `.git`, `package.json`, etc.
- **Works anywhere** - `~/code`, `~/Source`, `~/projects`, or any nested structure
- **Detects editor** - Auto-detects `cursor`, `vscode`, or `sublime` for clickable file links

### Optional Configuration

Override auto-detection only if needed (set during `/peacock:setup`):

**Editor scheme** - Saved to `~/.claude/.peacock-config`:
```bash
# Force specific editor (optional)
EDITOR_SCHEME="vscode"  # Options: cursor, vscode, sublime, file
```

**Note:** If you don't create a config file, the statusline auto-detects everything!

### VSCode Settings Structure

The statusline reads these Peacock properties:

```json
{
  "peacock.color": "#8d0756",
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#8d0756",
    "activityBar.foreground": "#e7e7e7",
    "activityBarBadge.foreground": "#15202b",
    "activityBarBadge.background": "#6fb709"
  }
}
```

## Requirements

- Claude Code (latest version)
- `jq` command-line JSON processor
  ```bash
  brew install jq  # macOS
  apt install jq   # Ubuntu/Debian
  ```
- Terminal with 24-bit true color support (most modern terminals)

## Examples

### Project with Peacock Theme

```
⌂ sigma-auth ▶ ✓ ▶ ⎇ master  [35k] app/page.tsx
```
Uses deep magenta (#8d0756) from sigma-auth's Peacock settings, token usage in gray box

### Multiple Projects

```
⌂ prompts ▶ ✓ ▶ ⎇ master  ✎ go-sdk ▶ ✗1 ▶ ⎇ feature*  [89k] README.md
```
Working in prompts (cyan), editing go-sdk (project's theme color), separate token segment

### With Lint Errors

```
⌂ my-app ▶ ✗5 △12 ▶ ⎇ develop*  [142k] components/Button.tsx
```
5 errors, 12 warnings, uncommitted changes, clean visual separation

### Nested Project (Auto-detected Root)

```
⌂ website ▶ ✓ ▶ ⎇ main  [67k] src/components/ui/Button.tsx
```
File deep in `~/code/clients/acme/website/src/components/ui/Button.tsx`
Shows "website" as project root (found via `.git`), not "ui" or "components"

### ~/Source User (Zero Config)

```
⌂ my-project ▶ ✓ ▶ ⎇ main  [45k] index.ts
```
Works automatically even with code in `~/Source/my-project` instead of `~/code`

## Troubleshooting

### Statusline not showing colors

1. Check if your terminal supports 24-bit color:
   ```bash
   printf "\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n"
   ```
   Should show "TRUECOLOR" in orange

2. Verify jq is installed:
   ```bash
   jq --version
   ```

### Colors don't match VSCode

1. Check `.vscode/settings.json` exists in project
2. Verify Peacock properties are set
3. Try `/project-color #hexcode` to set manually

### Statusline shows wrong project

The statusline uses the most recent file operation and walks up to find the project root. If it's wrong:
1. Make sure the project has a root marker (`.git`, `package.json`, `go.mod`, etc.)
2. Read or edit a file in the correct project
3. Check that project root detection is working: files deep in subdirectories should still show the correct project name

**Example:** Editing `~/code/my-app/src/utils/helper.ts` should show "my-app", not "utils"

## Development

### Project Structure

```
claude-peacock/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── commands/
│   ├── peacock-setup.md      # Installation command
│   └── project-color.md      # Color setter command
├── statusline.sh             # Main statusline script
└── README.md
```

### Testing Locally

```bash
# Create test marketplace
mkdir -p ~/test-marketplace/.claude-plugin
cd ~/test-marketplace

# Create marketplace.json
cat > .claude-plugin/marketplace.json << 'EOF'
{
  "name": "test",
  "owner": { "name": "Test" },
  "plugins": [{
    "name": "claude-peacock",
    "source": "/Users/satchmo/code/claude-peacock",
    "description": "Testing local plugin"
  }]
}
EOF

# In Claude Code
/plugin marketplace add ~/test-marketplace
/plugin install claude-peacock@test
/peacock-setup
```

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test your changes locally
4. Submit a pull request

## Contributors

Thanks to these wonderful people for their contributions:

<!-- ALL-CONTRIBUTORS-LIST:START -->
<table>
  <tr>
    <td align="center">
      <a href="https://github.com/b-open-io">
        <img src="https://github.com/b-open-io.png" width="100px;" alt="b-open-io"/><br />
        <sub><b>b-open-io</b></sub>
      </a><br />
      💻 📖 🎨
    </td>
  </tr>
</table>
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification.

## License

MIT License - see LICENSE file for details

## Credits

Built by [b-open-io](https://github.com/b-open-io)

Inspired by the [Peacock VSCode extension](https://github.com/johnpapa/vscode-peacock) by John Papa

## See Also

- [Claude Code Documentation](https://docs.claude.ai/code)
- [VSCode Peacock](https://github.com/johnpapa/vscode-peacock)
- [Plugin Development Guide](https://docs.claude.ai/code/plugins)
