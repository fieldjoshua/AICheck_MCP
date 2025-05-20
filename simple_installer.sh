#!/bin/bash

# AICheck MCP - Simple One-Command Installer
# Creates all required directories and files for AICheck MCP

set -e  # Exit on any error

# Colors for pretty output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Banner
echo -e "${BOLD}${BLUE}"
echo "  █████╗ ██╗ ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗"
echo " ██╔══██╗██║██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝"
echo " ███████║██║██║     ███████║█████╗  ██║     █████╔╝ "
echo " ██╔══██║██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ "
echo " ██║  ██║██║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗"
echo " ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${BOLD}${BLUE}Multimodal Control Protocol - Simple Installer${NC}"
echo -e "${BLUE}===============================================${NC}\n"

echo -e "${BLUE}Installing AICheck MCP in current directory...${NC}"

# Create directory structure
echo -e "${BLUE}Creating directory structure...${NC}"
mkdir -p .aicheck/actions
mkdir -p .aicheck/templates/claude
mkdir -p documentation/api documentation/architecture documentation/configuration documentation/dependencies documentation/deployment documentation/testing documentation/user
mkdir -p tests/unit tests/integration tests/e2e tests/fixtures

# Create core files
echo -e "${BLUE}Creating core files...${NC}"
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
cat > .aicheck/rules.md << 'EOL'
# AICheck Rules

This document is the controlling reference for all work managed by the AICheck system in this PROJECT.

## 1. Core Principles

### 1.1 Documentation-First Approach
- Write clear docstrings for all functions and classes
- Include explanatory comments for complex code blocks
- Update README.md with relevant project information
- Create/update API documentation when adding endpoints
- All ACTIONS require their own directory with a documented PLAN before implementation
- PLANs require approval and must detail the ACTION's value to the PROGRAM
- ACTIONS must be TEST-Driven: tests must be created before implementation

### 1.2 Language-Specific Best Practices
- Python: Follow PEP 8 style guidelines with 150 max line length
- JavaScript/TypeScript: Use ESLint and Prettier standards
- Follow language idioms and patterns (pythonic, modern JS/TS)

### 1.3 Quality Standards
- Write unit tests for new functionality
- Maintain test coverage above 80%
- Handle errors explicitly with proper logging
- Use typed interfaces where possible

### 1.4 Security Practices
- Validate all user inputs
- Use parameterized queries for database operations
- Store secrets in environment variables, never in code
- Apply proper authentication and authorization

## 2. Action Management

### 2.1 AI Editor Scope
AI editors may implement without approval:
- Code implementing the ActiveAction plan (after PLAN approval)
- Documentation updates for ActiveAction
- Bug fixes and tests within ActiveAction scope
- Refactoring within ActiveAction scope

The following ALWAYS require human manager approval:
- Changing the ActiveAction
- Creating a new Action
- Making substantive changes to any Action
- Modifying any Action Plan

## 3. Project Structure and Organization

### 3.1 Directory Structure
```text
/
├── .aicheck/
│   ├── actions/                      # All PROJECT ACTIONS
│   │   └── [action-name]/            # Individual ACTION directory
│   │       ├── [action-name]-plan.md # ACTION PLAN (requires approval)
│   │       └── supporting_docs/      # ACTION-specific documentation
│   │           ├── claude-interactions/  # Claude Code logs
│   │           ├── process-tests/        # Temporary tests for ACTION
│   │           └── research/             # Research and notes
│   ├── current_action                # Current ActionActivity for EDITOR
│   ├── actions_index.md              # Master list of all ACTIONS
│   ├── rules.md                      # This document
│   └── templates/                    # Templates for prompts and actions
├── documentation/                    # Permanent PROJECT documentation
│   ├── api/                          # API documentation
│   ├── architecture/                 # System architecture docs
│   ├── configuration/                # Configuration guides
│   ├── dependencies/                 # Dependency documentation
│   ├── deployment/                   # Deployment procedures
│   ├── testing/                      # Testing strategies
│   └── user/                         # User documentation
├── tests/                            # Permanent test suite
│   ├── unit/                         # Unit tests
│   ├── integration/                  # Integration tests
│   ├── e2e/                          # End-to-end tests
│   └── fixtures/                     # Test data and fixtures
```

