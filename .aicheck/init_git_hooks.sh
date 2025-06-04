#!/bin/bash

# AICheck git hooks initializer
# Run this after git init to set up AICheck git hooks

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BRIGHT_BLURPLE}Setting up AICheck git hooks...${NC}"

# Check if git is initialized
if [ ! -d ".git" ]; then
  echo -e "${YELLOW}No Git repository found. Run 'git init' first.${NC}"
  exit 1
fi

# Create hooks directory
mkdir -p .git/hooks

# Copy pre-saved hooks
cp .aicheck/hooks/pre-commit .git/hooks/
cp .aicheck/hooks/commit-msg .git/hooks/

# Make executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

echo -e "${GREEN}✓ AICheck git hooks installed successfully${NC}"
echo -e "${BRIGHT_BLURPLE}Hooks will now provide helpful guidance during git commits${NC}"
