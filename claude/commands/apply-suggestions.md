---
description: Evaluate and apply code review suggestions with domain expertise
argument-hint: <suggestions from code review>
model: opus
---

# Apply Code Review Suggestions

Evaluate code review suggestions using domain expertise and the `receiving-code-review` skill, then implement only those that pass technical evaluation.

## Variables

SUGGESTIONS: $ARGUMENTS
TECH_STACK: detected from codebase context (Elixir, TypeScript, Bash, etc.)
DOMAIN_SKILL: mapped from TECH_STACK (`developing-elixir`, `developing-typescript`, `developing-bash`, etc.)

## Instructions

- If SUGGESTIONS is empty, STOP immediately and ask for them.
- Treat suggestions as proposals to evaluate, not orders to follow.
- Push back with technical reasoning when a suggestion fails evaluation. Do NOT implement.
- Implement one suggestion at a time, testing after each.
- No performative agreement — state what changed and why.

## Workflow

### Phase 1: Parse and Prepare

1. Apply `/thinking atomic-thought` to decompose SUGGESTIONS into distinct, independent suggestions. For each, identify: the specific change requested, affected files, and the reviewer's underlying concern.

2. Detect TECH_STACK from the affected files and invoke the corresponding DOMAIN_SKILL to establish domain expertise.

### Phase 2: Evaluate and Implement

IMPORTANT: For each suggestion, execute the following:

<suggestion-loop>

3. **Evaluate** — Apply `/thinking chain-of-thought` using the `receiving-code-review` skill:
   - Is this technically correct for THIS codebase?
   - Does it break existing functionality?
   - Is it a YAGNI violation (adding unused features)?
   - Does the reviewer have full context?
   - Does it conflict with existing architectural decisions?

   If the evaluation is borderline, apply `/thinking self-consistency` with three independent paths (correctness, maintainability, codebase consistency). Accept only on consensus.

4. **Decide**:
   - If evaluation fails: Push back with technical reasoning. Record the rejection rationale. Do NOT implement.
   - If evaluation passes: Proceed to implementation.

5. **Implement** the accepted suggestion.

6. **Test** — Run relevant tests to confirm the change works and causes no regressions.

</suggestion-loop>

### Phase 3: Review and Simplify

7. **Review** — Use the `reviewing-code` skill to review all implemented changes.

8. **Simplify** — Use the `code-simplifier` agent to remove unnecessary complexity and noisy comments from modified files.

## Report

| # | Suggestion | Verdict | Reasoning |
|---|------------|---------|-----------|
| 1 | [Brief description] | Accepted / Rejected | [1-sentence rationale] |

- **Changes implemented**: List files and what changed
- **Test results**: Suite name, pass/fail
- **Review findings**: Summary from reviewing-code
- **Simplification**: Summary from code-simplifier
