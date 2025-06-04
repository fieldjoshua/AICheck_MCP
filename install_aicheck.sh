#!/bin/bash

# Single-command AICheck MCP installer
# Run this in your project directory

set -e  # Exit on any error

GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}AICheck MCP - Single-Step Installer${NC}"
echo -e "${BLUE}Installing directly in current directory...${NC}\n"

# Create directory structure
mkdir -p .aicheck/actions
mkdir -p .aicheck/templates/claude
mkdir -p documentation/api documentation/architecture documentation/configuration documentation/dependencies documentation/deployment documentation/testing documentation/user
mkdir -p tests/unit tests/integration tests/e2e tests/fixtures

# Create core files
echo "None" > .aicheck/current_action

# Create actions index
cat > .aicheck/actions_index.md << 'EOL'
# Actions Index

This document tracks all ACTIONS in the PROJECT. All ACTIONS must be registered here.

## Active Actions

| ACTION | Owner | Status | Progress | Description |
|--------|-------|--------|----------|-------------|
| *None yet* | | | | |

## Completed Actions

| ACTION | Owner | Completion Date | Description |
|--------|-------|-----------------|-------------|
| *None yet* | | | |

## Blocked/On Hold Actions

| ACTION | Owner | Status | Blocker | Description |
|--------|-------|--------|---------|-------------|
| *None yet* | | | | |

---
*Last Updated: $(date +"%Y-%m-%d")*
EOL

# Create dependency index
mkdir -p documentation/dependencies
cat > documentation/dependencies/dependency_index.md << 'EOL'
# Dependency Index

This document tracks all dependencies in the PROJECT. All dependencies must be registered here.

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
EOL

# Create rules file
curl -s https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.aicheck/rules.md > .aicheck/rules.md

# Create git hooks directory
mkdir -p .git/hooks 2>/dev/null || true

# Create git hooks
cat > .git/hooks/pre-commit << 'EOL'
#!/bin/bash
# AICheck pre-commit hook
exit 0  # Non-blocking hook for now
EOL
chmod +x .git/hooks/pre-commit

cat > .git/hooks/commit-msg << 'EOL'
#!/bin/bash
# AICheck commit-msg hook
exit 0  # Non-blocking hook for now
EOL
chmod +x .git/hooks/commit-msg

# Done!
echo -e "\n${GREEN}${BOLD}✓ AICheck MCP installed successfully!${NC}"
echo -e "${GREEN}Directory structure and core files created in current directory.${NC}\n"

# Display activation text clearly
echo -e "${BLUE}${BOLD}TO ACTIVATE AICHECK:${NC}"
echo -e "${BLUE}Copy everything between the lines and paste to Claude in a new conversation:${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
cat << 'ACTIVATION'
# AICheck System Integration

I notice this project is using the AICheck Multimodal Control Protocol. Let me check the current action status.

I'll follow the AICheck workflow and adhere to the rules in `.aicheck/RULES.md`. This includes:

1. Using the slash commands: 
   - `/aicheck status` to check current action
   - `/aicheck action new/set/complete` to manage actions
   - `/aicheck dependency add/internal` to document dependencies
   - `/aicheck exec` for maintenance mode

2. Following the documentation-first approach:
   - Writing tests before implementation
   - Documenting all Claude interactions
   - Adhering to the ACTION plan
   - Focusing only on the active action's scope
   - Documenting all dependencies

3. Dependency Management:
   - Documenting all external dependencies
   - Recording all internal dependencies between actions
   - Verifying dependencies before completing actions

4. Git Hook Compliance:
   - Immediately respond to git hook suggestions
   - Address issues before continuing with new work
   - Follow commit message format guidelines
   - Document dependency changes promptly
   - Ensure test-driven development compliance

Let me check the current action status now with `/aicheck status` and proceed accordingly.
ACTIVATION
echo -e "${BLUE}---------------------------------------------------------------------${NC}"