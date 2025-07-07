#!/bin/bash
# AICheck Module Dependency Graph Generator
# Creates a visual representation of module dependencies

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}AICheck Module Dependency Graph${NC}"
echo "==============================="

# Output format
OUTPUT_FORMAT=${1:-"tree"}  # tree, dot, mermaid

# Build dependency map
declare -A dependencies
declare -A reverse_deps

# Scan all modules
for module in aicheck-lib/**/*.sh; do
    if [ -f "$module" ]; then
        module_rel=$(echo "$module" | sed 's|^aicheck-lib/||')
        
        # Extract dependencies
        while IFS= read -r line; do
            if [[ $line =~ source[[:space:]]+\".*\/(.*\.sh)\" ]]; then
                dep="${BASH_REMATCH[1]}"
                # Find the dependency's full path
                dep_full=$(find aicheck-lib -name "$dep" -type f | head -1 | sed 's|^aicheck-lib/||')
                if [ -n "$dep_full" ]; then
                    dependencies["$module_rel"]+="$dep_full "
                    reverse_deps["$dep_full"]+="$module_rel "
                fi
            fi
        done < <(grep "^source" "$module")
    fi
done

case "$OUTPUT_FORMAT" in
    "tree")
        echo -e "\n${BLUE}Module Dependency Tree${NC}"
        echo "======================"
        
        # Find root modules (no dependencies)
        declare -A printed
        
        function print_deps() {
            local module=$1
            local indent=$2
            
            # Avoid infinite loops
            if [ "${printed[$module]}" = "1" ]; then
                echo "${indent}(circular reference)"
                return
            fi
            
            printed["$module"]=1
            
            # Print module
            echo "${indent}├── $module"
            
            # Print its dependencies
            if [ -n "${dependencies[$module]}" ]; then
                for dep in ${dependencies[$module]}; do
                    print_deps "$dep" "${indent}│   "
                done
            fi
        }
        
        # Start with modules that have no dependencies
        for module in "${!dependencies[@]}"; do
            if [ -z "${reverse_deps[$module]}" ]; then
                echo -e "\n${GREEN}Root: $module${NC}"
                print_deps "$module" ""
            fi
        done
        
        # Show orphaned modules
        echo -e "\n${YELLOW}Standalone Modules:${NC}"
        for module in aicheck-lib/**/*.sh; do
            if [ -f "$module" ]; then
                module_rel=$(echo "$module" | sed 's|^aicheck-lib/||')
                if [ -z "${dependencies[$module_rel]}" ] && [ -z "${reverse_deps[$module_rel]}" ]; then
                    echo "  - $module_rel"
                fi
            fi
        done
        ;;
        
    "dot")
        echo -e "\n${BLUE}Graphviz DOT Format${NC}"
        echo "==================="
        echo "digraph G {"
        echo "  rankdir=LR;"
        echo "  node [shape=box];"
        echo ""
        
        # Color by directory
        for module in "${!dependencies[@]}"; do
            dir=$(dirname "$module")
            case "$dir" in
                "ui") color="lightblue" ;;
                "core") color="lightgreen" ;;
                "validation") color="lightyellow" ;;
                "actions") color="lightcoral" ;;
                *) color="lightgray" ;;
            esac
            echo "  \"$module\" [fillcolor=$color, style=filled];"
        done
        
        echo ""
        
        # Add edges
        for module in "${!dependencies[@]}"; do
            for dep in ${dependencies[$module]}; do
                echo "  \"$module\" -> \"$dep\";"
            done
        done
        
        echo "}"
        echo ""
        echo -e "${YELLOW}Save output to file.dot and run: dot -Tpng file.dot -o dependencies.png${NC}"
        ;;
        
    "mermaid")
        echo -e "\n${BLUE}Mermaid Diagram${NC}"
        echo "==============="
        echo "```mermaid"
        echo "graph TD"
        
        # Add nodes with styling
        for module in "${!dependencies[@]}"; do
            mod_name=$(basename "$module" .sh)
            dir=$(dirname "$module")
            echo "    $mod_name[$mod_name<br/>$dir]"
        done
        
        echo ""
        
        # Add edges
        for module in "${!dependencies[@]}"; do
            mod_name=$(basename "$module" .sh)
            for dep in ${dependencies[$module]}; do
                dep_name=$(basename "$dep" .sh)
                echo "    $mod_name --> $dep_name"
            done
        done
        
        echo "```"
        ;;
esac

# Statistics
echo -e "\n${BLUE}Dependency Statistics${NC}"
echo "===================="
total_modules=$(find aicheck-lib -name "*.sh" -type f | wc -l | tr -d ' ')
modules_with_deps=${#dependencies[@]}
modules_depended_on=${#reverse_deps[@]}

echo "Total modules: $total_modules"
echo "Modules with dependencies: $modules_with_deps"
echo "Modules depended upon: $modules_depended_on"

# Find most depended upon
echo -e "\n${GREEN}Most depended upon:${NC}"
for module in "${!reverse_deps[@]}"; do
    count=$(echo "${reverse_deps[$module]}" | wc -w | tr -d ' ')
    echo "$count $module"
done | sort -rn | head -5 | while read count module; do
    echo "  $module ($count dependencies)"
done

# Find modules with most dependencies
echo -e "\n${YELLOW}Most dependencies:${NC}"
for module in "${!dependencies[@]}"; do
    count=$(echo "${dependencies[$module]}" | wc -w | tr -d ' ')
    echo "$count $module"
done | sort -rn | head -5 | while read count module; do
    echo "  $module ($count dependencies)"
done

# Check for potential issues
echo -e "\n${BLUE}Potential Issues${NC}"
echo "==============="

# Check for circular dependencies (simple check)
circular_found=false
for module in "${!dependencies[@]}"; do
    for dep in ${dependencies[$module]}; do
        if [[ "${dependencies[$dep]}" == *"$module"* ]]; then
            echo -e "${YELLOW}⚠ Potential circular dependency: $module <-> $dep${NC}"
            circular_found=true
        fi
    done
done

if [ "$circular_found" = false ]; then
    echo -e "${GREEN}✓ No circular dependencies detected${NC}"
fi