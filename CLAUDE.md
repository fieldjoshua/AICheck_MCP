# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **AICheck MCP development repository** - the project that creates the AICheck governance system itself. When working on this codebase, we are developing the tools and systems that other projects will use, not following AICheck governance (which would create circular dependencies).

## Architecture

### Core Components
- **`./aicheck`** - Main bash script providing all AICheck functionality
- **Installation System** - Multiple installer scripts for different deployment scenarios
- **MCP Integration** - Server implementations in `MCP/` directories  
- **Rules Engine** - `RULES.md` defines the governance framework
- **Templates** - AI prompt templates in `templates/claude/`

### Key Scripts
```bash
./aicheck                    # Main command script (5000+ lines of bash)
./install.sh                # Primary installer with MCP configuration
./activate_aicheck_claude.sh # Claude MCP integration activation
./fix_permissions.sh         # Permission repair utility
./migrate_action_names.sh    # Migration utilities

# New Auto-Iterate Mode (v6.0.0)
./aicheck auto-iterate      # Goal-driven test-fix-test cycles
```

## Development Commands

### Testing
```bash
npm test                     # Node.js components test
echo 'Tests passed!' && exit 0  # Current test stub
```

### Installation Testing
```bash
./install.sh                # Test main installer
./install_local.sh          # Test local installation
```

### Validation
```bash
./aicheck-mcp-check         # MCP integration validation
bash install.sh            # Full installation test
```

## Development Guidelines

### Bash Development (Primary Language)
- Main `./aicheck` script is complex bash with 5000+ lines
- Use `set -e` for error handling
- Color-coded output using terminal escape codes
- Function-based architecture with clear separation
- Version management and update checking built-in

### Installation Script Patterns
- Support multiple installation modes (fresh, update, repair)
- MCP server configuration with conflict resolution
- Comprehensive error handling and rollback
- User-friendly progress indicators and success messages
- Automatic backup of existing configurations

### MCP Integration Architecture
- Separate MCP server implementations for different contexts
- Unique server naming to prevent conflicts across projects
- Resource exposure for rules, actions, and status
- Tool integration for all AICheck commands

## Testing Strategy

Since this creates tools for other projects:
- **Integration Testing**: Install in test directories and verify functionality
- **Cross-Platform Testing**: Ensure scripts work across different environments  
- **MCP Testing**: Verify Claude integration works correctly
- **User Experience Testing**: Ensure installation is smooth and error messages are helpful

## File Organization

### Core Files (Root Level)
- `RULES.md` - The governance framework (1000+ lines)
- `README.md` - Public-facing documentation
- `CHANGELOG.md` / `CHANGELOG_v5.md` - Version history
- Installation guides and quick references

### Development Directories
- `MCP/` - MCP server implementations
- `templates/` - AI prompt templates  
- `documentation/` - Project documentation
- `tests/` - Test suites and fixtures
- Various test directories for installation validation

### Generated/Working Directories
- `.aicheck/` - Created when AICheck is used (not for development)
- `node_modules/` - npm dependencies
- Various backup and temporary files

## Special Considerations

### Circular Dependency Avoidance
- This project creates AICheck but should NOT be subject to AICheck governance during development
- Use standard git workflow, not AICheck action workflow
- Focus on creating robust tools rather than following the rules those tools enforce

### Installation Complexity
- Multiple installer variants handle different scenarios
- MCP configuration must work across different Claude setups
- Error recovery and rollback capabilities essential
- User experience is critical for adoption

### Backward Compatibility
- Support migration from older AICheck versions
- Handle existing MCP configurations gracefully
- Provide clear upgrade paths and documentation

## Auto-Iterate Mode Development Notes

### New Feature (v6.0.0)
Auto-iterate mode enables goal-driven development cycles:
- **Goal Definition**: AI must propose specific, measurable objectives
- **Human Approval**: Required before any iteration begins
- **Action Integration**: Templates automatically added to active action directories
- **Git Safety**: Human approval required for all commits

### Implementation Details
- **Function**: `auto_iterate()` in main aicheck script
- **Template**: `templates/claude/auto-iterate-action.md`
- **Workflow**: Goal definition → Approval → Execution → Git approval
- **Files Generated**: 
  - `.aicheck/auto-iterate-goals.md` (goals and approval)
  - `.aicheck/auto-iterate-session-[ID].log` (detailed log)
  - `.aicheck/auto-iterate-changes-[ID].md` (change tracking)
  - `.aicheck/auto-iterate-summary-[ID].md` (final report)

### Usage for AI Development
When working on AICheck itself, auto-iterate can be used for:
- Complex test failure scenarios  
- Multi-step debugging processes
- Refactoring with test validation
- Integration testing cycles
