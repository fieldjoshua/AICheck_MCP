# AICheck MCP

Simple structure for Claude AI workflows.

## Setup

```bash
# Clone repo
git clone https://github.com/fieldjoshua/AICheck_MCP.git

# Copy files to your project
cp AICheck_MCP/*.sh /path/to/your/project/
cd /path/to/your/project/

# Run setup
./setup_aicheck_complete.sh
./setup_aicheck_hooks.sh
./setup_aicheck_status.sh
source ~/.zshrc  # Or ~/.bashrc

# Get activation text
cat /tmp/aicheck_prompt.md
# Copy output and paste to Claude
```

## Commands

```
/aicheck status
/aicheck action new ActionName
/aicheck action set ActionName
/aicheck action complete
/aicheck dependency add NAME VERSION
```

## Further Reading

After installation, see `.aicheck/rules.md` for details.