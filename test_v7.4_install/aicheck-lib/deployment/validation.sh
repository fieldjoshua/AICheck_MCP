#!/bin/bash
# AICheck Deployment Validation Functions
# Pre-deployment checks and validation

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/errors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../detection/environment.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../git/operations.sh"

# Main deployment validation
function validate_deployment() {
    print_section "🚀 Pre-Deployment Validation"
    
    local validation_passed=true
    local checks_failed=0
    
    # 1. Check for uncommitted changes
    print_header "Checking git status..."
    if has_uncommitted_changes; then
        print_error "Uncommitted changes detected"
        get_git_status_summary
        validation_passed=false
        ((checks_failed++))
    else
        print_success "Working directory clean"
    fi
    
    # 2. Run tests
    print_header "Running test suite..."
    if ! run_deployment_tests; then
        validation_passed=false
        ((checks_failed++))
    fi
    
    # 3. Check dependencies
    print_header "Validating dependencies..."
    if ! validate_all_dependencies; then
        validation_passed=false
        ((checks_failed++))
    fi
    
    # 4. Lint checks
    print_header "Running lint checks..."
    if ! run_deployment_linting; then
        validation_passed=false
        ((checks_failed++))
    fi
    
    # 5. Type checks
    print_header "Running type checks..."
    if ! run_deployment_typechecks; then
        validation_passed=false
        ((checks_failed++))
    fi
    
    # 6. Security checks
    print_header "Running security checks..."
    if ! run_security_checks; then
        validation_passed=false
        ((checks_failed++))
    fi
    
    # 7. Build verification
    print_header "Verifying build..."
    if ! verify_build; then
        validation_passed=false
        ((checks_failed++))
    fi
    
    # 8. Documentation check
    print_header "Checking documentation..."
    if ! check_documentation; then
        print_warning "Documentation may be outdated"
        # Don't fail deployment for docs
    fi
    
    # Summary
    echo ""
    if [ "$validation_passed" = "true" ]; then
        print_success "✅ All deployment checks passed!"
        print_info "Ready for deployment"
        return 0
    else
        print_error "❌ Deployment validation failed"
        print_error "$checks_failed checks failed"
        print_info "Fix the issues above before deploying"
        return 1
    fi
}

# Run deployment tests
function run_deployment_tests() {
    local test_commands=($(get_test_command))
    
    if [ "${test_commands[0]}" = "none" ]; then
        print_warning "No test command configured"
        print_info "Add test configuration to ensure quality"
        return 0  # Don't fail if no tests configured
    fi
    
    local all_passed=true
    
    for cmd in "${test_commands[@]}"; do
        print_info "Running: $cmd"
        if eval "$cmd"; then
            print_success "Tests passed: $cmd"
        else
            print_error "Tests failed: $cmd"
            all_passed=false
        fi
    done
    
    [ "$all_passed" = "true" ]
}

# Validate dependencies
function validate_all_dependencies() {
    local issues=0
    
    # Check package manager files are in sync
    if has_project_feature "node"; then
        if has_project_feature "npm" && [ ! -f "package-lock.json" ]; then
            print_warning "Missing package-lock.json"
            ((issues++))
        fi
        
        # Check for outdated packages
        if command -v npm >/dev/null 2>&1; then
            local outdated=$(npm outdated --json 2>/dev/null | jq -r 'keys | length' 2>/dev/null || echo "0")
            if [ "$outdated" -gt 0 ]; then
                print_warning "$outdated outdated npm packages"
            fi
        fi
    fi
    
    if has_project_feature "python-poetry"; then
        if [ ! -f "poetry.lock" ]; then
            print_warning "Missing poetry.lock file"
            ((issues++))
        elif command -v poetry >/dev/null 2>&1; then
            if ! poetry check >/dev/null 2>&1; then
                print_error "Poetry dependency check failed"
                ((issues++))
            fi
        fi
    fi
    
    if [ $issues -eq 0 ]; then
        print_success "All dependencies validated"
        return 0
    else
        print_error "Found $issues dependency issues"
        return 1
    fi
}

# Run linting
function run_deployment_linting() {
    local lint_commands=($(get_lint_command))
    
    if [ "${lint_commands[0]}" = "none" ]; then
        print_info "No linting configured"
        return 0
    fi
    
    local all_passed=true
    
    for cmd in "${lint_commands[@]}"; do
        print_info "Running: $cmd"
        if eval "$cmd"; then
            print_success "Linting passed: $cmd"
        else
            print_error "Linting failed: $cmd"
            all_passed=false
        fi
    done
    
    [ "$all_passed" = "true" ]
}

# Run type checking
function run_deployment_typechecks() {
    local typecheck_commands=($(get_typecheck_command))
    
    if [ "${typecheck_commands[0]}" = "none" ]; then
        print_info "No type checking configured"
        return 0
    fi
    
    local all_passed=true
    
    for cmd in "${typecheck_commands[@]}"; do
        print_info "Running: $cmd"
        if eval "$cmd"; then
            print_success "Type check passed: $cmd"
        else
            print_error "Type check failed: $cmd"
            all_passed=false
        fi
    done
    
    [ "$all_passed" = "true" ]
}

