#!/bin/bash
# Simulate the v7.3 installer to test it properly

echo "Testing AICheck v7.3.0 Installer"
echo "================================"

# Create test directory
TEST_DIR="test_v7.3_install"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo -e "\n1. Testing download simulation..."
# Simulate downloads by copying local files
cp ../aicheck .
chmod +x aicheck

# Create module structure
mkdir -p aicheck-lib/{ui,core,validation,detection,actions,mcp,git,automation,maintenance,deployment,tools}

# Copy all modules
echo -e "\n2. Installing modules..."
modules=(
    "ui/colors.sh"
    "ui/output.sh"
    "core/errors.sh"
    "core/state.sh"
    "core/dispatcher.sh"
    "core/utilities.sh"
    "validation/input.sh"
    "validation/actions.sh"
    "detection/environment.sh"
    "actions/management.sh"
    "mcp/integration.sh"
    "git/operations.sh"
    "automation/auto_iterate.sh"
    "maintenance/cleanup.sh"
    "deployment/validation.sh"
)

INSTALLED=0
FAILED=0

for module in "${modules[@]}"; do
    if [ -f "../aicheck-lib/$module" ]; then
        cp "../aicheck-lib/$module" "aicheck-lib/$module"
        echo "  ✓ $module"
        ((INSTALLED++))
    else
        echo "  ✗ $module (not found)"
        ((FAILED++))
    fi
done

echo -e "\nModules: $INSTALLED installed, $FAILED failed"

# Initialize AICheck
echo -e "\n3. Initializing AICheck..."
mkdir -p .aicheck
echo "None" > .aicheck/current_action
cat > .aicheck/actions_index.md << 'EOF'
# AICheck Actions Index

| Action | Description | Status | Created | Context Size |
|--------|-------------|--------|---------|--------------|
EOF

# Test functionality
echo -e "\n4. Testing core functionality..."
echo -n "  Version: "
./aicheck version >/dev/null 2>&1 && echo "✓" || echo "✗"

echo -n "  Status: "
./aicheck status >/dev/null 2>&1 && echo "✓" || echo "✗"

echo -n "  Module loading: "
bash -c 'source aicheck-lib/core/dispatcher.sh && load_all_modules && type print_success >/dev/null 2>&1' && echo "✓" || echo "✗"

echo -n "  Create action: "
./aicheck new TestAction "Test description" >/dev/null 2>&1 && echo "✓" || echo "✗"

echo -n "  List actions: "
ls -la .aicheck/actions/ 2>/dev/null | grep -q test-action && echo "✓" || echo "✗"

# Test that modules are found
echo -e "\n5. Module accessibility test..."
if [ -d "aicheck-lib" ]; then
    MODULE_COUNT=$(find aicheck-lib -name "*.sh" | wc -l)
    echo "  Modules found: $MODULE_COUNT"
    if [ "$MODULE_COUNT" -ge 15 ]; then
        echo "  ✓ All core modules present"
    else
        echo "  ✗ Missing modules (found $MODULE_COUNT, expected 15+)"
    fi
else
    echo "  ✗ aicheck-lib directory not found!"
fi

# Summary
echo -e "\n================================"
if [ $FAILED -eq 0 ] && [ "$MODULE_COUNT" -ge 15 ]; then
    echo "✓ Installation test PASSED"
    echo "  The installer would work correctly"
else
    echo "✗ Installation test FAILED"
    echo "  Issues found that need fixing"
fi

cd ..
echo -e "\nTest directory: $TEST_DIR"