# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository follows the AICheck system, a documentation-first, test-driven development approach with clear rules for managing actions. The project emphasizes thorough planning, comprehensive testing, and detailed documentation.

## Core Principles

1. **Documentation-First**: All implementations must follow approved PLAN documents
2. **Test-Driven Development**: Tests must be created and approved before implementation
3. **Action-Based Development**: Work is organized into discrete ACTIONS with clear boundaries and objectives

## Directory Structure

```
/
├── .aicheck/
│   ├── actions/                      # All PROJECT ACTIONS
│   │   └── [action-name]/            # Individual ACTION directory
│   │       ├── [action-name]-plan.md # ACTION PLAN (requires approval)
│   │       └── supporting_docs/      # ACTION-specific documentation
│   ├── current_action                # Current ActionActivity for EDITOR
│   ├── actions_index.md              # Master list of all ACTIONS
│   └── rules.md                      # Project rules
├── .claude/                          # Claude-specific configuration
│   └── commands/                     # Custom Claude commands
├── .mcp/                             # MCP server for AICheck integration
│   ├── server/                       # MCP server implementation
│   └── mcp.json                      # MCP configuration
├── documentation/                    # Permanent PROJECT documentation
└── tests/                            # Permanent test suite
```

## Claude Code's Role

Claude Code functions as an AI engineer within the AICheck workflow:
- Generate implementation code from PLAN specifications
- Create comprehensive test suites following test-driven methodology
- Provide code review and optimization suggestions
- Enhance/generate documentation based on implementation details
- Assist with migrations and refactoring
- Support debugging complex issues

## Custom Claude Commands

The AICheck system includes custom Claude commands to help interact with the governance system:

### Action Management

- `/actionindex` - Lists all actions in the project with their status and descriptions
- `/AA` - Shows the currently active action and a brief summary of its details
- `/actionnew <instruction>` - Proposes the creation of a new Action directory and PLAN based on instructions
- `/AASet` - Suggests which Action should be the Active Action based on chat context

### Claude Interaction Logging

- `/claude-log <purpose>` - Logs a Claude interaction for the current action, capturing the conversation

### AICheck System Management

- `/aicheck rules` - Shows the AICheck governance rules from rules.md
- `/aicheck status` - Displays overall status of the AICheck system, including actions and verification
- `/aicheck verify` - Verifies that the AICheck structure follows requirements
- `/aicheck testing` - Verifies test-first concept for current Active Action is consistent with objectives
- `/aicheck exec` - Temporarily suspends the ActiveAction for a back and forth session (toggle)

### System Operations

- `/githubupdate` - Enters AICheck exec mode and helps push all recent changes to GitHub
- `/vulnerabilities` - Enters AICheck exec mode and analyzes GitHub vulnerabilities and codebase issues
- `/audit <instructions>` - Enters AICheck exec mode and performs a detailed audit based on instructions

## Exec Mode

AICheck includes an "exec mode" that temporarily suspends the Active Action governance system for specific system-level operations. In exec mode:

- The Active Action is temporarily suspended
- Operations are not tracked against a specific ACTION
- System-level tasks can be performed (GitHub updates, audits, vulnerability analysis)
- Return to normal ACTION-based workflow with `/aicheck exec` again

## MCP Integration

The AICheck system integrates with Claude through the Model Context Protocol (MCP). This provides Claude with tools to interact with the AICheck governance system:

### Available Resources

- `aicheck/rules`: The rules governing the AICheck system
- `aicheck/actions_index`: The index of all actions in the project
- `aicheck/current_action`: The currently active action

### Available Tools

- `aicheck.getCurrentAction`: Get the currently active action
- `aicheck.listActions`: List all actions in the project
- `aicheck.getActionPlan`: Get the plan for a specific action
- `aicheck.createActionDirectory`: Create a new action directory with the required structure
- `aicheck.writeActionPlan`: Write an action plan (requires human approval)
- `aicheck.setCurrentAction`: Set the currently active action (requires human approval)
- `aicheck.logClaudeInteraction`: Log a Claude interaction for the current action

### MCP Server Setup

To set up the AICheck MCP server:

1. Run the setup script:
   ```
   .mcp/setup.sh
   ```

2. Verify the setup:
   ```
   claude mcp list
   ```

## Action Workflow

1. Each ACTION requires approved PLAN documentation before implementation
2. Tests must be written before implementation code
3. All work must adhere to language-specific best practices
4. Documentation should be continuously updated
5. Only work on the ActiveAction identified in `.aicheck/current_action`

## Claude Code Boundaries

**ALLOWED without approval:**
- Implementing code based on approved PLAN
- Writing unit tests for defined functionality
- Refactoring code for readability (same functionality)
- Adding logging statements
- Updating comments and docstrings
- Creating helper functions within ACTION scope

**REQUIRES approval:**
- Changing the ActiveAction
- Creating a new Action
- Making substantive changes to any Action
- Modifying any Action Plan
- Adding new dependencies

## Documentation Requirements

- All implementations must document changes in supporting_docs
- Claude Code interactions must be logged in supporting_docs/claude-interactions/
- Code must include appropriate comments and docstrings
- Updates to ACTION status required after significant changes

## Testing Standards

- Follow test-driven development approach
- Create tests for core functionality, boundary conditions, integration, and error handling
- Maintain test organization according to project structure
- Ensure proper test coverage

## Language-Specific Standards

### Python Standards
- Follow PEP 8 with 120-character line length
- Use type hints for all new functions
- Docstrings required for all public functions
- Use Black for code formatting
- Import order: standard library → third-party → local application

### JavaScript/TypeScript Standards
- Use ESLint with the project's configuration
- Prefer TypeScript for new files
- Use Jest for testing
- Follow Airbnb style guide with modifications
- Prefer async/await over promises
- Use functional programming patterns where appropriate

## Error Handling

All errors must include:
- Error code for programmatic handling
- Human-readable message
- Suggested resolution steps
- Context about where the error occurred
- Appropriate logging level

## Implementation Standards

- Never hard-code credentials or secrets
- Use environment variables for configuration
- Document all environment variables
- Follow atomic commit practices
- Maintain clear error handling and logging

## Test Locations

- Product functionality unit tests → tests/unit/
- Integration tests → tests/integration/
- E2E tests → tests/e2e/
- Process-specific temporary tests → .aicheck/actions/[action-name]/supporting_docs/process-tests/

## Documentation Organization

- ACTION process documentation → .aicheck/actions/[action-name]/supporting_docs/
- Product documentation → /documentation/[CATEGORY]/
- API documentation → /documentation/api/
- Architecture documentation → /documentation/architecture/