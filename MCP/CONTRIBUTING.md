# Contributing to AICheck MCP

Thank you for your interest in contributing to the AICheck MCP project! This document provides guidelines and instructions for contributing.

## AICheck Governance System

This project follows the AICheck governance system, a documentation-first, test-driven development approach. Please read the [RULES.md](/.aicheck/rules.md) file to understand the governance system before contributing.

## Getting Started

1. Clone the repository
2. Set up the MCP server by running `.mcp/setup.sh`
3. Review the current ACTION index in `.aicheck/actions_index.md`

## How to Contribute

### Creating a New ACTION

1. Create a GitHub issue using the ACTION Request template
2. Wait for approval from the project maintainer
3. Once approved, create a new branch for your ACTION
4. Create the ACTION directory structure:
   ```
   .aicheck/actions/[action-name]/
   ├── [action-name]-plan.md
   ├── progress.md
   ├── status.txt
   └── supporting_docs/
   ```
5. Follow the test-driven development approach
6. Submit a pull request with your changes

### Modifying an Existing ACTION

1. Ensure you are working on an active ACTION
2. Make sure your changes align with the ACTION's plan
3. Document any significant changes
4. Update the ACTION's status and progress
5. Submit a pull request with your changes

## Coding Standards

Please follow the language-specific standards defined in RULES.md:

- **Python**: Follow PEP 8 with 120-character line length, use type hints, include docstrings
- **JavaScript/TypeScript**: Use ESLint, prefer TypeScript, follow Airbnb style guide

## Documentation

All contributions should include appropriate documentation:

- Update the ACTION plan if necessary
- Document Claude interactions in the appropriate location
- Update product documentation for enduring changes
- Update tests to reflect new functionality

## Pull Request Process

1. Ensure all tests pass
2. Update documentation as necessary
3. Reference the ACTION in your pull request
4. Wait for review and approval

## Contact

If you have any questions, please contact the project maintainer:
- Joshua Field (GitHub: @fieldjoshua)