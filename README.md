# Peacock

> Peacock theme integration for Claude Code

Beautiful, theme-aware statusline for Claude Code that automatically matches your VSCode Peacock colors with 24-bit true color support.

## Features

- 🎨 **Automatic Peacock Detection** - Reads colors from `.vscode/settings.json`
- 🌈 **24-bit True Color** - Exact hex color matching (no ANSI 256 approximations)
- 🎯 **Automatic Project Root Detection** - Walks up directory tree to find `.git`, `package.json`, etc.
- 📁 **Works Everywhere** - No configuration needed for `~/code`, `~/Source`, `~/projects`, or any code directory
- 🏠 **Project Awareness** - Shows both CWD (⌂ project) and working folder (✎ currently editing)
- 🔀 **Git Integration** - Branch name with dirty state indicator
- ✓ **Lint Status** - Error/warning counts with theme-matched badge colors
- 🎨 **Smart Text Contrast** - Uses Peacock's foreground colors for perfect readability
- 🔗 **Clickable Paths** - Last edited file as clickable link (Cursor/VSCode/Sublime)
- 📊 **Token Usage** - Real-time tracking in separate visual segment

## Installation

**Step 1:** Install the plugin

```shell
/plugin marketplace add b-open-io/claude-plugins
/plugin install peacock@b-open-io
```

**Step 2:** Run setup

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

### Setting Project Colors

Manually edit `.vscode/settings.json` in your project:

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

Or use the VSCode Peacock extension to set colors interactively.

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

## License

MIT License - see LICENSE file for details

## Credits

Built by [b-open-io](https://github.com/b-open-io)

Inspired by the [Peacock VSCode extension](https://github.com/johnpapa/vscode-peacock) by John Papa

## See Also

- [Claude Code Documentation](https://docs.claude.ai/code)
- [VSCode Peacock](https://github.com/johnpapa/vscode-peacock)
- [Plugin Development Guide](https://docs.claude.ai/code/plugins)
