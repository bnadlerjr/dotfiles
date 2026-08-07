---
name: {{skill-name}}
description: {{What it does, in third person.}} Use when {{trigger conditions, stated as instructions to the agent — list contexts explicitly, including where the user won't name the domain}}.
# Optional spec fields — portable everywhere:
# license: {{license name or bundled filename}}
# compatibility: {{only if the skill has real environment requirements; max 500 chars}}
# metadata:
#   version: "1.0"
# allowed-tools: Read Grep Glob      # space-separated string; experimental
#
# NON-SPEC — support is per field, not per client. Check the matrix in
# references/claude-code-extensions.md before assuming any of these carry over.
# disable-model-invocation: true     # user-only skills with side effects; also
#                                    # honoured by Pi, and by Codex via a sidecar
# argument-hint: "[arg1] [arg2]"     # Claude Code only
# user-invocable: false              # Claude Code only — NOT the inverse of the above
# paths: ["**/*.graphql"]            # Claude Code only
# context: fork                      # run in an isolated subagent context
# agent: Explore                     # subagent type when context: fork
---

# {{Skill Name}}

{{One or two sentences: what this skill accomplishes and why it matters. Assume the
agent is capable — state only what it wouldn't know without this file.}}

## Quick start

{{The fastest path to value. A minimal working example, not an explanation.}}

```{{language}}
{{minimal working example}}
```

{{One escape hatch if the default doesn't fit: "For {{edge case}}, use {{alternative}}
instead."}}

## Instructions

1. {{First action — specific enough that a stranger could follow it}}
2. {{Second action}}
3. {{Third action}}

{{Match specificity to fragility. Fragile or irreversible steps get exact commands and
"do not modify this"; judgment calls get criteria rather than steps.}}

## Examples

**Input:** {{realistic user request}}

**Output:**
```
{{what the skill should produce}}
```

## Gotchas

{{The highest-value section in most skills. Environment-specific facts that defy
reasonable assumptions — not general advice. Delete this section if there are none
yet, and add to it every time you have to correct the agent.}}

- {{Concrete correction, e.g. "The `users` table uses soft deletes; queries must
  include `WHERE deleted_at IS NULL`."}}

## Success criteria

- [ ] {{Verifiable outcome — checkable, not "the user is satisfied"}}
- [ ] {{Verifiable outcome}}
- [ ] {{Verifiable outcome}}
