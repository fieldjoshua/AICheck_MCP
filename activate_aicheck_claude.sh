#!/bin/bash

# AICheck Claude Code Activation Script

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
