# AICheck MCP

AICheck is a Multimodal Control Protocol that helps Claude Code follow structured development practices.

## Quick Start (3 Simple Steps)

```bash
# 1. Download the setup script
curl -O https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/setup_aicheck_complete.sh
chmod +x setup_aicheck_complete.sh

# 2. Run the script in your project folder
./setup_aicheck_complete.sh

# 3. Activate in your next Claude conversation
./activate_aicheck_claude.sh
# Copy the text that opens and paste it to Claude
```

That's it! Claude will now follow AICheck rules and understand commands like `/aicheck status`.

## What AICheck Does

AICheck gives Claude a structured workflow with:
- Action-based task management
- Documentation templates
- Dependency tracking
- Git hook suggestions
- Status display

## Commands You Can Use

After setup, Claude understands these commands:

```
/aicheck status                    # Show current action status
/aicheck action new ActionName     # Create a new action
/aicheck action set ActionName     # Switch to an action
/aicheck action complete           # Complete current action
/aicheck dependency add NAME VER   # Add external dependency
```

## Status Display

Run `aicheck_status` anytime to see:
- Current action and progress
- Git branch and status
- Last commit time

## Detailed Documentation

For more details about AICheck, see [.aicheck/rules.md](.aicheck/rules.md) after installation.

---

🤖 Created with [Claude Code](https://claude.ai/code)