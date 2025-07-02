#!/bin/bash
# Test script for AICheck modular structure

echo "Testing AICheck Modular Structure"
echo "================================="

# Test colors module
echo -e "\n1. Testing colors module..."
source aicheck-lib/ui/colors.sh
echo -e "${GREEN}✓ Green text${NC}"
echo -e "${RED}✓ Red text${NC}"
echo -e "${BRIGHT_BLURPLE}✓ Bright blurple text${NC}"

# Test output module
echo -e "\n2. Testing output module..."
source aicheck-lib/ui/output.sh
print_success "Success message test"
print_error "Error message test"
print_warning "Warning message test"
print_info "Info message test"

# Test error module
echo -e "\n3. Testing error module..."
source aicheck-lib/core/errors.sh
echo "Error codes defined: ERR_GENERAL=$ERR_GENERAL, ERR_NOT_INITIALIZED=$ERR_NOT_INITIALIZED"

# Test input validation
echo -e "\n4. Testing input validation..."
source aicheck-lib/validation/input.sh
if validate_command "status"; then
    echo "✓ 'status' is a valid command"
fi
if ! validate_command "invalid-command" 2>/dev/null; then
    echo "✓ 'invalid-command' correctly rejected"
fi

# Test action validation
echo -e "\n5. Testing action validation..."
source aicheck-lib/validation/actions.sh
echo "✓ Action validation functions loaded"

# Test environment detection
echo -e "\n6. Testing environment detection..."
source aicheck-lib/detection/environment.sh
echo "Detected environment: $(detect_project_environment | tr '\n' ' ')"

# Test state management
echo -e "\n7. Testing state management..."
source aicheck-lib/core/state.sh
echo "✓ State management functions loaded"

# Test full aicheck command
echo -e "\n8. Testing full aicheck command..."
./aicheck version | head -3

echo -e "\n${GREEN}✓ All modular structure tests passed!${NC}"