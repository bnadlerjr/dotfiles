# Core git-machete Commands

Practical reference for building and maintaining the branch tree.

## The `.git/machete` File

The branch tree is stored as an indented text file at `.git/machete`. Children are nested under parents with consistent indentation (tabs or spaces; pick one). Annotations after the branch name are free-form text shown in `status`.

```text
main
    feature-a    PR #123 backend changes
        feature-b    PR #124 frontend on top of -a
        feature-c    spike — do not merge
    hotfix-login
develop
```

Key rules:
- Roots are at column 0 (typically `main`, `develop`, release branches).
- Indentation depth = tree depth. Be consistent — mixing tabs and spaces breaks parsing.
- Anything after the branch name (separated by whitespace) is the annotation.
- `qualifiers` like `push=no` or `rebase=no` can be attached as annotations to suppress traverse behavior per branch.

```text
main
    feature-a    push=no  # never push this one
    feature-b    rebase=no slide-out=no
```

## Discovering and Editing the Tree

```bash
# Build an initial tree by inferring parents from reflog/refs
git machete discover

# Preview without writing
git machete discover --list-commits

# Constrain to specific roots (useful in repos with stale branches)
git machete discover --roots=main,develop

# Edit the file directly in $GIT_EDITOR
git machete edit

# Show the file path (useful for piping or scripting)
git machete file
```

`discover` is destructive — it overwrites `.git/machete`. Run it on a fresh repo or after a major reorg, not on a tree you've curated.

## Adding and Removing Branches

```bash
# Add the currently-checked-out branch under its tracked-upstream's parent
git machete add

# Add an existing branch as a child of the current branch
git machete add feature-b

# Add explicitly under a specific parent
git machete add feature-c --onto=feature-a

# Add as the first child (default appends as last); -f is the short flag
git machete add feature-c --onto=feature-a --as-first-child
git machete add feature-c --onto=feature-a -f

# Create AND add a new branch in one step
git machete add --as-first-child new-feature --onto=main

# Remove a branch from the tree, re-parenting its children to its parent
git machete slide-out feature-b

# Slide out and run the children's rebase non-interactively (no editor)
git machete slide-out --no-interactive-rebase feature-b

# Slide out and merge children into the new parent instead of rebasing
git machete slide-out -M feature-b

# Use a specific fork-point for the children's rebase (preserves more history)
git machete slide-out -d <commit-sha> feature-b

# Slide out and delete the local branch
git machete slide-out --delete feature-b
```

`slide-out` is for abandoned branches. For merged branches, prefer `advance` (see fork-points reference).
By default `slide-out` rebases children onto the new parent interactively. `--no-interactive-rebase`
only suppresses the editor; to avoid the rebase entirely use `-M/--merge` (merge instead) or pin
`-d/--down-fork-point=<commit>` to control which range gets replayed.

## Status — The Workhorse Diagnostic

```bash
# Tree only
git machete status

# Tree + commits unique to each branch (most useful form)
git machete status -L
git machete status --list-commits

# Show fork-point shas alongside commits
git machete status --list-commits-with-hashes

# Color forced on for piping
git machete status -L --color=always | less -R
```

Edge colors in `status` output (parent-to-child edge):
- Red (`x-`): branch is NOT a direct descendant of upstream — rebase needed.
- Yellow (`?-`): direct descendant of upstream BUT fork-point ≠ upstream — fork-point override likely needed.
- Green (`o-`): direct descendant AND fork-point = upstream — in sync.
- Grey/dimmed (`m-`): branch has been merged into upstream (commit-equivalency or strict merge detection) — `advance` or `slide-out` candidate.

Remote sync indicators after the branch name:
- `(ahead of origin)` — local has commits not on remote
- `(behind origin)` — remote has commits not local
- `(diverged from origin)` — both, force-push likely needed
- `(untracked)` — never pushed

## Traversal — Syncing the Whole Tree

