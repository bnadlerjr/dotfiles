# Invocation Control

By default both you and Claude can invoke any skill. Four frontmatter fields let you restrict *who* invokes, *where* the skill runs, and *when* it auto-activates.

## `disable-model-invocation`

Only users can invoke; Claude cannot auto-load. Use for side-effectful actions whose timing you want to control.

```yaml
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
allowed-tools: Bash(kubectl *) Bash(helm *)
---

Deploy $ARGUMENTS to production:
1. Run the test suite
2. Build and push the image
3. Roll out the deployment
4. Verify health checks
```

You don't want Claude deciding to deploy because the code "looks ready."

## `user-invocable: false`

Only Claude can invoke; hidden from the `/` menu. Use for background knowledge that isn't actionable as a command.

```yaml
---
name: legacy-auth-context
description: Explains how the pre-2024 auth middleware works. Use when touching files under src/auth/legacy/.
user-invocable: false
---

The legacy middleware stores session tokens in...
```

Claude loads this when relevant but users can't run `/legacy-auth-context`.

## Invocation Matrix

| Frontmatter | You invoke | Claude invokes | Context behavior |
|-------------|------------|----------------|------------------|
| (default) | yes | yes | Description always in context; body loads when invoked |
| `disable-model-invocation: true` | yes | no | Description not in context; body loads on user invoke |
| `user-invocable: false` | no | yes | Description always in context; body loads when invoked |

Note: `user-invocable` only controls menu visibility, not Skill-tool access. Use `disable-model-invocation` to block programmatic invocation entirely.

## `paths` — Path-Scoped Activation

Limit when Claude auto-loads a skill based on files being worked on:

```yaml
---
name: graphql-conventions
description: GraphQL schema design patterns for this codebase
paths:
  - "**/*.graphql"
  - "src/resolvers/**"
---
```

With `paths` set, Claude only auto-loads the skill when the active files match. Users invoking with `/graphql-conventions` bypass the path filter. Uses the same format as [path-specific memory rules](https://code.claude.com/docs/en/memory#path-specific-rules).

## `context: fork` — Subagent Execution

Run the skill in an isolated subagent context. The skill content becomes the prompt. The subagent does **not** inherit your conversation history.

```yaml
---
name: deep-research
description: Research a topic thoroughly in an isolated context
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:
1. Find relevant files with Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```

- `context: fork` → new isolated context
- `agent: Explore` (or `Plan`, `general-purpose`, or any custom agent from `.claude/agents/`) → determines model, tools, permissions
- Results summarized back to the main conversation

**Warning**: `context: fork` only makes sense for task content with explicit instructions. Reference/guideline skills forked without a task return nothing useful.

## `argument-hint`

Display a hint during `/` autocomplete:

```yaml
---
name: fix-issue
description: Fix a GitHub issue by number
argument-hint: "[issue-number]"
disable-model-invocation: true
---

Fix issue $1 following our coding standards.
```

## Restricting Skill Access Globally

Via `/permissions`:

```
Skill                    # deny all skills
Skill(commit)            # allow exact match
Skill(review-pr *)       # allow with prefix match on args
Skill(deploy *)          # deny with prefix match
```

Use deny rules in permissions to block skills from using specific tools — `allowed-tools` only *grants*, it cannot restrict.

## Choosing the Right Control

| Goal | Use |
|------|-----|
| Action with side effects; user must initiate | `disable-model-invocation: true` |
| Background knowledge; not a user-facing command | `user-invocable: false` |
| Auto-load only when editing certain files | `paths: [...]` |
| Run in isolation with a fresh context | `context: fork` + `agent` |
| Warn users about expected arguments | `argument-hint` |
