---
name: using-git-machete
description: |
  git-machete command-line expertise covering branch tree management, fork-point
  mechanics, rebase-driven syncing, and stacked-PR workflows on GitHub.

  Use when building or maintaining a tree of dependent branches, rebasing chains
  of feature branches against `main`, debugging fork-point inference after
  force-pushes or squashes, or driving stacked GitHub PRs with `git machete
  github` subcommands. Also use for `.git/machete` edits, `traverse` flag
  selection, and `advance`/`slide-out` after merges.
---

# Using git-machete

Expert guidance for managing branch trees and stacked PRs with `git-machete` (v3.x).

## Quick Start

For immediate help, identify your task type and consult the relevant reference:

| Working On | Reference File | Key Topics |
|------------|----------------|------------|
| discover, edit, add, status, traverse, slide-out | [core-commands](references/core-commands.md) | Branch tree CRUD, traversal flags, status -L |
| fork-point overrides, advance, squash, reapply | [fork-points-and-rebase](references/fork-points-and-rebase.md) | Fork-point inference, overrides, annotations |
| github checkout-prs, create-pr, restack-pr, retarget-pr, anno-prs, update-pr-descriptions | [github-integration](references/github-integration.md) | Stacked PRs, retarget, anno-prs |

## Core Principles

### `.git/machete` Is the Source of Truth

The branch tree lives in `.git/machete`, an indented text file. Most "machete is wrong" problems are solved by running `git machete edit` and fixing the indentation by hand.

```bash
git machete edit         # opens .git/machete in $GIT_EDITOR
cat .git/machete         # inspect without editing
```

### `status -L` Is the Default Diagnostic

Always start with `git machete status -L` (or `--list-commits`). It shows the tree, sync state of each branch versus its parent, and the commits unique to each branch. Plain `status` hides the commits and hides why a branch is out of sync.

```bash
git machete status -L                # tree + commits per branch
git machete status -L --color=always | less -R
```

### Let `traverse` Drive Rebases — Don't Run `git rebase` Yourself

`git machete traverse` walks the tree, rebases each branch onto its parent's tip using machete's fork-point inference, and (optionally) pushes. Running `git rebase` directly on a managed branch bypasses fork-point logic and creates duplicate commits on the next traverse.

```bash
git machete traverse --fetch --start-from=root --return-to=here
```

### Trust Fork-Point Inference Until It's Wrong, Then Override Explicitly

Fork-points are inferred from the reflog. Force-pushes, upstream squash-merges, and rebases off the chain corrupt that inference. Fix with `--override-to-inferred` or `--override-to=<commit>` rather than editing history blindly.

```bash
git machete fork-point --override-to-inferred my-branch
git machete fork-point --override-to=abc1234 my-branch
git machete fork-point --unset-override my-branch
```

### After a PR Merges, `advance` — Don't `slide-out`

When a child branch's commits land on its parent (typical after a squash-merge or fast-forward merge), `git machete advance` fast-forwards the parent and slides the child out of the tree in one step. Use `slide-out` only when the branch was abandoned without merging.

```bash
git machete go down && git machete advance      # advance to current child
```

## Common Pattern Template

The canonical daily loop for a managed tree:

```bash
git machete status -L                            # see the tree
git machete traverse --fetch --push --start-from=first-root
# ... resolve any rebase conflicts as prompted ...
git machete status -L                            # verify
```

For starting a new feature on top of an existing branch:

```bash
git checkout parent-branch
git machete add new-feature --onto=parent-branch --as-first-child
# ... commit work ...
git machete traverse --push                      # rebase + push
```

## Anti-Patterns

### Editing `.git/machete` to Remove a Merged Branch

```bash
# BAD — leaves the local branch behind, skips ff of parent
$EDITOR .git/machete

# GOOD — fast-forwards parent and removes child in one step
git checkout merged-child
git machete advance
```

### Running `git rebase` on a Managed Branch

```bash
# BAD — bypasses fork-point inference, duplicates commits next traverse
git checkout feature-b
git rebase feature-a

# GOOD — let machete compute the fork-point
git machete update                               # rebase current branch onto parent
# or for the whole tree:
git machete traverse
```

### Force-Pushing Without `--force-with-lease` After a Rebase

```bash
# BAD — clobbers any teammate commits pushed since you fetched
git push --force

# GOOD — refuses to overwrite remote work you haven't seen
git push --force-with-lease
# or, best, let traverse handle it:
git machete traverse --push
```

### Trusting Fork-Point After a Squash-Merge Upstream

```bash
# BAD — traverse will try to replay already-merged commits
git machete traverse

# GOOD — pin the fork-point to the squash commit, then traverse
git machete fork-point --override-to=<squash-sha> child-branch
git machete traverse
```

## Reference File IDs

For programmatic access: `core-commands` · `fork-points-and-rebase` · `github-integration`
