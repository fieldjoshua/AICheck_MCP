#!/bin/bash
# AICheck Cleanup and Optimization Functions
# Handles system maintenance and optimization

# Load dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../core/errors.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../ui/output.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../core/state.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../validation/actions.sh"

# Main cleanup function
function cleanup_and_optimize() {
    print_section "🧹 AICheck Cleanup & Optimization"
    
    local total_issues_fixed=0
    
    # 1. Fix multiple active actions
    print_header "Checking for multiple active actions..."
    if fix_multiple_active_actions; then
        ((total_issues_fixed++))
    fi
    
    # 2. Synchronize state
    print_header "Synchronizing action state..."
    if sync_action_state; then
        ((total_issues_fixed++))
    fi
    
    # 3. Check context pollution
    print_header "Analyzing context pollution..."
    local pollution_score=$(analyze_context_pollution)
    if [ "$pollution_score" -gt 50 ]; then
        if compact_context; then
            ((total_issues_fixed++))
        fi
    fi
    
    # 4. Archive old sessions
    print_header "Archiving old sessions..."
    if archive_old_sessions; then
        ((total_issues_fixed++))
    fi
    
    # 5. Clean temporary files
    print_header "Cleaning temporary files..."
    if clean_temp_files; then
        ((total_issues_fixed++))
    fi
    
    # 6. Optimize file sizes
    print_header "Optimizing file sizes..."
    if optimize_file_sizes; then
        ((total_issues_fixed++))
    fi
    
    # Summary
    echo ""
    if [ $total_issues_fixed -gt 0 ]; then
        print_success "Cleanup complete! Fixed/optimized $total_issues_fixed items"
    else
        print_success "System is already clean and optimized"
    fi
}

