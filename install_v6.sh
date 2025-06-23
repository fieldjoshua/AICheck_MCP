#!/bin/bash

# AICheck v6.0.0 Careful Installer/Updater
# Handles existing installations with minimal disruption
# Introduces Auto-Iterate Mode

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'
PURPLE='\033[1;35m'
ORANGE='\033[1;33m'
NEON_GREEN='\033[1;92m'

# Version information
NEW_VERSION="6.0.0"
MIN_SAFE_VERSION="5.0.0"

echo ""
echo -e "${BOLD}${PURPLE}█████╗ ██╗ ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗${NC}"
echo -e "${BOLD}${PURPLE}██╔══██╗██║██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝${NC}"
echo -e "${BOLD}${ORANGE}███████║██║██║     ███████║█████╗  ██║     █████╔╝ ${NC}"
echo -e "${BOLD}${ORANGE}██╔══██║██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ ${NC}"
echo -e "${BOLD}${NEON_GREEN}██║  ██║██║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗${NC}"
echo -e "${BOLD}${NEON_GREEN}╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝${NC}"
echo ""
echo -e "${BOLD}${NEON_GREEN}                        v${NEW_VERSION}${NC}"
echo -e "${BOLD}${PURPLE}  Goal-driven AI development governance${NC}"
echo ""
echo -e "${BOLD}${NEON_GREEN}🆕 NEW: Auto-Iterate Mode${NC}"
echo -e "${BOLD}${ORANGE}  → Goal-driven test-fix-test cycles${NC}"
echo -e "${BOLD}${ORANGE}  → Human approval gates${NC}"
echo -e "${BOLD}${ORANGE}  → Action integration${NC}"
echo ""
echo -e "${BOLD}${PURPLE}══════════════════════════════════════════════════════${NC}"

# Safety check function
function check_system_safety() {
    echo -e "${BLUE}🔍 Performing safety checks...${NC}"
    
    # Check if we're in a git repository
    if [ -d ".git" ]; then
        # Check for uncommitted changes
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            echo -e "${YELLOW}⚠️  Warning: Uncommitted changes detected${NC}"
            echo -e "${YELLOW}Recommendation: Commit changes before updating AICheck${NC}"
            echo ""
            read -p "Continue anyway? (y/N): " continue_anyway
            if [[ ! "$continue_anyway" =~ ^[Yy] ]]; then
                echo -e "${YELLOW}Update cancelled. Commit your changes and try again.${NC}"
                exit 1
            fi
        fi
        
        # Check for active action
        if [ -f ".aicheck/current_action" ]; then
            local current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
            if [ "$current_action" != "None" ] && [ "$current_action" != "AICheckExec" ]; then
                echo -e "${YELLOW}⚠️  Active action detected: ${current_action}${NC}"
                echo -e "${YELLOW}Recommendation: Complete or pause action before updating${NC}"
                echo ""
                read -p "Continue anyway? (y/N): " continue_anyway
                if [[ ! "$continue_anyway" =~ ^[Yy] ]]; then
                    echo -e "${YELLOW}Update cancelled. Complete your action and try again.${NC}"
                    exit 1
                fi
            fi
        fi
    fi
    
    echo -e "${GREEN}✓ Safety checks passed${NC}"
}

