#!/bin/bash
# Integration test for AICheck modular structure

set -e

echo "AICheck Integration Tests"
echo "========================"

# Test environment
TEST_DIR="test_integration_$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Initialize git repo for testing
git init --quiet
git config user.email "test@example.com"
git config user.name "Test User"

# Copy aicheck and modules
cp -r ../aicheck .
cp -r ../aicheck-lib .

# Initialize AICheck
mkdir -p .aicheck
echo "None" > .aicheck/current_action

echo -e "\n1. Testing action creation..."
if bash -c 'source aicheck-lib/actions/management.sh && create_action "TestAction" "Test the integration"'; then
    echo "✓ Action creation successful"
else
    echo "✗ Action creation failed"
    exit 1
fi

echo -e "\n2. Testing action activation..."
if bash -c 'source aicheck-lib/core/state.sh && source aicheck-lib/actions/management.sh && set_active_action "TestAction"'; then
    echo "✓ Action activation successful"
else
    echo "✗ Action activation failed"
    exit 1
fi

echo -e "\n3. Testing environment detection..."
# Create test files
touch package.json
echo '[tool.poetry]' > pyproject.toml
mkdir -p .github/workflows
touch .github/workflows/test.yml

env_result=$(bash -c 'source aicheck-lib/detection/environment.sh && detect_project_environment')
if [[ "$env_result" == *"node"* ]] && [[ "$env_result" == *"python-poetry"* ]] && [[ "$env_result" == *"github-actions"* ]]; then
    echo "✓ Environment detection successful"
    echo "  Detected: $env_result"
else
    echo "✗ Environment detection failed"
    exit 1
fi

echo -e "\n4. Testing MCP header generation..."
touch test.py
if bash -c 'source aicheck-lib/mcp/integration.sh && source aicheck-lib/core/state.sh && generate_mcp_header "test.py"' > /dev/null; then
    echo "✓ MCP header generation successful"
else
    echo "✗ MCP header generation failed"
    exit 1
fi

echo -e "\n5. Testing git operations..."
echo "test content" > test.txt
git add test.txt
git commit -m "Initial commit" --quiet

# Set default branch name for consistency
git checkout -b main --quiet 2>/dev/null || true

branch=$(bash -c 'source aicheck-lib/git/operations.sh && get_current_branch' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')
if [ "$branch" = "main" ] || [ "$branch" = "master" ]; then
    echo "✓ Git operations successful (branch: $branch)"
else
    echo "✗ Git operations failed (branch: '$branch')"
    exit 1
fi

echo -e "\n6. Testing state management..."
current=$(bash -c 'source aicheck-lib/core/state.sh && get_current_action' | sed 's/\x1b\[[0-9;]*m//g' | tr -d '\n')
if [ "$current" = "TestAction" ]; then
    echo "✓ State management successful"
else
    echo "✗ State management failed (expected: TestAction, got: '$current')"
    exit 1
fi

echo -e "\n7. Testing validation..."
if bash -c 'source aicheck-lib/validation/input.sh && validate_command "status"'; then
    echo "✓ Command validation successful"
else
    echo "✗ Command validation failed"
    exit 1
fi

echo -e "\n8. Testing full aicheck command..."
if ./aicheck version > /dev/null 2>&1; then
    echo "✓ Full aicheck command works"
else
    echo "✗ Full aicheck command failed"
    exit 1
fi

# Cleanup
cd ..
rm -rf "$TEST_DIR"

echo -e "\n✅ All integration tests passed!"