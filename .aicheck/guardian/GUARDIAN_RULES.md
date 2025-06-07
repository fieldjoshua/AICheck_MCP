# AICheck Guardian Rules

## Protected Code Zones

### CRITICAL (Level 1 - Highest Protection)
Files that must NEVER be modified without explicit approval:
- Core security modules
- Authentication/authorization code
- Cryptographic implementations
- Database schemas
- API contracts

### SENSITIVE (Level 2 - Change Monitoring)
Files that require logging and review:
- Business logic
- Data models
- Configuration files
- Integration points
- Payment processing

### MONITORED (Level 3 - Track Changes)
Files under observation:
- UI components
- Helper utilities
- Documentation
- Tests

## Guardian Actions

### PREVENT
- Block any modification to CRITICAL files without approval
- Require two-factor confirmation for sensitive operations
- Auto-revert unauthorized changes

### ALERT
- Real-time notifications for protected file access
- Suspicious pattern detection
- Unusual permission requests

### LOG
- Every access attempt to protected files
- All modifications with full diff
- Who, what, when, why tracking

### BACKUP
- Automatic versioning before any change
- Encrypted backups of critical files
- Point-in-time recovery capability

## Enforcement Rules

1. **No Direct Modification** - Critical files must be modified through approved workflows
2. **Audit Trail** - All changes must have associated tickets/reasons
3. **Peer Review** - Sensitive changes require review before application
4. **Rollback Ready** - Any change must be reversible within 30 seconds
5. **Zero Trust** - Verify every access, even from trusted sources