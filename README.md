# AICheck MCP

AICheck is a Multimodal Control Protocol that helps Claude Code follow structured development practices.

## Quick Start (1 Simple Step)

```bash
# Download and run the installer (v1.0)
curl -s "https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/setup.sh?$(date +%s)" | bash
```

That's it! The installer will:
1. Set up the AICheck structure
2. Install git hooks
3. Configure status display
4. Automatically copy activation text to clipboard
5. Tell you when it's ready to paste to Claude

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

## Troubleshooting

If commands aren't working, try:
```bash
source ~/.zshrc  # Or source ~/.bashrc for Bash users
```

If you don't see the AICheck activation text copied to your clipboard, run:
```bash
./activate_aicheck_claude.sh
```

## Detailed Documentation

For more details about AICheck, see [.aicheck/rules.md](.aicheck/rules.md) after installation.

---

🤖 Created with [Claude Code](https://claude.ai/code)