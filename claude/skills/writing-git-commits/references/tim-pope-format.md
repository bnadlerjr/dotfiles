# Tim Pope Commit Message Format

Detailed reference for Tim Pope's commit message style, the de facto standard for well-formatted Git commits.

## The Seven Rules

### 1. Separate Subject from Body with Blank Line

```
Subject line (50 chars or less)

Body starts here after the blank line. This separation allows
tools like `git log --oneline` to show just subjects while
`git log` shows the full message.
```

Git commands that benefit from this separation:
- `git log --oneline` - Shows only subjects
- `git shortlog` - Groups commits by author with subjects
- `git rebase -i` - Shows subjects in the pick list
- GitHub/GitLab - Uses subject as PR merge commit title

### 2. Limit Subject to ~50 Characters

**Why 50?**
- GitHub truncates at 72 with ellipsis
- `git log --oneline` fits nicely in 80-char terminal
- Forces concise, focused descriptions
- Easier to scan in logs

**The guideline:**
- Aim for 50 characters
- Hard limit at 72 characters
- Never exceed 72

**Character counting tip:**
```
         1         2         3         4         5         6         7
123456789012345678901234567890123456789012345678901234567890123456789012
|<-- aim for here (50) ------------>|<-- hard max (72) ------------>|
```

### 3. Capitalize the Subject Line

```
Add user authentication          ✓
add user authentication          ✗
```

Consistent capitalization improves readability in logs and makes subjects look like proper sentences.

### 4. Do Not End Subject with Period

```
Add user authentication          ✓
Add user authentication.         ✗
```

Space is precious in 50 characters. The period adds nothing.

### 5. Use Imperative Mood in Subject

Write as if giving a command:

| Imperative (Correct) | Indicative (Wrong) |
|---------------------|-------------------|
| Add feature | Added feature |
| Fix bug | Fixes bug |
| Update dependency | Updated dependency |
| Remove deprecated code | Removing deprecated code |

**The completion test:**

A properly formed subject should complete this sentence:

> "If applied, this commit will **[your subject line]**"

Examples:
- "If applied, this commit will **Add user authentication**" ✓
- "If applied, this commit will **Added user authentication**" ✗
- "If applied, this commit will **Fixes the login bug**" ✗
- "If applied, this commit will **Fix the login bug**" ✓

**Why imperative?**
- Git itself uses imperative ("Merge branch", "Revert commit")
- Matches the action the commit performs
- Shorter than past tense in most cases
- Consistent with generated messages (merge, revert, cherry-pick)

### 6. Wrap Body at 72 Characters

**Why 72?**
- Git doesn't auto-wrap
- `git log` doesn't wrap, assumes 80-char terminal
- 72 leaves room for 4-space indent in nested quotes
- Email clients wrap at 72 by convention

**Hard wrap, not soft wrap:**
```
This is a properly wrapped paragraph in a commit message body.
Each line is hard-wrapped at 72 characters so that it displays
correctly in all terminals and Git tools without relying on the
viewer to wrap text.
```

### 7. Use Body to Explain What and Why, Not How

The diff shows **how** - the code change is right there.

The body should explain:
- **What** changed at a conceptual level
- **Why** the change was necessary
- **What** alternatives were considered
- **What** consequences or side effects exist

**Bad (explains how):**
```
Change user validation

Added an if statement to check if email is null before
calling the validation function. Also added a try-catch
block around the database query.
```

**Good (explains what/why):**
```
Add null check in user validation

Email addresses from the legacy import can be null, which
crashed the validation step. Gracefully handle missing
emails by skipping validation for those records.

The legacy data will be cleaned up in a future migration.
```

## Body Best Practices

### Use Bullet Points for Multiple Items

```
Improve error handling in payment flow

- Add retry logic for transient gateway failures
- Log detailed error context for debugging
- Return user-friendly messages to clients
```

### Reference Issues at the End

```
Fix memory leak in image processing

The resize operation wasn't releasing buffers after completion.

Fixes #456
Refs #400
```

Common keywords:
- `Fixes #123` - Closes the issue
- `Closes #123` - Same as Fixes
- `Refs #123` - References without closing
- `See #123` - Informal reference

### Call Out Breaking Changes

```
Remove deprecated API endpoints

BREAKING CHANGE: The /api/v1/* endpoints are removed.
Clients must migrate to /api/v2/*.

Migration guide: docs/migration.md
```

### Explain Non-Obvious Decisions

```
Use polling instead of WebSockets for status updates

WebSockets require sticky sessions which complicate our
load balancer configuration. Polling every 5 seconds is
acceptable for status updates and allows stateless scaling.

We may revisit this when we move to a WebSocket-aware proxy.
```

## Edge Cases

### Trivial Changes

For genuinely trivial changes, subject-only is fine:

```
Fix typo in README
```

```
Update copyright year
```

### Revert Commits

Follow Git's default format:

```
Revert "Add experimental caching"

This reverts commit abc1234.

The caching caused data inconsistency in multi-node deployments.
Need to redesign with distributed cache invalidation.
```

### Merge Commits

For non-fast-forward merges:

```
Merge branch 'feature/authentication' into main

Adds JWT-based authentication system including:
- Token generation and validation
- Refresh token rotation
- Password reset flow
```

### Work in Progress

Avoid WIP commits in shared history. If you must:

```
WIP: Add user authentication (do not merge)

Checkpoint before vacation. Missing:
- Password reset flow
- Email verification
- Tests
```

Better: Use `git commit --fixup` and squash before pushing.

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| `fixed bug` | Not capitalized, vague | `Fix null pointer in user lookup` |
| `Adds feature.` | Not imperative, has period | `Add feature` |
| `Updated stuff` | Past tense, vague | `Update payment validation rules` |
| `WIP` | Not descriptive | `Add cart total calculation (incomplete)` |
| `misc changes` | Too vague | Split into focused commits |
| `Fix #123` | No description | `Fix login timeout (#123)` |
| 80+ char subject | Too long | Shorten or move detail to body |

## Git Configuration Tips

### Set Default Editor
```bash
git config --global core.editor "vim"
```

### Create Commit Template
```bash
git config --global commit.template ~/.gitmessage
```

Example `~/.gitmessage`:
```


# Subject: 50 chars --|
# Body: 72 chars -------------------------------------|
#
# What: Describe the change
# Why: Explain the reasoning
#
# Refs: #issue-number
```

### Enable Verbose Commits
```bash
git config --global commit.verbose true
```

Shows diff in editor while writing message.

### Set Up Commit Signing (Optional)
```bash
git config --global commit.gpgsign true
```

## Tools That Parse Commit Messages

These tools rely on well-formatted messages:

- **GitHub/GitLab** - Uses subject for merge commit titles, parses issue refs
- **Semantic Release** - Generates changelogs from commit subjects
- **git log --oneline** - Shows only subjects
- **git shortlog** - Groups commits by author
- **git rebase -i** - Uses subjects in pick list
- **Conventional Changelog** - Generates release notes
- **GitHub Release Notes** - Auto-generates from commits

## Further Reading

- [Tim Pope's Original Post](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
- [Pro Git Book - Commit Guidelines](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project#_commit_guidelines)
- [How to Write a Git Commit Message](https://cbea.ms/git-commit/) by Chris Beams
