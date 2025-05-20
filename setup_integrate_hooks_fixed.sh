#!/bin/bash

# Script to integrate git hook rules into AICheck setup
# Fixed version for macOS compatibility

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Integrating git hook rules into AICheck setup...${NC}"

# Read git hook rules
GIT_HOOK_RULES=$(cat git_hook_rules.md)

# Add to setup_aicheck_complete.sh - manually insert at the right place
echo -e "${BLUE}Adding git hook compliance rules to setup script...${NC}"
awk '
/### 1.5 Dependency Management/ {
  print;
  while(getline line < "git_hook_rules.md") {
    print line;
  }
  next;
}
{print}
' setup_aicheck_complete.sh > setup_aicheck_complete.sh.tmp
mv setup_aicheck_complete.sh.tmp setup_aicheck_complete.sh

# Update Claude.md template in the script
echo -e "${BLUE}Updating CLAUDE.md template in setup script...${NC}"
awk '
/6. Document all dependencies before completing an action/ {
  print;
  print "7. Immediately respond to git hook suggestions before continuing work";
  next;
}
{print}
' setup_aicheck_complete.sh > setup_aicheck_complete.sh.tmp
mv setup_aicheck_complete.sh.tmp setup_aicheck_complete.sh

# Add git hook installation to the script
echo -e "${BLUE}Adding git hook installation to setup script...${NC}"
awk '
/echo -e "  \${BLUE}\/aicheck dependency internal DEP_ACTION ACTION TYPE \[DESCRIPTION\]\${NC} - Add internal dependency"/ {
  print;
  print "\necho -e \"\\nSetting up AICheck git hooks...\"";
  print "./setup_aicheck_hooks.sh";
  next;
}
{print}
' setup_aicheck_complete.sh > setup_aicheck_complete.sh.tmp
mv setup_aicheck_complete.sh.tmp setup_aicheck_complete.sh

# Update claude_aicheck_prompt.md section
echo -e "${BLUE}Updating Claude prompt template in setup script...${NC}"
awk '
/3. Dependency Management:/ {
  print;
  print "   - Documenting all external dependencies";
  print "   - Recording all internal dependencies between actions";
  print "   - Verifying dependencies before completing actions";
  print "";
  print "4. Git Hook Compliance:";
  print "   - Immediately respond to git hook suggestions";
  print "   - Address issues before continuing with new work";
  print "   - Follow commit message format guidelines";
  print "   - Document dependency changes promptly";
  print "   - Ensure test-driven development compliance";
  getline;
  getline;
  getline;
  next;
}
{print}
' setup_aicheck_complete.sh > setup_aicheck_complete.sh.tmp
mv setup_aicheck_complete.sh.tmp setup_aicheck_complete.sh

# Make sure script is executable
chmod +x setup_aicheck_complete.sh

echo -e "${GREEN}✓ Integrated git hook rules into AICheck setup${NC}"
echo -e "\nChanges made:"
echo -e "  - Added Git Hook Compliance section to RULES.md"
echo -e "  - Updated CLAUDE.md template to include git hook compliance"
echo -e "  - Added git hook installation to setup script"
echo -e "  - Updated Claude prompt to include git hook awareness"

echo -e "\nRun setup_aicheck_complete.sh to install with hook compliance"