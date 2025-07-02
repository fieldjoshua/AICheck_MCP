#!/bin/bash
# AICheck Project Environment Detection
# Detects project type, tools, and dependencies

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"

# Detect project environment and tools
function detect_project_environment() {
    local project_info=()
    
    # Python detection
    if [ -f "pyproject.toml" ]; then
        project_info+=("python-poetry")
        [ -f "poetry.lock" ] && project_info+=("poetry-lock")
    elif [ -f "requirements.txt" ] || [ -f "requirements-dev.txt" ]; then
        project_info+=("python-pip")
    elif [ -f "setup.py" ] || [ -f "setup.cfg" ]; then
        project_info+=("python-setuptools")
    fi
    
    # Node.js detection
    if [ -f "package.json" ]; then
        project_info+=("node")
        [ -f "package-lock.json" ] && project_info+=("npm")
        [ -f "yarn.lock" ] && project_info+=("yarn")
        [ -f "pnpm-lock.yaml" ] && project_info+=("pnpm")
        [ -f "bun.lockb" ] && project_info+=("bun")
    fi
    
    # Build tools detection
    [ -f "Makefile" ] && project_info+=("make")
    [ -f "CMakeLists.txt" ] && project_info+=("cmake")
    [ -f "build.gradle" ] || [ -f "build.gradle.kts" ] && project_info+=("gradle")
    [ -f "pom.xml" ] && project_info+=("maven")
    
    # Language-specific files
    [ -f "Cargo.toml" ] && project_info+=("rust-cargo")
    [ -f "go.mod" ] && project_info+=("go-modules")
    [ -f "composer.json" ] && project_info+=("php-composer")
    [ -f "Gemfile" ] && project_info+=("ruby-bundler")
    
    # CI/CD detection
    [ -d ".github/workflows" ] && project_info+=("github-actions")
    [ -f ".gitlab-ci.yml" ] && project_info+=("gitlab-ci")
    [ -f ".circleci/config.yml" ] && project_info+=("circleci")
    [ -f "Jenkinsfile" ] && project_info+=("jenkins")
    
    # Docker detection
    [ -f "Dockerfile" ] && project_info+=("docker")
    [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] && project_info+=("docker-compose")
    
    # Testing frameworks
    [ -f "pytest.ini" ] || [ -f ".pytest.ini" ] || [ -f "setup.cfg" ] && grep -q "pytest" setup.cfg 2>/dev/null && project_info+=("pytest")
    [ -f "jest.config.js" ] || [ -f "jest.config.ts" ] && project_info+=("jest")
    [ -d "__tests__" ] || [ -d "tests" ] || [ -d "test" ] && project_info+=("has-tests")
    
    # Linters and formatters
    [ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] && project_info+=("eslint")
    [ -f ".prettierrc" ] || [ -f ".prettierrc.js" ] || [ -f ".prettierrc.json" ] && project_info+=("prettier")
    [ -f ".flake8" ] || [ -f "setup.cfg" ] && grep -q "flake8" setup.cfg 2>/dev/null && project_info+=("flake8")
    [ -f ".pylintrc" ] || [ -f "pyproject.toml" ] && grep -q "pylint" pyproject.toml 2>/dev/null && project_info+=("pylint")
    [ -f ".rubocop.yml" ] && project_info+=("rubocop")
    [ -f "ruff.toml" ] || [ -f "pyproject.toml" ] && grep -q "ruff" pyproject.toml 2>/dev/null && project_info+=("ruff")
    
    # Type checking
    [ -f "tsconfig.json" ] && project_info+=("typescript")
    [ -f "mypy.ini" ] || [ -f ".mypy.ini" ] || [ -f "pyproject.toml" ] && grep -q "mypy" pyproject.toml 2>/dev/null && project_info+=("mypy")
    
    # Framework detection
    [ -f "angular.json" ] && project_info+=("angular")
    [ -f "next.config.js" ] || [ -f "next.config.ts" ] && project_info+=("nextjs")
    [ -f "nuxt.config.js" ] || [ -f "nuxt.config.ts" ] && project_info+=("nuxtjs")
    [ -f "vue.config.js" ] && project_info+=("vuejs")
    [ -f "manage.py" ] && grep -q "django" manage.py 2>/dev/null && project_info+=("django")
    [ -f "app.py" ] || [ -f "application.py" ] && project_info+=("flask")
    
    # Output array
    printf '%s\n' "${project_info[@]}"
}

# Check if a specific tool/environment is present
function has_project_feature() {
    local feature=$1
    local environments=($(detect_project_environment))
    
    for env in "${environments[@]}"; do
        if [ "$env" = "$feature" ]; then
            return 0
        fi
    done
    
    return 1
}

