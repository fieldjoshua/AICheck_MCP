#!/bin/bash

# Enhanced script to fully automate AICheck MCP setup with Claude integration
# 1. Sets up AICheck directory structure
# 2. Adds slash commands to Claude Code
# 3. Creates an initial prompt for Claude to use AICheck

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
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
mkdir -p documentation/dependencies
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p tests/e2e
mkdir -p tests/fixtures

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

### 1.5 Dependency Management
- All external dependencies must be documented in dependency_index.md
- All internal dependencies between actions must be documented
- External dependencies require justification and version specification
- Dependencies must be verified before action completion

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
│   │   └── dependency_index.md       # Index of all dependencies
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

function add_dependency() {
  local dependency_name=$1
  local version=$2
  local justification=$3
  local action=$4
  
  if [ -z "$dependency_name" ] || [ -z "$version" ] || [ -z "$justification" ]; then
    echo -e "${RED}Error: Missing required parameters${NC}"
    echo "Usage: /aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]"
    exit 1
  fi
  
  # Current date
  local date_added=$(date +"%Y-%m-%d")
  
  # Current user
  local added_by=$(whoami)
  
  # Current action if not specified
  if [ -z "$action" ]; then
    action=$(cat .aicheck/current_action)
    if [ "$action" = "None" ] || [ "$action" = "AICheckExec" ]; then
      action="N/A"
    fi
  fi
  
  # Check if dependency index exists
  if [ ! -f "documentation/dependencies/dependency_index.md" ]; then
    mkdir -p documentation/dependencies
    cat > documentation/dependencies/dependency_index.md << END_INDEX
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
END_INDEX
  fi
  
  # Get the line number of the "External Dependencies" table's end
  line_num=$(grep -n "\| \*None yet\* \| \| \| \| \| \|" documentation/dependencies/dependency_index.md | head -1 | cut -d':' -f1)
  
  if [ -n "$line_num" ]; then
    # Replace the "None yet" line with the new dependency
    sed -i "$line_num s/| \*None yet\* | | | | | |/| $dependency_name | $version | $added_by | $date_added | $justification | $action |\\n| \*None yet\* | | | | | |/" documentation/dependencies/dependency_index.md
  else
    # Find the line after the header row
    line_num=$(grep -n "\| Dependency \| Version \| Added By \| Date Added \| Justification \| Actions Using \|" documentation/dependencies/dependency_index.md | cut -d':' -f1)
    if [ -n "$line_num" ]; then
      line_num=$((line_num + 2)) # Skip the header separator line
      awk -v line="$line_num" -v dep="| $dependency_name | $version | $added_by | $date_added | $justification | $action |" 'NR==line{print dep}1' documentation/dependencies/dependency_index.md > documentation/dependencies/dependency_index.md.tmp
      mv documentation/dependencies/dependency_index.md.tmp documentation/dependencies/dependency_index.md
    fi
  fi
  
  # Update last updated date
  sed -i "s/\*Last Updated: .*\*/\*Last Updated: $date_added\*/" documentation/dependencies/dependency_index.md
  
  echo -e "${GREEN}✓ Added dependency: $dependency_name (version $version)${NC}"
  echo -e "${BLUE}For action: $action${NC}"
}

