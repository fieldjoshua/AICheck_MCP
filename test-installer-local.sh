#!/bin/bash
# Test the installer locally

echo "Testing AICheck v7.3.0 Installer Locally"
echo "======================================="

# Create test directory
TEST_DIR="test_install_v7.3"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Copy files instead of downloading
echo "Copying files..."
cp ../aicheck .
cp -r ../aicheck-lib .

# Make executable
chmod +x aicheck

# Initialize
mkdir -p .aicheck
echo "None" > .aicheck/current_action

# Test basic commands
echo ""
echo "Testing commands..."
echo "=================="

echo -n "Version: "
if ./aicheck version >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi

echo -n "Status: "
if ./aicheck status >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi

echo -n "Help: "
if ./aicheck help >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi

echo -n "Module loading: "
if bash -c 'source aicheck-lib/core/dispatcher.sh && load_all_modules' >/dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi

# Cleanup
cd ..
echo ""
echo "Test complete. Keeping $TEST_DIR for inspection."