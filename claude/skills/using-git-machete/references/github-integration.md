# GitHub Integration and Stacked PRs

`git machete github` subcommands for driving stacked PRs against GitHub.

## Setup and Authentication

git-machete resolves a GitHub token from the first source that yields one, in this order:

1. `GITHUB_TOKEN` environment variable
2. `~/.github-token` file
3. `gh auth token` (if `gh` CLI is installed and authenticated)
4. `hub` CLI auth token (if `hub` is installed and authenticated)

`~/.github-token` supports per-domain entries (one token per line; bare tokens default to `github.com`):

```text
ghp_token_for_github_com
ghp_token_for_enterprise git.example.org
ghp_token_for_other_enterprise git.example.com
```

```bash
# Quickest setup if gh CLI is present
gh auth login
git machete github checkout-prs --mine     # picks up gh's token

# Verify which token source is being used
git machete github --debug checkout-prs --mine 2>&1 | grep -i token
```

GitLab equivalents exist (`git machete gitlab ...`) and follow the same shape; this reference covers GitHub.

### Git Config Keys

Repo-detection keys (used when `git remote get-url origin` can't be parsed, e.g., GitHub Enterprise):

| Key | Purpose |
|-----|---------|
| `machete.github.domain` | GitHub Enterprise hostname (e.g., `git.example.org`) |
| `machete.github.remote` | Name of the remote to use (default: inferred) |
| `machete.github.organization` | GitHub org/user (must be set together with repository) |
| `machete.github.repository` | GitHub repo name (must be set together with organization) |

Behavior keys:

| Key | Effect |
|-----|--------|
| `machete.github.annotateWithUrls` | When `true`, every command that writes PR numbers into annotations also includes the full PR URL. |
| `machete.github.forceDescriptionFromCommitMessage` | When `true`, `create-pr` always takes the PR description from the first unique commit's message body, ignoring `.git/info/description` and `.github/pull_request_template.md`. |
| `machete.github.prDescriptionIntroStyle` | Selects the auto-generated "intro" section appended to PR descriptions. Values: `full`, `full-no-branches`, `up-only` (default), `up-only-no-branches`, `none`. |

There is no `machete.github.token` config key — token comes from env/file/CLI as listed above.

## Reconstructing a Stack Locally

When you need to review or contribute to someone else's stacked PRs:

```bash
# Check out a specific PR and rebuild the chain in .git/machete
git machete github checkout-prs 1234

# Check out all PRs by a specific user (rebuilds the whole stack)
git machete github checkout-prs --by=alice

# Check out PRs authored by the authenticated user
git machete github checkout-prs --mine

# Check out every open PR
git machete github checkout-prs --all
```

`checkout-prs` does three things:

1. Fetches the PR head refs locally as branches.
2. Adds them to `.git/machete` with the upstream PR's base as parent.
3. Sets each branch's annotation to the PR number (and URL if `machete.github.annotateWithUrls=true`).

When the current user is NOT the author, `checkout-prs` adds `rebase=no push=no` qualifiers automatically so traverse won't touch someone else's PR.

Run `git machete status -L` after to verify the reconstructed tree.

## Creating a New PR for the Current Branch

```bash
# Open a PR with the current branch's parent (in machete) as the base
git machete github create-pr

# Open as draft
git machete github create-pr --draft

# Override the title (default: first commit subject)
git machete github create-pr --title "feat: add widget"

# Don't ask for confirmation before pushing
git machete github create-pr --yes

# Update related PRs' description "intros" to include this new PR
git machete github create-pr -U
```

Key behavior: `create-pr` uses the **machete parent**, not `main`, as the PR base. This is the entire reason to use it for stacked PRs — each PR targets the one below it in the stack rather than `main`.

If `.git/info/milestone` or `.git/info/reviewers` exists, their contents are applied. PR description comes from `.git/info/description` or `.github/pull_request_template.md` if present (or the first commit's message body when `machete.github.forceDescriptionFromCommitMessage=true`).

## Maintaining the Stack: restack-pr

`restack-pr` is the workhorse for stacked-PR workflows. It:

1. If the PR is ready-for-review, converts it to draft (so CODEOWNERS aren't auto-pinged on every push).
2. Retargets the PR's base on GitHub to its machete parent (same as `retarget-pr`).
3. Force-pushes the branch (with `--force-with-lease`).
4. If step 1 drafted the PR, reverts it to ready-for-review.

```bash
# Restack the current PR
git machete github restack-pr

# Restack and update related PR descriptions' intros
git machete github restack-pr -U
git machete github restack-pr --update-related-descriptions
```

The only flag is `-U/--update-related-descriptions`. There is no `--yes`.

The canonical stacked-PR loop after the bottom of the stack changes (e.g., review feedback on PR #1 in a stack of #1 → #2 → #3):

```bash
# Make changes on PR #1's branch
git checkout pr-1-branch
# ... edit, commit ...

# Walk up the stack, rebasing and syncing PR bases on GitHub in one pass
git machete traverse --fetch -H --push --start-from=root
```

`traverse -H` (`--sync-github-prs`) retargets PR bases on GitHub during traversal whenever the GitHub base differs from the machete parent. This replaces the previously documented `github sync` flow.

## retarget-pr — Change Just the Base

When you want to change a PR's base on GitHub without rebasing:

```bash
# Set the current branch's PR base to its machete parent
git machete github retarget-pr

# Specify which branch to operate on (default: current)
git machete github retarget-pr -b feature-x
git machete github retarget-pr --branch=feature-x

# Don't fail if there's no PR for the branch (useful in scripts)
git machete github retarget-pr --ignore-if-missing

# Update related PR descriptions' intros after retargeting
git machete github retarget-pr -U
```

The PR's new base is **always** the machete parent of the branch. There is no `--to=<branch>` flag — to retarget a PR to a different parent, edit `.git/machete` to move the branch under that parent first, then run `retarget-pr`. There is no `--dry-run` flag either.

Real flags: `-b/--branch=<branch>`, `--ignore-if-missing`, `-U/--update-related-descriptions`.

## anno-prs — Set Annotations From PR Data

```bash
# Populate annotations from PR titles/numbers for branches with open PRs
git machete github anno-prs

# Include full PR URLs in the annotations
git machete github anno-prs --with-urls
```

`--with-urls` is unique to `anno-prs`. To get URLs in annotations from `checkout-prs`, `create-pr`, `retarget-pr`, or `restack-pr`, set the `machete.github.annotateWithUrls` config key:

```bash
git config machete.github.annotateWithUrls true
```

The result in `.git/machete`:

```text
main
    feature-a    PR #123 — feat: backend API
        feature-b    PR #124 — feat: frontend
```

For non-author PRs, `anno-prs` adds `rebase=no push=no` qualifiers — same as `checkout-prs`.

## update-pr-descriptions — Refresh Generated Intros

`create-pr`, `restack-pr`, and `retarget-pr` write a generated section ("intro") into PR descriptions listing the upstream/downstream PR chain, delimited by `<!-- start git-machete generated -->` and `<!-- end git-machete generated -->` comments. `update-pr-descriptions` rewrites those intros without touching the rest of the description.

```bash
# Update intros for every open PR in the repo
git machete github update-pr-descriptions --all

# Update intros for PRs authored by a specific user
git machete github update-pr-descriptions --by=alice

# Update intros for PRs authored by the authenticated user
git machete github update-pr-descriptions --mine

# Update intros for the current branch's related PRs (up- and/or downstream)
git machete github update-pr-descriptions --related
```

`--related` is the most common form. Whether it touches downstream and/or upstream PRs depends on `machete.github.prDescriptionIntroStyle`:

| Value | Intro contents | `--related` updates |
|-------|----------------|---------------------|
| `full` | Upstream chain + downstream tree | Both up and down |
| `full-no-branches` | Same as full, no branch names | Both up and down |
| `up-only` (default) | Upstream chain only | Downstream only |
| `up-only-no-branches` | Same as up-only, no branch names | Downstream only |
| `none` | No intro | Nothing |

```bash
# Switch to "full" intros across the repo
git config machete.github.prDescriptionIntroStyle full
git machete github update-pr-descriptions --all
```

## A Note on `github sync` (Deprecated)

`git machete github sync` still exists in 3.35.1 but is deprecated. Modern equivalents:

- For the "checkout my PRs and clean up stale local branches" use case: `github checkout-prs --mine` + `delete-unmanaged` + `slide-out --removed-from-remote`.
- For the "update PR bases on GitHub to match the local tree" use case: `traverse --fetch -H` (per-branch) or `github retarget-pr` (single branch).

Don't use `sync` in new workflows; it's listed in `git machete github --help` only for backward compatibility.

## Stacked-PR Workflow End-to-End

### Starting a New Stack

```bash
# Branch 1: backend API
git checkout -b feat/api main
git machete add feat/api --onto=main
# ... commit work ...
git machete github create-pr --draft

# Branch 2: frontend, on top of branch 1
git checkout -b feat/ui feat/api
git machete add feat/ui --onto=feat/api
# ... commit work ...
git machete github create-pr --draft

# Branch 3: docs, on top of branch 2
git checkout -b feat/docs feat/ui
git machete add feat/docs --onto=feat/ui
# ... commit work ...
git machete github create-pr --draft

git machete status -L                 # verify the stack
```

### Iterating on Review Feedback

```bash
# Reviewer asks for changes on the bottom PR
git checkout feat/api
# ... edit, commit, amend, whatever ...

# Sync the whole stack — rebase children, force-push, retarget PR bases on GitHub
git machete traverse --fetch -H --push --start-from=here -y
```

### When the Bottom Merges

```bash
# Pull main, advance the bottom PR's branch out (ff main, push, slide out feat/api)
git checkout main && git pull
git machete advance

# The next PR (feat/ui) is now at the bottom — retarget its base on GitHub to main
git checkout feat/ui
git machete github retarget-pr

# Restack to clean up history (optional but standard)
git machete github restack-pr
```

### Reviewing Someone Else's Stack

```bash
# Pull all of alice's open PRs and rebuild her tree locally
git machete github checkout-prs --by=alice

# Inspect
git machete status -L

# Walk the stack
git machete go root
# ... review ...
git machete go down
# ... review ...
```

## Common Errors and Fixes

### "Could not determine the GitHub repo"

git-machete reads `git remote get-url origin` to figure out the repo. If your remote isn't named `origin` or uses an SSH URL it can't parse:

```bash
git remote -v
# explicitly set the repo
git config machete.github.remote origin
git config machete.github.organization myorg
git config machete.github.repository myrepo
```

For GitHub Enterprise, usually only `machete.github.domain` is needed.

### "PR has no parent in the local tree"

You ran `restack-pr`/`retarget-pr` but the PR's base branch isn't in `.git/machete`. Add it:

```bash
git machete add <base-branch> --onto=main
```

### "API rate limit exceeded"

Authenticate. Unauthenticated calls have a 60/hr limit; authenticated calls have 5000/hr.

```bash
gh auth status
export GITHUB_TOKEN=$(gh auth token)
```

## Gotchas

- `create-pr` uses the **machete parent** as the base. If `.git/machete` is wrong, the PR base will be wrong. Verify with `status -L` first.
- `restack-pr` force-pushes (with lease). If a teammate has pushed to your branch, the lease will refuse — inspect before forcing.
- `retarget-pr` only retargets to the machete parent — there is no `--to`. To retarget elsewhere, move the branch in `.git/machete` first.
- `checkout-prs` overwrites the affected portion of `.git/machete` — back up your tree if you've curated annotations.
- `traverse -H` retargets PR bases as it walks; if you want only the retarget side-effect (no rebase/push), use `github retarget-pr` per branch instead.
- `update-pr-descriptions --related` honors `prDescriptionIntroStyle` — under the default `up-only`, it touches downstream PRs only. Set the key to `full` if you also need upstream PR intros refreshed.
- GitHub's "merge queue" and "auto-merge" features can race with `restack-pr` and `traverse -H`. Disable them on stacked PRs while iterating.
