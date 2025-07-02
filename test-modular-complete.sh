#!/bin/bash
# Comprehensive test of the modular AICheck system

echo "Complete Modular AICheck Test Suite"
echo "=================================="

# Test various commands
echo -e "\n1. Testing version command..."
./aicheck-modular version > /dev/null && echo "✓ Version command works" || echo "✗ Version failed"

echo -e "\n2. Testing help command..."
./aicheck-modular help > /dev/null && echo "✓ Help command works" || echo "✗ Help failed"

echo -e "\n3. Testing status command..."
./aicheck-modular status 2>&1 | grep -q "Current Action" && echo "✓ Status command works" || echo "✗ Status failed"

echo -e "\n4. Testing dependency check..."
./aicheck-modular deps 2>&1 | grep -q "Required commands" && echo "✓ Dependency check works" || echo "✗ Deps failed"

echo -e "\n5. Testing cleanup command..."
./aicheck-modular cleanup 2>&1 | grep -q "Cleanup" && echo "✓ Cleanup command works" || echo "✗ Cleanup failed"

echo -e "\n6. Testing MCP subcommands..."
./aicheck-modular mcp info 2>&1 | grep -q "No active action" && echo "✓ MCP info works" || echo "✗ MCP failed"

echo -e "\n7. Testing action subcommands..."
./aicheck-modular action list 2>&1 | grep -q "Actions" && echo "✓ Action list works" || echo "✗ Action list failed"

echo -e "\n8. Module count check..."
module_count=$(find aicheck-lib -name "*.sh" -type f | wc -l | tr -d ' ')
echo "Total modules created: $module_count"

echo -e "\n9. Line count comparison..."
original_lines=$(wc -l < aicheck)
modular_lines=$(wc -l < aicheck-modular)
module_lines=$(find aicheck-lib -name "*.sh" -type f -exec wc -l {} + | tail -1 | awk '{print $1}')
echo "Original aicheck: $original_lines lines"
echo "Modular aicheck: $modular_lines lines"
echo "Module libraries: $module_lines lines"
echo "Total modular: $((modular_lines + module_lines)) lines"

echo -e "\n✅ Modular structure test complete!"