# Workflow: Add a Script to a Skill

**Read first:** `references/using-scripts.md`. Also read `references/api-security.md`
if the script will touch credentials.

## Step 1: Identify the skill and the operation

Ask, if not already supplied: which skill, and what operation should the script perform?

## Step 2: Confirm a script is the right answer

- [ ] The same logic runs across multiple invocations
- [ ] It is error-prone when rewritten from scratch each time
- [ ] Consistency matters more than flexibility

The strongest signal comes from evidence: while using the skill, the agent kept
reinventing the same helper. If that hasn't happened yet, inline instructions may be
enough — a script is a maintenance commitment.

If an existing packaged tool already does this, prefer invoking it directly
(`uvx`, `npx`, `pipx run`) with a pinned version. No script needed.

## Step 3: Design the interface

The interface is what the agent sees, so design it first:

- **Inputs** — flags, environment variables, or stdin. **Never interactive prompts**;
  agents run in non-interactive shells and a prompt hangs forever.
- **Output** — structured (JSON/CSV) on stdout; progress and warnings on stderr.
- **Failures** — what can go wrong, and what the error message should tell the agent to
  do next.
- **Exit codes** — distinct codes for distinct failures.
- **Destructive operations** — add `--dry-run`, and consider requiring `--confirm`.
- **Output size** — if it could be large, default to a summary and offer a flag for
  more.

Choose the language by the work: bash for shell and file operations, Python for data
processing and APIs, Node/TypeScript for the JS ecosystem.

## Step 4: Create the directory

```bash
mkdir -p ~/.claude/skills/{skill-name}/scripts
```

## Step 5: Write the script

Declare dependencies inline so there is no separate install step. For Python, PEP 723:

````python
# /// script
# requires-python = ">=3.11"
# dependencies = ["requests>=2.32,<3"]
# ///
````

Run with `uv run scripts/{name}.py`.

Include a purpose comment, usage in `--help`, input validation, explicit error handling,
and named constants with reasons — never `TIMEOUT = 47` with no explanation.

For bash: `#!/usr/bin/env bash` and `set -euo pipefail`, then `chmod +x`.

**No hardcoded secrets, and no command that renders a credential into the transcript.**

## Step 6: Test the script directly

Before wiring it in, run it standalone: the happy path, a bad-input case, and `--help`.
Confirm the error messages would actually tell an agent what to do differently.

Write tests if the logic is non-trivial. `scripts/validate_skill.py` and
`scripts/test_validate_skill.py` in this skill are a worked example.

## Step 7: Wire it into the skill

List it where the agent will look:

```markdown
## Available scripts

- **`scripts/{name}.py`** — {what it does}
```

Then add the invocation to the workflow step that needs it, using a **relative path from
the skill root** — the agent runs commands from there.

## Step 8: Validate

```bash
uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ~/.claude/skills/{skill-name}
```

A script nothing references is an orphan; the validator will flag it.

## Success criteria

- [ ] A script is genuinely warranted, not a one-off
- [ ] Never prompts interactively; `--help` documents the interface
- [ ] Structured output on stdout, diagnostics on stderr, meaningful exit codes
- [ ] Errors say what went wrong, what was expected, and what to try
- [ ] Dependencies declared inline; constants explained
- [ ] No hardcoded secrets, and no credential rendered into a command
- [ ] Executable, if a shell script
- [ ] Referenced from at least one workflow by relative path
- [ ] Tested standalone and through the skill
