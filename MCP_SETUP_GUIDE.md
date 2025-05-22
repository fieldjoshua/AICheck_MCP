# AICheck MCP Server Setup Guide

This guide explains how to set up the AICheck Model Context Protocol (MCP) server for integration with Claude Code.

## Prerequisites

- Node.js (version 14 or higher)
- Claude Code CLI installed and available in PATH
- Project with AICheck directory structure (created by the AICheck installer)

## Automatic Setup (Recommended)

**The MCP server is now automatically included in the AICheck installer!** When you run the ultimate AICheck installer, it creates all necessary MCP files.

After running the installer, simply execute:

```bash
./.mcp/setup.sh
```

This is now **Step 1** in the installer's next steps and will:
1. Install all required dependencies
2. Update the Anthropic SDK to the latest version
3. Make the server executable
4. Register the server with Claude Code

## Quick Setup (Manual Projects)

For existing AICheck projects, use the automated setup script:

```bash
cd /path/to/your/aicheck/project
./.mcp/setup.sh
```

This script will:
1. Install all required dependencies
2. Update the Anthropic SDK to the latest version
3. Make the server executable
4. Register the server with Claude Code

## Manual Setup

If you prefer to set up the server manually:

### 1. Install Dependencies

```bash
cd .mcp/server
npm install
```

### 2. Make Server Executable

```bash
chmod +x .mcp/server/index.js
```

### 3. Register with Claude Code

```bash
claude mcp add -s local -t stdio aicheck node "/absolute/path/to/your/project/.mcp/server/index.js"
```

### 4. Verify Setup

```bash
claude mcp list
```

You should see `aicheck` listed as a configured MCP server.

## Configuration Options

### Server Scope

- `-s local`: Server available only in the current working directory
- `-s user`: Server available globally for your user account
- `-s project`: Server available for the current project (requires .mcp.json)

### Transport Type

- `-t stdio`: Standard input/output communication (recommended)
- `-t sse`: Server-sent events (for HTTP-based servers)

## Troubleshooting

### Common Issues

**1. "claude: command not found"**
- Ensure Claude Code is installed and available in your PATH
- Visit https://claude.ai/code for installation instructions

**2. "npm error code ETARGET"**
- The Anthropic SDK version in package.json may be outdated
- Run the setup script to automatically update to the latest version

**3. "Server not responding"**
- Check that Node.js is installed and working: `node --version`
- Verify the server file exists and is executable: `ls -la .mcp/server/index.js`
- Check for syntax errors: `node .mcp/server/index.js --help`

**4. "Permission denied"**
- Make sure you have write permissions in the project directory
- Run: `chmod +x .mcp/server/index.js`

### Advanced Configuration

You can customize the MCP server behavior by editing `.mcp/server/index.js` or setting environment variables:

```bash
# Enable debug mode
export DEBUG=true

# Set custom port (if needed)
export MCP_PORT=3000
```

## Integration with AICheck

Once the MCP server is set up, Claude Code will have access to AICheck governance tools:

- **Action Management**: Create, set, and complete actions
- **Rule Enforcement**: Automatic adherence to AICheck rules
- **Documentation**: Automatic logging of Claude interactions
- **Dependency Tracking**: Monitor and manage project dependencies

## Updating the Server

To update the MCP server:

1. Pull the latest changes from the repository
2. Run the setup script again: `./.mcp/setup.sh`
3. Restart Claude Code if necessary

## Security Considerations

- The MCP server runs locally and doesn't send data to external services
- All file operations are restricted to the project directory
- Human approval is required for sensitive operations like changing actions

## Support

If you encounter issues not covered in this guide:

1. Check the AICheck project documentation
2. Verify your Claude Code installation
3. Review the server logs for error messages
4. Ensure all dependencies are properly installed