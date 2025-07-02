# AICheck Action Terminology Clarification

## The Problem
AICheck v7.0.0 has confusion between multiple terms that should represent the same concept:
- **ActiveAction** - Status in actions_index.md
- **Active** - Alternative status (should not be used)
- **current_action** - File storing the currently active action name

## The Solution
AICheck enforces **ONE and ONLY ONE** active action at a time:

1. **ActiveAction** is the ONLY valid status for an active action
2. The `.aicheck/current_action` file MUST match the action with ActiveAction status
3. All other actions MUST have status: "Not Started", "In Progress", or "Completed"

## Status Values
- **Not Started** - Action created but work hasn't begun
- **In Progress** - Work started but action is not currently active
- **ActiveAction** - THE currently active action (only one allowed)
- **Completed** - Action finished

## Enforcement
- `./aicheck ACTIVE <name>` - Sets ONE action as ActiveAction, all others become "In Progress"
- `./aicheck cleanup` - Fixes multiple active actions
- Validation runs before commands to detect violations

## Key Principle
**There is NO "current action" separate from the ActiveAction. They are the same thing.**

When you set an action as ACTIVE:
1. Its status becomes "ActiveAction" 
2. It's recorded in `.aicheck/current_action`
3. ALL other actions lose ActiveAction status

This ensures focused, single-action development as per AICheck principles.