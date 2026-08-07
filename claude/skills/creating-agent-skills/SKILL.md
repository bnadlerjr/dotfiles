---
name: creating-agent-skills
description: Authors, audits, and refines Agent Skills — SKILL.md files, frontmatter, progressive disclosure, and bundled scripts, references, and assets. Use when creating a new skill, improving or auditing an existing one, fixing skill frontmatter, deciding how to structure a skill's files, or checking a skill against the Agent Skills specification. Applies even when the user says only "make a skill", "write a SKILL.md", or names a skills directory without mentioning the spec.
metadata:
  version: "2.0"
  standard: "agent-skills"
---

# Creating Agent Skills

Agent Skills is an **open, vendor-neutral format** — a folder with a `SKILL.md` that
teaches an agent a capability. Claude Code, Cursor, Copilot, VS Code, Codex, Gemini
CLI, OpenCode, Goose and others all load the same folder.

## How this skill works

These four principles apply to every workflow below. They are inline because they
must not be skipped.

### 1. The spec is the floor

`name` and `description` are **required**. `description` is capped at **1024
characters** — a hard validity limit, not a display truncation. `name` must be
lowercase alphanumeric with single hyphens, and **must match its parent directory**.

Everything else — `license`, `compatibility`, `metadata`, `allowed-tools` — is
optional. Full rules: [references/agent-skills-spec.md](references/agent-skills-spec.md).

### 2. Portable by default

Any frontmatter field outside those six is non-spec, and support for it is **per
field, not per client**. Some are widely supported, some have an equivalent in a
per-client sidecar file, and some exist in one client only — where the behaviour
silently disappears rather than degrading. Check the field before assuming either way.

The matrix, the sidecar pattern, and where clients disagree about the spec itself:
[references/claude-code-extensions.md](references/claude-code-extensions.md).

### 3. Progressive disclosure is the point

Three stages load on demand: `name` + `description` (~100 tokens, always);
the `SKILL.md` body (**under 500 lines and 5,000 tokens**, on activation);
bundled files (only when needed).

Tell the agent *when* to load each file. "Read `references/api-errors.md` if the API
returns a non-200" beats "see references/ for details."

### 4. Add what the agent lacks

The context window is shared. Only include what the agent would get wrong without it.
Skills grounded in real expertise — actual conventions, real failure modes, corrections
you had to make — beat skills generated from general knowledge. That is the single
biggest quality lever: [references/authoring-guidance.md](references/authoring-guidance.md).

## What would you like to do?

Ask the user:

```
What would you like to do?
1. Create a new skill
2. Audit an existing skill against the spec and best practices
3. Verify an existing skill's content is still accurate
4. Add a component (reference, script, template, or workflow)
5. Restructure a skill that outgrew a single file
6. Understand skill design
```

**Wait for the response before proceeding.**

### Routing

| Answer | Workflow |
|---|---|
| 1, "create", "new skill", "build a skill" | [workflows/create-new-skill.md](workflows/create-new-skill.md) — or [workflows/create-domain-expertise-skill.md](workflows/create-domain-expertise-skill.md) when the skill is mostly domain knowledge rather than procedure |
| 2, "audit", "review", "check", "conformance" | [workflows/audit-skill.md](workflows/audit-skill.md) |
| 3, "verify", "still accurate", "stale", "out of date" | [workflows/verify-skill.md](workflows/verify-skill.md) |
| 4, "add reference" | [workflows/add-reference.md](workflows/add-reference.md) |
| 4, "add script" | [workflows/add-script.md](workflows/add-script.md) |
| 4, "add template" | [workflows/add-template.md](workflows/add-template.md) |
| 4, "add workflow" | [workflows/add-workflow.md](workflows/add-workflow.md) |
| 5, "restructure", "split", "too big", "router" | [workflows/upgrade-to-router.md](workflows/upgrade-to-router.md) |
| 6, "guidance", "explain", "how should I" | [workflows/get-guidance.md](workflows/get-guidance.md) |
| anything else | Clarify, then route |

**After reading the workflow, follow it exactly.**

### Non-interactive callers

If the request already contains the requirements — a caller supplied scope, structure,
and intent up front, or you are running as a subagent — then **skip the intake
question, choose the workflow yourself from the table above, and do not use
AskUserQuestion.** Answer the workflow's questions from the context you were given and
proceed to writing files. Workflow filenames in the table are stable; callers may name
them directly.

## Naming

Use **gerund form** (verb + -ing): `processing-pdfs`, `analyzing-spreadsheets`,
`reviewing-code`. Noun phrases (`pdf-processing`) are acceptable.

Avoid vague (`helper`, `utils`, `tools`), generic (`documents`, `data`), and reserved
(`anthropic-*`, `claude-*`) names.

## Validate before finishing

Every workflow ends here. This is not optional — it is how "done" is defined:

```bash
uv run scripts/validate_skill.py path/to/skill
```

Exit 0 means no errors. It checks every mechanical spec rule, plus broken links,
reference chains too deep to reach reliably, and files nothing references.

## Reference index

Load these on demand — the workflows say which ones they need.

| Reference | Read it when |
|---|---|
| [agent-skills-spec.md](references/agent-skills-spec.md) | Any question about frontmatter, limits, or directory layout |
| [claude-code-extensions.md](references/claude-code-extensions.md) | Considering a non-spec field, or the skill must run in more than one client |
| [claude-code-runtime.md](references/claude-code-runtime.md) | How Claude Code executes a skill: compaction, substitutions, shell injection, command overlap |
| [authoring-guidance.md](references/authoring-guidance.md) | Deciding what goes in and how prescriptive to be |
| [instruction-patterns.md](references/instruction-patterns.md) | Structuring the body: gotchas, templates, checklists, validation loops |
| [skill-structure.md](references/skill-structure.md) | Choosing between a single file and a router |
| [evaluating-skills.md](references/evaluating-skills.md) | The skill doesn't trigger, or its output is inconsistent |
| [using-scripts.md](references/using-scripts.md) | Bundling executable code |
| [api-security.md](references/api-security.md) | The skill touches an external API or handles credentials |

Skills are prompts packaged for discovery. For foundational prompt engineering, see the
`writing-prompts` skill if it is installed alongside this one.

## Success criteria

A finished skill:

- Passes `scripts/validate_skill.py` with zero errors
- Has `name` matching its directory and a `description` stating what it does **and**
  when to use it, in under 1024 characters
- Keeps `SKILL.md` under 500 lines and 5,000 tokens
- Uses non-standard fields only deliberately, with the trade-off recorded
- Has every bundled file reachable, and says when to load each one
- Has been run against a real task, not a hypothetical one
