#!/bin/bash
# AICheck Auto-Iterate Functionality
# Automated test-fix-test cycles with AI assistance

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/errors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/state.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../detection/environment.sh"

# Configuration defaults
AUTO_ITERATE_MAX_ITERATIONS=10
AUTO_ITERATE_TIMEOUT=300
AUTO_ITERATE_AUTO_CONTINUE=true
AUTO_ITERATE_HUMAN_TIMEOUT=30
AUTO_ITERATE_TEST_TIMEOUT=120
AUTO_ITERATE_ENABLE_RECOVERY=true

# Load config if exists
function load_auto_iterate_config() {
    if [ -f ".aicheck/auto-iterate.conf" ]; then
        source .aicheck/auto-iterate.conf
    fi
}

# Main auto-iterate function
function auto_iterate() {
    load_auto_iterate_config
    
    # Parse arguments
    case "$1" in
        "--help"|"-h")
            show_auto_iterate_help
            return 0
            ;;
        "--approve")
            approve_auto_iterate_goals
            return $?
            ;;
        "--execute")
            shift
            execute_auto_iterate "$@"
            return $?
            ;;
        "--summary")
            generate_auto_iterate_summary
            return $?
            ;;
        "--recover")
            recover_auto_iterate_session "$2"
            return $?
            ;;
        "--clean-recovery")
            clean_recovery_files
            return 0
            ;;
        *)
            # Check for interrupted sessions
            if check_auto_iterate_recovery; then
                if ! confirm "Proceed with new session anyway?"; then
                    print_warning "Use recovery options above or --clean-recovery to clear"
                    return 1
                fi
            fi
            # Default: Goal definition phase
            define_auto_iterate_goals
            return $?
            ;;
    esac
}

# Show help
function show_auto_iterate_help() {
    print_header "Auto-Iterate Mode - Goal-Driven Test-Fix-Test Cycles"
    echo ""
    print_section "Usage:"
    print_command "./aicheck auto-iterate                    # Define goals (first step)"
    print_command "./aicheck auto-iterate --approve          # Approve defined goals"
    print_command "./aicheck auto-iterate --execute [args]   # Execute approved iteration"
    echo ""
    print_section "Execution Options:"
    print_command "./aicheck auto-iterate --execute [max_iterations] [timeout]"
    echo ""
    print_section "Examples:"
    print_command "./aicheck auto-iterate                    # Step 1: Define goals"
    print_command "./aicheck auto-iterate --approve          # Step 2: Human approval"
    print_command "./aicheck auto-iterate --execute          # Step 3: Execute"
    print_command "./aicheck auto-iterate --execute 5        # Execute with max 5 iterations"
    echo ""
    print_section "Workflow:"
    echo "  1. AI editor analyzes failures and proposes goals"
    echo "  2. Human reviews and approves goals"
    echo "  3. System iterates toward approved goals"
    echo "  4. Human approves any changes before git commit"
}

# Define auto-iterate goals
function define_auto_iterate_goals() {
    local current_action=$(get_current_action)
    
    if [ "$current_action" = "None" ]; then
        error_exit "No active action. Create one with './aicheck new <name>'" $ERR_STATE_CONFLICT
    fi
    
    print_section "🎯 Auto-Iterate Goal Definition"
    print_info "Current action: $current_action"
    
    # Create goals file
    local goals_file=".aicheck/auto-iterate-goals.md"
    local template_file="templates/claude/auto-iterate-action.md"
    
    # Check for template
    if [ ! -f "$template_file" ]; then
        print_warning "Template not found: $template_file"
        print_info "Creating basic goals file..."
        
        cat > "$goals_file" << EOF
# Auto-Iterate Goals for $current_action

## Status: PENDING_APPROVAL

## Objective
[AI: Define the specific, measurable objective for this auto-iterate session]

## Success Criteria
- [ ] [AI: Define specific success criterion 1]
- [ ] [AI: Define specific success criterion 2]
- [ ] [AI: Define specific success criterion 3]

## Approach
[AI: Describe the iterative approach to achieve the objective]

## Constraints
- Maximum iterations: $AUTO_ITERATE_MAX_ITERATIONS
- Timeout per iteration: ${AUTO_ITERATE_TIMEOUT}s
- Auto-continue: $AUTO_ITERATE_AUTO_CONTINUE

## Notes
[AI: Add any relevant notes or considerations]
EOF
    else
        # Copy template
        cp "$template_file" "$goals_file"
    fi
    
    print_success "Goals file created: $goals_file"
    print_info "AI editor should now analyze and fill in the goals"
    echo ""
    print_warning "Next steps:"
    echo "1. AI editor fills in the goals in: $goals_file"
    echo "2. Review the goals carefully"
    echo "3. Run: ./aicheck auto-iterate --approve"
    echo "4. Then: ./aicheck auto-iterate --execute"
}

