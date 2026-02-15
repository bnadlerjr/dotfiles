---
name: managing-linear
description: Manages Linear issues via CLI using linearis (czottmann/linearis). Use when the user mentions Linear issue identifiers (e.g., 'ENG-123'), teams, cycles, projects, labels, issue management, or workflow automation. Handles issue CRUD, comments, cycle/project/label/team/user listing, document management, file embeds, search, and GitHub/GitLab PR linking via issue identifiers.
allowed-tools:
  - Bash
---

# Managing Linear

CLI-based Linear operations using linearis (czottmann/linearis).

## Quick Start

Verify authentication before any operation:

```bash
npx -y linearis teams list
```

If this fails, inform the user to set up authentication:
1. Get a Personal API key from Linear: Settings > "Security & Access" > "Personal API keys"
2. Save the token to `~/.linear_api_token`, or export `LINEAR_API_TOKEN=<token>`

## Workflow Patterns

### Start Work on Issue

```bash
# Read the issue
npx -y linearis issues read ENG-123

# Update status to In Progress
npx -y linearis issues update ENG-123 --status "In Progress"
```

### Complete Issue

```bash
# Move to done and add a comment
npx -y linearis issues update ENG-123 --status "Done"
npx -y linearis comments create ENG-123 --body "Completed in PR #456"
```

### Daily Standup

```bash
# My in-progress issues
npx -y linearis issues search "" --team "Engineering" | jq '[.[] | select(.status.name == "In Progress")]'

# Current cycle issues
npx -y linearis cycles list --team "Engineering" --active
```

### Link PR to Issue

Include the issue identifier (e.g., `ENG-123`) in your Git branch name, PR title, or PR description. Linear's GitHub/GitLab integration automatically links PRs to issues when it detects the identifier.

## Error Handling

```bash
# Check if issue exists
if ! npx -y linearis issues read ENG-123 >/dev/null 2>&1; then
    echo "Issue not found"
fi

# Check available teams before scoping
npx -y linearis teams list | jq '.[].name'

# Check available labels before assigning
npx -y linearis labels list --team "Engineering" | jq '.[].name'
```

## Best Practices

1. **All output is JSON** - pipe to `jq` for parsing and filtering
2. **Use smart ID resolution** - `linearis` accepts both IDs and human-readable names for teams, projects, and cycles
3. **Priority scale is inverted** - 0 = No priority, 1 = Urgent, 2 = High, 3 = Medium, 4 = Low
4. **Use label management modes** - `--label-by adding` (default), `replacing`, or `removing` to control label behavior
5. **Scope searches with --team and --project** for faster, more relevant results
6. **Write multi-line content to /tmp first** when creating documents or descriptions with complex markdown

## References

- [cli-reference.md](references/cli-reference.md) - Complete command reference with all flags and options
- [filter-reference.md](references/filter-reference.md) - Filtering, searching, and query patterns
