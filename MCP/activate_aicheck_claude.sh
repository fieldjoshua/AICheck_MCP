#!/bin/bash

# Script to activate AICheck in a Claude Code session

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Activating AICheck in Claude Code...${NC}"

# Copy the prompt template
cp .aicheck/claude_aicheck_prompt.md /tmp/aicheck_prompt.md

# Instructions
echo -e "${GREEN}✓ AICheck activation ready${NC}"
echo -e "\nTo activate AICheck in Claude Code:"
echo -e "1. Start a new Claude Code conversation"
echo -e "2. Copy the contents of /tmp/aicheck_prompt.md"
echo -e "3. Paste this as your first message to Claude"
echo -e "4. Claude will automatically recognize AICheck and use the system\n"

# Open the file
echo -e "${YELLOW}Opening the prompt file...${NC}"
open /tmp/aicheck_prompt.md
