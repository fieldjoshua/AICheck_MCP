#!/bin/bash
# AICheck MCP Integration Functions
# Handles MCP headers and editor integration

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/errors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/state.sh"

# Generate MCP header for a file
function generate_mcp_header() {
    local file_path=$1
    local action_name=${2:-$(get_current_action)}
    local task_desc=${3:-""}
    
    if [ "$action_name" = "None" ] || [ -z "$action_name" ]; then
        error_exit "No active action. Set one with './aicheck ACTIVE <action>'" $ERR_STATE_CONFLICT
    fi
    
    # Get task description if not provided
    if [ -z "$task_desc" ]; then
        local dir_name=$(to_kebab_case "$action_name")
        if [ -f ".aicheck/actions/$dir_name/task.txt" ]; then
            task_desc=$(cat ".aicheck/actions/$dir_name/task.txt")
        else
            task_desc="Working on $action_name"
        fi
    fi
    
    # Generate header based on file type
    local extension="${file_path##*.}"
    local comment_style=""
    
    case "$extension" in
        py|sh|bash|rb|pl|r|jl|nim)
            comment_style="#"
            ;;
        js|ts|jsx|tsx|java|c|cpp|cc|cxx|h|hpp|cs|go|rs|kt|swift|scala|dart)
            comment_style="//"
            ;;
        html|xml|vue|svelte)
            echo "<!-- MCP: AICheck_Scoper -->"
            echo "<!-- Action: $action_name -->"
            echo "<!-- DateTime: $(date '+%Y-%m-%d %H:%M:%S %Z') -->"
            echo "<!-- Task: $task_desc -->"
            echo "<!-- File: $file_path -->"
            echo "<!-- You may only modify this file. Stay within the current action scope. -->"
            echo "<!-- Follow the approved plan and avoid scope creep. -->"
            return 0
            ;;
        css|scss|sass|less)
            echo "/* MCP: AICheck_Scoper */"
            echo "/* Action: $action_name */"
            echo "/* DateTime: $(date '+%Y-%m-%d %H:%M:%S %Z') */"
            echo "/* Task: $task_desc */"
            echo "/* File: $file_path */"
            echo "/* You may only modify this file. Stay within the current action scope. */"
            echo "/* Follow the approved plan and avoid scope creep. */"
            return 0
            ;;
        sql)
            comment_style="--"
            ;;
        *)
            # Default to hash comments
            comment_style="#"
            ;;
    esac
    
    # Generate header with appropriate comment style
    echo "${comment_style} MCP: AICheck_Scoper"
    echo "${comment_style} Action: $action_name"
    echo "${comment_style} DateTime: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "${comment_style} Task: $task_desc"
    echo "${comment_style} File: $file_path"
    echo "${comment_style} You may only modify this file. Stay within the current action scope."
    echo "${comment_style} Follow the approved plan and avoid scope creep."
}

# Add MCP header to a file
function add_mcp_header() {
    local file_path=$1
    
    if [ ! -f "$file_path" ]; then
        error_exit "File not found: $file_path" $ERR_FILE_NOT_FOUND
    fi
    
    # Check if file already has MCP header
    if grep -q "MCP: AICheck_Scoper" "$file_path" 2>/dev/null; then
        print_warning "File already has MCP header: $file_path"
        return 0
    fi
    
    # Create temp file with header
    local temp_file=$(mktemp)
    generate_mcp_header "$file_path" > "$temp_file"
    echo "" >> "$temp_file"
    cat "$file_path" >> "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$file_path"
    
    print_success "Added MCP header to: $file_path"
}

