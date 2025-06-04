#!/bin/bash

# Script to set up AICheck git hooks
# These hooks maintain AICheck compliance without being too restrictive

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up AICheck git hooks...${NC}"

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Create pre-commit hook
cat > .git/hooks/pre-commit << 'EOL'
#!/bin/bash

# AICheck pre-commit hook
# Helps maintain compliance without being too restrictive

GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Get current action
CURRENT_ACTION=""
if [ -f ".aicheck/current_action" ]; then
  CURRENT_ACTION=$(cat .aicheck/current_action)
fi

# Get list of files being committed
FILES=$(git diff --cached --name-only --diff-filter=ACM)

# 1. Check commit message format (run during commit-msg hook, but check staged files here)
echo -e "${BLUE}Analyzing staged changes...${NC}"

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
    echo -e "${YELLOW}Consider running:\n  /aicheck dependency add NAME VERSION JUSTIFICATION${NC}"
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
    echo -e "${YELLOW}Use /aicheck action set ACTION_NAME to switch actions${NC}"
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
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
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

# Create post-commit hook
cat > .git/hooks/post-commit << 'EOL'
#!/bin/bash

# AICheck post-commit hook
# Updates action progress tracking

# Get current action
CURRENT_ACTION=""
if [ -f ".aicheck/current_action" ]; then
  CURRENT_ACTION=$(cat .aicheck/current_action)
fi

# Skip if no action or in exec mode
if [ -z "$CURRENT_ACTION" ] || [ "$CURRENT_ACTION" = "None" ] || [ "$CURRENT_ACTION" = "AICheckExec" ]; then
  exit 0
fi

# Convert PascalCase to kebab-case
ACTION_DIR=$(echo "$CURRENT_ACTION" | sed -r 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')

# Update progress file with commit information
PROGRESS_FILE=".aicheck/actions/$ACTION_DIR/progress.md"
if [ -f "$PROGRESS_FILE" ]; then
  COMMIT_HASH=$(git log -1 --format="%h")
  COMMIT_MSG=$(git log -1 --format="%s")
  COMMIT_DATE=$(git log -1 --format="%ad" --date=short)
  
  # Add new update to progress file
  sed -i "/^## Updates/a \\
$COMMIT_DATE - [$COMMIT_HASH] $COMMIT_MSG" "$PROGRESS_FILE"
fi

exit 0
EOL

chmod +x .git/hooks/post-commit

echo -e "${GREEN}✓ Installed AICheck git hooks${NC}"
echo -e "\nHooks installed:"
echo -e "  ${BLUE}pre-commit${NC} - Checks for dependency updates and test coverage"
echo -e "  ${BLUE}commit-msg${NC} - Validates commit message format and action references"
echo -e "  ${BLUE}post-commit${NC} - Updates action progress tracking"
echo -e "\nThese hooks provide helpful guidance without blocking workflow."
echo -e "They won't prevent commits, just offer friendly reminders to follow AICheck practices."