#!/bin/bash
# AICheck State Management Functions
# Manages action state and synchronization

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/errors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../validation/actions.sh"

# Lock file management
LOCK_DIR=".aicheck"
STATE_LOCK="$LOCK_DIR/.state.lock"
OPERATION_LOCK="$LOCK_DIR/.operation.lock"

# Acquire lock with timeout
function acquire_lock() {
    local lock_file=$1
    local timeout=${2:-10}
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        if mkdir "$lock_file" 2>/dev/null; then
            echo $$ > "$lock_file/pid"
            return 0
        fi
        
        # Check if lock holder is still alive
        if [ -f "$lock_file/pid" ]; then
            local pid=$(cat "$lock_file/pid" 2>/dev/null)
            if [ -n "$pid" ] && ! kill -0 "$pid" 2>/dev/null; then
                # Process is dead, remove stale lock
                rm -rf "$lock_file"
                continue
            fi
        fi
        
        sleep 0.5
        elapsed=$((elapsed + 1))
    done
    
    return 1
}

# Release lock
function release_lock() {
    local lock_file=$1
    rm -rf "$lock_file"
}

# Get current action (with locking)
function get_current_action() {
    if ! acquire_lock "$STATE_LOCK"; then
        error_exit "Could not acquire state lock" $ERR_LOCK_FAILED
    fi
    
    local current_action=$(cat "$LOCK_DIR/current_action" 2>/dev/null || echo "None")
    
    release_lock "$STATE_LOCK"
    echo "$current_action"
}

# Set current action (with validation and locking)
function set_current_action() {
    local new_action=$1
    
    if ! acquire_lock "$STATE_LOCK"; then
        error_exit "Could not acquire state lock" $ERR_LOCK_FAILED
    fi
    
    # Validate action name
    if [ "$new_action" != "None" ]; then
        validate_action_name "$new_action" || {
            release_lock "$STATE_LOCK"
            return 1
        }
    fi
    
    # Update current_action file
    echo "$new_action" > "$LOCK_DIR/current_action"
    
    # Update actions_index.md
    if [ -f "$LOCK_DIR/actions_index.md" ] && [ "$new_action" != "None" ]; then
        # First, remove any existing ActiveAction status
        sed -i.bak 's/| ActiveAction |/| In Progress |/g' "$LOCK_DIR/actions_index.md"
        
        # Then set the new action as ActiveAction
        sed -i.bak "s/| $new_action | \\([^|]*\\) | [^|]* |/| $new_action | \\1 | ActiveAction |/" "$LOCK_DIR/actions_index.md"
        
        # Clean up backup files
        rm -f "$LOCK_DIR/actions_index.md.bak"
    fi
    
    # Update action's status.txt
    if [ "$new_action" != "None" ]; then
        local dir_name=$(to_kebab_case "$new_action")
        echo "ActiveAction" > "$LOCK_DIR/actions/$dir_name/status.txt"
    fi
    
    release_lock "$STATE_LOCK"
    return 0
}

# Clear current action
function clear_current_action() {
    local current=$(get_current_action)
    
    if [ "$current" != "None" ]; then
        if ! acquire_lock "$STATE_LOCK"; then
            error_exit "Could not acquire state lock" $ERR_LOCK_FAILED
        fi
        
        # Update status in actions_index.md
        if [ -f "$LOCK_DIR/actions_index.md" ]; then
            sed -i.bak "s/| $current | \\([^|]*\\) | ActiveAction |/| $current | \\1 | In Progress |/" "$LOCK_DIR/actions_index.md"
            rm -f "$LOCK_DIR/actions_index.md.bak"
        fi
        
        # Update action's status.txt
        local dir_name=$(to_kebab_case "$current")
        if [ -d "$LOCK_DIR/actions/$dir_name" ]; then
            echo "In Progress" > "$LOCK_DIR/actions/$dir_name/status.txt"
        fi
        
        # Clear current_action
        echo "None" > "$LOCK_DIR/current_action"
        
        release_lock "$STATE_LOCK"
    fi
}

