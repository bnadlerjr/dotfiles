# Fork-Points and Rebase Mechanics

How git-machete decides what to rebase, when inference goes wrong, and how to fix it.

## What a Fork-Point Is

For a child branch `B` with parent `A`, the fork-point is the commit at which `B` diverged from `A`'s history. `git machete update`/`traverse` rebases `B` from the fork-point onto the tip of `A`. Get the fork-point wrong and you either replay too few commits (losing work) or too many (replaying merged commits or other branches' commits).

## How Inference Works

git-machete infers the fork-point by walking the reflog and refs. It looks for the most recent commit reachable from `A` that is also reachable from a recent state of `B`. This works correctly when:

- `B` was branched from `A` and only ever rebased onto `A`.
- The reflog hasn't been pruned (`git gc` with aggressive settings).
- No history-rewriting tools (other than machete itself) have touched the chain.

It breaks when:

- `A` was force-pushed and pulled, replacing the commits `B` was branched from.
- `A`'s commits were squash-merged upstream and the squash isn't in the reflog.
- `B` was branched from a third party that's no longer in the tree.
- The reflog has been pruned.

## Inspecting the Fork-Point

```bash
# Show the inferred fork-point for a branch
git machete fork-point feature-b

# Show the fork-point that inference *would* produce, ignoring any override
git machete fork-point --inferred feature-b

# Status with hashes shows fork-points alongside commits
git machete status --list-commits-with-hashes
```

To inspect overrides directly (no dedicated subcommand exists), read the git config:

```bash
git config --get-regexp '^machete\.overrideForkPoint\.'
```

Symptoms of a wrong fork-point in `status -L`:

- A branch shows commits in its list that you know are already on the parent.
- A `?-` (yellow) edge in the tree — machete is uncertain.
- `traverse` proposes to replay commits with the same message twice.

## Overriding the Fork-Point

There are four override commands:

```bash
# Override to whatever inference *would* produce — pin it so it stops drifting
git machete fork-point --override-to-inferred feature-b

# Override to the current tip of the branch's machete-parent
# (use after a manual rebase off the chain, when the parent IS the right starting point)
git machete fork-point --override-to-parent feature-b

# Override to a specific commit
git machete fork-point --override-to=abc1234 feature-b
git machete fork-point --override-to=origin/main feature-b
git machete fork-point --override-to=$(git rev-parse HEAD~3) feature-b

# Remove an override (revert to live inference)
git machete fork-point --unset-override feature-b
```

Overrides are stored in `git config` under `machete.overrideForkPoint.<branch>.to` and `.whileDescendantOf`. View with:

```bash
git config --get-regexp '^machete\.overrideForkPoint\.'
```

The `whileDescendantOf` half is set automatically — the override is invalidated if `<branch>` is no longer a descendant of that commit (e.g., after a rebase that drops it). At that point machete falls back to inference again.

### When to Use Each Override

