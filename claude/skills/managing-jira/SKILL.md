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

## Workflow Patterns

### Start Work on Issue

```bash
jira issue assign PROJ-123 $(jira me)
jira issue move PROJ-123 "In Progress"
```

### Complete Issue

```bash
jira issue move PROJ-123 "Done" --resolution "Fixed"
jira issue comment add PROJ-123 -b"Completed in PR #123"
```

### Daily Standup

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

1. **Use `$(jira me)` for current user** instead of hardcoding email addresses
2. **Prefer non-interactive mode** with `--no-input` and explicit flags
3. **Validate transitions** by checking available transitions first
4. **Use `--plain --no-headers`** when parsing output programmatically
5. **Write multi-line content to /tmp first** - the CLI struggles with inline multi-line strings

## References

- [cli-reference.md](references/cli-reference.md) - Complete command reference with all flags and options
- [jql-reference.md](references/jql-reference.md) - Advanced JQL queries, operators, functions, and bulk operations
