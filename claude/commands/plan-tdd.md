---
description: Create TDD implementation plans with explicit test-first phases
argument-hint: <story requirements, design artifact path, or tech spec>
model: opus
---

Invoke the `planning-tdd` skill to create a test-driven implementation plan.

TASK: $ARGUMENTS

## Instructions

- If TASK is empty, STOP immediately and ask the user to provide
  story requirements, a design artifact path, or a tech spec.
- Search `$CLAUDE_DOCS_ROOT/` for existing research, plans, designs,
  and handoffs related to TASK before starting.

## Artifact Management

After the plan is complete, save the output as a plan artifact:

1. **Look up project context** from `$CLAUDE_DOCS_ROOT/projects.yaml`
   - Match current repository to a known project
   - If no match, ask the user which project this belongs to
   - If no project applies, use `Area: One-off` with no project fields

2. **Generate the slug** from the TASK (kebab-case, descriptive)

3. **Save to** `$CLAUDE_DOCS_ROOT/plans/plan--<slug>.md` with this structure:

```yaml
---
tags: [claude-artifact, resource, plan]
Area: [<area from project>]
Created: [[<today's date>]]
Modified: <today's date>
AutoNoteMover: disable
Project: [[<project name>]]
ProjectSlug: <project-slug>
Repositories: ["<org/repo>"]
Status: Active
---
```

4. **Body structure:** Include all plan sections from the template output.

5. **Report:** Provide:
   - Plan file path
   - Phase count with TDD cycle count per phase
   - Testing stack summary (framework, patterns)
   - Any assumptions made
