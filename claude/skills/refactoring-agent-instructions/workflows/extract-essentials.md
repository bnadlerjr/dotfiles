# Phase 2: Extract Essentials

Separate instructions into two buckets: what MUST stay in the root file vs. what moves to linked category files.

## Inputs

- Resolved instruction set (from Phase 1)
- All discovered file contents

## Decision Criteria

### Stays in Root (Essential)

Only these belong in the root file:

1. **Project identity** — One-line description of what this project is
2. **Package manager** — Only if non-standard (e.g., pnpm instead of npm)
3. **Non-obvious commands** — Build, test, lint commands that differ from defaults
4. **Critical overrides** — Instructions that MUST apply before anything else (e.g., "NEVER push to main")
5. **Universal rules** — Rules that apply to every task regardless of context
6. **Links to guidelines/** — Pointers to categorized files

### Essential vs. Detailed Decision Table

The core question: *"Would a developer need this on every single task, regardless of what they're working on?"* YES = root. NO = category file.

| Instruction Type | Root? | Why | Example |
|-----------------|-------|-----|---------|
| Project description (1-2 lines) | YES | Always relevant for orientation | "Phoenix API for Acme billing" |
| Non-standard build/test/lint commands | YES | Needed constantly, non-obvious | `pnpm test`, `mix test --warnings-as-errors` |
| Standard commands | NO | Agent would guess correctly | `npm test`, `pytest` |
| Critical overrides ("NEVER do X") | YES | Serious harm if missed | "NEVER push to main" |
| Universal rules (apply to every file) | YES | Affects every interaction | "All code must be TS strict mode" |
| Language-specific style rules | NO | Only relevant to that language | "Use 2-space indentation in Elixir" |
| Testing conventions and patterns | NO | Only relevant when testing | Test file naming, mocking approach |
| Git workflow details | NO | Only relevant for commits/PRs | Branch naming, PR process |
| Architecture decisions | NO | Only relevant for design tasks | Design patterns, boundaries |
| Error handling patterns | NO | Only relevant to error scenarios | Logging, exception strategy |
| Security, performance, API rules | NO | Context-specific | Auth, caching, REST conventions |

**Borderline cases**: If under 50 lines with it in root, it can stay. If over 50 lines, move borderline items to categories. When in doubt, move it out. For additional detail and borderline case examples, read `references/essential-vs-detailed.md`.

### Moves to guidelines/ (Detailed)

Everything not in the table's "YES" rows above — language style, testing, git workflow, architecture, API design, error handling, performance, security, documentation, tool configuration.

## Procedure

### 1. Classify Each Instruction

For every instruction in the resolved set, apply the decision criteria:

```
Instruction: "Use 2-space indentation for TypeScript files"
Category: code-style
Essential? NO — language-specific style rule
Destination: guidelines/code-style.md (or guidelines/typescript.md)
```

```
Instruction: "Run tests with: pnpm test"
Category: commands
Essential? YES — non-obvious command (pnpm, not npm)
Destination: Root file
```

### 2. Build Two Lists

**Root content** (target: under 50 lines total):
- Project description (1-2 lines)
- Non-standard commands (3-10 lines)
- Critical overrides (2-5 lines)
- Universal rules (3-10 lines)
- Links section (3-8 lines, one per category)

**Category content** (everything else):
- Group by logical category
- Each instruction tagged with its destination category

### 3. Validate Root Size

If the root content exceeds 50 lines:
1. Re-examine each item against the "essential" criteria
2. Move borderline items to categories
3. Tighten wording — every line in root should be direct and minimal

If root content is under 20 lines, that is fine. Minimal is the goal.

### 4. Present Classification

Show the user:

```
## Root File (N lines)
- [List each item that stays in root]

## Category Files
- **typescript.md**: N instructions
- **testing.md**: N instructions
- **git-workflow.md**: N instructions
- [etc.]

Does this classification look right?
```

## Outputs

- **Root content list**: Instructions staying in root with final wording
- **Category content map**: `{category_name: [list of instructions]}`
- **Line count estimate** for root file

## Transition

When the user confirms the classification, proceed to Phase 3: Categorize Instructions.
