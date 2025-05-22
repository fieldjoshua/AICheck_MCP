#!/bin/bash

# Script to set up AICheck MCP for a new project
# Creates .aicheck directory with RULES.md and sets up CLAUDE.md with common commands

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up AICheck MCP for your project...${NC}"

# Create .aicheck directory structure
mkdir -p .aicheck/actions
mkdir -p .aicheck/templates/claude
mkdir -p documentation/api
mkdir -p documentation/architecture
mkdir -p documentation/configuration
mkdir -p documentation/deployment
mkdir -p documentation/testing
mkdir -p documentation/user
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p tests/e2e
mkdir -p tests/fixtures

echo -e "${GREEN}✓ Created AICheck directory structure${NC}"

# Create actions_index.md
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

echo -e "${GREEN}✓ Created actions_index.md${NC}"

# Create current_action file
echo "None" > .aicheck/current_action

echo -e "${GREEN}✓ Created current_action file${NC}"

# Create RULES.md with template content
cat > .aicheck/RULES.md << 'EOL'
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
│   ├── deployment/                   # Deployment procedures
│   ├── testing/                      # Testing strategies
│   └── user/                         # User documentation
├── tests/                            # Permanent test suite
│   ├── unit/                         # Unit tests
│   ├── integration/                  # Integration tests
│   ├── e2e/                          # End-to-end tests
│   └── fixtures/                     # Test data and fixtures
```
EOL

# Create or update user's global CLAUDE.md if requested
echo -e "${BLUE}Do you want to create/update your global CLAUDE.md file? (y/n)${NC}"
read -r update_claude_md

if [[ $update_claude_md == "y" || $update_claude_md == "Y" ]]; then
  mkdir -p ~/.claude
  
  # Prompt for common commands
  echo -e "${BLUE}Enter build command (e.g., npm run build):${NC}"
  read -r build_cmd
  
  echo -e "${BLUE}Enter development command (e.g., npm run dev):${NC}"
  read -r dev_cmd
  
  echo -e "${BLUE}Enter lint command (e.g., npm run lint):${NC}"
  read -r lint_cmd
  
  echo -e "${BLUE}Enter type check command (e.g., npm run type-check):${NC}"
  read -r typecheck_cmd
  
  echo -e "${BLUE}Enter test command (e.g., npm test):${NC}"
  read -r test_cmd
  
  # Create CLAUDE.md with the provided commands
  cat > ~/.claude/CLAUDE.md << EOL
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Rules

Claude should follow the rules specified in \`.aicheck/RULES.md\` with focus on documentation-first approach and adherence to language-specific best practices.

## Build & Development Commands

- Build: \`$build_cmd\`
- Development: \`$dev_cmd\`
- Lint: \`$lint_cmd\`
- Type check: \`$typecheck_cmd\`
- Test: \`$test_cmd\`

## Code Style Guidelines

- Follow project-specific linting rules
- Document functions and complex logic
- Use consistent naming conventions
- Maintain test coverage for new code
EOL

  echo -e "${GREEN}Global CLAUDE.md created at ~/.claude/CLAUDE.md${NC}"
else
  echo -e "${BLUE}Skipping global CLAUDE.md creation${NC}"
fi

# Create a project-specific CLAUDE.md if requested
echo -e "${BLUE}Do you want to create a project-specific CLAUDE.md in this directory? (y/n)${NC}"
read -r create_project_claude

if [[ $create_project_claude == "y" || $create_project_claude == "Y" ]]; then
  # Prompt for project-specific commands
  echo -e "${BLUE}Enter project-specific build command:${NC}"
  read -r p_build_cmd
  
  echo -e "${BLUE}Enter project-specific development command:${NC}"
  read -r p_dev_cmd
  
  echo -e "${BLUE}Enter project-specific lint command:${NC}"
  read -r p_lint_cmd
  
  echo -e "${BLUE}Enter project-specific test command:${NC}"
  read -r p_test_cmd
  
  # Create project-specific CLAUDE.md
  cat > CLAUDE.md << EOL
# Project-Specific Guidelines for Claude

## Project Commands

- Build: \`$p_build_cmd\`
- Development: \`$p_dev_cmd\`
- Lint: \`$p_lint_cmd\`
- Test: \`$p_test_cmd\`

## Project Structure

This is a placeholder for your project structure description.
Describe your key directories and files here to help Claude understand the codebase.

## Additional Guidelines

- Project follows AICheck guidelines in .aicheck/RULES.md
- Refer to the global CLAUDE.md for general practices
EOL

  echo -e "${GREEN}Project-specific CLAUDE.md created in the current directory${NC}"
else
  echo -e "${BLUE}Skipping project-specific CLAUDE.md creation${NC}"
fi

# Create claude prompt templates
mkdir -p .aicheck/templates/claude

# Create basic implementation template
cat > .aicheck/templates/claude/basic-implementation.md << 'EOL'
# Implementation Prompt Template

## Context

- ACTION: [action-name]
- PLAN Section: [specific section reference]
- System Components: [related components]

## Requirements

- Implement [specific functionality]
- Ensure the implementation follows the test requirements
- Follow [language] best practices
- Consider error handling for edge cases

## Existing Code Reference

```
[example of similar code or patterns to follow]
```

## Expected Output

- Implementation that passes provided tests
- Clean, well-structured code following project conventions
- Appropriate error handling and logging
- Proper documentation

## Success Criteria

- All tests pass
- Code follows ACTION specifications
- Documentation is complete
- No security vulnerabilities introduced
EOL

# Create test generation template
cat > .aicheck/templates/claude/test-generation.md << 'EOL'
# Test Generation Prompt Template

## Context

- ACTION: [action-name]
- PLAN Section: [specific section reference]
- Testing Approach: [unit/integration/e2e]

## Requirements

- Create tests for [specific functionality]
- Cover expected behavior and edge cases
- Mock dependencies appropriately
- Follow project test patterns

## Test Cases to Cover

1. [test case 1]
2. [test case 2]
3. [edge case 1]
4. [error condition 1]

## Existing Test Reference

```
[example of similar tests to follow]
```

## Expected Output

- Complete test suite for the functionality
- Well-structured tests following project patterns
- Clear descriptions of what each test validates
- Comprehensive coverage of requirements
EOL

echo -e "${GREEN}✓ Created Claude prompt templates${NC}"

# Create Claude Code slash command script in .claudecode directory
mkdir -p ~/.claudecode

cat > ~/.claudecode/aicheck_commands.sh << 'EOL'
#!/bin/bash

# AICheck command implementation for Claude Code

set -e

CMD=$1
shift
ARGS=$@

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

function create_action() {
  local action_name=$1
  
  if [ -z "$action_name" ]; then
    echo -e "${RED}Error: Action name is required${NC}"
    echo "Usage: /aicheck action new ACTION_NAME"
    exit 1
  fi
  
  # Convert PascalCase to kebab-case for directories
  local dir_name=$(echo "$action_name" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  
  # Create action directory
  mkdir -p ".aicheck/actions/$dir_name"
  mkdir -p ".aicheck/actions/$dir_name/supporting_docs/claude-interactions"
  mkdir -p ".aicheck/actions/$dir_name/supporting_docs/process-tests"
  mkdir -p ".aicheck/actions/$dir_name/supporting_docs/research"
  
  # Create plan file
  cat > ".aicheck/actions/$dir_name/$dir_name-plan.md" << PLAN
# ACTION: $action_name

Version: 1.0
Last Updated: $(date +"%Y-%m-%d")
Status: Not Started
Progress: 0%

## Purpose

[Describe the purpose of this ACTION and its value to the PROGRAM]

## Requirements

- [Requirement 1]
- [Requirement 2]

## Dependencies

- [Dependency 1, if any]

## Implementation Approach

### Phase 1: Research

- [Research task 1]
- [Research task 2]

### Phase 2: Design

- [Design task 1]
- [Design task 2]

### Phase 3: Implementation

- [Implementation task 1]
- [Implementation task 2]

### Phase 4: Testing

- [Test case 1]
- [Test case 2]

## Success Criteria

- [Criterion 1]
- [Criterion 2]

## Estimated Timeline

- Research: [X days]
- Design: [X days]
- Implementation: [X days]
- Testing: [X days]
- Total: [X days]

## Notes

[Any additional notes or considerations]
PLAN
  
  # Create status file
  echo "Not Started" > ".aicheck/actions/$dir_name/status.txt"
  
  # Create progress file
  echo "# $action_name Progress

## Updates

$(date +"%Y-%m-%d") - Action created

## Tasks

- [ ] Research phase
- [ ] Design phase
- [ ] Implementation phase
- [ ] Testing phase
- [ ] Documentation
" > ".aicheck/actions/$dir_name/progress.md"
  
  # Update actions_index.md
  # Get the line number of the "Active Actions" table's end
  line_num=$(grep -n "\| \*None yet\* \| \| \| \| \|" .aicheck/actions_index.md | cut -d':' -f1)
  
  if [ -n "$line_num" ]; then
    # Replace the "None yet" line with the new action
    sed -i "$line_num s/| \*None yet\* | | | | |/| $action_name | | Not Started | 0% | |\n| \*None yet\* | | | | |/" .aicheck/actions_index.md
  else
    # Append to the Active Actions table
    line_num=$(grep -n "## Active Actions" .aicheck/actions_index.md | cut -d':' -f1)
    if [ -n "$line_num" ]; then
      awk -v line="$line_num" -v action="| $action_name | | Not Started | 0% | |" 'NR==line+4{print action}1' .aicheck/actions_index.md > .aicheck/actions_index.md.tmp
      mv .aicheck/actions_index.md.tmp .aicheck/actions_index.md
    fi
  fi
  
  # Update last updated date
  sed -i "s/\*Last Updated: .*\*/\*Last Updated: $(date +"%Y-%m-%d")\*/" .aicheck/actions_index.md
  
  echo -e "${GREEN}✓ Created new ACTION: $action_name${NC}"
  echo -e "${BLUE}Directory: .aicheck/actions/$dir_name${NC}"
  echo -e "${YELLOW}NOTE: This ACTION requires planning and approval before implementation${NC}"
}

function set_active_action() {
  local action_name=$1
  
  if [ -z "$action_name" ]; then
    echo -e "${RED}Error: Action name is required${NC}"
    echo "Usage: /aicheck action set ACTION_NAME"
    exit 1
  fi
  
  # Convert PascalCase to kebab-case for directories
  local dir_name=$(echo "$action_name" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  
  # Check if action exists
  if [ ! -d ".aicheck/actions/$dir_name" ]; then
    echo -e "${RED}Error: Action '$action_name' does not exist${NC}"
    echo "Available actions:"
    ls -1 .aicheck/actions/ | grep -v "README"
    exit 1
  fi
  
  # Set as current action
  echo "$action_name" > .aicheck/current_action
  
  # Update status to ActiveAction if not already
  if [ "$(cat ".aicheck/actions/$dir_name/status.txt")" != "ActiveAction" ]; then
    echo "ActiveAction" > ".aicheck/actions/$dir_name/status.txt"
    
    # Update actions_index.md
    sed -i "s/| $action_name | .* | [^|]* | [^|]* | /| $action_name | | ActiveAction | 0% | /" .aicheck/actions_index.md
    
    # Update last updated date
    sed -i "s/\*Last Updated: .*\*/\*Last Updated: $(date +"%Y-%m-%d")\*/" .aicheck/actions_index.md
  fi
  
  echo -e "${GREEN}✓ Set current action to: $action_name${NC}"
}

function exec_mode() {
  # Save current action
  local current_action=$(cat .aicheck/current_action)
  
  if [ "$current_action" = "AICheckExec" ]; then
    # Exit exec mode, return to previous action
    if [ -f .aicheck/previous_action ]; then
      local previous_action=$(cat .aicheck/previous_action)
      echo "$previous_action" > .aicheck/current_action
      rm .aicheck/previous_action
      echo -e "${GREEN}✓ Exited Exec Mode${NC}"
      echo -e "${BLUE}Returned to action: $previous_action${NC}"
    else
      echo "None" > .aicheck/current_action
      echo -e "${GREEN}✓ Exited Exec Mode${NC}"
      echo -e "${BLUE}No previous action found${NC}"
    fi
  else
    # Enter exec mode, save current action
    echo "$current_action" > .aicheck/previous_action
    echo "AICheckExec" > .aicheck/current_action
    echo -e "${GREEN}✓ Entered AICheck Exec Mode${NC}"
    echo -e "${YELLOW}NOTE: Exec Mode is for system maintenance only${NC}"
    echo -e "${YELLOW}No substantive code changes should be made in this mode${NC}"
  fi
}

function show_status() {
  local current_action=$(cat .aicheck/current_action)
  
  echo -e "${BLUE}AICheck Status${NC}"
  echo -e "-------------------"
  echo -e "Current Action: ${GREEN}$current_action${NC}"
  
  if [ "$current_action" != "None" ] && [ "$current_action" != "AICheckExec" ]; then
    # Convert PascalCase to kebab-case for directories
    local dir_name=$(echo "$current_action" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
    
    local status=$(cat ".aicheck/actions/$dir_name/status.txt")
    local progress=$(grep "Progress:" ".aicheck/actions/$dir_name/$dir_name-plan.md" | cut -d':' -f2 | tr -d ' %')
    
    echo -e "Status: ${GREEN}$status${NC}"
    echo -e "Progress: ${GREEN}$progress%${NC}"
    echo -e "Plan: ${BLUE}.aicheck/actions/$dir_name/$dir_name-plan.md${NC}"
  elif [ "$current_action" = "AICheckExec" ]; then
    echo -e "${YELLOW}SYSTEM IS IN EXEC MODE${NC}"
    echo -e "${YELLOW}For system maintenance only${NC}"
    if [ -f .aicheck/previous_action ]; then
      local previous_action=$(cat .aicheck/previous_action)
      echo -e "Previous action: ${BLUE}$previous_action${NC} (will be restored on exec mode exit)"
    fi
  fi
  
  echo -e "\nActive Actions:"
  grep -A 5 "## Active Actions" .aicheck/actions_index.md | tail -n +4 | grep -v "\*None yet\*" | grep -v "^$"
}

# Main command handling
case "$CMD" in
  "action")
    case "$1" in
      "new")
        create_action "$2"
        ;;
      "set")
        set_active_action "$2"
        ;;
      *)
        echo -e "${RED}Unknown action command: $1${NC}"
        echo "Available commands: new, set"
        ;;
    esac
    ;;
  "exec")
    exec_mode
    ;;
  "status")
    show_status
    ;;
  *)
    echo -e "${RED}Unknown command: $CMD${NC}"
    echo "Available commands: action, exec, status"
    ;;
esac
EOL

chmod +x ~/.claudecode/aicheck_commands.sh

echo -e "${GREEN}✓ Created AICheck slash commands for Claude Code${NC}"

# Create Claude Code instructions in the README.md
cat > README.md << 'EOL'
# AICheck MCP Project

This project uses AICheck Multimodal Control Protocol for AI-assisted development.

## Claude Code Commands

Claude Code now supports the following AICheck slash commands:

- `/aicheck action new ActionName` - Create a new action
- `/aicheck action set ActionName` - Set the current active action
- `/aicheck exec` - Toggle exec mode for system maintenance
- `/aicheck status` - Show the current action status

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

## Documentation-First Approach

AICheck follows a documentation-first, test-driven approach:

1. Document your plan thoroughly before implementation
2. Write tests before implementing features
3. Keep documentation updated as the project evolves
4. Migrate completed action documentation to the central documentation directories
EOL

echo -e "${GREEN}✓ Created project README.md${NC}"

echo -e "${GREEN}AICheck MCP setup complete!${NC}"
echo -e "\nYou can now use Claude Code with your project and it will follow the guidelines in .aicheck/RULES.md"
echo -e "\nAvailable Claude Code slash commands:"
echo -e "  ${BLUE}/aicheck action new ActionName${NC} - Create a new action"
echo -e "  ${BLUE}/aicheck action set ActionName${NC} - Set the current active action"
echo -e "  ${BLUE}/aicheck exec${NC} - Toggle exec mode for system maintenance"
echo -e "  ${BLUE}/aicheck status${NC} - Show the current action status"