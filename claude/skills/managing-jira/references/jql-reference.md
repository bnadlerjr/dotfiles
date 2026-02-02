# JQL Reference

Advanced JQL syntax and bulk operations for jira-cli.

## Operators

`=`, `!=`, `IN`, `NOT IN`, `~`, `>`, `<`, `>=`, `<=`, `IS`, `IS NOT`

## Functions

| Function | Description |
|----------|-------------|
| `currentUser()` | Current logged-in user |
| `openSprints()` | Active sprints |
| `closedSprints()` | Completed sprints |
| `startOfDay()`, `endOfDay()` | Day boundaries |
| `startOfWeek()`, `endOfWeek()` | Week boundaries |

## Date Ranges

```jql
updated >= -7d                    # Last 7 days
created >= startOfWeek()          # This week
resolved < endOfDay(-30)          # Resolved more than 30 days ago
```

## Text Search

```jql
summary ~ "keyword"               # Contains keyword
description ~ "exact phrase"      # Phrase search
```

## Common Queries

```bash
# My overdue tickets
jira issue list --jql "assignee = currentUser() AND duedate < now() AND status != Done"

# Unassigned high-priority bugs
jira issue list --jql "assignee IS EMPTY AND type = Bug AND priority IN (Highest, High)"

# Recently updated by others
jira issue list --jql "assignee = currentUser() AND updated >= -1d AND updatedBy != currentUser()"

# Issues in specific epic
jira issue list --jql "\"Epic Link\" = PROJ-123"

# Multiple statuses
jira issue list --jql "status IN ('To Do', 'In Progress')"

# Updated this week
jira issue list --jql "updated >= -7d AND assignee = currentUser()"

# High priority bugs
jira issue list --jql "type = Bug AND priority IN (Highest, High)"

# Issues with specific labels
jira issue list --jql "labels IN (backend, api)"
```

## Ordering

```jql
ORDER BY priority DESC, updated DESC, created ASC
```

## Bulk Operations

**Important**: Always verify JQL results before bulk operations.

**Transition all To Do tickets to In Progress:**
```bash
for issue in $(jira issue list --jql "status='To Do' AND assignee = currentUser()" --plain --columns KEY | tail -n +2); do
    jira issue move "$issue" "In Progress"
done
```

**Add label to sprint tickets:**
```bash
for ticket in $(jira issue list --jql "sprint in openSprints()" --plain --columns KEY | tail -n +2); do
    jira issue edit "$ticket" --label "sprint-active"
done
```

**Assign unassigned bugs to me:**
```bash
for bug in $(jira issue list --jql "type = Bug AND assignee IS EMPTY" --plain --columns KEY | tail -n +2); do
    jira issue assign "$bug" $(jira me)
done
```
