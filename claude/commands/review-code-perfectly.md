---
description: Review a pull request with the PERFECT methodology — 7 principles applied in strict priority order
argument-hint: <PR-ID or PR-URL>
allowed-tools: Bash, Read, Grep, Glob, Skill
---

# Review Code Perfectly

**Level 3 (Control Flow)** — Checks a PR out into an isolated worktree, loads the language skills its changed files call for, judges the diff against 7 principles in strict priority order, and reports a verdict per principle. Based on Daniil Bastrich's PERFECT methodology.

## Variables

- **PR_REF**: `$ARGUMENTS` — a PR number (`42`, requires the working directory to be the target repo) or a PR URL (`https://github.com/org/repo/pull/42`, works from anywhere).

## Instructions

- If PR_REF is empty, STOP and ask for it.
- Report every principle, even when it passes.
- Every finding states the concrete problem, its impact, a `file:line` citation, and a proposed alternative. "This is bad" and "this could be better" are not findings.
- Separate blocking issues from non-blocking suggestions in every section.
- Cap Taste at 3 items and mark them non-blocking.
- Skip generated files (lock files, compiled output, snapshots) and binary assets.
- Review the code, not the author, and not team process.
- Never approve on "LGTM" alone — demonstrate that you understood the change.
- Clean up the worktree even when the review stops early.

## Workflow

### Step 1: Check out the PR

```bash
# Parses PR_REF and checks the code out into an isolated worktree.
# Outputs REVIEW_DIR, OWNER, REPO, PR_NUMBER. For URLs, creates a bare clone
# when the working directory is not the target repo.
eval "$(pr-review-worktree setup <PR_REF>)"

# Build the --repo flag for cross-repo gh commands
REPO_FLAG=""
if [ -n "$OWNER" ] && [ -n "$REPO" ]; then
    REPO_FLAG="--repo ${OWNER}/${REPO}"
fi

gh pr view $PR_NUMBER $REPO_FLAG --json title,body,files,additions,deletions,baseRefName,headRefName,url,state,reviewDecision
gh pr diff $PR_NUMBER $REPO_FLAG
gh pr view $PR_NUMBER $REPO_FLAG --json files --jq '.files[].path'
```

URL parsing is deterministic — `gh-pr-parse` handles it, not you.

### Step 2: Read the changed files

Read each changed file in full from `$REVIEW_DIR/<path>`. Grep and Glob within `$REVIEW_DIR` for the related code the diff depends on.

### Step 3: Load language skills

Match the changed paths against this table and invoke every matching skill with the Skill tool. Deduplicate — load each skill once.

| Path pattern | Skills |
|---|---|
| `.ex`, `.exs` | `developing-elixir` |
| `_test.exs` | `developing-elixir`, `testing-elixir` |
| `.ts`, `.tsx`, `.js`, `.jsx` | `developing-typescript` |
| `.test.ts(x)`, `.spec.ts(x)` | `developing-typescript`, `testing-react-with-vitest` |
| `.sh`, `.bash`, `Makefile` | `developing-bash` |

The loaded skills supply the language-specific half of each principle: idioms and anti-patterns for Form, language gotchas for Edge Cases, performance and security patterns for Reliability, naming conventions for Clarity, and testing patterns for Evidence.

No match (Python, Go, Ruby, and so on): review with general knowledge and state in the report that no specialized skill was consulted.

### Step 4: Apply the principles

Work through all 7 in order. Priority descends with the number — 1 is critical, 2-3 high, 4-5 medium, 6 low, 7 non-blocking. A Purpose failure outranks every Clarity nit, and a PR that fails Purpose has zero value however clean its code is.

#### 1. Purpose — the code solves the task

Read the PR description and linked ticket to establish the task. If the task is unclear, flag that immediately; you cannot review code without knowing what it should do. Sketch your own approach first, then compare it against the implementation.

Look for: missing requirements, partial implementation, scope creep beyond the task, a different problem solved than the one described, a refactor that changes behavior when it should not, and unstated assumptions that affect correctness.

#### 2. Edge Cases — corner cases are handled

| Category | Examples |
|---|---|
| Business | Unusual but valid input combinations, boundary values at and around a threshold, omitted requirements ("user has no orders"), race conditions in concurrent workflows |
| Technical | nil/null/undefined where presence is assumed, empty collections, integer overflow and float precision, very large or very small inputs, Unicode and whitespace-only strings, time zones and DST and leap years, network timeouts and partial responses |
| "Impossible" | Unreachable-looking but dangerous states, optional values read without a presence check, enums treated as exhaustive against future additions, default branches that silently swallow unexpected values |

For each function and branch in the diff, ask what input would break it. Check nil handling on everything from a database, an API, or user input, and verify error paths, not only happy paths.

#### 3. Reliability — no performance or security issues

| Performance | Security |
|---|---|
| Time complexity against expected volume — O(n²) on 10 items is fine, on 100,000 it is not | Input validated before use |
| Whole datasets in memory where streaming works | Raw string interpolation in queries (SQL injection) |
| N+1 queries — database calls inside loops | User content rendered unsanitized (XSS) |
| Queries on unindexed columns of large tables | Secrets in code, logs, or error messages |
| Cached data never invalidated when the source changes | Missing permission checks on sensitive operations |
| Repeated computation and redundant API calls | User-controlled file paths (path traversal) |
| | API calls without timeout, retry, or error handling |

