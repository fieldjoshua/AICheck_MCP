#!/bin/bash

# AICheck v7.3.0 Modular Installer
# Installs both monolithic and modular versions

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

echo ""
echo -e "${BOLD}${PURPLE}█████╗ ██╗ ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗${NC}"
echo -e "${BOLD}${PURPLE}██╔══██╗██║██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝${NC}"
echo -e "${BOLD}${ORANGE}███████║██║██║     ███████║█████╗  ██║     █████╔╝ ${NC}"
echo -e "${BOLD}${ORANGE}██╔══██║██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ ${NC}"
echo -e "${BOLD}${NEON_GREEN}██║  ██║██║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗${NC}"
echo -e "${BOLD}${NEON_GREEN}╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝${NC}"
echo ""
echo -e "${BOLD}${NEON_GREEN}                    v7.3.0 MODULAR${NC}"
echo -e "${BOLD}${PURPLE}  Clean architecture ${ORANGE}+${NEON_GREEN} maintainable automation${NC}"
echo ""
echo -e "${BOLD}${PURPLE}══════════════════════════════════════════════════════${NC}"

# Detect installation mode
INSTALL_MODE="fresh"
if [ -f "./aicheck" ]; then
    echo -e "${YELLOW}Existing AICheck installation detected${NC}"
    CURRENT_VERSION=$(./aicheck version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    echo -e "Current version: ${YELLOW}$CURRENT_VERSION${NC}"
    INSTALL_MODE="update"
fi

# Create backup if updating
if [ "$INSTALL_MODE" = "update" ]; then
    echo -e "${BLUE}Creating backup...${NC}"
    BACKUP_DIR=".aicheck.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Backup existing installation
    if [ -f "./aicheck" ]; then
        cp ./aicheck "${BACKUP_DIR}_aicheck.bak"
    fi
    
    if [ -d "./aicheck-lib" ]; then
        tar -czf "${BACKUP_DIR}_aicheck-lib.tar.gz" ./aicheck-lib 2>/dev/null
        echo -e "${GREEN}✓ Backed up existing modules${NC}"
    fi
    
    if [ -d ".aicheck" ]; then
        find .aicheck -type f -name "*.md" -exec chmod +w {} \; 2>/dev/null || true
        timeout 30s tar -czf "${BACKUP_DIR}.tar.gz" .aicheck 2>/dev/null && {
            echo -e "${GREEN}✓ Backup created: ${BACKUP_DIR}.tar.gz${NC}"
        } || {
            echo -e "${YELLOW}⚠ Backup skipped (timeout or error)${NC}"
        }
    fi
fi

# Download/copy main script
echo -e "${BLUE}Installing AICheck core...${NC}"
if [ "$0" = "bash" ] || [ "$0" = "sh" ]; then
    # Running from curl/wget
    curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/aicheck -o aicheck
else
    # Running locally
    if [ -f "../aicheck" ]; then
        cp ../aicheck .
    elif [ -f "./aicheck" ]; then
        echo -e "${GREEN}✓ AICheck core already present${NC}"
    else
        echo -e "${RED}✗ Cannot find aicheck script${NC}"
        exit 1
    fi
fi

chmod +x aicheck

# Install modular components
echo -e "${BLUE}Installing modular architecture...${NC}"

# Create module directories
mkdir -p aicheck-lib/{ui,core,validation,detection,actions,mcp,git,automation,maintenance,deployment}

# Function to download or copy module
install_module() {
    local module_path=$1
    local module_name=$(basename "$module_path")
    
    if [ "$0" = "bash" ] || [ "$0" = "sh" ]; then
        # Download from GitHub
        local url="https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/${module_path}"
        curl -sSL "$url" -o "$module_path" 2>/dev/null && {
            echo -e "  ${GREEN}✓${NC} $module_name"
        } || {
            echo -e "  ${RED}✗${NC} $module_name (download failed)"
            return 1
        }
    else
        # Copy from local
        if [ -f "../$module_path" ]; then
            cp "../$module_path" "$module_path"
            echo -e "  ${GREEN}✓${NC} $module_name"
        elif [ -f "./$module_path" ]; then
            echo -e "  ${GREEN}✓${NC} $module_name (exists)"
        else
            echo -e "  ${YELLOW}⚠${NC} $module_name (not found)"
            return 1
        fi
    fi
    
    chmod +x "$module_path" 2>/dev/null || true
}

# Install all modules
echo -e "${BLUE}Installing modules:${NC}"

# UI modules
install_module "aicheck-lib/ui/colors.sh"
install_module "aicheck-lib/ui/output.sh"

# Core modules
install_module "aicheck-lib/core/errors.sh"
install_module "aicheck-lib/core/state.sh"
install_module "aicheck-lib/core/dispatcher.sh"
install_module "aicheck-lib/core/utilities.sh"

# Validation modules
install_module "aicheck-lib/validation/input.sh"
install_module "aicheck-lib/validation/actions.sh"

# Feature modules
install_module "aicheck-lib/detection/environment.sh"
install_module "aicheck-lib/actions/management.sh"
install_module "aicheck-lib/mcp/integration.sh"
install_module "aicheck-lib/git/operations.sh"
install_module "aicheck-lib/automation/auto_iterate.sh"
install_module "aicheck-lib/maintenance/cleanup.sh"
install_module "aicheck-lib/deployment/validation.sh"

# Create module documentation
cat > aicheck-lib/README.md << 'EOF'
# AICheck Library Modules

This directory contains the modular components of AICheck v7.3.0+

## Module Structure

- **ui/** - User interface components (colors, output formatting)
- **core/** - Core functionality (errors, state, dispatcher, utilities)
- **validation/** - Input and data validation
- **detection/** - Environment and project detection
- **actions/** - Action management functionality
- **mcp/** - MCP integration for AI editors
- **git/** - Git operations and helpers
- **automation/** - Auto-iterate and automation features
- **maintenance/** - Cleanup and optimization
- **deployment/** - Deployment validation and checks

## Usage

The main `aicheck` script automatically loads these modules. For development:

```bash
source aicheck-lib/core/dispatcher.sh
load_all_modules
```

## Creating New Modules

1. Create a new .sh file in the appropriate directory
2. Add necessary dependencies at the top
3. Export functions that should be available globally
4. Update the dispatcher to load your module

## Module Dependencies

Modules should source their dependencies at the top:

```bash
source "$(dirname "${BASH_SOURCE[0]}")/../core/errors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"
```
EOF

# Verify module installation
echo -e "\n${BLUE}Verifying module installation...${NC}"
MODULE_COUNT=$(find aicheck-lib -name "*.sh" -type f | wc -l | tr -d ' ')
if [ "$MODULE_COUNT" -ge 15 ]; then
    echo -e "${GREEN}✓ All $MODULE_COUNT modules installed successfully${NC}"
else
    echo -e "${YELLOW}⚠ Only $MODULE_COUNT/15 modules found${NC}"
fi

# Install modular wrapper (optional)
echo -e "\n${BLUE}Install modular wrapper?${NC}"
echo -e "This provides a pure modular version for testing"
read -p "Install aicheck-modular? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat > aicheck-modular << 'EOF'
#!/bin/bash
# AICheck Modular Version
set -e

AICHECK_VERSION="7.3.0-modular"
GITHUB_REPO="fieldjoshua/AICheck_MCP"
CMD=${1:-help}
shift || true
ARGS=("$@")

AICHECK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AICHECK_LIB="$AICHECK_DIR/aicheck-lib"

if [ ! -d "$AICHECK_LIB" ]; then
    echo "Error: aicheck-lib directory not found"
    exit 1
fi

source "$AICHECK_LIB/core/dispatcher.sh"
load_all_modules
export AICHECK_VERSION
dispatch_command "$CMD" "${ARGS[@]}"
EOF
    chmod +x aicheck-modular
    echo -e "${GREEN}✓ Modular wrapper installed${NC}"
fi

# Initialize AICheck if fresh install
if [ "$INSTALL_MODE" = "fresh" ] || [ ! -d ".aicheck" ]; then
    echo -e "\n${BLUE}Initializing AICheck...${NC}"
    mkdir -p .aicheck/{actions,archive,logs}
    echo "None" > .aicheck/current_action
    
    # Create default RULES.md
    if [ ! -f ".aicheck/RULES.md" ]; then
        curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/RULES.md -o .aicheck/RULES.md 2>/dev/null || {
            echo -e "${YELLOW}⚠ Could not download RULES.md${NC}"
        }
    fi
    
    chmod 444 .aicheck/RULES.md 2>/dev/null || true
fi

# Install MCP server if not present
if [ ! -f ".mcp/server/package.json" ]; then
    echo -e "\n${BLUE}Setting up MCP server...${NC}"
    bash activate_aicheck_claude.sh 2>/dev/null || {
        echo -e "${YELLOW}⚠ Run activate_aicheck_claude.sh manually for MCP setup${NC}"
    }
fi

# Clean up old backups
echo -e "\n${BLUE}Cleaning up old backups...${NC}"
BACKUP_COUNT=$(ls -1 .aicheck.backup.* 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 3 ]; then
    ls -1t .aicheck.backup.* | tail -n +4 | xargs rm -rf
    echo -e "${GREEN}✓ Kept 3 most recent backups${NC}"
fi

# Final verification
echo -e "\n${BOLD}${PURPLE}═══════════════════════════════════════════${NC}"
echo -e "${BOLD}${GREEN}✓ AICheck v7.3.0 Modular installed successfully!${NC}"
echo -e "${BOLD}${PURPLE}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${BOLD}Quick Start:${NC}"
echo -e "  ${GREEN}./aicheck version${NC}     - See all commands"
echo -e "  ${GREEN}./aicheck new <name>${NC}  - Create your first action"
echo -e "  ${GREEN}./aicheck status${NC}      - Check system status"
echo ""
echo -e "${BOLD}Modular Features:${NC}"
echo -e "  • Clean architecture with 15+ specialized modules"
echo -e "  • Easy to extend and maintain"
echo -e "  • Full backward compatibility"
echo ""
echo -e "${YELLOW}Need help?${NC} Run ${GREEN}./aicheck stuck${NC}"
echo ""