```bash
# Interactive walk through the tree, rebasing each branch onto its parent
git machete traverse

# Fetch all remotes first (almost always what you want)
git machete traverse --fetch

# Start from a specific point in the tree
git machete traverse --start-from=here              # current branch
git machete traverse --start-from=root              # current branch's root
git machete traverse --start-from=first-root        # first root in file

# Return to a specific branch when done
git machete traverse --return-to=here               # branch you started on
git machete traverse --return-to=nearest-remaining  # last touched branch
git machete traverse --return-to=stay               # whatever traverse ended on

# Always push / never push (default: prompt per branch)
git machete traverse --push
git machete traverse --no-push

# Skip the interactive rebase editor (just replay commits)
git machete traverse --no-interactive-rebase

# Don't prompt for any decisions — auto-yes
git machete traverse -y
git machete traverse --yes

# Walk the entire tree regardless of where you start
git machete traverse --whole

# Sync PR bases on GitHub during traversal (retargets any PR whose base differs
# from the machete parent). Replaces the deprecated `github sync`.
git machete traverse --fetch -H --push

# Use exact patch comparison to detect upstream squash-merges (slower but
# catches more cases than the default `simple` mode)
git machete traverse --squash-merge-detection=exact

# Combine: a "sync everything from origin" one-liner
git machete traverse --fetch --whole --push --no-interactive-rebase -y
```

Common combinations:

```bash
# Daily morning sync — fetch, rebase current branch's lineage, push
git machete traverse --fetch --start-from=root --return-to=here --push

# Pre-PR cleanup — current branch only, no push
git machete traverse --start-from=here --return-to=here --no-push -y

# After a long absence — full sync, no prompts
git machete traverse --fetch --whole --push -y
```

## Update — Rebase a Single Branch

```bash
# Rebase the current branch onto its machete-parent (uses fork-point)
git machete update

# Don't open the interactive rebase editor
git machete update --no-interactive-rebase

# Rebase onto a specific commit instead of the parent's tip
git machete update --fork-point=abc1234
```

`update` is `traverse` for one branch. Use it when you don't want to walk the whole tree.

## Navigation

```bash
git machete go up         # checkout parent
git machete go down       # checkout first child
git machete go next       # checkout next branch in file order
git machete go prev       # checkout previous branch in file order
git machete go root       # checkout current branch's root

# Short aliases
git machete g u           # up
git machete g d           # down
```

## Maintenance

```bash
# Local branches not in the tree
git machete list unmanaged

# Local branches that exist on remote and can be deleted
git machete delete-unmanaged

# Check whether a branch is managed (exit code 0/1, scripting-friendly)
git machete is-managed feature-x && echo "yes" || echo "no"

# Show the parent of a branch
git machete show up feature-x
git machete show down feature-x      # first child
git machete show root feature-x

# Show the entire tree as paths
git machete list managed
git machete list addable                      # branches that could be added
git machete list slidable                     # branches whose only child is itself
git machete list childless                    # managed branches with no children
git machete list with-overridden-fork-point   # branches with an override config key set
```

## Gotchas

- `discover` overwrites `.git/machete` — back it up first if you've curated annotations.
- `slide-out` rebases children onto the new parent by default; pass `--no-interactive-rebase` to skip the editor or keep the children unchanged.
- `traverse` stops on conflict — resolve with `git rebase --continue`, then re-run `git machete traverse` from the same branch. Traverse is stateless: there is no `--continue` flag, no `.git/rebase-apply` state of its own. Just invoke it again and it picks up from the current branch.
- For upstream squash-merges that the default detector misses, run `git machete traverse --squash-merge-detection=exact` (slower; compares patches commit-by-commit).
- `status` without `-L` is misleading; you can't tell *why* a branch is out of sync.
- `.git/machete` indentation must be consistent. If parsing breaks, run `git machete edit` and fix by eye.
- `git machete add` without arguments adds the *current* branch — easy to add the wrong one if you forgot to checkout first.
