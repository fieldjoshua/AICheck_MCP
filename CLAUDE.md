# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ IMPORTANT: Development Context

**DO NOT USE AICheck MCP tools when working on this repository.** This is the AICheck development repository itself - we are creating the governance system, not using it. Using AICheck governance on its own development would create circular dependencies.

When you see MCP tools like `mcp__aicheck__*` available, ignore them for this project. Use standard git workflows and development practices instead.

## Project Overview

AICheck is a bash-based governance system for AI-assisted development that enforces single-action focus, human oversight, and production safety. This repository develops AICheck itself - the tool that other projects use for governance.

## Core Architecture

### Main Script (`./aicheck`)
- **5000+ line bash script** with 55+ functions
- **Command Router**: Main case statement at line ~3811 handles all subcommands
- **Color System**: Uses ANSI escape codes (defined ~line 198)
- **Version**: `AICHECK_VERSION` variable (currently 7.2.0)
- **State Files**:
  - `.aicheck/current_action` - Stores the single active action name
  - `.aicheck/actions_index.md` - Markdown table tracking all actions
  - `.aicheck/actions/*/status.txt` - Individual action status files

### Key Functions
- `validate_single_active_action()` - Enforces one active action principle
- `detect_project_environment()` - Smart detection of Python/Node/build tools
- `run_smart_completion_checks()` - Context-aware validation on completion
- `cleanup_and_optimize()` - Interactive state cleanup
- `fix_multiple_active_actions()` - Resolves state conflicts
- `install_smart_precommit_hook()` - Installs context-aware git hooks
- `auto_iterate()` - Goal-driven development cycles with approval gates

### Installation System
- **Primary**: `install.sh` - Downloads aicheck, sets up MCP, configures Claude
- **Backup Strategy**: Uses tar with 30s timeout, keeps only 3 recent backups
- **MCP Configuration**: Modifies `~/.config/claude/claude_desktop_config.json`
- **Unique Naming**: Server named `aicheck-{directory}` to prevent conflicts

## Commands

### Development & Testing
```bash
# Syntax validation
bash -n aicheck
bash -n install.sh

# Run tests
npm test  # Currently just echoes success

# Test specific functionality
./aicheck cleanup      # Test cleanup command
./aicheck status       # Check current state
./aicheck version      # Verify version

# Installation testing
bash install.sh        # Test full installation
```

### Version Management
When releasing a new version:
1. Update `AICHECK_VERSION` in `aicheck` (line ~19)
2. Update version references in `install.sh`
3. Update `README.md` title and "What's New" section
4. Run comprehensive tests before committing

## State Management

### Action Status Values
- **Not Started** - Created but work hasn't begun
- **In Progress** - Work started but action not currently active
- **ActiveAction** - THE currently active action (only ONE allowed)
- **Completed** - Action finished

### State Synchronization
Three sources of truth must stay synchronized:
1. `.aicheck/current_action` file
2. `ActiveAction` status in `.aicheck/actions_index.md`
3. `status.txt` files in action directories

The `fix_multiple_active_actions()` function handles synchronization.

## Smart Detection Features

### Project Environment Detection (`detect_project_environment()`)
Detects and returns array of project characteristics:
- Package managers: `python-poetry`, `node`, `npm-lock`, `yarn-lock`
- Build tools: `make`, `gradle`, `maven`
- Test frameworks: `pytest`, `jest`, `tests-dir`
- Linters: `black`, `ruff`, `eslint`, `prettier`
- Type checkers: `mypy`, `typescript`

### Completion Checks (`run_smart_completion_checks()`)
Runs only relevant checks based on detected environment:
1. Dependency integrity (lock files in sync)
2. Test suite (if tests exist)
3. Code quality (if linters configured)
4. Git status (uncommitted changes)
5. Build success (if build system exists)

## MCP Integration

### Server Structure
```
MCP/
├── AICheck_MCP/
│   └── server.js    # MCP server implementation
└── package.json     # Dependencies
```

### MCP Header Types
- `AICheck_Planner` - Strategic planning files
- `AICheck_Tracker` - Progress tracking files
- `AICheck_Scoper` - Code with scope limits
- `AICheck_Validator` - Test files

## Critical Implementation Notes

### Bash Gotchas
- Always quote variables: `"$var"` not `$var`
- Use `local` only inside functions
- Check for empty vars: `[ -z "$var" ]` or `[ "$var" = "" ]`
- Escape regex properly in grep/sed
- macOS sed requires `sed -i ""` not `sed -i`

### Color Codes
```bash
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
BRIGHT_BLURPLE="\033[38;5;135m"
NC="\033[0m"  # No Color
```

### Error Handling Patterns
- Check command existence: `command -v tool >/dev/null 2>&1`
- Suppress errors: `command 2>/dev/null || true`
- Default values: `${var:-default}`
- Exit on error in functions: `return 1` not `exit 1`

## Testing Strategy

Since AICheck creates tools for other projects:
1. **Syntax Testing**: `bash -n` all shell scripts
2. **Integration Testing**: Create test directory, run installer, verify functionality
3. **State Testing**: Create multiple actions, test enforcement
4. **Edge Cases**: Empty actions_index.md, missing files, corrupted state

## Common Development Tasks

### Adding a New Command
1. Add case in main command handling (~line 3811)
2. Create function if complex logic needed
3. Update help text in `show_version()`
4. Test with various edge cases

### Debugging State Issues
1. Check `.aicheck/current_action` contents
2. Verify `actions_index.md` ActiveAction entries
3. Check `status.txt` files in action directories
4. Run `./aicheck cleanup` for interactive fix

### Updating Installer
1. Test backup mechanism with timeout
2. Verify MCP configuration handling
3. Check version detection and update logic
4. Test both fresh install and update paths

## Memories

- Run comprehensive tests on entire codebase before committing changes
- The main aicheck script has duplicate case statements that need careful handling
- Local variables declared outside functions cause "local: can only be used in a function" errors
- Empty grep patterns when no actions exist are cosmetic issues, not critical