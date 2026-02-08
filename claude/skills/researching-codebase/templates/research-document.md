# Research Document Template

Structure for research documents. See SKILL.md for metadata gathering and filename conventions.

## Template

```markdown
---
tags: [research, ai]
Area: <Area name from metadata>
Created: [[<Current date in YYYY-MM-DD format>]]
Modified: <Current date in YYYY-MM-DD format>
Project: [[<project name from user>]]
AutoNoteMover: disable
---

# Research: [User's Question/Topic]

**Date**: [Current date and time with timezone]
**Git Commit**: [Current commit hash]
**Branch**: [Current branch name]
**Repository**: [Repository name]
**Topic**: [User's Question/Topic]
**Tags**: [research, codebase, relevant-component-names]
**Status**: complete
**Last Updated**: [Current date in YYYY-MM-DD format]

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
- Get `Area` and `Project` from `git metadata` output (infer from repo name)

### Header Fields
- Metadata block provides context for future reference
- `Status` should be `complete` when document is finalized
- Update `Last Updated` when adding follow-up research

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
