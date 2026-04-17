---
description: Write detailed implementation plan from approved design and structure
argument-hint: <design-doc-path> <structure-outline-path> [research-doc-paths...]
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
- Tests ARE the plan. Specify RED test specs + structural context per cycle. Do NOT include GREEN/implementation code or REFACTOR commentary — those emerge during execution via the `practicing-tdd` and `refactoring-code` skills.
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
   - **TDD Cycles**: Per testable behavior (one cycle per behavior):
     - **RED — Write Failing Test**: The exact test to write first, as a code
       block with concrete inputs and expected outputs. Use the project's
       existing test patterns and framework.
     - **Expected failure**: What the failure message will look like when run
       (e.g., "function X is undefined", assertion message, etc.)
     - **Structural context**: `file:line` references for modules/files in
       play, where the test file lives, relevant contracts or interfaces.
       Do NOT include GREEN/implementation code or REFACTOR commentary —
       those emerge during execution.
   - **Automated Testing** (phase summary):
     - Checkboxed list of all tests in the phase with brief descriptions
     - Exact command to run them (prefer `make` targets or project-standard
       test command scoped to the phase's test files)
     - Expected pass/fail count
   - **Done When**: Checkboxed list of:
     - All tests pass (reference the run command)
     - Behavior-based criteria (e.g., "User can create a new account")
     - Type checking and linting pass
   </phase-detail>

4. **Validate completeness** — apply `/thinking self-consistency`:
   - Does every cycle start with a RED test spec (exact test code, concrete inputs, expected outputs)?
   - Does any cycle contain GREEN/implementation code or REFACTOR commentary? → Remove it
   - Does any cycle contain code that is not a test? → Replace with structural context
   - Does every phase have an automated testing summary with an exact run command?
   - Are all `file:line` references verified against current source?
   - Are dependencies from the structure outline respected?
   - Is scope bounded by the "What We're NOT Doing" from the design doc?

5. **Save artifact**
   - Check for existing artifacts: `ls $CLAUDE_DOCS_ROOT/plans/`
   - Read `$CLAUDE_DOCS_ROOT/projects.yaml` for project context
   - Save to `ARTIFACT_DIR/plan--<slug>.md` with full frontmatter per
     artifact-management guidelines
   - Report the file path

## Report

The artifact follows PLAN_TEMPLATE with these sections:

```markdown
# [Task Name] Implementation Plan

## Overview

[1-2 sentences: what we're building and why]

## References

- Design: [path to design doc]
- Structure: [path to structure outline]
- Research: [path(s) to research docs]
- Ticket: [if referenced in upstream artifacts]

## Current State Analysis

### Key Discoveries

[Carried forward from research — verified `file:line` references only]

## Desired End State

[From the design document]

## What We're NOT Doing

[From the design document — carried forward verbatim]

## Phase Dependencies

[From the structure outline — include only if non-linear]

---

## Phase 1: [Name from structure outline]

### Overview
### TDD Cycles
### Automated Testing
### Done When

---

## Phase N: ...

---

## Migration Notes

[Only if applicable — how to handle existing data/systems]
```

Present the plan file path to the user. Do NOT auto-proceed to implementation.
