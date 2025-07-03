#!/bin/bash
# Simple module test that works with older bash versions

echo "Testing AICheck Modules"
echo "======================"

PASSED=0
FAILED=0

# Test each module exists and has valid syntax
for module in aicheck-lib/**/*.sh; do
    if [ -f "$module" ]; then
        echo -n "Testing $module ... "
        if bash -n "$module" 2>/dev/null; then
            echo "✓"
            ((PASSED++))
        else
            echo "✗"
            ((FAILED++))
        fi
    fi
done

echo ""
echo "Results: $PASSED passed, $FAILED failed"

# Test module loading
echo ""
echo "Testing module loading..."
if bash -c 'source aicheck-lib/core/dispatcher.sh && load_all_modules && type print_success >/dev/null 2>&1'; then
    echo "✓ Modules load successfully"
else
    echo "✗ Module loading failed"
fi