# Setup MCP for editing
function setup_mcp_edit() {
    local current_action=$(get_current_action)
    
    if [ "$current_action" = "None" ]; then
        error_exit "No active action. Use './aicheck new <name>' to create one." $ERR_STATE_CONFLICT
    fi
    
    print_section "🤖 Setting up MCP headers for: $current_action"
    
    local dir_name=$(to_kebab_case "$current_action")
    local action_dir=".aicheck/actions/$dir_name"
    
    # Get list of files to add headers to
    local files_to_edit=()
    
    # Check for files specified in plan
    if [ -f "$action_dir/files_to_edit.txt" ]; then
        while IFS= read -r file; do
            [ -n "$file" ] && files_to_edit+=("$file")
        done < "$action_dir/files_to_edit.txt"
    fi
    
    # If no files specified, ask user
    if [ ${#files_to_edit[@]} -eq 0 ]; then
        print_info "No files specified in action plan."
        print_info "Which files will you be editing? (one per line, empty line to finish)"
        
        while true; do
            read -r file
            [ -z "$file" ] && break
            [ -f "$file" ] && files_to_edit+=("$file") || print_warning "File not found: $file"
        done
        
        # Save for future reference
        printf '%s\n' "${files_to_edit[@]}" > "$action_dir/files_to_edit.txt"
    fi
    
    # Add headers to files
    local headers_added=0
    for file in "${files_to_edit[@]}"; do
        if add_mcp_header "$file"; then
            ((headers_added++))
        fi
    done
    
    if [ $headers_added -gt 0 ]; then
        print_success "Added MCP headers to $headers_added files"
        print_info "Files are now ready for AI-assisted editing"
    else
        print_info "No new headers added"
    fi
}

# Launch editor with MCP context
function launch_editor_with_mcp() {
    local editor=$1
    local file_path=$2
    
    # Validate editor
    case "$editor" in
        claude|cursor|vscode|code)
            ;;
        *)
            error_exit "Unsupported editor: $editor. Use 'claude' or 'cursor'" $ERR_INVALID_INPUT
            ;;
    esac
    
    # Ensure file exists
    if [ -n "$file_path" ] && [ ! -f "$file_path" ]; then
        error_exit "File not found: $file_path" $ERR_FILE_NOT_FOUND
    fi
    
    # Add MCP header if needed
    if [ -n "$file_path" ]; then
        add_mcp_header "$file_path"
    fi
    
    # Launch editor
    case "$editor" in
        claude)
            print_info "Opening Claude with MCP context..."
            if [ -n "$file_path" ]; then
                print_info "Copy the MCP header and file contents to Claude"
                print_info "File: $file_path"
            else
                print_info "Copy relevant files with MCP headers to Claude"
            fi
            ;;
        cursor|vscode|code)
            if command -v cursor >/dev/null 2>&1; then
                print_info "Opening Cursor with MCP context..."
                if [ -n "$file_path" ]; then
                    cursor "$file_path"
                else
                    cursor .
                fi
            elif command -v code >/dev/null 2>&1; then
                print_info "Opening VS Code with MCP context..."
                if [ -n "$file_path" ]; then
                    code "$file_path"
                else
                    code .
                fi
            else
                error_exit "Neither Cursor nor VS Code found in PATH" $ERR_DEPENDENCY_MISSING
            fi
            ;;
    esac
}

# Get MCP action info for current context
function get_mcp_action_info() {
    local current_action=$(get_current_action)
    
    if [ "$current_action" = "None" ]; then
        echo "No active action"
        return 1
    fi
    
    local dir_name=$(to_kebab_case "$current_action")
    local action_dir=".aicheck/actions/$dir_name"
    
    echo "Action: $current_action"
    
    if [ -f "$action_dir/task.txt" ]; then
        echo "Task: $(cat "$action_dir/task.txt")"
    fi
    
    if [ -f "$action_dir/status.txt" ]; then
        echo "Status: $(cat "$action_dir/status.txt")"
    fi
    
    if [ -f "$action_dir/files_to_edit.txt" ]; then
        echo "Files in scope:"
        cat "$action_dir/files_to_edit.txt" | sed 's/^/  - /'
    fi
}

# Update MCP headers in files
function update_mcp_headers() {
    local current_action=$(get_current_action)
    
    if [ "$current_action" = "None" ]; then
        print_info "No active action"
        return 0
    fi
    
    print_section "🔄 Updating MCP headers for: $current_action"
    
    # Find files with MCP headers
    local files_updated=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Create temp file with updated header
            local temp_file=$(mktemp)
            
            # Generate new header
            generate_mcp_header "$file" > "$temp_file"
            echo "" >> "$temp_file"
            
            # Copy content after old header
            sed '/^.*MCP: AICheck_Scoper/,/^.*Follow the approved plan/d' "$file" >> "$temp_file"
            
            # Replace file
            mv "$temp_file" "$file"
            ((files_updated++))
        fi
    done < <(grep -l "MCP: AICheck_Scoper" * 2>/dev/null || true)
    
    if [ $files_updated -gt 0 ]; then
        print_success "Updated MCP headers in $files_updated files"
    else
        print_info "No MCP headers found to update"
    fi
}

# Remove MCP headers from files
function remove_mcp_headers() {
    print_section "🧹 Removing MCP headers"
    
    local files_cleaned=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            # Create temp file without header
            local temp_file=$(mktemp)
            
            # Remove header lines
            sed '/^.*MCP: AICheck_Scoper/,/^.*Follow the approved plan/d' "$file" > "$temp_file"
            
            # Remove extra blank lines at start
            sed -i '1{/^$/d;}' "$temp_file"
            
            # Replace file
            mv "$temp_file" "$file"
            ((files_cleaned++))
            
            print_info "Removed header from: $file"
        fi
    done < <(grep -l "MCP: AICheck_Scoper" * 2>/dev/null || true)
    
    if [ $files_cleaned -gt 0 ]; then
        print_success "Removed MCP headers from $files_cleaned files"
    else
        print_info "No MCP headers found to remove"
    fi
}