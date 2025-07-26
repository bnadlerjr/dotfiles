#!/usr/bin/env bash
#
# TaskWarrior Delete Old Tasks Script
# Deletes tasks older than X months (marks as deleted, keeps in database)
#
# Usage:
#   taskwarrior-delete-old.sh [months] [--dry-run] [--force]
#
# Examples:
#   taskwarrior-delete-old.sh          # Delete tasks older than 6 months (default)
#   taskwarrior-delete-old.sh 12       # Delete tasks older than 12 months
#   taskwarrior-delete-old.sh --dry-run 6   # Preview what would be deleted
#   taskwarrior-delete-old.sh --force 6     # Delete without confirmation

set -euo pipefail

# Default values
MONTHS_OLD=6
DRY_RUN=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        [0-9]*)
            MONTHS_OLD=$1
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 [months] [--dry-run] [--force]"
            exit 1
            ;;
    esac
done

# Date filter for tasks older than X months (only pending tasks)
DATE_FILTER="entry.before:now-${MONTHS_OLD}mo status:pending"

# Count tasks to be deleted
TASK_COUNT=$(task "$DATE_FILTER" count 2>/dev/null || echo "0")

if [[ $TASK_COUNT -eq 0 ]]; then
    echo "No tasks found older than $MONTHS_OLD months."
    exit 0
fi

echo "Found $TASK_COUNT tasks older than $MONTHS_OLD months."

# Dry run mode - show what would be deleted
if [[ $DRY_RUN == true ]]; then
    echo -e "\nDry run mode - no changes will be made."
    echo -e "\nSample of tasks that would be deleted (first 10):"
    task "$DATE_FILTER" limit:10 list
    exit 0
fi

# Confirmation prompt (unless forced)
if [[ $FORCE != true ]]; then
    echo -e "\nThis will mark $TASK_COUNT pending tasks as deleted."
    read -p "Continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
fi

# Delete tasks
echo "Deleting tasks older than $MONTHS_OLD months..."
if ! task "$DATE_FILTER" delete rc.confirmation=no; then
    echo "Error: Failed to delete tasks"
    exit 1
fi

echo -e "\nDone!"
echo "  Tasks deleted: $TASK_COUNT"
echo "  Note: Use 'task undo' to restore if needed"
