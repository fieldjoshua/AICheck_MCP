#!/bin/bash

# Script to integrate git hook rules into AICheck setup

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Integrating git hook rules into AICheck setup...${NC}"

# Read git hook rules
GIT_HOOK_RULES=$(cat git_hook_rules.md)

# Add to setup_aicheck_complete.sh
sed -i '/### 1.5 Dependency Management/r git_hook_rules.md' setup_aicheck_complete.sh

# Update Claude.md template in the script
sed -i '/^# Create a custom CLAUDE.md file with AICheck integration/,/^EOL/ {
    /6. Document all dependencies before completing an action/a \
7. Immediately respond to git hook suggestions before continuing work
}' setup_aicheck_complete.sh

# Add git hook installation to the script
sed -i '/echo -e "  ${BLUE}\/aicheck dependency internal DEP_ACTION ACTION TYPE \[DESCRIPTION\]${NC} - Add internal dependency"/a \\\necho -e "\\nSetting up AICheck git hooks..."\n./setup_aicheck_hooks.sh' setup_aicheck_complete.sh

# Update claude_aicheck_prompt.md section
sed -i '/^# Create a file to inject AICheck awareness in Claude conversations/,/^EOL/ {
    /3. Dependency Management:/a \\\n4. Git Hook Compliance:\\\n   - Immediately respond to git hook suggestions\\\n   - Address issues before continuing with new work\\\n   - Follow commit message format guidelines\\\n   - Document dependency changes promptly\\\n   - Ensure test-driven development compliance
}' setup_aicheck_complete.sh

echo -e "${GREEN}✓ Integrated git hook rules into AICheck setup${NC}"
echo -e "\nChanges made:"
echo -e "  - Added Git Hook Compliance section to RULES.md"
echo -e "  - Updated CLAUDE.md template to include git hook compliance"
echo -e "  - Added git hook installation to setup script"
echo -e "  - Updated Claude prompt to include git hook awareness"

echo -e "\nRun setup_aicheck_complete.sh to install with hook compliance"