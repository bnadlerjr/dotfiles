---
description: Refactor bloated agent instruction files into minimal root + categorized guidelines/ files
argument-hint: "[path to instruction file, or omit to auto-discover]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion
---

# Refactor Agent Instructions

**Level 3 (Control Flow)** — Discovers agent instruction files (CLAUDE.md, AGENTS.md, COPILOT.md, .cursorrules, etc.), resolves their contradictions with the user, then rewrites them as a minimal root file linking to categorized files in `guidelines/`.

## Variables

- **TARGET**: `$ARGUMENTS` — path to a specific instruction file. Omit to auto-discover.

## Instructions

- Never delete an instruction without user approval.
- Preserve the original root filename. `CLAUDE.md` stays `CLAUDE.md`; do not rename it.
- Stop at each phase gate and get confirmation before continuing.
- Category names must reflect what the project actually contains, not a generic template.
- Each category file stands alone. No cross-references between files in `guidelines/`.
- Root links use relative paths: `[Testing](guidelines/testing.md)`.
- Produce 3-8 category files. Fewer means the files are still bloated; more fragments the content.
- Never nest below `guidelines/*.md`.
- Do not commit. Leave the working tree dirty so the user can review.

## Workflow

### Phase 0: Discover

If TARGET is set, use it and skip the scan. Otherwise scan the project root:

| Path | Agent |
|---|---|
| `CLAUDE.md`, `.claude/CLAUDE.md` | Claude Code |
| `AGENTS.md`, `CODING_GUIDELINES.md` | Generic |
| `COPILOT.md`, `.github/copilot-instructions.md` | GitHub Copilot |
| `.cursorrules`, `cursor.md`, `.cursor/rules/*.md`, `.cursor/rules/*.mdc` | Cursor |
| `.windsurfrules` | Windsurf |
| `.clinerules`, `cline_docs/` | Cline |
| `CONTRIBUTING.md` | Include only if it holds directives aimed at agents — grep for "AI", "agent", "Claude", "Copilot", "LLM". Exclude purely human contributor docs. |

Report `Found N files totaling M lines` as a table of file, line count, and target agent, then ask which to include.

Stop conditions:
- No files found: report it and stop.
- One file under 50 lines: report that it is already compact and offer an audit instead.
- Monorepo: scan the current project root only, not sub-packages.
- Files targeting different agents: ask whether to consolidate into one root file or refactor each separately. A single `guidelines/` directory can serve several root files.

### Phase 1: Analyze contradictions

Extract every instruction from the confirmed files. For each, record source `file:line`, category, directive, and strength (MUST, SHOULD, prefer, avoid, NEVER).

Cross-reference for conflicts:

| Type | Example |
|---|---|
| Direct contradiction | "Use tabs" vs "Use spaces" |
| Incompatible workflow | "Always write tests first" vs "Prototype without tests" |
| Conflicting tools | "Use npm" vs "Use yarn" |
| Scope overlap | Two files defining the same behavior differently |
| Strength mismatch | "MUST use X" vs "Prefer Y over X" |

Present each contradiction with both instructions quoted, their `file:line`, the conflict type, and three resolution options: keep A, keep B, or a suggested merged wording. Record the winner and its final wording for later phases.

The same instruction appearing in two files is duplication, not contradiction. Flag it for Phase 5.

Gate: resolve every contradiction before continuing. If the user defers one, mark it unresolved and revisit it in Phase 5.

### Phase 2: Extract essentials

The question for every instruction: *would a developer need this on every single task, regardless of what they are working on?* Yes means root. No means `guidelines/`.

| Instruction type | Root? | Example |
|---|---|---|
| Project description, 1-2 lines | YES | "Phoenix API for Acme billing" |
| Non-standard build/test/lint command | YES | `pnpm test`, `mix test --warnings-as-errors` |
| Standard command the agent would guess | NO | `npm test`, `pytest` |
| Critical override, serious harm if missed | YES | "NEVER push to main", "NEVER commit .env" |
| Universal rule affecting every file | YES | "All code must be TS strict mode" |
| Language-specific style | NO | "2-space indentation in Elixir" |
| Testing conventions | NO | Test file naming, mocking approach |
| Git workflow detail | NO | Branch naming, PR process |
| Architecture decision | NO | Design patterns, boundaries |
| Error handling, security, performance, API rules | NO | Context-specific |

Borderline items move out. One style rule alone does not justify root placement.

