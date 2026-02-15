# CLI Reference

Complete reference for the `linearis` CLI (czottmann/linearis).

## Discovery

```bash
# Show available tools
npx -y linearis

# Display all commands (token-efficient)
npx -y linearis usage

# Get subcommand details
npx -y linearis issues
npx -y linearis cycles
npx -y linearis documents
```

## Authentication

Precedence order:
1. Command flag: `linearis --api-token <token> issues list`
2. Environment variable: `LINEAR_API_TOKEN=<token>`
3. Config file: `~/.linear_api_token`

Token: Linear > Settings > "Security & Access" > "Personal API keys"

## Viewing Issues

```bash
# View single issue (supports ABC-123 format)
npx -y linearis issues read ENG-123

# JSON output includes: identifier, title, description, status,
# priority, parentIssue, subIssues, embeds
npx -y linearis issues read ENG-123 | jq '.title'
```

## Listing Issues

```bash
# List issues (default limit)
npx -y linearis issues list

# Limit results
npx -y linearis issues list -l 10
npx -y linearis issues list --limit 20

# Parse output with jq
npx -y linearis issues list -l 5 | jq '.[] | .identifier + ": " + .title'
```

## Searching Issues

```bash
# Text search
npx -y linearis issues search "login bug"

# Scope by team
npx -y linearis issues search "login bug" --team "Engineering"

# Scope by project
npx -y linearis issues search "migration" --project "Platform Upgrade"

# Combine team and project scope
npx -y linearis issues search "auth" --team "Backend" --project "Security"

# Empty query with scope (list all in team/project)
npx -y linearis issues search "" --team "Engineering"
```

## Creating Issues

```bash
# Minimal creation
npx -y linearis issues create "Fix login timeout" --team "Engineering"

# Full creation with all options
npx -y linearis issues create "Add export feature" \
    --team "Engineering" \
    --assignee user-id \
    --labels "backend,feature" \
    --priority 2 \
    --description "Users need CSV export for reports"

# Priority scale: 0=None, 1=Urgent, 2=High, 3=Medium, 4=Low
```

### Multi-line Content

Write complex descriptions to `/tmp` first:

```bash
cat > /tmp/linear_desc.md <<'EOF'
## Description
Users need the ability to export report data.

## Requirements
- Support CSV format
- Support JSON format
- Include date range filter
EOF

npx -y linearis issues create "Add export feature" \
    --team "Engineering" \
    --description "$(cat /tmp/linear_desc.md)"
```

## Updating Issues

```bash
# Update status
npx -y linearis issues update ENG-123 --status "In Progress"
npx -y linearis issues update ENG-123 --status "Done"

# Update priority
npx -y linearis issues update ENG-123 --priority 2

# Add labels (default mode: adding)
npx -y linearis issues update ENG-123 --labels "urgent,backend"

# Replace all labels
npx -y linearis issues update ENG-123 --labels "frontend,redesign" --label-by replacing

# Remove specific labels
npx -y linearis issues update ENG-123 --labels "deprecated" --label-by removing

# Clear all labels
npx -y linearis issues update ENG-123 --clear-labels

# Set parent issue (sub-issue relationship)
npx -y linearis issues update ENG-123 --parent-ticket ENG-100

# Combine updates
npx -y linearis issues update ENG-123 --status "In Review" --priority 2 --labels "review-needed"
```

### Label Management Modes

| Mode | Flag | Behavior |
|------|------|----------|
| Adding | `--label-by adding` | Appends to existing labels (default) |
| Replacing | `--label-by replacing` | Replaces all existing labels |
| Removing | `--label-by removing` | Removes specified labels |
| Clear | `--clear-labels` | Removes all labels |

## Comments

```bash
# Add comment to issue
npx -y linearis comments create ENG-123 --body "Investigated the root cause, it's a race condition"

# Multi-line comment
cat > /tmp/linear_comment.md <<'EOF'
## Investigation

Found the race condition in the auth middleware.

### Steps to reproduce
1. Open two tabs
2. Login simultaneously
3. Observe token collision
EOF

npx -y linearis comments create ENG-123 --body "$(cat /tmp/linear_comment.md)"
```

## Cycles

```bash
# List cycles for a team
npx -y linearis cycles list --team "Engineering"

# Limit results
npx -y linearis cycles list --team "Engineering" --limit 5

# Active cycle only
npx -y linearis cycles list --active

# Active cycle for a specific team
npx -y linearis cycles list --team "Engineering" --active

# Cycles around the active one (offset: number of cycles before/after)
npx -y linearis cycles list --team "Engineering" --around-active 2

# Read a specific cycle (by name or ID)
npx -y linearis cycles read "Sprint 42" --team "Engineering"
npx -y linearis cycles read cycle-uuid-here
```

### Valid Cycle Flag Combinations

