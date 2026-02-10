---
description: TDD-based bug diagnosis and fix with structured thinking patterns
argument-hint: <bug description, error message, or reproduction steps>
model: sonnet
---

# TDD Bugfix

Diagnose and fix a bug using test-driven development, structured thinking patterns, and domain expertise.

## Variables

BUG_DESCRIPTION: $ARGUMENTS
TECH_STACK: detected from codebase context (Elixir, TypeScript, Bash, etc.)
DOMAIN_SKILL: mapped from TECH_STACK (`developing-elixir`, `developing-typescript`, `developing-bash`, etc.)

## Instructions

- If BUG_DESCRIPTION is empty, STOP immediately and ask the user to describe the bug.
- Follow the `practicing-tdd` skill strictly — no production code without a failing test first.
- Minimal fix only — do not refactor unrelated code.
- Detect TECH_STACK from the codebase and invoke the corresponding DOMAIN_SKILL for expertise.

## Workflow

### Phase 1: Understand

1. Apply `/thinking atomic-thought` to decompose BUG_DESCRIPTION into independent sub-questions: What is the expected behavior? What actually happens? Where in the codebase? When does it occur? How to reproduce?

2. **Investigate** — Search the codebase for relevant code, read affected files, check git history for recent changes. Build a mental model of the affected code paths.

3. **Write failing test** — Following the `practicing-tdd` skill (RED phase), write a test that reproduces the exact bug. Run it and confirm it fails for the right reason.

### Phase 2: Diagnose

4. Apply `/thinking chain-of-thought` to trace the root cause step by step — follow the execution path from input to incorrect output, identifying where behavior diverges from expectation.

5. If multiple valid fix approaches exist, apply `/thinking tree-of-thoughts` to evaluate them. Compare on correctness, minimal change, and risk of side effects. For obvious single-approach fixes, skip this step.

### Phase 3: Fix and Verify

6. **Implement fix** — Following the `practicing-tdd` skill (GREEN phase), write the minimal code to make the failing test pass.

7. **Refactor** — Following the `practicing-tdd` skill (REFACTOR phase), clean up the fix while keeping all tests green.

8. Apply `/thinking self-consistency` to verify the fix from multiple angles: Does it address the root cause (not just the symptom)? Could it cause regressions? Are edge cases handled?

9. **Review and simplify** — Use the `reviewing-code` skill to review the changes, then use the `code-simplifier` agent to remove unnecessary complexity from modified files.

## Report

- **Bug**: one-line summary
- **Root cause**: what was wrong and why
- **Fix**: files changed and what was modified
- **Tests**: what was added or modified
- **Verification**: test results (pass/fail, suite status)
