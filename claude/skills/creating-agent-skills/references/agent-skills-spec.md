# Agent Skills Specification

The normative standard. This file is the single source of truth for what makes a
skill valid. Everything else in this skill is convention or guidance layered on top.

Source: [agentskills.io/specification](https://agentskills.io/specification)

<!-- Verified against spec: 2026-08-06. If today is more than ~60 days past this
     date, re-fetch the source URL and diff before trusting this file. -->

Agent Skills is an **open, vendor-neutral standard**. It was developed by Anthropic,
released as an open standard, and is now implemented by many agent products —
Claude Code, Cursor, GitHub Copilot / VS Code, OpenAI Codex, Gemini CLI, OpenCode,
Goose, Amp, Kiro, Letta, and others.

A skill written to this spec runs anywhere. Anything **outside** this spec is
non-spec, and support varies by field: a few are honoured by several clients, some
have a per-client sidecar equivalent, and the rest work in one client only. Check the
matrix in [claude-code-extensions.md](claude-code-extensions.md) before assuming a
field is either safe or dead.

Clients also disagree about parts of this spec — Pi does not enforce the
name/directory rule, and description limits are read differently. Those differences
are catalogued there too.

## Contents

- [Directory structure](#directory-structure)
- [Frontmatter](#frontmatter) — the six fields, with per-field rules
- [Body content](#body-content)
- [Optional directories](#optional-directories)
- [Progressive disclosure](#progressive-disclosure)
- [File references](#file-references)
- [Validation](#validation)

## Directory structure

A skill is a directory containing, at minimum, a `SKILL.md` file:

```
skill-name/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...               # Any additional files or directories
```

Only `SKILL.md` is required. The three subdirectory names are **conventions**, not
requirements — a skill may contain any files and directories. Use the conventional
names anyway; they are what other authors and tools expect.

## Frontmatter

`SKILL.md` must contain YAML frontmatter followed by Markdown content.

| Field | Required | Constraints |
|---|---|---|
| `name` | **Yes** | Max 64 characters. Lowercase letters, numbers, and hyphens only. Must not start or end with a hyphen. |
| `description` | **Yes** | Max 1024 characters. Non-empty. Describes what the skill does and when to use it. |
| `license` | No | License name or reference to a bundled license file. |
| `compatibility` | No | Max 500 characters. Indicates environment requirements (intended product, system packages, network access, etc.). |
| `metadata` | No | Arbitrary key-value mapping for additional metadata (a map from string keys to string values). |
| `allowed-tools` | No | Space-separated string of pre-approved tools the skill may use. **(Experimental)** |

Minimal valid skill:

```markdown
---
name: skill-name
description: A description of what this skill does and when to use it.
---
```

With optional fields:

```markdown
---
name: pdf-processing
description: Extract PDF text, fill forms, merge files. Use when handling PDFs.
license: Apache-2.0
metadata:
  author: example-org
  version: "1.0"
---
```

### `name`

- Must be 1-64 characters
- May only contain lowercase alphanumeric characters (`a-z`, `0-9`) and hyphens (`-`)
- Must not start or end with a hyphen
- Must not contain consecutive hyphens (`--`)
- **Must match the parent directory name**

Equivalent regex: `^[a-z0-9]+(-[a-z0-9]+)*$`, length 1-64.

Valid: `pdf-processing`, `data-analysis`, `code-review`

Invalid:

```yaml
name: PDF-Processing   # uppercase not allowed
name: -pdf             # cannot start with a hyphen
name: pdf--processing  # consecutive hyphens not allowed
```

### `description`

- Must be 1-1024 characters — this is a **hard limit**, not a display truncation
- Should describe both what the skill does and when to use it
- Should include specific keywords that help agents identify relevant tasks

The description carries the entire burden of triggering: at startup an agent loads
only `name` and `description`. If the description does not convey when the skill is
useful, the skill never activates. See [evaluating-skills.md](evaluating-skills.md)
for how to test and optimize it.

Good:

```yaml
description: Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction.
```

Poor:

```yaml
description: Helps with PDFs.
```

### `license`

Specifies the license applied to the skill. Keep it short — either a license name or
the name of a bundled license file.

```yaml
license: Proprietary. LICENSE.txt has complete terms
```

### `compatibility`

- Must be 1-500 characters if provided
- Include it only if the skill has specific environment requirements
- Can indicate intended product, required system packages, network access needs

```yaml
compatibility: Designed for Claude Code (or similar products)
compatibility: Requires git, docker, jq, and access to the internet
compatibility: Requires Python 3.14+ and uv
```

Most skills do not need this field.

### `metadata`

A map from string keys to string values. Clients use it to store properties the spec
does not define. Make key names reasonably unique to avoid conflicts.

```yaml
metadata:
  author: example-org
  version: "1.0"
```

### `allowed-tools`

A space-separated **string** of tools pre-approved to run.

```yaml
allowed-tools: Bash(git:*) Bash(jq:*) Read
```

**Experimental.** Support varies between agent implementations. Some clients also
accept a YAML list; the spec defines only the string form, so prefer the string if
the skill needs to be portable.

## Body content

The Markdown body after the frontmatter contains the skill instructions. **The spec
imposes no format restrictions** — write whatever helps agents perform the task.

Recommended sections: step-by-step instructions, examples of inputs and outputs,
common edge cases.

The agent loads this entire file once it decides to activate the skill. Split longer
content into referenced files.

> **Repo convention, not a spec rule:** skills in this repository use standard
> markdown headings (`#`, `##`) for body structure rather than XML tags. This
> matches every official example and keeps skills readable in GitHub and editors.
> The spec permits either.

## Optional directories

### `scripts/`

Executable code agents can run. Scripts should be self-contained or clearly document
dependencies, include helpful error messages, and handle edge cases gracefully.
Supported languages depend on the agent implementation; Python, Bash, and JavaScript
are common. See [using-scripts.md](using-scripts.md).

### `references/`

Additional documentation agents read when needed — `REFERENCE.md`, `FORMS.md`,
domain-specific files. Keep individual reference files focused: agents load them on
demand, so smaller files mean less context used.

### `assets/`

Static resources: document and configuration templates, images, data files
(lookup tables, schemas).

## Progressive disclosure

Agents load skills progressively, pulling in detail only as a task calls for it:

| Stage | What loads | Budget |
|---|---|---|
| 1. Metadata | `name` + `description`, for **all** skills, at startup | ~100 tokens |
| 2. Instructions | The full `SKILL.md` body, when the skill activates | **< 5,000 tokens** recommended |
| 3. Resources | Files in `scripts/`, `references/`, `assets/` | Loaded only when required |

Keep `SKILL.md` under **500 lines and 5,000 tokens**. Move detailed reference
material to separate files.

Telling the agent *when* to load each file matters more than listing the files.
"Read `references/api-errors.md` if the API returns a non-200 status code" is more
useful than "see references/ for details."

## File references

Reference other files with **relative paths from the skill root**:

```markdown
See [the reference guide](references/REFERENCE.md) for details.

Run the extraction script:
scripts/extract.py
```

Keep file references **one level deep** from `SKILL.md`. Avoid deeply nested
reference chains (`SKILL.md` → `a.md` → `b.md`), because agents may only partially
read files reached indirectly.

Script execution paths in code blocks are relative to the **skill directory root**,
including inside support files like `references/*.md`, because the agent runs
commands from there.

Always use forward slashes, never backslashes.

## Validation

This skill bundles a validator that checks every mechanical rule above:

```bash
uv run scripts/validate_skill.py path/to/skill
```

Exit code 0 means clean; 1 means problems were found. Run it before considering any
skill finished.

The standard also publishes a reference implementation,
[skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref):

```bash
skills-ref validate ./my-skill
```

It installs from source (clone the repo, then `uv sync` or `pip install -e .` inside
`skills-ref/`), so it is optional here — the bundled validator is the default gate.
