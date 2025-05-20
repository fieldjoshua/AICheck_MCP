# AICheck MCP

## Setup

```bash
# Step 1: Get the files
git clone https://github.com/fieldjoshua/AICheck_MCP.git
cp AICheck_MCP/*.sh /path/to/your/project/
cd /path/to/your/project/

# Step 2: Install
./setup_aicheck_complete.sh
./setup_aicheck_hooks.sh
./setup_aicheck_status.sh
source ~/.zshrc
```

## Step 3: Activate Claude

Copy and paste this text to Claude in a new conversation:

```
# AICheck System Integration

I notice this project is using the AICheck Multimodal Control Protocol. Let me check the current action status.

I'll follow the AICheck workflow and adhere to the rules in `.aicheck/RULES.md`. This includes:

1. Using the slash commands: 
   - `/aicheck status` to check current action
   - `/aicheck action new/set/complete` to manage actions
   - `/aicheck dependency add/internal` to document dependencies
   - `/aicheck exec` for maintenance mode

2. Following the documentation-first approach:
   - Writing tests before implementation
   - Documenting all Claude interactions
   - Adhering to the ACTION plan
   - Focusing only on the active action's scope
   - Documenting all dependencies

3. Dependency Management:
   - Documenting all external dependencies
   - Recording all internal dependencies between actions
   - Verifying dependencies before completing actions

4. Git Hook Compliance:
   - Immediately respond to git hook suggestions
   - Address issues before continuing with new work
   - Follow commit message format guidelines
   - Document dependency changes promptly
   - Ensure test-driven development compliance

Let me check the current action status now with `/aicheck status` and proceed accordingly.
```

## Commands

```
/aicheck status
/aicheck action new ActionName
/aicheck action set ActionName
/aicheck action complete
/aicheck dependency add NAME VERSION
```

For details, see `.aicheck/rules.md` after installation.