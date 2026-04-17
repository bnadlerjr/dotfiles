# Dynamic Context Injection

Skills can run shell commands *before* the content is sent to Claude. Output replaces the placeholder, so Claude receives the actual data, not the command. This is preprocessing — Claude does not execute it.

## Inline Form

Use `` !`command` `` for single-line commands:

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
allowed-tools: Bash(gh *)
---

## Pull request context
- Diff: !`gh pr diff`
- Comments: !`gh pr view --comments`
- Files changed: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```

When invoked, each `` !`...` `` runs, its stdout replaces the placeholder, and Claude sees the fully-rendered prompt with live data.

## Fenced Block Form

Use ```` ```! ```` for multi-line commands:

````markdown
## Environment
```!
node --version
npm --version
git status --short
```
````

## Arguments in Shell Commands

Combine with string substitutions to parametrize:

```yaml
---
name: issue-context
description: Pull context for a GitHub issue
---

Issue: !`gh issue view $1 --json title,body,labels`
Recent commits touching this area: !`git log --oneline -n 20 -- $2`
```

Invoking `/issue-context 42 src/auth/` runs both commands with those values substituted.

## Security Setting

To disable shell execution for user/project/plugin/added-directory skills, set in [settings](https://code.claude.com/docs/en/settings):

```json
{
  "disableSkillShellExecution": true
}
```

Each command is replaced with `[shell command execution disabled by policy]`. Bundled and managed skills are not affected. Most useful in managed settings where users cannot override.

## String Substitutions Reference

| Variable | Expands to |
|----------|-----------|
| `$ARGUMENTS` | Full argument string as typed |
| `$ARGUMENTS[N]` / `$N` | Nth argument (0-based), shell-quoted |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing this `SKILL.md` |

Wrap multi-word arguments in quotes at the call site: `/my-skill "hello world" second` sets `$0` to `hello world` and `$1` to `second`.

If `$ARGUMENTS` is not referenced in the body, arguments are appended as `ARGUMENTS: <value>` so Claude still sees them.

## Common Patterns

**Absolute path to bundled script:**
```yaml
---
name: codebase-visualizer
allowed-tools: Bash(python *)
---

Run: !`python ${CLAUDE_SKILL_DIR}/scripts/visualize.py .`
```

Using `${CLAUDE_SKILL_DIR}` means the script works regardless of CWD.

**Session-scoped logs:**
```yaml
---
name: session-logger
description: Log activity for this session
---

Log to: logs/${CLAUDE_SESSION_ID}.log

$ARGUMENTS
```

## Extended Thinking

To enable extended thinking in a skill, include the word `ultrathink` anywhere in the content.
