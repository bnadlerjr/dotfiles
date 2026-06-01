# Detection Heuristics

How to find supersessions (mechanical) and decide which are worth a comment
(semantic). For the exact commands, see [command-recipes.md](command-recipes.md).

## The fork-point subtlety

A branch's *introduced* changes are its diff against its **fork-point**, not against
its parent's current HEAD.

After you rebase a stack, `parent..branch` no longer isolates one branch's work:
the parent's tip has moved, and commits can appear on both sides, so a raw
`parent..branch` diff double-counts or mis-attributes hunks. git-machete tracks each
branch's fork-point (the commit where the branch genuinely diverged, inferred from
reflogs) precisely to survive rebases and force-pushes.

Therefore, to get what branch `i` actually introduced:

- Prefer `git machete diff <branch_i>` (diffs the branch against its fork-point), or
- Compute the fork-point with `git machete fork-point <branch_i>` (fall back to
  `git merge-base` only if needed) and diff `<fork-point>..<branch_i>`.

Delegate fork-point reasoning to the `using-git-machete` skill if inference looks
wrong (e.g., after a squash the fork-point may need an explicit override).

## Mechanical pass — candidate detection

You are looking for: **lines introduced by an earlier branch whose same file +
overlapping line range is later modified or deleted by a downstream branch.**

For each earlier branch `i` (every branch except the tip) and each file it touched:

1. **Net downstream effect on the file.** `git diff <branch_i>..<branch_tip> -- <file>`
   shows the cumulative change between branch `i`'s state and the tip for that file.
   A non-empty diff means downstream branches touched it. Treat this only as a coarse
   "did anything change" gate — the two-dot range shows net difference between the two
   endpoints, so it hides a change that was introduced then reverted downstream and does
   not attribute the change to a branch. Step 2's `git log -L` is authoritative for
   *which* commit (hence which branch/PR) actually changed a given range.
2. **Per-range attribution.** For a specific range introduced in branch `i`,
   `git log -L<start>,<end>:<file> <branch_i>..<branch_tip>` shows whether that range
   was later changed and *in which commit* — map the commit back to its branch (hence
   its PR) to know which later PR supersedes it.
3. **Moves and renames.** Run diffs with `--find-renames` / `--find-copies` so a file
   relocated downstream is recognized as a move, not a delete+add.
4. **Deletions.** A line added in branch `i` that no longer exists at the tip is a
   downstream deletion. Detect by checking whether the introduced range survives to
   `branch_tip` (the `log -L` history ends in a removing commit, or the line is absent
   from the tip's version of the file).

Record each candidate as: `earlier_branch`, `file`, `introduced_range`,
`later_branch(es)`, `later_commit(s)`. Over-collect here; the semantic pass filters.

### Mapping line ranges back to later PRs

Each superseding commit belongs to exactly one branch in the stack. Resolve the
commit's branch (it is the lowest branch in the chain that contains the commit), then
map that branch to its PR number in the branch→PR step. That PR number is what the
draft comment cites ("handled later in #N").

## Semantic pass — classification taxonomy

Read the actual before/after hunks for each candidate and assign one category. Each
has a one-line heuristic:

| Category | Heuristic | Draft it? |
|----------|-----------|-----------|
| **refactored** | Same observable behavior, different shape (extracted function, restructured logic) | Yes |
| **renamed/moved** | An identifier or whole file relocated/renamed downstream | Yes |
| **deleted** | The introduced code is removed entirely in a later branch | Yes |
| **fixed-forward** | A bug or known issue in the earlier code is corrected in a later branch | Yes |
| **cosmetic** | Formatting / whitespace / comment-only change downstream, behavior identical | **No — suppress** |
| **false-positive** | Lines touched again for an unrelated reason (range overlap is coincidental, different concern) | **No — suppress** |

### Distinguishing the tricky cases

- **refactored vs. cosmetic:** if the downstream change only reflows whitespace,
  reorders imports, or edits comments, it is cosmetic — a reviewer commenting on the
  earlier form is not wasting effort, so suppress. If structure or naming changed such
  that earlier-form feedback is moot, it is refactored — draft it.
- **fixed-forward vs. false-positive:** fixed-forward means the *same logical code*
  is corrected later (worth telling the reviewer "the bug here is fixed in #N").
  False-positive means the later branch edited adjacent or overlapping lines for an
  unrelated change; the earlier code stands on its own — suppress.
- **renamed/moved vs. deleted:** use `--find-renames`/`--find-copies`. If the content
  reappears elsewhere, it is moved/renamed (cite the new location); if it genuinely
  vanishes, it is deleted.

When uncertain between a "draft it" category and false-positive, lean toward
suppressing — a wrong preemptive comment is worse than a missing one.

## Output of these passes

A filtered list of supersessions, each with: target (earlier) branch+PR, the
`path:line` of the superseded code, the category, a one-line description of what
changed, and the later branch+PR that superseded it. This feeds the draft templates
in command-recipes.
