# AICheck v6.1.0 MCP Configuration Guide

**🔌 Set up optimized Claude Code integration with working MCP tools**

## 🚀 Quick Setup (Automatic)

The optimized installer handles MCP configuration automatically:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/install_optimized.sh)
```

After installation:
1. Restart Claude
2. All AICheck MCP tools will work correctly
3. Test with any `aicheck_*` tool in Claude Code

## 🔧 Manual MCP Configuration

### 1. Locate Claude Configuration File

**macOS:**
```bash
~/.claude/claude_desktop_config.json
# OR
~/Library/Application Support/Claude/claude_desktop_config.json
```

**Windows:**
```bash
%APPDATA%\Claude\claude_desktop_config.json
```

**Linux:**
```bash
~/.config/claude/claude_desktop_config.json
```

### 2. Add AICheck MCP Server

Edit your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "aicheck-mcp-server": {
      "command": "node",
      "args": ["/path/to/your/project/.mcp/server/index.js.backup"]
    }
  }
}
```

**Important:** Replace `/path/to/your/project/` with your actual project path.

### 3. Verify Configuration

Check that the MCP server file exists:
```bash
ls -la .mcp/server/index.js.backup
```

The file should be ~500 lines and contain the optimized command mappings.

## ✅ Working MCP Tools (v6.1.0)

All these tools now work correctly in Claude Code:

### `aicheck_getCurrentAction`
- **Function**: Get the currently active action
- **Maps to**: File read of `.aicheck/current_action`
- **Returns**: Action name or "None"

### `aicheck_listActions` 
- **Function**: List all actions in the project
- **Maps to**: File read of `.aicheck/actions_index.md`
- **Returns**: Markdown list of all actions

### `aicheck_contextPollution`
- **Function**: Analyze context pollution and suggest cleanup
- **Maps to**: `./aicheck focus` ✅ (FIXED)
- **Returns**: Pollution score and warnings
- **Performance**: Uses 30-second cache

### `aicheck_contextCompact`
- **Function**: Automatically compact context and archive old interactions
- **Maps to**: `./aicheck cleanup` ✅ (FIXED)
- **Returns**: Cleanup results and optimizations
- **Performance**: Respects `--fast` mode

### `aicheck_checkBoundaries`
- **Function**: Check for action boundary violations and scope creep
- **Maps to**: `./aicheck focus` ✅ (FIXED)
- **Returns**: Scope analysis and boundary warnings

### `aicheck_analyzeCosts`
- **Function**: Analyze usage patterns and cost efficiency
- **Maps to**: `./aicheck usage` ✅ (FIXED)
- **Returns**: AI usage statistics and cost analysis

### `aicheck_optimizeContext`
- **Function**: Auto-optimize context for better performance
- **Maps to**: `./aicheck cleanup` ✅ (FIXED)
- **Returns**: Optimization results and recommendations

## 🐛 Troubleshooting

### Common Issues

#### "Unknown command" Errors
**Problem**: MCP tools return "Unknown command: context"
**Solution**: Update to v6.1.0 - all command mappings are fixed

#### MCP Server Not Found
**Problem**: Claude can't find the MCP server
**Solution**: 
1. Check file path in `claude_desktop_config.json`
2. Verify `.mcp/server/index.js.backup` exists
3. Use absolute path in configuration

#### Tools Not Working
**Problem**: MCP tools don't appear in Claude Code
**Solution**:
1. Restart Claude completely
2. Check MCP server logs in Claude settings
3. Verify Node.js is installed and accessible

### Diagnostic Commands

Check MCP server file:
```bash
# Verify the file exists and has correct content
head -20 .mcp/server/index.js.backup

# Check for optimization markers
grep -n "aicheck focus" .mcp/server/index.js.backup
grep -n "aicheck cleanup" .mcp/server/index.js.backup
grep -n "aicheck usage" .mcp/server/index.js.backup
```

Test AICheck commands directly:
```bash
# These should work before testing MCP
./aicheck focus
./aicheck cleanup  
./aicheck usage
```

## 🔄 Upgrading MCP Configuration

### From v6.0.0 to v6.1.0

The installer automatically:
1. Backs up old MCP configuration
2. Installs fixed command mappings
3. Tests the new configuration