# Approve goals
function approve_auto_iterate_goals() {
    local goals_file=".aicheck/auto-iterate-goals.md"
    
    if [ ! -f "$goals_file" ]; then
        error_exit "No goals file found. Run './aicheck auto-iterate' first" $ERR_FILE_NOT_FOUND
    fi
    
    # Check if already approved
    if grep -q "## Status: APPROVED" "$goals_file"; then
        print_info "Goals already approved"
        return 0
    fi
    
    print_section "📋 Review Auto-Iterate Goals"
    echo ""
    cat "$goals_file"
    echo ""
    
    if confirm "Approve these goals?"; then
        # Update status
        sed -i.bak 's/## Status: PENDING_APPROVAL/## Status: APPROVED/' "$goals_file"
        echo "## Approved by: Human" >> "$goals_file"
        echo "## Approved at: $(date '+%Y-%m-%d %H:%M:%S')" >> "$goals_file"
        
        print_success "Goals approved!"
        print_info "You can now run: ./aicheck auto-iterate --execute"
    else
        print_warning "Goals not approved"
        print_info "Edit $goals_file and try again"
        return 1
    fi
}

# Execute auto-iterate
function execute_auto_iterate() {
    local max_iterations=${1:-$AUTO_ITERATE_MAX_ITERATIONS}
    local timeout=${2:-$AUTO_ITERATE_TIMEOUT}
    
    # Check goals are approved
    local goals_file=".aicheck/auto-iterate-goals.md"
    if [ ! -f "$goals_file" ] || ! grep -q "## Status: APPROVED" "$goals_file"; then
        error_exit "Goals not approved. Run './aicheck auto-iterate --approve' first" $ERR_STATE_CONFLICT
    fi
    
    # Create session
    local session_id=$(date +%Y%m%d_%H%M%S)
    local log_file=".aicheck/auto-iterate-session-$session_id.log"
    local state_file=".aicheck/auto-iterate-state-$session_id.tmp"
    local changes_file=".aicheck/auto-iterate-changes-$session_id.md"
    
    # Setup signal handlers for recovery
    setup_auto_iterate_signal_handlers "$session_id" "$log_file" "$state_file"
    
    print_section "🚀 Starting Auto-Iterate Session: $session_id"
    echo "Max iterations: $max_iterations"
    echo "Timeout per iteration: ${timeout}s"
    echo "Log file: $log_file"
    echo ""
    
    # Log session start
    {
        echo "AUTO-ITERATE SESSION: $session_id"
        echo "Started: $(date)"
        echo "Goals file: $goals_file"
        echo "Max iterations: $max_iterations"
        echo "Timeout: $timeout"
        echo "---"
        cat "$goals_file"
        echo "---"
    } > "$log_file"
    
    # Run iterations
    local iteration=0
    local continue_iterating=true
    
    while [ $iteration -lt $max_iterations ] && [ "$continue_iterating" = "true" ]; do
        ((iteration++))
        print_header "Iteration $iteration of $max_iterations"
        
        # Run tests
        print_info "Running tests..."
        local test_result=$(run_project_tests)
        echo "ITERATION $iteration: Test result: $test_result" >> "$log_file"
        
        if [ "$test_result" = "success" ]; then
            print_success "All tests passing!"
            echo "SUCCESS: All tests passing at iteration $iteration" >> "$log_file"
            continue_iterating=false
            break
        fi
        
        # AI analyzes and fixes
        print_info "AI analyzing failures and applying fixes..."
        echo "ITERATION $iteration: AI analysis started" >> "$log_file"
        
        # Track changes
        git diff >> "$changes_file"
        
        # Check if we should continue
        if [ "$AUTO_ITERATE_AUTO_CONTINUE" = "false" ]; then
            if ! confirm "Continue to next iteration?"; then
                continue_iterating=false
            fi
        fi
    done
    
    # Cleanup signal handlers
    trap - SIGINT SIGTERM SIGHUP
    
    # Generate summary
    generate_iteration_summary "$session_id" "$iteration" "$test_result" "$changes_file" "$log_file"
    
    # Clean up state file
    rm -f "$state_file"
}

# Run project tests
function run_project_tests() {
    local test_cmd=$(get_test_command)
    
    if [ "$test_cmd" = "none" ]; then
        print_warning "No test command found"
        echo "none"
        return 1
    fi
    
    if timeout $AUTO_ITERATE_TEST_TIMEOUT bash -c "$test_cmd" > /dev/null 2>&1; then
        echo "success"
        return 0
    else
        echo "failed"
        return 1
    fi
}

