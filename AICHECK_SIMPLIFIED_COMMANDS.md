<!-- MCP: AICheck_Planner -->
<!-- Action: integration-test -->
<!-- DateTime: 2025-07-07 11:10:00 PDT -->
<!-- Task: Plan command simplification -->
<!-- File: AICHECK_SIMPLIFIED_COMMANDS.md -->
<!-- Before coding, outline the steps you plan to take to complete this task. -->
<!-- Follow the approved action plan and document any scope changes. -->
<!--
<!-- IMPORTANT: Current active action is 'integration-test'
<!-- If your work is not reflective of this active action, you must either:
<!--   1. Edit the current action plan (requires approval)
<!--   2. Create a new action (requires approval)
<!--   3. Enter exec mode for temporary work (requires approval)
<!-- Use MCP tools to check current action and ensure compliance.
-->

# AICheck Simplified Command Structure

## Essential Commands (Keep these for daily use)

### `./aicheck status`
Complete overview of current state - shows active action, progress, git status, and warnings

### `./aicheck new <name>`
Quick way to create and switch to a new action

### `./aicheck complete`
Finish current action with smart validation checks

### `./aicheck stuck`
Get help when confused - combines status + suggestions

### `./aicheck cleanup`
Fix issues, optimize context, ensure compliance

## Commands to Consolidate

### Remove these redundant aliases:
- `iterate`, `auto` → Keep only `auto-iterate`
- `ACTIVE`, `Active` → Keep only lowercase `active`
- `Complete`, `COMPLETE` → Keep only lowercase `complete`
- `--version` → Keep only `version`

### Move under parent commands:

**Action management** → `./aicheck action <subcommand>`
- `action new <name>` - Create new action
- `action set <name>` - Set active action (replaces ACTIVE)
- `action complete` - Complete current action
- `action list` - Show all actions
- `action status` - Detailed action status

**Context management** → Already grouped properly
- `context check` - Analyze pollution
- `context clean` - Archive old context
- `context compact` - Auto-compact

**MCP operations** → Simplify names
- `mcp setup` - Interactive setup (rename from 'edit')
- `mcp validate` - Check headers
- `mcp hook` - Install git hook (rename from 'install-hook')

## Internal Functions (Not user commands)

These are called automatically and don't need to be user-facing:
- `validate_single_active_action()` - Runs before every command
- `detect_project_environment()` - Auto-detects project type
- `enforce_action_boundaries()` - Called by focus/stuck
- `run_smart_completion_checks()` - Called by complete
- `fix_multiple_active_actions()` - Called by cleanup

## Recommended Simplifications

1. **Merge similar functionality:**
   - `stuck` could include `focus` output
   - `cleanup` could auto-run `context compact`
   - `complete` could show final `status`

2. **Auto-detect more:**
   - `edit` command could auto-detect Claude vs Cursor
   - `deploy` could auto-detect deployment type
   - MCP setup could auto-configure based on project

3. **Hide advanced features:**
   - Move `dependency`, `guardian`, `exec` to advanced help
   - Internal validation functions don't need command exposure
   - Progress tracking could be automatic

## Minimal Command Set

For new users, just these 5 commands:
```bash
./aicheck new <name>     # Start new task
./aicheck status         # Where am I?
./aicheck stuck          # Get help
./aicheck complete       # Finish task
./aicheck cleanup        # Fix issues
```

Everything else can be discovered through help or run automatically.

## AI Editor Compliance

When files are opened with `./aicheck edit`, MCP headers now include:
- Current active action name
- Compliance reminder that work must match the action
- Options if work doesn't match (edit action, new action, or exec mode)
- Reminder to use MCP tools to check compliance

This ensures AI editors are constantly aware of the current action context and enforce single-action focus.