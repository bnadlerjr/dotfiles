# Credentials and API Security

For skills that call authenticated APIs. The goal is that **no secret ever appears in
the conversation transcript**.

## Contents

- [The problem](#the-problem) — why an env var alone doesn't protect a secret
- [The pattern: a wrapper script](#the-pattern-a-wrapper-script)
- [Rules](#rules)
- [Multiple accounts](#multiple-accounts)
- [Where credentials live](#where-credentials-live)
- [Verifying without exposure](#verifying-without-exposure)

## The problem

An agent's shell commands and their output become part of the conversation. A command
with an expanded environment variable leaks the secret into the transcript, into any
logs, and into any context that is later summarized or shared:

```bash
# Leaks: the expanded key appears in the transcript
curl -H "Authorization: Bearer $API_KEY" https://api.example.com/data
```

The variable protects the value in the shell. It does not protect it from the
transcript, because the agent sees the rendered command and its output.

## The pattern: a wrapper script

Put the credential handling **inside a bundled script**, and have the skill invoke the
script by operation name. The command in the transcript names an operation; the secret
is read inside the process and never rendered.

```bash
# Safe: the transcript shows only this
bash scripts/api.sh list-campaigns
bash scripts/api.sh get-contact "user@example.com"
```

The script loads credentials itself:

````bash
#!/usr/bin/env bash
# api.sh - Authenticated calls to Example API.
# Usage: api.sh <operation> [args]
# Credentials: EXAMPLE_API_KEY, read from the environment or an env file.

set -euo pipefail

: "${EXAMPLE_API_KEY:?EXAMPLE_API_KEY is not set. Add it to your environment, then retry.}"

OPERATION="${1:?Usage: api.sh <operation> [args]. Operations: list-items, get-item}"
shift

case "$OPERATION" in
  list-items)
    curl -sS -H "Authorization: Bearer $EXAMPLE_API_KEY" \
      "https://api.example.com/items"
    ;;
  get-item)
    ITEM_ID="${1:?get-item requires an item id}"
    curl -sS -H "Authorization: Bearer $EXAMPLE_API_KEY" \
      "https://api.example.com/items/$ITEM_ID"
    ;;
  *)
    echo "Unknown operation: $OPERATION. Valid: list-items, get-item" >&2
    exit 2
    ;;
esac
````

Add every operation the skill needs. Making the agent assemble `curl` invocations
itself defeats the purpose — that is exactly when the raw command with the expanded
secret reappears.

## Rules

1. **Never show a raw command containing a credential variable** in `SKILL.md`,
   references, or examples. Even as an illustration, it teaches the pattern that leaks.
2. **Never hardcode a secret** in a script, a template, or an example.
3. **Fail loudly on a missing credential**, naming the variable and what to do:
   `EXAMPLE_API_KEY is not set. Add it to your environment, then retry.` Never print
   the value, and never echo it back to confirm it.
4. **Use a closed set of operations.** The wrapper decides what calls are possible.
5. **Redact in errors.** If the API returns a body echoing the request, strip
   authorization headers before printing.
6. **Guard destructive calls** with `--dry-run` and an explicit `--confirm`.
7. **Validate inputs** before interpolating them into a URL or request body.

## Multiple accounts

When a service has several accounts or environments, make the selection explicit rather
than implicit — using the wrong account is the failure mode that matters.

Suffix the variables per profile (`EXAMPLE_MAIN_API_KEY`, `EXAMPLE_STAGING_API_KEY`),
accept the profile as an argument, and have the skill **announce which profile it is
using before each call**. If exactly one profile is configured, use it and say so. If
several are, ask which. Never guess.

```bash
bash scripts/api.sh --profile main list-items
```

## Where credentials live

The portable answer is **the environment**. The skill documents which variables it
needs; the user supplies them however their setup does it — shell profile, direnv, a
secret manager, or the agent client's own configuration.

Declare the requirement in frontmatter so the dependency is discoverable:

```yaml
compatibility: Requires EXAMPLE_API_KEY in the environment and network access
```

If a skill loads an env file, it must fail with a clear message when the file is
absent, and the file must be outside version control.

> Do not invent a shared credential-broker path and document it as though it exists.
> A skill that instructs the agent to run a script that is not installed produces a
> confusing failure at exactly the moment credentials are involved. Bundle the wrapper
> **inside the skill**, where the relative path is guaranteed to resolve.

## Verifying without exposure

Check that a credential is configured without printing it:

```bash
[ -n "${EXAMPLE_API_KEY:-}" ] && echo "EXAMPLE_API_KEY configured" || echo "EXAMPLE_API_KEY missing"
```

Then exercise the wrapper on a read-only operation and confirm the transcript contains
the operation name and the response — and no secret.
