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