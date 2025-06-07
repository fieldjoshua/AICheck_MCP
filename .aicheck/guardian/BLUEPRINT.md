# Critical Path Blueprint System

## Overview
The Guardian Blueprint system defines and protects the critical execution paths in your codebase, ensuring all changes maintain logical consistency and architectural integrity.

## Blueprint Structure

### 1. Critical Path Definition
```yaml
critical_paths:
  authentication:
    entry_point: "src/auth/login.js"
    flow:
      - "src/auth/validate.js"
      - "src/auth/token.js"
      - "src/middleware/auth.js"
    dependencies:
      - "config/security.json"
      - "lib/crypto.js"
    contracts:
      - returns: "AuthToken | null"
      - throws: "AuthError"
      - side_effects: ["logs_attempt", "updates_session"]
    
  payment_processing:
    entry_point: "src/payments/process.js"
    flow:
      - "src/payments/validate.js"
      - "src/payments/gateway.js"
      - "src/payments/receipt.js"
    dependencies:
      - "config/payment.json"
      - "lib/encryption.js"
    contracts:
      - returns: "PaymentResult"
      - throws: "PaymentError"
      - side_effects: ["charges_card", "sends_email", "updates_db"]
```

### 2. Dependency Graph
Links to AICheck's dependency index to understand:
- Which actions depend on critical paths
- External dependencies required
- Internal module relationships

### 3. Contract Enforcement
- Input/output types
- Error handling requirements
- Side effect declarations
- Performance constraints

## Integration Points

### With AICheck Dependency System
```bash
# When adding a dependency that affects a critical path
./aicheck dependency add express 4.18.0 "Web framework" 
# Guardian checks: Does this affect authentication flow?

# When creating internal dependencies
./aicheck dependency internal PaymentModule AuthModule function
# Guardian checks: Does this create circular dependencies?
```

### With AICheck Actions
```bash
# When completing an action that modified critical paths
./aicheck action complete UpdateAuth
# Guardian runs:
# 1. Critical path validation
# 2. Contract verification
# 3. Dependency consistency check
# 4. Documentation requirements
```

### With Documentation
- Auto-generates impact analysis
- Updates architecture diagrams
- Maintains change history
- Links to relevant actions

## Conflict Detection

### Type 1: Direct Conflicts
- Changing function signatures in critical path
- Removing required dependencies
- Altering return types

### Type 2: Logical Conflicts
- Breaking error handling chains
- Creating race conditions
- Violating state assumptions

### Type 3: Architectural Conflicts
- Violating separation of concerns
- Creating circular dependencies
- Breaking abstraction layers

## Change Analysis Process

1. **Parse Proposed Change**
   - Identify affected files
   - Extract modifications
   - Determine scope

2. **Map to Critical Paths**
   - Find which paths are affected
   - Identify downstream impacts
   - Check contract violations

3. **Run Consistency Checks**
   - Type compatibility
   - Error propagation
   - State management
   - Performance impact

4. **Generate Report**
   - Safe changes (proceed)
   - Warnings (review needed)
   - Violations (blocked)

## Example Workflow

```bash
# Developer proposes change
echo "async function login(user, pass) { return null; }" > src/auth/login.js

# Guardian analyzes
./aicheck guardian analyze-change src/auth/login.js

# Output:
🚨 CRITICAL PATH VIOLATION DETECTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Path: authentication
File: src/auth/login.js
Issues:
  ❌ Contract Violation: Should return AuthToken | null, not just null
  ❌ Missing Error Handling: No try/catch for auth errors
  ⚠️  Side Effect Missing: No login attempt logging
  
Downstream Impact:
  → src/middleware/auth.js expects valid token structure
  → src/dashboard/user.js will fail on null token
  
Recommendation: 
  Revert change or update to match contract:
  - Add proper token generation
  - Implement error handling
  - Include audit logging
```