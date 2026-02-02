---
name: managing-claude-docs
description: Manages Claude documentation in Obsidian vault - plans, research, tickets, architecture, handoffs. Use when creating, organizing, or referencing Claude documentation, or when needing document paths and metadata.
---

# Managing Claude Docs

Centralized documentation management for Claude workflows, stored in an Obsidian vault.

## Quick Start

Before creating any document:
```bash
# Get the correct path
DOCS_DIR=$(claude-docs-path plans)    # or: research, tickets, architecture, handoffs

# Get metadata for the document
git metadata
```

## Document Types

| Type | Path | Purpose |
|------|------|---------|
| Plans | `claude-docs-path plans` | Implementation plans |
| Research | `claude-docs-path research` | Codebase investigations |
| Tickets | `claude-docs-path tickets` | Work items |
| Architecture | `claude-docs-path architecture` | Design decisions |
| Handoffs | `claude-docs-path handoffs` | Context for continuity |

## Creating Documents

### Step 1: Get Metadata

```bash
git metadata
```

Output:
- `Current Date/Time (TZ)` - For document header
- `Current Git Commit Hash` - For context
- `Current Branch Name` - For context
- `Repository Name` - For Project field
- `Area` - For frontmatter
- `Timestamp For Filename` - Use this in filename

### Step 2: Resolve Path

```bash
claude-docs-path <type>
```

Examples:
```bash
claude-docs-path plans        # → ~/Obsidian/Vault/Claude/Projects/myapp/plans
claude-docs-path research     # → ~/Obsidian/Vault/Claude/Projects/myapp/research
```

### Step 3: Create File

Filename pattern: `YYYY-MM-DD-description.md`

### Step 4: Add Frontmatter

All documents need Obsidian-compatible frontmatter:

```yaml
---
tags: [<type>, ai, resource]
Area: <from git metadata>
Created: [[YYYY-MM-DD]]
Modified: YYYY-MM-DD
Project: [[<repository name>]]
AutoNoteMover: disable
---
```

## Templates

- [Research Document Template](templates/research-document.md)
- [Plan Template](templates/plan-template.md)

## Environment Setup

Set `CLAUDE_DOCS_ROOT` to your Obsidian vault path:

```bash
export CLAUDE_DOCS_ROOT=~/Dropbox/Obsidian/Vault/Claude/Projects
```

If unset, falls back to `.claude/docs/` (project-local).

## Finding Existing Docs

Use the `docs-locator` agent to search existing documentation:

```
Search for existing research on authentication in the docs directory
```

## Troubleshooting

**`git metadata` fails:**
- Verify you're in a git repository: `git rev-parse --git-dir`
- Check if the command exists: `which git-metadata` or check aliases
- Fall back to manual: `git log -1 --format="%H"` for commit hash

**`claude-docs-path` returns nothing:**
- Check if `CLAUDE_DOCS_ROOT` is set: `echo $CLAUDE_DOCS_ROOT`
- Fall back to `.claude/docs/` in project root
