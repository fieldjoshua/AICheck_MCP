# AICheck v5.0.0 - Simplified AI Development Governance

**🚀 Curated human oversight ⟷ effective automation.**

## ✨ What's New in v5.0.0

### 🎯 **Radical Simplification**
- **Just 9 Essential Commands** - Simplified from 20+ to what you actually use
- **deploy Command** - One-stop pre-deployment validation
- **Unified Dependency Management** - Works seamlessly with Poetry/npm
- **Enhanced Automation** - Pre-push hooks, dependency guardian, auto-cleanup
- **Clear ACTION vs ActiveAction** - No more confusion about context switching

### 🛡️ **Dependency Guardian**
- **Pre-push Verification** - Never push broken dependencies again
- **Lock File Checking** - Ensures poetry.lock/package-lock.json are synced
- **Import Validation** - Verifies all imports are in dependencies
- **Auto-fix Command** - `./aicheck deps fix` resolves common issues

### 🔌 **MCP Integration**
- **Automatic Configuration** - Installer sets up Claude integration
- **Native Tool Access** - All AICheck features available in Claude
- **No Manual Setup** - Just restart Claude after installation

## 🚀 Installation

```bash
bash <(curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/install.sh)
```

That's it! The installer will:
- Download and set up AICheck v5.0.0
- Configure MCP server for Claude Code integration
- Install templates and documentation
- Set up activation script
- Test the installation

## 🎯 **Your Commands**

```bash
./aicheck status    # Show detailed status
./aicheck focus     # Check for scope creep  
./aicheck stuck     # Get unstuck when confused
./aicheck deploy    # Pre-deployment validation
./aicheck new       # Create a new action
./aicheck ACTIVE    # Set the ACTIVE action
./aicheck complete  # Complete the ACTIVE action
./aicheck cleanup   # Optimize and fix compliance
./aicheck usage     # See AI usage and costs
```

**Note:** The longer forms still work (e.g., `./aicheck action new`), but these shortcuts are faster!

## 🚀 **What is deploy?**

`./aicheck deploy` runs a comprehensive pre-deployment validation:

1. **Dependency Check**
   - ✅ Lock files committed (poetry.lock, package-lock.json)
   - ✅ All imports have corresponding dependencies
   - ✅ No missing packages

2. **Test Suite**
   - ✅ Runs all tests (pytest for Python, npm test for Node.js)
   - ✅ Ensures zero test failures

3. **Git Status**
   - ✅ Shows uncommitted changes
   - ✅ Warns about untracked files

If everything passes, you'll see: **"✅ Ready to deploy!"**  
If something fails, it tells you exactly what to fix.

## 🔄 **Typical Development Flow**

1. **Create:** `./aicheck new FixLoginBug`
2. **Activate:** `./aicheck ACTIVE FixLoginBug`
3. **Work on code...**
4. **Check:** `./aicheck deploy`
5. **Push:** `git push`
6. **Done:** `./aicheck complete`

## 👤 **Curated Human Oversight ⟷ Effective Automation** 🤖

### **Automated (No Approval Needed)**
- Session startup checks and status summaries
- Log archiving and context optimization  
- Auto-creation of missing documentation structure
- Timestamp and progress tracking updates
- Context pollution detection and scoring

### **Human Approval Required**
- Destructive context cleanup operations
- Creating new actions when scope creep detected
- Proceeding with high context pollution (>30 score)
- Force removal of multiple active actions

### **Smart Warnings (Continue or Stop)**
- Dependency changes without documentation
- Implementation without corresponding tests
- Working outside current action scope
- Action plans older than 7 days

## 📊 **RULES Compliance Features**

AICheck v5.0.0 automatically validates and enforces:

- **Action Management:** Status tracking, progress updates, timeline management
- **Dependency Tracking:** External and internal dependency documentation  
- **Documentation Standards:** Required plan sections, AI interaction logging
- **Test Coverage:** TDD compliance validation and test file verification
- **File Organization:** Proper documentation migration, action isolation
- **Git Integration:** Commit message format, dependency change detection

## 🛠 **Advanced Features**

### **Context Management**
- **Pollution Detection:** 0-100 scoring system with automatic recommendations
- **Boundary Enforcement:** Prevents scope creep and action conflicts
- **Cost Optimization:** Usage analysis and context efficiency optimization

### **MCP Integration**  
- **Native AI Assistant Integration:** Seamless tool access via MCP protocol
- **Resource Exposure:** Direct access to rules, actions, and status
- **Tool Automation:** All automation features available programmatically

### **Templates & Patterns**
- **Structured Prompts:** Auto-surgical-fix, research-plan-implement, auto-TDD-cycle
- **Cost-Efficient Development:** Budget-aware workflows and optimization
- **Proven Patterns:** Battle-tested templates for common development tasks

## 📚 **Documentation & Support**

- **RULES.md** - Full governance rules (v5.0)
- **QUICK_START.md** - Quick command reference
- **CHANGELOG_v5.md** - What's new in v5.0.0
- **GitHub Issues** - Report bugs or request features

## 🎯 **Perfect For**

- **AI-Assisted Development** with Claude Code, Cursor, or similar tools
- **Team Projects** requiring consistent development practices  
- **Complex Codebases** where scope management is critical
- **Cost-Conscious Development** with usage tracking and optimization
- **Compliance-Heavy Projects** requiring documentation and audit trails

## 🚀 **Get Started Now**

```bash
# Install AICheck in your project directory
bash <(curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/install.sh)

# Restart Claude to load MCP integration

# Start working
./aicheck stuck

# You're ready to go! 🎉
```

---

**Built for AI-Assisted Development | Curated Oversight | Effective Automation | Production Ready**