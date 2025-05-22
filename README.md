# AICheck MCP - Multimodal Control Protocol

AICheck MCP is a system for AI-assisted development that provides structure, documentation, and control for working with Claude Code and other AI systems.

## One-Command Installation

Install AICheck MCP in any project with a single command:

```bash
curl -s https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/ultimate_aicheck_installer.sh | bash
```

This will:
1. Create the AICheck directory structure and files
2. Set up git hooks for AICheck compliance
3. Create the Claude Code activation script
4. **Install the complete AICheck MCP server infrastructure**

## Next Steps

After installation, follow these steps for full integration:

### 1. Set up MCP Server (New!)
```bash
./.mcp/setup.sh
```

This sets up the Model Context Protocol server that gives Claude direct access to AICheck governance tools.

### 2. Activate Claude Code Integration
```bash
./activate_aicheck_claude.sh
```

This copies the AICheck activation prompt to your clipboard. Paste this into a new Claude Code conversation to activate AICheck.

## MCP Server Integration

The installer now includes a complete MCP server that provides Claude with direct access to:

- **aicheck.getCurrentAction** - Get the currently active action
- **aicheck.listActions** - List all actions in the project  
- **aicheck.getActionPlan** - Get the plan for a specific action
- **aicheck.setCurrentAction** - Set the currently active action (requires approval)
- **aicheck.logClaudeInteraction** - Log Claude interactions for the current action

Plus access to AICheck resources:
- AICheck rules and governance
- Actions index and status
- Current action details

This enables Claude Code to directly interact with the AICheck governance system without requiring manual command execution. See [MCP_SETUP_GUIDE.md](MCP_SETUP_GUIDE.md) for detailed instructions.

## What is AICheck MCP?

AICheck MCP is a structured protocol for AI-assisted development that helps Claude Code follow consistent patterns:

- Documentation-first approach
- Action-based development workflow
- Dependency tracking
- Git integration
- Built-in command line tools

## AICheck Command Reference

AICheck provides a command-line interface for managing actions:

```bash
# Show current action status
./aicheck status

# Create a new action
./aicheck action new ActionName

# Set the active action
./aicheck action set ActionName

# Complete an action
./aicheck action complete [ActionName]

# Add external dependency
./aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]

# Add internal dependency
./aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]

# Toggle system maintenance mode
./aicheck exec

# Migrate existing PascalCase action directories to kebab-case
./migrate_action_names.sh
```

## Naming Conventions

AICheck uses **kebab-case** for action directory names:
- ✅ `my-action`, `setup-database`, `create-user-interface`
- ❌ `MyAction`, `SetupDatabase`, `CreateUserInterface`

If you have existing PascalCase directories, run the migration script:
```bash
./migrate_action_names.sh
```

## Documentation-First Development

AICheck follows a structured approach to development:

1. **Create an Action**: Define its purpose, requirements, and success criteria
2. **Write Tests First**: Follow test-driven development practices
3. **Implement with AI**: Let Claude Code work within clear boundaries
4. **Document Dependencies**: Track all external and internal dependencies
5. **Complete with Verification**: Ensure all requirements and tests pass

## Directory Structure

```
/
├── .aicheck/                          # AICheck system files
│   ├── actions/                       # All PROJECT ACTIONS
│   │   └── [action-name]/             # Individual ACTION directory
│   │       ├── [action-name]-plan.md  # ACTION PLAN
│   │       └── supporting_docs/       # ACTION-specific documentation
│   ├── current_action                 # Current active action
│   ├── actions_index.md               # Master list of all actions
│   ├── rules.md                       # AICheck system rules
│   └── templates/                     # Templates for prompts and actions
├── documentation/                     # Permanent documentation
├── tests/                             # Test suite
```

## Troubleshooting

If you encounter any issues with the installation:

1. **Missing `./aicheck` executable**: Re-run the installer or check file permissions:
   ```bash
   curl -s https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/ultimate_aicheck_installer.sh | bash
   chmod +x ./aicheck
   ```

2. **PascalCase action directories**: Run the migration script:
   ```bash
   ./migrate_action_names.sh
   ```

3. **Permission issues**: Make sure you have the necessary permissions in your project directory

4. **Conflicting directories**: Check for existing `.aicheck` directory that might conflict

5. **Installation failures**: Run the script directly after downloading if curl pipe fails:
   ```bash
   curl -s -o install.sh https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/ultimate_aicheck_installer.sh
   chmod +x install.sh
   ./install.sh
   ```

6. **Claude Code integration**: If Claude Code doesn't recognize AICheck, try running `./aicheck status` first to verify your installation

## Learn More

After installation, read `.aicheck/rules.md` for complete documentation.

## License

MIT License