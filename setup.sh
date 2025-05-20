#!/bin/bash

# Master installer for AICheck MCP
# Downloads and runs all required components

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}AICheck MCP Installer${NC}"
echo -e "${BLUE}=====================${NC}"

# Download all required scripts
echo -e "\n${BLUE}Downloading setup scripts...${NC}"
curl -s -O https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/setup_aicheck_complete.sh
curl -s -O https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/setup_aicheck_hooks.sh
curl -s -O https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/setup_aicheck_status.sh

# Make executable
chmod +x setup_aicheck_complete.sh
chmod +x setup_aicheck_hooks.sh
chmod +x setup_aicheck_status.sh

# Run the main setup
echo -e "\n${BLUE}Running AICheck core setup...${NC}"
./setup_aicheck_complete.sh

# Run git hooks setup
echo -e "\n${BLUE}Setting up AICheck git hooks...${NC}"
./setup_aicheck_hooks.sh

# Run status display setup
echo -e "\n${BLUE}Setting up AICheck status display...${NC}"
./setup_aicheck_status.sh

echo -e "\n${GREEN}AICheck MCP installation complete!${NC}"
echo -e "${GREEN}All components have been installed successfully.${NC}"

# Remind about activation
echo -e "\n${YELLOW}To activate in your current terminal session, run:${NC}"
echo -e "  source ~/.zshrc ${YELLOW}or${NC} source ~/.bashrc"

# Prompt for activation
echo -e "\n${BLUE}Would you like to activate AICheck in Claude now? (y/n)${NC}"
read -r activate_claude

if [[ "$activate_claude" == "y" || "$activate_claude" == "Y" ]]; then
  ./activate_aicheck_claude.sh
fi