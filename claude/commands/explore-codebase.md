---
description: Conduct targeted codebase research based on resolved questions
argument-hint: [path to decisions artifact from /question-me]
model: opus
---

# Explore Codebase

Conduct targeted codebase research driven by a decisions artifact. You are a cartographer — map what exists, where it exists, how it works, and how components connect. Do not suggest changes, critique implementations, or make design decisions.

Read and follow the methodology in the `researching-codebase` skill:
`~/dotfiles/claude/skills/researching-codebase/SKILL.md`

## Variables

DECISIONS_PATH: $ARGUMENTS
ARTIFACT_DIR: $CLAUDE_DOCS_ROOT/research/

## Instructions

- If DECISIONS_PATH is empty, STOP and respond:
  "Usage: `/explore-codebase <path-to-decisions-artifact>`
  Run `/question-me` first to produce the decisions artifact."
- Document only — describe what exists, not what to improve
- Include `file:line` references for every finding
- Wait for ALL agents to complete before synthesizing
- Never use placeholder values in the artifact

## Workflow

1. **Load decisions**
   - Read the decisions artifact at DECISIONS_PATH completely
   - Extract: Goal, Resolved Decisions, Scope Boundaries, Research Targets
   - These Research Targets drive all agent work below

2. **Spawn parallel agents** — one batch per research target, all launched simultaneously:
   - **codebase-navigator**: Find all files related to each research target
   - **codebase-analyzer**: Understand how current implementations work
   - **codebase-pattern-finder**: Find conventions and patterns used in similar areas
   - **docs-locator**: Find existing research or decisions about this area
   - Tell every agent: "Document what exists. Do not suggest improvements."
   - Tell every agent: "Include `file:line` references for all findings."
   - When a research target involves a library already imported in the codebase
     (e.g., TanStack Table, Apollo Client, Ecto, Phoenix), include in one agent's
     prompt: "Check the library's documentation or API for built-in support for
     [the feature]. Report what the library provides natively before we design a
     custom solution."
   - If web research is needed, instruct agents to return URLs with their findings

3. **Wait for ALL agents to complete** — do not proceed until every agent returns

4. **Verify and cross-reference**
   - Read all identified files fully — do not skim
   - Confirm `file:line` references are accurate
   - Note discrepancies or conflicts between agent findings
   - Resolve conflicts by reading the source directly

5. **Write research artifact**
   - Check for existing artifacts: `ls $CLAUDE_DOCS_ROOT/research/`
   - Read `$CLAUDE_DOCS_ROOT/projects.yaml` for project context
   - Save to `ARTIFACT_DIR/research--<slug>.md` with full frontmatter per artifact-management guidelines
   - Use the report format below for the document body

6. **Present summary** — show the user the Summary and Open Questions sections

## Report

```markdown
## Research Question

[Goal from the decisions artifact]

## Summary

[What exists, in 3-5 sentences. No opinions.]

## Resolved Decisions

[Carry forward from the decisions artifact for traceability]

## Detailed Findings

### [Component/Area Name]

**What exists**: [Description with `file:line` references]

**Connections**: [Data flow, dependencies, how it relates to other components]

**Patterns**: [Conventions this area follows — naming, structure, test patterns]

### [Next Component/Area]

...

## Code References

[Consolidated list of `path/to/file:line` with one-line descriptions]

## Architecture

[How components relate. Data flow diagrams if helpful. Key interfaces and boundaries.]

## Open Questions for Design

[Things research could not answer that require human judgment — these feed back into the next design conversation]
```