### Manual Upgrade

If you need to upgrade manually:

```bash
# Backup current MCP server
cp .mcp/server/index.js.backup .mcp/server/index.js.backup.pre-v6.1.0

# Download optimized version
curl -sL "https://raw.githubusercontent.com/fieldjoshua/AICheck_MCP/main/.mcp/server/index.js.backup" -o .mcp/server/index.js.backup

# Restart Claude
```

## 🎯 Multiple Project Setup

AICheck v6.1.0 supports multiple projects in Claude:

### Unique Server Names
Each project should have a unique MCP server name:

```json
{
  "mcpServers": {
    "aicheck-project1": {
      "command": "node",
      "args": ["/path/to/project1/.mcp/server/index.js.backup"]
    },
    "aicheck-project2": {
      "command": "node", 
      "args": ["/path/to/project2/.mcp/server/index.js.backup"]
    }
  }
}
```

### Automatic Conflict Resolution
The installer detects existing AICheck servers and suggests unique names.

## 📊 Performance Integration

MCP tools in v6.1.0 automatically use performance optimizations:

### Caching
- `aicheck_contextPollution` uses 30-second cache
- `aicheck_checkBoundaries` shares the same cache
- Results are instant for repeated calls

### Fast Mode Integration
- Tools respect the `--fast` flag automatically
- No need to manually specify performance flags

### Network Optimization
- Tools use `--no-update` to avoid network calls
- Faster responses in Claude Code

## 🛠 Advanced Configuration

### Custom Server Configuration

For advanced setups, you can customize the MCP server:

```json
{
  "mcpServers": {
    "aicheck-custom": {
      "command": "node",
      "args": [
        "/path/to/project/.mcp/server/index.js.backup"
      ],
      "env": {
        "AICHECK_FAST_MODE": "true",
        "AICHECK_NO_UPDATE": "true"
      }
    }
  }
}
```

### Development Mode

For AICheck development, use a custom server:

```json
{
  "mcpServers": {
    "aicheck-dev": {
      "command": "node",
      "args": [
        "/path/to/AICheck_MCP/.mcp/server/index.js.backup"
      ],
      "env": {
        "DEBUG": "true"
      }
    }
  }
}
```

## 📋 Configuration Checklist

### ✅ Installation Verification

- [ ] `claude_desktop_config.json` contains AICheck server entry
- [ ] `.mcp/server/index.js.backup` file exists and is ~500 lines
- [ ] File contains fixed command mappings (grep for "aicheck focus")
- [ ] Claude has been restarted after configuration
- [ ] MCP tools appear in Claude Code interface

### ✅ Functionality Testing

- [ ] `aicheck_getCurrentAction` returns current action
- [ ] `aicheck_contextPollution` runs `./aicheck focus` correctly
- [ ] `aicheck_contextCompact` runs `./aicheck cleanup` correctly
- [ ] `aicheck_analyzeCosts` runs `./aicheck usage` correctly
- [ ] No "Unknown command" errors in tool responses

### ✅ Performance Verification

- [ ] MCP tools respond quickly (< 2 seconds)
- [ ] Repeated calls use cached results
- [ ] No network delays from version checks
- [ ] Claude Code feels responsive with AICheck tools

## 🔮 Future MCP Features

### Planned for v6.2.0
- **Streaming responses**: Real-time tool output
- **Background operations**: Async context analysis
- **Tool chaining**: Automatic sequences like focus→cleanup
- **Smart suggestions**: Proactive tool recommendations

### Experimental Features
- **Auto-optimization**: Tools automatically run cleanup
- **Context monitoring**: Background pollution detection
- **Performance analytics**: Tool usage statistics

---

## 💡 Quick Reference

**Key Files:**
```
claude_desktop_config.json    # Claude MCP configuration  
.mcp/server/index.js.backup   # AICheck MCP server (optimized)
```

**Test Commands:**
```bash
./aicheck focus              # Should match aicheck_contextPollution
./aicheck cleanup            # Should match aicheck_contextCompact  
./aicheck usage              # Should match aicheck_analyzeCosts
```

**Restart Required:**
- After MCP configuration changes
- After AICheck MCP server updates
- When switching between projects

---

*For installation help, run: `bash install_optimized.sh --help`*