## 4. Dependency Management

### 4.1 External Dependencies
- All external dependencies must be documented in /documentation/dependencies/dependency_index.md
- Include justification for every new dependency added
- Document specific version requirements
- Note which ACTIONS depend on each dependency

### 4.2 Internal Dependencies
- Document dependencies between ACTIONS
- Track which ACTIONS depend on others' functionality
- Document the type of dependency (data, function, service)
- Always verify dependencies before completing an ACTION

## 5. AICheck Commands

Claude Code supports these AICheck slash commands:
- `/aicheck status` - Show current action status
- `/aicheck action new ActionName` - Create a new action
- `/aicheck action set ActionName` - Set current active action
- `/aicheck action complete [ActionName]` - Complete action
- `/aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `/aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency
- `/aicheck exec` - Toggle exec mode for system maintenance
EOL

# Create README.md
cat > README.md << 'EOL'
# AICheck MCP Project

This project uses AICheck Multimodal Control Protocol for AI-assisted development.

## Claude Code Commands

Claude Code now supports the following AICheck slash commands:

- `/aicheck status` - Show current action status
- `/aicheck action new ActionName` - Create a new action
- `/aicheck action set ActionName` - Set current active action
- `/aicheck action complete [ActionName]` - Complete action with dependency verification
- `/aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `/aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency
- `/aicheck exec` - Toggle exec mode for system maintenance

## Project Structure

The AICheck system follows a structured approach to development:

- `.aicheck/` - Contains all AICheck system files
  - `actions/` - Individual actions with plans and documentation
  - `templates/` - Templates for Claude prompts
  - `rules.md` - AICheck system rules
- `documentation/` - Project documentation
- `tests/` - Test suite

## Getting Started

1. Review the AICheck rules in `.aicheck/rules.md`
2. Create a new action with `/aicheck action new ActionName`
3. Plan your action in the generated plan file
4. Set it as your active action with `/aicheck action set ActionName`
5. Implement according to the plan
EOL

# Create git hooks directory
if [ -d ".git" ]; then
  mkdir -p .git/hooks
  
  # Create pre-commit hook
  cat > .git/hooks/pre-commit << 'EOL'
#!/bin/bash
# AICheck pre-commit hook
exit 0  # Non-blocking hook for now
EOL
  chmod +x .git/hooks/pre-commit
  
  # Create commit-msg hook
  cat > .git/hooks/commit-msg << 'EOL'
#!/bin/bash
# AICheck commit-msg hook
exit 0  # Non-blocking hook for now
EOL
  chmod +x .git/hooks/commit-msg
fi

# Create activation text
cat > .aicheck/activation.md << 'EOL'
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
EOL

# Copy to clipboard if possible
if command -v pbcopy >/dev/null 2>&1; then
  cat .aicheck/activation.md | pbcopy
  CLIPBOARD="copied to clipboard"
elif command -v xclip >/dev/null 2>&1; then
  cat .aicheck/activation.md | xclip -selection clipboard
  CLIPBOARD="copied to clipboard"
else
  CLIPBOARD="ready to copy manually"
fi

# Done!
echo -e "\n${GREEN}${BOLD}✓ AICheck MCP installed successfully!${NC}"
echo -e "${GREEN}Directory structure and core files created in current directory.${NC}\n"

# Display activation text
echo -e "${BOLD}${BLUE}TO ACTIVATE AICHECK:${NC}"
echo -e "${BLUE}Activation text ${CLIPBOARD}. Paste to Claude in a new conversation:${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
cat .aicheck/activation.md
echo -e "${BLUE}---------------------------------------------------------------------${NC}"