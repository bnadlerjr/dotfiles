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
PLAN_TEMPLATE: ~/dotfiles/claude/skills/implementation-planning/templates/plan-template.md
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
- TDD is implicit — do not add "write tests" steps. Describe what to build.
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
   - **Changes Required**: Per component/file group:
     - File path with line reference
     - Description of what changes
     - Code snippet showing what to add/modify (include enough surrounding
       context to locate the change site — skip for trivial changes)
   - **Done When**: Checkboxed list of:
     - Behavior-based criteria (e.g., "User can create a new account")
     - Commands to run (type checking, linting, test commands — prefer `make` targets)
     - Specific files that should exist
   - **Manual Verification**: Before proceeding to next phase:
     - Checkboxed list of things the human should test
     - UI behavior, edge cases, performance observations
     - **PAUSE**: After automated checks pass, wait for human confirmation
       before proceeding to the next phase
   - **Implementation Notes** (only if non-obvious):
     - Edge cases to handle
     - Ordering constraints within the phase
     - Gotchas discovered during reference verification
   </phase-detail>

4. **Validate completeness** — apply `/thinking self-consistency`:
   - Does every phase have concrete file changes (not just descriptions)?
   - Does every phase have both automated and manual verification?
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
### Changes Required
### Done When
### Manual Verification
### Implementation Notes

---

## Phase N: ...

---

## Migration Notes

[Only if applicable — how to handle existing data/systems]
```

Present the plan file path to the user. Do NOT auto-proceed to implementation.
