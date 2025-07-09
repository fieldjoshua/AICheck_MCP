#!/bin/bash
# AICheck Core Utilities
# Common utility functions

# Show version information
function show_version() {
    print_header "AICheck MCP"
    echo -e "Version: ${GREEN}${AICHECK_VERSION}${NC}"
    echo -e "Repository: ${GITHUB_REPO}"
    echo ""
    print_header "📋 Your Commands:"
    print_command "./aicheck status           # Show detailed status"
    print_command "./aicheck focus            # Check for scope creep"
    print_command "./aicheck stuck            # Get unstuck when confused"
    print_command "./aicheck deploy           # Pre-deployment validation"
    print_command "./aicheck auto-iterate     # Automated test-fix-test cycles"
    print_command "./aicheck new              # Create a new action"
    print_command "./aicheck ACTIVE           # Set the ACTIVE action"
    print_command "./aicheck complete         # Complete the ACTIVE action"
    print_command "./aicheck cleanup          # Optimize and fix compliance"
    print_command "./aicheck usage            # See AI usage and costs"
    echo ""
    print_header "🤖 AI Editor Integration:"
    print_command "./aicheck mcp edit         # Setup MCP headers for AI coding"
    print_command "./aicheck edit claude <file>  # Launch Claude with MCP"
    print_command "./aicheck edit cursor <file>  # Launch Cursor with MCP"
    echo ""
    print_warning "💡 Only one action can be ACTIVE at a time."
}

# Show help
function show_help() {
    show_version
    echo ""
    print_section "Additional Help:"
    print_info "For detailed help on any command, use:"
    print_command "./aicheck <command> --help"
    echo ""
    print_info "Examples:"
    print_command "./aicheck new MyFeature 'Add user authentication'"
    print_command "./aicheck ACTIVE MyFeature"
    print_command "./aicheck auto-iterate --execute 5"
    echo ""
    print_info "Documentation: https://github.com/$GITHUB_REPO"
}

# Utility: Create directory if not exists
function ensure_dir() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# Utility: Safe file write with backup
function safe_write() {
    local file=$1
    local content=$2
    
    if [ -f "$file" ]; then
        cp "$file" "$file.bak"
    fi
    
    echo "$content" > "$file"
}

# Utility: Get file age in days
function get_file_age_days() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        echo "999999"  # Very old if doesn't exist
        return
    fi
    
    local mod_time=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null || echo "0")
    local current_time=$(date +%s)
    local age_seconds=$((current_time - mod_time))
    local age_days=$((age_seconds / 86400))
    
    echo "$age_days"
}

# Utility: Format file size
function format_file_size() {
    local size=$1
    
    if [ "$size" -lt 1024 ]; then
        echo "${size}B"
    elif [ "$size" -lt 1048576 ]; then
        echo "$((size / 1024))KB"
    elif [ "$size" -lt 1073741824 ]; then
        echo "$((size / 1048576))MB"
    else
        echo "$((size / 1073741824))GB"
    fi
}

# Utility: Get relative time string
function get_relative_time() {
    local timestamp=$1
    local current=$(date +%s)
    local diff=$((current - timestamp))
    
    if [ $diff -lt 60 ]; then
        echo "$diff seconds ago"
    elif [ $diff -lt 3600 ]; then
        echo "$((diff / 60)) minutes ago"
    elif [ $diff -lt 86400 ]; then
        echo "$((diff / 3600)) hours ago"
    elif [ $diff -lt 604800 ]; then
        echo "$((diff / 86400)) days ago"
    else
        echo "$((diff / 604800)) weeks ago"
    fi
}

# Utility: Generate unique ID
function generate_id() {
    local prefix=${1:-"id"}
    echo "${prefix}_$(date +%Y%m%d_%H%M%S)_$$"
}

# Utility: Check if running in CI environment
function is_ci_environment() {
    [ -n "${CI:-}" ] || [ -n "${CONTINUOUS_INTEGRATION:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]
}

# Utility: Get terminal width
function get_terminal_width() {
    tput cols 2>/dev/null || echo 80
}

# Utility: Truncate string to width
function truncate_string() {
    local str=$1
    local max_width=${2:-80}
    
    if [ ${#str} -le $max_width ]; then
        echo "$str"
    else
        echo "${str:0:$((max_width-3))}..."
    fi
}

# Utility: Repeat character
function repeat_char() {
    local char=$1
    local count=$2
    printf "%${count}s" | tr ' ' "$char"
}

# Utility: Center text
function center_text() {
    local text=$1
    local width=$(get_terminal_width)
    local text_width=${#text}
    local padding=$(( (width - text_width) / 2 ))
    
    printf "%${padding}s%s\n" "" "$text"
}

# Utility: Draw separator line
function draw_separator() {
    local char=${1:-"-"}
    local width=$(get_terminal_width)
    repeat_char "$char" "$width"
    echo
}

# Utility: Check for updates
function check_for_updates() {
    print_info "Checking for updates..."
    
    # Get remote version
    local remote_version=$(curl -s "${GITHUB_RAW_BASE}/aicheck" | grep "AICHECK_VERSION=" | head -1 | cut -d'"' -f2)
    
    if [ -z "$remote_version" ]; then
        print_warning "Could not check remote version"
        return 1
    fi
    
    echo -e "Local version:  ${GREEN}${AICHECK_VERSION}${NC}"
    echo -e "Remote version: ${GREEN}${remote_version}${NC}"
    
    if [ "$AICHECK_VERSION" != "$remote_version" ]; then
        print_warning "Update available: $remote_version"
        print_info "To update: curl -sSL https://raw.githubusercontent.com/$GITHUB_REPO/main/install.sh | bash"
        return 0
    else
        print_success "AICheck is up to date"
        return 1
    fi
}