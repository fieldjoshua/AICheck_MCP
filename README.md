# AICheck MCP

AICheck MCP is a governance system for AI-assisted software development projects that integrates with Claude through the Model Context Protocol (MCP).

## Overview

AICheck is a documentation-first, test-driven development approach with clear rules for managing actions. The system emphasizes thorough planning, comprehensive testing, and detailed documentation, organized into discrete ACTIONS.

This repository integrates the AICheck governance system with Claude through the Model Context Protocol (MCP), allowing Claude to interact with and enforce the AICheck rules.

## Core Principles

1. **Documentation-First**: All implementations must follow approved PLAN documents
2. **Test-Driven Development**: Tests must be created and approved before implementation
3. **Action-Based Development**: Work is organized into discrete ACTIONS with clear boundaries and objectives
4. **Governance**: Clear rules for what requires approval and what can be done autonomously

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- Claude CLI (`npm install -g @anthropic-ai/claude-cli`)

### Installation

1. Clone this repository:
   ```
   git clone https://github.com/fieldjoshua/AICheck_MCP.git
   cd AICheck_MCP
   ```

2. Run the setup script:
   ```
   .mcp/setup.sh
   ```

3. Verify the setup:
   ```
   claude mcp list
   ```

## Using AICheck with Claude

Claude integrates with the AICheck system in multiple ways:

### Custom Claude Commands

The AICheck system includes custom Claude commands for direct interaction:

```
# Action Management
/action list                  # List all actions in the project
/action current               # Show the currently active action
/action new <action_name>     # Create a new action (requires approval)
/action plan <action_name>    # Show or create an action plan
/action set <action_name>     # Set the currently active action (requires approval)

# Claude Interaction Logging
/claude-log <purpose>         # Log a Claude interaction for the current action

# AICheck System Management
/aicheck rules                # Show the AICheck rules
/aicheck status               # Show the status of the AICheck system
/aicheck verify               # Verify the AICheck structure
```

### MCP Tools

Claude can also interact with the AICheck system using the MCP tools:

```javascript
// Get the currently active action
aicheck.getCurrentAction()

// List all actions
aicheck.listActions()

// Create a new action directory
aicheck.createActionDirectory({ action: "MyNewAction" })

// Write an action plan (requires approval)
aicheck.writeActionPlan({ action: "MyAction", content: "# Action Plan..." })

// Set the currently active action (requires approval)
aicheck.setCurrentAction({ action: "MyAction" })

// Log a Claude interaction
aicheck.logClaudeInteraction({
  purpose: "Generate error handler",
  prompt: "I need help with...",
  response: "Here's the solution..."
})
```

See CLAUDE.md for complete details on available commands and tools.

## Project Structure

The repository is organized according to the AICheck system:

```
/
├── .aicheck/              # AICheck governance system
├── .claude/               # Claude-specific configuration and commands
├── .mcp/                  # MCP integration for Claude
├── documentation/         # Permanent project documentation
└── tests/                 # Test suite
```

## MCP Integration

This repository includes an MCP server (`/.mcp/server/`) that provides Claude with tools to interact with the AICheck governance system. For details on the MCP integration, see:

- `.mcp/server/README.md`: Documentation for the MCP server
- `CLAUDE.md`: Instructions for Claude when working with this repository

## Custom Commands Integration

The AICheck system includes custom Claude commands in the `.claude/commands/` directory. These commands allow Claude to interact directly with the AICheck system without using MCP tools.

## License

[MIT License](LICENSE)

## Acknowledgments

- [Anthropic](https://www.anthropic.com/) for Claude and the MCP protocol
- [Model Context Protocol](https://modelcontextprotocol.io/) for the standardized interface