# Non-Spec Frontmatter and Cross-Client Support

**Portability is per-field, not per-client.** The six spec fields work everywhere.
Everything else varies: some non-spec fields are supported by several clients, some
have an equivalent expressed in a sidecar file, and some exist only in Claude Code.
Check the field, not the vendor.

Claude Code runtime behaviour — substitutions, shell injection, compaction, command
overlap — moved to [claude-code-runtime.md](claude-code-runtime.md). It applies no
matter which fields you use.

Sources, all verified 2026-08-07:

- Claude Code — [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills)
- Pi — `docs/skills.md` shipped in `@earendil-works/pi-coding-agent`
- Codex — [learn.chatgpt.com/docs/build-skills](https://learn.chatgpt.com/docs/build-skills)
- Spec — [agentskills.io/specification](https://agentskills.io/specification)

<!-- If today is more than ~60 days past 2026-08-07, re-fetch all four and diff.
     Pi's copy ships with the package: read it from node_modules, not the web. -->

## Contents

- [Support matrix](#support-matrix) — which field works in which client
- [`disable-model-invocation` is the portable one](#disable-model-invocation-is-the-portable-one)
- [Sidecar files: `agents/openai.yaml`](#sidecar-files-agentsopenaiyaml)
- [Where clients disagree about the spec](#where-clients-disagree-about-the-spec)
- [Discovery locations](#discovery-locations)
- [Choosing](#choosing) — the decision table

## Support matrix

Verified for the three clients in use here. "ignored" means the client parses the
skill and silently drops the field — no error, no behaviour.

| Field | Claude Code | Pi | Codex |
|---|---|---|---|
| `disable-model-invocation` | native | **native** | sidecar (see below) |
| `argument-hint` | native | ignored | no equivalent documented |
| `user-invocable` | native | ignored | no equivalent documented |
| `model` | native | ignored | no equivalent documented |
| `effort` | native | ignored | no equivalent documented |
| `context: fork` + `agent` | native | ignored | no equivalent documented |
| `hooks` | native | ignored | no equivalent documented |
| `paths` | native | ignored | no equivalent documented |
| `shell` | native | ignored | no equivalent documented |
| `when_to_use` | native (appended to `description`) | ignored | ignored |

Pi has session-level equivalents for two of these — `--model` and `--thinking` — but
they are not settable per skill. A skill that needs a specific model to behave
correctly cannot express that in Pi.

`when_to_use` is not a spec field in any client. Elsewhere it is dead metadata: the
trigger text you put there never reaches the model. Fold it into `description`.

## `disable-model-invocation` is the portable one

It is supported natively by both Claude Code and Pi, and Codex expresses the same
intent through a sidecar. If a skill must be user-initiated — anything with side
effects whose timing you control — this is the field to reach for, and it is not a
portability compromise.

````markdown
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
allowed-tools: Bash(kubectl *) Bash(helm *)
---
````

You don't want an agent deciding to deploy because the code "looks ready."

Note that `user-invocable: false` — the inverse, hiding a skill from the user menu —
has **no** support outside Claude Code. The two fields look symmetric and are not.

## Sidecar files: `agents/openai.yaml`

Codex reads a per-client sidecar next to `SKILL.md`. It carries UI metadata and
invocation policy that the spec has no field for. The sidecar is invisible to clients
that don't look for it, so it costs nothing to include.

```
my-skill/
├── SKILL.md
└── agents/
    └── openai.yaml
```

Schema:

```yaml
interface:
  display_name: string          # user-facing name
  short_description: string     # user-facing description
  icon_small: string            # path to small logo
  icon_large: string            # path to large logo
  brand_color: string           # hex colour
  default_prompt: string        # surrounding prompt template
policy:
  allow_implicit_invocation: boolean   # default: true
dependencies:
  tools:
    - type: string              # e.g. "mcp"
      value: string
      description: string
      transport: string         # e.g. "streamable_http"
      url: string
```

For a user-invoked skill, the pairing is:

```yaml
# agents/openai.yaml
policy:
  allow_implicit_invocation: false
```

alongside `disable-model-invocation: true` in the frontmatter.

**Keep the two in sync — a skill is user-invoked in both harnesses or neither.** They
are independent switches, so drift is silent: the skill stays out of the model's hands
in one client and not the other.

`interface.display_name` and `short_description` are user-facing; unlike `description`
they carry no triggering burden, so drop the "Use when…" phrasing there.

A working example is on disk at `~/.agents/skills/plannotator-annotate/`.

## Where clients disagree about the spec

These are not extensions — they are the same rule read differently. Each one can
produce a skill that works in one client and fails in another.

| Point | Spec | Claude Code | Pi | Codex |
|---|---|---|---|---|
| `name` matches parent directory | required | enforced | **not required, deliberately** | not required |
| `allowed-tools` form | space-separated string | string or YAML list | string | undocumented |
| `description` length | 1024 hard limit | truncates `description` + `when_to_use` display at 1,536 | warns over 1024, still loads | undocumented |
| Missing `description` | invalid | invalid | **skill not loaded at all** | invalid |
| Name collision | undefined | priority order wins | warns, first found wins | undefined |

Two of these deserve attention when authoring:

**The 1,536-character listing cap is not the description limit.** Claude Code
truncates the combined `description` + `when_to_use` at 1,536 characters in its skill
listing. That is a *display* behaviour of one client. Write to 1024. A description
between 1,025 and 1,536 characters renders fine in Claude Code and is invalid
everywhere else.

**Pi relaxes the name/directory rule on purpose**, calling the requirement
"suboptimal for shared skill directories used across multiple agent harnesses." This
skill's validator enforces the spec and errors on a mismatch. That is a deliberate
choice to stay spec-strict — the cost is that a directory Pi accepts may fail
validation here.

## Discovery locations

Where each client looks. The skill directory format is portable; the search path is
not.

| Client | Locations |
|---|---|
| Claude Code | enterprise settings; `~/.claude/skills/`; `.claude/skills/` (and parent dirs); plugins |
| Pi | `~/.pi/agent/skills/`; `~/.agents/skills/`; `.pi/skills/`; `.agents/skills/` (cwd to repo root); package `skills/` dirs; `skills` array in settings; `--skill <path>` |
| Codex | `.agents/skills/` (cwd to repo root); `$HOME/.agents/skills/`; `/etc/codex/skills`; bundled |

Claude Code's priority ordering is in
[claude-code-runtime.md](claude-code-runtime.md#skill-locations-and-priority).

**One skills directory, several clients.** Pi reads other harnesses' directories
directly rather than requiring a copy:

```json
// ~/.pi/agent/settings.json
{ "skills": ["~/.claude/skills"] }
```

Prefer this to duplicating or symlinking trees. Duplicated skills drift; Pi also warns
on name collisions and keeps whichever it found first, which is not necessarily the
one you edited.

## Choosing

Work down this list. Stop at the first row that matches.

| Situation | Do this |
|---|---|
| A spec field expresses it | Use the spec field. No decision needed. |
| Must be user-initiated | `disable-model-invocation: true` + `agents/openai.yaml` policy. Portable across all three. |
| Codex UI metadata | `agents/openai.yaml` under `interface`. Invisible elsewhere. |
| Claude Code-only field, skill runs only there | Use it, and add `compatibility: Designed for Claude Code` so the constraint is declared rather than assumed. |
| Claude Code-only field, skill must run elsewhere | The behaviour will be absent, not degraded gracefully. Either restructure so the body carries the intent, or accept it and say so in `compatibility`. |

The trap is the last row. A skill using `context: fork` runs in an isolated subagent in
Claude Code and **inline on the main context** in Pi — not a cosmetic difference but a
different execution model, arrived at silently.

`compatibility` is the spec's own mechanism for declaring an environment requirement
(max 500 characters). Using it makes non-portability greppable instead of something
recorded in a chat that has since been compacted away.

**Validator note**: `validate_skill.py` splits the two cases. **W041** means "not a spec
field; support varies by client and may be absent entirely" — check the matrix above
before assuming it carries. **W042** is reserved for non-spec fields this file
establishes as broadly supported, currently `disable-model-invocation`; it flags the
field for review rather than reporting a portability problem. Neither code is an error,
and neither is a verdict.
