#!/bin/bash
# AICheck UI Output Functions
# This module provides consistent output formatting functions

# Ensure colors are loaded
if [ -z "$GREEN" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"
fi

# Success message
function print_success() {
    echo -e "${GREEN}${CHECK_MARK} $1${NC}"
}

# Error message
function print_error() {
    echo -e "${RED}${CROSS_MARK} $1${NC}" >&2
}

# Warning message
function print_warning() {
    echo -e "${YELLOW}${WARNING_SIGN} $1${NC}"
}

# Info message
function print_info() {
    echo -e "${CYAN}${INFO_SIGN} $1${NC}"
}

# Header message
function print_header() {
    echo -e "${BRIGHT_BLURPLE}$1${NC}"
}

# Section header
function print_section() {
    echo -e "\n${BRIGHT_BLURPLE}$1${NC}"
}

# Progress spinner
function show_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    
    while [ "$(ps a | awk '{print $1}' | grep -q $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Styled prompt
function prompt_user() {
    local prompt=$1
    local default=$2
    local response
    
    if [ -n "$default" ]; then
        echo -en "${CYAN}$prompt [${default}]: ${NC}"
    else
        echo -en "${CYAN}$prompt: ${NC}"
    fi
    
    read -r response
    echo "${response:-$default}"
}

# Confirmation prompt
function confirm() {
    local prompt=${1:-"Continue?"}
    local response
    
    echo -en "${YELLOW}$prompt (y/n): ${NC}"
    read -r response
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Print command for user to run
function print_command() {
    echo -e "${GRAY}$1${NC}"
}

# Print file path
function print_path() {
    echo -e "${CYAN}$1${NC}"
}

# Print action name
function print_action() {
    echo -e "${GREEN}$1${NC}"
}

# Print status
function print_status() {
    local status=$1
    case "$status" in
        "ActiveAction")
            echo -e "${GREEN}$status${NC}"
            ;;
        "Completed")
            echo -e "${BLUE}$status${NC}"
            ;;
        "In Progress")
            echo -e "${YELLOW}$status${NC}"
            ;;
        "Not Started")
            echo -e "${GRAY}$status${NC}"
            ;;
        *)
            echo "$status"
            ;;
    esac
}