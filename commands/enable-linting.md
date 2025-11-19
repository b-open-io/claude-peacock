---
version: 0.0.1
allowed-tools: Read, Write, AskUserQuestion, Bash(jq:*)
description: Enable automatic linting and select languages
tags: linting, configuration, enable
---

# Enable Automatic Linting

Enable automatic linting on file save with language selection.

**Usage:**
```
/peacock:enable-linting
```

---

<instructions>
Enable automatic linting and configure which languages to lint.

## Step 1: Check Config File

Check if the config file exists:
```bash
test -f ~/.claude/.peacock-config
```

If it doesn't exist, create it with defaults:
```bash
cat > ~/.claude/.peacock-config << 'EOF'
# Peacock configuration
# This file is sourced by statusline.sh and lint hooks

# Editor configuration
EDITOR_SCHEME=""

# Linting configuration
LINT_ENABLED="true"
LINT_TYPESCRIPT="true"
LINT_GO="true"
EOF
```

Then output:
```
✅ Linting enabled for all languages

Linting will now run automatically when you save files.

Languages enabled:
  • TypeScript/JavaScript (via Biome or ESLint)
  • Go (via golangci-lint)

To customize which languages are linted, run /peacock:setup

To disable linting, run /peacock:disable-linting
```

And exit.

## Step 2: Ask User Which Languages

If config file exists, ask which languages to enable:

**Question:**
- header: "Languages"
- question: "Which languages should be linted?"
- multiSelect: true
- options:
  - label: "TypeScript/JavaScript", description: "Lint .ts/.js files using Biome or ESLint"
  - label: "Go", description: "Lint .go files using golangci-lint"

Store the selected values.

## Step 3: Update Config File

Update the config file using sed or awk to modify the LINT_* variables:

```bash
# Enable linting
sed -i.bak 's/^LINT_ENABLED=.*/LINT_ENABLED="true"/' ~/.claude/.peacock-config

# Set TypeScript based on selection
if [[ "$TYPESCRIPT_SELECTED" == "true" ]]; then
  sed -i.bak 's/^LINT_TYPESCRIPT=.*/LINT_TYPESCRIPT="true"/' ~/.claude/.peacock-config
else
  sed -i.bak 's/^LINT_TYPESCRIPT=.*/LINT_TYPESCRIPT="false"/' ~/.claude/.peacock-config
fi

# Set Go based on selection
if [[ "$GO_SELECTED" == "true" ]]; then
  sed -i.bak 's/^LINT_GO=.*/LINT_GO="true"/' ~/.claude/.peacock-config
else
  sed -i.bak 's/^LINT_GO=.*/LINT_GO="false"/' ~/.claude/.peacock-config
fi

# Remove backup file
rm ~/.claude/.peacock-config.bak
```

## Step 4: Confirm Success

Build a list of enabled languages based on selection, then output:

```
✅ Linting enabled

Linting will now run automatically when you save files.

Languages enabled:
$ENABLED_LANGUAGES

To disable linting, run /peacock:disable-linting
```

Where `$ENABLED_LANGUAGES` is:
- If TypeScript selected: "  • TypeScript/JavaScript (via Biome or ESLint)"
- If Go selected: "  • Go (via golangci-lint)"
- If both: show both lines
- If neither: "  (none selected - linting effectively disabled)"

## Error Handling

- If sed fails, show error and suggest manual edit
- Validate that config file is readable after update
</instructions>
