#!/bin/bash
# AICheck v7.3.0 Installer - Modular Architecture Update

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}AICheck v7.3.0 - Modular Architecture${NC}"
echo "======================================"

# Check if updating
if [ -f "./aicheck" ]; then
    echo -e "${YELLOW}Updating existing installation...${NC}"
    # Simple backup
    cp aicheck aicheck.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
fi

# Download/copy files
echo -e "${BLUE}Installing AICheck...${NC}"

# Main script
if [ ! -f "./aicheck" ]; then
    curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/aicheck -o aicheck || {
        echo -e "${RED}Failed to download aicheck${NC}"
        exit 1
    }
fi
chmod +x aicheck

# Install modules
echo -e "${BLUE}Installing modules...${NC}"
mkdir -p aicheck-lib/{ui,core,validation,detection,actions,mcp,git,automation,maintenance,deployment,tools}

# Base URL for downloads
BASE_URL="https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main"

# Download each module
modules=(
    "ui/colors.sh"
    "ui/output.sh"
    "core/errors.sh"
    "core/state.sh"
    "core/dispatcher.sh"
    "core/utilities.sh"
    "validation/input.sh"
    "validation/actions.sh"
    "detection/environment.sh"
    "actions/management.sh"
    "mcp/integration.sh"
    "git/operations.sh"
    "automation/auto_iterate.sh"
    "maintenance/cleanup.sh"
    "deployment/validation.sh"
)

for module in "${modules[@]}"; do
    curl -sSL "$BASE_URL/aicheck-lib/$module" -o "aicheck-lib/$module" 2>/dev/null && {
        echo -e "  ${GREEN}✓${NC} $module"
    } || {
        echo -e "  ${RED}✗${NC} $module"
    }
done

# Quick verification
MODULE_COUNT=$(find aicheck-lib -name "*.sh" | wc -l | tr -d ' ')
echo -e "\n${GREEN}Installed $MODULE_COUNT modules${NC}"

# Initialize if needed
if [ ! -d ".aicheck" ]; then
    mkdir -p .aicheck
    echo "None" > .aicheck/current_action
    echo -e "${GREEN}✓ AICheck initialized${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "Run ${BLUE}./aicheck version${NC} to get started"