#!/bin/bash
# AICheck Command Dispatcher
# Routes commands to appropriate functions

# Load all modules
function load_all_modules() {
    local lib_dir="$(dirname "${BASH_SOURCE[0]}")/.."
    
    # Core modules
    source "$lib_dir/ui/colors.sh"
    source "$lib_dir/ui/output.sh"
    source "$lib_dir/core/errors.sh"
    source "$lib_dir/core/state.sh"
    source "$lib_dir/core/utilities.sh"
    
    # Validation
    source "$lib_dir/validation/input.sh"
    source "$lib_dir/validation/actions.sh"
    
    # Features
    source "$lib_dir/detection/environment.sh"
    source "$lib_dir/actions/management.sh"
    source "$lib_dir/mcp/integration.sh"
    source "$lib_dir/git/operations.sh"
    source "$lib_dir/automation/auto_iterate.sh"
    source "$lib_dir/maintenance/cleanup.sh"
    source "$lib_dir/deployment/validation.sh"
}

# Main dispatcher
function dispatch_command() {
    local cmd=$1
    shift
    local args=("$@")
    
    # Validate command
    if ! validate_command "$cmd"; then
        print_error "Unknown command: $cmd"
        show_usage
        return 1
    fi
    
    # Check AICheck initialization for most commands
    case "$cmd" in
        "version"|"help"|"init")
            # These don't need initialization
            ;;
        *)
            require_aicheck_init
            ;;
    esac
    
    # Dispatch to appropriate function
    case "$cmd" in
        "version")
            show_version
            ;;
        "help")
            show_help
            ;;
        "init")
            initialize_aicheck
            ;;
        "status")
            show_status
            ;;
        "new")
            if [ ${#args[@]} -lt 1 ]; then
                print_error "Usage: ./aicheck new <action-name> [description]"
                return 1
            fi
            create_action "${args[0]}" "${args[1]:-}"
            ;;
        "ACTIVE"|"active")
            if [ ${#args[@]} -lt 1 ]; then
                print_error "Usage: ./aicheck ACTIVE <action-name>"
                return 1
            fi
            set_active_action "${args[0]}"
            ;;
        "complete")
            complete_action
            ;;
        "focus")
            check_focus
            ;;
        "stuck")
            get_unstuck
            ;;
        "deploy")
            validate_deployment
            ;;
        "deploy-check")
            quick_deployment_check
            ;;
        "auto-iterate")
            auto_iterate "${args[@]}"
            ;;
        "cleanup")
            cleanup_and_optimize
            ;;
        "usage")
            show_usage_stats
            ;;
        "mcp")
            handle_mcp_command "${args[@]}"
            ;;
        "edit")
            if [ ${#args[@]} -lt 1 ]; then
                print_error "Usage: ./aicheck edit <editor> [file]"
                return 1
            fi
            launch_editor_with_mcp "${args[0]}" "${args[1]:-}"
            ;;
        "action")
            handle_action_command "${args[@]}"
            ;;
        "dependency"|"deps"|"d")
            check_dependencies
            ;;
        *)
            print_error "Command not implemented: $cmd"
            return 1
            ;;
    esac
}

# Show usage
function show_usage() {
    print_header "AICheck Usage"
    echo ""
    print_section "Core Commands:"
    print_command "./aicheck status          # Show current status"
    print_command "./aicheck new <name>     # Create new action"
    print_command "./aicheck ACTIVE <name>  # Set active action"
    print_command "./aicheck complete       # Complete current action"
    echo ""
    print_section "Workflow Commands:"
    print_command "./aicheck focus          # Check for scope creep"
    print_command "./aicheck stuck          # Get unstuck"
    print_command "./aicheck deploy         # Pre-deployment validation"
    print_command "./aicheck auto-iterate   # Automated iterations"
    echo ""
    print_section "Maintenance Commands:"
    print_command "./aicheck cleanup        # Clean and optimize"
    print_command "./aicheck usage          # Show usage statistics"
    echo ""
    print_section "Integration Commands:"
    print_command "./aicheck mcp edit       # Setup MCP headers"
    print_command "./aicheck edit <editor>  # Launch with MCP"
}

