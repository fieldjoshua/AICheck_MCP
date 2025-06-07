#!/bin/bash

# AICheck MCP Configuration Fix Script
# Fixes common MCP server issues

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}AICheck MCP Configuration Fix${NC}"
echo "================================"

# Check if we're in an AICheck project
if [ ! -f "aicheck" ]; then
    echo -e "${RED}❌ Not in an AICheck project directory${NC}"
    echo "Run this script from your AICheck project root"
    exit 1
fi

echo -e "${GREEN}✓ Found AICheck project${NC}"

# Get absolute path
PROJECT_PATH="$(pwd)"
echo -e "Project path: ${BLUE}$PROJECT_PATH${NC}"

# Detect Claude config directory
if [[ "$OSTYPE" == "darwin"* ]]; then
    CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    CLAUDE_CONFIG_DIR="$APPDATA/Claude"
else
    CLAUDE_CONFIG_DIR="$HOME/.config/claude"
fi

echo -e "Claude config directory: ${BLUE}$CLAUDE_CONFIG_DIR${NC}"

# Create config directory if it doesn't exist
mkdir -p "$CLAUDE_CONFIG_DIR" 2>/dev/null || true

# Check if config exists
CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"

if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}⚠️  Existing Claude config found${NC}"
    
    # Check if AICheck is already configured for this project
    if grep -q "\"$PROJECT_PATH/.mcp/server/index.js\"" "$CONFIG_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ This project is already configured${NC}"
        
        # Check if MCP server exists
        if [ -f ".mcp/server/index.js" ]; then
            echo -e "${GREEN}✓ MCP server exists${NC}"
            
            # Test MCP server
            echo -e "${BLUE}Testing MCP server...${NC}"
            if timeout 2s node .mcp/server/index.js --version >/dev/null 2>&1; then
                echo -e "${GREEN}✓ MCP server can start${NC}"
            else
                echo -e "${YELLOW}⚠️  MCP server test inconclusive${NC}"
            fi
            
            echo ""
            echo -e "${YELLOW}Configuration looks correct. Try:${NC}"
            echo "1. Restart Claude Code completely"
            echo "2. Check Claude's MCP panel for 'aicheck' server"
            echo "3. If still failing, check Claude logs"
        else
            echo -e "${RED}❌ MCP server missing${NC}"
            echo "Run: bash <(curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/install.sh)"
        fi
    else
        echo -e "${YELLOW}⚠️  This project not configured in Claude${NC}"
        echo ""
        echo -e "${BLUE}Add this to your claude_desktop_config.json mcpServers section:${NC}"
        echo ""
        echo "  \"aicheck-$(basename "$PROJECT_PATH")\": {"
        echo "    \"command\": \"node\","
        echo "    \"args\": [\"$PROJECT_PATH/.mcp/server/index.js\"],"
        echo "    \"cwd\": \"$PROJECT_PATH\""
        echo "  }"
        echo ""
        echo -e "${YELLOW}Or run the installer to auto-configure:${NC}"
        echo "bash <(curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/install.sh)"
    fi
else
    echo -e "${RED}❌ No Claude config file found${NC}"
    echo -e "${BLUE}Creating new configuration...${NC}"
    
    # Create new config
    cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "aicheck-$(basename "$PROJECT_PATH")": {
      "command": "node",
      "args": ["$PROJECT_PATH/.mcp/server/index.js"],
      "cwd": "$PROJECT_PATH"
    }
  }
}
EOF
    
    echo -e "${GREEN}✓ Created Claude configuration${NC}"
    echo -e "${YELLOW}Please restart Claude Code${NC}"
fi

echo ""
echo -e "${BLUE}Summary:${NC}"
echo "1. Restart Claude Code completely"
echo "2. Check MCP panel for 'aicheck' server status"
echo "3. If still failing, the server might be trying to access missing .aicheck files"
echo ""
echo -e "${YELLOW}Next steps if still failing:${NC}"
echo "- Ensure .aicheck/RULES.md exists"
echo "- Ensure .aicheck/current_action exists" 
echo "- Ensure .aicheck/actions_index.md exists"