#!/bin/bash

# AICheck Guardian - Code Protection Agent
# Protects critical code from unauthorized modifications

GUARDIAN_DIR=".aicheck/guardian"
GUARDIAN_DB="$GUARDIAN_DIR/guardian.db"
GUARDIAN_LOG="$GUARDIAN_DIR/guardian.log"
PROTECTED_FILES="$GUARDIAN_DIR/protected_files.txt"
HASHES_DB="$GUARDIAN_DIR/file_hashes.db"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Initialize Guardian
init_guardian() {
    mkdir -p "$GUARDIAN_DIR"
    touch "$GUARDIAN_DB" "$GUARDIAN_LOG" "$PROTECTED_FILES" "$HASHES_DB"
    
    echo -e "${BLUE}🛡️  AICheck Guardian Initialized${NC}"
    echo -e "${YELLOW}Configure protected files in: $PROTECTED_FILES${NC}"
}

# Add file to protection
protect_file() {
    local file="$1"
    local level="${2:-MONITORED}"  # CRITICAL, SENSITIVE, MONITORED
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ File not found: $file${NC}"
        return 1
    fi
    
    # Calculate hash
    local hash=$(shasum -a 256 "$file" | cut -d' ' -f1)
    
    # Add to protected files
    echo "$file|$level|$hash|$(date +%s)" >> "$PROTECTED_FILES"
    
    # Store initial hash
    echo "$file:$hash:$(date +%s)" >> "$HASHES_DB"
    
    log_action "PROTECT" "$file" "Added to $level protection"
    echo -e "${GREEN}✓ Protected: $file (Level: $level)${NC}"
}

# Check file integrity
check_integrity() {
    local file="$1"
    local stored_hash=$(grep "^$file:" "$HASHES_DB" 2>/dev/null | cut -d':' -f2)
    
    if [ -z "$stored_hash" ]; then
        echo -e "${YELLOW}⚠ File not in guardian database: $file${NC}"
        return 2
    fi
    
    local current_hash=$(shasum -a 256 "$file" 2>/dev/null | cut -d' ' -f1)
    
    if [ "$stored_hash" != "$current_hash" ]; then
        echo -e "${RED}🚨 INTEGRITY VIOLATION: $file has been modified!${NC}"
        log_action "VIOLATION" "$file" "Hash mismatch detected"
        
        # Get protection level
        local level=$(grep "^$file|" "$PROTECTED_FILES" | cut -d'|' -f2)
        
        if [ "$level" = "CRITICAL" ]; then
            echo -e "${RED}CRITICAL FILE MODIFIED - IMMEDIATE ACTION REQUIRED${NC}"
            # Could auto-revert here if configured
        fi
        
        return 1
    else
        echo -e "${GREEN}✓ Integrity verified: $file${NC}"
        return 0
    fi
}

# Scan all protected files
scan_all() {
    echo -e "${BLUE}🔍 Scanning protected files...${NC}"
    local violations=0
    
    while IFS='|' read -r file level hash timestamp; do
        if [ -n "$file" ]; then
            if ! check_integrity "$file"; then
                ((violations++))
            fi
        fi
    done < "$PROTECTED_FILES"
    
    if [ $violations -eq 0 ]; then
        echo -e "${GREEN}✅ All protected files intact${NC}"
    else
        echo -e "${RED}⚠️  Found $violations integrity violations${NC}"
    fi
    
    log_action "SCAN" "ALL" "Found $violations violations"
}

# Monitor files in real-time (requires fswatch/inotify)
monitor_realtime() {
    echo -e "${BLUE}👁️  Starting real-time monitoring...${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    
    if command -v fswatch >/dev/null 2>&1; then
        # macOS with fswatch
        fswatch -0 $(cat "$PROTECTED_FILES" | cut -d'|' -f1) | while read -d "" event; do
            echo -e "${YELLOW}⚡ Change detected: $event${NC}"
            check_integrity "$event"
        done
    elif command -v inotifywait >/dev/null 2>&1; then
        # Linux with inotify
        inotifywait -m -e modify,create,delete --format '%w%f' $(cat "$PROTECTED_FILES" | cut -d'|' -f1) | while read file; do
            echo -e "${YELLOW}⚡ Change detected: $file${NC}"
            check_integrity "$file"
        done
    else
        echo -e "${RED}Real-time monitoring requires fswatch (macOS) or inotify-tools (Linux)${NC}"
        echo -e "Install with: ${YELLOW}brew install fswatch${NC} or ${YELLOW}apt-get install inotify-tools${NC}"
    fi
}

# Log actions
log_action() {
    local action="$1"
    local target="$2"
    local details="$3"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $action | $target | $details | User: $(whoami)" >> "$GUARDIAN_LOG"
}

# Update hash after approved change
update_hash() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ File not found: $file${NC}"
        return 1
    fi
    
    local new_hash=$(shasum -a 256 "$file" | cut -d' ' -f1)
    
    # Update in hashes database
    sed -i.bak "s|^$file:.*|$file:$new_hash:$(date +%s)|" "$HASHES_DB"
    
    # Update in protected files
    sed -i.bak "s|^$file|.*|$file|$(grep "^$file|" "$PROTECTED_FILES" | cut -d'|' -f2)|$new_hash|$(date +%s)|" "$PROTECTED_FILES"
    
    log_action "UPDATE" "$file" "Hash updated after approved change"
    echo -e "${GREEN}✓ Updated hash for: $file${NC}"
}

# Show guardian status
status() {
    echo -e "${PURPLE}🛡️  AICheck Guardian Status${NC}"
    echo "========================="
    
    local total=$(wc -l < "$PROTECTED_FILES")
    local critical=$(grep "|CRITICAL|" "$PROTECTED_FILES" | wc -l)
    local sensitive=$(grep "|SENSITIVE|" "$PROTECTED_FILES" | wc -l)
    local monitored=$(grep "|MONITORED|" "$PROTECTED_FILES" | wc -l)
    
    echo -e "Protected Files: ${BLUE}$total${NC}"
    echo -e "  ${RED}CRITICAL: $critical${NC}"
    echo -e "  ${YELLOW}SENSITIVE: $sensitive${NC}"
    echo -e "  ${GREEN}MONITORED: $monitored${NC}"
    
    echo -e "\nRecent Activity:"
    tail -5 "$GUARDIAN_LOG" | while read line; do
        echo -e "  ${YELLOW}$line${NC}"
    done
}

# Main command handler
case "$1" in
    init)
        init_guardian
        ;;
    protect)
        protect_file "$2" "$3"
        ;;
    check)
        if [ -n "$2" ]; then
            check_integrity "$2"
        else
            scan_all
        fi
        ;;
    scan)
        scan_all
        ;;
    monitor)
        monitor_realtime
        ;;
    update)
        update_hash "$2"
        ;;
    status)
        status
        ;;
    log)
        cat "$GUARDIAN_LOG"
        ;;
    *)
        echo -e "${BLUE}AICheck Guardian - Code Protection System${NC}"
        echo "Usage: $0 {init|protect|check|scan|monitor|update|status|log}"
        echo ""
        echo "Commands:"
        echo "  init              Initialize guardian system"
        echo "  protect FILE LVL  Add file to protection (LVL: CRITICAL/SENSITIVE/MONITORED)"
        echo "  check [FILE]      Check file integrity (or all if no file specified)"
        echo "  scan              Scan all protected files"
        echo "  monitor           Start real-time monitoring"
        echo "  update FILE       Update hash after approved change"
        echo "  status            Show guardian status"
        echo "  log               View guardian log"
        ;;
esac