#!/bin/bash

# Script to set up a persistent AICheck status bar
# Works with tmux or as a shell prompt enhancement

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up AICheck status display...${NC}"

# Create the status update script
mkdir -p ~/.aicheck

cat > ~/.aicheck/status_update.sh << 'EOL'
#!/bin/bash

# AICheck status update script - provides current action and git status

# Colors for status bar
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BOLD="\033[1m"
NC="\033[0m" # No Color

# Function to get current action info
get_action_info() {
  if [ ! -f ".aicheck/current_action" ]; then
    echo "No AICheck"
    return
  fi
  
  local current_action=$(cat .aicheck/current_action)
  
  if [ "$current_action" = "None" ]; then
    echo "AICheck: ${YELLOW}No Active Action${NC}"
    return
  elif [ "$current_action" = "AICheckExec" ]; then
    echo "AICheck: ${RED}Exec Mode${NC}"
    return
  fi
  
  # Convert PascalCase to kebab-case for directories
  local dir_name=$(echo "$current_action" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  
  if [ ! -d ".aicheck/actions/$dir_name" ]; then
    echo "AICheck: ${RED}Error: Invalid Action${NC}"
    return
  fi
  
  local status=$(cat ".aicheck/actions/$dir_name/status.txt" 2>/dev/null || echo "Unknown")
  local progress=$(grep "Progress:" ".aicheck/actions/$dir_name/$dir_name-plan.md" 2>/dev/null | cut -d':' -f2 | tr -d ' %' || echo "0")
  
  local dep_count=0
  if [ -f "documentation/dependencies/dependency_index.md" ]; then
    dep_count=$(grep -c "$current_action" documentation/dependencies/dependency_index.md || echo "0")
  fi
  
  echo "Action: ${BOLD}${current_action}${NC} | Status: ${BLUE}${status}${NC} | Progress: ${GREEN}${progress}%${NC} | Deps: ${dep_count}"
}

# Function to get git status
get_git_status() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "No Git"
    return
  fi
  
  local branch=$(git branch --show-current 2>/dev/null)
  local last_commit_time=$(git log -1 --format="%cr" 2>/dev/null || echo "never")
  local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  
  if [ "$changes" -gt 0 ]; then
    changes="${RED}${changes} changes${NC}"
  else
    changes="${GREEN}Clean${NC}"
  fi
  
  echo "Git: ${BOLD}${branch}${NC} | Last commit: ${BLUE}${last_commit_time}${NC} | Status: ${changes}"
}

# Output based on format request
case "$1" in
  "tmux")
    echo "$(get_action_info) | $(get_git_status)"
    ;;
  "prompt")
    echo "[$(get_action_info)]"
    ;;
  *)
    echo "AICheck Status:"
    echo "$(get_action_info)"
    echo "$(get_git_status)"
    ;;
esac
EOL

chmod +x ~/.aicheck/status_update.sh

# Option 1: tmux integration
if command -v tmux >/dev/null 2>&1; then
  echo -e "${GREEN}Found tmux, setting up status bar integration${NC}"
  
  # Create or update tmux config
  if [ ! -f ~/.tmux.conf ]; then
    echo "# AICheck status bar configuration" > ~/.tmux.conf
  fi
  
  # Check if AICheck is already in tmux config
  if ! grep -q "AICheck status" ~/.tmux.conf; then
    cat >> ~/.tmux.conf << 'EOL'

# AICheck status bar configuration
set -g status-interval 10
set -g status-right "#[fg=green]#(~/.aicheck/status_update.sh tmux)"
set -g status-right-length 100
EOL
    echo -e "${GREEN}✓ Added AICheck status to tmux configuration${NC}"
    echo -e "${YELLOW}Restart tmux or run 'tmux source-file ~/.tmux.conf' to apply changes${NC}"
  else
    echo -e "${YELLOW}AICheck status already configured in tmux${NC}"
  fi
fi

# Option 2: Shell prompt integration
echo -e "${BLUE}Setting up shell prompt integration${NC}"

# For Bash
if [ -f ~/.bashrc ]; then
  if ! grep -q "AICheck prompt" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOL'

# AICheck prompt integration
aicheck_prompt() {
  if [ -f ".aicheck/current_action" ]; then
    echo "$(/bin/bash ~/.aicheck/status_update.sh prompt) "
  fi
}
export PS1="\$(aicheck_prompt)$PS1"
EOL
    echo -e "${GREEN}✓ Added AICheck status to bash prompt${NC}"
  else
    echo -e "${YELLOW}AICheck status already configured in bash prompt${NC}"
  fi
fi

# For Zsh
if [ -f ~/.zshrc ]; then
  if ! grep -q "AICheck prompt" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOL'

# AICheck prompt integration
aicheck_prompt() {
  if [ -f ".aicheck/current_action" ]; then
    echo "$(/bin/bash ~/.aicheck/status_update.sh prompt) "
  fi
}
export PROMPT='$(aicheck_prompt)'$PROMPT
EOL
    echo -e "${GREEN}✓ Added AICheck status to zsh prompt${NC}"
  else
    echo -e "${YELLOW}AICheck status already configured in zsh prompt${NC}"
  fi
fi

# Create a simple status checker command
cat > ~/.aicheck/aicheck_status << 'EOL'
#!/bin/bash
~/.aicheck/status_update.sh
EOL

chmod +x ~/.aicheck/aicheck_status

# Add to PATH
echo 'export PATH="$HOME/.aicheck:$PATH"' >> ~/.bashrc
echo 'export PATH="$HOME/.aicheck:$PATH"' >> ~/.zshrc

echo -e "${GREEN}✓ Added aicheck_status command${NC}"

echo -e "\n${GREEN}AICheck status display setup complete!${NC}"
echo -e "\nOptions for accessing status information:"
echo -e "1. ${BLUE}tmux status bar${NC} - If using tmux, status appears at bottom of screen"
echo -e "2. ${BLUE}Shell prompt${NC} - Status appears before each command prompt"
echo -e "3. ${BLUE}aicheck_status${NC} - Run this command anytime to see current status"
echo -e "\n${YELLOW}Note: You may need to restart your terminal or run 'source ~/.bashrc' to apply changes${NC}"