function add_internal_dependency() {
  local dependency_action=$1
  local dependent_action=$2
  local dep_type=$3
  local description=$4
  
  if [ -z "$dependency_action" ] || [ -z "$dependent_action" ] || [ -z "$dep_type" ]; then
    echo -e "${RED}Error: Missing required parameters${NC}"
    echo "Usage: /aicheck dependency internal DEPENDENCY_ACTION DEPENDENT_ACTION TYPE [DESCRIPTION]"
    exit 1
  fi
  
  # Current date
  local date_added=$(date +"%Y-%m-%d")
  
  # Check if dependency index exists
  if [ ! -f "documentation/dependencies/dependency_index.md" ]; then
    mkdir -p documentation/dependencies
    cat > documentation/dependencies/dependency_index.md << END_INDEX
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
END_INDEX
  fi
  
  # Get the line number of the "Internal Dependencies" table's end
  line_num=$(grep -n "\| \*None yet\* \| \| \| \| \|" documentation/dependencies/dependency_index.md | tail -1 | cut -d':' -f1)
  
  if [ -n "$line_num" ]; then
    # Replace the "None yet" line with the new dependency
    sed -i "$line_num s/| \*None yet\* | | | | |/| $dependency_action | $dependent_action | $dep_type | $date_added | $description |\\n| \*None yet\* | | | | |/" documentation/dependencies/dependency_index.md
  else
    # Find the line after the header row
    line_num=$(grep -n "\| Dependency Action \| Dependent Action \| Type \| Date Added \| Description \|" documentation/dependencies/dependency_index.md | cut -d':' -f1)
    if [ -n "$line_num" ]; then
      line_num=$((line_num + 2)) # Skip the header separator line
      awk -v line="$line_num" -v dep="| $dependency_action | $dependent_action | $dep_type | $date_added | $description |" 'NR==line{print dep}1' documentation/dependencies/dependency_index.md > documentation/dependencies/dependency_index.md.tmp
      mv documentation/dependencies/dependency_index.md.tmp documentation/dependencies/dependency_index.md
    fi
  fi
  
  # Update last updated date
  sed -i "s/\*Last Updated: .*\*/\*Last Updated: $date_added\*/" documentation/dependencies/dependency_index.md
  
  echo -e "${GREEN}✓ Added internal dependency: $dependency_action -> $dependent_action (Type: $dep_type)${NC}"
}

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
    sed -i "$line_num s/| \*None yet\* | | | | |/| $action_name | | Not Started | 0% | |\\n| \*None yet\* | | | | |/" .aicheck/actions_index.md
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

function complete_action() {
  local action_name=$1
  
  if [ -z "$action_name" ]; then
    # Use current action if not specified
    action_name=$(cat .aicheck/current_action)
    if [ "$action_name" = "None" ] || [ "$action_name" = "AICheckExec" ]; then
      echo -e "${RED}Error: No active action to complete${NC}"
      echo "Usage: /aicheck action complete [ACTION_NAME]"
      exit 1
    fi
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
  
  # Check for dependencies
  echo -e "${BLUE}Verifying dependencies for $action_name...${NC}"
  
  # Check if any dependencies are recorded for this action
  dependencies_found=$(grep -c "$action_name" documentation/dependencies/dependency_index.md || true)
  
  if [ "$dependencies_found" -eq 0 ]; then
    echo -e "${YELLOW}WARNING: No dependencies found for this action${NC}"
    echo -e "${YELLOW}If this action uses external libraries or depends on other actions,${NC}"
    echo -e "${YELLOW}they should be documented before completing the action.${NC}"
    
    read -p "Do you want to add dependencies now? (y/n): " add_deps
    if [[ "$add_deps" == "y" || "$add_deps" == "Y" ]]; then
      echo -e "${BLUE}Please add dependencies with:${NC}"
      echo "  /aicheck dependency add NAME VERSION JUSTIFICATION"
      echo "  /aicheck dependency internal DEPENDENCY_ACTION ACTION TYPE DESCRIPTION"
      exit 0
    fi
    
    read -p "Confirm action completion without dependencies? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo -e "${YELLOW}Action completion cancelled${NC}"
      exit 0
    fi
  else
    echo -e "${GREEN}✓ Dependencies verified${NC}"
  fi
  
  # Update status to Completed
  echo "Completed" > ".aicheck/actions/$dir_name/status.txt"
  
  # Get completion date
  local completion_date=$(date +"%Y-%m-%d")
  
  # Move from Active to Completed in actions_index.md
  local action_line
  action_line=$(grep -n "| $action_name |" .aicheck/actions_index.md | head -1 | cut -d':' -f1)
  
  if [ -n "$action_line" ]; then
    # Get the description
    local description
    description=$(sed -n "${action_line}p" .aicheck/actions_index.md | awk -F '|' '{print $6}' | xargs)
    
    # Delete the line from Active Actions
    sed -i "${action_line}d" .aicheck/actions_index.md
    
    # Add to Completed Actions
    line_num=$(grep -n "\| \*None yet\* \| \| \| \|" .aicheck/actions_index.md | grep -A1 "Completed Actions" | cut -d':' -f1)
    if [ -n "$line_num" ]; then
      sed -i "${line_num}s/| \*None yet\* | | | |/| $action_name | | $completion_date | $description |\\n| \*None yet\* | | | |/" .aicheck/actions_index.md
    fi
    
    # Update the progress in plan
    sed -i "s/Progress: [0-9]*%/Progress: 100%/" ".aicheck/actions/$dir_name/$dir_name-plan.md"
    
    # Update last updated date
    sed -i "s/\*Last Updated: .*\*/\*Last Updated: $completion_date\*/" .aicheck/actions_index.md
    
    # If this was the current action, set current_action to None
    if [ "$(cat .aicheck/current_action)" = "$action_name" ]; then
      echo "None" > .aicheck/current_action
    fi
    
    echo -e "${GREEN}✓ Completed ACTION: $action_name${NC}"
    echo -e "${BLUE}Completion Date: $completion_date${NC}"
  else
    echo -e "${RED}Error: Could not find action in index${NC}"
    exit 1
  fi
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
    
    # Check if this action has recorded dependencies
    local dep_count=$(grep -c "$current_action" documentation/dependencies/dependency_index.md || true)
    if [ "$dep_count" -gt 0 ]; then
      echo -e "Dependencies: ${GREEN}$dep_count recorded${NC}"
    else
      echo -e "Dependencies: ${YELLOW}None recorded${NC}"
    fi
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
      "complete")
        complete_action "$2"
        ;;
      *)
        echo -e "${RED}Unknown action command: $1${NC}"
        echo "Available commands: new, set, complete"
        ;;
    esac
    ;;
  "dependency" | "dep")
    case "$1" in
      "add")
        add_dependency "$2" "$3" "$4" "$5"
        ;;
      "internal")
        add_internal_dependency "$2" "$3" "$4" "$5"
        ;;
      *)
        echo -e "${RED}Unknown dependency command: $1${NC}"
        echo "Available commands: add, internal"
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
    echo "Available commands: action, dependency, exec, status"
    ;;