#### 4. Form — the code aligns with design principles

High Cohesion / Low Coupling is the foundational principle; SOLID, KISS, and DRY are specific interpretations of it. Ask whether each unit has a single focused purpose and whether modules can change independently on explicit, minimal dependencies.

Look for: a new class or function doing unrelated things, higher-level modules depending on concrete implementations instead of abstractions, true logic duplication, premature abstraction before multiple concrete use cases exist, and layering violations such as UI code reaching into the database.

Design is subjective, so a Form finding needs more than a label. "This violates SRP" is not enough — give the concrete cost ("if billing rules change you must also modify the notification module, because they share mutable state"), propose a direction, and name the trade-off. Similar-looking code that varies for different reasons is not a DRY violation. Where no project convention exists and the current approach works, defer to the author.

#### 5. Evidence — tests and CI pass

Review test code with these same principles.

Verify that CI passes (a red PR is not ready for review), that new logic has new tests and modified logic has updated tests, and that the tests are worth having: behavior over implementation, edge cases from principle 2 covered, names that state scenario and expected outcome, meaningful assertions rather than "does not throw".

Test anti-patterns: tests that break on refactors that change no behavior, over-mocking that leaves the test proving nothing, `if (process.env.TEST)` hooks in production code instead of naturally testable design, and happy-path-only coverage.

#### 6. Clarity — the code communicates intent

Code should be readable diagonally.

Look for: names that do not communicate purpose, illogical file organization, functions over 50 lines that need decomposition (algorithms excepted), nesting past 3 levels where guard clauses and early returns would help, unrelated statements interleaved, public API buried under private helpers, and comments explaining WHAT instead of WHY.

Keep clarity findings proportional — do not rewrite the PR for style. Where no agreed convention exists and the code is not explicitly unclear, defer to the author.

#### 7. Taste — personal preferences

Never blocking — the author may decline any of these without justification. Give reasoning and a constructive proposal anyway: "I'd prefer X because…", not "I'd prefer X". A taste item worth standardizing belongs in a team-convention proposal, raised separately from the PR.

### Step 5: Check CI and tests

```bash
gh pr checks $PR_NUMBER $REPO_FLAG
```

Identify the project test command from its config and run the relevant tests from `$REVIEW_DIR` when they can run locally.

### Step 6: Produce the review

Emit the report below.

### Step 7: Clean up

```bash
pr-review-worktree cleanup "$REVIEW_DIR"
```

## Severity

| Level | Meaning | Blocks merge? |
|---|---|---|
| FAIL | Critical — bugs, security, task not solved | Yes |
| NEEDS DISCUSSION | The task or the intended approach is unclear — unreviewable without the author | Yes |
| CONCERN | Significant — should fix, carries risk if not | Depends on context |
| PASS | No issues found for this principle | No |
| N/A | Not applicable (Taste only) | No |

## Report

```markdown
# PERFECT Review: PR #<ID> — <PR Title>

**PR**: <URL>
**Author**: <author>
**Base**: <base-branch> <- <head-branch>
**Files changed**: <count> (+<additions> -<deletions>)

---

## 1. Purpose

**Verdict**: PASS | FAIL | NEEDS DISCUSSION

<The task, as understood from the PR description or linked ticket>

<How the implementation approaches it, and any gap between the two>

### Findings
- **[file:line]**: <finding with reasoning>

---

## 2. Edge Cases

**Verdict**: PASS | CONCERN | FAIL

### Findings
- **[file:line]**: <the case, why it matters, proposed handling>

---

## 3. Reliability

**Verdict**: PASS | CONCERN | FAIL

### Findings
- **[file:line]**: <performance or security concern with reasoning>

---

## 4. Form

**Verdict**: PASS | CONCERN | FAIL

### Findings
- **[file:line]**: <design concern with concrete cost and an alternative>

---

## 5. Evidence

**Verdict**: PASS | CONCERN | FAIL

<CI status and coverage assessment>

### Findings
- **[file:line]**: <test gap or test quality issue>

---

## 6. Clarity

**Verdict**: PASS | CONCERN

### Findings
- **[file:line]**: <clarity issue with a suggested improvement>

---

## 7. Taste

**Verdict**: N/A (non-blocking)

### Suggestions (non-blocking)
- **[file:line]**: <preference, marked as opinion>

---

## Summary

| Principle | Verdict |
|-----------|---------|
| Purpose | PASS/FAIL/NEEDS DISCUSSION |
| Edge Cases | PASS/CONCERN/FAIL |
| Reliability | PASS/CONCERN/FAIL |
| Form | PASS/CONCERN/FAIL |
| Evidence | PASS/CONCERN/FAIL |
| Clarity | PASS/CONCERN |
| Taste | N/A |

**Recommendation**: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION

**Key blocking issues** (if any):
1. <issue summary with file reference>

**Top suggestions** (non-blocking):
1. <suggestion summary>
```
