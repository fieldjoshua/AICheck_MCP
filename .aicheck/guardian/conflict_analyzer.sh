#!/bin/bash

# Guardian Conflict Analyzer
# Detects logical conflicts and inconsistencies in proposed changes

# Analyze JavaScript/TypeScript function changes
analyze_js_function() {
    local file="$1"
    local old_content="$2"
    local new_content="$3"
    
    # Extract function signatures
    local old_sigs=$(echo "$old_content" | grep -E "^(async\s+)?function|^(export\s+)?(const|let|var)\s+\w+\s*=\s*(async\s*)?\(" | sed 's/{.*//')
    local new_sigs=$(echo "$new_content" | grep -E "^(async\s+)?function|^(export\s+)?(const|let|var)\s+\w+\s*=\s*(async\s*)?\(" | sed 's/{.*//')
    
    # Check for signature changes
    if [ "$old_sigs" != "$new_sigs" ]; then
        echo "CONFLICT: Function signature changed"
        echo "Old: $old_sigs"
        echo "New: $new_sigs"
    fi
    
    # Check for return type consistency
    local old_returns=$(echo "$old_content" | grep -c "return")
    local new_returns=$(echo "$new_content" | grep -c "return")
    
    if [ "$old_returns" -ne "$new_returns" ]; then
        echo "WARNING: Number of return statements changed ($old_returns -> $new_returns)"
    fi
    
    # Check for error handling
    local old_try=$(echo "$old_content" | grep -c "try\s*{")
    local new_try=$(echo "$new_content" | grep -c "try\s*{")
    
    if [ "$old_try" -gt "$new_try" ]; then
        echo "CONFLICT: Error handling removed (try/catch blocks reduced)"
    fi
}

# Analyze dependency changes
analyze_dependencies() {
    local file="$1"
    
    # Check package.json changes
    if [[ "$file" == "package.json" ]]; then
        echo "CRITICAL: Package dependencies modified"
        echo "Action required: Update dependency index with './aicheck dependency add'"
    fi
    
    # Check import statement changes
    local import_changes=$(git diff --cached "$file" 2>/dev/null | grep -E "^[+-]import" | wc -l)
    if [ "$import_changes" -gt 0 ]; then
        echo "WARNING: Import statements modified - verify dependency graph"
    fi
}

# Analyze state consistency
analyze_state_consistency() {
    local file="$1"
    local content="$2"
    
    # Check for global state modifications
    local global_mods=$(echo "$content" | grep -E "window\.|global\.|process\.env" | wc -l)
    if [ "$global_mods" -gt 0 ]; then
        echo "WARNING: Global state modifications detected"
    fi
    
    # Check for async without await
    local async_funcs=$(echo "$content" | grep -c "async\s")
    local awaits=$(echo "$content" | grep -c "await\s")
    
    if [ "$async_funcs" -gt 0 ] && [ "$awaits" -eq 0 ]; then
        echo "WARNING: Async function without await - possible race condition"
    fi
}

# Main analysis function
analyze_change() {
    local file="$1"
    local change_type="${2:-modify}"
    
    echo "=== Conflict Analysis for $file ==="
    
    # Get file extension
    local ext="${file##*.}"
    
    # Get old content (if exists)
    local old_content=""
    if [ -f "$file" ]; then
        old_content=$(cat "$file")
    fi
    
    # For demonstration, analyze current content
    local new_content=$(cat "$file" 2>/dev/null || echo "")
    
    case "$ext" in
        js|ts|jsx|tsx)
            analyze_js_function "$file" "$old_content" "$new_content"
            analyze_dependencies "$file"
            analyze_state_consistency "$file" "$new_content"
            ;;
        json)
            if [[ "$file" == *"package.json"* ]]; then
                analyze_dependencies "$file"
            fi
            ;;
        py)
            # Python analysis would go here
            echo "Python analysis not yet implemented"
            ;;
        *)
            echo "No specific analyzer for .$ext files"
            ;;
    esac
    
    # Check against AICheck action plan
    local current_action=$(cat .aicheck/current_action 2>/dev/null)
    if [ "$current_action" != "None" ] && [ "$current_action" != "" ]; then
        echo ""
        echo "=== Action Compliance Check ==="
        local action_dir=".aicheck/actions/${current_action,,}"
        if [ -f "$action_dir/${current_action,,}-plan.md" ]; then
            local in_scope=$(grep -c "$file" "$action_dir/${current_action,,}-plan.md" || echo "0")
            if [ "$in_scope" -eq 0 ]; then
                echo "WARNING: File not mentioned in action plan"
                echo "Current action: $current_action"
                echo "Consider: Is this change within scope?"
            else
                echo "✓ File is part of action plan"
            fi
        fi
    fi
    
    # Check against dependency index
    echo ""
    echo "=== Dependency Impact ==="
    if [ -f "documentation/dependencies/dependency_index.md" ]; then
        local deps=$(grep -A5 -B5 "$file" "documentation/dependencies/dependency_index.md" 2>/dev/null)
        if [ -n "$deps" ]; then
            echo "File referenced in dependencies:"
            echo "$deps" | grep -E "^\|" | head -3
        else
            echo "✓ No direct dependency references found"
        fi
    fi
}

# Export for use by guardian
if [ "${1}" ]; then
    analyze_change "$@"
fi