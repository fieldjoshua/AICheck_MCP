# AICheck MCP Server

This MCP (Model Context Protocol) server provides tools that integrate Claude with the AICheck governance system. It allows Claude to interact with and enforce the rules defined in RULES.md.

## Purpose

The AICheck MCP server enables Claude to:

1. Read and understand the AICheck rules
2. Work with ACTIONS according to the AICheck governance system
3. Track current ACTIONS and their status
4. Create proper documentation for Claude interactions
5. Follow the proper ACTION management workflow

## Setup

1. Install dependencies:
   ```
   cd .mcp/server
   npm install
   ```

2. Make the server executable:
   ```
   chmod +x index.js
   ```

3. Register the MCP server with Claude:
   ```
   claude mcp add aicheck --type stdio --command node --args ["/path/to/your/project/.mcp/server/index.js"]
   ```

## Available Resources

The MCP server provides the following resources:

- `aicheck/rules`: The rules governing the AICheck system
- `aicheck/actions_index`: The index of all actions in the project
- `aicheck/current_action`: The currently active action

## Available Tools

The MCP server provides the following tools:

- `aicheck.getCurrentAction`: Get the currently active action
- `aicheck.listActions`: List all actions in the project
- `aicheck.getActionPlan`: Get the plan for a specific action
- `aicheck.createActionDirectory`: Create a new action directory with the required structure
- `aicheck.writeActionPlan`: Write an action plan (requires human approval)
- `aicheck.setCurrentAction`: Set the currently active action (requires human approval)
- `aicheck.logClaudeInteraction`: Log a Claude interaction for the current action

## Integration with Claude

Claude can use these tools to follow the AICheck governance system. For example:

1. Get the currently active action:
   ```
   aicheck.getCurrentAction()
   ```

2. Create a new action:
   ```
   aicheck.createActionDirectory({ action: "MyNewAction" })
   ```

3. Log a Claude interaction:
   ```
   aicheck.logClaudeInteraction({
     purpose: "Generate error handler base classes",
     prompt: "I need help creating error handler classes...",
     response: "Here's how you can implement error handlers...",
     verification: "The code passes all unit tests"
   })
   ```

## Permissions and Approval

Some tools require human approval:

- `aicheck.writeActionPlan`: Writing or changing an action plan requires approval
- `aicheck.setCurrentAction`: Changing the active action requires approval

These tools will note that approval is required and will not take effect until approved by a human.