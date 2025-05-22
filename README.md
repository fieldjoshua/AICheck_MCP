# AICheck MCP (Multimodal Control Protocol)

AICheck is a comprehensive development governance system that brings structure, accountability, and AI-enhanced workflows to software projects. It enforces documentation-first, test-driven development while providing seamless integration with Claude Code.

## 🚀 Quick Installation

### One-Line Install

```bash
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/ultimate_aicheck_installer.sh | bash
```

### Manual Install

1. **Download the installer:**
   ```bash
   curl -O https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/ultimate_aicheck_installer.sh
   chmod +x ultimate_aicheck_installer.sh
   ```

2. **Run the installer:**
   ```bash
   ./ultimate_aicheck_installer.sh
   ```

3. **Follow the post-installation steps displayed by the installer**

## ✨ Features

- **Structured Development**: Organized ACTION-based workflow
- **Todo Management**: Integrated task tracking with Claude Code's todo functions
- **Documentation-First**: Enforces planning before implementation
- **Test-Driven**: Requires tests before features
- **AI Integration**: Deep integration with Claude Code
- **Dependency Tracking**: External and internal dependency management
- **Git Hook Integration**: Automated compliance checking
- **MCP Server Support**: Optional Model Context Protocol server

## 📋 What Gets Installed

The installer creates:
- `.aicheck/` directory structure
- RULES.md with governance guidelines
- Action templates and todo templates
- Git hooks for compliance
- Documentation structure
- Testing framework directories

## Claude Code Commands

Claude Code now supports the following AICheck slash commands:

- `./aicheck status` - Show current action status
- `./aicheck action new ActionName` - Create a new action
- `./aicheck action set ActionName` - Set current active action
- `./aicheck action complete [ActionName]` - Complete action with dependency verification
- `./aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `./aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency
- `./aicheck exec` - Toggle exec mode for system maintenance

## Project Structure

The AICheck system follows a structured approach to development:

- `.aicheck/` - Contains all AICheck system files
  - `actions/` - Individual actions with plans and documentation
  - `templates/` - Templates for Claude prompts
  - `rules.md` - AICheck system rules
- `documentation/` - Project documentation
- `tests/` - Test suite

## Getting Started

### After Installation

1. **Review the rules:**
   ```bash
   cat .aicheck/rules.md
   ```

2. **Create your first action:**
   ```bash
   ./aicheck action new MyFirstAction
   ```

3. **Edit the action plan:**
   - Open `.aicheck/actions/my-first-action/my-first-action-plan.md`
   - Fill in the purpose, requirements, and implementation approach
   - Review the auto-generated `todo.md` file

4. **Set as active action:**
   ```bash
   ./aicheck action set MyFirstAction
   ```

5. **Start implementing:**
   - Follow the plan phases
   - Claude Code will track your todos automatically
   - Write tests first (TDD approach)

6. **Complete the action:**
   ```bash
   ./aicheck action complete MyFirstAction
   ```

## Documentation-First Approach

AICheck follows a documentation-first, test-driven approach:

1. Document your plan thoroughly before implementation
2. Write tests before implementing features
3. Keep documentation updated as the project evolves
4. Migrate completed action documentation to the central documentation directories

## 🔧 Requirements

- **Git**: Version control system
- **Bash**: Shell environment (included on macOS/Linux)
- **Claude Code** (optional): For AI-enhanced development workflows

## 🎯 MCP Server Setup (Optional)

If you want to use the AICheck MCP server with Claude Code:

1. **Install the MCP server:**
   ```bash
   cd .mcp
   ./setup.sh
   ```

2. **The setup script will:**
   - Install Node.js dependencies
   - Configure the MCP server
   - Register with Claude Code

3. **Verify installation:**
   ```bash
   claude mcp list
   ```

## 📚 Learn More

- **Full Documentation**: See the `/documentation` directory after installation
- **AICheck Rules**: Review `.aicheck/rules.md` for governance details
- **Templates**: Check `.aicheck/templates/` for prompt templates
- **MCP Setup Guide**: See `MCP_SETUP_GUIDE.md` for detailed MCP instructions

## 🤝 Contributing

1. Fork the repository
2. Create an action: `./aicheck action new YourFeature`
3. Plan and implement following AICheck rules
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Designed for seamless integration with Claude Code
- Built on documentation-first and test-driven principles
- Inspired by enterprise development best practices
