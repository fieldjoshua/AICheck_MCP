#!/bin/bash

# AICheck v4.3.0 Universal Installer
# One installer to rule them all

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}AICheck v4.3.0 Installation${NC}"
echo "============================"

# Create directory structure
echo -e "${BLUE}Creating directory structure...${NC}"
mkdir -p .aicheck/actions
mkdir -p .aicheck/templates/claude
mkdir -p .mcp/server
mkdir -p documentation/dependencies
mkdir -p tests

# Download core files
echo -e "${BLUE}Downloading AICheck...${NC}"

# Download aicheck command
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/aicheck > aicheck || {
    echo -e "${RED}Failed to download aicheck${NC}"
    exit 1
}
chmod +x aicheck

# Download RULES.md
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/RULES.md > .aicheck/RULES.md || {
    echo -e "${RED}Failed to download RULES.md${NC}"
    exit 1
}

# Download MCP server
echo -e "${BLUE}Setting up MCP server...${NC}"
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/index.js > .mcp/server/index.js
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/package.json > .mcp/server/package.json
chmod +x .mcp/server/index.js

# Download templates
echo -e "${BLUE}Downloading templates...${NC}"
for template in auto-surgical-fix research-plan-implement auto-tdd-cycle cost-efficient-development; do
    curl -sSL "https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/templates/claude/${template}.md" > ".aicheck/templates/claude/${template}.md" 2>/dev/null || true
done

# Create initial files
echo "None" > .aicheck/current_action

cat > .aicheck/actions_index.md << 'EOF'
# Actions Index

*Last Updated: $(date +"%Y-%m-%d")*

## Active Actions

| Action | Author | Status | Progress | Notes |
|--------|--------|--------|----------|-------|
| *None yet* | | | | |

## Completed Actions  

| Action | Author | Completed | Notes |
|--------|--------|-----------|-------|
| *None yet* | | | |
EOF

cat > documentation/dependencies/dependency_index.md << 'EOF'
# Dependency Index

This document tracks all dependencies in the PROJECT.

## External Dependencies

| Dependency | Version | Added By | Date Added | Justification | Actions Using |
|------------|---------|----------|------------|---------------|---------------|
| *None yet* | | | | | |

## Internal Dependencies

| Dependency Action | Dependent Action | Type | Date Added | Description |
|-------------------|------------------|------|------------|-------------|
| *None yet* | | | | |

---
*Last Updated: $(date +"%Y-%m-%d")*
EOF

# Install MCP dependencies if npm is available
if command -v npm >/dev/null 2>&1; then
    echo -e "${BLUE}Installing MCP dependencies...${NC}"
    cd .mcp/server && npm install --silent && cd ../..
    echo -e "${GREEN}✓ MCP server ready${NC}"
else
    echo -e "${YELLOW}⚠ npm not found - run 'cd .mcp/server && npm install' later${NC}"
fi

# Create activation script
cat > activate_aicheck_claude.sh << 'EOF'
#!/bin/bash
PROMPT="I'm working on a project with AICheck governance. Please acknowledge that you understand the AICheck system and are ready to follow the rules in .aicheck/RULES.md. Check the current action with ./aicheck status and help me implement according to the active action plan."

echo "$PROMPT"
echo ""
echo "Copy the text above and paste it into Claude Code to activate AICheck."

# Try to copy to clipboard
if command -v pbcopy >/dev/null 2>&1; then
    echo "$PROMPT" | pbcopy
    echo "✓ Copied to clipboard"
elif command -v xclip >/dev/null 2>&1; then
    echo "$PROMPT" | xclip -selection clipboard
    echo "✓ Copied to clipboard"
fi
EOF
chmod +x activate_aicheck_claude.sh

# Test installation
echo -e "\n${BLUE}Testing installation...${NC}"
if ./aicheck version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ AICheck installed successfully!${NC}"
else
    echo -e "${RED}✗ Installation test failed${NC}"
    exit 1
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "\n${BLUE}Next steps:${NC}"
echo "1. Run: ./activate_aicheck_claude.sh"
echo "2. Paste the prompt into Claude Code"
echo "3. Start with: ./aicheck stuck"
echo -e "\n${BLUE}Key commands:${NC}"
echo "• ./aicheck stuck - Check status and get unstuck"
echo "• ./aicheck focus - Check boundaries before work"
echo "• ./aicheck cleanup - Clean up after work"
echo "• ./aicheck usage - Check costs and optimization"