# AICheck MCP 

AICheck is a Multimodal Control Protocol (MCP) for AI-assisted development, designed to help Claude Code follow consistent development practices and documentation standards.

## What is AICheck?

AICheck provides a structured framework for AI development, featuring:

- Documentation-first approach with clear rules and templates
- Action-based work organization with planning and tracking
- Test-driven development practices
- Dependency management and tracking
- Git integration with helpful hooks
- Persistent status display

## Installation

### Option 1: Complete Setup (Recommended)

To install the full AICheck system in your project:

```bash
# Clone this repository
git clone https://github.com/fieldjoshua/AICheck_MCP.git

# Copy the setup script to your project
cp AICheck_MCP/setup_aicheck_complete.sh /path/to/your/project/

# Navigate to your project
cd /path/to/your/project

# Run the setup script
chmod +x setup_aicheck_complete.sh
./setup_aicheck_complete.sh
```

This will:
- Create the AICheck directory structure
- Add command templates and hooks
- Configure Claude Code integration
- Set up git hooks and status display

### Option 2: Individual Components

If you prefer to install specific components:

```bash
# For basic AICheck setup
./setup_aicheck.sh

# For git hooks
./setup_aicheck_hooks.sh

# For status display
./setup_aicheck_status.sh
```

## Using AICheck with Claude Code

After installation:

1. Run `./activate_aicheck_claude.sh` to generate a template prompt
2. Start a new Claude Code conversation
3. Paste the generated prompt as your first message
4. Claude will recognize the AICheck system and follow its rules

## AICheck Commands

AICheck provides these slash commands for Claude Code:

- `/aicheck action new ActionName` - Create a new action
- `/aicheck action set ActionName` - Set the current active action  
- `/aicheck action complete` - Complete current action with dependency verification
- `/aicheck dependency add NAME VERSION JUSTIFICATION` - Document external dependency
- `/aicheck dependency internal DEP_ACTION ACTION TYPE` - Document action dependency
- `/aicheck exec` - Toggle system maintenance mode
- `/aicheck status` - Show current action status

## Directory Structure

```
/
├── .aicheck/                      # AICheck system files
│   ├── actions/                   # Individual actions
│   ├── current_action             # Active action tracking
│   ├── rules.md                   # System rules
│   └── templates/                 # Claude prompt templates
├── documentation/                 # Project documentation
│   ├── api/                       # API docs
│   ├── dependencies/              # Dependency tracking
│   └── ...                        # Other documentation
└── tests/                         # Test suite
```

## Status Display

AICheck provides three ways to display status information:

1. **TMux Status Bar**: Shows in the status bar if using tmux
2. **Shell Prompt**: Integrates with your terminal prompt
3. **Command**: Run `aicheck_status` anytime

The status display shows:
- Current action and progress
- Dependency count
- Git branch and status
- Last commit information

## Documentation

AICheck follows a documentation-first approach:
1. Create a new action with `/aicheck action new`
2. Plan the action before implementation
3. Document dependencies as they're added
4. Complete actions with `/aicheck action complete`

## Requirements

- Bash-compatible shell
- Git (for hook functionality)
- TMux (optional, for status bar display)

## License

MIT

---

🤖 Created with [Claude Code](https://claude.ai/code)