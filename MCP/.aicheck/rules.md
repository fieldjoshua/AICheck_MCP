# AICheck Rules

This document is the controlling reference for all work managed by the AICheck system in this PROJECT.

## 1. Core Principles

### 1.1 Documentation-First Approach
- Write clear docstrings for all functions and classes
- Include explanatory comments for complex code blocks
- Update README.md with relevant project information
- Create/update API documentation when adding endpoints
- All ACTIONS require their own directory with a documented PLAN before implementation
- PLANs require approval and must detail the ACTION's value to the PROGRAM
- ACTIONS must be TEST-Driven: tests must be created before implementation

### 1.2 Language-Specific Best Practices
- Python: Follow PEP 8 style guidelines with 150 max line length
- JavaScript/TypeScript: Use ESLint and Prettier standards
- Follow language idioms and patterns (pythonic, modern JS/TS)

### 1.3 Quality Standards
- Write unit tests for new functionality
- Maintain test coverage above 80%
- Handle errors explicitly with proper logging
- Use typed interfaces where possible

### 1.4 Security Practices
- Validate all user inputs
- Use parameterized queries for database operations
- Store secrets in environment variables, never in code
- Apply proper authentication and authorization

### 1.5 Dependency Management
# Git Hook Compliance Section for RULES.md

### 1.6 Git Hook Compliance

Claude Code must always respect and respond to git hook suggestions, following these practices:

- **Immediate Response**: Address git hook suggestions before continuing with new work
- **Dependency Documentation**: When hooks indicate missing dependency documentation, immediately use `/aicheck dependency add` to document dependencies
- **Commit Message Format**: Follow suggested commit message formats, using present-tense verbs and referencing the current action
- **Test-Driven Development**: When hooks indicate implementation without tests, pause to create required tests
- **Action Boundaries**: Respect boundaries between actions, using the proper action context for work

#### 1.6.1 Hook Response Workflow

When git hooks provide suggestions:

1. **Acknowledge the suggestion** in your response to the user
2. **Take immediate corrective action**, such as:
   - Adding missing dependency documentation
   - Updating commit messages to use proper format
   - Writing tests for implementation
   - Switching to the correct action context
3. **Confirm compliance** before proceeding with additional work
4. **Document the hook suggestion** and your response in the action's progress tracking

#### 1.6.2 Commit Message Standards

All commit messages must:

- Begin with a present-tense verb (Add, Update, Fix, etc.)
- Be concise (under 72 characters for the first line)
- Reference the current action when applicable using the format `[ActionName]`
- Use the extended commit body (separated by a blank line) for detailed explanations
- Follow the pattern: `Verb descriptive-content [ActionName]`

#### 1.6.3 Claude Code Response to Hooks

When git hooks trigger, Claude Code should:

- **Never ignore** hook suggestions
- **Proactively fix** issues before continuing
- **Explain changes** made to comply with hook suggestions
- **Reference this section** of the rules when making compliance changes

#### 1.6.4 Hook Education

Claude Code should educate users about git hook suggestions by:

- Explaining the purpose of each suggestion
- Demonstrating proper compliance
- Connecting suggestions to AICheck principles
- Using this as an opportunity to reinforce AICheck best practices
- All external dependencies must be documented in dependency_index.md
- All internal dependencies between actions must be documented
- External dependencies require justification and version specification
- Dependencies must be verified before action completion

## 2. Action Management

### 2.1 AI Editor Scope
AI editors may implement without approval:
- Code implementing the ActiveAction plan (after PLAN approval)
- Documentation updates for ActiveAction
- Bug fixes and tests within ActiveAction scope
- Refactoring within ActiveAction scope

The following ALWAYS require human manager approval:
- Changing the ActiveAction
- Creating a new Action
- Making substantive changes to any Action
- Modifying any Action Plan

## 3. Project Structure and Organization

### 3.1 Directory Structure
```text
/
├── .aicheck/
│   ├── actions/                      # All PROJECT ACTIONS
│   │   └── [action-name]/            # Individual ACTION directory
│   │       ├── [action-name]-plan.md # ACTION PLAN (requires approval)
│   │       └── supporting_docs/      # ACTION-specific documentation
│   │           ├── claude-interactions/  # Claude Code logs
│   │           ├── process-tests/        # Temporary tests for ACTION
│   │           └── research/             # Research and notes
│   ├── current_action                # Current ActionActivity for EDITOR
│   ├── actions_index.md              # Master list of all ACTIONS
│   ├── rules.md                      # This document
│   └── templates/                    # Templates for prompts and actions
├── documentation/                    # Permanent PROJECT documentation
│   ├── api/                          # API documentation
│   ├── architecture/                 # System architecture docs
│   ├── configuration/                # Configuration guides
│   ├── dependencies/                 # Dependency documentation
│   │   └── dependency_index.md       # Index of all dependencies
│   ├── deployment/                   # Deployment procedures
│   ├── testing/                      # Testing strategies
│   └── user/                         # User documentation
├── tests/                            # Permanent test suite
│   ├── unit/                         # Unit tests
│   ├── integration/                  # Integration tests
│   ├── e2e/                          # End-to-end tests
│   └── fixtures/                     # Test data and fixtures
```
