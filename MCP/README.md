# AICheck MCP Project

This project uses AICheck Multimodal Control Protocol for AI-assisted development.

## Claude Code Commands

Claude Code now supports the following AICheck slash commands:

- `/aicheck action new ActionName` - Create a new action
- `/aicheck action set ActionName` - Set the current active action
- `/aicheck action complete [ActionName]` - Complete an action (requires dependency verification)
- `/aicheck exec` - Toggle exec mode for system maintenance
- `/aicheck status` - Show the current action status
- `/aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `/aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency

## Dependency Verification

Before an action can be completed, its dependencies must be verified:
1. External dependencies must be recorded in the dependency index
2. Internal dependencies between actions must be documented
3. Dependency verification happens automatically when completing an action

## Project Structure

The AICheck system follows a structured approach to development:

- `.aicheck/` - Contains all AICheck system files
  - `actions/` - Individual actions with plans and documentation
  - `templates/` - Templates for Claude prompts
  - `rules.md` - AICheck system rules
- `documentation/` - Project documentation
  - `dependencies/` - Dependency documentation and index
- `tests/` - Test suite

## Getting Started

1. Review the AICheck rules in `.aicheck/rules.md`
2. Create a new action with `/aicheck action new ActionName`
3. Plan your action in the generated plan file
4. Set it as your active action with `/aicheck action set ActionName`
5. Implement according to the plan
6. Document dependencies with `/aicheck dependency add` or `/aicheck dependency internal`
7. Complete the action with `/aicheck action complete`

## Documentation-First Approach

AICheck follows a documentation-first, test-driven approach:

1. Document your plan thoroughly before implementation
2. Write tests before implementing features
3. Keep documentation updated as the project evolves
4. Document all dependencies
5. Migrate completed action documentation to the central documentation directories
