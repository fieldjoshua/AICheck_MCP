#!/bin/bash

# AICheck v5.0.0 Universal Installer
# Works for both new installations and updates

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}AICheck v5.0.0 Installation${NC}"
echo -e "${YELLOW}Curated human oversight + effective automation${NC}"
echo "============================"

# Check if this is an update or fresh install
if [ -f "./aicheck" ]; then
    echo -e "${YELLOW}Existing AICheck installation detected${NC}"
    
    # Get current version
    CURRENT_VERSION=$(./aicheck version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    echo -e "Current version: ${YELLOW}$CURRENT_VERSION${NC}"
    
    # Fix permissions on read-only files before backup
    echo -e "${BLUE}Fixing file permissions...${NC}"
    find .aicheck -type f -name "*.md" -exec chmod +w {} \; 2>/dev/null || true
    find .mcp -type f -exec chmod +w {} \; 2>/dev/null || true
    
    # Backup important files
    if [ -d ".aicheck" ]; then
        echo -e "${BLUE}Creating backup...${NC}"
        # Use rsync if available for better handling of missing files
        if command -v rsync >/dev/null 2>&1; then
            rsync -a --ignore-missing-args .aicheck/ .aicheck.backup.$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || cp -r .aicheck .aicheck.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
        else
            # Fallback to cp but ignore errors
            cp -r .aicheck .aicheck.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
        fi
    fi
    
    MODE="update"
else
    echo -e "${GREEN}Fresh installation${NC}"
    MODE="fresh"
fi

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
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/aicheck > aicheck.new || {
    echo -e "${RED}Failed to download aicheck${NC}"
    exit 1
}
chmod +x aicheck.new
mv aicheck.new aicheck

# Download RULES.md (always update)
# Remove read-only if it exists
if [ -f ".aicheck/RULES.md" ]; then
    chmod +w .aicheck/RULES.md 2>/dev/null || true
fi
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/RULES.md > .aicheck/RULES.md || {
    echo -e "${RED}Failed to download RULES.md${NC}"
    exit 1
}

# Download MCP server
echo -e "${BLUE}Setting up MCP server...${NC}"
# Fix permissions if files exist
if [ -f ".mcp/server/index.js" ]; then
    chmod +w .mcp/server/index.js 2>/dev/null || true
fi
if [ -f ".mcp/server/package.json" ]; then
    chmod +w .mcp/server/package.json 2>/dev/null || true
fi
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/index.js > .mcp/server/index.js
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/package.json > .mcp/server/package.json
chmod +x .mcp/server/index.js

# Download templates
echo -e "${BLUE}Downloading templates...${NC}"
for template in auto-surgical-fix research-plan-implement auto-tdd-cycle cost-efficient-development; do
    curl -sSL "https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/templates/claude/${template}.md" > ".aicheck/templates/claude/${template}.md" 2>/dev/null || true
done

# Only create initial files for fresh installs
if [ "$MODE" = "fresh" ]; then
    echo -e "${BLUE}Creating initial files...${NC}"
    
    # Create current_action file
    echo "None" > .aicheck/current_action
    
    # Create actions_index.md
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

    # Create dependency index
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
else
    echo -e "${GREEN}✓ Preserved existing actions and configuration${NC}"
fi

# Install MCP dependencies if npm is available
if command -v npm >/dev/null 2>&1; then
    echo -e "${BLUE}Installing MCP dependencies...${NC}"
    cd .mcp/server && npm install --silent && cd ../..
    echo -e "${GREEN}✓ MCP server ready${NC}"
else
    echo -e "${YELLOW}⚠ npm not found - run 'cd .mcp/server && npm install' later${NC}"
fi

# Create or update activation script
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

# Show appropriate completion message
echo ""
echo -e "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    ${GREEN}AICHECK v5.0.0${BLUE}                     ║${NC}"
echo -e "${BLUE}║   ${YELLOW}Curated human oversight + effective automation${BLUE}    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$MODE" = "update" ]; then
    echo -e "${GREEN}Update complete!${NC}"
    echo -e "${YELLOW}Your existing actions and configuration have been preserved${NC}"
    # Check if any backup directories exist
    if ls .aicheck.backup.* >/dev/null 2>&1; then
        echo -e "${BLUE}Backup created in: $(ls -d .aicheck.backup.* | tail -1)${NC}"
    fi
else
    echo -e "${GREEN}Installation complete!${NC}"
fi

echo -e "\n${BLUE}Next steps:${NC}"
echo "1. Run: ./activate_aicheck_claude.sh"
echo "2. Paste the prompt into Claude Code"
echo "3. Start with: ./aicheck stuck"
echo -e "\n${BLUE}Your commands:${NC}"
echo "• ./aicheck stuck    - Get unstuck when confused"
echo "• ./aicheck deploy   - Pre-deployment validation"
echo "• ./aicheck new      - Create a new action"
echo "• ./aicheck ACTIVE   - Set the ACTIVE action"
echo "• ./aicheck complete - Complete the ACTIVE action"
echo "• ./aicheck cleanup - Clean up after work"
echo "• ./aicheck usage - Check costs and optimization"

if [ "$MODE" = "update" ]; then
    echo -e "\n${BLUE}What's new in v4.3.0:${NC}"
    echo "• MCP Integration - Native Claude Code integration"
    echo "• Context Management - Auto pollution detection & cleanup"
    echo "• Session Detection - Auto-runs checks on new sessions"
    echo "• Cost Analysis - Track and optimize Claude usage"
fi