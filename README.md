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

# Step 3: Display activation text
cat /tmp/aicheck_prompt.md

# Step 4: Copy this text and paste to Claude in a new conversation
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