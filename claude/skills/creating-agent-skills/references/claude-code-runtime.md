# Claude Code Runtime

How Claude Code executes a skill once it loads. **None of this is portability
guidance** — these are facts about the runtime, true regardless of which frontmatter
fields a skill uses. For what other clients support, see
[claude-code-extensions.md](claude-code-extensions.md).

Source: [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)

<!-- Verified against docs: 2026-08-06. If today is more than ~60 days past this
     date, re-fetch the source URL and diff before trusting this file. -->

## Contents

- [Content lifecycle](#content-lifecycle) — compaction, and why the token budget bites twice
- [String substitutions](#string-substitutions)
- [Dynamic context injection](#dynamic-context-injection) — shell output rendered before load
- [Skill locations and priority](#skill-locations-and-priority)
- [Commands and skills share a runtime](#commands-and-skills-share-a-runtime)
- [Restricting skill access](#restricting-skill-access)

## Content lifecycle

When a skill is invoked, the rendered `SKILL.md` enters the conversation as a single
message and stays for the session. Claude Code does **not** re-read the file on later
turns. Write guidance as **standing instructions**, not one-time steps.

**Auto-compaction**: the most recent invocation of each skill is re-attached after
summarization, keeping the first 5,000 tokens per skill within a 25,000-token combined
budget. Oldest invocations drop first. Re-invoke a skill after compaction to restore
full content.

This is a second, independent reason to respect the spec's 5,000-token body budget:
past it, content is silently dropped on compaction.

## String substitutions

Rendered before Claude sees the prompt.

| Variable | Expands to |
|---|---|
| `$ARGUMENTS` | Full argument string as typed |
| `$ARGUMENTS[N]` / `$N` | Nth argument (0-based), shell-quoted |
| `${CLAUDE_SESSION_ID}` | Current session ID |
| `${CLAUDE_SKILL_DIR}` | Directory containing this `SKILL.md` |

Wrap multi-word arguments in quotes at the call site: `/my-skill "hello world" second`
sets `$0` to `hello world` and `$1` to `second`. If `$ARGUMENTS` is not referenced in
the body, arguments are appended as `ARGUMENTS: <value>`.

`${CLAUDE_SKILL_DIR}` is the reliable way to reach a bundled script regardless of
working directory. The portable alternative is a relative path from the skill root,
which works because agents run commands from there. **Prefer the relative path** —
`${CLAUDE_SKILL_DIR}` expands to nothing in other clients, silently producing a broken
path rather than an error.

## Dynamic context injection

Skills can run shell commands *before* content is sent to Claude. Output replaces the
placeholder, so Claude receives data, not the command. This is preprocessing — Claude
does not execute it.

Inline form, `` !`command` ``:

````markdown
---
name: pr-summary
description: Summarize changes in a pull request
allowed-tools: Bash(gh *)
---

## Pull request context
- Diff: !`gh pr diff`
- Files changed: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
````

Fenced form, ```` ```! ````:

`````markdown
## Environment
```!
node --version
git status --short
```
`````

To disable shell execution for user, project, plugin, and added-directory skills, set
`"disableSkillShellExecution": true` in settings. Each command is then replaced with
`[shell command execution disabled by policy]`. Bundled and managed skills are
unaffected.

Including the word `ultrathink` anywhere in the content enables extended thinking.

**Portability**: no other client executes this syntax. Elsewhere the backtick command
is delivered to the model as literal text, so a skill relying on injected data instead
gets a shell command it may decide to run itself — or may not. Treat dynamic injection
as Claude Code-only.

## Skill locations and priority

```
Enterprise (highest) → Personal → Project → Plugin (lowest)
```

| Type | Path | Applies to |
|---|---|---|
| Enterprise | managed settings | All users in the organization |
| Personal | `~/.claude/skills/` | You, across all projects |
| Project | `.claude/skills/` | Anyone working in the repository |
| Plugin | bundled with plugins | Anyone with the plugin installed; namespaced `plugin-name:skill-name` |

Higher-priority locations win on name collision. Plugin skills cannot collide because
of the namespace. Claude Code also discovers `.claude/skills/` in parent
subdirectories, supporting monorepos.

Where other clients look is in
[claude-code-extensions.md](claude-code-extensions.md#discovery-locations).

**Live change detection**: adding, editing, or removing a skill takes effect within
the current session. Creating a brand-new top-level skills directory requires a
restart.

## Commands and skills share a runtime

Custom commands at `.claude/commands/` and skills at `.claude/skills/<name>/SKILL.md`
share the same runtime. A command file and a skill of the same name both create
`/name`; if both exist, the skill wins.

Do not write a `/<skill-name>` command that only forwards to one skill — skills are
already discoverable through their `description`, and the wrapper is duplicate surface
to keep in sync. A command earns its place only when it composes multiple skills or
adds orchestration the skill cannot carry itself.

## Restricting skill access

Via `/permissions`:

```
Skill                    # deny all skills
Skill(commit)            # allow exact match
Skill(review-pr *)       # allow with prefix match on args
Skill(deploy *)          # deny with prefix match
```

`allowed-tools` only *grants* permissions; it cannot restrict. Use deny rules in
permissions to block a skill from specific tools.
