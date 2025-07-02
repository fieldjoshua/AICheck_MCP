#!/bin/bash
# AICheck Git Operations Functions
# Handles git-related operations and checks

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/errors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"

# Check if we're in a git repository
function is_git_repo() {
    git rev-parse --git-dir >/dev/null 2>&1
}

# Get current git branch
function get_current_branch() {
    if is_git_repo; then
        git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n' || echo "unknown"
    else
        echo "not-a-git-repo"
    fi
}

# Get git status summary
function get_git_status_summary() {
    if ! is_git_repo; then
        echo "Not a git repository"
        return 1
    fi
    
    local branch=$(get_current_branch)
    local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    local staged=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
    local unstaged=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
    local untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    
    echo "Branch: $branch"
    echo "Total changes: $changes"
    echo "Staged: $staged, Unstaged: $unstaged, Untracked: $untracked"
}

# Check for uncommitted changes
function has_uncommitted_changes() {
    if ! is_git_repo; then
        return 1
    fi
    
    [ -n "$(git status --porcelain 2>/dev/null)" ]
}

# Get list of modified files
function get_modified_files() {
    if ! is_git_repo; then
        return 1
    fi
    
    git status --porcelain 2>/dev/null | awk '{print $2}'
}

# Check if file is tracked by git
function is_file_tracked() {
    local file=$1
    
    if ! is_git_repo; then
        return 1
    fi
    
    git ls-files --error-unmatch "$file" >/dev/null 2>&1
}

# Get last commit info
function get_last_commit_info() {
    if ! is_git_repo; then
        echo "Not a git repository"
        return 1
    fi
    
    git log -1 --pretty=format:"%h %s" 2>/dev/null || echo "No commits yet"
}

# Create git commit with AICheck context
function create_aicheck_commit() {
    local message=$1
    local action_name=${2:-$(get_current_action)}
    
    if ! is_git_repo; then
        error_exit "Not a git repository" $ERR_GENERAL
    fi
    
    if ! has_uncommitted_changes; then
        print_info "No changes to commit"
        return 0
    fi
    
    # Add action context to commit message
    local full_message="$message"
    if [ "$action_name" != "None" ] && [ -n "$action_name" ]; then
        full_message="[$action_name] $message"
    fi
    
    # Show what will be committed
    print_section "📝 Commit Preview"
    echo "Message: $full_message"
    echo ""
    git status --short
    
    # Confirm
    if confirm "Proceed with commit?"; then
        git add -A
        git commit -m "$full_message"
        print_success "Created commit: $(git log -1 --pretty=format:'%h %s')"
    else
        print_info "Commit cancelled"
    fi
}

# Check git hooks
function check_git_hooks() {
    if ! is_git_repo; then
        return 1
    fi
    
    local hooks_found=false
    
    # Check .git/hooks
    if [ -d ".git/hooks" ]; then
        for hook in pre-commit pre-push commit-msg post-commit; do
            if [ -f ".git/hooks/$hook" ] && [ -x ".git/hooks/$hook" ]; then
                echo "Found hook: $hook"
                hooks_found=true
            fi
        done
    fi
    
    # Check for pre-commit framework
    if [ -f ".pre-commit-config.yaml" ] || [ -f ".pre-commit-config.yml" ]; then
        echo "Found: pre-commit framework configuration"
        hooks_found=true
    fi
    
    # Check for husky
    if [ -d ".husky" ]; then
        echo "Found: husky git hooks"
        hooks_found=true
    fi
    
    if ! $hooks_found; then
        echo "No git hooks found"
    fi
}

# Run pre-commit checks
function run_pre_commit_checks() {
    if ! is_git_repo; then
        return 0
    fi
    
    print_section "🔍 Running pre-commit checks"
    
    # Check for pre-commit tool
    if command -v pre-commit >/dev/null 2>&1 && [ -f ".pre-commit-config.yaml" -o -f ".pre-commit-config.yml" ]; then
        print_info "Running pre-commit hooks..."
        if pre-commit run --all-files; then
            print_success "All pre-commit checks passed"
            return 0
        else
            print_error "Pre-commit checks failed"
            return 1
        fi
    fi
    
    # Check for husky
    if [ -f ".husky/pre-commit" ]; then
        print_info "Running husky pre-commit hook..."
        if bash .husky/pre-commit; then
            print_success "Husky pre-commit passed"
            return 0
        else
            print_error "Husky pre-commit failed"
            return 1
        fi
    fi
    
    # Check for git pre-commit hook
    if [ -f ".git/hooks/pre-commit" ] && [ -x ".git/hooks/pre-commit" ]; then
        print_info "Running git pre-commit hook..."
        if .git/hooks/pre-commit; then
            print_success "Git pre-commit passed"
            return 0
        else
            print_error "Git pre-commit failed"
            return 1
        fi
    fi
    
    print_info "No pre-commit hooks configured"
    return 0
}

# Get files changed in current branch
function get_branch_changes() {
    if ! is_git_repo; then
        return 1
    fi
    
    local base_branch=${1:-main}
    local current_branch=$(get_current_branch)
    
    if [ "$current_branch" = "$base_branch" ]; then
        # On main branch, show uncommitted changes
        get_modified_files
    else
        # Show all files changed in branch
        git diff --name-only "$base_branch"..."$current_branch" 2>/dev/null
    fi
}

# Create branch for action
function create_action_branch() {
    local action_name=$1
    
    if ! is_git_repo; then
        print_warning "Not a git repository - skipping branch creation"
        return 0
    fi
    
    local branch_name="action/$(to_kebab_case "$action_name")"
    
    # Check if branch exists
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        print_info "Branch already exists: $branch_name"
        if confirm "Switch to existing branch?"; then
            git checkout "$branch_name"
        fi
    else
        if confirm "Create new branch '$branch_name'?"; then
            git checkout -b "$branch_name"
            print_success "Created and switched to branch: $branch_name"
        fi
    fi
}