# Handle MCP subcommands
function handle_mcp_command() {
    local subcmd=$1
    shift
    
    case "$subcmd" in
        "edit")
            setup_mcp_edit
            ;;
        "update")
            update_mcp_headers
            ;;
        "remove")
            remove_mcp_headers
            ;;
        "info")
            get_mcp_action_info
            ;;
        *)
            print_error "Unknown MCP subcommand: $subcmd"
            print_info "Available: edit, update, remove, info"
            return 1
            ;;
    esac
}

# Handle action subcommands
function handle_action_command() {
    local subcmd=$1
    shift
    
    case "$subcmd" in
        "list")
            list_actions
            ;;
        "show")
            if [ $# -lt 1 ]; then
                print_error "Usage: ./aicheck action show <name>"
                return 1
            fi
            get_action_details "$1"
            ;;
        "archive")
            archive_completed_actions
            ;;
        *)
            print_error "Unknown action subcommand: $subcmd"
            print_info "Available: list, show, archive"
            return 1
            ;;
    esac
}

# Initialize AICheck
function initialize_aicheck() {
    if [ -d ".aicheck" ]; then
        print_warning "AICheck already initialized"
        if confirm "Reinitialize?"; then
            rm -rf .aicheck
        else
            return 0
        fi
    fi
    
    print_section "🚀 Initializing AICheck"
    
    # Create directory structure
    mkdir -p .aicheck/{actions,archive,logs}
    
    # Create initial files
    echo "None" > .aicheck/current_action
    echo "# AICheck Actions Index

| Action | Description | Status | Created | Context Size |
|--------|-------------|--------|---------|--------------|" > .aicheck/actions_index.md
    
    # Create config
    cat > .aicheck/config << EOF
# AICheck Configuration
version=$AICHECK_VERSION
initialized=$(date +%Y-%m-%d)
mode=smart
EOF
    
    print_success "AICheck initialized successfully!"
    print_info "Create your first action with: ./aicheck new <name>"
}

# Show current status
function show_status() {
    print_section "AICheck Status"
    echo "-------------------"
    
    # Current action
    local current=$(get_current_action)
    echo -e "Current Action: $([ "$current" != "None" ] && print_action "$current" || echo "None")"
    echo ""
    
    # Active actions
    echo "Active Actions:"
    if [ -f ".aicheck/actions_index.md" ]; then
        local active_count=$(grep -c "| ActiveAction |" .aicheck/actions_index.md 2>/dev/null || echo "0")
        if [ "$active_count" -gt 0 ]; then
            grep "| ActiveAction |" .aicheck/actions_index.md | while read -r line; do
                local action=$(echo "$line" | cut -d'|' -f2 | xargs)
                echo "  - $action"
            done
        else
            echo "  None"
        fi
    else
        echo "  No action index found"
    fi
    echo ""
    
    # Context health
    echo "Context Health:"
    local pollution_score=$(analyze_context_pollution 2>/dev/null | tail -1 || echo "0")
    if [ "$pollution_score" -lt 30 ]; then
        echo -e "  Pollution score: ${GREEN}$pollution_score/100 (Clean)${NC}"
    elif [ "$pollution_score" -lt 70 ]; then
        echo -e "  Pollution score: ${YELLOW}$pollution_score/100 (Moderate)${NC}"
    else
        echo -e "  Pollution score: ${RED}$pollution_score/100 (High)${NC}"
    fi
    echo ""
    
    # Git status
    if is_git_repo; then
        echo "Git Status:"
        get_git_status_summary | sed 's/^/  /'
    fi
}

# Check focus
function check_focus() {
    local current=$(get_current_action)
    
    if [ "$current" = "None" ]; then
        print_info "No active action - you're free to explore!"
        return 0
    fi
    
    print_section "🎯 Focus Check for: $current"
    
    # Check for scope creep
    local modified_files=($(get_modified_files))
    local out_of_scope=0
    
    # Check against allowed files
    local dir_name=$(to_kebab_case "$current")
    if [ -f ".aicheck/actions/$dir_name/files_to_edit.txt" ]; then
        print_info "Checking modified files against scope..."
        
        for file in "${modified_files[@]}"; do
            if ! grep -q "^$file$" ".aicheck/actions/$dir_name/files_to_edit.txt"; then
                print_warning "Out of scope: $file"
                ((out_of_scope++))
            fi
        done
    fi
    
    if [ $out_of_scope -eq 0 ]; then
        print_success "✅ All changes within scope!"
    else
        print_warning "⚠️  $out_of_scope files modified outside of scope"
        print_info "Consider adding them to scope or reverting changes"
    fi
}

