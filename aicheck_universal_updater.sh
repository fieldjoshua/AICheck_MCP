#!/bin/bash

# AICheck Universal Updater
# Works with ANY version of aicheck - old or new
# Automatically detects and updates both command and rules

set -e

# Colors
GREEN='\033[0;32m'
BRIGHT_BLURPLE='\033[38;5;135m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BRIGHT_BLURPLE}AICheck Universal Updater${NC}"
echo -e "================================"
echo ""

# Check if we're in an AICheck project
if [ ! -f "./aicheck" ]; then
    echo -e "${RED}✗ No aicheck command found in current directory${NC}"
    echo -e "${YELLOW}Run this from your AICheck project directory${NC}"
    exit 1
fi

echo -e "${BRIGHT_BLURPLE}Updating AICheck to latest version...${NC}"
echo ""

# 1. Backup current aicheck
echo -e "${BRIGHT_BLURPLE}Creating backup...${NC}"
cp ./aicheck ./aicheck.backup.$(date +%Y%m%d_%H%M%S)
echo -e "${GREEN}✓ Backup created${NC}"

# 2. Download latest aicheck command
echo -e "${BRIGHT_BLURPLE}Downloading latest aicheck command...${NC}"
if curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/aicheck -o ./aicheck.new; then
    chmod +x ./aicheck.new
    mv ./aicheck.new ./aicheck
    echo -e "${GREEN}✓ AICheck command updated${NC}"
else
    echo -e "${RED}✗ Failed to download aicheck command${NC}"
    exit 1
fi

# 3. Update RULES.md if .aicheck directory exists
if [ -d ".aicheck" ]; then
    echo -e "${BRIGHT_BLURPLE}Updating RULES.md...${NC}"
    if [ -f ".aicheck/RULES.md" ]; then
        chmod +w .aicheck/RULES.md 2>/dev/null || true
    fi
    
    if curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/RULES.md -o .aicheck/RULES.md; then
        chmod 444 .aicheck/RULES.md
        echo -e "${GREEN}✓ RULES.md updated${NC}"
    else
        echo -e "${YELLOW}⚠ Failed to update RULES.md${NC}"
    fi
fi

# 4. Test the new version
echo ""
echo -e "${BRIGHT_BLURPLE}Testing updated aicheck...${NC}"
if ./aicheck version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Update successful!${NC}"
    echo ""
    ./aicheck version
    echo ""
    echo -e "${GREEN}🎉 AICheck is now fully automated and up to date!${NC}"
    echo -e "${BRIGHT_BLURPLE}You can now use: ./aicheck update${NC}"
else
    echo -e "${RED}✗ Update failed, restoring backup...${NC}"
    cp ./aicheck.backup.$(date +%Y%m%d_%H%M%S) ./aicheck
    chmod +x ./aicheck
    echo -e "${YELLOW}⚠ Restored previous version${NC}"
    exit 1
fi