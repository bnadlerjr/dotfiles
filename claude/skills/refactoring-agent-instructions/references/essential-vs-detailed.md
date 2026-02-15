# Essential vs. Detailed: Decision Criteria

How to decide whether an instruction belongs in the root file or a linked category file.

## The Core Question

> "Would a developer need this instruction on every single task, regardless of what they're working on?"

- **YES** -> Root file (essential)
- **NO** -> Category file in `guidelines/` (detailed)

## Root File Criteria (Essential)

An instruction belongs in root ONLY if it meets one or more of these criteria:

### 1. Project Identity

What this project is, in one or two lines. This orients the agent and is always relevant.

**Stays in root:**
- "Phoenix API backend for the Acme billing platform"
- "React component library published to npm as @acme/ui"

**Moves to guidelines/:**
- Architectural decisions about the project (-> `guidelines/architecture.md`)
- Technology stack details (-> language-specific file)

### 2. Non-Standard Commands

Build, test, lint, and format commands ONLY when they differ from what the agent would guess from the project type.

**Stays in root:**
- `pnpm test` (non-obvious: project uses pnpm, not npm)
- `mix test --warnings-as-errors` (non-obvious flag)
- `make build` (non-standard entry point)

**Moves to guidelines/:**
- `npm test` (standard; agent would guess this)
- `pytest` (standard for Python)
- Detailed test configuration (-> `guidelines/testing.md`)

### 3. Critical Overrides

Instructions that override default agent behavior in ways that would cause serious problems if missed. These are "stop and read this first" rules.

**Stays in root:**
- "NEVER push to main"
- "NEVER commit .env files"
- "All PRs require approval from @security-team for changes to auth/"
- "This repo uses a monorepo structure; always specify the package name"

**Moves to guidelines/:**
- Detailed git workflow (-> `guidelines/git-workflow.md`)
- Detailed security practices (-> `guidelines/security.md`)

### 4. Universal Rules

Rules that apply to every task the agent might perform, regardless of the area of the codebase.

**Stays in root:**
- "All code must be TypeScript strict mode"
- "No console.log in committed code"
- "Every public function needs a JSDoc comment"

**Moves to guidelines/:**
- TypeScript type patterns (-> `guidelines/typescript.md`)
- Logging framework details (-> `guidelines/error-handling.md`)
- Documentation standards (-> `guidelines/documentation.md`)

### 5. Links to Guidelines

The root file's primary job after essentials is pointing to the right category file for deeper detail.

**Format:**
```markdown
## Guidelines

- [Code Style](guidelines/code-style.md)
- [Testing](guidelines/testing.md)
- [Git Workflow](guidelines/git-workflow.md)
```

## Category File Criteria (Detailed)

Everything that does NOT meet the root criteria above. Common categories:

| Content Type | Category File |
|-------------|---------------|
| Language-specific style | `guidelines/typescript.md`, `guidelines/elixir.md`, etc. |
| Test patterns and conventions | `guidelines/testing.md` |
| Git branch/commit/PR rules | `guidelines/git-workflow.md` |
| Architecture and patterns | `guidelines/architecture.md` |
| API conventions | `guidelines/api-design.md` |
| Security practices | `guidelines/security.md` |
| Error handling patterns | `guidelines/error-handling.md` |
| Performance rules | `guidelines/performance.md` |
| General formatting/naming | `guidelines/code-style.md` |

## Borderline Cases

### "Always use semicolons"
- Context-dependent. If this is a universal project rule that affects every file, it could be root.
- But if it's one of many style rules, group it with style rules in `guidelines/code-style.md`.
- **Default: Move to category.** One style rule alone rarely justifies root placement.

### "Use feature branches"
- This is a workflow detail, not a critical override.
- Move to `guidelines/git-workflow.md`.
- Exception: If the project has an unusual branching model (e.g., trunk-based with feature flags), a one-line mention in root is fine.

### "Prefer composition over inheritance"
- Architecture preference, not a universal rule.
- Move to `guidelines/architecture.md`.

### "Run `npm run lint` before committing"
- If there's a pre-commit hook, this is redundant (delete it).
- If there's no hook, this is a workflow instruction for `guidelines/git-workflow.md`.
- Only stays in root if lint failure causes CI to block merges AND the command is non-obvious.

## The 50-Line Test

After classifying everything, count root file lines. If over 50:

1. Re-examine each root item: "Is this truly needed on EVERY task?"
2. Move borderline items to categories
3. Tighten wording: use bullet points, not paragraphs
4. Combine related items onto single lines

If under 20 lines, that is fine. The root file should be scannable in seconds.