# Get unstuck
function get_unstuck() {
    print_section "🤔 Getting Unstuck"
    
    local current=$(get_current_action)
    if [ "$current" = "None" ]; then
        print_info "No active action. Start with: ./aicheck new <name>"
        return 0
    fi
    
    print_info "Current action: $current"
    echo ""
    
    # Provide context-aware suggestions
    print_header "Try these steps:"
    echo "1. Review your action plan:"
    print_command "  cat .aicheck/actions/$(to_kebab_case "$current")/plan.md"
    echo ""
    echo "2. Check recent progress:"
    print_command "  tail .aicheck/actions/$(to_kebab_case "$current")/progress.md"
    echo ""
    echo "3. Run tests to see what's failing:"
    local test_cmd=$(get_test_command | head -1)
    if [ "$test_cmd" != "none" ]; then
        print_command "  $test_cmd"
    fi
    echo ""
    echo "4. Use auto-iterate for test-driven fixes:"
    print_command "  ./aicheck auto-iterate"
    echo ""
    echo "5. If blocked, break down the task:"
    print_info "  - Identify the smallest next step"
    print_info "  - Focus on one file at a time"
    print_info "  - Write a failing test first"
}

# Show usage statistics
function show_usage_stats() {
    print_section "📊 AICheck Usage Statistics"
    
    if [ ! -d ".aicheck" ]; then
        print_error "AICheck not initialized"
        return 1
    fi
    
    # Action statistics
    local total_actions=$(get_all_actions | wc -l | tr -d ' ')
    local completed=$(grep -c "| Completed |" .aicheck/actions_index.md 2>/dev/null || echo "0")
    local active=$(count_active_actions)
    
    echo "Actions:"
    echo "  Total: $total_actions"
    echo "  Active: $active"
    echo "  Completed: $completed"
    echo "  In Progress: $((total_actions - completed - active))"
    echo ""
    
    # Session statistics
    local iterate_sessions=$(ls .aicheck/auto-iterate-session-*.log 2>/dev/null | wc -l | tr -d ' ')
    echo "Sessions:"
    echo "  Auto-iterate: $iterate_sessions"
    echo ""
    
    # Storage usage
    local storage=$(du -sh .aicheck 2>/dev/null | awk '{print $1}' || echo "N/A")
    echo "Storage:"
    echo "  Total size: $storage"
    echo "  Files: $(find .aicheck -type f 2>/dev/null | wc -l | tr -d ' ')"
}

# Check dependencies
function check_dependencies() {
    print_section "🔍 Checking Dependencies"
    
    # Required commands
    local required=("git" "sed" "grep" "find" "curl")
    local missing=0
    
    print_header "Required commands:"
    for cmd in "${required[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            print_success "  ✓ $cmd"
        else
            print_error "  ✗ $cmd (missing)"
            ((missing++))
        fi
    done
    
    # Optional commands
    local optional=("jq" "gzip" "npm" "poetry" "make")
    
    echo ""
    print_header "Optional commands:"
    for cmd in "${optional[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            print_success "  ✓ $cmd"
        else
            print_info "  - $cmd (not installed)"
        fi
    done
    
    # Project-specific dependencies
    echo ""
    print_header "Project dependencies:"
    local env_info=($(detect_project_environment))
    if [ ${#env_info[@]} -gt 0 ]; then
        for feature in "${env_info[@]}"; do
            print_info "  • $feature"
        done
    else
        print_info "  No specific project type detected"
    fi
    
    if [ $missing -gt 0 ]; then
        echo ""
        print_error "Missing $missing required dependencies"
        return 1
    else
        echo ""
        print_success "All required dependencies installed"
        return 0
    fi
}