# AICheck MCP

AICheck is a Multimodal Control Protocol that helps Claude Code follow structured development practices.

## Installation (3 Steps)

### Step 1: Clone the Repository

```bash
# Clone the AICheck MCP repository
git clone https://github.com/fieldjoshua/AICheck_MCP.git
cd AICheck_MCP
```

### Step 2: Run Setup Scripts

```bash
# Run all setup scripts
./setup_aicheck_complete.sh  # Core AICheck setup
./setup_aicheck_hooks.sh     # Git hooks setup
./setup_aicheck_status.sh    # Status display setup

# Load shell configuration to activate commands
source ~/.zshrc  # Or source ~/.bashrc for Bash users
```

### Step 3: Activate in Claude

```bash
# Generate and copy activation text
./activate_aicheck_claude.sh
# Copy text from opened file, then paste to Claude in a new conversation
```

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

## Using in Other Projects

To use AICheck in a different project:

1. Copy the setup scripts to your project:
```bash
cp AICheck_MCP/*.sh /path/to/your/project/
```

2. Run the setup scripts in your project:
```bash
cd /path/to/your/project/
./setup_aicheck_complete.sh
./setup_aicheck_hooks.sh
./setup_aicheck_status.sh
```

3. Activate as described above.

## Detailed Documentation

For more details about AICheck, see [.aicheck/rules.md](.aicheck/rules.md) after installation.

---

🤖 Created with [Claude Code](https://claude.ai/code)