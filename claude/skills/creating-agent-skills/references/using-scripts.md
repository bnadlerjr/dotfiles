# Using Scripts in Skills

Running commands and bundling executable code. Merged from Anthropic's guidance and
[agentskills.io/skill-creation/using-scripts](https://agentskills.io/skill-creation/using-scripts).

## Contents

- [Why bundle a script](#why-bundle-a-script)
- [One-off commands](#one-off-commands) — when a packaged tool already does it
- [Referencing scripts](#referencing-scripts)
- [Self-contained scripts](#self-contained-scripts) — inline dependency declarations
- [Designing scripts for agentic use](#designing-scripts-for-agentic-use)
- [Shell script conventions](#shell-script-conventions)
- [MCP tool references](#mcp-tool-references)
- [Dependencies and environment](#dependencies-and-environment)

## Why bundle a script

Even when the agent could write the code, a pre-made script is:

- **More reliable** — tested once, not regenerated each run
- **Cheaper** — the script body never enters the context window; only its output does
- **Consistent** — same behaviour across invocations

The signal to write one: while iterating on a skill, you notice the agent independently
reinventing the same logic each run — building a chart, parsing a format, validating
output. Write it once and bundle it.

Say explicitly whether the agent should **execute** the script ("Run
`scripts/analyze_form.py` to extract fields") or **read it as reference** ("See
`scripts/analyze_form.py` for the extraction algorithm"). Execution is right for almost
all utility scripts.

## One-off commands

When an existing package already does the job, reference it directly — no `scripts/`
directory needed. Most ecosystems have a runner that resolves dependencies at runtime:

| Runner | Example | Notes |
|---|---|---|
| `uvx` | `uvx ruff@0.8.0 check .` | Ships with `uv`. Fast, caches aggressively. |
| `pipx` | `pipx run 'black==24.10.0' .` | Mature alternative; broader OS packaging. |
| `npx` | `npx eslint@9 --fix .` | Ships with npm. |
| `bunx` | `bunx eslint@9 --fix .` | Only when the environment has Bun. |
| `deno run` | `deno run --allow-read npm:eslint@9 -- --fix .` | Needs explicit permission flags. |
| `go run` | `go run golang.org/x/tools/cmd/goimports@v0.28.0 .` | Built into Go. |

**Pin versions** so the command behaves the same over time. **State prerequisites** in
`SKILL.md` rather than assuming them — for runtime-level requirements use the
`compatibility` frontmatter field. **Move complex commands into scripts**: a one-off
works for a tool with a few flags; once it's hard to get right first time, a tested
script is more reliable.

## Referencing scripts

Use **relative paths from the skill directory root**. The agent runs commands from
there, so no absolute paths are needed — and this holds inside `references/*.md` too.

List what exists so the agent knows:

```markdown
## Available scripts

- **`scripts/validate.sh`** — Validates configuration files
- **`scripts/process.py`** — Processes input data
```

Then say when to run them:

`````markdown
## Workflow

1. Run the validation script:
   ```bash
   bash scripts/validate.sh "$INPUT_FILE"
   ```
2. Process the results:
   ```bash
   python3 scripts/process.py --input results.json
   ```
`````

## Self-contained scripts

Declare dependencies inline so the agent runs the script with one command — no manifest
file, no install step.

**Python (PEP 723)** — the default choice here:

````python
# /// script
# requires-python = ">=3.11"
# dependencies = ["beautifulsoup4>=4.12,<5"]
# ///

from bs4 import BeautifulSoup
...
````

Run with `uv run scripts/extract.py`. `uv` creates an isolated environment, installs the
declared dependencies, and runs it. Use `uv lock --script` for full reproducibility.

Equivalents exist elsewhere: Deno's `npm:`/`jsr:` specifiers, Bun's auto-install with
pinned import paths, Ruby's `bundler/inline`.

This skill's own [validate_skill.py](../scripts/validate_skill.py) and its tests in
[test_validate_skill.py](../scripts/test_validate_skill.py) are worked examples — PEP
723 headers, no separate manifest, run directly with `uv run`.

## Designing scripts for agentic use

The agent reads stdout and stderr to decide what to do next. A few choices make a
script dramatically easier to drive.

### Never prompt interactively

A hard requirement. Agents run in non-interactive shells and cannot answer TTY prompts,
password dialogs, or confirmation menus — a blocking script hangs indefinitely. Take
all input via flags, environment variables, or stdin.

```
# Bad: hangs waiting for input
$ python scripts/deploy.py
Target environment: _

# Good: clear error with guidance
$ python scripts/deploy.py
Error: --env is required. Options: development, staging, production.
Usage: python scripts/deploy.py --env staging --tag v1.2.3
```

### Document usage with `--help`

`--help` is how the agent learns the interface. Include a description, the flags, and
examples — concisely, because the output lands in the context window.

### Write errors that shape the next attempt

An opaque "Error: invalid input" wastes a turn. Say what went wrong, what was expected,
and what to try:

```
Error: --format must be one of: json, csv, table.
       Received: "xml"
```

Show the valid options. See the validator table in
[instruction-patterns.md](instruction-patterns.md).

### Use structured output, and separate data from diagnostics

Prefer JSON, CSV, or TSV over whitespace-aligned text — both the agent and standard
tools (`jq`, `cut`, `awk`) can consume them.

Send structured data to **stdout** and progress, warnings, and diagnostics to
**stderr**. The agent then captures clean parseable output while still having
diagnostics available.

### Further considerations

- **Idempotency** — agents retry. "Create if not exists" beats "create and fail".
- **Input constraints** — reject ambiguous input with a clear error rather than
  guessing. Prefer enums and closed sets.
- **Dry-run support** — a `--dry-run` flag lets the agent preview destructive changes.
- **Meaningful exit codes** — distinct codes for distinct failures, documented in
  `--help`.
- **Safe defaults** — consider requiring `--confirm` or `--force` for destructive
  operations.
- **Predictable output size** — harnesses truncate tool output past a threshold
  (often 10-30K characters), silently losing information. Default to a summary, support
  `--offset` for more, or require an explicit `--output` target for large results.

### Solve, don't punt

Handle error conditions in the script rather than leaving them for the agent:

````python
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"{path} not found, creating it", file=sys.stderr)
        Path(path).write_text("")
        return ""
````

### No voodoo constants

Every tuning value gets a reason:

````python
# HTTP requests typically complete within 30 seconds
REQUEST_TIMEOUT = 30

# Three retries balances reliability against latency
MAX_RETRIES = 3
````

Not `TIMEOUT = 47` with no explanation.

## Shell script conventions

````bash
#!/usr/bin/env bash
# deploy.sh - Deploy the project
# Usage: deploy.sh [preview|production]

set -euo pipefail

ENVIRONMENT="${1:-preview}"

if [[ "$ENVIRONMENT" != "preview" && "$ENVIRONMENT" != "production" ]]; then
    echo "Error: environment must be 'preview' or 'production'; got '$ENVIRONMENT'" >&2
    exit 2
fi
````

Use `set -euo pipefail`, validate inputs before acting, keep scripts single-purpose,
and make them executable.

## MCP tool references

If a skill uses MCP tools, always use the fully qualified name — `ServerName:tool_name`,
e.g. `BigQuery:bigquery_schema`, `GitHub:create_issue`. Without the server prefix the
agent may fail to locate the tool when several MCP servers are connected.

## Dependencies and environment

List required packages in `SKILL.md` and say how to get them — "Install required
package: `pip install pypdf`", not "use the pdf library". For runtime-level needs
(a language version, a system binary, network access), use the `compatibility`
frontmatter field described in [agent-skills-spec.md](agent-skills-spec.md).

Execution environments differ in what they allow: some permit installing packages at
runtime, others have no network access at all. Self-contained scripts with inline
dependency declarations degrade most gracefully.

Handling credentials is a separate concern — see [api-security.md](api-security.md).
