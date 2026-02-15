---
name: refactoring-agent-instructions
description: |
  Refactors bloated agent instruction files (CLAUDE.md, AGENTS.md, COPILOT.md, .cursorrules, etc.)
  to follow progressive disclosure — minimal root file linking to categorized files in guidelines/.
  Use when agent instructions are too long, hard to maintain, contain contradictions, or need reorganization.
---

# Refactoring Agent Instructions

Refactor bloated agent instruction files into a minimal root with linked category files in `guidelines/`.

## Quick Start

```
"My CLAUDE.md is 500 lines and hard to maintain"
"Clean up these agent instructions"
"Reorganize my project's coding guidelines"
```

## Example: Before and After

### Before — Bloated CLAUDE.md (~200 lines, everything inline)

```markdown
# CLAUDE.md

This is the Acme billing API, a Phoenix backend serving REST and GraphQL.

Run tests: mix test --warnings-as-errors
Run lint: mix credo --strict
Format: mix format

NEVER push directly to main. All changes go through PRs.
NEVER commit .env or secrets files.

Use 2-space indentation in all Elixir files.
Pipe chains should start with a raw value, not a function call.
Prefer pattern matching over conditional logic.
Module names must match directory structure.
Always add @moduledoc to public modules.
Use Ecto.Multi for operations touching 2+ tables.
Changesets must validate all user-facing input.
Keep schema fields alphabetized.

Tests go in test/ mirroring lib/ structure.
Use ExUnit.Case, not third-party test frameworks.
Prefer setup blocks over repeated build calls.
Name test files *_test.exs matching the module under test.
Minimum 80% coverage on payment modules.

Use feature/ prefix for branches.
Squash-merge all PRs.
Commit messages: imperative mood, 50-char subject, blank line, body.
Tag releases as vX.Y.Z.
```

### After — Minimal root + category files

**CLAUDE.md (18 lines)**
```markdown
# Acme Billing API

Phoenix backend for the Acme billing platform.

## Commands

- `mix test --warnings-as-errors`
- `mix credo --strict`
- `mix format`

## Rules

- NEVER push directly to main
- NEVER commit .env or secrets files

## Guidelines

- [Elixir](guidelines/elixir.md)
- [Testing](guidelines/testing.md)
- [Git Workflow](guidelines/git-workflow.md)
```

**guidelines/elixir.md (snippet)**
```markdown
# Elixir

## Style

- Use 2-space indentation in all Elixir files
- Pipe chains must start with a raw value, not a function call
- Prefer pattern matching over conditional logic

## Modules

- Module names must match directory structure
- Always add @moduledoc to public modules
...
```

## Output Structure

```
project-root/
├── CLAUDE.md (or AGENTS.md)     # Minimal root (<50 lines) with links
└── guidelines/                   # Categorized instruction files
    ├── typescript.md
    ├── testing.md
    ├── code-style.md
    ├── git-workflow.md
    └── architecture.md
```

## Phase Overview

| Phase | Workflow | Purpose |
|-------|----------|---------|
| 1. Analyze | `workflows/analyze-contradictions.md` | Find conflicting instructions |
| 2. Extract | `workflows/extract-essentials.md` | Identify what stays in root |
| 3. Categorize | `workflows/categorize-instructions.md` | Group into 3-8 linked files |
| 4. Structure | `workflows/create-structure.md` | Write all files |
| 5. Prune | `workflows/prune-redundant.md` | Flag redundant content for deletion |

## Discovery

Auto-discover agent instruction files. Read `references/discovery-patterns.md` for the full list of known filenames and locations to scan.

### Quick Discovery

Scan the project root for these files:
- `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/settings.json`
- `AGENTS.md`, `COPILOT.md`, `.github/copilot-instructions.md`
- `.cursorrules`, `cursor.md`, `.cursor/rules/*.md`
- `CODING_GUIDELINES.md`, `CONTRIBUTING.md`
- `.windsurfrules`, `cline_docs/`

Present discovered files to the user before proceeding.

## Workflow

### Step 1: Discover and Read

1. Scan project root using the discovery patterns
2. Read all discovered files
3. Present findings: "Found N agent instruction files totaling M lines"
4. Confirm with user which files to include

### Step 2: Run Phases 1-5 Sequentially

Execute each phase in order. Each phase reads its workflow file for detailed instructions.

**Phase 1 — Analyze**: Read `workflows/analyze-contradictions.md`
- Scan all files for conflicting instructions
- Present contradictions to user for resolution
- Record resolutions for use in later phases

**Phase 2 — Extract**: Read `workflows/extract-essentials.md`
- Separate essential root content from detailed content
- Use `references/essential-vs-detailed.md` for decision criteria
- Produce two lists: root content and content-to-categorize

**Phase 3 — Categorize**: Read `workflows/categorize-instructions.md`
- Group content-to-categorize into 3-8 logical files
- Use `references/category-templates.md` for file templates
- Produce a category map: `{category: [instructions]}`

**Phase 4 — Structure**: Read `workflows/create-structure.md`
- Create `guidelines/` directory at project root
- Write each category file using templates
- Rewrite root file with links to `guidelines/*.md`
- Verify all links resolve

**Phase 5 — Prune**: Read `workflows/prune-redundant.md`
- Use `references/deletion-criteria.md` to identify candidates
- Present deletion candidates to user
- Remove approved items

### Step 3: Verify

Run the verification checklist:
1. Root file is under 50 lines
2. All `guidelines/*.md` links resolve to existing files
3. No contradictions remain
4. Every instruction is actionable
5. No instructions lost (unless user-approved deletion)
6. Each linked file is self-contained

## Anti-Patterns

- Keeping everything in root (defeats progressive disclosure)
- Too many categories (>8 causes fragmentation)
- Too few categories (<3 means files are still bloated)
- Vague instructions that waste tokens
- Duplicating what agents already know by default
- Deep nesting beyond `guidelines/*.md`

## Guidelines

- Always confirm with the user before deleting any instruction
- Preserve the original file format (CLAUDE.md stays CLAUDE.md, not renamed)
- Category names should reflect actual project content, not generic labels
- Each category file must stand alone — no cross-references between category files
- Root file links use relative paths: `See [Testing](guidelines/testing.md)`

## References

- `references/discovery-patterns.md` — Known agent file names and scan locations
- `references/category-templates.md` — Templates for category files
- `references/deletion-criteria.md` — What to flag for deletion and why
- `references/essential-vs-detailed.md` — Root vs. linked decision criteria
