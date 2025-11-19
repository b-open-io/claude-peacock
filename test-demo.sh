#!/bin/bash
# Test the demo statusline with different scenarios

DEMO_SCRIPT="/Users/satchmo/code/claude-peacock/statusline-demo.sh"

echo "Testing Peacock Statusline Demo"
echo "================================"
echo ""

# Scenario 1: Simple case - current directory
echo "Scenario 1: Working in claude-peacock project"
echo "   File: /Users/satchmo/code/claude-peacock/README.md"
echo ""
cat <<EOF | $DEMO_SCRIPT
{
  "cwd": "/Users/satchmo/code/claude-peacock",
  "transcript_path": "/tmp/test-transcript.json"
}
EOF
echo ""
echo ""

# Create a test transcript for scenarios 2-4
cat > /tmp/test-transcript.json <<'TRANSCRIPT'
{"role":"user","content":"test"}
{"role":"assistant","content":[{"type":"tool_use","name":"Read","input":{"file_path":"/Users/satchmo/code/claude-peacock/commands/setup.md"}}],"usage":{"input_tokens":45000,"output_tokens":3500}}
TRANSCRIPT

# Scenario 2: With token usage
echo "Scenario 2: With token usage (48.5k tokens)"
echo "   File: /Users/satchmo/code/claude-peacock/commands/setup.md"
echo ""
cat <<EOF | $DEMO_SCRIPT
{
  "cwd": "/Users/satchmo/code/claude-peacock",
  "transcript_path": "/tmp/test-transcript.json"
}
EOF
echo ""
echo ""

# Scenario 3: Nested project - file deep in directory
cat > /tmp/test-transcript-nested.json <<'TRANSCRIPT'
{"role":"user","content":"test"}
{"role":"assistant","content":[{"type":"tool_use","name":"Read","input":{"file_path":"/Users/satchmo/code/claude-peacock/commands/integrations/stripe/config.ts"}}],"usage":{"input_tokens":89000,"output_tokens":5000}}
TRANSCRIPT

echo "Scenario 3: Deep nested file (project root detection)"
echo "   CWD: /Users/satchmo/code/claude-peacock"
echo "   File: /Users/satchmo/code/claude-peacock/commands/integrations/stripe/config.ts"
echo "   (Should show 'claude-peacock' as project, not 'stripe')"
echo ""
cat <<EOF | $DEMO_SCRIPT
{
  "cwd": "/Users/satchmo/code/claude-peacock",
  "transcript_path": "/tmp/test-transcript-nested.json"
}
EOF
echo ""
echo ""

# Scenario 4: Different project in workspace
mkdir -p /tmp/test-workspace/my-project
cat > /tmp/test-workspace/my-project/package.json <<'PKG'
{"name":"my-project","version":"1.0.0"}
PKG

cat > /tmp/test-transcript-diff.json <<'TRANSCRIPT'
{"role":"user","content":"test"}
{"role":"assistant","content":[{"type":"tool_use","name":"Edit","input":{"file_path":"/tmp/test-workspace/my-project/src/components/Button.tsx"}}],"usage":{"input_tokens":125000,"output_tokens":8000}}
TRANSCRIPT

echo "Scenario 4: Working in different project (shows both)"
echo "   CWD (⌂ project): /Users/satchmo/code/claude-peacock"
echo "   Edited (✎ working folder): /tmp/test-workspace/my-project/src/components/Button.tsx"
echo "   (Should show both projects with different colors)"
echo ""
cat <<EOF | $DEMO_SCRIPT
{
  "cwd": "/Users/satchmo/code/claude-peacock",
  "transcript_path": "/tmp/test-transcript-diff.json"
}
EOF
echo ""
echo ""

# Scenario 5: ~/Source instead of ~/code
mkdir -p ~/Source/test-project
cat > ~/Source/test-project/package.json <<'PKG'
{"name":"test-project","version":"1.0.0"}
PKG

cat > /tmp/test-transcript-source.json <<'TRANSCRIPT'
{"role":"user","content":"test"}
{"role":"assistant","content":[{"type":"tool_use","name":"Read","input":{"file_path":"~/Source/test-project/index.ts"}}],"usage":{"input_tokens":67000,"output_tokens":4200}}
TRANSCRIPT

echo "Scenario 5: User with ~/Source directory (not ~/code)"
echo "   CWD: ~/Source/test-project"
echo "   File: ~/Source/test-project/index.ts"
echo "   (Should work without CODE_DIR config)"
echo ""
cat <<EOF | $DEMO_SCRIPT
{
  "cwd": "$HOME/Source/test-project",
  "transcript_path": "/tmp/test-transcript-source.json"
}
EOF
echo ""
echo ""

echo "================================"
echo "Demo complete!"
echo ""
echo "Key improvements demonstrated:"
echo "  ✓ Project root detection (walks up to find .git, package.json, etc.)"
echo "  ✓ Token usage in separate gray box (no powerline bleed)"
echo "  ✓ Works with any code directory (~/code, ~/Source, ~/projects)"
echo "  ✓ Nested files show correct project root"
echo "  ✓ Clear distinction: ⌂ = project (CWD), ✎ = working folder (editing)"
echo ""
echo "To test in your actual Claude Code session:"
echo "  1. Copy statusline-demo.sh to ~/.claude/statusline.sh"
echo "  2. Restart Claude Code"
echo "  3. Work in different projects and see it adapt automatically"

# Cleanup
rm -f /tmp/test-transcript*.json
