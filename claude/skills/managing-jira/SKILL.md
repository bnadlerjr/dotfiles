---
name: managing-jira
description: Interacts with Jira via CLI for ticket operations. Use when the user mentions ticket identifiers (e.g., 'ABC-123'), discusses work tracking, references Jira projects, or needs search, create, edit, transition, comment, assign, or sprint/epic management. Handles JQL queries, workflow automation, and bulk operations using jira-cli (ankitpokhrel/jira-cli).
---

# Managing Jira

CLI-based Jira operations using jira-cli (ankitpokhrel/jira-cli).

## Quick Start

Verify authentication before any operation:

```bash
jira me
```

If this fails, inform the user to run `jira init` to configure authentication.

## Core Operations

### Search and List Issues

**By assignee:**
```bash
jira issue list --assignee $(jira me)              # My issues
jira issue list --assignee "user@example.com"     # Specific user
jira issue list --assignee "unassigned"           # Unassigned
```

**By status/project:**
```bash
jira issue list --status "In Progress"
jira issue list --project PROJ --type Bug --priority High
```

**Current sprint:**
```bash
jira sprint list --current
jira issue list --jql "sprint in openSprints() AND assignee = currentUser()"
```

**Output formats:**
```bash
jira issue list --plain --no-headers           # For scripting
jira issue list --plain --columns key,summary  # Specific columns
```

### View Issue Details

```bash
jira issue view PROJ-123                # Full details
jira issue view PROJ-123 --comments 5   # Include last 5 comments
jira issue view PROJ-123 --raw          # JSON output
jira open PROJ-123                      # Open in browser
```

### Create Issues

```bash
jira issue create \
    --project PROJ \
    --type Story \
    --summary "Summary text" \
    --body "Description text" \
    --priority High \
    --assignee $(jira me)
```

**With labels:**
```bash
jira issue create \
    --project PROJ \
    --type Bug \
    --summary "Bug description" \
    --label backend \
    --label security
```

**Under an epic:**
```bash
jira issue create \
    --project PROJ \
    --type Story \
    --summary "Feature work" \
    --parent PROJ-100  # Epic key
```

**Capture created key:**
```bash
issue_key=$(jira issue create --project PROJ --type Task --summary "Test" --no-input 2>&1 | grep -o 'PROJ-[0-9]*')
```

### Edit/Update Issues

```bash
jira issue edit PROJ-123 --summary "New summary"
jira issue edit PROJ-123 --body "New description"
jira issue edit PROJ-123 --priority High
jira issue edit PROJ-123 --assignee $(jira me)
jira issue edit PROJ-123 --label "new-label"
jira issue edit PROJ-123 --parent PROJ-100  # Add to epic
jira issue edit PROJ-123 --parent ""         # Remove from epic
```

### Transition Issues

**View available transitions:**
```bash
jira issue transitions PROJ-123
```

**Move to status:**
```bash
jira issue move PROJ-123 "In Progress"
jira issue move PROJ-123 "Done"
jira issue move PROJ-123 "Done" --resolution "Fixed"
```

### Comments

```bash
jira issue comment add PROJ-123 -b"Comment text"
jira issue comment add PROJ-123 --template /path/to/comment.md
```

### Assign Issues

```bash
jira issue assign PROJ-123 $(jira me)           # Self-assign
jira issue assign PROJ-123 "user@example.com"   # Specific user
jira issue assign PROJ-123 x                    # Unassign
jira issue assign PROJ-123 default              # Default assignee
```

### Link Issues

```bash
jira issue link PROJ-123 PROJ-124 "Blocks"    # PROJ-123 blocks PROJ-124
jira issue link PROJ-123 PROJ-125 "Relates"
jira issue link PROJ-123 PROJ-126 "Duplicate"
jira issue link PROJ-EPIC PROJ-STORY "Epic-Story"
```

## Sprint & Epic Operations

**Sprints:**
```bash
jira sprint list --project PROJ
jira sprint list --current
jira sprint add SPRINT-ID PROJ-123              # Add to sprint
```

**Epics:**
```bash
jira issue list --project PROJ --type Epic      # List epics
jira issue list --jql "\"Epic Link\" = PROJ-100" # Issues in epic
```

## Workflow Patterns

**Start work on issue:**
```bash
jira issue move PROJ-123 "In Progress"
jira issue assign PROJ-123 $(jira me)
```

**Complete issue:**
```bash
jira issue move PROJ-123 "Done" --resolution "Fixed"
jira issue comment add PROJ-123 -b"Completed in PR #123"
```

**Daily standup:**
```bash
jira issue list --jql "assignee = currentUser() AND status = 'In Progress'"
jira issue list --jql "assignee = currentUser() AND status = 'Blocked'"
```

## Error Handling

```bash
# Check if issue exists
if ! jira issue view PROJ-123 >/dev/null 2>&1; then
    echo "Issue not found"
fi

# Check if transition is valid
available=$(jira issue transitions PROJ-123 2>/dev/null)
if ! echo "$available" | grep -q "In Progress"; then
    echo "Cannot transition to In Progress"
fi
```

## Best Practices

1. **Always use `$(jira me)`** for current user instead of hardcoding
2. **Prefer non-interactive mode** with `--no-input` and explicit flags
3. **Validate transitions** by checking available transitions first
4. **Use `--plain --no-headers`** when parsing output programmatically
5. **Write multi-line content to /tmp first** - the CLI chokes on multi-line strings:
   ```bash
   cat > /tmp/jira_body.md <<'EOF'
   Description content here...
   EOF
   jira issue create -tStory -s"Summary" -b"$(cat /tmp/jira_body.md)" --no-input
   ```

## References

- [cli-reference.md](references/cli-reference.md) - Complete command reference with all flags and options
- [jql-reference.md](references/jql-reference.md) - Advanced JQL queries, operators, functions, and bulk operations
