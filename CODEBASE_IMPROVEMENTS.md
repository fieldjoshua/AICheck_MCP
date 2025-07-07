# AICheck Codebase Improvements - Priority List

**⚠️ IMPORTANT: Complete these improvements before releasing new AICheck versions**

This document contains the audit findings and prioritized improvements for the AICheck codebase. These should be addressed to improve maintainability, reliability, and security.

## 🎯 Priority Order (by Impact vs Effort)

### Priority 1: Critical Foundation (Do First)
1. **Extract functions into modules** - Makes testing and maintenance easier
2. **Add proper error handling framework** - Prevents silent failures  
3. **Create basic test suite** - Catches regressions
4. **Fix state synchronization** - Core functionality issue
5. **Add input validation** - Security and stability

### Priority 2: Core Improvements (Do Second)
6. **Implement atomic state operations** - Prevent race conditions
7. **Add progress indicators** - Better UX for long operations
8. **Create migration framework** - Smoother updates
9. **Centralize help system** - Better documentation
10. **Add dry-run mode** - Safer operations

### Priority 3: Long-term Health (Do Third)
11. **Performance optimizations** - Caching, batch operations
12. **Comprehensive test coverage** - Unit and integration tests
13. **Security hardening** - Full input sanitization
14. **Backwards compatibility system** - Version management
15. **Automatic cleanup** - Old backups, orphaned files

---

## 📋 Detailed Improvement Plan

### 1. Code Structure & Architecture 🏗️

**Problem**: 5000+ line monolithic script is hard to maintain

**Solution**: Modular structure
```bash
aicheck-lib/
├── core.sh          # Core functions, state management
├── commands.sh      # Command implementations  
├── validation.sh    # All validation functions
├── ui.sh           # Color codes, output formatting
├── mcp.sh          # MCP-related functions
└── detection.sh    # Project detection logic
```

**Implementation**:
- Create aicheck-lib directory
- Extract functions by category
- Update main script to source modules
- Test each module independently

### 2. Error Handling Framework ⚠️

**Problem**: Inconsistent error handling, silent failures

**Solution**: Centralized error system
```bash
function error_exit() {
    echo -e "${RED}ERROR: $1${NC}" >&2
    exit "${2:-1}"
}

function require_aicheck_init() {
    if [ ! -d ".aicheck" ]; then
        error_exit "Not in an AICheck project. Run from project root."
    fi
}
```

**Implementation**:
- Add to core.sh module
- Replace all exit/return inconsistencies
- Add error codes documentation
- Test error paths

### 3. State Management 🔄

**Problem**: Three sources of truth can desync

**Solution**: Atomic state operations
```bash
function update_action_state() {
    local action_name=$1
    local new_status=$2
    
    # Lock file to prevent concurrent modifications
    local lockfile=".aicheck/.state.lock"
    exec 200>"$lockfile"
    flock -n 200 || error_exit "State is locked by another process"
    
    # Update all three sources atomically
    echo "$action_name" > .aicheck/current_action
    update_status_file "$action_name" "$new_status"
    update_actions_index "$action_name" "$new_status"
    
    # Release lock
    flock -u 200
}
```

**Implementation**:
- Create state.sh module
- Implement locking mechanism
- Add transaction rollback
- Test concurrent access

### 4. Testing Infrastructure 🧪

**Problem**: No real tests exist

**Solution**: Comprehensive test suite
```bash
tests/
├── unit/
│   ├── test_state_management.sh
│   ├── test_validation.sh
│   └── test_detection.sh
├── integration/
│   ├── test_full_workflow.sh
│   └── test_mcp_integration.sh
├── fixtures/
│   └── test_projects/
└── run_tests.sh
```

**Implementation**:
- Create test framework
- Add assertion functions
- Mock external dependencies
- Add to CI/CD pipeline

### 5. Input Validation & Security 🔒

**Problem**: Potential shell injection, no input sanitization

**Solution**: Validation framework
```bash
function validate_action_name() {
    local name=$1
    if [[ ! "$name" =~ ^[A-Za-z][A-Za-z0-9-]*$ ]]; then
        error_exit "Invalid action name. Use only letters, numbers, and hyphens."
    fi
}

function escape_for_regex() {
    printf '%s\n' "$1" | sed 's/[[\.*^$()+?{|]/\\&/g'
}
```

**Implementation**:
- Add validation.sh module
- Validate all user inputs
- Escape special characters
- Add security tests

### 6. Performance Optimizations 🚀

**Problem**: Redundant operations, no caching

**Solution**: Smart caching and batch operations
```bash
# Cache project environment
CACHED_PROJECT_ENV=""
function get_project_environment() {
    if [ -n "$CACHED_PROJECT_ENV" ]; then
        echo "$CACHED_PROJECT_ENV"
        return
    fi
    CACHED_PROJECT_ENV=$(detect_project_environment)
    echo "$CACHED_PROJECT_ENV"
}
```

**Implementation**:
- Add caching layer
- Batch file operations
- Profile slow operations
- Optimize hot paths

### 7. User Experience 💡

**Problem**: Poor feedback, no progress indicators

**Solution**: Better UI/UX
```bash
function with_spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
}

DRY_RUN=${DRY_RUN:-false}
```

**Implementation**:
- Add progress indicators
- Implement dry-run mode
- Improve error messages
- Add verbose mode

### 8. Migration Framework 🔄

**Problem**: Manual migrations, version conflicts

**Solution**: Automatic migration system
```bash
function migrate_if_needed() {
    local current_version=$(get_installed_version)
    local new_version="$AICHECK_VERSION"
    
    if version_less_than "$current_version" "$new_version"; then
        echo "Migrating from $current_version to $new_version..."
        run_migrations "$current_version" "$new_version"
    fi
}
```

**Implementation**:
- Create migrations/ directory
- Version comparison functions
- Rollback capability
- Migration tests

---

## 📊 Success Metrics

- [ ] All functions < 50 lines
- [ ] Test coverage > 80%
- [ ] Zero shellcheck warnings
- [ ] All user inputs validated
- [ ] State operations atomic
- [ ] Error messages helpful
- [ ] Performance improved 2x
- [ ] Migration automatic

---

## 🚀 Implementation Plan

### Phase 1 (Week 1-2): Foundation
- Extract modules
- Add error framework
- Create test structure
- Fix critical bugs

### Phase 2 (Week 3-4): Core Systems  
- State management
- Input validation
- Basic tests
- Documentation

### Phase 3 (Week 5-6): Polish
- Performance optimization
- UI improvements
- Migration system
- Full test coverage

---

**Remember**: No new features until these improvements are complete!