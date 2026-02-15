# Phase 5: Prune Redundant

Identify and flag instructions that should be deleted because they add no value.

## Inputs

- All newly written files (root + guidelines/)
- Original source files for comparison
- Deletion criteria from `references/deletion-criteria.md`

## Procedure

### 1. Scan for Deletion Candidates

Scan every instruction in the new files against these six deletion categories:

| Category | Flag When | Delete Example | Keep Example |
|----------|-----------|----------------|--------------|
| **Agent default** | Agent already does this without being told | "Write clean, maintainable code", "Read existing code before modifying" | "Use snake_case for DB columns" (specific rule) |
| **Too vague** | Not actionable, no specific behavior change | "Follow best practices", "Use appropriate error handling" | "Return Result types from fallible functions" (specific) |
| **Overly obvious** | Any competent developer would do this | "Test your code", "Make sure the code compiles" | "Minimum 80% coverage on payment modules" (specific threshold) |
| **Duplicates built-in** | Restates default tool behavior | "Use git for version control", "Format with Prettier" (if pre-commit handles it) | "Run `mix credo` before push" (no pre-commit hook) |
| **Outdated** | References deprecated tools/versions/patterns | "Use Webpack 4" (project uses Vite now) | Only flag if confirmed outdated from codebase |
| **Aspirational** | Describes ideal state, not an actionable rule | "Strive for 100% coverage", "Try to keep PRs small" | "PRs must change <300 lines" (concrete threshold) |

**Decision rule**: If removing the instruction would NOT change the agent's behavior, flag it. If removing it WOULD change behavior, keep it. When in doubt, keep it and let the user decide.

For additional detail, examples, and presentation format, read `references/deletion-criteria.md`.

### 2. Present Deletion Candidates

Group candidates by category and present for user review:

```
## Deletion Candidates

### Agent Already Knows (N items)
These instructions restate behavior the agent does by default:

1. **"Write clean, readable code"** (from guidelines/code-style.md:12)
   - Why: All LLM agents produce clean code by default. This wastes tokens.
   - Recommendation: DELETE

2. **"Handle errors appropriately"** (from guidelines/error-handling.md:5)
   - Why: Too vague to change behavior. Agent already handles errors.
   - Recommendation: DELETE or REWRITE to be specific

### Too Vague (N items)
These instructions don't specify what behavior to change:

1. **"Follow best practices"** (from guidelines/architecture.md:8)
   - Why: Which best practices? This is not actionable.
   - Recommendation: DELETE or REWRITE with specific practices

### Redundant Source Files (N items)
These original files are now fully represented in the new structure:

1. **`.cursorrules`** — All instructions migrated to guidelines/
   - Recommendation: DELETE file (or archive)

[etc.]
```

### 3. Get User Decisions

For each candidate, the user can:
- **DELETE** — Remove the instruction entirely
- **REWRITE** — Provide a more specific version (rewrite it for them with a specific suggestion)
- **KEEP** — Leave as-is (user disagrees with the flag)

### 4. Apply Decisions

- Delete approved items from the category files
- Rewrite items the user asked to improve
- Leave kept items unchanged
- For redundant source files: delete or archive as user directs

### 5. Final Summary

```
## Pruning Complete

- **Deleted**: N instructions removed
- **Rewritten**: N instructions improved
- **Kept**: N flagged items retained by user choice
- **Source files removed**: [list, if any]

## Final Structure

project-root/
├── CLAUDE.md              # N lines
└── guidelines/
    ├── code-style.md      # N lines
    ├── testing.md         # N lines
    ├── git-workflow.md    # N lines
    └── [etc.]             # N lines

Total: N lines across M files (down from X lines in Y files)
```

## Outputs

- Updated category files with deletions and rewrites applied
- Summary of all changes
- Before/after line counts
- Final file tree

## Verification

After pruning, re-run the verification checklist from SKILL.md:

1. Root file is under 50 lines
2. All links resolve
3. No contradictions
4. Every remaining instruction is actionable
5. No instructions lost without user approval
6. Each file is self-contained
