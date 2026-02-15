# Filter Reference

Filtering, searching, and query patterns for the `linearis` CLI.

## Search

`linearis issues search` is the primary filtering tool. It accepts a text query and optional scope flags.

```bash
# Text search across all issues
npx -y linearis issues search "search terms"

# Scope to team
npx -y linearis issues search "search terms" --team "Engineering"

# Scope to project
npx -y linearis issues search "search terms" --project "Platform Upgrade"

# Scope to both
npx -y linearis issues search "search terms" --team "Engineering" --project "Platform Upgrade"

# Empty query returns all issues in scope
npx -y linearis issues search "" --team "Engineering"
```

## Filtering with jq

All `linearis` output is JSON. Use `jq` for client-side filtering.

### By Status

```bash
# Issues in a specific status
npx -y linearis issues list | jq '[.[] | select(.status.name == "In Progress")]'

# Issues NOT in a status
npx -y linearis issues list | jq '[.[] | select(.status.name != "Done")]'

# Multiple statuses
npx -y linearis issues list | jq '[.[] | select(.status.name == "In Progress" or .status.name == "In Review")]'
```

### By Priority

```bash
# Urgent issues (priority 1)
npx -y linearis issues list | jq '[.[] | select(.priority == 1)]'

# High priority and above (urgent + high)
npx -y linearis issues list | jq '[.[] | select(.priority >= 1 and .priority <= 2)]'

# Issues with any priority set
npx -y linearis issues list | jq '[.[] | select(.priority > 0)]'
```

### By Assignee

```bash
# Issues assigned to a specific user
npx -y linearis issues list | jq '[.[] | select(.assignee.name == "Jane Doe")]'

# Unassigned issues
npx -y linearis issues list | jq '[.[] | select(.assignee == null)]'
```

### By Label

```bash
# Issues with a specific label
npx -y linearis issues list | jq '[.[] | select(.labels[]?.name == "bug")]'

# Issues with any of several labels
npx -y linearis issues list | jq '[.[] | select(any(.labels[]?.name; . == "bug" or . == "urgent"))]'
```

### Combined Filters

```bash
# High-priority bugs in progress
npx -y linearis issues list | jq '[.[] | select(.priority <= 2 and .priority > 0 and .status.name == "In Progress")]'

# Unassigned urgent issues
npx -y linearis issues list | jq '[.[] | select(.assignee == null and .priority == 1)]'
```

## Scoping by Team

```bash
# List available teams first
npx -y linearis teams list | jq '.[].name'

# Search within a team
npx -y linearis issues search "" --team "Engineering"
npx -y linearis issues search "auth" --team "Backend"

# Team-scoped labels
npx -y linearis labels list --team "Engineering"

# Team-scoped cycles
npx -y linearis cycles list --team "Engineering"
npx -y linearis cycles list --team "Engineering" --active
```

## Scoping by Project

```bash
# List available projects first
npx -y linearis projects list | jq '.[].name'

# Search within a project
npx -y linearis issues search "" --project "Platform Upgrade"

# Project-scoped documents
npx -y linearis documents list --project "Platform Upgrade"
```

## Cycle Queries

```bash
# Active cycle for a team
npx -y linearis cycles list --team "Engineering" --active

# Recent and upcoming cycles
npx -y linearis cycles list --team "Engineering" --around-active 2

# Read cycle details
npx -y linearis cycles read "Sprint 42" --team "Engineering"
```

## Common Queries

### My Work

```bash
# Find your user ID first
npx -y linearis users list --active | jq '.[] | select(.name == "Your Name") | .id'

# Then filter issues by assignee name
npx -y linearis issues search "" --team "Engineering" | jq '[.[] | select(.assignee.name == "Your Name")]'
```

### Sprint/Cycle Planning

```bash
# Current cycle
npx -y linearis cycles list --team "Engineering" --active

# All issues in the team
npx -y linearis issues search "" --team "Engineering" | jq '[.[] | select(.status.name != "Done" and .status.name != "Canceled")]'

# Unassigned issues
npx -y linearis issues search "" --team "Engineering" | jq '[.[] | select(.assignee == null)]'
```

### Bug Triage

```bash
# All bugs (assuming "bug" label exists)
npx -y linearis issues search "" --team "Engineering" | jq '[.[] | select(any(.labels[]?.name; . == "bug"))]'

# Unassigned bugs
npx -y linearis issues search "" --team "Engineering" | jq '[.[] | select(any(.labels[]?.name; . == "bug") and .assignee == null)]'

# High-priority issues without assignees
npx -y linearis issues search "" --team "Engineering" | jq '[.[] | select(.priority <= 2 and .priority > 0 and .assignee == null)]'
```

### Status Overview

```bash
# Count issues by status
npx -y linearis issues search "" --team "Engineering" | jq 'group_by(.status.name) | map({status: .[0].status.name, count: length})'

# Count issues by priority
npx -y linearis issues search "" --team "Engineering" | jq 'group_by(.priority) | map({priority: .[0].priority, count: length})'
```

## Bulk Operations

**Important**: Always verify results before bulk operations.

### Transition Multiple Issues

```bash
# Move all "To Do" issues to "In Progress" for a team
npx -y linearis issues search "" --team "Engineering" \
    | jq -r '.[] | select(.status.name == "To Do") | .identifier' \
    | while read -r id; do
        npx -y linearis issues update "$id" --status "In Progress"
    done
```

### Add Labels in Bulk

```bash
# Add "sprint-active" label to all in-progress issues
npx -y linearis issues search "" --team "Engineering" \
    | jq -r '.[] | select(.status.name == "In Progress") | .identifier' \
    | while read -r id; do
        npx -y linearis issues update "$id" --labels "sprint-active"
    done
```

### Update Priority in Bulk

```bash
# Set all no-priority bugs to Medium
npx -y linearis issues search "" --team "Engineering" \
    | jq -r '.[] | select(.priority == 0 and any(.labels[]?.name; . == "bug")) | .identifier' \
    | while read -r id; do
        npx -y linearis issues update "$id" --priority 3
    done
```

### Add Comment to Multiple Issues

```bash
# Add a comment to all issues in a project
npx -y linearis issues search "" --project "Platform Upgrade" \
    | jq -r '.[].identifier' \
    | while read -r id; do
        npx -y linearis comments create "$id" --body "Milestone deadline moved to March 15"
    done
```

## Output Formatting

```bash
# Compact issue list: identifier + title
npx -y linearis issues list | jq -r '.[] | .identifier + ": " + .title'

# Table-style output: identifier, status, priority, title
npx -y linearis issues list | jq -r '.[] | [.identifier, .status.name, (.priority | tostring), .title] | @tsv'

# JSON summary per issue
npx -y linearis issues list | jq '.[] | {id: .identifier, title: .title, status: .status.name, priority: .priority}'
```

## GitHub/GitLab PR Linking

Linear automatically links PRs to issues when the issue identifier appears in:
- Branch name: `feature/ENG-123-add-export`
- PR title: `ENG-123: Add CSV export feature`
- PR description: `Closes ENG-123`

No CLI command needed — the integration handles linking automatically.
