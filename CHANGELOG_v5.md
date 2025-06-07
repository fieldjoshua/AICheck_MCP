# AICheck v5.0.0 Changelog

## 🚀 Major Release: Radical Simplification

### Breaking Changes
- Reduced command set from 20+ to just 5 essential commands
- Many commands now run automatically (focus, cleanup, etc.)
- Removed manual dependency tracking in favor of Poetry/npm integration

### New Features

#### 🎯 Simplified Command Set
- `./aicheck stuck` - Universal help command
- `./aicheck deploy-check` - Pre-deployment validation (NEW!)
- `./aicheck action new` - Create new action
- `./aicheck action set` - Set active action
- `./aicheck action complete` - Complete active action

#### 🛡️ Dependency Guardian
- Pre-push hook runs comprehensive dependency checks
- Validates lock files are committed
- Verifies all imports are available
- Checks dev/prod dependency separation
- Auto-fix common issues with `./aicheck deps fix`

#### 📦 Unified Dependency Management
- Poetry metadata integration via pyproject.toml
- AICheck metadata stored alongside Poetry dependencies
- Simplified dependency commands
- Works with both Poetry and npm projects

### Improvements

#### 📚 Documentation
- Clear distinction between ACTION and ActiveAction
- Simplified README focusing on essential commands
- New QUICK_START.md guide
- Updated RULES.md with ActiveAction clarification

#### 🤖 Enhanced Automation
- Pre-push hooks prevent deployment failures
- Automatic context management
- Session detection and startup
- Post-commit compliance checks

### Technical Details

#### New Scripts
- `.aicheck/scripts/dependency_guardian.py` - Comprehensive dependency checker
- `.aicheck/scripts/aicheck_deps.py` - Poetry/npm integration
- `.aicheck/scripts/simple_dependency_check.py` - Lightweight checker
- `.aicheck/scripts/verify_routers.py` - API endpoint verification

#### Updated Files
- `aicheck` - Main script simplified to 5 commands
- `RULES.md` - Added ACTION vs ActiveAction clarification
- `.aicheck/hooks/pre-push` - Enhanced with dependency checks

### Migration Guide

1. Update AICheck: `./aicheck update`
2. Install hooks: `./aicheck hooks install`
3. For Python projects: Ensure Poetry is installed
4. Review new command structure in README

### Philosophy

v5.0.0 embraces the principle that **tools should be invisible when working correctly**. By reducing the command surface area to just 5 essential commands and automating everything else, AICheck becomes a guardian that protects without getting in the way.

Remember: **Just 5 commands. Everything else is automatic.**