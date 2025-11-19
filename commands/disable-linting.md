---
version: 0.0.1
allowed-tools: Read, Bash(sed:*)
description: Disable automatic linting
tags: linting, configuration, disable
---

# Disable Automatic Linting

Disable automatic linting on file save.

**Usage:**
```
/peacock:disable-linting
```

---

<instructions>
Disable automatic linting by updating the config file.

## Step 1: Check Config File

Check if the config file exists:
```bash
test -f ~/.claude/.peacock-config
```

If it doesn't exist, output:
```
ℹ️  Linting is not configured

Linting is already disabled (no config file found).

To enable linting, run /peacock:enable-linting
```

And exit.

## Step 2: Update Config File

Update the config file to disable linting:

```bash
sed -i.bak 's/^LINT_ENABLED=.*/LINT_ENABLED="false"/' ~/.claude/.peacock-config
rm ~/.claude/.peacock-config.bak
```

## Step 3: Confirm Success

Output:
```
✅ Linting disabled

Automatic linting has been disabled. Lint hooks will no longer run on file save.

Language-specific settings have been preserved. To re-enable linting, run:
  /peacock:enable-linting

To completely reset Peacock configuration, run:
  /peacock:setup
```

## Error Handling

- If sed fails, show error and suggest manual edit
- Validate that config file is still readable after update
</instructions>
