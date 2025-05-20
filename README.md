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
   git clone https://github.com/yourusername/AICheck_MCP.git
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

Claude can interact with the AICheck system using the MCP tools:

1. Get the currently active action:
   ```
   aicheck.getCurrentAction()
   ```

2. List all actions:
   ```
   aicheck.listActions()
   ```

3. Create a new action directory:
   ```
   aicheck.createActionDirectory({ action: "MyNewAction" })
   ```

4. And more (see CLAUDE.md for details)

## Project Structure

The repository is organized according to the AICheck system:

```
/
├── .aicheck/              # AICheck governance system
├── .mcp/                  # MCP integration for Claude
├── documentation/         # Permanent project documentation
└── tests/                 # Test suite
```

## MCP Integration

This repository includes an MCP server (`/.mcp/server/`) that provides Claude with tools to interact with the AICheck governance system. For details on the MCP integration, see:

- `.mcp/server/README.md`: Documentation for the MCP server
- `CLAUDE.md`: Instructions for Claude when working with this repository

## License

[MIT License](LICENSE)

## Acknowledgments

- [Anthropic](https://www.anthropic.com/) for Claude and the MCP protocol
- [Model Context Protocol](https://modelcontextprotocol.io/) for the standardized interface