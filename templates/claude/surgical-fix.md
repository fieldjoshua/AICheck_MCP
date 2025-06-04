# Surgical Fix Template

Use this template for focused, boundary-limited fixes that prevent scope creep.

## Template

```
SURGICAL FIX REQUEST:

**Target Issue:** [Describe the specific issue to fix]

**Scope Boundaries:**
- ONLY modify: [specific files/functions to change]
- DO NOT modify: [files/areas to avoid]
- DO NOT add new features
- DO NOT refactor unrelated code

**Success Criteria:**
- [ ] Issue is resolved
- [ ] No changes outside specified scope
- [ ] Existing functionality preserved
- [ ] Tests pass (if applicable)

**Implementation Approach:**
1. Read and understand the target code
2. Identify the minimal change needed
3. Implement the fix
4. Verify the change works
5. Confirm no side effects

**Verification:**
- [ ] Original issue resolved
- [ ] No new issues introduced
- [ ] Code style/patterns maintained
```

## Example Usage

```
SURGICAL FIX REQUEST:

**Target Issue:** Authentication timeout not properly handled in login.js

**Scope Boundaries:**
- ONLY modify: src/auth/login.js, handleTimeout function
- DO NOT modify: other auth files, UI components, config files
- DO NOT add new features like auto-retry
- DO NOT refactor the entire auth system

**Success Criteria:**
- [ ] Timeout errors show proper user message
- [ ] No changes to login flow logic
- [ ] Existing error handling preserved
- [ ] Auth tests still pass
```

## Benefits

- Prevents scope creep and task drift
- Maintains focused implementation
- Reduces risk of introducing bugs
- Ensures predictable outcomes
- Facilitates easier code review