# Fix state synchronization issues
function sync_action_state() {
    print_section "🔧 Synchronizing action state..."
    
    if ! acquire_lock "$STATE_LOCK"; then
        error_exit "Could not acquire state lock" $ERR_LOCK_FAILED
    fi
    
    local current_action=$(cat "$LOCK_DIR/current_action" 2>/dev/null || echo "None")
    local fixed_issues=0
    
    # 1. Check actions_index.md for multiple ActiveActions
    if [ -f "$LOCK_DIR/actions_index.md" ]; then
        local active_count=$(grep -c "| ActiveAction |" "$LOCK_DIR/actions_index.md" || echo "0")
        
        if [ "$active_count" -gt 1 ]; then
            print_warning "Found $active_count ActiveAction entries, fixing..."
            # Remove all ActiveAction statuses
            sed -i.bak 's/| ActiveAction |/| In Progress |/g' "$LOCK_DIR/actions_index.md"
            fixed_issues=$((fixed_issues + 1))
        fi
        
        # If we have a current action, ensure it's marked as ActiveAction
        if [ "$current_action" != "None" ] && [ "$current_action" != "" ]; then
            if ! grep -q "| $current_action | .* | ActiveAction |" "$LOCK_DIR/actions_index.md"; then
                print_info "Setting $current_action as ActiveAction in index..."
                sed -i.bak "s/| $current_action | \\([^|]*\\) | [^|]* |/| $current_action | \\1 | ActiveAction |/" "$LOCK_DIR/actions_index.md"
                fixed_issues=$((fixed_issues + 1))
            fi
        fi
        
        rm -f "$LOCK_DIR/actions_index.md.bak"
    fi
    
    # 2. Check all action directories for status.txt consistency
    if [ -d "$LOCK_DIR/actions" ]; then
        for action_dir in "$LOCK_DIR/actions"/*; do
            if [ -d "$action_dir" ]; then
                local dir_name=$(basename "$action_dir")
                local action_name=$(to_pascal_case "$dir_name")
                local status_file="$action_dir/status.txt"
                
                if [ -f "$status_file" ]; then
                    local status=$(cat "$status_file")
                    
                    # If this is the current action, it should be ActiveAction
                    if [ "$action_name" = "$current_action" ] && [ "$status" != "ActiveAction" ]; then
                        print_info "Updating status.txt for $action_name to ActiveAction..."
                        echo "ActiveAction" > "$status_file"
                        fixed_issues=$((fixed_issues + 1))
                    # If this is not the current action, it should not be ActiveAction
                    elif [ "$action_name" != "$current_action" ] && [ "$status" = "ActiveAction" ]; then
                        print_info "Updating status.txt for $action_name to In Progress..."
                        echo "In Progress" > "$status_file"
                        fixed_issues=$((fixed_issues + 1))
                    fi
                fi
            fi
        done
    fi
    
    # 3. If current_action is None but we have an ActiveAction in index, clear it
    if [ "$current_action" = "None" ] || [ -z "$current_action" ]; then
        if [ -f "$LOCK_DIR/actions_index.md" ] && grep -q "| ActiveAction |" "$LOCK_DIR/actions_index.md"; then
            print_info "Clearing ActiveAction status (no current action)..."
            sed -i.bak 's/| ActiveAction |/| In Progress |/g' "$LOCK_DIR/actions_index.md"
            rm -f "$LOCK_DIR/actions_index.md.bak"
            fixed_issues=$((fixed_issues + 1))
        fi
    fi
    
    release_lock "$STATE_LOCK"
    
    if [ $fixed_issues -eq 0 ]; then
        print_success "Action state is synchronized"
    else
        print_success "Fixed $fixed_issues state synchronization issues"
    fi
    
    return 0
}

# Get action status
function get_action_status() {
    local action_name=$1
    local dir_name=$(to_kebab_case "$action_name")
    local status_file="$LOCK_DIR/actions/$dir_name/status.txt"
    
    if [ -f "$status_file" ]; then
        cat "$status_file"
    else
        echo "Not Started"
    fi
}

# Update action status
function update_action_status() {
    local action_name=$1
    local new_status=$2
    
    if ! acquire_lock "$STATE_LOCK"; then
        error_exit "Could not acquire state lock" $ERR_LOCK_FAILED
    fi
    
    local dir_name=$(to_kebab_case "$action_name")
    local status_file="$LOCK_DIR/actions/$dir_name/status.txt"
    
    # Validate status
    case "$new_status" in
        "Not Started"|"In Progress"|"ActiveAction"|"Completed")
            ;;
        *)
            release_lock "$STATE_LOCK"
            error_exit "Invalid status: $new_status" $ERR_INVALID_INPUT
            ;;
    esac
    
    # Only one action can be ActiveAction
    if [ "$new_status" = "ActiveAction" ]; then
        # Clear any existing ActiveAction
        clear_current_action
        # Set this as current
        set_current_action "$action_name"
    else
        # Update status file
        echo "$new_status" > "$status_file"
        
        # Update actions_index.md
        if [ -f "$LOCK_DIR/actions_index.md" ]; then
            sed -i.bak "s/| $action_name | \\([^|]*\\) | [^|]* |/| $action_name | \\1 | $new_status |/" "$LOCK_DIR/actions_index.md"
            rm -f "$LOCK_DIR/actions_index.md.bak"
        fi
    fi
    
    release_lock "$STATE_LOCK"
    return 0
}

# Check if action is active
function is_action_active() {
    local action_name=$1
    local current=$(get_current_action)
    
    [ "$action_name" = "$current" ]
}

# Get all actions
function get_all_actions() {
    if [ ! -f "$LOCK_DIR/actions_index.md" ]; then
        return
    fi
    
    # Skip header lines and extract action names
    tail -n +3 "$LOCK_DIR/actions_index.md" | grep "^|" | while read -r line; do
        local action_name=$(echo "$line" | cut -d'|' -f2 | xargs)
        [ -n "$action_name" ] && echo "$action_name"
    done
}

# Count active actions (for validation)
function count_active_actions() {
    local count=0
    
    # Count in actions_index.md
    if [ -f "$LOCK_DIR/actions_index.md" ]; then
        count=$(grep -c "| ActiveAction |" "$LOCK_DIR/actions_index.md" || echo "0")
    fi
    
    echo "$count"
}