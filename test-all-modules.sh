#!/bin/bash
# AICheck Module Testing Framework
# Tests all modules for syntax, dependencies, and basic functionality

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}AICheck Module Testing Framework${NC}"
echo "================================="

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNINGS=0

# Test result tracking
declare -A test_results

# Function to run a test
run_test() {
    local test_name=$1
    local test_command=$2
    local module=${3:-"general"}
    
    ((TOTAL_TESTS++))
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} $test_name"
        ((PASSED_TESTS++))
        test_results["$module:$test_name"]="PASS"
    else
        echo -e "  ${RED}✗${NC} $test_name"
        ((FAILED_TESTS++))
        test_results["$module:$test_name"]="FAIL"
    fi
}

# Function to check module
check_module() {
    local module=$1
    local module_name=$(basename "$module")
    
    echo -e "\n${BLUE}Testing: $module_name${NC}"
    
    # Syntax check
    run_test "Syntax valid" "bash -n $module" "$module_name"
    
    # Check for sourcing dependencies
    local deps=$(grep "^source" "$module" | wc -l | tr -d ' ')
    if [ "$deps" -gt 0 ]; then
        echo -e "  ${YELLOW}ℹ${NC} Has $deps dependencies"
        
        # Verify dependencies exist
        while IFS= read -r line; do
            if [[ $line =~ source[[:space:]]+\"([^\"]+)\" ]]; then
                local dep_path="${BASH_REMATCH[1]}"
                # Resolve relative path
                dep_path=$(echo "$dep_path" | sed "s|\$(dirname \"\${BASH_SOURCE\[0\]}\")|$(dirname "$module")|g")
                
                if [ -f "$dep_path" ]; then
                    run_test "Dependency exists: $(basename "$dep_path")" "true" "$module_name"
                else
                    run_test "Dependency exists: $(basename "$dep_path")" "false" "$module_name"
                fi
            fi
        done < <(grep "^source" "$module")
    fi
    
    # Check for required functions based on module type
    case "$module_name" in
        *"dispatcher.sh")
            run_test "Has dispatch_command function" "grep -q 'function dispatch_command' $module" "$module_name"
            run_test "Has load_all_modules function" "grep -q 'function load_all_modules' $module" "$module_name"
            ;;
        *"colors.sh")
            run_test "Defines GREEN color" "grep -q 'GREEN=' $module" "$module_name"
            run_test "Defines NC (no color)" "grep -q 'NC=' $module" "$module_name"
            ;;
        *"output.sh")
            run_test "Has print_success function" "grep -q 'function print_success' $module" "$module_name"
            run_test "Has print_error function" "grep -q 'function print_error' $module" "$module_name"
            ;;
        *"errors.sh")
            run_test "Defines error codes" "grep -q 'ERR_' $module" "$module_name"
            run_test "Has error_exit function" "grep -q 'function error_exit' $module" "$module_name"
            ;;
        *"state.sh")
            run_test "Has get_current_action function" "grep -q 'function get_current_action' $module" "$module_name"
            run_test "Has set_current_action function" "grep -q 'function set_current_action' $module" "$module_name"
            ;;
    esac
    
    # Check for common issues
    if grep -q "set -e" "$module"; then
        echo -e "  ${YELLOW}⚠${NC} Uses 'set -e' (may cause issues in sourced modules)"
        ((WARNINGS++))
    fi
    
    # Check for shellcheck issues if available
    if command -v shellcheck >/dev/null 2>&1; then
        if shellcheck -S error "$module" >/dev/null 2>&1; then
            run_test "ShellCheck clean" "true" "$module_name"
        else
            run_test "ShellCheck clean" "false" "$module_name"
        fi
    fi
}

# Test all modules
echo -e "${BLUE}Scanning for modules...${NC}"
MODULE_COUNT=0

for module in aicheck-lib/**/*.sh; do
    if [ -f "$module" ]; then
        check_module "$module"
        ((MODULE_COUNT++))
    fi
