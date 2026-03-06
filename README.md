# Peacock

> Project color theming for your terminal

A Claude Code plugin that brings your VSCode Peacock project colors into the terminal. Start Claude Code in a project with a Peacock color configured and your iTerm2 tab automatically turns that color. Manage project colors entirely from the command line without opening VSCode.

## Features

- **iTerm2 Tab Colors** - Tab color automatically matches your project's Peacock theme
- **Peacock Color Detection** - Reads colors from `.vscode/settings.json`
- **11 Color Commands** - Full color management without leaving the terminal
- **Natural Language Colors** - Set colors by name ("dark forest green") or hex code
- **Favorites System** - Save and reuse colors across projects
- **Terminal Title** - Sets terminal title to current project name

## Installation

### Via Claude Code Marketplace

```bash
/plugin marketplace add b-open-io/claude-plugins
/plugin install peacock@b-open-io
```

### Via Skills (Cross-Platform)

Works with Claude Code, Cursor, Codex, and other AI coding agents:

```bash
npx add-skill b-open-io/claude-peacock
```

### Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/b-open-io/claude-peacock.git
   ```

2. Install as a local plugin in Claude Code.

## Commands

### Setting Colors

| Command | Description |
|---------|-------------|
| `/peacock:change-color [color]` | Set color by hex, natural language, or random if no argument |
| `/peacock:random-color` | Apply a random vibrant color |
| `/peacock:peacock-green` | Apply signature Peacock Green (#42b883) |

```bash
/peacock:change-color #8d0756         # Hex code
/peacock:change-color deep magenta    # Natural language
/peacock:change-color                 # Random
/peacock:random-color                 # Quick random
/peacock:peacock-green                # Signature green
```

### Adjusting Colors

| Command | Description |
|---------|-------------|
| `/peacock:darken` | Darken current color by 10% |
| `/peacock:lighten` | Lighten current color by 10% |

### Managing Favorites

| Command | Description |
|---------|-------------|
| `/peacock:save-favorite [name]` | Save current color to favorites |
| `/peacock:favorite-color` | Apply a color from your favorites |
| `/peacock:add-recommended` | Add 14 curated colors (Angular Red, React Blue, Vue Green, etc.) |

Favorites are stored in `~/.claude/.peacock-favorites.json` and shared across all projects.

### Viewing and Resetting

| Command | Description |
|---------|-------------|
| `/peacock:show-current` | Display current color info |
| `/peacock:reset-colors` | Remove Peacock colors from the current project |
| `/peacock:remove-all-colors` | Remove all colors, favorites, and config |

## How It Works

1. Reads `.vscode/settings.json` in your project directory
2. Extracts `peacock.color` or `titleBar.activeBackground`
3. Sends the color to iTerm2 via proprietary OSC escape sequences
4. Sets terminal title to the project name

When you run a color command, it writes the color back to `.vscode/settings.json` so it stays in sync with VSCode Peacock.

### VSCode Settings

The plugin reads and writes these properties:

```json
{
  "peacock.color": "#8d0756",
  "workbench.colorCustomizations": {
    "titleBar.activeBackground": "#8d0756"
  }
}
```

## Troubleshooting

### Tab color not appearing

1. Confirm you are using iTerm2. Other terminals ignore the escape sequences silently.
2. Check that `.vscode/settings.json` exists in your project with a `peacock.color` value.
3. Try setting a color manually to verify the pipeline works:
   ```bash
   /peacock:change-color #ff5733
   ```

### Color not matching VSCode

1. Run `/peacock:show-current` to see what color the plugin detects.
2. Verify `peacock.color` in `.vscode/settings.json` matches what you expect.

## Future Plans

iTerm2 is the primary supported terminal today. Future versions may add support for:

- **tmux** - Pane/window color theming
- **kitty** - Tab and window color theming

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
      </a>
    </td>
  </tr>
</table>
<!-- ALL-CONTRIBUTORS-LIST:END -->

## License

MIT License - see LICENSE file for details.

## Credits

Built by [b-open-io](https://github.com/b-open-io)

Inspired by the [Peacock VSCode extension](https://github.com/johnpapa/vscode-peacock) by John Papa
