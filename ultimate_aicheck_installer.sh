#!/bin/bash

# Ultimate AICheck MCP Installer
# A single command to install AICheck and integrate with Claude Code
# Features:
# - Creates AICheck directory structure
# - Creates all required files
# - Sets up git hooks
# - Creates Claude activation prompt
# - Provides streamlined workflow

set -e  # Exit on any error

# Colors for pretty output - Neon Blurple Theme
GREEN='\033[0;32m'
NEON_BLURPLE='\033[38;5;99m'      # Neon blurple highlight color
BRIGHT_BLURPLE='\033[38;5;135m'   # Bright blurple for text
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Banner with Neon Blurple
echo -e "${BOLD}${NEON_BLURPLE}"
echo "  █████╗ ██╗ ██████╗██╗  ██╗███████╗ ██████╗██╗  ██╗"
echo " ██╔══██╗██║██╔════╝██║  ██║██╔════╝██╔════╝██║ ██╔╝"
echo " ███████║██║██║     ███████║█████╗  ██║     █████╔╝ "
echo " ██╔══██║██║██║     ██╔══██║██╔══╝  ██║     ██╔═██╗ "
echo " ██║  ██║██║╚██████╗██║  ██║███████╗╚██████╗██║  ██╗"
echo " ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝ ╚═════╝╚═╝  ╚═╝"
echo -e "${NC}"
echo -e "${BOLD}${BRIGHT_BLURPLE}Multimodal Control Protocol - Ultimate Installer${NC}"
echo -e "${NEON_BLURPLE}===============================================${NC}\n"

echo -e "${BRIGHT_BLURPLE}Installing AICheck MCP in current directory...${NC}"

# Create directory structure
echo -e "${BRIGHT_BLURPLE}Creating directory structure...${NC}"
mkdir -p .aicheck/actions
mkdir -p .aicheck/templates/claude
mkdir -p documentation/api documentation/architecture documentation/configuration documentation/dependencies documentation/deployment documentation/testing documentation/user
mkdir -p tests/unit tests/integration tests/e2e tests/fixtures

# Create core files
echo -e "${BRIGHT_BLURPLE}Creating core files...${NC}"
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
- Each ACTION directory MUST contain a todo.md file for task tracking and progress management

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
- Managing todo.md files within ActiveAction scope (creating, updating task status, marking complete)

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
│   │       ├── todo.md               # ACTION TODO tracking (required)
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

## 4. Todo Management

### 4.1 Todo File Requirements
- Every ACTION directory MUST contain a todo.md file
- Todo files track task progress, priorities, and completion status
- Claude Code will automatically manage todo.md files using native todo functions
- Todo items should align with the ACTION plan and success criteria

### 4.2 Todo File Format
Todo files use structured markdown with the following format:
```markdown
# TODO: [Action Name]

## Active Tasks
- [ ] Task description (priority: high/medium/low, status: pending/in_progress/completed)

## Completed Tasks
- [x] Completed task description

## Notes
Additional context or dependencies for tasks
```

### 4.3 Todo Management Workflow
- Claude Code automatically creates todo.md when starting an ACTION
- Tasks are derived from the ACTION plan phases and requirements
- Progress is tracked in real-time as tasks are completed
- Todo status integrates with overall ACTION progress tracking

## 5. Dependency Management

### 5.1 External Dependencies
- All external dependencies must be documented in /documentation/dependencies/dependency_index.md
- Include justification for every new dependency added
- Document specific version requirements
- Note which ACTIONS depend on each dependency

### 5.2 Internal Dependencies
- Document dependencies between ACTIONS
- Track which ACTIONS depend on others' functionality
- Document the type of dependency (data, function, service)
- Always verify dependencies before completing an ACTION

## 6. AICheck Commands

Claude Code supports these AICheck slash commands:
- `./aicheck status` - Show current action status
- `./aicheck action new ActionName` - Create a new action
- `./aicheck action set ActionName` - Set current active action
- `./aicheck action complete [ActionName]` - Complete action
- `./aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `./aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency
- `./aicheck exec` - Toggle exec mode for system maintenance
EOL

# Create Claude prompt templates
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

# Create TODO template
cat > .aicheck/templates/TODO_TEMPLATE.md << 'EOL'
# TODO: [Action Name]

## Active Tasks
- [ ] Review and understand ACTION plan requirements (priority: high, status: pending)
- [ ] Create initial test specifications (priority: high, status: pending)
- [ ] Implement core functionality (priority: high, status: pending)
- [ ] Write comprehensive tests (priority: high, status: pending)
- [ ] Update documentation (priority: medium, status: pending)
- [ ] Verify all success criteria met (priority: high, status: pending)

## Completed Tasks
<!-- Move completed tasks here with [x] -->

## Notes
- Review ACTION plan at: .aicheck/actions/[action-name]/[action-name]-plan.md
- Update progress in status.txt as tasks complete
- Ensure all tests pass before marking implementation tasks complete
EOL

echo -e "${GREEN}✓ Created AICheck core files${NC}"

# Create README.md
echo -e "${BRIGHT_BLURPLE}Creating AICheck README.md...${NC}"

cat > README.md << 'EOL'
# AICheck MCP Project

This project uses AICheck Multimodal Control Protocol for AI-assisted development.

## Claude Code Commands

Claude Code now supports the following AICheck slash commands:

- `./aicheck status` - Show current action status
- `./aicheck action new ActionName` - Create a new action
- `./aicheck action set ActionName` - Set current active action
- `./aicheck action complete [ActionName]` - Complete action with dependency verification
- `./aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `./aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency
- `./aicheck exec` - Toggle exec mode for system maintenance

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
2. Create a new action with `./aicheck action new ActionName`
3. Plan your action in the generated plan file
4. Set it as your active action with `./aicheck action set ActionName`
5. Implement according to the plan

## Documentation-First Approach

AICheck follows a documentation-first, test-driven approach:

1. Document your plan thoroughly before implementation
2. Write tests before implementing features
3. Keep documentation updated as the project evolves
4. Migrate completed action documentation to the central documentation directories
EOL

echo -e "${GREEN}✓ Created project README.md${NC}"

# Setup git hooks
echo -e "${BRIGHT_BLURPLE}Setting up AICheck git hooks...${NC}"

# Create hooks directory if it doesn't exist
if [ -d ".git" ]; then
  mkdir -p .git/hooks
  
  # Create pre-commit hook
  cat > .git/hooks/pre-commit << 'EOL'
#!/bin/bash

# AICheck pre-commit hook
# Helps maintain compliance without being too restrictive

GREEN="\033[0;32m"
NEON_BLURPLE="\033[38;5;99m"      # Neon blurple highlight color
BRIGHT_BLURPLE="\033[38;5;135m"   # Bright blurple for text
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Get current action
CURRENT_ACTION=""
if [ -f ".aicheck/current_action" ]; then
  CURRENT_ACTION=$(cat .aicheck/current_action)
fi

# Get list of files being committed
FILES=$(git diff --cached --name-only --diff-filter=ACM)

# 1. Check commit message format (run during commit-msg hook, but check staged files here)
echo -e "${BRIGHT_BLURPLE}Analyzing staged changes...${NC}"

# 2. Check for dependency changes
DEPENDENCY_CHANGES=0
for file in $FILES; do
  # Look for dependency-related imports in code files
  if [[ $file == *.py ]]; then
    if grep -q "^import " "$file" || grep -q "^from .* import " "$file"; then
      # Python imports found
      DEPENDENCY_CHANGES=1
    fi
  elif [[ $file == *.js || $file == *.ts || $file == *.jsx || $file == *.tsx ]]; then
    if grep -q "^import " "$file" || grep -q "require(" "$file"; then
      # JS/TS imports found
      DEPENDENCY_CHANGES=1
    fi
  elif [[ $file == *package.json || $file == *requirements.txt || $file == *Gemfile || $file == *pom.xml || $file == *build.gradle ]]; then
    # Dependency manifests
    DEPENDENCY_CHANGES=1
  fi
done