| Situation | Command |
|-----------|---------|
| Inference is right but unstable (drifts on each traverse) | `--override-to-inferred` |
| Parent was squash-merged upstream | `--override-to=<squash-sha>` |
| You rebased the branch off the chain and parent's tip is the right starting point | `--override-to-parent` |
| You rebased the branch off the chain onto a specific commit | `--override-to=HEAD~N` (where N = your branch's commits) |
| You want to start fresh | `--unset-override` |

## advance — Fast-Forward, Push, Slide Out

When a child branch's commits land on its parent (typical fast-forward merge), `advance` performs three steps in sequence:

1. Fast-forwards the parent (current branch) to the tip of the child.
2. Pushes the parent.
3. Slides the child out of the tree (and prompts to delete the local child branch).

Each step requires confirmation unless `-y/--yes` is passed. The only flag is `-y/--yes`.

```bash
# From the parent, advance to its child (prompts at each step)
git checkout main
git machete advance

# Auto-confirm everything (only works if parent has exactly one green-edge child)
git machete advance -y
```

`advance` selects the child via the green-edge criterion: the child must be a direct descendant of the parent's tip with the fork-point equal to the parent's tip. If multiple green-edge children exist, advance prompts; under `-y`, it fails. If none qualify, advance fails — fall back to `traverse` or a manual merge.

Side-effect to remember: step 2 pushes the parent. If the parent is `master`/`main`, pushing it is usually fine; if you've configured `push=no` on the parent, that step is skipped.

## squash — Collapse Branch Commits

```bash
# Squash all of the current branch's commits (since fork-point) into one
git machete squash

# Squash with a specific message
git machete squash -m "feat: implement feature-b"

# Squash from a specific fork-point (override)
git machete squash --fork-point=abc1234
```

`squash` is the cleaner alternative to interactive rebase when you just want one commit. It uses the fork-point as the squash boundary, so every commit unique to the branch becomes one commit.

## reapply — Rebase Branch Onto Itself

```bash
# Open interactive rebase from fork-point onto current tip
git machete reapply

# With explicit fork-point override
git machete reapply --fork-point=abc1234
```

Useful for cleaning up commits on the current branch (squash, reorder, edit) without changing what it's based on. Equivalent to `git rebase -i <fork-point>`, but uses machete's fork-point inference.

## Annotations and Qualifiers in `.git/machete`

Free-form text after a branch name is the annotation, displayed in `status`:

```text
main
    feature-a    PR #123 — backend
        feature-b    PR #124 — frontend on top of -a
```

Manage annotations from the CLI:

```bash
# Set
git machete anno -b feature-a "PR #123 — backend"

# Set on current branch
git machete anno "PR #123 — backend"

# Clear
git machete anno -b feature-a ""

# Show
git machete anno -b feature-a
```

### Qualifiers

Special tokens in the annotation control traverse behavior per branch:

| Qualifier | Effect |
|-----------|--------|
| `push=no` | Skip pushing this branch in `traverse --push` |
| `rebase=no` | Skip rebasing this branch (treat as in-sync) |
| `slide-out=no` | Refuse to slide this branch out automatically |

```text
main
    release-1.x    push=no rebase=no  # frozen release branch
    feature-a
        feature-b
```

## Common Repair Recipes

### "After upstream squash-merged my parent, my branch is full of duplicate commits"

```bash
# Find the squash commit on main
git log --oneline main | head -5

# Pin the fork-point to it
git machete fork-point --override-to=<squash-sha> feature-b

# Verify status looks right
git machete status -L

# Then traverse normally
git machete traverse
```

### "I rebased my branch manually and now machete thinks all parent commits are mine"

```bash
# Pin to inferred — stops the drift
git machete fork-point --override-to-inferred feature-b
```

### "My branch's fork-point keeps moving each time I traverse"

The reflog isn't telling a clean story. Pin it:

```bash
git machete fork-point --override-to-inferred feature-b
```

### "I want to redo what machete just rebased"

```bash
# git-machete leaves an ORIG_HEAD-equivalent — recover via reflog
git reflog show feature-b | head -10
git reset --hard feature-b@{1}    # or whichever entry pre-dates the rebase
```

## Gotchas

- Overrides become stale silently when the branch is rebased — the `whileDescendantOf` clause invalidates them. Re-set after major history changes.
- `advance` with multiple eligible children prompts interactively; pass `-y` only when you've checked which child it'll pick.
- `squash` uses the fork-point as the boundary — if the fork-point is wrong, you'll squash the wrong commits.
- `reapply` is interactive by default. Pass `--no-interactive-rebase` if you just want a non-editing fork-point repair.
- After any rebase machete performs, the remote will reject a plain `git push`. Use `git push --force-with-lease` or let `traverse --push` handle it.
- `--override-to=<ref>` resolves the ref *now*. If you pass a branch name and it moves later, the override doesn't follow. Use a SHA when you want stability.
