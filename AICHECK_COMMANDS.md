# AICheck Commands Reference

## Core Commands

### `./aicheck status`
Shows detailed status of current action, including:
- Current active action name and status
- Progress percentage
- Plan file location
- Context health and pollution score
- Git status and recent commits
- Boundary violations

### `./aicheck new <ActionName>`
Creates a new action with:
- Action directory structure
- Status file
- Plan template
- Progress tracking
- Updates actions index

### `./aicheck ACTIVE <ActionName>`
Sets an action as the current active action:
- Enforces single active action rule
- Updates current_action file
- Updates actions_index.md status
- Marks other actions as "In Progress"

### `./aicheck complete`
Completes the current active action:
- Runs smart completion checks based on project type
- Checks tests, dependencies, code quality
- Validates git status
- Updates action status to completed
- Resets current action to None

### `./aicheck focus`
Checks for scope creep and boundary violations:
- Runs enforce_action_boundaries
- Shows files modified outside expected scope
- Helps maintain single-action focus

### `./aicheck stuck`
Helper command when confused:
- Shows current status
- Provides quick command suggestions
- Helps get back on track

### `./aicheck cleanup`
Interactive cleanup and optimization:
- Validates RULES compliance
- Fixes multiple active actions
- Cleans up old context
- Archives completed actions
- Optimizes git status

### `./aicheck deploy`
Pre-deployment validation:
- Checks all tests pass
- Validates dependencies
- Ensures clean git status
- Checks for security issues
- Deployment readiness assessment

### `./aicheck auto-iterate`
Automated development cycles:
- Sets goal
- Runs tests
- Fixes issues
- Repeats until goal met
- Requires approval for each iteration

## MCP Integration Commands

### `./aicheck mcp edit`
Sets up MCP headers for AI coding:
- Adds appropriate headers to files
- Configures scoping and validation
- Enables AI governance

### `./aicheck edit claude <file>`
Opens file in Claude Desktop with MCP integration

### `./aicheck edit cursor <file>`
Opens file in Cursor with MCP integration

## Context Management

### `./aicheck context <subcommand>`
- `check` - Analyzes context pollution
- `clear` - Archives old interactions
- `compact` - Auto-compacts context
- `analyze` - Shows usage patterns
- `costs` - Analyzes AI costs
- `boundaries` - Checks scope violations

## Dependency Management

### `./aicheck dependency <subcommand>`
- `add <name> <version> <justification>` - Adds dependency
- `check` - Validates dependencies
- `list` - Shows current dependencies

## Progress Tracking

### `./aicheck progress <percent>`
Updates progress percentage for current action

## Usage Analytics

### `./aicheck usage`
Shows AI usage statistics and costs:
- Token usage
- Cost estimates
- Usage patterns
- Optimization suggestions

## Installation & Setup

### `./aicheck install-hook`
Installs smart pre-commit hook that:
- Validates single active action
- Checks for scope creep
- Ensures tests pass
- Validates dependencies

### `./aicheck version`
Shows version info and available commands

## Advanced Commands

### `./aicheck action <subcommand>`
- `current` - Shows current action
- `prompt` - Gets action-specific AI prompt

### `./aicheck validate`
Runs comprehensive validation:
- Single active action rule
- State file consistency
- Index synchronization
- Dependency compliance

### `./aicheck protect`
Protects critical files from modification:
- Adds files to protected list
- Prevents accidental changes
- Maintains production safetyan1