if [ $DEPENDENCY_CHANGES -eq 1 ] && [ -f "documentation/dependencies/dependency_index.md" ]; then
  # Check if dependency index has been updated in this commit
  if ! git diff --cached --name-only | grep -q "documentation/dependencies/dependency_index.md"; then
    echo -e "${YELLOW}WARNING: Dependency changes detected, but dependency_index.md not updated.${NC}"
    echo -e "${YELLOW}Consider running:\n  ./aicheck dependency add NAME VERSION JUSTIFICATION${NC}"
    echo ""
    # Not blocking the commit, just a friendly reminder
  fi
fi

# 3. Check for file organization - if changing action files but not in active action
if [ -n "$CURRENT_ACTION" ] && [ "$CURRENT_ACTION" != "None" ] && [ "$CURRENT_ACTION" != "AICheckExec" ]; then
  # Convert PascalCase to kebab-case
  ACTION_DIR=$(echo "$CURRENT_ACTION" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  
  if echo "$FILES" | grep -q "\.aicheck/actions/" && ! echo "$FILES" | grep -q "\.aicheck/actions/$ACTION_DIR/"; then
    echo -e "${YELLOW}WARNING: Modifying action files outside current action ($CURRENT_ACTION)${NC}"
    echo -e "${YELLOW}Current action directory: .aicheck/actions/$ACTION_DIR/${NC}"
    echo -e "${YELLOW}Use ./aicheck action set ACTION_NAME to switch actions${NC}"
    echo ""
    # Not blocking the commit, just a friendly reminder
  fi
fi

# 4. Check for test files when implementing functionality
IMPLEMENTATION_FILES=0
TEST_FILES=0

for file in $FILES; do
  if [[ $file == *.py || $file == *.js || $file == *.ts || $file == *.jsx || $file == *.tsx || $file == *.rb || $file == *.go || $file == *.java ]]; then
    if [[ $file != *test* && $file != *spec* ]]; then
      # Implementation file
      IMPLEMENTATION_FILES=1
    fi
  fi
  
  if [[ $file == *test* || $file == *spec* ]]; then
    # Test file
    TEST_FILES=1
  fi
done

if [ $IMPLEMENTATION_FILES -eq 1 ] && [ $TEST_FILES -eq 0 ]; then
  echo -e "${YELLOW}REMINDER: Implementation changes without test updates${NC}"
  echo -e "${YELLOW}AICheck follows test-driven development: tests should be written first${NC}"
  echo -e "${YELLOW}Consider adding tests to verify your implementation${NC}"
  echo ""
  # Not blocking the commit, just a friendly reminder
fi

# Always allow the commit to proceed - these are helpful warnings, not blockers
exit 0
EOL

  chmod +x .git/hooks/pre-commit

  # Create commit-msg hook
  cat > .git/hooks/commit-msg << 'EOL'
#!/bin/bash

# AICheck commit-msg hook
# Validates commit message format

GREEN="\033[0;32m"
NEON_BLURPLE="\033[38;5;99m"      # Neon blurple highlight color
BRIGHT_BLURPLE="\033[38;5;135m"   # Bright blurple for text
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat $COMMIT_MSG_FILE)
FIRST_LINE=$(head -n 1 $COMMIT_MSG_FILE)

# Get current action
CURRENT_ACTION="None"
if [ -f ".aicheck/current_action" ]; then
  CURRENT_ACTION=$(cat .aicheck/current_action)
fi

# 1. Check commit message starts with present-tense verb
if ! echo "$FIRST_LINE" | grep -q -E "^(Add|Update|Fix|Remove|Refactor|Document|Test|Implement|Create|Delete|Merge|Revert|Improve|Optimize|Bump|Release|Hotfix|Security) "; then
  echo -e "${YELLOW}WARNING: Commit message should start with a present-tense verb${NC}"
  echo -e "${YELLOW}Examples: Add, Update, Fix, Remove, Refactor, Document, etc.${NC}"
  echo -e "${YELLOW}Current message: \"$FIRST_LINE\"${NC}"
  echo ""
  # Not blocking the commit, just a friendly reminder
fi

