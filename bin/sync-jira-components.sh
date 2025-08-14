#!/bin/bash
# Script to sync Jira tasks with TaskWarrior
# - Updates projects based on Jira components
# - Unescapes HTML entities in summaries and descriptions
# Run this after bugwarrior-pull to fix both issues

set -e

# Function to get component for a Jira issue using jira CLI
get_component_for_issue() {
    local issue_id="$1"
    
    # Extract component from jira CLI output
    # The component appears after the 📦 emoji in the output
    component=$(jira issue view "$issue_id" 2>/dev/null | \
        grep "📦" | \
        sed 's/.*📦[[:space:]]*//' | \
        sed 's/[[:space:]]*🏷️.*//' | \
        tr '[:upper:]' '[:lower:]' | \
        tr ' ' '_')
    
    echo "$component"
}

# Function to unescape HTML entities
unescape_html() {
    local text="$1"
    # Replace common HTML entities that taskw incorrectly uses
    text="${text//&open;/[}"
    text="${text//&close;/]}"
    text="${text//&dquot;/\"}"
    text="${text//&quot;/\"}"
    text="${text//&apos;/\'}"
    text="${text//&amp;/&}"
    text="${text//&lt;/<}"
    text="${text//&gt;/>}"
    echo "$text"
}

# Function to escape for task command
escape_for_task() {
    local text="$1"
    # Escape backslashes and quotes for task command
    text="${text//\\/\\\\}"
    text="${text//\"/\\\"}"
    echo "$text"
}

echo "Syncing Jira tasks with TaskWarrior..."
echo "  • Setting projects from components"
echo "  • Unescaping HTML entities"
echo ""

# Counters for progress
component_updates=0
unescape_updates=0
skipped=0
errors=0

# Get all pending Jira tasks with their fields
while IFS='|' read -r uuid jiraid jirasummary description; do
    if [ -n "$uuid" ] && [ -n "$jiraid" ]; then
        modifications=""
        update_desc=""
        
        # Check if we need to update the project from component
        component=$(get_component_for_issue "$jiraid")
        if [ -n "$component" ]; then
            modifications="project:\"$component\""
            update_desc="project=$component"
            ((component_updates++)) || true
        else
            ((skipped++)) || true
        fi
        
        # Check if we need to unescape HTML entities in summary
        if [[ "$jirasummary" == *"&open;"* ]] || [[ "$jirasummary" == *"&close;"* ]] || [[ "$jirasummary" == *"&dquot;"* ]]; then
            unescaped_summary=$(unescape_html "$jirasummary")
            escaped_summary=$(escape_for_task "$unescaped_summary")
            if [ -n "$modifications" ]; then
                modifications="$modifications jirasummary:\"$escaped_summary\""
                update_desc="$update_desc, unescaped summary"
            else
                modifications="jirasummary:\"$escaped_summary\""
                update_desc="unescaped summary"
            fi
            ((unescape_updates++)) || true
        fi
        
        # Check if we need to unescape HTML entities in description
        if [[ "$description" == *"&open;"* ]] || [[ "$description" == *"&close;"* ]] || [[ "$description" == *"&dquot;"* ]]; then
            unescaped_description=$(unescape_html "$description")
            escaped_description=$(escape_for_task "$unescaped_description")
            if [ -n "$modifications" ]; then
                modifications="$modifications description:\"$escaped_description\""
                update_desc="$update_desc, unescaped description"
            else
                modifications="description:\"$escaped_description\""
                update_desc="unescaped description"
            fi
            ((unescape_updates++)) || true
        fi
        
        # Apply all modifications in a single command if needed
        if [ -n "$modifications" ]; then
            echo "  ✓ $jiraid: $update_desc"
            # Use eval with properly escaped values
            if ! eval "task \"$uuid\" modify $modifications" 2>/dev/null; then
                echo "    ⚠ Failed to update task"
                ((errors++)) || true
            fi
        fi
    fi
done < <(task jiraid.any: status:pending export 2>/dev/null | jq -r '.[] | "\(.uuid)|\(.jiraid)|\(.jirasummary // "")|\(.description // "")"')

echo ""
echo "Done!"
echo "  • Component updates: $component_updates"
echo "  • HTML unescaping: $unescape_updates"
echo "  • Skipped (no component): $skipped"
echo "  • Errors: $errors"