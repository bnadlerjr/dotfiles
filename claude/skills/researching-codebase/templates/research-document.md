# Research Document Template

Structure for research documents. See SKILL.md for metadata gathering and filename conventions.

## Template

```markdown
[YAML frontmatter per CLAUDE-PERSONAL.md "Artifact Management" schema]

# Research: [User's Question/Topic]

## Research Question
[Original user query]

## Summary
[High-level documentation of what was found, answering the user's question by describing what exists]

## Detailed Findings

### [Component/Area 1]
- Description of what exists ([file.ext:line](link))
- How it connects to other components
- Current implementation details (without evaluation)

### [Component/Area 2]
...

## Code References
- `path/to/file.py:123` - Description of what's there
- `another/file.ts:45-67` - Description of the code block

## Architecture Documentation
[Current patterns, conventions, and design implementations found in the codebase]

## Historical Context
[Relevant insights from docs directory with references]

## Related Research
[Links to other related research documents]

## Open Questions
[Any areas that need further investigation]
```

---

## Section Guidelines

### Frontmatter
- All fields required
- Populate from `projects.yaml` per CLAUDE-PERSONAL.md artifact management schema

### Detailed Findings
- Group by component or logical area
- Include file:line references for every claim
- Describe what exists without evaluation

### Code References
- Standalone section for quick navigation
- Use GitHub permalinks when on main branch

### Historical Context
- Reference docs directory findings
- Provide context for current implementations

### Open Questions
- Areas needing further investigation
- Helps scope follow-up research
