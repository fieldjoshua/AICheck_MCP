#!/bin/bash

# MCP: AICheck_Scoper
# Action: AICheck-Installer-v7
# DateTime: 2025-06-25 16:50:00 PDT
# Task: Update installer for v7.0.0 release
# File: install.sh
# You may only modify this file. Stay within the current action scope.
# Follow the approved plan and avoid scope creep.

# AICheck v7.0.0 Universal Installer
# Works for both new installations and updates

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'
PURPLE='\033[1;35m'  # Bold purple
ORANGE='\033[1;33m'  # Bold orange (bright yellow)
NEON_GREEN='\033[1;92m'  # Bright green

echo ""
echo -e "${BOLD}${PURPLE}█████╗ ██╗ ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗${NC}"
echo -e "${BOLD}${PURPLE}██╔══██╗██║██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝${NC}"
echo -e "${BOLD}${ORANGE}███████║██║██║     ███████║█████╗  ██║     █████╔╝ ${NC}"
echo -e "${BOLD}${ORANGE}██╔══██║██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ ${NC}"
echo -e "${BOLD}${NEON_GREEN}██║  ██║██║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗${NC}"
echo -e "${BOLD}${NEON_GREEN}╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝${NC}"
echo ""
echo -e "${BOLD}${NEON_GREEN}                        v7.0.0${NC}"
echo -e "${BOLD}${PURPLE}  Curated human oversight ${ORANGE}+${NEON_GREEN} effective automation${NC}"
echo ""
echo -e "${BOLD}${PURPLE}══════════════════════════════════════════════════════${NC}"

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
    
    # Clean up old backups (keep only 3 most recent)
    echo -e "${BLUE}Managing backups...${NC}"
    BACKUP_COUNT=$(ls -d .aicheck.backup.* 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 3 ]; then
        echo -e "${BLUE}Removing old backups (keeping 3 most recent)...${NC}"
        ls -dt .aicheck.backup.* | tail -n +4 | xargs rm -rf
    fi
    
    # Backup important files (with timeout to prevent hanging)
    if [ -d ".aicheck" ]; then
        echo -e "${BLUE}Creating backup...${NC}"
        BACKUP_DIR=".aicheck.backup.$(date +%Y%m%d_%H%M%S)"
        
        # Use a simple tar-based backup with timeout
        timeout 30s tar -czf "${BACKUP_DIR}.tar.gz" .aicheck 2>/dev/null && {
            echo -e "${GREEN}✓ Backup created: ${BACKUP_DIR}.tar.gz${NC}"
        } || {
            echo -e "${YELLOW}⚠ Backup skipped (timeout or error)${NC}"
            echo -e "${YELLOW}  Continuing with installation...${NC}"
        }
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
mkdir -p .aicheck/hooks
mkdir -p .aicheck/scripts
mkdir -p .mcp/server
mkdir -p documentation/dependencies
mkdir -p tests

# Download core files
echo -e "${BLUE}Downloading AICheck v7.0.0...${NC}"

# Download aicheck command with cache-busting
curl -sSL "https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/aicheck?$(date +%s)" > aicheck.new || {
    echo -e "${RED}Failed to download aicheck${NC}"
    exit 1
}

# Verify version
if grep -q "7.0.0" aicheck.new; then
    echo -e "${GREEN}✓ Downloaded AICheck v7.0.0${NC}"
else
    echo -e "${YELLOW}⚠️  Version verification inconclusive${NC}"
fi

chmod +x aicheck.new
mv aicheck.new aicheck

# Download RULES.md (always update)
echo -e "${BLUE}Downloading RULES.md...${NC}"
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/RULES.md > .aicheck/RULES.md || {
    echo -e "${RED}Failed to download RULES.md${NC}"
    exit 1
}

# Download MCP server
echo -e "${BLUE}Setting up MCP server...${NC}"
# Fix permissions if files exist and remove any cached versions
if [ -f ".mcp/server/index.js" ]; then
    chmod +w .mcp/server/index.js 2>/dev/null || true
    rm -f .mcp/server/index.js
fi
if [ -f ".mcp/server/package.json" ]; then
    chmod +w .mcp/server/package.json 2>/dev/null || true
    rm -f .mcp/server/package.json
fi

# Force fresh download with cache-busting
echo -e "  Downloading latest MCP server (force refresh)..."
curl -sSL "https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/index.js?$(date +%s)" > .mcp/server/index.js
curl -sSL "https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/package.json?$(date +%s)" > .mcp/server/package.json
chmod +x .mcp/server/index.js

# Verify the MCP server has correct tool naming
echo -e "${BLUE}Verifying MCP server tool names...${NC}"
if grep -q "aicheck_getCurrentAction" .mcp/server/index.js; then
    echo -e "${GREEN}✓ MCP server uses correct underscore naming${NC}"
else
    echo -e "${RED}❌ MCP server download failed - missing underscore tool names${NC}"
    echo -e "${YELLOW}This may cause MCP connection failures${NC}"
fi

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

