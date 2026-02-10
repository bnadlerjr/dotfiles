---
description: Create detailed implementation plans through interactive research and iteration
argument-hint: <file path, ticket reference, or task description>
model: opus
---

# Implementation Plan

Create a detailed implementation plan through interactive research,
structured thinking, and iterative alignment.

Read and follow the methodology in the `implementation-planning` skill:
`~/dotfiles/claude/skills/implementation-planning/SKILL.md`

## Variables

TASK_INPUT: $ARGUMENTS
PLAN_TEMPLATE: `~/dotfiles/claude/skills/implementation-planning/templates/plan-template.md`

## Instructions

- If TASK_INPUT is empty, STOP immediately and ask the user to provide
  a task description, file path, or ticket reference.
- Follow the `implementation-planning` skill methodology throughout.
- Interactive — never dump a complete plan. Gather context → verify
  understanding → align on approach → detail phases.
- Grounded — verify every claim against code. Include `file:line` refs.
- Bounded — every plan includes a "What We're NOT Doing" section.
- TDD-First — describe what to build. Automated testing is implicit.
- No Open Questions — resolve all questions before finalizing.
  STOP and ask if anything is unclear.

## Workflow

### Phase 1: Gather Context

1. Apply `/thinking atomic-thought` to decompose TASK_INPUT into key
   questions: What is the goal? What exists today? What changes? What
   constraints apply?

2. Read all referenced documents FULLY — ticket files, research docs,
   related plans.

3. Search `$CLAUDE_DOCS_ROOT/` for existing research, plans, and
   handoffs related to TASK_INPUT. Surface anything relevant — prior
   research may already answer key questions.

4. Spawn research agents in parallel:
   - **codebase-navigator** → Find all relevant files and entry points
   - **codebase-analyzer** → Understand current implementation details
   - **docs-locator** → Find existing documentation or related artifacts

5. Present informed understanding with `file:line` references and any
   prior artifacts found. Ask only questions that code investigation
   couldn't answer.

### Phase 2: Research & Discover

6. If the user provides corrections, verify against code before
   accepting — spawn new research agents if needed.

7. If multiple valid approaches exist, apply `/thinking tree-of-thoughts`
   to evaluate design options. Compare on complexity, risk, and alignment
   with existing patterns. For single-approach tasks, skip this step.

8. Present findings and design options with pros/cons. Get alignment
   before proceeding.

### Phase 3: Outline Structure

9. Apply `/thinking skeleton-of-thought` to draft the phase structure —
   name each phase, what it accomplishes, and dependencies.

10. Present the outline for feedback. Get approval before detailing.

### Phase 4: Detail Plan

11. Read PLAN_TEMPLATE for the standard plan format.

12. Write the detailed plan following the template. Include:
    - Current state analysis with `file:line` references
    - Desired end state specification
    - "What We're NOT Doing" section
    - Phase details with specific file changes
    - Manual verification checkpoints per phase

13. Apply `/thinking self-consistency` to validate the plan: Does every
    phase have clear "done when" criteria? Are dependencies correct?
    Is scope properly bounded?

## Report

Present the completed plan with:
- Plan file path
- Phase count and key milestones
- Any assumptions made
