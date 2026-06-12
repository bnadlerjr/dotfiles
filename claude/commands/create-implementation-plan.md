---
description: Write detailed implementation plan from approved design and structure
argument-hint: <design-doc-path> <structure-outline-path> [research-doc-paths...]
allowed-tools: Read, Glob, Grep, Bash, Write, Skill
model: opus
---

# Create Implementation Plan

Fill in precise technical details for an approved phase structure. Design decisions
are SETTLED. Phase structure is APPROVED. Your only job is to specify exactly what
changes go into each phase — files, code snippets, and verification criteria.

Use the `thinking-patterns` skill for structured reasoning.

## Variables

ARTIFACT_PATHS: $ARGUMENTS
PLAN_TEMPLATE: ~/dotfiles/claude/skills/planning-tdd/templates/plan-template.md
ARTIFACT_DIR: $CLAUDE_DOCS_ROOT/plans/

## Instructions

- If ARTIFACT_PATHS is empty or contains fewer than 2 paths, STOP and respond:
  "Usage: `/create-implementation-plan <design-doc> <structure-outline> [research-docs...]`
  Run `/align-understanding` and `/outline-phases` first to produce the required artifacts."
- Do NOT revisit design decisions — they are settled. If you discover one needs
  revisiting, STOP immediately, explain the conflict with `file:line` evidence,
  and ask the user how to proceed.
- Do NOT change the phase structure — it is approved. If you believe a phase
  should be added, split, or reordered, flag it with rationale and wait.
- Do NOT spawn research agents — research is complete. Use Read/Glob/Grep
  directly if you need to verify references or gather surrounding context.
- Tests ARE the plan — specified as behavior, not code. Every phase's cycles are
  behavioral (Behavior, Assertion focus, Expected failure category, Structural
  context); the plan contains NO test code and NO implementation code.
  Why: exact code is design that goes stale before execution reaches it. `/implement`
  details each phase into exact RED specs just-in-time; GREEN and REFACTOR emerge
  during execution via the `practicing-tdd` and `refactoring-code` skills.
- Read `~/dotfiles/claude/skills/planning-tdd/SKILL.md` for the full methodology before detailing phases.
- No open questions in the final plan. If anything is unclear, ask NOW.

## Workflow

1. **Load input artifacts**
   - Read ALL documents in ARTIFACT_PATHS completely — do not skim
   - Identify which is the design document and which is the structure outline
     (remaining paths are research documents)
   - Extract from design doc: desired end state, design decisions, scope boundaries,
     patterns to follow
   - Extract from structure outline: phase names, goals, dependencies, components
     touched, verification criteria
   - Extract from research docs: `file:line` references, code patterns, architecture

2. **Verify references** — apply `/thinking self-consistency`:
   - Spot-check `file:line` references from research — read the actual source files
     to confirm they are still accurate
   - If a reference is stale, update it by searching for the current location
   - Gather surrounding code context needed for code snippets in the plan

3. **Detail each phase** — read PLAN_TEMPLATE for the standard format, then:

   IMPORTANT: For each phase in the structure outline, produce the following:

   <phase-detail>
   - **Overview**: What this phase accomplishes (from the structure outline)
   - **TDD Cycles**: Per testable behavior (one cycle per behavior), in
     behavioral form — no code:
     - **Behavior**: Given/When/Then at the behavior level
     - **Assertion focus**: the single thing the test asserts
     - **Expected failure category**: e.g., "function undefined",
       "assertion mismatch", "constraint missing"
     - **Structural context**: module-level references; `file:line` only
       where the reference is stable across phases. Do NOT include
       GREEN/implementation code or REFACTOR commentary — those emerge
       during execution.
   - **Automated Testing** (phase summary):
     - Checkboxed list of all tests in the phase with brief descriptions —
       test file paths marked "path resolved at detailing time"
     - Exact command to run them (prefer `make` targets or project-standard
       test command scoped to the phase's test directory)
     - Expected pass/fail count
   - **Done When**: Checkboxed list of:
     - All tests pass (reference the run command)
     - Behavior-based criteria (e.g., "User can create a new account")
     - Type checking and linting pass
   </phase-detail>

4. **Validate completeness** — apply `/thinking self-consistency`:
   - Does any phase contain test code? → Convert to behavioral cycles
   - Does every cycle have a Behavior, Assertion focus, and Expected failure category?
   - Does any cycle contain GREEN/implementation code or REFACTOR commentary? → Remove it
   - Does any cycle contain code of any kind? → Replace with structural context
   - Does every phase have an automated testing summary with an exact run command?
   - Are all `file:line` references verified against current source?
   - Are dependencies from the structure outline respected?
   - Is scope bounded by the "What We're NOT Doing" from the design doc?

5. **Save artifact**
   - Check for existing artifacts: `ls ARTIFACT_DIR`
   - Read `$CLAUDE_DOCS_ROOT/projects.yaml` for project context
   - Save to `ARTIFACT_DIR/plan--<slug>.md` with full frontmatter per
     artifact-management guidelines
   - Report the file path

## Report

The artifact follows PLAN_TEMPLATE (read in Workflow step 3) — that file is the
single source of truth for format. In order, the sections are:

1. **Overview** — what we're building and why
2. **References** — design doc, structure outline, research doc(s), ticket
3. **Current State Analysis** — key discoveries with verified `file:line` references
4. **Desired End State** — from the design document
5. **What We're NOT Doing** — from the design document, carried forward verbatim
6. **Phase Dependencies** — from the structure outline; include only if non-linear
7. **Phase 1..N** — each with Overview, TDD Cycles, Automated Testing, Done When
8. **Migration Notes** — only if existing data/systems need handling

Present the plan file path to the user. Do NOT auto-proceed to implementation.