# Set up MCP server if needed
if [ -d ".mcp/server" ]; then
    echo -e "\n${BLUE}Setting up MCP server...${NC}"
    cd .mcp/server
    npm install >/dev/null 2>&1
    cd ../..
    
    # Configure Claude to use the MCP server
    echo -e "${BLUE}Configuring Claude integration...${NC}"
    
    # Detect Claude config directory
    if [[ "$OSTYPE" == "darwin"* ]]; then
        CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        CLAUDE_CONFIG_DIR="$APPDATA/Claude"
    else
        CLAUDE_CONFIG_DIR="$HOME/.config/claude"
    fi
    
    # Create config directory if it doesn't exist
    mkdir -p "$CLAUDE_CONFIG_DIR" 2>/dev/null || true
    
    # Get absolute path to AICheck
    AICHECK_PATH="$(pwd)"
    
    # Check if config already exists
    if [ -f "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" ]; then
        echo -e "${YELLOW}⚠️  Existing Claude config found${NC}"
        
        # Check if this project is already configured
        PROJECT_NAME="aicheck-$(basename "$AICHECK_PATH")"
        if grep -q "\"$PROJECT_NAME\"" "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" 2>/dev/null; then
            echo -e "${GREEN}✓ This project already configured in Claude${NC}"
        elif grep -q "\"$AICHECK_PATH/.mcp/server/index.js\"" "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" 2>/dev/null; then
            echo -e "${GREEN}✓ This project path already configured${NC}"
        else
            echo -e "${BLUE}Adding project to existing Claude config...${NC}"
            
            # Create a backup
            cp "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" "$CLAUDE_CONFIG_DIR/claude_desktop_config.json.backup"
            
            # Add this project to existing config
            # Remove closing braces and add new server
            sed -i.tmp '$ s/}//' "$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
            sed -i.tmp '$ s/}//' "$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
            
            cat >> "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" << EOF
    "$PROJECT_NAME": {
      "command": "node",
      "args": ["$AICHECK_PATH/.mcp/server/index.js"],
      "cwd": "$AICHECK_PATH"
    }
  }
}
EOF
            rm -f "$CLAUDE_CONFIG_DIR/claude_desktop_config.json.tmp"
            echo -e "${GREEN}✓ Added project to Claude configuration${NC}"
        fi
    else
        # Create claude_desktop_config.json
        cat > "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" << EOF
{
  "mcpServers": {
    "aicheck-$(basename "$AICHECK_PATH")": {
      "command": "node",
      "args": ["$AICHECK_PATH/.mcp/server/index.js"],
      "cwd": "$AICHECK_PATH"
    }
  }
}
EOF
        echo -e "${GREEN}✓ Claude MCP configuration created${NC}"
    fi
    
    echo -e "${GREEN}✓ MCP server configured${NC}"
    echo -e "${YELLOW}⚠️  Please restart Claude for changes to take effect${NC}"
fi

# Test installation
echo -e "\n${BLUE}Testing installation...${NC}"
if ./aicheck version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ AICheck installed successfully!${NC}"
else
    echo -e "${RED}✗ Installation test failed${NC}"
    exit 1
fi

# Test MCP server if available
if [ -f ".mcp/server/index.js" ] && command -v node >/dev/null 2>&1; then
    echo -e "${BLUE}Testing MCP server...${NC}"
    if timeout 3s node .mcp/server/index.js --version >/dev/null 2>&1; then
        echo -e "${GREEN}✓ MCP server can start${NC}"
    else
        echo -e "${YELLOW}⚠️  MCP server test inconclusive${NC}"
    fi
    
    # Verify required files exist
    echo -e "${BLUE}Checking MCP requirements...${NC}"
    if [ -f ".aicheck/RULES.md" ]; then
        echo -e "${GREEN}✓ RULES.md exists${NC}"
    else
        echo -e "${RED}✗ RULES.md missing${NC}"
    fi
    
    if [ -f ".aicheck/current_action" ]; then
        echo -e "${GREEN}✓ current_action exists${NC}"
    else
        echo -e "${RED}✗ current_action missing${NC}"
    fi
    
    if [ -f ".aicheck/actions_index.md" ]; then
        echo -e "${GREEN}✓ actions_index.md exists${NC}"
    else
        echo -e "${RED}✗ actions_index.md missing${NC}"
    fi
fi

# Show appropriate completion message
echo ""
echo -e "${BOLD}${PURPLE}══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${NEON_GREEN}█████╗ ██╗ ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗${NC}"
echo -e "${BOLD}${NEON_GREEN}██╔══██╗██║██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝${NC}"
echo -e "${BOLD}${ORANGE}███████║██║██║     ███████║█████╗  ██║     █████╔╝ ${NC}"
echo -e "${BOLD}${ORANGE}██╔══██║██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ ${NC}"
echo -e "${BOLD}${PURPLE}██║  ██║██║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗${NC}"
echo -e "${BOLD}${PURPLE}╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝${NC}"
echo -e "${BOLD}${NEON_GREEN}              ✨ Installation Complete! ✨${NC}"
echo -e "${BOLD}${PURPLE}══════════════════════════════════════════════════════${NC}"
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

echo ""
echo -e "${BOLD}${NEON_GREEN}🎯 NEXT STEPS:${NC}"
echo ""
echo -e "${BOLD}${PURPLE}1.${NC} ${BOLD}${ORANGE}Restart Claude Code completely${NC} ${YELLOW}(required for MCP changes)${NC}"
echo -e "${BOLD}${PURPLE}2.${NC} Run: ${BOLD}${ORANGE}./activate_aicheck_claude.sh${NC}"
echo -e "${BOLD}${PURPLE}3.${NC} ${BOLD}${NEON_GREEN}Paste the prompt into Claude Code${NC} ${YELLOW}(copied to clipboard)${NC}"
echo -e "${BOLD}${PURPLE}4.${NC} Start with: ${BOLD}${ORANGE}./aicheck stuck${NC}"
echo ""
echo -e "${BOLD}${BLUE}🔧 MCP TROUBLESHOOTING:${NC}"
echo -e "• Check Claude's MCP panel for 'aicheck-$(basename "$(pwd)")' server"
echo -e "• If MCP shows 'failed', restart Claude and check server status"
echo -e "• For multiple projects, each needs its own AICheck installation"
echo ""