# Fix multiple active actions
function fix_multiple_active_actions() {
    local active_count=$(count_active_actions)
    
    if [ "$active_count" -le 1 ]; then
        print_info "No multiple active actions found"
        return 1
    fi
    
    print_warning "Found $active_count active actions (should be 0 or 1)"
    print_info "Resolving conflicts..."
    
    # Get current from file
    local current=$(get_current_action)
    
    if [ "$current" != "None" ] && [ -n "$current" ]; then
        # Keep current, deactivate others
        local fixed=0
        
        for action in $(get_all_actions); do
            if [ "$action" != "$current" ]; then
                local status=$(get_action_status "$action")
                if [ "$status" = "ActiveAction" ]; then
                    update_action_status "$action" "In Progress"
                    ((fixed++))
                fi
            fi
        done
        
        print_success "Deactivated $fixed conflicting actions"
        print_info "Kept '$current' as the active action"
    else
        # Interactive resolution
        print_info "Please select which action should remain active:"
        
        local active_actions=()
        local i=1
        
        for action in $(get_all_actions); do
            local status=$(get_action_status "$action")
            if [ "$status" = "ActiveAction" ]; then
                active_actions+=("$action")
                echo "  $i) $action"
                ((i++))
            fi
        done
        
        echo "  $i) None (deactivate all)"
        
        read -p "Select (1-$i): " choice
        
        if [ "$choice" -eq "$i" ]; then
            # Deactivate all
            for action in "${active_actions[@]}"; do
                update_action_status "$action" "In Progress"
            done
            clear_current_action
            print_success "All actions deactivated"
        elif [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
            # Activate selected, deactivate others
            local selected="${active_actions[$((choice-1))]}"
            set_current_action "$selected"
            
            for action in "${active_actions[@]}"; do
                if [ "$action" != "$selected" ]; then
                    update_action_status "$action" "In Progress"
                fi
            done
            
            print_success "Set '$selected' as the only active action"
        else
            print_error "Invalid selection"
            return 1
        fi
    fi
    
    return 0
}

# Analyze context pollution
function analyze_context_pollution() {
    local total_size=0
    local file_count=0
    local old_files=0
    local current_time=$(date +%s)
    
    # Check .aicheck directory size
    if [ -d ".aicheck" ]; then
        total_size=$(du -sk .aicheck 2>/dev/null | awk '{print $1}' || echo "0")
        file_count=$(find .aicheck -type f 2>/dev/null | wc -l | tr -d ' ')
        
        # Count files older than 7 days
        old_files=$(find .aicheck -type f -mtime +7 2>/dev/null | wc -l | tr -d ' ')
    fi
    
    # Calculate pollution score (0-100)
    local score=0
    
    # Size factor (>10MB = high pollution)
    if [ "$total_size" -gt 10240 ]; then
        score=$((score + 40))
    elif [ "$total_size" -gt 5120 ]; then
        score=$((score + 20))
    elif [ "$total_size" -gt 1024 ]; then
        score=$((score + 10))
    fi
    
    # File count factor (>100 files = high pollution)
    if [ "$file_count" -gt 100 ]; then
        score=$((score + 30))
    elif [ "$file_count" -gt 50 ]; then
        score=$((score + 15))
    elif [ "$file_count" -gt 20 ]; then
        score=$((score + 5))
    fi
    
    # Old files factor
    if [ "$old_files" -gt 20 ]; then
        score=$((score + 30))
    elif [ "$old_files" -gt 10 ]; then
        score=$((score + 15))
    elif [ "$old_files" -gt 5 ]; then
        score=$((score + 5))
    fi
    
    # Display analysis
    echo "Context Analysis:"
    echo "  Total size: ${total_size}KB"
    echo "  File count: $file_count"
    echo "  Old files: $old_files"
    echo "  Pollution score: $score/100"
    
    echo "$score"
}

# Compact context
function compact_context() {
    print_info "Compacting context..."
    
    local compacted=0
    
    # Archive old auto-iterate sessions
    if [ -d ".aicheck" ]; then
        local old_sessions=$(find .aicheck -name "auto-iterate-*.log" -mtime +3 2>/dev/null | wc -l | tr -d ' ')
        if [ "$old_sessions" -gt 0 ]; then
            mkdir -p .aicheck/archived
            find .aicheck -name "auto-iterate-*.log" -mtime +3 -exec mv {} .aicheck/archived/ \; 2>/dev/null
            ((compacted += old_sessions))
            print_info "Archived $old_sessions old auto-iterate sessions"
        fi
    fi
    
    # Compress large log files
    for log in .aicheck/*.log; do
        if [ -f "$log" ] && [ "$(stat -f%z "$log" 2>/dev/null || stat -c%s "$log" 2>/dev/null)" -gt 1048576 ]; then
            gzip "$log"
            ((compacted++))
            print_info "Compressed large log: $(basename "$log")"
        fi
    done
    
    # Clean empty directories
    find .aicheck -type d -empty -delete 2>/dev/null
    
    if [ $compacted -gt 0 ]; then
        print_success "Compacted $compacted items"
        return 0
    else
        print_info "Nothing to compact"
        return 1
    fi
}

# Archive old sessions
function archive_old_sessions() {
    local archive_dir=".aicheck/archive/$(date +%Y%m)"
    local archived=0
    
    # Find sessions older than 30 days
    if [ -d ".aicheck" ]; then
        for item in .aicheck/*; do
            if [ -f "$item" ] && [ "$(find "$item" -mtime +30 2>/dev/null | wc -l)" -gt 0 ]; then
                mkdir -p "$archive_dir"
                mv "$item" "$archive_dir/"
                ((archived++))
            fi
        done
    fi
    
    if [ $archived -gt 0 ]; then
        print_success "Archived $archived old items to $archive_dir"
        return 0
    else
        print_info "No old sessions to archive"
        return 1
    fi
}

# Clean temporary files
function clean_temp_files() {
    local cleaned=0
    
    # Clean recovery files older than 7 days
    if [ -d ".aicheck" ]; then
        local old_recovery=$(find .aicheck -name "*-state-*.tmp" -mtime +7 2>/dev/null | wc -l | tr -d ' ')
        if [ "$old_recovery" -gt 0 ]; then
            find .aicheck -name "*-state-*.tmp" -mtime +7 -delete 2>/dev/null
            ((cleaned += old_recovery))
            print_info "Removed $old_recovery old recovery files"
        fi
    fi
    
    # Clean backup files
    local old_backups=$(find . -name "*.bak" -o -name "*~" -mtime +7 2>/dev/null | wc -l | tr -d ' ')
    if [ "$old_backups" -gt 0 ]; then
        find . -name "*.bak" -o -name "*~" -mtime +7 -delete 2>/dev/null
        ((cleaned += old_backups))
        print_info "Removed $old_backups old backup files"
    fi
    
    if [ $cleaned -gt 0 ]; then
        print_success "Cleaned $cleaned temporary files"
        return 0
    else
        print_info "No temporary files to clean"
        return 1
    fi
}

# Optimize file sizes
function optimize_file_sizes() {
    local optimized=0
    
    # Truncate large log files (keep last 1000 lines)
    for log in .aicheck/*.log; do
        if [ -f "$log" ]; then
            local size=$(stat -f%z "$log" 2>/dev/null || stat -c%s "$log" 2>/dev/null || echo "0")
            if [ "$size" -gt 1048576 ]; then  # > 1MB
                local temp=$(mktemp)
                tail -1000 "$log" > "$temp"
                mv "$temp" "$log"
                ((optimized++))
                print_info "Truncated large log: $(basename "$log")"
            fi
        fi
    done
    
    if [ $optimized -gt 0 ]; then
        print_success "Optimized $optimized files"
        return 0
    else
        print_info "No files need optimization"
        return 1
    fi
}

# Clean all AICheck data (dangerous!)
function clean_all_aicheck_data() {
    print_warning "This will remove ALL AICheck data and reset to fresh state!"
    print_warning "All actions, history, and configuration will be lost!"
    
    if ! confirm "Are you absolutely sure?"; then
        print_info "Cleanup cancelled"
        return 1
    fi
    
    # Double confirmation for safety
    echo -en "${RED}Type 'DELETE ALL' to confirm: ${NC}"
    read -r confirmation
    
    if [ "$confirmation" != "DELETE ALL" ]; then
        print_info "Cleanup cancelled"
        return 1
    fi
    
    print_info "Removing all AICheck data..."
    rm -rf .aicheck
    print_success "All AICheck data removed"
    print_info "Run './aicheck init' to start fresh"
}

# Generate cleanup report
function generate_cleanup_report() {
    local report_file=".aicheck/cleanup-report-$(date +%Y%m%d_%H%M%S).md"
    
    print_section "📊 Generating Cleanup Report"
    
    {
        echo "# AICheck Cleanup Report"
        echo "Generated: $(date)"
        echo ""
        echo "## System Status"
        echo "- Active actions: $(count_active_actions)"
        echo "- Total actions: $(get_all_actions | wc -l | tr -d ' ')"
        echo "- Directory size: $(du -sh .aicheck 2>/dev/null | awk '{print $1}' || echo 'N/A')"
        echo ""
        echo "## Pollution Analysis"
        analyze_context_pollution
        echo ""
        echo "## Recommendations"
        
        local pollution_score=$(analyze_context_pollution | tail -1)
        if [ "$pollution_score" -gt 70 ]; then
            echo "- **High pollution detected** - Run full cleanup"
            echo "- Consider archiving completed actions"
            echo "- Compress or truncate large log files"
        elif [ "$pollution_score" -gt 40 ]; then
            echo "- Moderate pollution - Regular cleanup recommended"
            echo "- Archive old sessions"
        else
            echo "- System is clean - No immediate action needed"
        fi
    } > "$report_file"
    
    print_success "Report saved to: $report_file"
}