esac
EOL

chmod +x ~/.claudecode/aicheck_commands.sh

echo -e "${GREEN}✓ Created AICheck slash commands for Claude Code${NC}"

# Create a link between Claude Code and the AICheck commands
echo 'export PATH="$HOME/.claudecode:$PATH"' >> ~/.zshrc
echo 'export PATH="$HOME/.claudecode:$PATH"' >> ~/.bashrc

echo -e "${GREEN}✓ Added AICheck commands to shell path${NC}"

# Create Claude Code instructions in the README.md
cat > README.md << 'EOL'
# AICheck MCP Project

This project uses AICheck Multimodal Control Protocol for AI-assisted development.

## Claude Code Commands

Claude Code now supports the following AICheck slash commands:

- `/aicheck action new ActionName` - Create a new action
- `/aicheck action set ActionName` - Set the current active action
- `/aicheck action complete [ActionName]` - Complete an action (requires dependency verification)
- `/aicheck exec` - Toggle exec mode for system maintenance
- `/aicheck status` - Show the current action status
- `/aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `/aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency

## Dependency Verification

Before an action can be completed, its dependencies must be verified:
1. External dependencies must be recorded in the dependency index
2. Internal dependencies between actions must be documented
3. Dependency verification happens automatically when completing an action

## Project Structure

The AICheck system follows a structured approach to development:

- `.aicheck/` - Contains all AICheck system files
  - `actions/` - Individual actions with plans and documentation
  - `templates/` - Templates for Claude prompts
  - `rules.md` - AICheck system rules
- `documentation/` - Project documentation
  - `dependencies/` - Dependency documentation and index
- `tests/` - Test suite

## Getting Started

1. Review the AICheck rules in `.aicheck/rules.md`
2. Create a new action with `/aicheck action new ActionName`
3. Plan your action in the generated plan file
4. Set it as your active action with `/aicheck action set ActionName`
5. Implement according to the plan
6. Document dependencies with `/aicheck dependency add` or `/aicheck dependency internal`
7. Complete the action with `/aicheck action complete`

