# AICheck Guardian Demo

## 🛡️ Code Guardian System

The AICheck Guardian protects your critical code from unauthorized modifications.

## Quick Start

### 1. Initialize Guardian
```bash
./aicheck guardian init
```

### 2. Protect Critical Files
```bash
# Protect your core authentication module
./aicheck guardian protect src/auth/auth.js CRITICAL

# Protect your database schema
./aicheck guardian protect db/schema.sql CRITICAL

# Monitor configuration files
./aicheck guardian protect config/production.json SENSITIVE

# Track UI components
./aicheck guardian protect src/components/Dashboard.jsx MONITORED
```

### 3. Check Integrity
```bash
# Check all protected files
./aicheck guardian scan

# Check specific file
./aicheck guardian check src/auth/auth.js
```

### 4. Real-Time Monitoring
```bash
# Start monitoring (requires fswatch on macOS or inotify on Linux)
./aicheck guardian monitor
```

## Protection Levels

- **CRITICAL**: No modifications without explicit approval
- **SENSITIVE**: All changes logged and reviewed
- **MONITORED**: Track changes for audit trail

## Example Workflow

1. **Someone modifies a critical file:**
```bash
$ echo "// Hacked!" >> src/auth/auth.js
```

2. **Guardian detects the violation:**
```bash
$ ./aicheck guardian check
🔍 Scanning protected files...
🚨 INTEGRITY VIOLATION: src/auth/auth.js has been modified!
CRITICAL FILE MODIFIED - IMMEDIATE ACTION REQUIRED
⚠️  Found 1 integrity violations
```

3. **After approved change, update hash:**
```bash
$ ./aicheck guardian update src/auth/auth.js
✓ Updated hash for: src/auth/auth.js
```

## Guardian Features

- **Hash-based integrity checking** - Detects any unauthorized changes
- **Real-time monitoring** - Instant alerts on file modifications
- **Audit logging** - Complete trail of who touched what and when
- **Protection levels** - Different security levels for different files
- **Auto-recovery** - Can revert unauthorized changes (when configured)

## Integration with AICheck

The Guardian is fully integrated into AICheck workflow:

```bash
# During action completion, guardian checks critical files
./aicheck action complete MyAction

# Guardian ensures no critical files were modified without approval
# If violations found, action completion is blocked
```

## Advanced Usage

### View Guardian Status
```bash
./aicheck guardian status
```

### View Audit Log
```bash
./aicheck guardian log
```

### Batch Protection
```bash
# Protect all auth files as CRITICAL
find src/auth -name "*.js" | while read f; do
  ./aicheck guardian protect "$f" CRITICAL
done
```

## Security Best Practices

1. **Protect early** - Add files to guardian before they become critical
2. **Regular scans** - Run `./aicheck guardian scan` before deployments
3. **Monitor production** - Use real-time monitoring on production systems
4. **Review logs** - Check guardian logs regularly for suspicious activity
5. **Update hashes** - After approved changes, always update the hash

The Guardian ensures your critical code remains secure and unchanged!