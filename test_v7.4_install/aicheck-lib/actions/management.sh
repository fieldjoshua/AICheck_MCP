#!/bin/bash
# AICheck Action Management Functions
# Handles creation, activation, and completion of actions

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/errors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/state.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../validation/actions.sh"

# Create a new action
function create_action() {
    local action_name=$1
    local task_description=$2
    
    # Validate action name
    validate_action_name "$action_name" || return 1
    
    # Convert to directory name
    local dir_name=$(to_kebab_case "$action_name")
    local action_dir=".aicheck/actions/$dir_name"
    
    # Check if action already exists
    if [ -d "$action_dir" ]; then
        error_exit "Action '$action_name' already exists" $ERR_STATE_CONFLICT
    fi
    
    # Create action directory structure
    mkdir -p "$action_dir"
    
    # Initialize action files
    echo "$task_description" > "$action_dir/task.txt"
    echo "Not Started" > "$action_dir/status.txt"
    echo "Created: $(date '+%Y-%m-%d %H:%M:%S')" > "$action_dir/metadata.txt"
    echo "Action: $action_name" >> "$action_dir/metadata.txt"
    
    # Create initial plan
    cat > "$action_dir/plan.md" << EOF
# Action Plan: $action_name

## Task
$task_description

## Objectives
1. [Define specific objectives]

## Approach
[Describe the approach]

## Success Criteria
- [ ] Criteria 1
- [ ] Criteria 2

## Dependencies
- None identified yet
EOF
    
    # Create progress tracking
    cat > "$action_dir/progress.md" << EOF
# Progress: $action_name

## $(date '+%Y-%m-%d')
- Action created
- Task: $task_description
EOF
    
    # Update actions index
    update_actions_index "$action_name" "$task_description" "Not Started"
    
    print_success "Created new action: $action_name"
    print_info "Action directory: $action_dir"
    
    return 0
}

# Set an action as active
function set_active_action() {
    local action_name=$1
    
    # Validate action exists
    validate_action_exists "$action_name" || return 1
    
    # Check current state
    local current=$(get_current_action)
    if [ "$current" = "$action_name" ]; then
        print_info "Action '$action_name' is already active"
        return 0
    fi
    
    # Validate single active action principle
    if ! validate_single_active_action "ACTIVE"; then
        print_error "Cannot set active action due to state conflicts"
        print_info "Run './aicheck cleanup' first"
        return 1
    fi
    
    # Set as current action (handles all state updates)
    set_current_action "$action_name"
    
    # Show activation summary
    print_success "Set current action to: $action_name"
    print_info "All other actions marked as 'In Progress' or 'Not Started'"
    
    return 0
}

# Complete the current action
function complete_action() {
    local current_action=$(get_current_action)
    
    if [ "$current_action" = "None" ] || [ -z "$current_action" ]; then
        error_exit "No active action to complete" $ERR_STATE_CONFLICT
    fi
    
    local dir_name=$(to_kebab_case "$current_action")
    local action_dir=".aicheck/actions/$dir_name"
    
    print_section "📋 Completing action: $current_action"
    
    # Run completion checks
    if ! validate_action_completeness; then
        print_warning "Action has compliance issues. Fix them before completing."
        return 1
    fi
    
    # Run smart completion checks
    if ! run_smart_completion_checks "$current_action" "$dir_name"; then
        print_error "Action failed completion checks"
        return 1
    fi
    
    # Update status
    update_action_status "$current_action" "Completed"
    
    # Clear current action
    clear_current_action
    
    # Add completion note to progress
    echo -e "\n## $(date '+%Y-%m-%d %H:%M:%S')" >> "$action_dir/progress.md"
    echo "- Action completed successfully" >> "$action_dir/progress.md"
    
    print_success "Action '$current_action' completed successfully!"
    print_info "Remember to commit your changes if needed"
    
    return 0
}

# Update actions index
function update_actions_index() {
    local action_name=$1
    local description=$2
    local status=$3
    local created=$(date '+%Y-%m-%d')
    local context_size=$(find . -name "*.ai" -o -name "*.claude" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
    
    # Create index if it doesn't exist
    if [ ! -f ".aicheck/actions_index.md" ]; then
        cat > ".aicheck/actions_index.md" << EOF
# AICheck Actions Index

| Action | Description | Status | Created | Context Size |
|--------|-------------|--------|---------|--------------|
EOF
    fi
    
    # Add new action to index
    echo "| $action_name | $description | $status | $created | $context_size lines |" >> ".aicheck/actions_index.md"
}

# List all actions
function list_actions() {
    if [ ! -f ".aicheck/actions_index.md" ]; then
        print_info "No actions found"
        return 0
    fi
    
    print_section "📋 AICheck Actions"
    
    # Show current action
    local current=$(get_current_action)
    if [ "$current" != "None" ]; then
        print_header "Active Action: $(print_action "$current")"
    fi
    
    # Display actions table
    cat ".aicheck/actions_index.md"
}

# Get action details
function get_action_details() {
    local action_name=$1
    local dir_name=$(to_kebab_case "$action_name")
    local action_dir=".aicheck/actions/$dir_name"
    
    if [ ! -d "$action_dir" ]; then
        error_exit "Action '$action_name' not found" $ERR_FILE_NOT_FOUND
    fi
    
    print_section "📋 Action: $action_name"
    
    # Show status
    local status=$(cat "$action_dir/status.txt" 2>/dev/null || echo "Unknown")
    echo -e "Status: $(print_status "$status")"
    
    # Show task
    if [ -f "$action_dir/task.txt" ]; then
        echo -e "\nTask:"
        cat "$action_dir/task.txt"
    fi
    
    # Show plan
    if [ -f "$action_dir/plan.md" ]; then
        echo -e "\nPlan:"
        head -20 "$action_dir/plan.md"
    fi
    
    # Show recent progress
    if [ -f "$action_dir/progress.md" ]; then
        echo -e "\nRecent Progress:"
        tail -10 "$action_dir/progress.md"
    fi
}

# Archive completed actions
function archive_completed_actions() {
    local archived_count=0
    local archive_dir=".aicheck/archived_actions"
    
    # Create archive directory if needed
    mkdir -p "$archive_dir"
    
    # Find completed actions
    for action_dir in .aicheck/actions/*; do
        if [ -d "$action_dir" ] && [ -f "$action_dir/status.txt" ]; then
            local status=$(cat "$action_dir/status.txt")
            if [ "$status" = "Completed" ]; then
                local action_name=$(basename "$action_dir")
                local archive_name="${action_name}_$(date '+%Y%m%d_%H%M%S')"
                
                # Move to archive
                mv "$action_dir" "$archive_dir/$archive_name"
                ((archived_count++))
                
                print_info "Archived: $action_name"
            fi
        fi
    done
    
    if [ $archived_count -gt 0 ]; then
        print_success "Archived $archived_count completed actions"
    else
        print_info "No completed actions to archive"
    fi
}