# Guardian Integration Demo

## 🛡️ Enhanced Guardian with AICheck Integration

The Guardian now integrates deeply with AICheck's existing systems to provide comprehensive protection.

## Key Features

### 1. Critical Path Blueprints
Define the critical execution paths in your code:

```bash
# Define authentication flow
./aicheck guardian blueprint add auth src/auth/login.js

# Define payment processing flow  
./aicheck guardian blueprint add payment src/payments/process.js
```

### 2. Conflict Detection
Before making changes, analyze for conflicts:

```bash
# Analyze proposed changes
./aicheck guardian analyze src/auth/login.js

# Output:
🔬 Deep Analysis of: src/auth/login.js
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
=== Conflict Analysis ===
CONFLICT: Function signature changed
WARNING: Error handling removed (try/catch blocks reduced)

=== Action Compliance Check ===
WARNING: File not mentioned in action plan
Current action: UpdateAuth

=== Dependency Impact ===
File referenced in dependencies:
| AuthModule | LoginFeature | function | Critical authentication |

Protection Level: CRITICAL
⚠️ This is a CRITICAL file - changes require approval
```

### 3. Integration with AICheck Systems

#### With Dependency Tracking:
```bash
# Guardian checks dependencies when files change
./aicheck dependency add bcrypt 5.0.1 "Password hashing"
# Guardian: "This affects authentication flow - update tests"
```

#### With Action Management:
```bash
# Guardian validates changes against current action
./aicheck action set UpdatePayments
echo "// new code" >> src/auth/login.js
./aicheck guardian analyze src/auth/login.js
# Guardian: "❌ Change outside current action boundaries"
```

#### With Documentation:
```bash
# Guardian ensures docs stay in sync
./aicheck guardian analyze src/api/endpoints.js
# Guardian: "Contract change detected - update API documentation"
```

## Workflow Example

### 1. Start New Action
```bash
./aicheck action new RefactorAuth
./aicheck action set RefactorAuth
```

### 2. Guardian Monitors Changes
```bash
# Make a change
vim src/auth/login.js

# Guardian analyzes
./aicheck guardian analyze src/auth/login.js
```

### 3. Guardian Output
```
🔬 Deep Analysis of: src/auth/login.js
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

=== Conflict Analysis ===
✓ Function signatures maintained
✓ Error handling present
WARNING: New import added - verify dependency

=== AICheck Validation ===
✓ Change appears within action boundaries
✓ Matches action plan requirements

=== Dependency Impact ===
This module is used by:
- src/middleware/auth.js
- src/api/user.js
- tests/auth.test.js

Recommended Actions:
1. Update dependent module tests
2. Document the refactoring
3. Run: ./aicheck guardian update src/auth/login.js
```

### 4. Complete Action with Guardian Validation
```bash
./aicheck action complete RefactorAuth
# Guardian runs final validation:
# - Checks all modified files
# - Verifies contracts maintained
# - Ensures documentation updated
# - Validates dependency consistency
```

## Advanced Features

### Logical Consistency Checking
```javascript
// Before
async function processPayment(amount) {
    return await chargeCard(amount);
}

// After  
function processPayment(amount) {
    return chargeCard(amount);
}
```

Guardian detects:
- ❌ Async removed but still calling async function
- ❌ Missing await will return Promise not result
- ❌ Breaking change for callers expecting async

### State Management Validation
```javascript
// Proposed change
function updateUser(id, data) {
    window.userData = data;  // Guardian: "WARNING: Global state modification"
    localStorage.setItem('user', data); // Guardian: "WARNING: Unencrypted storage"
}
```

### Circular Dependency Prevention
```bash
./aicheck dependency internal UserModule AuthModule function
# Guardian: "WARNING: AuthModule already depends on UserModule - circular dependency"
```

## Benefits

1. **Prevents Breaking Changes** - Catches contract violations before they cause issues
2. **Maintains Architectural Integrity** - Ensures changes align with design patterns
3. **Integrates with Workflow** - Works seamlessly with AICheck actions and dependencies
4. **Provides Actionable Feedback** - Tells you exactly what needs fixing
5. **Documents Everything** - Maintains audit trail of all changes and decisions

The Guardian ensures your critical code paths remain stable, consistent, and well-documented!