## Documentation-First Approach

AICheck follows a documentation-first, test-driven approach:

1. Document your plan thoroughly before implementation
2. Write tests before implementing features
3. Keep documentation updated as the project evolves
4. Document all dependencies
5. Migrate completed action documentation to the central documentation directories
EOL

# Create a custom CLAUDE.md file with AICheck integration
mkdir -p ~/.claude

cat > ~/.claude/CLAUDE.md << 'EOL'
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AICheck Integration

Claude should follow the rules specified in `.aicheck/RULES.md` and use AICheck commands:

- `/aicheck action new ActionName` - Create a new action 
- `/aicheck action set ActionName` - Set the current active action
- `/aicheck action complete [ActionName]` - Complete an action with dependency verification
- `/aicheck exec` - Toggle exec mode for system maintenance
- `/aicheck status` - Show the current action status
- `/aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `/aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency

## Project Rules

Claude should follow the rules specified in `.aicheck/RULES.md` with focus on documentation-first approach and adherence to language-specific best practices.

## AICheck Procedures

1. Always check the current action with `/aicheck status` at the start of a session
2. Follow the active action's plan when implementing
3. Create tests before implementation code
4. Document all Claude interactions in supporting_docs/claude-interactions/
5. Only work within the scope of the active action
6. Document all dependencies before completing an action

## Dependency Management

When adding external libraries or frameworks:
1. Document with `/aicheck dependency add NAME VERSION JUSTIFICATION`
2. Include specific version requirements
3. Provide clear justification for adding the dependency

When creating dependencies between actions:
1. Document with `/aicheck dependency internal DEP_ACTION ACTION TYPE DESCRIPTION`
2. Specify the type of dependency (data, function, service, etc.)
3. Add detailed description of the dependency relationship

## Claude Workflow

When the user requests work:
1. Check if it fits within the current action (if not, suggest creating a new action)
2. Consult the action plan for guidance
3. Follow test-driven development practices
4. Document your thought process
5. Document all dependencies
6. Implement according to the plan
7. Verify your implementation against the success criteria

## Project-Specific Commands

- Build: `npm run build` or `python setup.py build`
- Development: `npm run dev` or `python manage.py runserver`
- Lint: `npm run lint` or `flake8`
- Type check: `npm run type-check` or `mypy`
- Test: `npm test` or `pytest`
EOL

echo -e "${GREEN}✓ Created global CLAUDE.md with AICheck integration${NC}"

# Create a file to inject AICheck awareness in Claude conversations
cat > .aicheck/claude_aicheck_prompt.md << 'EOL'
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

Let me check the current action status now with `/aicheck status` and proceed accordingly.
EOL

echo -e "${GREEN}✓ Created Claude AICheck prompt template${NC}"

# Create a script to activate AICheck in Claude conversations
cat > activate_aicheck_claude.sh << 'EOL'
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
EOL

chmod +x activate_aicheck_claude.sh

echo -e "${GREEN}✓ Created AICheck activation script${NC}"

echo -e "${GREEN}AICheck MCP setup complete!${NC}"
echo -e "\nYou can now use Claude Code with your project and it will follow the guidelines in .aicheck/RULES.md"
echo -e "\nActivate AICheck in Claude Code:"
echo -e "1. Run ${BLUE}./activate_aicheck_claude.sh${NC}"
echo -e "2. Copy the generated prompt"
echo -e "3. Paste it as your first message to Claude"
echo -e "\nAvailable Claude Code slash commands:"
echo -e "  ${BLUE}/aicheck action new ActionName${NC} - Create a new action"
echo -e "  ${BLUE}/aicheck action set ActionName${NC} - Set the current active action"
echo -e "  ${BLUE}/aicheck action complete [ActionName]${NC} - Complete action (with dependency verification)"
echo -e "  ${BLUE}/aicheck exec${NC} - Toggle exec mode for system maintenance"
echo -e "  ${BLUE}/aicheck status${NC} - Show the current action status"
echo -e "  ${BLUE}/aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]${NC} - Add external dependency"
echo -e "  ${BLUE}/aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]${NC} - Add internal dependency"