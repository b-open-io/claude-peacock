# Peacock

> Peacock theme integration for Claude Code

Beautiful, theme-aware statusline for Claude Code that automatically matches your VSCode Peacock colors with 24-bit true color support.

## Features

- 🎨 **Automatic Peacock Detection** - Reads colors from `.vscode/settings.json`
- 🌈 **24-bit True Color** - Exact hex color matching (no ANSI 256 approximations)
- 📁 **Project Awareness** - Shows both CWD (⌂) and last edited project (✎)
- 🔀 **Git Integration** - Branch name with dirty state indicator
- ✓ **Lint Status** - Error/warning counts with theme-matched badge colors
- 🎯 **Smart Text Contrast** - Uses Peacock's foreground colors for perfect readability
- 🔗 **Clickable Paths** - Last edited file as clickable link (Cursor/VSCode/Sublime)
- 📊 **Token Usage** - Real-time token consumption tracking

## Installation

### Via Plugin System

```shell
/plugin marketplace add b-open-io/claude-plugins
/plugin install peacock@b-open-io
```

That's it! The plugin automatically:
- Installs on first session start (SessionStart hook)
- Copies statusline.sh to ~/.claude/
- Configures settings.json
- No manual commands needed!

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
⌂ project-name ▶ ✓ ▶ ⎇ main  ✎ other-project ▶ ✗2 △1 ▶ ⎇ feature*  125k statusline.sh
```

**Segments:**
- `⌂ project-name` - Current working directory (cyan/theme color)
- `✓` or `✗N △M` - Lint status (✓ clean, ✗ errors, △ warnings)
- `⎇ main` - Git branch (clean) or `⎇ feature*` (dirty)
- `✎ other-project` - Last edited project if different (purple/theme color)
- `125k` - Token usage in thousands
- `statusline.sh` - Last edited file (clickable)

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

### Path Detection

Monitors ALL Claude operations to detect current project:
- ✅ Read/Write/Edit - `file_path` parameter
- ✅ Grep - `path` parameter
- ✅ Glob - `pattern` if it contains a path
- ✅ Bash cd - directory changes
- ✅ Any Bash command - with file paths

Uses **most recent** operation to determine active project.

### Color Rendering

- Base color from Peacock
- +40 RGB for medium shade
- +80 RGB for light shade
- Theme's `activityBar.foreground` (#e7e7e7) for main text
- Theme's `activityBarBadge.foreground` (#15202b) for dark text (git branch)
- Theme's `activityBarBadge.background` for lint indicators

## Configuration

**No configuration needed!** The statusline automatically detects:
- **Code directory**: Checks `~/code`, `~/projects`, `~/dev`, `~/workspace`, `~/src` (or falls back to `~`)
- **Editor**: Detects installed editors (`cursor`, `code`, `subl`) for clickable file links

### Optional Environment Variables

Override auto-detection if needed:

```bash
# Custom code directory
export CODE_DIR="$HOME/custom/path"

# Force specific editor scheme
export EDITOR_SCHEME="vscode"  # Options: cursor, vscode, sublime, file
```

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
⌂ sigma-auth ▶ ✓ ▶ ⎇ master  35k app/page.tsx
```
Uses deep magenta (#8d0756) from sigma-auth's Peacock settings

### Multiple Projects

```
⌂ prompts ▶ ✓ ▶ ⎇ master  ✎ go-sdk ▶ ✗1 ▶ ⎇ feature*  89k README.md
```
Working in prompts (cyan), editing go-sdk (project's theme color)

### With Lint Errors

```
⌂ my-app ▶ ✗5 △12 ▶ ⎇ develop*  142k components/Button.tsx
```
5 errors, 12 warnings, uncommitted changes

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

The statusline uses the most recent file operation. If it's wrong:
1. Read a file in the correct project
2. Check that paths are absolute (not relative)

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
