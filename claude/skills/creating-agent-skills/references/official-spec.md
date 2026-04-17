# Anthropic Official Skill Specification

Source of truth: [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)

Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard, which works across multiple AI tools. Claude Code extends the standard with invocation control, subagent execution, and dynamic context injection.

<!-- Verified against spec: 2026-04-17. If today is more than ~60 days past this date, re-fetch the source URL and diff before trusting this file. -->

## SKILL.md File Structure

Every Skill is a directory containing a `SKILL.md` file with YAML frontmatter followed by Markdown instructions.

### Basic Format

```markdown
---
name: your-skill-name
description: What this Skill does and when to use it
---

# Your Skill Name

Provide clear, step-by-step guidance for Claude.
```

## Frontmatter Reference

All fields are optional. Only `description` is recommended so Claude knows when to use the skill.

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Display name. If omitted, uses the directory name. Lowercase letters, numbers, and hyphens only (max 64 characters). |
| `description` | Recommended | What the skill does and when to use it. If omitted, uses the first paragraph of markdown content. Combined `description` + `when_to_use` is truncated at **1,536 characters** in the skill listing. |
| `when_to_use` | No | Additional trigger phrases or example requests. Appended to `description` and counts toward the 1,536-char cap. |
| `argument-hint` | No | Autocomplete hint indicating expected arguments, e.g. `[issue-number]` or `[filename] [format]`. |
| `disable-model-invocation` | No | `true` prevents Claude from auto-loading; only users can invoke with `/name`. Use for side-effectful actions (`/deploy`, `/commit`). Default: `false`. |
| `user-invocable` | No | `false` hides from the `/` menu — only Claude can invoke. Use for background knowledge. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without per-use approval while this skill is active. Space-separated string **or** YAML list. |
| `model` | No | Specific model to use when this skill is active. Defaults to the conversation's model. |
| `effort` | No | Effort level overrides the session level. Options: `low`, `medium`, `high`, `xhigh`, `max` (available levels depend on model). |
| `context` | No | Set to `fork` to run the skill in a forked subagent context. |
| `agent` | No | Subagent type when `context: fork` is set (e.g. `Explore`, `Plan`, `general-purpose`, or a custom agent). |
| `hooks` | No | Hooks scoped to this skill's lifecycle. See [Hooks in skills and agents](https://code.claude.com/docs/en/hooks#hooks-in-skills-and-agents). |
| `paths` | No | Glob patterns that limit auto-activation. Comma-separated string or YAML list. Uses the same format as path-specific memory rules. |
| `shell` | No | `bash` (default) or `powershell`. The latter requires `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. |

## String Substitutions

Skills support substitution for dynamic values in the skill content (rendered before Claude sees the prompt):

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking the skill. If not present in the body, arguments are appended as `ARGUMENTS: <value>`. |
| `$ARGUMENTS[N]` | Specific argument by 0-based index. |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g. `$0`, `$1`). |
| `${CLAUDE_SESSION_ID}` | Current session ID — useful for logging or session-scoped files. |
| `${CLAUDE_SKILL_DIR}` | Directory containing this `SKILL.md`. Use in bash commands to reference bundled scripts regardless of CWD. |

Indexed arguments use shell-style quoting — wrap multi-word values in quotes to pass as a single argument.

## Dynamic Context Injection

See [dynamic-context.md](dynamic-context.md). Skills can run shell commands *before* content is sent to Claude using `` !`command` `` (inline) and ```` ```! ```` (fenced block). Output replaces the placeholder.

## Invocation Control

See [invocation-control.md](invocation-control.md). `disable-model-invocation`, `user-invocable`, `context: fork`, and `paths` control who can invoke a skill and where it runs.

## Skill Locations & Priority

```
Enterprise (highest) → Personal → Project → Plugin (lowest)
```

| Type | Path | Applies to |
|------|------|-----------|
| Enterprise | See managed settings | All users in organization |
| Personal | `~/.claude/skills/` | You, across all projects |
| Project | `.claude/skills/` | Anyone working in repository |
| Plugin | Bundled with plugins | Anyone with plugin installed. Namespaced as `plugin-name:skill-name`. |

Higher-priority locations override when names collide. Plugin skills cannot collide because of the namespace.

**Nested discovery**: Claude Code also discovers `.claude/skills/` in parent subdirectories of your current file, supporting monorepos.

**Live change detection**: Adding, editing, or removing a skill takes effect within the current session. Creating a brand-new top-level skills directory requires restarting.

## How Skills Work

1. **Discovery**: Claude Code loads names and descriptions at startup.
2. **Activation**: When your request matches a description, Claude loads the full skill content (or asks if `disable-model-invocation` is set).
3. **Execution**: Claude follows the instructions and loads referenced files on demand.

Skills are **model-invoked** unless `disable-model-invocation: true`.

## Skill Content Lifecycle

When a skill is invoked, the rendered `SKILL.md` enters the conversation as a single message and stays for the session. Claude Code does not re-read the file on later turns. Write guidance as **standing instructions**, not one-time steps.

**Auto-compaction**: The most recent invocation of each skill is re-attached after summarization, keeping the first 5,000 tokens per skill, with a 25,000-token combined budget. Oldest invocations get dropped first. Re-invoke a skill after compaction to restore full content.

## Progressive Disclosure Pattern

Keep `SKILL.md` under 500 lines. Link to supporting files:

```
my-skill/
├── SKILL.md              # required — overview + navigation
├── reference.md          # detailed docs, loaded when needed
├── examples.md           # usage examples, loaded when needed
└── scripts/
    └── helper.py         # executed, not loaded into context
```

Reference supporting files from `SKILL.md` so Claude knows what each contains.

## Writing Effective Descriptions

- **Third person.** The description is injected into the system prompt.
- **Include trigger keywords** users would naturally say.
- **Front-load the key use case** — text is truncated at 1,536 chars.

Good: `Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.`

Bad: `Helps with documents`

## Commands Merged Into Skills

Custom commands at `.claude/commands/` and skills at `.claude/skills/<name>/SKILL.md` now share the same runtime. A command file and a skill of the same name both create `/name`. If both exist, the skill wins. Existing command files keep working; skills add supporting-file directories and auto-invocation.

## Distribution

- **Project Skills**: Commit `.claude/skills/` to version control
- **Plugins**: Add `skills/` directory to plugin with skill folders
- **Enterprise**: Deploy organization-wide through managed settings

## Related Skill Tool Permissions

Control which skills Claude can invoke via `/permissions`:

```
Skill                    # deny all
Skill(commit)            # allow specific skill
Skill(review-pr *)       # prefix match with any args
Skill(deploy *)          # deny specific skill
```
