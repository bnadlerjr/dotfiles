---
name: reviewing-code-perfectly
description: Reviews pull requests using the PERFECT code review methodology — 7 principles applied in strict priority order (Purpose, Edge Cases, Reliability, Form, Evidence, Clarity, Taste). Use when reviewing a PR, conducting code review, or when the user mentions PERFECT review methodology.
allowed-tools: Bash, Read, Grep, Glob
---

# Reviewing Code with PERFECT Methodology

Structured PR review applying 7 principles in strict priority order to maximize review value while reducing cognitive load. Based on Daniil Bastrich's PERFECT methodology.

## Quick Start

```
reviewing-code-perfectly <PR-ID or PR-URL>
```

1. Fetch PR data via `gh` CLI
2. Analyze changes against each PERFECT principle in order
3. Produce structured review with pass/fail per principle

## Inputs

- **PR ID** (number): e.g., `42`
- **PR URL**: e.g., `https://github.com/org/repo/pull/42`

## Workflow

### Step 1: Gather PR Data

```bash
# Check out PR code into an isolated worktree
REVIEW_DIR=$(pr-review-worktree setup <PR-ID>)

# Get PR description, title, and metadata
gh pr view <PR-ID> --json title,body,files,additions,deletions,baseRefName,headRefName,url,state,reviewDecision

# Get the full diff
gh pr diff <PR-ID>

# List changed files
gh pr view <PR-ID> --json files --jq '.files[].path'
```

### Step 2: Read Changed Files

For each changed file, read the full file from `$REVIEW_DIR` (not just the diff) to understand context. Use `$REVIEW_DIR/<file-path>` for all Read calls. Use Grep and Glob within `$REVIEW_DIR` to find related code when needed.

### Step 3: Load Language Skills

Examine the file extensions of all changed files and load relevant language/framework skills for domain-specific review guidance. Use the [language-skill-mapping](references/language-skill-mapping.md) to determine which skills apply.

For each matched skill, invoke it using the Skill tool so its domain expertise is available when applying the PERFECT principles. If multiple languages are present, load all matching skills.

The loaded skills inform your review in several ways:
- **Form**: Language idioms, conventions, and anti-patterns
- **Edge Cases**: Language-specific gotchas (e.g., nil handling in Elixir, async pitfalls in TypeScript)
- **Reliability**: Language-specific performance and security patterns
- **Clarity**: Naming conventions and code organization standards for the language
- **Evidence**: Language-specific testing patterns and coverage expectations

### Step 4: Apply PERFECT Principles

Evaluate the PR against each principle in strict priority order. Stop and report blocking issues at the earliest principle that fails critically. Later principles still get reviewed but are lower priority.

For detailed guidance on each principle, see [perfect-principles.md](references/perfect-principles.md).

**Priority order:**

1. **Purpose** — Does the code solve the stated task?
2. **Edge Cases** — Are edge cases handled?
3. **Reliability** — No performance or security issues?
4. **Form** — Aligns with design principles?
5. **Evidence** — Tests pass and cover changes?
6. **Clarity** — Code communicates intent clearly?
7. **Taste** — Personal preferences (non-blocking only)

### Step 5: Check CI/Test Status

```bash
# Check CI status
gh pr checks <PR-ID>

# If tests can be run locally
# Identify test command from project config and run relevant tests
```

### Step 6: Produce Review Output

### Step 7: Clean Up Worktree

```bash
pr-review-worktree cleanup "$REVIEW_DIR"
```

## Output Format

```markdown
# PERFECT Review: PR #<ID> — <PR Title>

**PR**: <URL>
**Author**: <author>
**Base**: <base-branch> <- <head-branch>
**Files changed**: <count> (+<additions> -<deletions>)

---

## 1. Purpose

**Verdict**: PASS | FAIL | NEEDS DISCUSSION

<Understanding of the task from PR description/linked ticket>

<How the implementation approaches the task>

<Any gaps between task requirements and implementation>

### Findings
- **[file:line]**: <finding with reasoning>

---

## 2. Edge Cases

**Verdict**: PASS | CONCERN | FAIL

### Findings
- **[file:line]**: <edge case description, why it matters, proposed handling>

---

## 3. Reliability

**Verdict**: PASS | CONCERN | FAIL

### Findings
- **[file:line]**: <performance or security concern with reasoning>

---

## 4. Form

**Verdict**: PASS | CONCERN | FAIL

### Findings
- **[file:line]**: <design principle concern with concrete argument and alternative>

---

## 5. Evidence

**Verdict**: PASS | CONCERN | FAIL

<CI status, test coverage assessment>

### Findings
- **[file:line]**: <test gap or test quality issue>

---

## 6. Clarity

**Verdict**: PASS | CONCERN

### Findings
- **[file:line]**: <clarity issue with suggested improvement>

---

## 7. Taste

**Verdict**: N/A (non-blocking)

### Suggestions (non-blocking)
- **[file:line]**: <personal preference, clearly marked as opinion>

---

## Summary

| Principle | Verdict |
|-----------|---------|
| Purpose | PASS/FAIL |
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

## Guidelines

### Feedback Quality

- Describe clearly what is wrong and why
- Support every finding with concrete arguments
- Propose alternatives (at least at a high level)
- Never use vague statements like "this is bad" or "this could be better"
- Distinguish blocking issues from non-blocking suggestions

### Review Ethos

- Just because you would write it differently does not mean it is bad
- Focus on constructive, actionable feedback
- Code review is about the code, not the author
- Taste items are explicitly non-blocking — the author may decline them
- Never approve with just "LGTM" — always demonstrate understanding of the changes

### Scope Boundaries

- Review only code changes in the PR diff
- Skip generated files (lock files, compiled output, snapshots)
- Skip binary assets
- Do not review project process or team conventions — focus on the code

### Severity Levels

| Level | Meaning | Blocks merge? |
|-------|---------|---------------|
| FAIL | Critical issue — bugs, security, task not solved | Yes |
| CONCERN | Significant issue — should fix, risks if not | Depends on context |
| PASS | No issues found for this principle | No |
| N/A | Not applicable (used for Taste) | No |
