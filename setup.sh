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

# Source shell config automatically
SOURCE_CMD=""
if [ -f ~/.zshrc ]; then
  SOURCE_CMD="source ~/.zshrc"
  echo -e "\n${BLUE}Activating commands by sourcing your shell configuration...${NC}"
  source ~/.zshrc
elif [ -f ~/.bashrc ]; then
  SOURCE_CMD="source ~/.bashrc"
  echo -e "\n${BLUE}Activating commands by sourcing your shell configuration...${NC}"
  source ~/.bashrc
fi

# Automatically run activation script and copy to clipboard if possible
echo -e "\n${BLUE}Activating AICheck for Claude Code...${NC}"

# Generate the activation text
if [ -f ./activate_aicheck_claude.sh ]; then
  ./activate_aicheck_claude.sh
  
  # Try to copy to clipboard automatically if possible
  if command -v pbcopy >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Copied AICheck activation text to clipboard!${NC}"
    echo -e "${GREEN}✓ Just paste it to Claude in a new conversation${NC}"
    cat /tmp/aicheck_prompt.md | pbcopy
  elif command -v xclip >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Copied AICheck activation text to clipboard!${NC}"
    echo -e "${GREEN}✓ Just paste it to Claude in a new conversation${NC}"
    cat /tmp/aicheck_prompt.md | xclip -selection clipboard
  else
    echo -e "${YELLOW}Manually copy the text from the opened file and paste to Claude${NC}"
  fi
else
  echo -e "${RED}Activation script not found. Run ./activate_aicheck_claude.sh manually.${NC}"
fi

echo -e "\n${GREEN}Setup complete! AICheck is ready to use.${NC}"