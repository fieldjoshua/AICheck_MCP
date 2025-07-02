#!/bin/bash
# AICheck Input Validation Functions
# Validates and sanitizes user input

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/errors.sh"

# Validate command line arguments
function validate_command() {
    local cmd=$1
    local valid_commands=(
        "status" "focus" "stuck" "deploy" "auto-iterate" 
        "new" "ACTIVE" "active" "complete" "cleanup" 
        "usage" "version" "mcp" "edit" "action" 
        "dependency" "deploy-check" "mcp-report"
        "deps" "d" "init"
    )
    
    # Check if command is in valid list
    local found=0
    for valid_cmd in "${valid_commands[@]}"; do
        if [ "$cmd" = "$valid_cmd" ]; then
            found=1
            break
        fi
    done
    
    if [ $found -eq 0 ]; then
        return 1
    fi
    
    return 0
}

# Sanitize string for use in filenames
function sanitize_filename() {
    local input=$1
    # Remove dangerous characters, keep only alphanumeric, dash, underscore
    echo "$input" | sed 's/[^a-zA-Z0-9_-]//g'
}

# Sanitize string for use in regex
function escape_for_regex() {
    local input=$1
    # Escape special regex characters
    printf '%s\n' "$input" | sed 's/[[\.*^$()+?{|]/\\&/g'
}

# Sanitize string for use in sed
function escape_for_sed() {
    local input=$1
    # Escape special sed characters
    printf '%s\n' "$input" | sed 's/[[\.*^$()+?{|&/]/\\&/g'
}

# Validate file path
function validate_file_path() {
    local path=$1
    
    # Check if path is empty
    if [ -z "$path" ]; then
        error_exit "File path cannot be empty" $ERR_INVALID_INPUT
    fi
    
    # Check for path traversal attempts
    if [[ "$path" =~ \.\. ]]; then
        error_exit "Path traversal not allowed: $path" $ERR_INVALID_INPUT
    fi
    
    # Check if path starts with /
    if [[ "$path" =~ ^/ ]]; then
        error_exit "Absolute paths not allowed: $path" $ERR_INVALID_INPUT
    fi
    
    return 0
}

# Validate integer
function validate_integer() {
    local value=$1
    local min=${2:-}
    local max=${3:-}
    
    # Check if it's a number
    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        error_exit "Invalid integer: $value" $ERR_INVALID_INPUT
    fi
    
    # Check min bound
    if [ -n "$min" ] && [ "$value" -lt "$min" ]; then
        error_exit "Value $value is less than minimum $min" $ERR_INVALID_INPUT
    fi
    
    # Check max bound
    if [ -n "$max" ] && [ "$value" -gt "$max" ]; then
        error_exit "Value $value is greater than maximum $max" $ERR_INVALID_INPUT
    fi
    
    return 0
}

# Validate boolean
function validate_boolean() {
    local value=$1
    
    case "${value,,}" in
        "true"|"false"|"yes"|"no"|"y"|"n"|"1"|"0")
            return 0
            ;;
        *)
            error_exit "Invalid boolean value: $value" $ERR_INVALID_INPUT
            ;;
    esac
}

# Convert to boolean
function to_boolean() {
    local value=$1
    
    case "${value,,}" in
        "true"|"yes"|"y"|"1")
            echo "true"
            ;;
        *)
            echo "false"
            ;;
    esac
}

# Validate email (basic check)
function validate_email() {
    local email=$1
    
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        error_exit "Invalid email format: $email" $ERR_INVALID_INPUT
    fi
    
    return 0
}

# Validate URL (basic check)
function validate_url() {
    local url=$1
    
    if [[ ! "$url" =~ ^https?:// ]]; then
        error_exit "Invalid URL format: $url" $ERR_INVALID_INPUT
    fi
    
    return 0
}

# Validate git branch name
function validate_branch_name() {
    local branch=$1
    
    # Git branch naming rules
    if [[ ! "$branch" =~ ^[a-zA-Z0-9/_.-]+$ ]]; then
        error_exit "Invalid branch name: $branch" $ERR_INVALID_INPUT
    fi
    
    # Check for invalid patterns
    if [[ "$branch" =~ (^[.-]|[.-]$|\.\.|\/$|\/\.|@\{) ]]; then
        error_exit "Invalid branch name pattern: $branch" $ERR_INVALID_INPUT
    fi
    
    return 0
}