done

# Integration tests
echo -e "\n${BLUE}Running Integration Tests${NC}"
echo "========================="

# Test module loading
echo -e "\n${BLUE}Testing module loading...${NC}"
test_script=$(mktemp)
cat > "$test_script" << 'EOF'
#!/bin/bash
AICHECK_LIB="./aicheck-lib"
source "$AICHECK_LIB/core/dispatcher.sh"
load_all_modules
# Test if functions are available
type print_success >/dev/null 2>&1 && echo "SUCCESS"
EOF
chmod +x "$test_script"

if [ "$($test_script 2>/dev/null)" = "SUCCESS" ]; then
    echo -e "  ${GREEN}✓${NC} Modules load successfully"
    ((PASSED_TESTS++))
else
    echo -e "  ${RED}✗${NC} Module loading failed"
    ((FAILED_TESTS++))
fi
rm -f "$test_script"

# Test circular dependencies
echo -e "\n${BLUE}Checking for circular dependencies...${NC}"
CIRCULAR_DEPS=0

# Build dependency graph
declare -A dep_graph
for module in aicheck-lib/**/*.sh; do
    if [ -f "$module" ]; then
        module_name=$(basename "$module")
        deps=$(grep "^source.*\.sh" "$module" | sed 's/.*\/\([^\/]*\.sh\).*/\1/' | tr '\n' ' ')
        dep_graph["$module_name"]="$deps"
    fi
done

# Simple circular dependency check (basic)
for module in "${!dep_graph[@]}"; do
    deps="${dep_graph[$module]}"
    for dep in $deps; do
        if [[ "${dep_graph[$dep]}" == *"$module"* ]]; then
            echo -e "  ${RED}✗${NC} Circular dependency: $module <-> $dep"
            ((CIRCULAR_DEPS++))
        fi
    done
done

if [ $CIRCULAR_DEPS -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} No circular dependencies found"
    ((PASSED_TESTS++))
else
    ((FAILED_TESTS++))
fi

((TOTAL_TESTS++))

# Performance test
echo -e "\n${BLUE}Testing module load performance...${NC}"
start_time=$(date +%s.%N)
bash -c 'source aicheck-lib/core/dispatcher.sh && load_all_modules' 2>/dev/null
end_time=$(date +%s.%N)
load_time=$(echo "$end_time - $start_time" | bc)

echo -e "  ⏱️  Module load time: ${load_time}s"
if (( $(echo "$load_time < 0.5" | bc -l) )); then
    echo -e "  ${GREEN}✓${NC} Load time acceptable"
    ((PASSED_TESTS++))
else
    echo -e "  ${YELLOW}⚠${NC} Load time slow (>0.5s)"
    ((WARNINGS++))
fi
((TOTAL_TESTS++))

# Summary
echo -e "\n${BLUE}═══════════════════════════════════${NC}"
echo -e "${BLUE}Test Summary${NC}"
echo -e "${BLUE}═══════════════════════════════════${NC}"
echo -e "Modules tested: $MODULE_COUNT"
echo -e "Total tests: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

# Success rate
if [ $TOTAL_TESTS -gt 0 ]; then
    SUCCESS_RATE=$(( PASSED_TESTS * 100 / TOTAL_TESTS ))
    echo -e "Success rate: ${SUCCESS_RATE}%"
    
    if [ $SUCCESS_RATE -eq 100 ]; then
        echo -e "\n${GREEN}✅ All tests passed!${NC}"
        exit 0
    elif [ $SUCCESS_RATE -ge 90 ]; then
        echo -e "\n${YELLOW}⚠️  Most tests passed${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Many tests failed${NC}"
        exit 1
    fi
fi

# Generate detailed report
if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "\n${RED}Failed Tests:${NC}"
    for key in "${!test_results[@]}"; do
        if [ "${test_results[$key]}" = "FAIL" ]; then
            echo "  - $key"
        fi
    done
fi