# Security checks
function run_security_checks() {
    local issues=0
    
    # Check for secrets in code
    print_info "Checking for exposed secrets..."
    
    # Common secret patterns
    local secret_patterns=(
        "api_key"
        "apikey"
        "secret"
        "password"
        "token"
        "private_key"
        "AWS_"
        "GITHUB_TOKEN"
    )
    
    for pattern in "${secret_patterns[@]}"; do
        if git grep -i "$pattern.*=.*['\"]" -- ':!*.md' ':!*.txt' 2>/dev/null | grep -v "example\|sample\|test\|dummy" | grep -q .; then
            print_warning "Potential secrets found for pattern: $pattern"
            ((issues++))
        fi
    done
    
    # Check for sensitive files
    local sensitive_files=(
        ".env"
        ".env.local"
        ".env.production"
        "credentials"
        "*.pem"
        "*.key"
    )
    
    for file_pattern in "${sensitive_files[@]}"; do
        if find . -name "$file_pattern" -not -path "./.git/*" 2>/dev/null | grep -q .; then
            print_warning "Sensitive file pattern found: $file_pattern"
            print_info "Ensure it's in .gitignore"
        fi
    done
    
    if [ $issues -eq 0 ]; then
        print_success "No security issues found"
        return 0
    else
        print_error "Found $issues potential security issues"
        return 1
    fi
}

# Verify build
function verify_build() {
    # Check for common build commands
    if has_project_feature "node"; then
        if grep -q '"build"' package.json 2>/dev/null; then
            print_info "Running build..."
            local pkg_manager=$(get_package_manager)
            
            case "$pkg_manager" in
                "yarn") cmd="yarn build" ;;
                "pnpm") cmd="pnpm build" ;;
                "bun") cmd="bun build" ;;
                *) cmd="npm run build" ;;
            esac
            
            if eval "$cmd"; then
                print_success "Build successful"
                return 0
            else
                print_error "Build failed"
                return 1
            fi
        fi
    fi
    
    if has_project_feature "make"; then
        if grep -q "^build:" Makefile 2>/dev/null; then
            print_info "Running make build..."
            if make build; then
                print_success "Build successful"
                return 0
            else
                print_error "Build failed"
                return 1
            fi
        fi
    fi
    
    print_info "No build process configured"
    return 0
}

# Check documentation
function check_documentation() {
    local docs_ok=true
    
    # Check README
    if [ ! -f "README.md" ] && [ ! -f "README.rst" ] && [ ! -f "README.txt" ]; then
        print_warning "No README file found"
        docs_ok=false
    fi
    
    # Check if docs are up to date
    if [ -f "README.md" ]; then
        local readme_age=$(find README.md -mtime +30 2>/dev/null | wc -l | tr -d ' ')
        if [ "$readme_age" -gt 0 ]; then
            print_warning "README.md hasn't been updated in 30+ days"
            docs_ok=false
        fi
    fi
    
    # Check for API documentation
    if [ -d "docs" ] || [ -d "documentation" ]; then
        print_info "Documentation directory found"
    else
        print_info "No documentation directory found"
    fi
    
    [ "$docs_ok" = "true" ]
}

# Generate deployment checklist
function generate_deployment_checklist() {
    local checklist_file=".aicheck/deployment-checklist-$(date +%Y%m%d_%H%M%S).md"
    
    print_section "📋 Generating Deployment Checklist"
    
    {
        echo "# Deployment Checklist"
        echo "Generated: $(date)"
        echo ""
        echo "## Pre-Deployment"
        echo "- [ ] All tests passing"
        echo "- [ ] No linting errors"
        echo "- [ ] Type checks pass"
        echo "- [ ] Dependencies up to date"
        echo "- [ ] Security scan completed"
        echo "- [ ] Build successful"
        echo "- [ ] Documentation updated"
        echo ""
        echo "## Deployment Steps"
        echo "- [ ] Tag release version"
        echo "- [ ] Create release branch"
        echo "- [ ] Deploy to staging"
        echo "- [ ] Run smoke tests"
        echo "- [ ] Deploy to production"
        echo "- [ ] Verify deployment"
        echo ""
        echo "## Post-Deployment"
        echo "- [ ] Monitor error rates"
        echo "- [ ] Check performance metrics"
        echo "- [ ] Update status page"
        echo "- [ ] Notify stakeholders"
        echo ""
        echo "## Rollback Plan"
        echo "- [ ] Previous version ready"
        echo "- [ ] Rollback procedure documented"
        echo "- [ ] Database migration reversible"
    } > "$checklist_file"
    
    print_success "Checklist saved to: $checklist_file"
}

# Quick deployment check
function quick_deployment_check() {
    print_section "⚡ Quick Deployment Check"
    
    local ready=true
    
    # Essential checks only
    echo -n "Git status: "
    if has_uncommitted_changes; then
        print_error "DIRTY"
        ready=false
    else
        print_success "CLEAN"
    fi
    
    echo -n "Tests: "
    local test_cmd=$(get_test_command | head -1)
    if [ "$test_cmd" != "none" ] && eval "$test_cmd" >/dev/null 2>&1; then
        print_success "PASS"
    else
        print_error "FAIL"
        ready=false
    fi
    
    echo -n "Build: "
    if verify_build >/dev/null 2>&1; then
        print_success "OK"
    else
        print_error "FAIL"
        ready=false
    fi
    
    echo ""
    if [ "$ready" = "true" ]; then
        print_success "✅ Ready for deployment"
    else
        print_error "❌ Not ready for deployment"
    fi
    
    [ "$ready" = "true" ]
}