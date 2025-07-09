# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ IMPORTANT: Development Context

**DO NOT USE AICheck MCP tools when working on this repository.** This is the AICheck development repository itself - we are creating the governance system, not using it. Using AICheck governance on its own development would create circular dependencies.

When you see MCP tools like `mcp__aicheck__*` available, ignore them for this project. Use standard git workflows and development practices instead.

## Project Overview

AICheck is a bash-based governance system for AI-assisted development that enforces single-action focus, human oversight, and production safety. This repository develops AICheck itself - the tool that other projects use for governance.

## Core Architecture

### Main Script (`./aicheck`)
- **5000+ line bash script** organized with modular library system
- **Modular Architecture**: 15+ specialized modules in `aicheck-lib/` directory
- **Command Router**: Main case statement at line ~3847 handles all subcommands
- **Version**: `AICHECK_VERSION` variable (currently 7.4.0)
- **Module Loading**: Sources from `aicheck-lib/` or falls back to inline definitions

### Modular Library Structure (`aicheck-lib/`)
```
aicheck-lib/
├── ui/           # User interface (colors.sh, output.sh)
├── core/         # Core functionality (errors.sh, state.sh, dispatcher.sh, utilities.sh)
├── validation/   # Input/action validation (input.sh, actions.sh)
├── detection/    # Environment detection (environment.sh)
├── actions/      # Action management (management.sh)
├── mcp/          # MCP integration (integration.sh)
├── git/          # Git operations (operations.sh)
├── automation/   # Auto-iterate feature (auto_iterate.sh)
├── maintenance/  # Cleanup operations (cleanup.sh)
└── deployment/   # Deploy validation (validation.sh)
```

### State Management
- `.aicheck/current_action` - Single active action name
- `.aicheck/actions_index.md` - Markdown table tracking all actions (5 columns: Action|Description|Status|Progress|Created)
- `.aicheck/actions/*/status.txt` - Individual action status files
- Status values: `Not Started`, `In Progress`, `ActiveAction`, `Completed`

### MCP Integration
- **Server**: `.mcp/server/index.js` - Node.js MCP server
- **Tools**: Exposes AICheck functions as MCP tools (getCurrentAction, listActions, etc.)
- **Headers**: Injects compliance reminders showing current action in every file

## Commands

### Build & Test
```bash
# Syntax validation
bash -n aicheck
bash -n install.sh
bash -n aicheck-lib/*/*.sh

# Module testing
./test-all-modules.sh      # Comprehensive module tests
./test-modules-simple.sh   # Quick module validation
./test-integration.sh      # Integration tests

# Installation testing
bash install.sh            # Test full installation
./test-installer-local.sh  # Test installer locally
```

### Development Commands
```bash
# Version check
./aicheck version

# Essential commands (v7.4.0 simplified structure)
./aicheck status           # Current state overview
./aicheck new <name>       # Create new action
./aicheck complete         # Finish current action
./aicheck stuck            # Get help
./aicheck cleanup          # Fix issues

# Action management (consolidated in v7.4.0)
./aicheck action new <name>      # Create action
./aicheck action set <name>      # Set active action
./aicheck action complete        # Complete action
./aicheck action list           # List all actions
./aicheck action status         # Detailed status

# MCP commands (simplified names in v7.4.0)
./aicheck mcp setup        # Interactive MCP setup
./aicheck mcp validate     # Check MCP headers
./aicheck mcp hook         # Install git hook
```

### Version Release Process
1. Update `AICHECK_VERSION` in `aicheck` (line ~19)
2. Update `README.md` title and "What's New" section
3. Test with `bash -n aicheck` and `./test-all-modules.sh`
4. Commit with descriptive message
5. Push to main branch (installer pulls from GitHub)

## Critical Implementation Details

### Bash Compatibility
- **Bash 3.2 compatible** for macOS support
- No `${var,,}` lowercase expansion - use `tr '[:upper:]' '[:lower:]'`
- macOS sed requires `sed -i ""` not `sed -i`
- Always quote variables: `"$var"` not `$var`
- Use `local` only inside functions

### Module Dependencies
When modules call each other:
1. UI modules (colors, output) are loaded first
2. Core modules depend on UI
3. All other modules depend on core
4. Circular dependencies prevented by load order

### State Synchronization
Three sources must stay synchronized:
1. `.aicheck/current_action` file
2. `ActiveAction` status in `.aicheck/actions_index.md`
3. Individual `status.txt` files

The `fix_multiple_active_actions()` function handles conflicts.

### Error Patterns
- Empty grep patterns when `$current_action` is "None" - check with `[ "$current_action" != "None" ]`
- Integer expression errors from `grep -c` - pipe through `tr -d '\n'`
- Module not found warnings are non-fatal - inline definitions used as fallback

## Testing Strategy

### Module Tests
- Each module should be independently testable
- Use `test-all-modules.sh` for comprehensive testing
- Modules must handle missing dependencies gracefully

### Integration Tests
1. Create test directory
2. Run installer
3. Test all commands
4. Verify MCP integration
5. Check state management

### Edge Cases to Test
- Empty actions_index.md
- current_action = "None"
- Missing module files
- Corrupted state files
- Multiple active actions

## Recent Changes (v7.4.0)

### Simplified Commands
- Removed aliases: `ACTIVE`→`active`, `Complete`→`complete`, `--version`
- Consolidated action commands under parent `action` command
- Renamed MCP commands: `edit`→`setup`, `install-hook`→`hook`

### Enhanced Compliance
- MCP headers now include active action reminder
- Clear instructions if work doesn't match action
- Forces AI to use MCP tools for compliance checking

### Bug Fixes
- Fixed integer expression errors in grep commands
- Fixed missing `check_compliance` function
- Fixed empty grep patterns when current_action is "None"
- Added GRAY color definition for neon purple-gray output