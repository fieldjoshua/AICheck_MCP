# AICheck Library Modules

This directory contains the modularized components of AICheck, extracted from the monolithic script for better maintainability.

## Module Structure

- **core/** - Core state management and fundamental operations
- **ui/** - User interface, colors, and output formatting
- **validation/** - Input validation and verification functions
- **detection/** - Project environment detection
- **commands/** - Command implementations
- **mcp/** - MCP (Model Context Protocol) related functions
- **utils/** - Utility functions and helpers

## Loading Order

Modules should be sourced in this order to handle dependencies:
1. ui/colors.sh - Base colors and formatting
2. ui/output.sh - Output functions
3. core/errors.sh - Error handling framework
4. core/state.sh - State management
5. validation/input.sh - Input validation
6. detection/environment.sh - Environment detection
7. commands/*.sh - Command implementations
8. mcp/*.sh - MCP functions

## Usage

In the main aicheck script:
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/aicheck-lib/ui/colors.sh"
source "$SCRIPT_DIR/aicheck-lib/ui/output.sh"
# ... etc
```