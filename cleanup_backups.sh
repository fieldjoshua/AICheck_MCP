#!/bin/bash
# Cleanup old AICheck backups

echo "Current AICheck backups:"
ls -lah .aicheck.backup.* 2>/dev/null || echo "No backups found"

echo ""
read -p "Keep how many recent backups? (default: 3): " KEEP_COUNT
KEEP_COUNT=${KEEP_COUNT:-3}

BACKUP_COUNT=$(ls -d .aicheck.backup.* 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt "$KEEP_COUNT" ]; then
    echo "Removing old backups (keeping $KEEP_COUNT most recent)..."
    ls -dt .aicheck.backup.* | tail -n +$((KEEP_COUNT + 1)) | xargs rm -rf
    echo "✓ Cleanup complete"
else
    echo "Only $BACKUP_COUNT backups exist, no cleanup needed"
fi

echo ""
echo "Remaining backups:"
ls -lah .aicheck.backup.* 2>/dev/null || echo "No backups found"