# Updating AICheck to v4.3.0

## Quick Update (Recommended)

To update any existing AICheck installation to the latest v4.3.0:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/install.sh)
```

This will:
- ✅ Detect your existing installation
- ✅ Create a timestamped backup of `.aicheck` directory
- ✅ Update core files (aicheck, RULES.md, MCP server)
- ✅ Preserve all your existing actions and configuration
- ✅ Install MCP server dependencies
- ✅ Show what's new in v4.3.0

## Alternative Update Method

If you prefer using the dedicated update script:

```bash
curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/update_aicheck_v43.sh | bash
```

## What Gets Updated

### Core Files (Always Updated)
- `aicheck` - Main command with v4.3.0 features
- `.aicheck/RULES.md` - Latest governance rules
- `.mcp/server/*` - MCP server for Claude Code integration
- Templates - Latest prompt templates

### Preserved Files (Never Touched)
- `.aicheck/actions/*` - All your existing actions
- `.aicheck/current_action` - Your active action
- `.aicheck/actions_index.md` - Your action history
- `documentation/dependencies/*` - Your dependency records
- Any custom files you've created

## What's New in v4.3.0

### 🔌 MCP Integration
- Native Claude Code integration via MCP protocol
- Fixed tool naming (all use underscores now)
- Direct access to AICheck commands from Claude

### 🧹 Context Management
- `./aicheck stuck` - Get unstuck when confused
- `./aicheck focus` - Check boundaries and scope creep
- `./aicheck cleanup` - Clean up context pollution
- `./aicheck usage` - Track costs and optimization
- `./aicheck reset` - Clean slate (with permission)

### 🤖 Automation Features
- Auto session detection
- Pre-action boundary validation
- Post-commit cleanup
- Context pollution scoring (0-100)

## Verifying Your Update

After updating, verify everything works:

```bash
# Check version
./aicheck version

# Check status
./aicheck status

# Test MCP integration (restart Claude Code first)
# The MCP tools should appear as mcp__aicheck-server__*
```

## Rolling Back

If you need to rollback:

1. Your backup is in `.aicheck.backup.YYYYMMDD_HHMMSS`
2. To restore:
   ```bash
   rm -rf .aicheck
   mv .aicheck.backup.* .aicheck
   ```

## Troubleshooting

### "npm not found" warning
Install Node.js, then run:
```bash
cd .mcp/server && npm install
```

### MCP tools not showing in Claude
1. Restart Claude Code
2. Check MCP is registered: `claude mcp list`
3. If not listed, the installer will register it automatically

### Old version still showing
Clear any cached versions:
```bash
rm -f aicheck
bash <(curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/install.sh)
```

## Need Help?

- Run `./aicheck stuck` for quick help
- Check `.aicheck/RULES.md` for governance guidelines
- Review your backup in `.aicheck.backup.*` if needed