Produce two lists: root content (project description, non-standard commands, critical overrides, universal rules, links section) and category content grouped by destination. Estimate the root line count. Over 50, re-examine each item and move borderline ones out. Under 20 is fine.

Gate: present the classification and confirm it before writing anything.

### Phase 3: Categorize

Group the category content into 3-8 files. Categories emerge from the content, not from this table — use what fits, skip the rest.

| File | Covers |
|---|---|
| `code-style.md` | Formatting, naming, imports |
| `testing.md` | Framework, conventions, patterns, coverage |
| `git-workflow.md` | Branches, commit format, PR process, restrictions |
| `architecture.md` | Structure, design patterns, boundaries, data flow |
| `typescript.md`, `elixir.md`, `python.md` | Language-specific rules |
| `security.md` | Secrets, input validation, auth, sessions |
| `api-design.md` | URL structure, HTTP methods, response format, versioning |
| `error-handling.md` | Error types, exception strategy, logging, boundaries |
| `performance.md` | Caching, query optimization, bundle size, monitoring |
| `documentation.md` | Doc style, comments, READMEs |

Sizing: 30-100 lines per file. Merge a category under 10 lines into a related one. Split one over 150 lines. Never duplicate an instruction across categories; when it spans two, file it under the more specific one.

Order within each file: most impactful first, then by how often the rule applies, with related items grouped under sub-topic headings.

Names are lowercase kebab-case with a `.md` extension.

Gate: present the proposed structure with per-file line estimates and confirm.

### Phase 4: Write the structure

Run `mkdir -p guidelines`, then write each category file:

```markdown
# [Title matching the filename]

## [Sub-topic]

- [Actionable instruction]
- [Actionable instruction]
```

No frontmatter. Every line is a directive, not commentary. Add sub-topic headings only when 3+ instructions share a theme.

Rewrite the root file, keeping its original filename:

```markdown
# [Project Name]

[One-line description.]

## Commands

- **Test**: `[command]`
- **Lint**: `[command]`

## Critical Rules

- [Universal rule]
- [Critical override]

## Guidelines

- [Code Style](guidelines/code-style.md)
- [Testing](guidelines/testing.md)
```

Include the Commands section only for non-standard commands, and Critical Rules only for genuine overrides.

When several source files fed the refactor, pick one primary root (prefer `CLAUDE.md` for Claude Code projects) and consolidate into it. Leave the other source files in place; Phase 5 handles them.

Verify every root link resolves to a file in `guidelines/` and that the link text matches that file's title. Count the root lines. Over 50, move content out and tighten until it fits.

### Phase 5: Prune

Scan every instruction in the new files against these six categories:

| Category | Flag when | Delete | Keep |
|---|---|---|---|
| Agent default | The agent already does this untold | "Write clean, maintainable code" | "Use snake_case for DB columns" |
| Too vague | No specific behavior change | "Use appropriate error handling" | "Return Result types from fallible functions" |
| Overly obvious | Any competent developer does this | "Test your code" | "Minimum 80% coverage on payment modules" |
| Duplicates built-in | Restates default tool behavior | "Format with Prettier" when a pre-commit hook does it | "Run `mix credo` before push" when no hook exists |
| Outdated | Deprecated tool, version, or pattern | "Use Webpack 4" when the project uses Vite | Flag only when the codebase confirms it |
| Aspirational | Ideal state, not a rule | "Strive for 100% coverage" | "PRs must change fewer than 300 lines" |

Decision rule: if removing the instruction would not change agent behavior, flag it. If it would, keep it. When unsure, keep it and let the user decide.

Also flag source files now fully represented in the new structure, such as a `.cursorrules` whose content all moved to `guidelines/`, as candidates for deletion or archiving.

Present candidates grouped by category. For each, give the quoted instruction with its `file:line`, one sentence on why it adds no value, and a recommendation of DELETE or a concrete REWRITE. The user answers DELETE, REWRITE, or KEEP per item. Apply the decisions.

## Verification

1. Root file is under 50 lines.
2. Every `guidelines/*.md` link resolves.
3. No contradictions remain.
4. Every surviving instruction is actionable.
5. No instruction was lost without user approval.
6. Each category file is self-contained.

## Report

- Before/after line counts.
- Final file tree with per-file line counts.
- Contradictions found and how each was resolved.
- Instructions deleted, rewritten, and kept by user choice.
- Source files removed or archived.
