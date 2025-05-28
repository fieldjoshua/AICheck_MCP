# AICheck MCP (Multimodal Control Protocol)

AICheck is a comprehensive development governance system that brings structure, accountability, and AI-enhanced workflows to software projects. It enforces documentation-first, test-driven development while providing seamless integration with Claude Code.

---

# ⚠️ IMPORTANT: PROJECT Context for AI Assistants

## This PROJECT Creates AICheck - It Is NOT Governed By AICheck

**For Claude Code and other AI assistants working on this PROJECT:**

- 🏗️ **YOU ARE BUILDING the AICheck system** 
- 🚫 **This PROJECT is NOT subject to AICheck governance**
- 📝 **You are editing the RULES.md that OTHER PROJECTs will use**
- 🔧 **You are improving the `aicheck` command that OTHER PROJECTs will install**
- 📦 **Changes here get distributed via installer to OTHER PROJECTs**

### Dangerous Confusion to Avoid:
❌ Treating this as a PROJECT using AICheck governance  
❌ Looking for `.aicheck/` directory in this PROJECT  
❌ Trying to create ACTIONs for this work  
❌ Following AICheck rules for development here  

### Correct Understanding:
✅ This builds the AICheck tool itself  
✅ Edit RULES.md directly (it becomes the distributed template)  
✅ Improve the installer and aicheck command  
✅ Test changes by running installer in OTHER PROJECTs  

---

## 🚀 Installation

```bash
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/ultimate_aicheck_installer.sh | bash
```

That's it. The installer handles everything automatically.

## ✨ Features

- **Structured Development**: Organized ACTION-based workflow with governance
- **Todo Management**: Integrated task tracking with Claude Code's todo functions
- **Documentation-First**: Enforces planning before implementation
- **Test-Driven**: Requires tests before features
- **AI Integration**: Deep integration with Claude Code and MCP server
- **Dependency Tracking**: External and internal dependency management
- **Git Hook Integration**: Automated compliance checking
- **Template System**: Consistent development patterns
- **Deployment Verification**: Mandatory production testing before action completion
- **Auto-Update**: Built-in update system for latest rules and features

## Claude Code Commands

Claude Code now supports the following AICheck slash commands:

- `./aicheck status` - Show current action status
- `./aicheck action new ActionName` - Create a new action
- `./aicheck action set ActionName` - Set current active action
- `./aicheck action complete [ActionName]` - Complete action with dependency verification
- `./aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `./aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency
- `./aicheck exec` - Toggle exec mode for system maintenance
- `./aicheck update` - Update AICheck rules from official repository

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

Internet connection. That's it.

## 📚 After Installation

- **Rules**: `.aicheck/RULES.md` (the governance document)
- **Commands**: `./aicheck status`, `./aicheck action new ActionName`, etc.
- **Templates**: `.aicheck/templates/` for consistent development

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
