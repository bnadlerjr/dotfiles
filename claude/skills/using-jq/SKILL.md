---
name: using-jq
description: |
  jq command-line JSON processor expertise covering filter syntax, object/array
  manipulation, data transformation, and CLI tool integration patterns.

  Use when processing JSON output from CLI tools (jira, gh, curl), extracting
  fields from API responses, transforming JSON data structures, or formatting
  JSON for shell consumption. Also use for jq filters, JSON parsing in bash,
  or when piping JSON through command-line tools.
---

# Using jq

Expert guidance for processing JSON on the command line with jq.

## Quick Start

For immediate help, identify your task type and consult the relevant reference:

| Working On | Reference File | Key Topics |
|------------|----------------|------------|
| Filter syntax, arrays, objects | [core-filters](references/core-filters.md) | Access, select, map, conditionals, built-ins |
| Jira CLI, GitHub CLI, curl | [cli-integrations](references/cli-integrations.md) | Tool-specific JSON patterns |
| Shell variables, TSV, CSV | [output-formatting](references/output-formatting.md) | -r, @tsv, @csv, null handling |

## Core Principles

### Use `-e` for Error Detection

Always use `jq -e` when checking for values — it sets exit code 1 when the result is `false` or `null`, enabling proper error handling in shell pipelines.

### Use `-r` for Shell Consumption

Always use `jq -r` when the output feeds into shell variables, pipes, or further processing. Without `-r`, strings include surrounding quotes.

### Build Filters Incrementally with Pipe

Compose complex filters by chaining simple ones with `|`:

```bash
# Build up step by step
jq '.items'            # get array
jq '.items[]'          # iterate elements
jq '.items[] | .name'  # extract field from each
```

### Inject Variables with `--arg`

Never interpolate shell variables into jq filter strings. Use `--arg` and `--argjson`:

```bash
# Correct: --arg for strings, --argjson for numbers/booleans/null
jq --arg name "$user" '.users[] | select(.name == $name)' data.json
jq --argjson id "$numeric_id" '.items[] | select(.id == $id)' data.json

# WRONG: shell interpolation — breaks on special characters, injection risk
jq ".users[] | select(.name == \"$user\")" data.json
```

## Common Pattern Template

The canonical pipeline pattern for extracting data from a command:

```bash
command_producing_json | jq -r '.path.to.field'
```

For multiple fields per record:

```bash
command_producing_json | jq -r '.items[] | [.field1, .field2] | @tsv'
```

## Anti-Patterns

### String Interpolation in Filters

```bash
# BAD — breaks on special characters, injection risk
jq ".users[] | select(.name == \"$name\")" file.json

# GOOD — safe variable injection
jq --arg name "$name" '.users[] | select(.name == $name)' file.json
```

### Using grep/sed on JSON

```bash
# BAD — fragile, breaks on formatting changes
curl -s "$url" | grep '"name"' | sed 's/.*: "//;s/".*//'

# GOOD — structural access
curl -s "$url" | jq -r '.name'
```

### Unquoted jq Output in Shell

```bash
# BAD — word splitting on values with spaces
name=$(curl -s "$url" | jq '.name')  # includes quotes!

# GOOD — raw output, quoted assignment
name="$(curl -s "$url" | jq -r '.name')"
```

### Ignoring Null Values

```bash
# BAD — prints "null" as literal string
jq -r '.optional_field'

# GOOD — skip nulls or provide defaults
jq -r '.optional_field // empty'
jq -r '.optional_field // "default"'
```

## Reference File IDs

For programmatic access: `core-filters` · `cli-integrations` · `output-formatting`