# Generate iteration summary
function generate_iteration_summary() {
    local session_id=$1
    local iterations=$2
    local final_result=$3
    local changes_file=$4
    local log_file=$5
    
    local summary_file=".aicheck/auto-iterate-summary-$session_id.md"
    
    print_section "📊 Generating Session Summary"
    
    cat > "$summary_file" << EOF
# Auto-Iterate Session Summary

## Session: $session_id
- Total iterations: $iterations
- Final result: $final_result
- Date: $(date)

## Goals Achieved
[Review goals file and mark what was achieved]

## Changes Made
\`\`\`diff
$(tail -100 "$changes_file" || echo "No changes tracked")
\`\`\`

## Session Log
\`\`\`
$(tail -50 "$log_file")
\`\`\`

## Git Commit
Ready to commit changes? Review above and approve.
EOF
    
    print_success "Summary saved to: $summary_file"
    
    # Ask about git commit
    if has_uncommitted_changes && [ "$final_result" = "success" ]; then
        echo ""
        if confirm "Create git commit for these changes?"; then
            local msg="[Auto-Iterate] Fixes from session $session_id - $iterations iterations"
            create_aicheck_commit "$msg"
        fi
    fi
}

# Signal handlers
function setup_auto_iterate_signal_handlers() {
    local session_id=$1
    local log_file=$2
    local state_file=$3
    
    # Create state file
    cat > "$state_file" << EOF
SESSION_ID=$session_id
LOG_FILE=$log_file
INTERRUPTED_AT=$(date +%s)
RECOVERY_AVAILABLE=true
EOF
    
    trap "auto_iterate_graceful_shutdown $session_id $log_file $state_file" SIGINT SIGTERM SIGHUP
}

function auto_iterate_graceful_shutdown() {
    local session_id=$1
    local log_file=$2
    local state_file=$3
    
    echo ""
    print_warning "Auto-iterate session interrupted"
    echo "INTERRUPTED: Session $session_id stopped at $(date)" >> "$log_file"
    
    echo "INTERRUPTED_AT=$(date +%s)" >> "$state_file"
    echo "RECOVERY_NEEDED=true" >> "$state_file"
    
    print_info "Recovery information saved"
    print_command "./aicheck auto-iterate --recover $session_id"
    print_command "./aicheck auto-iterate --summary"
    
    exit 130
}

# Recovery functions
function check_auto_iterate_recovery() {
    local recovery_files=$(ls .aicheck/auto-iterate-state-*.tmp 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$recovery_files" -gt 0 ]; then
        print_warning "Found $recovery_files interrupted auto-iterate session(s)"
        print_section "Available recovery options:"
        
        for state_file in .aicheck/auto-iterate-state-*.tmp; do
            if [ -f "$state_file" ]; then
                source "$state_file"
                print_command "./aicheck auto-iterate --recover $SESSION_ID  # Resume session"
            fi
        done
        
        print_command "./aicheck auto-iterate --clean-recovery  # Clear all recovery files"
        echo ""
        return 0
    fi
    
    return 1
}

function clean_recovery_files() {
    print_info "Cleaning up recovery files..."
    rm -f .aicheck/auto-iterate-state-*.tmp
    print_success "Recovery files cleaned"
}

function recover_auto_iterate_session() {
    local session_id=$1
    
    if [ -z "$session_id" ]; then
        error_exit "Session ID required for recovery" $ERR_INVALID_INPUT
    fi
    
    local state_file=".aicheck/auto-iterate-state-$session_id.tmp"
    
    if [ ! -f "$state_file" ]; then
        error_exit "Recovery state not found for session: $session_id" $ERR_FILE_NOT_FOUND
    fi
    
    print_section "Recovering auto-iterate session: $session_id"
    print_warning "Recovery functionality will resume session state"
    print_error "Recovery implementation needed in future version"
    
    # TODO: Implement full recovery logic
    return 1
}

function generate_auto_iterate_summary() {
    local recent_session=$(ls .aicheck/auto-iterate-session-*.log 2>/dev/null | sort | tail -1)
    
    if [ -z "$recent_session" ]; then
        print_error "No auto-iterate sessions found"
        return 1
    fi
    
    local session_id=$(basename "$recent_session" | sed 's/auto-iterate-session-\(.*\)\.log/\1/')
    print_info "Generating summary for session: $session_id"
    
    generate_iteration_summary "$session_id" "manual" "manual" \
        ".aicheck/auto-iterate-changes-$session_id.md" "$recent_session"
}