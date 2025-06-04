#!/bin/bash

# Quick fix for AICheck permission issues

echo "Fixing AICheck file permissions..."

# Make RULES.md writable
if [ -f ".aicheck/RULES.md" ]; then
    chmod +w .aicheck/RULES.md 2>/dev/null && echo "✓ Fixed RULES.md permissions" || echo "✗ Could not fix RULES.md"
fi

# Fix all .md files in .aicheck
find .aicheck -type f -name "*.md" -exec chmod +w {} \; 2>/dev/null && echo "✓ Fixed all .aicheck/*.md files" || true

# Fix MCP files
find .mcp -type f -exec chmod +w {} \; 2>/dev/null && echo "✓ Fixed all .mcp files" || true

# Make aicheck executable
chmod +x aicheck 2>/dev/null && echo "✓ Made aicheck executable" || true

echo ""
echo "Permissions fixed! Now run the installer:"
echo "bash <(curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/install.sh)"