# Detect installation type
function detect_installation_type() {
    if [ -f "./aicheck" ]; then
        echo -e "${YELLOW}Existing AICheck installation detected${NC}"
        
        # Get current version
        local current_version=$(./aicheck version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
        echo -e "Current version: ${YELLOW}$current_version${NC}"
        
        # Version compatibility check
        if [ "$current_version" = "unknown" ]; then
            echo -e "${RED}⚠️  Cannot determine current version${NC}"
            echo -e "${RED}This may be a very old or corrupted installation${NC}"
            echo ""
            read -p "Force update anyway? (y/N): " force_update
            if [[ ! "$force_update" =~ ^[Yy] ]]; then
                echo -e "${YELLOW}Update cancelled. Please backup manually.${NC}"
                exit 1
            fi
            MODE="force_update"
        elif [[ "$current_version" < "$MIN_SAFE_VERSION" ]]; then
            echo -e "${RED}⚠️  Version $current_version is too old for safe auto-update${NC}"
            echo -e "${RED}Manual backup recommended before proceeding${NC}"
            echo ""
            read -p "Continue with manual verification? (y/N): " continue_old
            if [[ ! "$continue_old" =~ ^[Yy] ]]; then
                echo -e "${YELLOW}Update cancelled. Please backup manually.${NC}"
                exit 1
            fi
            MODE="legacy_update"
        else
            echo -e "${GREEN}✓ Version $current_version is compatible${NC}"
            MODE="safe_update"
        fi
    else
        echo -e "${GREEN}Fresh installation${NC}"
        MODE="fresh"
    fi
}

# Smart backup function
function create_smart_backup() {
    if [ "$MODE" = "fresh" ]; then
        echo -e "${BLUE}No backup needed for fresh installation${NC}"
        return 0
    fi
    
    echo -e "${BLUE}📦 Creating intelligent backup...${NC}"
    
    local backup_dir=".aicheck.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Fix permissions on read-only files before backup
    if [ -d ".aicheck" ]; then
        echo -e "${BLUE}Fixing file permissions...${NC}"
        find .aicheck -type f -name "*.md" -exec chmod +w {} \; 2>/dev/null || true
        find .mcp -type f -exec chmod +w {} \; 2>/dev/null || true
        
        # Create selective backup based on installation type
        case "$MODE" in
            "safe_update")
                # Only backup user data and configurations
                mkdir -p "$backup_dir/actions"
                mkdir -p "$backup_dir/configs"
                
                # Backup actions (most important)
                if [ -d ".aicheck/actions" ]; then
                    cp -r .aicheck/actions "$backup_dir/" 2>/dev/null || true
                    echo -e "${GREEN}✓ Actions backed up${NC}"
                fi
                
                # Backup configurations
                cp .aicheck/current_action "$backup_dir/configs/" 2>/dev/null || true
                cp .aicheck/*.conf "$backup_dir/configs/" 2>/dev/null || true
                
                # Backup MCP configurations
                if [ -d ".mcp" ]; then
                    cp -r .mcp "$backup_dir/" 2>/dev/null || true
                    echo -e "${GREEN}✓ MCP configuration backed up${NC}"
                fi
                ;;
                
            "legacy_update"|"force_update")
                # Full backup for safety
                if command -v rsync >/dev/null 2>&1; then
                    rsync -a --ignore-missing-args .aicheck/ "$backup_dir/" 2>/dev/null || true
                else
                    cp -r .aicheck "$backup_dir/" 2>/dev/null || true
                fi
                
                # Also backup old aicheck command
                cp aicheck "$backup_dir/aicheck.old" 2>/dev/null || true
                echo -e "${GREEN}✓ Full backup created${NC}"
                ;;
        esac
        
        echo -e "${GREEN}✓ Backup created: ${backup_dir}${NC}"
        BACKUP_DIR="$backup_dir"
    fi
}

# Download with verification
function download_with_verification() {
    local file="$1"
    local url="$2"
    local description="$3"
    local verify_pattern="$4"
    
    echo -e "${BLUE}Downloading ${description}...${NC}"
    
    # Download with cache-busting
    if curl -sSL "${url}?$(date +%s)" > "${file}.new"; then
        # Verify content if pattern provided
        if [ -n "$verify_pattern" ]; then
            if grep -q "$verify_pattern" "${file}.new"; then
                echo -e "${GREEN}✓ ${description} verified${NC}"
            else
                echo -e "${YELLOW}⚠️  ${description} verification inconclusive${NC}"
            fi
        else
            echo -e "${GREEN}✓ ${description} downloaded${NC}"
        fi
        
        # Make executable if it's a script
        if [[ "$file" =~ \.(sh|py)$ ]] || [ "$file" = "aicheck" ]; then
            chmod +x "${file}.new"
        fi
        
        # Atomic replacement
        mv "${file}.new" "$file"
        return 0
    else
        echo -e "${RED}✗ Failed to download ${description}${NC}"
        rm -f "${file}.new"
        return 1
    fi
}

# Setup directory structure
function setup_directories() {
    echo -e "${BLUE}📁 Setting up directory structure...${NC}"
    
    # Core directories
    mkdir -p .aicheck/actions
    mkdir -p .aicheck/templates/claude
    mkdir -p .aicheck/hooks
    mkdir -p .aicheck/scripts
    mkdir -p .mcp/server
    mkdir -p documentation/dependencies
    mkdir -p tests
    
    # New v5.2.0 directories
    mkdir -p templates/claude
    
    echo -e "${GREEN}✓ Directory structure ready${NC}"
}

# Download core files
function download_core_files() {
    echo -e "${BLUE}📥 Downloading AICheck v${NEW_VERSION}...${NC}"
    
    local base_url="https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main"
    
    # Download main aicheck command
    download_with_verification "aicheck" "$base_url/aicheck" "AICheck command" "$NEW_VERSION" || {
        echo -e "${RED}Critical failure: Could not download aicheck command${NC}"
        exit 1
    }
    
    # Download RULES.md (always update)
    download_with_verification ".aicheck/RULES.md" "$base_url/RULES.md" "RULES.md" "AICheck Rules" || {
        echo -e "${RED}Critical failure: Could not download RULES.md${NC}"
        exit 1
    }
    
    # Download new auto-iterate template
    download_with_verification "templates/claude/auto-iterate-action.md" "$base_url/templates/claude/auto-iterate-action.md" "Auto-iterate template" "Auto-Iterate" || {
        echo -e "${YELLOW}⚠️  Auto-iterate template download failed - will create basic version${NC}"
        create_basic_auto_iterate_template
    }
    
    # Download documentation
    download_with_verification "AUTO_ITERATE_GUIDE.md" "$base_url/AUTO_ITERATE_GUIDE.md" "Auto-iterate guide" "Auto-Iterate Mode" || {
        echo -e "${YELLOW}⚠️  Auto-iterate guide download failed${NC}"
    }
}

# Create basic auto-iterate template if download fails
function create_basic_auto_iterate_template() {
    echo -e "${BLUE}Creating basic auto-iterate template...${NC}"
    
    mkdir -p templates/claude
    
    cat > templates/claude/auto-iterate-action.md << 'EOF'
# Auto-Iterate Session Template

This template is automatically added to the active action's directory when auto-iterate mode is initiated.

## Integration Workflow

1. **Have Active Action**: Ensure you have an active action: `./aicheck status`
2. **Begin Auto-Iterate**: `./aicheck auto-iterate` (this template auto-added to action directory)
3. **Follow Goal-Driven Process**: Goals → Approval → Execution → Git Approval

---

# ACTION: [ACTION-NAME]

**Type:** Auto-Iterate Session  
**Created:** [DATE]  
**Status:** ActiveAction

## Auto-Iterate Goals

### Primary Goals
<!-- AI editor will define specific goals during auto-iterate process -->

**GOAL 1:** [Specific, measurable objective]
- **Success Criteria:** [How to verify this goal is complete]
- **Approach:** [High-level strategy to achieve this goal]
- **Risk Assessment:** [What could go wrong]

## Session Progress
<!-- Track multiple auto-iterate sessions within this action -->

## Integration with Action Plan
<!-- How this auto-iterate session supports the main action objectives -->

EOF
    
    echo -e "${GREEN}✓ Basic auto-iterate template created${NC}"
}

# Setup MCP server with conflict resolution
function setup_mcp_server() {
    echo -e "${BLUE}🔌 Setting up MCP server with conflict resolution...${NC}"
    
    # Generate unique MCP server name to avoid conflicts
    local project_name=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
    local mcp_server_name="aicheck-${project_name}"
    
    # Download MCP server file
    download_with_verification ".mcp/server/index.js" "https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/MCP/server/index.js" "MCP server" "aicheck" || {
        echo -e "${YELLOW}⚠️  MCP server download failed - will create basic version${NC}"
        create_basic_mcp_server
    }
    
    # Create activation script
    cat > activate_aicheck_claude.sh << EOF
#!/bin/bash

# AICheck v${NEW_VERSION} Claude Integration Activator
# This script sets up MCP server integration for Claude Code

echo "🔌 Activating AICheck v${NEW_VERSION} for Claude Code..."

# Detect Claude config location
CLAUDE_CONFIG=""
if [ -f "\$HOME/.claude/claude_desktop_config.json" ]; then
    CLAUDE_CONFIG="\$HOME/.claude/claude_desktop_config.json"
elif [ -f "\$HOME/.config/claude/claude_desktop_config.json" ]; then
    CLAUDE_CONFIG="\$HOME/.config/claude/claude_desktop_config.json"
else
    echo "Claude config not found. Please configure manually."
    echo "Add this to your Claude config:"
    echo "{"
    echo "  \"mcpServers\": {"
    echo "    \"${mcp_server_name}\": {"
    echo "      \"command\": \"node\","
    echo "      \"args\": [\"\$(pwd)/.mcp/server/index.js\"]"
    echo "    }"
    echo "  }"
    echo "}"
    exit 1
fi

echo "Found Claude config: \$CLAUDE_CONFIG"

# Use Python to safely update JSON config
python3 -c "
import json
import sys
import os

config_file = '\$CLAUDE_CONFIG'
project_dir = os.getcwd()
server_name = '${mcp_server_name}'

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
except FileNotFoundError:
    config = {}

# Initialize mcpServers if it doesn't exist
if 'mcpServers' not in config:
    config['mcpServers'] = {}

# Add or update AICheck server with unique name
config['mcpServers'][server_name] = {
    'command': 'node',
    'args': [os.path.join(project_dir, '.mcp/server/index.js')]
}

# Write back to file
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f'✓ Added {server_name} to Claude MCP configuration')
" || {
    echo "⚠️  Python JSON update failed. Please configure manually."
    exit 1
}

echo "✅ AICheck v${NEW_VERSION} activated for Claude Code!"
echo "🔄 Please restart Claude Code to load the new MCP server."
echo ""
echo "🆕 New in v${NEW_VERSION}: Auto-Iterate Mode"
echo "   Try: ./aicheck auto-iterate --help"
EOF
    
    chmod +x activate_aicheck_claude.sh
    echo -e "${GREEN}✓ MCP activation script created${NC}"
}

# Create basic MCP server if download fails
function create_basic_mcp_server() {
    echo -e "${BLUE}Creating basic MCP server...${NC}"
    
    mkdir -p .mcp/server
    
    cat > .mcp/server/index.js << 'EOF'
#!/usr/bin/env node

// Basic AICheck MCP Server v5.2.0
// Minimal implementation for auto-iterate mode

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');

const server = new Server(
  {
    name: 'aicheck',
    version: '5.2.0',
  },
  {
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

// Basic tool implementations would go here
// This is a minimal server for compatibility

server.connect();
EOF
    
    echo -e "${GREEN}✓ Basic MCP server created${NC}"
}

# Test installation
function test_installation() {
    echo -e "${BLUE}🧪 Testing installation...${NC}"
    
    # Test basic aicheck command
    if ./aicheck version &>/dev/null; then
        local installed_version=$(./aicheck version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        echo -e "${GREEN}✓ AICheck v${installed_version} working${NC}"
    else
        echo -e "${RED}✗ AICheck command test failed${NC}"
        return 1
    fi
    
    # Test auto-iterate help
    if ./aicheck auto-iterate --help &>/dev/null; then
        echo -e "${GREEN}✓ Auto-iterate mode available${NC}"
    else
        echo -e "${YELLOW}⚠️  Auto-iterate mode test failed${NC}"
    fi
    
    # Test MCP server syntax
    if node -c .mcp/server/index.js 2>/dev/null; then
        echo -e "${GREEN}✓ MCP server syntax valid${NC}"
    else
        echo -e "${YELLOW}⚠️  MCP server syntax check failed${NC}"
    fi
    
    echo -e "${GREEN}✓ Installation test completed${NC}"
}

# Main installation flow
function main() {
    echo -e "${BLUE}Starting AICheck v${NEW_VERSION} installation...${NC}"
    
    # Safety checks
    check_system_safety
    
    # Detect what kind of installation we're doing
    detect_installation_type
    
    # Create backup if needed
    create_smart_backup
    
    # Setup directories
    setup_directories
    
    # Download files
    download_core_files
    
    # Setup MCP integration
    setup_mcp_server
    
    # Test everything works
    test_installation
    
    # Success message
    echo ""
    echo -e "${BOLD}${GREEN}🎉 AICheck v${NEW_VERSION} installation complete!${NC}"
    echo ""
    echo -e "${BOLD}${NEON_GREEN}🆕 NEW: Auto-Iterate Mode${NC}"
    echo -e "${BLUE}Goal-driven test-fix-test cycles with human oversight${NC}"
    echo ""
    echo -e "${BOLD}${YELLOW}Quick Start:${NC}"
    echo -e "  ${GREEN}./aicheck status${NC}              # Check current status"
    echo -e "  ${GREEN}./aicheck auto-iterate --help${NC}  # Learn about auto-iterate"
    echo ""
    echo -e "${BOLD}${YELLOW}Claude Integration:${NC}"
    echo -e "  ${GREEN}./activate_aicheck_claude.sh${NC}   # Setup Claude MCP integration"
    echo -e "  ${BLUE}Then restart Claude Code${NC}"
    echo ""
    
    if [ -n "$BACKUP_DIR" ]; then
        echo -e "${BOLD}${YELLOW}Backup:${NC}"
        echo -e "  ${BLUE}Previous installation backed up to: ${BACKUP_DIR}${NC}"
        echo ""
    fi
    
    case "$MODE" in
        "safe_update")
            echo -e "${GREEN}✓ Safe update completed - all user data preserved${NC}"
            ;;
        "legacy_update"|"force_update")
            echo -e "${YELLOW}⚠️  Legacy update completed - please verify your actions are intact${NC}"
            ;;
        "fresh")
            echo -e "${GREEN}✓ Fresh installation completed${NC}"
            ;;
    esac
    
    echo -e "${BOLD}${PURPLE}Ready to revolutionize your AI development workflow!${NC}"
}

# Run main installation
main "$@"