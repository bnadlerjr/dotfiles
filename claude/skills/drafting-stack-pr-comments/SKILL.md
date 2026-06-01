---
name: drafting-stack-pr-comments
description: |
  Examines a git-machete stack of dependent branches and drafts preemptive PR
  comments warning reviewers that code in an earlier PR is already refactored,
  renamed, moved, deleted, or fixed later in the stack. Output is DRAFT ONLY —
  the user pastes it manually; the skill never posts to GitHub.

  Use for stacked PRs, a git-machete stack, when reviewers comment on code that
  is "already fixed/refactored/handled later in the stack", to preempt reviewer
  comments on superseded code, to draft PR comments for a branch stack, or to
  find code in an earlier branch that a later branch supersedes.
allowed-tools: Bash, Read, Grep, Glob
---

# Drafting Stack PR Comments

You stack pull requests with `git-machete`: a chain of dependent branches, one PR
per branch. Reviewers on an *earlier* PR often flag code you already refactored,
moved, renamed, or deleted in a *later* branch — wasting everyone's time. This
skill inspects the stack and drafts courteous heads-up comments you can paste onto
the earlier PRs: "this is handled later in #N — no need to comment."

## Hard Constraints — read first

- **DRAFT ONLY. NEVER post to GitHub.** Do not run `gh pr comment`, `gh pr review`,
  `gh api ... -X POST/PATCH/PUT`, or any write. All `gh` usage is **read-only**
  (`gh pr view`, `gh pr list`, `--json` reads). You produce a copy-paste-ready
  report; the human posts manually. If you ever feel tempted to post, stop — that
  is out of scope by design.
- **Never write to source files.** No Edit/Write on the repo. `allowed-tools` is
  read-only on purpose (Bash, Read, Grep, Glob).
- **Comment granularity:** line-anchored where possible (`path:line`), PR-level
  summary as fallback when supersession is not a clean single hunk.

## Security & Governance

Drafts quote diff hunks, so the report may contain **source code**. The output is
for local review only. Do not paste it into unapproved AI tools (per Instinct's AI
Usage Policy). The skill is read-only and never posts to GitHub by design — the
human reviews and posts each comment.

## Delegation

- For stack mechanics (reading the tree, fork-points, `git machete` subcommands),
  invoke the **`using-git-machete`** skill rather than re-deriving them.
- For parsing `gh --json` output, consult the **`using-jq`** skill.

## Workflow

Run these stages in order. Stages 2–3 carry the detail — see
[references/detection-heuristics.md](references/detection-heuristics.md) for the
classification logic and [references/command-recipes.md](references/command-recipes.md)
for the exact read-only commands and output templates.

### 1. Discover the stack (root → tip)

Get the ordered branch chain from base to tip. Read `git machete status -L`
and/or parse `.git/machete` (indentation encodes the tree; a linear stack is a
chain). Capture the ordered list of branches. See command-recipes for the exact
commands and how to handle a tree vs. a linear chain.

### 2. Mechanical pass — find candidates

For each **earlier** branch `i` in the stack, compute the changes it *introduced*
relative to its **fork-point** (not raw `parent..branch` — that double-counts after
rebases; see detection-heuristics for why). For each file branch `i` touched,
determine whether any **later** branch `j` (`i < j ≤ tip`) further modifies or
deletes the same line regions. Record each hit as a candidate: the earlier branch,
the file, the introduced line range, and which later branch changed it.

This pass is purely structural — same file + overlapping line ranges. It
over-collects on purpose; the next pass filters.

### 3. Semantic pass — classify and filter

For each candidate, read the actual before/after hunks and classify it using the
taxonomy in detection-heuristics: **refactored**, **renamed/moved**, **deleted**,
**fixed-forward**, **cosmetic**, or **false-positive**. Then:

- **Suppress cosmetic and false-positive candidates** — not worth a reviewer's time.
- Keep the rest, recording *what* changed and *where* (the later `path:line` or the
  later PR's nature of change) so the draft is precise.

### 4. Map branches to PRs (read-only)

For each branch involved (earlier targets and later superseders), resolve its PR:
`gh pr view <branch> --json number,url,title,state` or
`gh pr list --head <branch> --state all --json number,url,title`. If a branch has
no PR yet, still draft — label the target and the superseder by branch name and note
"PR not yet opened."

### 5. Draft and group the report

Produce a single copy-paste-ready report **grouped by target PR/branch** (the
earlier PR that should receive the comment):

- Top-level summary: *N supersessions across M PRs.*
- Per target PR: the anchored draft comments. Use a **line-anchored** comment
  (naming `path:line`) when the superseded code is an identifiable hunk; fall back
  to **one PR-level summary comment** when it is a file move or a broad refactor.

Use the phrasing template in command-recipes. Tone: concise, factual, courteous
heads-up. Each draft names the later PR number/URL and (where applicable) the
`path:line` anchor.

After presenting the report, remind the user the drafts are theirs to post — you
will not post them.

## Reference Files

- [references/detection-heuristics.md](references/detection-heuristics.md) —
  fork-point subtlety, mechanical supersession detection, the semantic
  classification taxonomy, and what to suppress.
- [references/command-recipes.md](references/command-recipes.md) — exact read-only
  git / git-machete / gh recipes, the draft-comment phrasing template, and the
  report format.
