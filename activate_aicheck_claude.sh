#!/bin/bash

# AICheck Claude Code Activation Script

# Check if MCP server is configured
if [ -d ".mcp/server" ] && [ ! -d ".mcp/server/node_modules" ]; then
    echo "Setting up MCP server..."
    cd .mcp/server && npm install && cd ../..
fi

# Show MCP configuration help
echo "📌 MCP Configuration for Claude Code:"
echo "===================================="
echo "Add this to your Claude Code settings:"
echo ""
echo '  "mcpServers": {'
echo '    "aicheck": {'
echo '      "command": "node",'
echo "      \"args\": [\"${PWD}/.mcp/server/index.js\"],"
echo '      "transport": "stdio"'
echo '    }'
echo '  }'
echo ""
echo "===================================="
echo ""

PROMPT="I'm working on a project with AICheck governance. Please acknowledge that you understand the AICheck system and are ready to follow the rules in .aicheck/RULES.md. Check the current action with ./aicheck status and help me implement according to the active action plan. Use AICheck's focus management features to maintain boundaries and prevent scope creep."

echo "AICheck Activation Prompt:"
echo "=========================="
echo "$PROMPT"
echo ""
echo "Copy the text above and paste it into Claude Code to activate AICheck integration."

# Try to copy to clipboard
if command -v pbcopy >/dev/null 2>&1; then
    echo "$PROMPT" | pbcopy
    echo "✓ Prompt copied to clipboard (macOS)"
elif command -v xclip >/dev/null 2>&1; then
    echo "$PROMPT" | xclip -selection clipboard
    echo "✓ Prompt copied to clipboard (Linux)"
elif command -v clip.exe >/dev/null 2>&1; then
    echo "$PROMPT" | clip.exe
    echo "✓ Prompt copied to clipboard (Windows)"
else
    echo "⚠ Could not copy to clipboard - please copy the text above manually"
fi
