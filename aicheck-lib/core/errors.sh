#!/bin/bash
# AICheck Error Handling Framework
# Provides consistent error handling across the application

# Load output functions if not already loaded
if ! type print_error >/dev/null 2>&1; then
    source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"
fi

# Error codes
export ERR_GENERAL=1
export ERR_NOT_INITIALIZED=2
export ERR_INVALID_INPUT=3
export ERR_STATE_CONFLICT=4
export ERR_FILE_NOT_FOUND=5
export ERR_PERMISSION_DENIED=6
export ERR_DEPENDENCY_MISSING=7
export ERR_LOCK_FAILED=8
export ERR_MIGRATION_FAILED=9
export ERR_MCP_ERROR=10

# Error exit function
function error_exit() {
    local message=$1
    local code=${2:-$ERR_GENERAL}
    
    print_error "ERROR: $message"
    
    # Log error if in debug mode
    if [ "${DEBUG:-0}" = "1" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR($code): $message" >> .aicheck/error.log
    fi
    
    exit "$code"
}

# Warning function (doesn't exit)
function warning() {
    local message=$1
    print_warning "WARNING: $message"
    
    if [ "${DEBUG:-0}" = "1" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $message" >> .aicheck/error.log
    fi
}

# Check if AICheck is initialized
function require_aicheck_init() {
    if [ ! -d ".aicheck" ]; then
        error_exit "Not in an AICheck project. Run from project root with an initialized AICheck setup." $ERR_NOT_INITIALIZED
    fi
}

# Check if a required command exists
function require_command() {
    local cmd=$1
    local message=${2:-"Required command '$cmd' not found. Please install it first."}
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
        error_exit "$message" $ERR_DEPENDENCY_MISSING
    fi
}

# Safe command execution with error handling
function safe_execute() {
    local cmd=$1
    local error_message=${2:-"Command failed: $cmd"}
    
    if ! eval "$cmd"; then
        error_exit "$error_message" $ERR_GENERAL
    fi
}

# Try-catch style error handling
function try() {
    [[ $- = *e* ]]; SAVED_OPT_E=$?
    set +e
}

function catch() {
    export exception_code=$?
    (( SAVED_OPT_E )) && set +e
    return $exception_code
}

# Cleanup function to be called on exit
function cleanup_on_exit() {
    local exit_code=$?
    
    # Remove lock files
    rm -f .aicheck/.state.lock 2>/dev/null
    rm -f .aicheck/.operation.lock 2>/dev/null
    
    # Reset terminal colors
    echo -en "$NC"
    
    exit $exit_code
}

# Set up exit trap
trap cleanup_on_exit EXIT INT TERM

# Debug logging
function debug_log() {
    if [ "${DEBUG:-0}" = "1" ]; then
        echo "[DEBUG] $1" >&2
    fi
}

# Validate required environment
function validate_environment() {
    # Check bash version (need 4.0+)
    if [ "${BASH_VERSION%%.*}" -lt 4 ]; then
        error_exit "AICheck requires Bash 4.0 or higher. Current version: $BASH_VERSION" $ERR_DEPENDENCY_MISSING
    fi
    
    # Check for required commands
    local required_commands=("git" "sed" "grep" "find")
    for cmd in "${required_commands[@]}"; do
        require_command "$cmd"
    done
}