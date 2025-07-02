#!/bin/bash
# AICheck Action Validation Functions
# Validates action state and consistency

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/errors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"

# Validate single active action principle
function validate_single_active_action() {
    # Only run for commands that need validation
    local cmd=${1:-}
    case "$cmd" in
        "status"|"focus"|"deploy"|"complete"|"auto-iterate"|"ACTIVE"|"new")
            # These commands need validation
            ;;
        *)
            # Skip validation for other commands
            return 0
            ;;
    esac
    
    # Count active actions
    local index_active=$(grep -c "| .* | .* | ActiveAction | .* | .* |" .aicheck/actions_index.md 2>/dev/null || echo "0")
    local current=$(cat .aicheck/current_action 2>/dev/null || echo "None")
    
    if [ "$index_active" -gt 1 ]; then
        print_error "ERROR: Multiple active actions detected!"
        print_warning "AICheck requires exactly ONE active action at a time."
        print_info "Run './aicheck cleanup' to fix this issue."
        echo ""
        return 1
    elif [ "$index_active" -eq 0 ] && [ "$current" != "None" ] && [ "$current" != "" ]; then
        print_warning "WARNING: Inconsistent state detected"
        print_info "Current action is '$current' but not marked active in index."
        print_info "Run './aicheck cleanup' to fix this issue."
        echo ""
        return 1
    fi
    return 0
}

# Validate action name format
function validate_action_name() {
    local name=$1
    
    if [ -z "$name" ]; then
        error_exit "Action name cannot be empty" $ERR_INVALID_INPUT
    fi
    
    # Check format: start with letter, then letters/numbers/hyphens
    if [[ ! "$name" =~ ^[A-Za-z][A-Za-z0-9-]*$ ]]; then
        error_exit "Invalid action name: '$name'. Use only letters, numbers, and hyphens. Must start with a letter." $ERR_INVALID_INPUT
    fi
    
    # Check length
    if [ ${#name} -gt 50 ]; then
        error_exit "Action name too long. Maximum 50 characters." $ERR_INVALID_INPUT
    fi
    
    return 0
}

# Validate action exists
function validate_action_exists() {
    local action_name=$1
    local dir_name=$(to_kebab_case "$action_name")
    
    if [ ! -d ".aicheck/actions/$dir_name" ]; then
        error_exit "Action '$action_name' does not exist" $ERR_FILE_NOT_FOUND
    fi
    
    return 0
}

# Convert PascalCase to kebab-case
function to_kebab_case() {
    echo "$1" | sed 's/\([a-z0-9]\)\([A-Z]\)/\1-\2/g' | tr '[:upper:]' '[:lower:]'
}

# Convert kebab-case to PascalCase
function to_pascal_case() {
    echo "$1" | sed 's/-\([a-z]\)/\U\1/g' | sed 's/^./\U&/'
}

# Validate action completeness
function validate_action_completeness() {
    local current_action=$(cat .aicheck/current_action 2>/dev/null || echo "None")
    
    if [ "$current_action" = "None" ] || [ "$current_action" = "AICheckExec" ]; then
        return 0
    fi
    
    print_section "🔍 Validating RULES compliance and action completeness..."
    
    local dir_name=$(to_kebab_case "$current_action")
    local action_dir=".aicheck/actions/$dir_name"
    local issues=()
    local auto_fixes=()
    
    # 1. RULES: Check action status and matrix updates
    print_header "📋 Checking action status compliance..."
    
    if [ ! -f "$action_dir/status.txt" ]; then
        issues+=("Action status file missing")
        auto_fixes+=("create_status_file")
    fi
    
    # Verify actions_index.md is current
    if [ -f ".aicheck/actions_index.md" ]; then
        if ! grep -q "$current_action" .aicheck/actions_index.md; then
            issues+=("Action not registered in actions_index.md")
            auto_fixes+=("update_actions_index")
        fi
    fi
    
    # 2. RULES: Check action timeline and progress tracking
    print_header "📈 Checking timeline and progress compliance..."
    
    if [ ! -f "$action_dir/progress.md" ]; then
        issues+=("Progress tracking missing: $action_dir/progress.md")
        auto_fixes+=("create_progress_tracking")
    else
        # Check if progress has been updated recently
        local last_update=$(stat -f "%m" "$action_dir/progress.md" 2>/dev/null || stat -c "%Y" "$action_dir/progress.md" 2>/dev/null || echo "0")
        local current_time=$(date +%s)
        local time_diff=$((current_time - last_update))
        if [ "$time_diff" -gt 86400 ]; then  # 24 hours
            issues+=("Progress tracking not updated in 24+ hours")
            auto_fixes+=("update_progress_timestamp")
        fi
    fi
    
    # 3. RULES: Check dependency documentation
    print_header "🔗 Checking dependency compliance..."
    
    # Report issues
    if [ ${#issues[@]} -gt 0 ]; then
        print_warning "Found ${#issues[@]} compliance issues:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
        return 1
    else
        print_success "All compliance checks passed"
        return 0
    fi
}