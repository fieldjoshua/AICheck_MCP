# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this PROJECT.

# ⚠️ CRITICAL PROJECT CONTEXT

**This PROJECT `/Users/joshuafield/Documents/Projects/AICheck_MCP/` creates the AICheck system - it is NOT governed by AICheck.**

**When working here:**
- ✅ You are building the AICheck tool itself
- ✅ Edit RULES.md directly (it becomes the distributed template)
- ✅ Improve installers and aicheck command
- ✅ This is the source PROJECT that gets distributed
- ❌ Do NOT look for `.aicheck/` directory here
- ❌ Do NOT try to create ACTIONs
- ❌ Do NOT follow AICheck governance rules

**Always check README.md first for PROJECT context orientation.**

## Development Approach (NOT AICheck Integration)

Claude should follow the rules specified in `.aicheck/RULES.md` and use AICheck commands:

- `./aicheck action new ActionName` - Create a new action 
- `./aicheck action set ActionName` - Set the current active action
- `./aicheck action complete [ActionName]` - Complete an action with dependency verification
- `./aicheck exec` - Toggle exec mode for system maintenance
- `./aicheck status` - Show the current action status
- `./aicheck dependency add NAME VERSION JUSTIFICATION [ACTION]` - Add external dependency
- `./aicheck dependency internal DEP_ACTION ACTION TYPE [DESCRIPTION]` - Add internal dependency

## Project Rules

Claude should follow the rules specified in `.aicheck/RULES.md` with focus on documentation-first approach and adherence to language-specific best practices.

## AICheck Procedures

1. Always check the current action with `./aicheck status` at the start of a session
2. Follow the active action's plan when implementing
3. Create tests before implementation code
4. Document all Claude interactions in supporting_docs/claude-interactions/
5. Only work within the scope of the active action
6. Document all dependencies before completing an action
7. Immediately respond to git hook suggestions before continuing work

## Dependency Management

When adding external libraries or frameworks:
1. Document with `./aicheck dependency add NAME VERSION JUSTIFICATION`
2. Include specific version requirements
3. Provide clear justification for adding the dependency

When creating dependencies between actions:
1. Document with `./aicheck dependency internal DEP_ACTION ACTION TYPE DESCRIPTION`
2. Specify the type of dependency (data, function, service, etc.)
3. Add detailed description of the dependency relationship

## Claude Workflow

When the user requests work:
1. Check if it fits within the current action (if not, suggest creating a new action)
2. Consult the action plan for guidance
3. Follow test-driven development practices
4. Document your thought process
5. Document all dependencies
6. Implement according to the plan
7. Verify your implementation against the success criteria