| Flags | Behavior |
|-------|----------|
| `--team` alone | All cycles for that team |
| `--active` alone | Active cycle across teams |
| `--team` + `--active` | Active cycle for that team |
| `--team` + `--around-active` | Cycles near the active one for that team |

**Note**: `--around-active` requires `--team`.

## Projects

```bash
# List all projects
npx -y linearis projects list

# Parse project names
npx -y linearis projects list | jq '.[].name'
```

## Labels

```bash
# List all labels
npx -y linearis labels list

# List labels for a specific team
npx -y linearis labels list --team "Engineering"

# Parse label names
npx -y linearis labels list | jq '.[].name'
```

## Teams

```bash
# List all teams
npx -y linearis teams list

# Parse team names
npx -y linearis teams list | jq '.[].name'
```

## Users

```bash
# List all users
npx -y linearis users list

# List active users only
npx -y linearis users list --active

# Parse user names and IDs
npx -y linearis users list --active | jq '.[] | {name: .name, id: .id}'
```

## Documents

```bash
# Create a document
npx -y linearis documents create --title "Architecture Decision" --content "## Context\n..."

# Create and attach to project
npx -y linearis documents create --title "Sprint Retro" --content "Notes..." --project "Platform"

# Create and attach to issue
npx -y linearis documents create --title "Investigation Notes" --content "Findings..." --attach-to ENG-123

# List documents
npx -y linearis documents list

# List documents for a project
npx -y linearis documents list --project "Platform"

# List documents attached to an issue
npx -y linearis documents list --issue ENG-123

# Read a document
npx -y linearis documents read document-uuid-here

# Update a document
npx -y linearis documents update document-uuid-here --title "Updated Title"
npx -y linearis documents update document-uuid-here --content "New content"
npx -y linearis documents update document-uuid-here --title "New Title" --content "New content"

# Delete a document
npx -y linearis documents delete document-uuid-here
```

### Multi-line Document Content

```bash
cat > /tmp/linear_doc.md <<'EOF'
## Sprint Retrospective

### What went well
- Shipped auth feature on time
- Zero production incidents

### What to improve
- Better estimation for frontend work
EOF

npx -y linearis documents create \
    --title "Sprint 42 Retro" \
    --content "$(cat /tmp/linear_doc.md)" \
    --project "Platform"
```

## Embeds (File Attachments)

```bash
# Upload a file (returns JSON with assetUrl)
npx -y linearis embeds upload /path/to/screenshot.png
# Output: { "success": true, "assetUrl": "https://...", "filename": "screenshot.png" }

# Download an embed
npx -y linearis embeds download "https://linear-asset-url" --output /tmp/downloaded-file.png

# Download with overwrite
npx -y linearis embeds download "https://linear-asset-url" --output /tmp/file.png --overwrite
```

## Flag Reference

### Issues

| Flag | Description |
|------|-------------|
| `--team <name>` | Team name (required for create, optional for search) |
| `--assignee <id>` | User ID to assign |
| `--labels "a,b"` | Comma-separated label names |
| `--label-by <mode>` | Label mode: adding, replacing, removing |
| `--clear-labels` | Remove all labels |
| `--priority <0-4>` | Priority: 0=None, 1=Urgent, 2=High, 3=Medium, 4=Low |
| `--description <text>` | Issue description |
| `--status "<name>"` | Workflow state name |
| `--parent-ticket <id>` | Parent issue identifier |
| `-l, --limit <n>` | Limit number of results |
| `--project <name>` | Project name (search scoping) |

### Cycles

| Flag | Description |
|------|-------------|
| `--team <name>` | Team name |
| `--limit <n>` | Limit number of results |
| `--active` | Active cycle only |
| `--around-active <n>` | Cycles near active (requires --team) |

### Documents

| Flag | Description |
|------|-------------|
| `--title "<text>"` | Document title |
| `--content "<text>"` | Document content (markdown) |
| `--project <name>` | Attach to project |
| `--attach-to <id>` | Attach to issue |
| `--issue <id>` | Filter by issue (list only) |

### Embeds

| Flag | Description |
|------|-------------|
| `--output <path>` | Download destination path |
| `--overwrite` | Overwrite existing file |

## Priority Scale

| Value | Meaning |
|-------|---------|
| 0 | No priority |
| 1 | Urgent |
| 2 | High |
| 3 | Medium |
| 4 | Low |

**Note**: This is inverted from typical scales. Lower numbers = higher urgency.

## Linear Data Model

| Linear | Jira Equivalent |
|--------|----------------|
| Issue | Issue/Ticket |
| Cycle | Sprint |
| Project | Epic |
| Team | Project |
| Status | Status (workflow states) |
| Priority 0-4 | Priority levels |
| Label | Label |
| Document | n/a (Confluence) |