# Get package manager for the project
function get_package_manager() {
    if has_project_feature "yarn"; then
        echo "yarn"
    elif has_project_feature "pnpm"; then
        echo "pnpm"
    elif has_project_feature "bun"; then
        echo "bun"
    elif has_project_feature "npm"; then
        echo "npm"
    elif has_project_feature "poetry-lock"; then
        echo "poetry"
    elif has_project_feature "python-pip"; then
        echo "pip"
    else
        echo "none"
    fi
}

# Get test command for the project
function get_test_command() {
    local pkg_manager=$(get_package_manager)
    
    # Check package.json scripts first
    if [ -f "package.json" ] && [ "$pkg_manager" != "none" ]; then
        if grep -q '"test"' package.json; then
            case "$pkg_manager" in
                "yarn") echo "yarn test" ;;
                "pnpm") echo "pnpm test" ;;
                "bun") echo "bun test" ;;
                *) echo "npm test" ;;
            esac
            return
        fi
    fi
    
    # Python projects
    if has_project_feature "pytest"; then
        if has_project_feature "poetry-lock"; then
            echo "poetry run pytest"
        else
            echo "pytest"
        fi
        return
    fi
    
    # Makefile
    if has_project_feature "make" && [ -f "Makefile" ]; then
        if grep -q "^test:" Makefile; then
            echo "make test"
            return
        fi
    fi
    
    echo "none"
}

# Get lint command for the project
function get_lint_command() {
    local commands=()
    
    # JavaScript/TypeScript linting
    if has_project_feature "eslint"; then
        local pkg_manager=$(get_package_manager)
        case "$pkg_manager" in
            "yarn") commands+=("yarn lint") ;;
            "pnpm") commands+=("pnpm lint") ;;
            "bun") commands+=("bun lint") ;;
            *) commands+=("npm run lint") ;;
        esac
    fi
    
    # Python linting
    if has_project_feature "ruff"; then
        if has_project_feature "poetry-lock"; then
            commands+=("poetry run ruff check .")
        else
            commands+=("ruff check .")
        fi
    elif has_project_feature "flake8"; then
        if has_project_feature "poetry-lock"; then
            commands+=("poetry run flake8")
        else
            commands+=("flake8")
        fi
    elif has_project_feature "pylint"; then
        if has_project_feature "poetry-lock"; then
            commands+=("poetry run pylint")
        else
            commands+=("pylint")
        fi
    fi
    
    # Output commands
    if [ ${#commands[@]} -gt 0 ]; then
        printf '%s\n' "${commands[@]}"
    else
        echo "none"
    fi
}

# Get type checking command
function get_typecheck_command() {
    local commands=()
    
    # TypeScript
    if has_project_feature "typescript"; then
        local pkg_manager=$(get_package_manager)
        # Check if there's a typecheck script
        if [ -f "package.json" ] && grep -q '"typecheck"' package.json; then
            case "$pkg_manager" in
                "yarn") commands+=("yarn typecheck") ;;
                "pnpm") commands+=("pnpm typecheck") ;;
                "bun") commands+=("bun typecheck") ;;
                *) commands+=("npm run typecheck") ;;
            esac
        else
            case "$pkg_manager" in
                "yarn") commands+=("yarn tsc --noEmit") ;;
                "pnpm") commands+=("pnpm tsc --noEmit") ;;
                "bun") commands+=("bun tsc --noEmit") ;;
                *) commands+=("npx tsc --noEmit") ;;
            esac
        fi
    fi
    
    # Python type checking
    if has_project_feature "mypy"; then
        if has_project_feature "poetry-lock"; then
            commands+=("poetry run mypy .")
        else
            commands+=("mypy .")
        fi
    fi
    
    # Output commands
    if [ ${#commands[@]} -gt 0 ]; then
        printf '%s\n' "${commands[@]}"
    else
        echo "none"
    fi
}

# Detect git hooks
function detect_git_hooks() {
    local hooks=()
    
    # Check for git hooks
    if [ -d ".git/hooks" ]; then
        for hook in pre-commit pre-push commit-msg post-commit; do
            if [ -f ".git/hooks/$hook" ] && [ -x ".git/hooks/$hook" ]; then
                hooks+=("$hook")
            fi
        done
    fi
    
    # Check for pre-commit framework
    if [ -f ".pre-commit-config.yaml" ] || [ -f ".pre-commit-config.yml" ]; then
        hooks+=("pre-commit-framework")
    fi
    
    # Check for husky
    if [ -f ".husky/pre-commit" ] || [ -f ".husky/pre-push" ]; then
        hooks+=("husky")
    fi
    
    # Output hooks
    if [ ${#hooks[@]} -gt 0 ]; then
        printf '%s\n' "${hooks[@]}"
    else
        echo "none"
    fi
}