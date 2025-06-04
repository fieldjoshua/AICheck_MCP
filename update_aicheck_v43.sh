#!/bin/bash
#
# AICheck v4.3 Update Script
# Updates existing AICheck installations to v4.3.0 with MCP support
#

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}AICheck v4.3.0 Update${NC}"
echo -e "${CYAN}Adding MCP support and context management tools${NC}"
echo

# Check if AICheck is installed
if [ ! -f "./aicheck" ]; then
    echo -e "${RED}Error: AICheck not found in current directory${NC}"
    echo "Please run this script from your project root where AICheck is installed"
    exit 1
fi

# Get current version
CURRENT_VERSION=$(grep "AICHECK_VERSION=" ./aicheck | head -1 | cut -d'"' -f2)
echo -e "${YELLOW}Current version: ${CURRENT_VERSION}${NC}"

# Backup current installation
echo -e "${BLUE}Creating backup...${NC}"
cp ./aicheck ./aicheck.backup.${CURRENT_VERSION}

# Download new version
echo -e "${BLUE}Downloading AICheck v4.3.0...${NC}"
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/aicheck > ./aicheck.new

# Verify download
if [ ! -s "./aicheck.new" ]; then
    echo -e "${RED}Error: Failed to download new version${NC}"
    exit 1
fi

# Check new version
NEW_VERSION=$(grep "AICHECK_VERSION=" ./aicheck.new | head -1 | cut -d'"' -f2)
if [ "$NEW_VERSION" != "4.3.0" ]; then
    echo -e "${RED}Error: Downloaded version mismatch (got ${NEW_VERSION})${NC}"
    rm ./aicheck.new
    exit 1
fi

# Replace old version
mv ./aicheck.new ./aicheck
chmod +x ./aicheck

# Update RULES.md if exists
if [ -f ".aicheck/RULES.md" ]; then
    echo -e "${BLUE}Updating RULES.md...${NC}"
    curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/RULES.md > .aicheck/RULES.md.new
    if [ -s ".aicheck/RULES.md.new" ]; then
        mv .aicheck/RULES.md.new .aicheck/RULES.md
    fi
fi

# Setup MCP server
echo -e "${BLUE}Setting up MCP server...${NC}"
mkdir -p .mcp/server

# Download MCP server files
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/index.js > .mcp/server/index.js
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/package.json > .mcp/server/package.json
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/setup.sh > .mcp/setup.sh

chmod +x .mcp/server/index.js
chmod +x .mcp/setup.sh

# Install MCP dependencies
echo -e "${BLUE}Installing MCP dependencies...${NC}"
cd .mcp/server
npm install --quiet
cd ../..

# Register with Claude if claude CLI is available
if command -v claude &> /dev/null; then
    echo -e "${BLUE}Registering MCP server with Claude...${NC}"
    claude mcp add -s local -t stdio aicheck node "$(pwd)/.mcp/server/index.js" || true
fi

echo
echo -e "${GREEN}${BOLD}✅ Successfully updated to AICheck v4.3.0!${NC}"
echo
echo -e "${CYAN}What's new in v4.3.0:${NC}"
echo "• MCP (Model Context Protocol) integration with Claude Code"
echo "• Fixed tool naming (all use underscores now)"
echo "• Context management tools (pollution, compact, optimize)"
echo "• Cost analysis and usage tracking"
echo
echo -e "${YELLOW}To use MCP features:${NC}"
echo "1. Restart Claude Code"
echo "2. MCP tools will be available as mcp__aicheck-server__*"
echo
echo -e "${BLUE}Run './aicheck status' to verify the installation${NC}"