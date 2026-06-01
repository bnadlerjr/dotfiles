# Command Recipes & Output Templates

All commands here are **read-only**. Never run a writing `gh` command
(`gh pr comment`, `gh pr review`, `gh api -X POST/PATCH/PUT/DELETE`). Never run a
writing `git` command. This skill drafts; the human posts.

For git-machete command semantics, delegate to the `using-git-machete` skill. For
`jq` filters over `gh --json` output, delegate to the `using-jq` skill.

## 1. Discover the stack (root → tip)

```bash
# Tree with line/commit annotations (preferred — shows the chain visually)
git machete status -L

# Raw tree definition — indentation encodes parent/child; a linear stack is a chain
cat .git/machete
```

Parse `.git/machete`: each line is a branch; leading indentation depth gives the
parent. A linear stack has each branch indented one level under the previous, giving
the ordered list base→tip. For a non-linear tree, walk each root-to-leaf path
independently and treat each path as its own stack.

## 2. Per-branch introduced changes (fork-point aware)

```bash
# Preferred: diff a branch against its machete fork-point
git machete diff <branch_i>

# Explicit fork-point, then a plain diff (use if you need the SHA)
fp=$(git machete fork-point <branch_i>)
git diff "$fp".."<branch_i>"

# Files a branch introduced (name + status)
git diff --name-status "$fp".."<branch_i>"
```

Do **not** use `<parent>..<branch_i>` — after rebases it double-counts. See
detection-heuristics for the fork-point rationale.

## 3. Cross-branch supersession detection

```bash
# Net downstream effect on one file, between earlier branch and the tip
git diff <branch_i>..<branch_tip> -- <file>

# Was a specific introduced range later changed, and in which commit?
# (combining -L with a revision range needs a reasonably modern Git, ~2.20+)
git log -L<start>,<end>:<file> <branch_i>..<branch_tip>

# Portable fallback if the ranged form misbehaves: log the line range on the tip,
# then intersect the resulting commits with the stack via `git branch --contains`.
git log -L<start>,<end>:<file> <branch_tip>

# Catch moves/renames downstream (don't misread a move as delete+add)
git diff --find-renames --find-copies <branch_i>..<branch_tip>

# Does an introduced line still exist at the tip? (deletion check)
git show <branch_tip>:<file>            # inspect the tip's version
# If the introduced text is absent here and log -L ends in a removal → deleted downstream
```

Resolve a superseding commit back to its branch (the lowest branch in the chain that
contains it):

```bash
git branch --contains <commit_sha>      # intersect with the stack's branch list
```

## 4. Branch → PR mapping (read-only)

```bash
# Preferred: direct view by branch (head)
gh pr view <branch> --json number,url,title,state

# Alternative: list (covers closed/merged too)
gh pr list --head <branch> --state all --json number,url,title,state
```

If neither returns a PR, the branch has no PR yet. Still draft — label the target and
the superseder by branch name and add "(PR not yet opened)". Pipe `--json` output
through `jq` per the `using-jq` skill, e.g.:

```bash
gh pr view <branch> --json number,url --jq '"#\(.number) \(.url)"'
```

## 5. Draft comment phrasing template

Tone: concise, factual, courteous heads-up. Always name the later PR (number/URL).
Include the `path:line` anchor when line-anchored.

**Line-anchored comment** (paste as a line-level review comment at `path:line`):

```
Heads-up — the `<symbol/area>` here is <refactored|renamed|moved|removed|fixed>
later in this stack in #<N> (<url>), so its current form is intentionally
temporary. No need to comment on it.
```

Category-specific variants:

- **refactored:** "…is refactored in #N, so its current shape is intentionally temporary."
- **renamed/moved:** "…is moved to `new/path.ext` (or renamed to `newName`) in #N."
- **deleted:** "…is removed entirely in #N — it does not survive to the tip of the stack."
- **fixed-forward:** "…this `<bug/issue>` is fixed in #N later in the stack."

**PR-level summary comment** (fallback for file moves / broad refactors that do not
map to one clean hunk):

```
Heads-up for reviewers: several areas in this PR are superseded later in the stack.
Before commenting, note:
- `<path>` — <what> is <category> in #<N> (<url>)
- `<path>` — <what> is <category> in #<M> (<url>)
These are intentional given the stacking order; no need to flag them on this PR.
```

## 6. Report format (final output, copy-paste ready)

```
# Stack PR Comment Drafts

Summary: <N> supersessions across <M> PRs.
Stack (root→tip): <branch_a> → <branch_b> → <branch_c>

---

## Target: PR #<N> — <title>  (branch `<branch>`)
<url>

### Line-anchored — `path/to/file.ext:42`
Category: refactored → superseded by PR #<M>
> Heads-up — the `parseConfig` helper here is refactored in #<M> (<url>), so its
> current form is intentionally temporary. No need to comment on it.

### PR-level summary
> Heads-up for reviewers: <…>

---

## Target: PR #<N2> — <title>  (branch `<branch2>`)
...
```

After printing the report, remind the user: these are drafts — review and post each
one yourself; this skill does not post to GitHub.
