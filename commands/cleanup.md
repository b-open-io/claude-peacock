---
version: 0.0.1
allowed-tools: Read, Write, Edit
description: Remove Peacock statusline configuration from settings.json
tags: cleanup, uninstall, settings
---

# Peacock Cleanup

Remove Peacock statusline configuration from your Claude Code settings.

**When to use:** Before uninstalling the Peacock plugin, run this command to clean up settings.json.

## Usage

```
/peacock:cleanup
```

---

<instructions>
Remove the Peacock statusline configuration from settings.json.

## Step 1: Read Current Settings

Use Read tool to load `~/.claude/settings.json`.

If the file doesn't exist, output:
```
ℹ️  No settings.json found - nothing to clean up.
```

## Step 2: Check for Peacock Statusline

Check if settings.json contains a statusLine configuration pointing to peacock:
- Look for `statusLine.command` containing "peacock" or "peacock/statusline.sh"

If NOT found, output:
```
ℹ️  No Peacock statusline configuration found in settings.json.
Nothing to clean up.
```

## Step 3: Remove Statusline Configuration

If Peacock statusline IS found, remove the entire `statusLine` object from settings.json.

Use Edit tool to update the file, removing the `statusLine` key while preserving all other settings.

## Step 4: Confirm Success

Output:
```
✅ Peacock statusline configuration removed from settings.json

The statusline will no longer appear after restarting Claude Code.

To re-enable, reinstall the plugin:
  /plugin install peacock@b-open-io
```

## Important Notes

- This only removes the statusline configuration
- Other settings are preserved
- You can safely run this multiple times
- Required before uninstalling the plugin to avoid orphaned config
</instructions>
