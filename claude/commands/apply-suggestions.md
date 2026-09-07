---
description: Evaluate and apply code review suggestions with domain expertise
argument-hint: <suggestions from code review>
model: opus
---

# Apply Code Review Suggestions

Evaluate code review suggestions using domain expertise, then implement only those that pass technical evaluation.

## Variables

SUGGESTIONS: $ARGUMENTS
TECH_STACK: detected from codebase context (Elixir, TypeScript, Bash, etc.)
DOMAIN_SKILL: mapped from TECH_STACK (`developing-elixir`, `developing-typescript`, `developing-bash`, etc.)

## Instructions

- If SUGGESTIONS is empty, STOP immediately and ask for them.
- Treat suggestions as proposals to evaluate, not orders to follow.
- Push back with technical reasoning when a suggestion fails evaluation. Do NOT implement.
- If you cannot verify a suggestion against the codebase, state the limitation and ask for direction. Do NOT proceed on assumption.
- Implement one suggestion at a time, testing after each.
- No performative agreement — state what changed and why.

## Workflow

### Phase 1: Parse and Prepare

1. Apply `/thinking atomic-thought` to decompose SUGGESTIONS into distinct, independent suggestions. For each, identify: the specific change requested, affected files, and the reviewer's underlying concern.

2. **Clarify and reconcile** — Before implementing anything:
   - If any suggestion is ambiguous, STOP and ask about every unclear item at once. Suggestions can be related, and partial understanding produces a wrong implementation.
   - If two suggestions conflict, do NOT pick a side. Summarize both positions with their tradeoffs and ask the user to decide.

3. **Order** the suggestions: blocking issues (breaks, security) first, then simple fixes (typos, imports), then complex fixes (refactoring, logic).

4. Detect TECH_STACK from the affected files and invoke the corresponding DOMAIN_SKILL to establish domain expertise.

### Phase 2: Evaluate and Implement

IMPORTANT: For each suggestion, execute the following:

<suggestion-loop>

5. **Evaluate** — Apply `/thinking chain-of-thought`:
   - Is this technically correct for THIS codebase?
   - Does it break existing functionality?
   - Is there a reason the current implementation is the way it is?
   - Does it hold on all platforms and versions this project supports?
   - Does the reviewer have full context?
   - Does it conflict with existing architectural decisions?
   - Is it a YAGNI violation? If the suggestion is to "implement X properly", grep for actual usage first. If nothing calls it, propose removal instead of implementation.

   If the evaluation is borderline, apply `/thinking self-consistency` with three independent paths (correctness, maintainability, codebase consistency). Accept only on consensus.

6. **Decide**:
   - If evaluation fails: Push back with technical reasoning. Record the rejection rationale. Do NOT implement. Skip to the next suggestion.
   - If the suggestion cannot be verified: State what blocks verification and ask for direction. If it stays unverified, record "Unverified". Do NOT implement. Skip to the next suggestion.
   - If evaluation passes: Proceed to the approval gate.

7. **Request approval** — Present to the user: the suggestion, the evaluation verdict, the planned change, and any risks. Use `AskUserQuestion` (or a direct prompt) to ask whether to implement.
   - If the user declines: Record the user's rationale (if given) as "Skipped by user". Do NOT implement. Move to the next suggestion.
   - If the user approves: Proceed to implementation.

8. **Implement** the approved suggestion.

9. **Test** — Run relevant tests to confirm the change works and causes no regressions.

</suggestion-loop>

### Phase 3: Review and Simplify

10. **Review** — Use the `reviewing-code` skill to review all implemented changes.

11. **Simplify** — Use the `code-simplifier` agent to remove unnecessary complexity and noisy comments from modified files.

## Report

| # | Suggestion | Verdict | Reasoning |
|---|------------|---------|-----------|
| 1 | [Brief description] | Applied / Rejected / Unverified / Skipped by user | [1-sentence rationale] |

- **Changes implemented**: List files and what changed
- **Test results**: Suite name, pass/fail
- **Review findings**: Summary from reviewing-code
- **Simplification**: Summary from code-simplifier
