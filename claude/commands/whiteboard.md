---
description: Design-first collaboration — whiteboard before keyboard
argument-hint: <story, requirements, or feature description>
---

Invoke the `collaborating-on-design` skill to run a design-first session.

TASK: $ARGUMENTS

## Artifact Management

After the design session completes, save the output as a design artifact:

1. **Look up project context** from `$CLAUDE_DOCS_ROOT/projects.yaml`
   - Match current repository to a known project
   - If no match, ask the user which project this belongs to
   - If no project applies, use `Area: One-off` with no project fields

2. **Generate the slug** from the TASK (kebab-case, descriptive)

3. **Save to** `$CLAUDE_DOCS_ROOT/designs/design--<slug>.md` with this structure:

```yaml
---
tags: [claude-artifact, resource, design]
Area: [<area from project>]
Created: [[<today's date>]]
Modified: <today's date>
AutoNoteMover: disable
Project: [[<project name>]]
ProjectSlug: <project-slug>
JiraEpic: <epic if Area includes Work>
Repositories: ["<org/repo>"]
Status: Active
---
```

4. **Body structure:** Include all approved levels with their diagrams, organized
   under clear headings.

5. **Report:** Provide the artifact file path after saving.
