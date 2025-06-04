#!/bin/bash

# Quick AICheck v4.1.0 Installation
# Simplified installer for immediate deployment

set -e

# Colors
GREEN='\033[0;32m'
BRIGHT_BLURPLE='\033[38;5;135m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BRIGHT_BLURPLE}Quick AICheck v4.1.0 Installation${NC}"
echo -e "=================================="

# Step 1: Create directory structure
echo -e "${BRIGHT_BLURPLE}Creating directory structure...${NC}"
mkdir -p .aicheck/actions
mkdir -p .aicheck/templates/claude
mkdir -p .mcp/server
mkdir -p documentation/dependencies
mkdir -p tests

# Step 2: Download core files
echo -e "${BRIGHT_BLURPLE}Downloading core files...${NC}"

# Download RULES.md
echo -e "Downloading RULES.md..."
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/RULES.md > .aicheck/RULES.md || {
    echo -e "${RED}Failed to download RULES.md${NC}"
    exit 1
}

# Download aicheck command
echo -e "Downloading aicheck command..."
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/aicheck > aicheck || {
    echo -e "${RED}Failed to download aicheck command${NC}"
    exit 1
}
chmod +x aicheck

# Download MCP server
echo -e "Downloading MCP server..."
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/index.js > .mcp/server/index.js || {
    echo -e "${RED}Failed to download MCP server${NC}"
    exit 1
}
chmod +x .mcp/server/index.js

# Download MCP package.json
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/package.json > .mcp/server/package.json || {
    echo -e "${RED}Failed to download MCP package.json${NC}"
    exit 1
}

# Download templates
echo -e "Downloading templates..."
mkdir -p .aicheck/templates/claude
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/templates/claude/auto-surgical-fix.md > .aicheck/templates/claude/auto-surgical-fix.md
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/templates/claude/research-plan-implement.md > .aicheck/templates/claude/research-plan-implement.md
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/templates/claude/auto-tdd-cycle.md > .aicheck/templates/claude/auto-tdd-cycle.md
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/templates/claude/cost-efficient-development.md > .aicheck/templates/claude/cost-efficient-development.md

# Step 3: Create basic files
echo -e "${BRIGHT_BLURPLE}Creating initial files...${NC}"

# Create current_action file
echo "None" > .aicheck/current_action

# Create actions_index.md
cat > .aicheck/actions_index.md << 'EOL'
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

EOL

# Create dependency index
mkdir -p documentation/dependencies
cat > documentation/dependencies/dependency_index.md << 'EODEP'
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
EODEP

# Step 4: Set up MCP server
echo -e "${BRIGHT_BLURPLE}Setting up MCP server...${NC}"
cd .mcp/server
if command -v npm >/dev/null 2>&1; then
    echo -e "Installing MCP dependencies..."
    npm install
    echo -e "${GREEN}✓ MCP dependencies installed${NC}"
else
    echo -e "${YELLOW}⚠ npm not found - MCP server dependencies not installed${NC}"
    echo -e "${YELLOW}  Install Node.js and run: cd .mcp/server && npm install${NC}"
fi
cd ../..

# Step 5: Create activation script
cat > activate_aicheck_claude.sh << 'EOACT'
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
EOACT

chmod +x activate_aicheck_claude.sh

# Step 6: Final setup
echo -e "${BRIGHT_BLURPLE}Final setup...${NC}"

# Test aicheck command
echo -e "Testing aicheck command..."
if ./aicheck version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ AICheck command working${NC}"
else
    echo -e "${YELLOW}⚠ AICheck command test failed${NC}"
fi

echo -e "\n${GREEN}✓ Quick installation completed!${NC}"
echo -e "\n${BRIGHT_BLURPLE}Next Steps:${NC}"
echo -e "1. Install MCP dependencies: ${YELLOW}cd .mcp/server && npm install${NC}"
echo -e "2. Activate AICheck: ${YELLOW}./activate_aicheck_claude.sh${NC}"
echo -e "3. Start Claude Code and paste the activation prompt"
echo -e "4. Test with: ${YELLOW}./aicheck status${NC}"

echo -e "\n${BRIGHT_BLURPLE}New v4.1.0 Features Available:${NC}"
echo -e "${GREEN}✓ Focus Management: ${YELLOW}./aicheck context clear|compact|check|pollution${NC}"
echo -e "${GREEN}✓ Cost Optimization: ${YELLOW}./aicheck context cost|optimize${NC}"
echo -e "${GREEN}✓ Structured Templates: ${YELLOW}.aicheck/templates/claude/${NC}"

echo -e "\n${GREEN}Installation complete! 🚀${NC}"