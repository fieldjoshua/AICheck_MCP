# AICheck MCP Installation Guide

This comprehensive guide covers all installation methods for AICheck MCP (Multimodal Control Protocol).

## 🚀 Quick Start (Recommended)

### One-Line Installation

```bash
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/ultimate_aicheck_installer.sh | bash
```

This command:
- Downloads and runs the ultimate installer
- Creates complete AICheck directory structure
- Sets up git hooks for compliance
- Creates templates and documentation
- Installs MCP server files (optional setup)

## 📋 Manual Installation

### Step 1: Download the Installer

```bash
curl -O https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/ultimate_aicheck_installer.sh
chmod +x ultimate_aicheck_installer.sh
```

### Step 2: Run the Installer

```bash
./ultimate_aicheck_installer.sh
```

### Step 3: Follow Post-Installation Steps

The installer will display next steps, typically:

1. **Review the generated rules:** `cat .aicheck/rules.md`
2. **Optional MCP setup:** `./.mcp/setup.sh` (if you want Claude Code integration)
3. **Create your first action:** `./aicheck action new MyFirstAction`

## 🔧 What Gets Installed

The installer creates:

```
your-project/
├── .aicheck/
│   ├── actions/                     # ACTION directories
│   ├── templates/
│   │   ├── claude/                  # Claude Code prompt templates
│   │   └── TODO_TEMPLATE.md         # Todo template for actions
│   ├── rules.md                     # AICheck governance rules
│   ├── actions_index.md             # Master action registry
│   └── current_action               # Tracks active action
├── .mcp/                           # MCP server files (optional)
│   ├── server/
│   │   ├── index.js                # MCP server implementation
│   │   └── package.json            # Node.js dependencies
│   └── setup.sh                    # MCP setup script
├── documentation/                   # Project documentation structure
│   ├── api/
│   ├── architecture/
│   ├── configuration/
│   ├── dependencies/
│   │   └── dependency_index.md     # Dependency tracking
│   ├── deployment/
│   ├── testing/
│   └── user/
├── tests/                          # Testing framework
│   ├── unit/
│   ├── integration/
│   ├── e2e/
│   └── fixtures/
├── .gitignore                      # Git ignore rules
└── README.md                       # Project documentation
```

## 🎯 MCP Server Setup (Optional)

The MCP server enables deep integration with Claude Code. To set it up:

### Prerequisites
- Node.js (version 14 or higher)
- Claude Code CLI installed

### Setup Steps

1. **Run the MCP setup script** (created by installer):
   ```bash
   cd .mcp
   ./setup.sh
   ```

2. **The setup script will:**
   - Install Node.js dependencies
   - Update Anthropic SDK to latest version
   - Make server executable
   - Register server with Claude Code

3. **Verify installation:**
   ```bash
   claude mcp list
   ```
   You should see `aicheck` listed as a configured MCP server.

### Manual MCP Registration

If automated registration fails:

```bash
claude mcp add -s local -t stdio aicheck node "/absolute/path/to/your/project/.mcp/server/index.js"
```

## ⚙️ Requirements

### System Requirements
- **Operating System**: macOS, Linux, or Windows with WSL
- **Shell**: Bash (included on macOS/Linux)
- **Git**: Version control system

### Optional Requirements
- **Node.js**: Version 14+ (for MCP server)
- **Claude Code**: For AI-enhanced development workflows

## 🚦 Getting Started After Installation

### 1. Review the Rules
```bash
cat .aicheck/rules.md
```

### 2. Create Your First Action
```bash
./aicheck action new MyFirstAction
```

### 3. Edit the Action Plan
- Open `.aicheck/actions/my-first-action/my-first-action-plan.md`
- Fill in purpose, requirements, and implementation approach
- Review the auto-generated `todo.md` file

### 4. Set as Active Action
```bash
./aicheck action set MyFirstAction
```

### 5. Start Development
- Follow test-driven development (write tests first)
- Claude Code will manage your todos automatically
- Update documentation as you progress

### 6. Complete the Action
```bash
./aicheck action complete MyFirstAction
```

## 🔍 Available Commands

After installation, you can use these AICheck commands:

```bash
./aicheck status                                    # Show current action status
./aicheck action new ActionName                     # Create new action
./aicheck action set ActionName                     # Set active action
./aicheck action complete [ActionName]              # Complete action
./aicheck dependency add NAME VERSION JUSTIFICATION # Add external dependency
./aicheck dependency internal DEP_ACTION ACTION TYPE # Add internal dependency
./aicheck exec                                      # Toggle exec mode
```

## 🛠 Troubleshooting

### Common Issues

**1. "Permission denied" when running installer**
```bash
chmod +x ultimate_aicheck_installer.sh
```

**2. "claude: command not found" (for MCP setup)**
- Install Claude Code from https://claude.ai/code
- Ensure it's in your PATH

**3. "npm error" during MCP setup**
- Install Node.js: https://nodejs.org/
- Run the MCP setup script again

**4. Git hooks not working**
- Ensure you're in a git repository: `git init`
- Check hook permissions: `ls -la .git/hooks/`

### Getting Help

If you encounter issues:
1. Check the generated `.aicheck/rules.md` for guidance
2. Review installation logs for error messages
3. Ensure all requirements are met
4. Try the manual installation method

## 🔄 Updating AICheck

To update to the latest version:

```bash
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/ultimate_aicheck_installer.sh | bash
```

The installer will detect existing installations and update components as needed.

## 🗑 Uninstalling

To remove AICheck from your project:

```bash
rm -rf .aicheck .mcp
# Remove lines from .gitignore if you added AICheck-specific entries
```

To remove MCP server from Claude Code:

```bash
claude mcp remove aicheck
```

## 📚 Next Steps

After installation:
- Read the [RULES.md](.aicheck/rules.md) for governance guidelines
- Explore [templates](.aicheck/templates/) for Claude Code prompts
- Review [documentation structure](documentation/) organization
- Start with a simple action to learn the workflow

---

**Need more help?** Check the main [README.md](README.md) or review the [RULES.md](.aicheck/rules.md) file created in your project.