# 2. Check line length
if [ ${#FIRST_LINE} -gt 72 ]; then
  echo -e "${YELLOW}WARNING: Commit message first line is too long (${#FIRST_LINE} > 72 characters)${NC}"
  echo -e "${YELLOW}Consider shortening your message for better readability${NC}"
  echo ""
  # Not blocking the commit, just a friendly reminder
fi

# 3. Check for action reference if there is an active action
if [ "$CURRENT_ACTION" != "None" ] && [ "$CURRENT_ACTION" != "AICheckExec" ]; then
  if ! echo "$COMMIT_MSG" | grep -q "\[$CURRENT_ACTION\]" && ! echo "$COMMIT_MSG" | grep -q "$CURRENT_ACTION"; then
    echo -e "${YELLOW}SUGGESTION: Consider referencing current action in commit message${NC}"
    echo -e "${YELLOW}Current action: $CURRENT_ACTION${NC}"
    echo -e "${YELLOW}Example format: \"Add new feature [$CURRENT_ACTION]\"${NC}"
    echo ""
    # Not blocking the commit, just a friendly reminder
  fi
fi

# Always allow the commit to proceed - these are helpful suggestions, not blockers
exit 0
EOL

  chmod +x .git/hooks/commit-msg

  echo -e "${GREEN}✓ Installed AICheck git hooks${NC}"
else
  echo -e "${YELLOW}No Git repository found in this directory.${NC}"
  echo -e "${YELLOW}Git hooks will be created when you initialize a Git repository.${NC}"
  
  # Create hooks directory for future use
  mkdir -p .aicheck/hooks
  
  # Save hooks for future use
  cat > .aicheck/hooks/pre-commit << 'EOL'
#!/bin/bash

# AICheck pre-commit hook
# Helps maintain compliance without being too restrictive

GREEN="\033[0;32m"
NEON_BLURPLE="\033[38;5;99m"      # Neon blurple highlight color
BRIGHT_BLURPLE="\033[38;5;135m"   # Bright blurple for text
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Get current action
CURRENT_ACTION=""
if [ -f ".aicheck/current_action" ]; then
  CURRENT_ACTION=$(cat .aicheck/current_action)
fi

# Get list of files being committed
FILES=$(git diff --cached --name-only --diff-filter=ACM)

# 1. Check commit message format (run during commit-msg hook, but check staged files here)
echo -e "${BRIGHT_BLURPLE}Analyzing staged changes...${NC}"

# 2. Check for dependency changes
DEPENDENCY_CHANGES=0
for file in $FILES; do
  # Look for dependency-related imports in code files
  if [[ $file == *.py ]]; then
    if grep -q "^import " "$file" || grep -q "^from .* import " "$file"; then
      # Python imports found
      DEPENDENCY_CHANGES=1
    fi
  elif [[ $file == *.js || $file == *.ts || $file == *.jsx || $file == *.tsx ]]; then
    if grep -q "^import " "$file" || grep -q "require(" "$file"; then
      # JS/TS imports found
      DEPENDENCY_CHANGES=1
    fi
  elif [[ $file == *package.json || $file == *requirements.txt || $file == *Gemfile || $file == *pom.xml || $file == *build.gradle ]]; then
    # Dependency manifests
    DEPENDENCY_CHANGES=1
  fi
done

if [ $DEPENDENCY_CHANGES -eq 1 ] && [ -f "documentation/dependencies/dependency_index.md" ]; then
  # Check if dependency index has been updated in this commit
  if ! git diff --cached --name-only | grep -q "documentation/dependencies/dependency_index.md"; then
    echo -e "${YELLOW}WARNING: Dependency changes detected, but dependency_index.md not updated.${NC}"
    echo -e "${YELLOW}Consider running:\n  ./aicheck dependency add NAME VERSION JUSTIFICATION${NC}"
    echo ""
    # Not blocking the commit, just a friendly reminder
  fi
fi

# 3. Check for file organization - if changing action files but not in active action
if [ -n "$CURRENT_ACTION" ] && [ "$CURRENT_ACTION" != "None" ] && [ "$CURRENT_ACTION" != "AICheckExec" ]; then
  # Convert PascalCase to kebab-case
  ACTION_DIR=$(echo "$CURRENT_ACTION" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  
  if echo "$FILES" | grep -q "\.aicheck/actions/" && ! echo "$FILES" | grep -q "\.aicheck/actions/$ACTION_DIR/"; then
    echo -e "${YELLOW}WARNING: Modifying action files outside current action ($CURRENT_ACTION)${NC}"
    echo -e "${YELLOW}Current action directory: .aicheck/actions/$ACTION_DIR/${NC}"
    echo -e "${YELLOW}Use ./aicheck action set ACTION_NAME to switch actions${NC}"
    echo ""
    # Not blocking the commit, just a friendly reminder
  fi
fi

# 4. Check for test files when implementing functionality
IMPLEMENTATION_FILES=0
TEST_FILES=0

for file in $FILES; do
  if [[ $file == *.py || $file == *.js || $file == *.ts || $file == *.jsx || $file == *.tsx || $file == *.rb || $file == *.go || $file == *.java ]]; then
    if [[ $file != *test* && $file != *spec* ]]; then
      # Implementation file
      IMPLEMENTATION_FILES=1
    fi
  fi
  
  if [[ $file == *test* || $file == *spec* ]]; then
    # Test file
    TEST_FILES=1
  fi
done

if [ $IMPLEMENTATION_FILES -eq 1 ] && [ $TEST_FILES -eq 0 ]; then
  echo -e "${YELLOW}REMINDER: Implementation changes without test updates${NC}"
  echo -e "${YELLOW}AICheck follows test-driven development: tests should be written first${NC}"
  echo -e "${YELLOW}Consider adding tests to verify your implementation${NC}"
  echo ""
  # Not blocking the commit, just a friendly reminder
fi

# Always allow the commit to proceed - these are helpful warnings, not blockers
exit 0
EOL

  cat > .aicheck/hooks/commit-msg << 'EOL'
#!/bin/bash

# AICheck commit-msg hook
# Validates commit message format

GREEN="\033[0;32m"
NEON_BLURPLE="\033[38;5;99m"      # Neon blurple highlight color
BRIGHT_BLURPLE="\033[38;5;135m"   # Bright blurple for text
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat $COMMIT_MSG_FILE)
FIRST_LINE=$(head -n 1 $COMMIT_MSG_FILE)

# Get current action
CURRENT_ACTION="None"
if [ -f ".aicheck/current_action" ]; then
  CURRENT_ACTION=$(cat .aicheck/current_action)
fi

# 1. Check commit message starts with present-tense verb
if ! echo "$FIRST_LINE" | grep -q -E "^(Add|Update|Fix|Remove|Refactor|Document|Test|Implement|Create|Delete|Merge|Revert|Improve|Optimize|Bump|Release|Hotfix|Security) "; then
  echo -e "${YELLOW}WARNING: Commit message should start with a present-tense verb${NC}"
  echo -e "${YELLOW}Examples: Add, Update, Fix, Remove, Refactor, Document, etc.${NC}"
  echo -e "${YELLOW}Current message: \"$FIRST_LINE\"${NC}"
  echo ""
  # Not blocking the commit, just a friendly reminder
fi

# 2. Check line length
if [ ${#FIRST_LINE} -gt 72 ]; then
  echo -e "${YELLOW}WARNING: Commit message first line is too long (${#FIRST_LINE} > 72 characters)${NC}"
  echo -e "${YELLOW}Consider shortening your message for better readability${NC}"
  echo ""
  # Not blocking the commit, just a friendly reminder
fi

# 3. Check for action reference if there is an active action
if [ "$CURRENT_ACTION" != "None" ] && [ "$CURRENT_ACTION" != "AICheckExec" ]; then
  if ! echo "$COMMIT_MSG" | grep -q "\[$CURRENT_ACTION\]" && ! echo "$COMMIT_MSG" | grep -q "$CURRENT_ACTION"; then
    echo -e "${YELLOW}SUGGESTION: Consider referencing current action in commit message${NC}"
    echo -e "${YELLOW}Current action: $CURRENT_ACTION${NC}"
    echo -e "${YELLOW}Example format: \"Add new feature [$CURRENT_ACTION]\"${NC}"
    echo ""
    # Not blocking the commit, just a friendly reminder
  fi
fi

# Always allow the commit to proceed - these are helpful suggestions, not blockers
exit 0
EOL

  chmod +x .aicheck/hooks/pre-commit
  chmod +x .aicheck/hooks/commit-msg
  
  # Create a git init helper script
  cat > .aicheck/init_git_hooks.sh << 'EOL'
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
EOL

  chmod +x .aicheck/init_git_hooks.sh
  
  echo -e "${YELLOW}Created hook installation script: .aicheck/init_git_hooks.sh${NC}"
  echo -e "${YELLOW}Run it after 'git init' to set up git hooks${NC}"
fi

# Create aicheck command script
echo -e "${BRIGHT_BLURPLE}Creating AICheck command script...${NC}"

cat > ./aicheck << 'EOL'
#!/bin/bash

# AICheck command script
# Provides the core functionality for AICheck MCP

set -e

CMD=$1
shift
ARGS=$@

GREEN="\033[0;32m"
NEON_BLURPLE="\033[38;5;99m"      # Neon blurple highlight color
BRIGHT_BLURPLE="\033[38;5;135m"   # Bright blurple for text
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# Function to create a new action
function create_action() {
  local action_name=$1
  
  if [ -z "$action_name" ]; then
    echo -e "${RED}Error: Action name is required${NC}"
    echo "Usage: ./aicheck action new ACTION_NAME"
    exit 1
  fi
  
  # Convert PascalCase to kebab-case for directories (compatible with macOS)
  local dir_name=$(echo "$action_name" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  
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
  
  # Create todo.md from template
  cat > ".aicheck/actions/$dir_name/todo.md" << TODO
# TODO: $action_name

## Active Tasks
- [ ] Review and understand ACTION plan requirements (priority: high, status: pending)
- [ ] Create initial test specifications (priority: high, status: pending)
- [ ] Implement core functionality (priority: high, status: pending)
- [ ] Write comprehensive tests (priority: high, status: pending)
- [ ] Update documentation (priority: medium, status: pending)
- [ ] Verify all success criteria met (priority: high, status: pending)

## Completed Tasks
<!-- Move completed tasks here with [x] -->

## Notes
- Review ACTION plan at: .aicheck/actions/$dir_name/$dir_name-plan.md
- Update progress in status.txt as tasks complete
- Ensure all tests pass before marking implementation tasks complete
TODO
  
  # Update actions_index.md
  # Get the line number of the "Active Actions" table's end
  line_num=$(grep -n "\| \*None yet\* \| \| \| \| \|" .aicheck/actions_index.md | cut -d':' -f1)
  
  if [ -n "$line_num" ]; then
    # Replace the "None yet" line with the new action
    sed -i "" "$line_num s/| \*None yet\* | | | | |/| $action_name | | Not Started | 0% | |\n| \*None yet\* | | | | |/" .aicheck/actions_index.md
  else
    # Append to the Active Actions table
    line_num=$(grep -n "## Active Actions" .aicheck/actions_index.md | cut -d':' -f1)
    if [ -n "$line_num" ]; then
      awk -v line="$line_num" -v action="| $action_name | | Not Started | 0% | |" 'NR==line+4{print action}1' .aicheck/actions_index.md > .aicheck/actions_index.md.tmp
      mv .aicheck/actions_index.md.tmp .aicheck/actions_index.md
    fi
  fi
  
  # Update last updated date
  sed -i "" "s/\*Last Updated: .*\*/\*Last Updated: $(date +"%Y-%m-%d")\*/" .aicheck/actions_index.md
  
  echo -e "${GREEN}✓ Created new ACTION: $action_name${NC}"
  echo -e "${BRIGHT_BLURPLE}Directory: .aicheck/actions/$dir_name${NC}"
  echo -e "${YELLOW}NOTE: This ACTION requires planning and approval before implementation${NC}"
}

# Function to set the active action
function set_active_action() {
  local action_name=$1
  
  if [ -z "$action_name" ]; then
    echo -e "${RED}Error: Action name is required${NC}"
    echo "Usage: ./aicheck action set ACTION_NAME"
    exit 1
  fi
  
  # Convert PascalCase to kebab-case for directories (compatible with macOS)
  local dir_name=$(echo "$action_name" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  
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
    sed -i "" "s/| $action_name | .* | [^|]* | [^|]* | /| $action_name | | ActiveAction | 0% | /" .aicheck/actions_index.md
    
    # Update last updated date
    sed -i "" "s/\*Last Updated: .*\*/\*Last Updated: $(date +"%Y-%m-%d")\*/" .aicheck/actions_index.md
  fi
  
  echo -e "${GREEN}✓ Set current action to: $action_name${NC}"
}

# Function to complete an action
function complete_action() {
  local action_name=$1
  
  # If no action name is provided, use the current action
  if [ -z "$action_name" ]; then
    if [ -f ".aicheck/current_action" ]; then
      action_name=$(cat .aicheck/current_action)
    fi
  fi
  
  if [ -z "$action_name" ] || [ "$action_name" = "None" ] || [ "$action_name" = "AICheckExec" ]; then
    echo -e "${RED}Error: No action specified and no current action set${NC}"
    echo "Usage: ./aicheck action complete [ACTION_NAME]"
    exit 1
  fi
  
  # Convert PascalCase to kebab-case for directories (compatible with macOS)
  local dir_name=$(echo "$action_name" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  
  # Check if action exists
  if [ ! -d ".aicheck/actions/$dir_name" ]; then
    echo -e "${RED}Error: Action '$action_name' does not exist${NC}"
    echo "Available actions:"
    ls -1 .aicheck/actions/ | grep -v "README"
    exit 1
  fi
  
  # Verify dependencies
  echo -e "${BRIGHT_BLURPLE}Verifying dependencies for $action_name...${NC}"
  
  local has_dependencies=0
  if [ -f "documentation/dependencies/dependency_index.md" ]; then
    # Check for dependencies in the dependency index
    if grep -q "$action_name" documentation/dependencies/dependency_index.md; then
      has_dependencies=1
      echo -e "${GREEN}✓ Dependencies documented for $action_name${NC}"
      
      # Display documented dependencies
      echo -e "${BRIGHT_BLURPLE}Dependencies documented:${NC}"
      grep -A 1 -B 1 "$action_name" documentation/dependencies/dependency_index.md
    fi
  fi
  
  # Check for imports in code files
  local imports_found=0
  local deps_dir=".aicheck/actions/$dir_name"
  
  if [ -d "$deps_dir" ]; then
    # Look for Python imports
    if find "$deps_dir" -type f -name "*.py" | xargs grep -l "^import\|^from .* import" 2>/dev/null; then
      imports_found=1
    fi
    
    # Look for JS/TS imports
    if find "$deps_dir" -type f -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | xargs grep -l "^import\|require(" 2>/dev/null; then
      imports_found=1
    fi
  fi
  
  if [ $imports_found -eq 1 ] && [ $has_dependencies -eq 0 ]; then
    echo -e "${YELLOW}WARNING: Code imports found but no dependencies documented.${NC}"
    echo -e "${YELLOW}Please document dependencies with:${NC}"
    echo -e "${YELLOW}./aicheck dependency add NAME VERSION JUSTIFICATION $action_name${NC}"
    echo -e "${YELLOW}Continue anyway? (y/n)${NC}"
    read -r continue_anyway
    
    if [[ $continue_anyway != "y" && $continue_anyway != "Y" ]]; then
      echo -e "${YELLOW}Action completion aborted. Please document dependencies first.${NC}"
      exit 0
    fi
  fi
  
  # Update action status
  echo "Completed" > ".aicheck/actions/$dir_name/status.txt"
  
  # Update progress to 100%
  sed -i "" "s/Progress: .*%/Progress: 100%/" ".aicheck/actions/$dir_name/$dir_name-plan.md"
  
  # Update actions_index.md
  # First, remove from Active Actions
  sed -i "" "/| $action_name | .* | [^|]* | [^|]* | .*|/d" .aicheck/actions_index.md
  
  # Then, add to Completed Actions
  # Get the line number of the "Completed Actions" table's end
  line_num=$(grep -n "\| \*None yet\* \| \| \| \|" .aicheck/actions_index.md | sed -n '2p' | cut -d':' -f1)
  
  if [ -n "$line_num" ]; then
    # Replace the "None yet" line with the new action
    sed -i "" "$line_num s/| \*None yet\* | | | |/| $action_name | | $(date +"%Y-%m-%d") | |\n| \*None yet\* | | | |/" .aicheck/actions_index.md
  else
    # Append to the Completed Actions table
    line_num=$(grep -n "## Completed Actions" .aicheck/actions_index.md | cut -d':' -f1)
    if [ -n "$line_num" ]; then
      awk -v line="$line_num" -v action="| $action_name | | $(date +"%Y-%m-%d") | |" 'NR==line+4{print action}1' .aicheck/actions_index.md > .aicheck/actions_index.md.tmp
      mv .aicheck/actions_index.md.tmp .aicheck/actions_index.md
    fi
  fi
  
  # Update last updated date
  sed -i "" "s/\*Last Updated: .*\*/\*Last Updated: $(date +"%Y-%m-%d")\*/" .aicheck/actions_index.md
  
  # If this was the current action, set current action to None
  if [ -f ".aicheck/current_action" ] && [ "$(cat .aicheck/current_action)" = "$action_name" ]; then
    echo "None" > .aicheck/current_action
    echo -e "${BRIGHT_BLURPLE}Current action reset to None${NC}"
  fi
  
  echo -e "${GREEN}✓ Completed ACTION: $action_name${NC}"
  echo -e "${BRIGHT_BLURPLE}Updated status, progress, and actions index${NC}"
}

# Function to toggle exec mode
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
      echo -e "${BRIGHT_BLURPLE}Returned to action: $previous_action${NC}"
    else
      echo "None" > .aicheck/current_action
      echo -e "${GREEN}✓ Exited Exec Mode${NC}"
      echo -e "${BRIGHT_BLURPLE}No previous action found${NC}"
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

# Function to add an external dependency
function add_dependency() {
  local name=$1
  local version=$2
  local justification=$3
  local action=$4
  
  if [ -z "$name" ] || [ -z "$version" ] || [ -z "$justification" ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo "Usage: ./aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]"
    exit 1
  fi
  
  # If no action is provided, use the current action
  if [ -z "$action" ]; then
    if [ -f ".aicheck/current_action" ]; then
      action=$(cat .aicheck/current_action)
    fi
  fi
  
  if [ -z "$action" ] || [ "$action" = "None" ] || [ "$action" = "AICheckExec" ]; then
    echo -e "${YELLOW}Warning: No action specified or current action set.${NC}"
    echo -e "${YELLOW}Dependency will be added without associating with an action.${NC}"
    action=""
  fi
  
  # Create dependency index if it doesn't exist
  mkdir -p documentation/dependencies
  if [ ! -f "documentation/dependencies/dependency_index.md" ]; then
    cat > documentation/dependencies/dependency_index.md << 'EODOC'
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
EODOC
  fi
  
  # Check if dependency already exists
  if grep -q "| $name | $version |" documentation/dependencies/dependency_index.md; then
    echo -e "${YELLOW}Dependency $name@$version already exists.${NC}"
    echo -e "${YELLOW}Updating to add this action as a user.${NC}"
    
    # Extract existing actions using this dependency
    local existing_actions=$(grep "| $name | $version |" documentation/dependencies/dependency_index.md | awk -F '|' '{print $6}' | xargs)
    
    # Add the current action if not already included
    if [ -n "$action" ] && ! echo "$existing_actions" | grep -q "$action"; then
      local new_actions="$existing_actions, $action"
      # Update the dependency entry
      sed -i "" "s/| $name | $version |.*|.*|.*|.*|/| $name | $version | | $(date +"%Y-%m-%d") | $justification | $new_actions |/" documentation/dependencies/dependency_index.md
    fi
  else
    # Get the line number of the "External Dependencies" table's "None yet" row
    line_num=$(grep -n "\| \*None yet\* \| \| \| \| \| \|" documentation/dependencies/dependency_index.md | cut -d':' -f1)
    
    if [ -n "$line_num" ]; then
      # Replace the "None yet" line with the new dependency
      sed -i "" "$line_num s/| \*None yet\* | | | | | |/| $name | $version | | $(date +"%Y-%m-%d") | $justification | $action |\n| \*None yet\* | | | | | |/" documentation/dependencies/dependency_index.md
    else
      # Append to the External Dependencies table
      line_num=$(grep -n "## External Dependencies" documentation/dependencies/dependency_index.md | cut -d':' -f1)
      if [ -n "$line_num" ]; then
        let line_num+=4  # Move to after the header row
        awk -v line="$line_num" -v dep="| $name | $version | | $(date +"%Y-%m-%d") | $justification | $action |" 'NR==line{print dep}1' documentation/dependencies/dependency_index.md > documentation/dependencies/dependency_index.md.tmp
        mv documentation/dependencies/dependency_index.md.tmp documentation/dependencies/dependency_index.md
      fi
    fi
  fi
  
  # Update last updated date
  sed -i "" "s/\*Last Updated: .*\*/\*Last Updated: $(date +"%Y-%m-%d")\*/" documentation/dependencies/dependency_index.md
  
  echo -e "${GREEN}✓ Added external dependency: $name@$version${NC}"
  if [ -n "$action" ]; then
    echo -e "${BRIGHT_BLURPLE}Associated with action: $action${NC}"
  fi
}

# Function to add an internal dependency
function add_internal_dependency() {
  local dep_action=$1
  local action=$2
  local type=$3
  local description=$4
  
  if [ -z "$dep_action" ] || [ -z "$action" ] || [ -z "$type" ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo "Usage: ./aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]"
    exit 1
  fi
  
  # Create dependency index if it doesn't exist
  mkdir -p documentation/dependencies
  if [ ! -f "documentation/dependencies/dependency_index.md" ]; then
    cat > documentation/dependencies/dependency_index.md << 'EODOC2'
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
EODOC2
  fi
  
  # Check if both actions exist
  local dep_dir_name=$(echo "$dep_action" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  local action_dir_name=$(echo "$action" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
  
  if [ ! -d ".aicheck/actions/$dep_dir_name" ]; then
    echo -e "${YELLOW}Warning: Dependency action '$dep_action' does not exist.${NC}"
  fi
  
  if [ ! -d ".aicheck/actions/$action_dir_name" ]; then
    echo -e "${YELLOW}Warning: Dependent action '$action' does not exist.${NC}"
  fi
  
  # Get the line number of the "Internal Dependencies" table's "None yet" row
  line_num=$(grep -n "\| \*None yet\* \| \| \| \| \|" documentation/dependencies/dependency_index.md | sed -n '2p' | cut -d':' -f1)
  
  if [ -n "$line_num" ]; then
    # Replace the "None yet" line with the new dependency
    sed -i "" "$line_num s/| \*None yet\* | | | | |/| $dep_action | $action | $type | $(date +"%Y-%m-%d") | ${description:-\"\"} |\n| \*None yet\* | | | | |/" documentation/dependencies/dependency_index.md
  else
    # Append to the Internal Dependencies table
    line_num=$(grep -n "## Internal Dependencies" documentation/dependencies/dependency_index.md | cut -d':' -f1)
    if [ -n "$line_num" ]; then
      let line_num+=4  # Move to after the header row
      awk -v line="$line_num" -v dep="| $dep_action | $action | $type | $(date +"%Y-%m-%d") | ${description:-\"\"} |" 'NR==line{print dep}1' documentation/dependencies/dependency_index.md > documentation/dependencies/dependency_index.md.tmp
      mv documentation/dependencies/dependency_index.md.tmp documentation/dependencies/dependency_index.md
    fi
  fi
  
  # Update last updated date
  sed -i "" "s/\*Last Updated: .*\*/\*Last Updated: $(date +"%Y-%m-%d")\*/" documentation/dependencies/dependency_index.md
  
  echo -e "${GREEN}✓ Added internal dependency${NC}"
  echo -e "${BRIGHT_BLURPLE}$action depends on $dep_action ($type)${NC}"
}

# Function to show the current status
function show_status() {
  local current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
  
  echo -e "${BRIGHT_BLURPLE}AICheck Status${NC}"
  echo -e "-------------------"
  echo -e "Current Action: ${GREEN}$current_action${NC}"
  
  if [ "$current_action" != "None" ] && [ "$current_action" != "AICheckExec" ]; then
    # Convert PascalCase to kebab-case for directories
    local dir_name=$(echo "$current_action" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')
    
    if [ -d ".aicheck/actions/$dir_name" ]; then
      local status=$(cat ".aicheck/actions/$dir_name/status.txt" 2>/dev/null || echo "Unknown")
      local progress=$(grep "Progress:" ".aicheck/actions/$dir_name/$dir_name-plan.md" 2>/dev/null | cut -d':' -f2 | tr -d ' %' || echo "0")
      
      echo -e "Status: ${GREEN}$status${NC}"
      echo -e "Progress: ${GREEN}$progress%${NC}"
      echo -e "Plan: ${BRIGHT_BLURPLE}.aicheck/actions/$dir_name/$dir_name-plan.md${NC}"
      
      # Show dependencies
      if [ -f "documentation/dependencies/dependency_index.md" ]; then
        local deps=$(grep -c "$current_action" documentation/dependencies/dependency_index.md || echo "0")
        if [ "$deps" -gt "0" ]; then
          echo -e "\nDependencies for $current_action:"
          grep "$current_action" documentation/dependencies/dependency_index.md
        fi
      fi
    else
      echo -e "${YELLOW}Warning: Action directory not found for $current_action${NC}"
    fi
  elif [ "$current_action" = "AICheckExec" ]; then
    echo -e "${YELLOW}SYSTEM IS IN EXEC MODE${NC}"
    echo -e "${YELLOW}For system maintenance only${NC}"
    if [ -f .aicheck/previous_action ]; then
      local previous_action=$(cat .aicheck/previous_action)
      echo -e "Previous action: ${BRIGHT_BLURPLE}$previous_action${NC} (will be restored on exec mode exit)"
    fi
  fi
  
  # Show active actions
  echo -e "\nActive Actions:"
  if [ -f ".aicheck/actions_index.md" ]; then
    grep -A 5 "## Active Actions" .aicheck/actions_index.md | tail -n +4 | grep -v "\*None yet\*" | grep -v "^$" || echo "No active actions"
  else
    echo "No action index found"
  fi
  
  # Show git status if in a git repo
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo -e "\nGit Status:"
    echo -e "Branch: $(git branch --show-current 2>/dev/null)"
    echo -e "Changes: $(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
    echo -e "Last commit: $(git log -1 --oneline 2>/dev/null || echo "No commits yet")"
  fi
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
  "dependency")
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

chmod +x ./aicheck

echo -e "${GREEN}✓ Created AICheck command script${NC}"

# Create Claude integration activation prompt
echo -e "${BRIGHT_BLURPLE}Creating Claude Code activation text...${NC}"

# Create activation text
cat > .aicheck/claude_aicheck_prompt.md << 'EOL'
# AICheck System Integration

I notice this project is using the AICheck Multimodal Control Protocol. Let me check the current action status.

I'll follow the AICheck workflow and adhere to the rules in `.aicheck/RULES.md`. This includes:

1. Using the command line tools: 
   - `./aicheck status` to check current action
   - `./aicheck action new/set/complete` to manage actions
   - `./aicheck dependency add/internal` to document dependencies
   - `./aicheck exec` for maintenance mode

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

Let me check the current action status now with `./aicheck status` and proceed accordingly.
EOL

# Create CLAUDE.md
echo -e "${BRIGHT_BLURPLE}Creating CLAUDE.md for additional configuration...${NC}"

cat > CLAUDE.md << 'EOL'
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AICheck Integration

Claude should follow the rules specified in `.aicheck/RULES.md` and use AICheck commands:

- `./aicheck action new ActionName` - Create a new action 
- `./aicheck action set ActionName` - Set the current active action
- `./aicheck action complete [ActionName]` - Complete an action with dependency verification
- `./aicheck exec` - Toggle exec mode for system maintenance
- `./aicheck status` - Show the current action status
- `./aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `./aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency

## Project Rules

Claude should follow the rules specified in `.aicheck/RULES.md` with focus on documentation-first approach and adherence to language-specific best practices.

## AICheck Procedures

1. Always check the current action with `./aicheck status` at the start of a session
2. Follow the active action's plan when implementing
3. Create tests before implementation code
4. Document all Claude interactions in supporting_docs/claude-interactions/
5. Only work within the scope of the active action
6. Document all dependencies before completing an action
7. Immediately respond to git hook suggestions before continuing work

## Dependency Management

When adding external libraries or frameworks:
1. Document with `./aicheck dependency add NAME VERSION JUSTIFICATION`
2. Include specific version requirements
3. Provide clear justification for adding the dependency

When creating dependencies between actions:
1. Document with `./aicheck dependency internal DEP_ACTION ACTION TYPE DESCRIPTION`
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
EOL

# Create activation script
echo -e "${BRIGHT_BLURPLE}Creating activation script...${NC}"

cat > activate_aicheck_claude.sh << 'EOL'
#!/bin/bash

# Script to activate AICheck in a Claude Code session

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BRIGHT_BLURPLE}Activating AICheck in Claude Code...${NC}"

# Check if the prompt file exists
if [ ! -f ".aicheck/claude_aicheck_prompt.md" ]; then
  echo -e "${YELLOW}Warning: Activation prompt not found.${NC}"
  echo -e "Creating default activation prompt..."
  
  mkdir -p .aicheck
  
  # Create activation text
  cat > .aicheck/claude_aicheck_prompt.md << 'PROMPT'
# AICheck System Integration

I notice this project is using the AICheck Multimodal Control Protocol. Let me check the current action status.

I'll follow the AICheck workflow and adhere to the rules in `.aicheck/RULES.md`. This includes:

1. Using the command line tools: 
   - `./aicheck status` to check current action
   - `./aicheck action new/set/complete` to manage actions
   - `./aicheck dependency add/internal` to document dependencies
   - `./aicheck exec` for maintenance mode

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

Let me check the current action status now with `./aicheck status` and proceed accordingly.
PROMPT
fi

# Copy the prompt template to clipboard
if command -v pbcopy > /dev/null; then
  # macOS
  cat .aicheck/claude_aicheck_prompt.md | pbcopy
  echo -e "${GREEN}✓ AICheck activation prompt copied to clipboard${NC}"
elif command -v xclip > /dev/null; then
  # Linux with xclip
  cat .aicheck/claude_aicheck_prompt.md | xclip -selection clipboard
  echo -e "${GREEN}✓ AICheck activation prompt copied to clipboard${NC}"
elif command -v clip.exe > /dev/null; then
  # Windows with clip.exe (WSL)
  cat .aicheck/claude_aicheck_prompt.md | clip.exe
  echo -e "${GREEN}✓ AICheck activation prompt copied to clipboard${NC}"
else
  # Fallback to temp file
  cp .aicheck/claude_aicheck_prompt.md /tmp/aicheck_prompt.md
  echo -e "${YELLOW}Copied prompt to /tmp/aicheck_prompt.md${NC}"
  
  # Try to open the file
  if command -v open > /dev/null; then
    open /tmp/aicheck_prompt.md
  elif command -v xdg-open > /dev/null; then
    xdg-open /tmp/aicheck_prompt.md
  elif command -v wslview > /dev/null; then
    wslview /tmp/aicheck_prompt.md
  else
    echo -e "${YELLOW}Unable to open file automatically.${NC}"
  fi
fi

# Instructions
echo -e "\n${BRIGHT_BLURPLE}To activate AICheck in Claude Code:${NC}"
echo -e "1. Start a new Claude Code conversation"
echo -e "2. Paste the activation text from your clipboard"
echo -e "3. Claude will automatically recognize AICheck and use the system\n"
echo -e "${GREEN}✓ AICheck activation ready${NC}"
EOL

chmod +x activate_aicheck_claude.sh

# Create migration script for existing PascalCase directories
cat > migrate_action_names.sh << 'MIGRATE'
#!/bin/bash

# AICheck Action Name Migration Script
# Converts existing PascalCase action directories to kebab-case

GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NEON_BLURPLE="\033[38;5;99m"      # Neon blurple highlight color
BRIGHT_BLURPLE="\033[38;5;135m"   # Bright blurple for text
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"

echo -e "${BRIGHT_BLURPLE}AICheck Action Name Migration${NC}"
echo "Converting PascalCase action directories to kebab-case..."
echo ""

if [ ! -d ".aicheck/actions" ]; then
  echo -e "${RED}Error: .aicheck/actions directory not found${NC}"
  exit 1
fi

migrated_count=0
for dir in .aicheck/actions/*/; do
  if [ -d "$dir" ]; then
    action_dir=$(basename "$dir")
    # Convert PascalCase to kebab-case
    kebab_name=$(echo "$action_dir" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]')
    
    if [ "$action_dir" != "$kebab_name" ]; then
      echo -e "${YELLOW}Migrating: $action_dir -> $kebab_name${NC}"
      
      # Create new directory with kebab-case name
      if [ ! -d ".aicheck/actions/$kebab_name" ]; then
        mv ".aicheck/actions/$action_dir" ".aicheck/actions/$kebab_name"
        
        # Update plan file name if it exists
        old_plan=".aicheck/actions/$kebab_name/$action_dir-plan.md"
        new_plan=".aicheck/actions/$kebab_name/$kebab_name-plan.md"
        if [ -f "$old_plan" ]; then
          mv "$old_plan" "$new_plan"
        fi
        
        # Update current_action file if it points to the old name
        if [ -f ".aicheck/current_action" ] && [ "$(cat .aicheck/current_action)" = "$action_dir" ]; then
          echo "$kebab_name" > .aicheck/current_action
          echo -e "${BRIGHT_BLURPLE}Updated current action reference${NC}"
        fi
        
        migrated_count=$((migrated_count + 1))
      else
        echo -e "${RED}Warning: Target directory $kebab_name already exists, skipping${NC}"
      fi
    fi
  fi
done

if [ $migrated_count -eq 0 ]; then
  echo -e "${GREEN}✓ No PascalCase directories found - all actions already use kebab-case${NC}"
else
  echo ""
  echo -e "${GREEN}✓ Migration complete! Migrated $migrated_count action directories${NC}"
  echo -e "${BRIGHT_BLURPLE}All action directories now use kebab-case naming convention${NC}"
fi
MIGRATE

chmod +x migrate_action_names.sh

echo -e "${GREEN}✓ Created AICheck activation script${NC}"

# Set up MCP server
echo -e "${BRIGHT_BLURPLE}Setting up MCP server integration...${NC}"

# Create MCP directory structure
mkdir -p .mcp/server

# Create MCP server package.json
cat > .mcp/server/package.json << 'MCP_PACKAGE'
{
  "name": "aicheck-mcp-server",
  "version": "1.0.0",
  "description": "AICheck Model Context Protocol Server",
  "main": "index.js",
  "type": "module",
  "dependencies": {
    "@modelcontextprotocol/sdk": "^1.0.0"
  },
  "scripts": {
    "start": "node index.js"
  }
}
MCP_PACKAGE

# Create MCP server implementation
cat > .mcp/server/index.js << 'MCP_SERVER'
#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  ReadResourceRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { execSync } from 'child_process';

class AICheckMCPServer {
  constructor() {
    this.server = new Server(
      {
        name: 'aicheck-mcp-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          resources: {},
          tools: {},
        },
      }
    );
    
    this.setupHandlers();
  }

  setupHandlers() {
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      return {
        resources: [
          {
            uri: 'aicheck://rules',
            name: 'AICheck Rules',
            description: 'The rules governing the AICheck system',
            mimeType: 'text/markdown',
          },
          {
            uri: 'aicheck://actions_index',
            name: 'Actions Index',
            description: 'The index of all actions in the project',
            mimeType: 'text/markdown',
          },
          {
            uri: 'aicheck://current_action',
            name: 'Current Action',
            description: 'The currently active action',
            mimeType: 'text/plain',
          },
        ],
      };
    });

    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const { uri } = request.params;
      
      try {
        let content = '';
        
        switch (uri) {
          case 'aicheck://rules':
            if (existsSync('.aicheck/RULES.md')) {
              content = readFileSync('.aicheck/RULES.md', 'utf-8');
            } else {
              content = 'AICheck rules not found';
            }
            break;
            
          case 'aicheck://actions_index':
            if (existsSync('.aicheck/actions_index.md')) {
              content = readFileSync('.aicheck/actions_index.md', 'utf-8');
            } else {
              content = 'Actions index not found';
            }
            break;
            
          case 'aicheck://current_action':
            if (existsSync('.aicheck/current_action')) {
              content = readFileSync('.aicheck/current_action', 'utf-8').trim();
            } else {
              content = 'None';
            }
            break;
            
          default:
            throw new Error(`Unknown resource: ${uri}`);
        }
        
        return {
          contents: [
            {
              uri,
              mimeType: uri.includes('rules') || uri.includes('actions_index') ? 'text/markdown' : 'text/plain',
              text: content,
            },
          ],
        };
      } catch (error) {
        throw new Error(`Failed to read resource ${uri}: ${error.message}`);
      }
    });

    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'aicheck.getCurrentAction',
            description: 'Get the currently active action',
            inputSchema: {
              type: 'object',
              properties: {},
            },
          },
          {
            name: 'aicheck.listActions',
            description: 'List all actions in the project',
            inputSchema: {
              type: 'object',
              properties: {},
            },
          },
          {
            name: 'aicheck.getActionPlan',
            description: 'Get the plan for a specific action',
            inputSchema: {
              type: 'object',
              properties: {
                actionName: {
                  type: 'string',
                  description: 'The name of the action',
                },
              },
              required: ['actionName'],
            },
          },
          {
            name: 'aicheck.setCurrentAction',
            description: 'Set the currently active action (requires human approval)',
            inputSchema: {
              type: 'object',
              properties: {
                actionName: {
                  type: 'string',
                  description: 'The name of the action to set as current',
                },
              },
              required: ['actionName'],
            },
          },
          {
            name: 'aicheck.logClaudeInteraction',
            description: 'Log a Claude interaction for the current action',
            inputSchema: {
              type: 'object',
              properties: {
                purpose: {
                  type: 'string',
                  description: 'The purpose of the interaction',
                },
                content: {
                  type: 'string',
                  description: 'The content of the interaction',
                },
              },
              required: ['purpose', 'content'],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      
      try {
        switch (name) {
          case 'aicheck.getCurrentAction':
            return await this.getCurrentAction();
            
          case 'aicheck.listActions':
            return await this.listActions();
            
          case 'aicheck.getActionPlan':
            return await this.getActionPlan(args.actionName);
            
          case 'aicheck.setCurrentAction':
            return await this.setCurrentAction(args.actionName);
            
          case 'aicheck.logClaudeInteraction':
            return await this.logClaudeInteraction(args.purpose, args.content);
            
          default:
            throw new Error(`Unknown tool: ${name}`);
        }
      } catch (error) {
        return {
          content: [
            {
              type: 'text',
              text: `Error: ${error.message}`,
            },
          ],
        };
      }
    });
  }

  async getCurrentAction() {
    try {
      const current = existsSync('.aicheck/current_action') 
        ? readFileSync('.aicheck/current_action', 'utf-8').trim()
        : 'None';
      
      return {
        content: [
          {
            type: 'text',
            text: current,
          },
        ],
      };
    } catch (error) {
      throw new Error(`Failed to get current action: ${error.message}`);
    }
  }

  async listActions() {
    try {
      const actionsIndex = existsSync('.aicheck/actions_index.md')
        ? readFileSync('.aicheck/actions_index.md', 'utf-8')
        : 'No actions found';
      
      return {
        content: [
          {
            type: 'text',
            text: actionsIndex,
          },
        ],
      };
    } catch (error) {
      throw new Error(`Failed to list actions: ${error.message}`);
    }
  }

  async getActionPlan(actionName) {
    try {
      const dirName = actionName.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
      const planPath = `.aicheck/actions/${dirName}/${dirName}-plan.md`;
      
      if (!existsSync(planPath)) {
        throw new Error(`Action plan not found for ${actionName}`);
      }
      
      const plan = readFileSync(planPath, 'utf-8');
      
      return {
        content: [
          {
            type: 'text',
            text: plan,
          },
        ],
      };
    } catch (error) {
      throw new Error(`Failed to get action plan: ${error.message}`);
    }
  }

  async setCurrentAction(actionName) {
    return {
      content: [
        {
          type: 'text',
          text: `Setting current action to ${actionName} requires human approval. Please run: ./aicheck action set ${actionName}`,
        },
      ],
    };
  }

  async logClaudeInteraction(purpose, content) {
    try {
      const currentAction = existsSync('.aicheck/current_action')
        ? readFileSync('.aicheck/current_action', 'utf-8').trim()
        : null;
      
      if (!currentAction || currentAction === 'None') {
        throw new Error('No current action set');
      }
      
      const dirName = currentAction.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase();
      const interactionDir = `.aicheck/actions/${dirName}/supporting_docs/claude-interactions`;
      
      if (!existsSync(interactionDir)) {
        mkdirSync(interactionDir, { recursive: true });
      }
      
      const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
      const filename = `${timestamp}-${purpose.replace(/\s+/g, '-').toLowerCase()}.md`;
      const filepath = join(interactionDir, filename);
      
      const logContent = `# Claude Interaction: ${purpose}

**Date:** ${new Date().toISOString()}
**Purpose:** ${purpose}
**Action:** ${currentAction}

## Content

${content}
`;
      
      writeFileSync(filepath, logContent);
      
      return {
        content: [
          {
            type: 'text',
            text: `Claude interaction logged: ${filepath}`,
          },
        ],
      };
    } catch (error) {
      throw new Error(`Failed to log Claude interaction: ${error.message}`);
    }
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('AICheck MCP server running on stdio');
  }
}

const server = new AICheckMCPServer();
server.run().catch(console.error);
MCP_SERVER

# Create MCP configuration
cat > .mcp/mcp.json << 'MCP_CONFIG'
{
  "mcpServers": {
    "aicheck": {
      "command": "node",
      "args": [".mcp/server/index.js"],
      "transport": "stdio"
    }
  }
}
MCP_CONFIG

# Create MCP setup script
cat > .mcp/setup.sh << 'MCP_SETUP'
#!/bin/bash

# AICheck MCP Server Setup Script

# Get the absolute path to the project directory
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
MCP_SERVER_DIR="$PROJECT_DIR/.mcp/server"

echo "Setting up AICheck MCP server in $MCP_SERVER_DIR"

# Install dependencies
echo "Installing dependencies..."
cd "$MCP_SERVER_DIR" || exit
npm install

# Make the server executable
echo "Making the server executable..."
chmod +x "$MCP_SERVER_DIR/index.js"

# Check if Claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo "Claude CLI not found. Please ensure Claude Code is installed and available in PATH."
    echo "Visit https://claude.ai/code for installation instructions."
    exit 1
fi

# Register the MCP server with Claude
echo "Registering the MCP server with Claude..."

# Try simple registration first
if claude mcp add aicheck > /dev/null 2>&1; then
    echo "✓ AICheck MCP server registered successfully (simple method)"
elif claude mcp add -s local -t stdio aicheck node "$MCP_SERVER_DIR/index.js" > /dev/null 2>&1; then
    echo "✓ AICheck MCP server registered successfully (detailed method)"
else
    echo "⚠ Registration failed. Manual setup required:"
    echo "   Run: claude mcp add aicheck"
    echo "   Or: claude mcp add -s local -t stdio aicheck node \"$MCP_SERVER_DIR/index.js\""
fi

echo "AICheck MCP server setup complete!"
echo
echo "You can now use AICheck governance tools with Claude."
echo "To verify the setup, run: claude mcp list"
MCP_SETUP

chmod +x .mcp/setup.sh

echo -e "${GREEN}✓ Created MCP server infrastructure${NC}"

# Check for and install Claude CLI if needed
echo -e "${BRIGHT_BLURPLE}Checking for Claude CLI...${NC}"

if command -v claude &> /dev/null; then
    echo -e "${GREEN}✓ Claude CLI already installed${NC}"
    CLAUDE_AVAILABLE=true
elif command -v npm &> /dev/null; then
    echo -e "${YELLOW}Claude CLI not found, but npm is available${NC}"
    echo -e "${BRIGHT_BLURPLE}Installing Claude CLI automatically...${NC}"
    
    # Install Claude CLI via npm
    if npm install -g @anthropic-ai/claude-code; then
        echo -e "${GREEN}✓ Claude CLI installed successfully${NC}"
        CLAUDE_AVAILABLE=true
    else
        echo -e "${RED}✗ Failed to install Claude CLI${NC}"
        echo -e "${YELLOW}You can install it manually: npm install -g @anthropic-ai/claude-code${NC}"
        CLAUDE_AVAILABLE=false
    fi
else
    echo -e "${YELLOW}Neither Claude CLI nor npm found${NC}"
    echo -e "${YELLOW}Install Node.js and npm first, then Claude CLI${NC}"
    echo -e "${YELLOW}Or install Claude Code from https://claude.ai/code${NC}"
    CLAUDE_AVAILABLE=false
fi

# Automatically set up MCP server if Claude CLI is available
echo -e "${BRIGHT_BLURPLE}Attempting automatic MCP server setup...${NC}"

if [ "$CLAUDE_AVAILABLE" = true ]; then
    echo -e "${GREEN}Claude CLI available! Setting up MCP server automatically...${NC}"
    
    # Run MCP setup
    if ./.mcp/setup.sh; then
        echo -e "${GREEN}✓ MCP server setup completed automatically${NC}"
        MCP_SETUP_SUCCESS=true
    else
        echo -e "${YELLOW}⚠ MCP setup encountered issues - you may need to run it manually${NC}"
        MCP_SETUP_SUCCESS=false
    fi
else
    echo -e "${YELLOW}Claude CLI not available - MCP setup will need to be run manually${NC}"
    MCP_SETUP_SUCCESS=false
fi

# Done!
echo -e "\n${GREEN}${BOLD}✓ AICheck MCP installed successfully!${NC}"
echo -e "${GREEN}Directory structure and core files created in current directory.${NC}\n"

# Display next steps based on MCP setup success
echo -e "${BOLD}${BRIGHT_BLURPLE}NEXT STEPS:${NC}"

# Auto-copy activation prompt to clipboard
echo -e "${BRIGHT_BLURPLE}Copying AICheck activation prompt to clipboard...${NC}"

CLIPBOARD_SUCCESS=false

if command -v pbcopy > /dev/null; then
    # macOS
    cat .aicheck/claude_aicheck_prompt.md | pbcopy
    CLIPBOARD_SUCCESS=true
elif command -v xclip > /dev/null; then
    # Linux with xclip
    cat .aicheck/claude_aicheck_prompt.md | xclip -selection clipboard
    CLIPBOARD_SUCCESS=true
elif command -v clip.exe > /dev/null; then
    # Windows with clip.exe (WSL)
    cat .aicheck/claude_aicheck_prompt.md | clip.exe
    CLIPBOARD_SUCCESS=true
fi

if [ "$CLIPBOARD_SUCCESS" = true ]; then
    echo -e "${GREEN}✓ AICheck activation prompt copied to clipboard${NC}"
else
    echo -e "${YELLOW}⚠ Could not copy to clipboard - will show manual steps${NC}"
fi

if [ "$MCP_SETUP_SUCCESS" = true ] && [ "$CLIPBOARD_SUCCESS" = true ]; then
    echo -e "${GREEN}${BOLD}🚀 FULLY AUTOMATED SETUP COMPLETE!${NC}"
    echo -e "${GREEN}✓ Claude CLI installed/configured${NC}"
    echo -e "${GREEN}✓ MCP server configured and registered${NC}" 
    echo -e "${GREEN}✓ Activation prompt copied to clipboard${NC}"
    echo -e "${BRIGHT_BLURPLE}READY TO USE:${NC}"
    echo -e "${BRIGHT_BLURPLE}1. Start a new Claude Code conversation${NC}"
    echo -e "${BRIGHT_BLURPLE}2. Paste the activation text (already in clipboard)${NC}"
    echo -e "${BRIGHT_BLURPLE}3. Start coding with full AICheck + MCP integration!${NC}\n"
    
    echo -e "${CYAN}To verify MCP setup: ${YELLOW}claude mcp list${NC}"
elif [ "$MCP_SETUP_SUCCESS" = true ]; then
    echo -e "${GREEN}✓ MCP server configured${NC}"
    echo -e "${BRIGHT_BLURPLE}1. Run the activation script to copy the Claude Code prompt:${NC}"
    echo -e "   ${YELLOW}./activate_aicheck_claude.sh${NC}"
    echo -e "${BRIGHT_BLURPLE}2. Start a new Claude Code conversation${NC}"
    echo -e "${BRIGHT_BLURPLE}3. Paste the activation text to Claude${NC}"
    echo -e "${BRIGHT_BLURPLE}4. Claude will automatically recognize and use AICheck with MCP tools${NC}\n"
    
    echo -e "${CYAN}To verify MCP setup: ${YELLOW}claude mcp list${NC}"
elif [ "$CLAUDE_AVAILABLE" = true ]; then
    echo -e "${GREEN}✓ Claude CLI available${NC}"
    echo -e "${BRIGHT_BLURPLE}1. Set up the MCP server:${NC}"
    echo -e "   ${YELLOW}./.mcp/setup.sh${NC}"
    echo -e "${BRIGHT_BLURPLE}   OR try the simple command: ${YELLOW}claude mcp add aicheck${NC}"
    echo -e "${BRIGHT_BLURPLE}2. Run the activation script:${NC}"
    echo -e "   ${YELLOW}./activate_aicheck_claude.sh${NC}"
    echo -e "${BRIGHT_BLURPLE}3. Start Claude Code and paste the activation text${NC}"
else
    echo -e "${BRIGHT_BLURPLE}MANUAL SETUP REQUIRED:${NC}"
    echo -e "${BRIGHT_BLURPLE}1. Install Claude CLI: ${YELLOW}npm install -g @anthropic-ai/claude-code${NC}"
    echo -e "${BRIGHT_BLURPLE}2. Set up MCP server: ${YELLOW}./.mcp/setup.sh${NC}"
    echo -e "${BRIGHT_BLURPLE}   OR try the simple command: ${YELLOW}claude mcp add aicheck${NC}"
    echo -e "${BRIGHT_BLURPLE}3. Copy activation prompt: ${YELLOW}./activate_aicheck_claude.sh${NC}"
    echo -e "${BRIGHT_BLURPLE}4. Start Claude Code and paste the activation text${NC}\n"
    
    echo -e "${YELLOW}Note: You'll need Node.js and npm if not already installed${NC}"
fi

echo -e "${YELLOW}If you have existing PascalCase action directories:${NC}"
echo -e "   ${YELLOW}./migrate_action_names.sh${NC} to convert them to kebab-case\n"

echo -e "${GREEN}${BOLD}Enjoy using AICheck MCP!${NC}"