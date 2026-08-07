---
name: {{skill-name}}
description: {{What it does, in third person.}} Use when {{trigger conditions covering every workflow below}}.
# metadata:
#   version: "1.0"
# See assets/simple-skill.md for the full optional-field list, including the
# non-portable Claude Code extensions.
---

# {{Skill Name}}

{{One or two sentences on what this skill covers.}}

## How this skill works

{{Principles that apply to EVERY workflow. They live here because SKILL.md always
loads — anything below this point in a workflow file can be skipped, this cannot.
Keep it to three or four.}}

### 1. {{First principle}}

{{Brief explanation. State the consequence, not just the rule.}}

### 2. {{Second principle}}

{{Brief explanation.}}

### 3. {{Third principle}}

{{Brief explanation.}}

## What would you like to do?

Ask the user:

```
What would you like to do?
1. {{First option}}
2. {{Second option}}
3. {{Third option}}
```

**Wait for the response before proceeding.**

### Routing

| Answer | Workflow |
|---|---|
| 1, "{{keyword}}", "{{keyword}}" | [workflows/{{first-workflow}}.md](workflows/{{first-workflow}}.md) |
| 2, "{{keyword}}", "{{keyword}}" | [workflows/{{second-workflow}}.md](workflows/{{second-workflow}}.md) |
| 3, "{{keyword}}", "{{keyword}}" | [workflows/{{third-workflow}}.md](workflows/{{third-workflow}}.md) |
| anything else | Clarify, then route |

**After reading the workflow, follow it exactly.**

### Non-interactive callers

If the request already contains the requirements — a caller supplied scope and intent
up front, or you are running as a subagent — **skip the intake question, choose the
workflow yourself from the table above, and do not ask.** Answer the workflow's
questions from the context you were given. Workflow filenames are stable; callers may
name them directly.

## Quick reference

{{Brief information worth having visible on every invocation, regardless of workflow.
Delete this section if there isn't any.}}

## Reference index

Load on demand — the workflows say which ones they need.

| Reference | Read it when |
|---|---|
| [{{reference-1}}.md](references/{{reference-1}}.md) | {{the condition that makes it relevant}} |
| [{{reference-2}}.md](references/{{reference-2}}.md) | {{the condition that makes it relevant}} |

## Workflow index

{{OPTIONAL — delete this whole section unless the purposes need more room than the
routing table gives them. The routing table above already names every workflow file,
so an index is a second copy to keep in sync.}}

| Workflow | Purpose |
|---|---|
| [{{first-workflow}}.md](workflows/{{first-workflow}}.md) | {{what it does}} |
| [{{second-workflow}}.md](workflows/{{second-workflow}}.md) | {{what it does}} |

## Success criteria

- [ ] {{Verifiable outcome}}
- [ ] {{Verifiable outcome}}
