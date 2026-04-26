---
description: Slice an epic into an ordered backlog of thin vertical stories, grounded in existing code
argument-hint: "<Jira ID | Linear ID | file path | inline epic text>"
model: opus
allowed-tools: Read, Write, Bash, Task, AskUserQuestion, Glob, Grep
---

# Epic to Stories

**Level 4 (Delegation)** — Orchestrates parallel codebase research, then applies the carpaccio slicing skill to produce an ordered backlog of 10-20 thin slices.

Take an epic, research relevant existing code, and produce an ordered backlog of thin vertical slices using the elephant-carpaccio methodology. Each slice is a candidate story that can later be refined into a full BDD story via `/refine-jira-story` or `/refine-linear-story`.

## Variables

- **EPIC_SOURCE**: `$ARGUMENTS` — Jira ID (e.g., POPS-123), Linear ID (e.g., ENG-45), file path, or inline epic text
- **ARTIFACT_DIR**: `$CLAUDE_DOCS_ROOT/stories/`
- **REPOS**: Repositories to research (default: current working directory)

## Dependencies

- **slicing-elephant-carpaccio skill**: Slicing methodology, INVEST + Vertical validity rules, ordering principles
- **thinking-patterns skill**: `atomic-thought` for research-target decomposition, `chain-of-thought` for slice validation
- **managing-jira skill** (conditional): `jira issue view` for Jira-sourced epics
- **managing-linear skill** (conditional): Linear CLI for Linear-sourced epics
- **codebase-analyzer agent**: Deep code research per research target
- **Project registry**: `$CLAUDE_DOCS_ROOT/projects.yaml` (for multi-repo epics)
- **Artifact management**: `~/.claude/guidelines/artifact-management.md` — frontmatter and naming conventions

## Initial Response

When invoked without arguments:

```
I'll slice an epic into an ordered backlog of thin vertical stories, grounded in existing code.

Provide the epic source — one of:
- Jira issue ID (e.g., POPS-123)
- Linear issue ID (e.g., ENG-45)
- File path containing the epic
- Inline epic text

Usage: /epic-to-stories <source>
```

---

## Phase 1: Intake

### Detect Source Type

Inspect `${EPIC_SOURCE}`:

- Matches a Jira project key pattern (e.g., `POPS-\d+`) → fetch via Jira
- Matches a Linear team key pattern (e.g., `ENG-\d+`) → fetch via Linear
- Existing file path → `Read` the file
- Otherwise → treat as inline epic text

If a key matches BOTH a Jira and Linear pattern, disambiguate via AskUserQuestion before fetching.

### Fetch (when sourced from a tracker)

**Jira:**
```bash
jira issue view ${EPIC_SOURCE} --comments 10
jira issue view ${EPIC_SOURCE} --raw
```

Then list child issues (epics typically have children):
```bash
jira issue list -q "parent=${EPIC_SOURCE}" --plain
```

**Linear:** use the `managing-linear` skill to fetch the issue, comments, and any sub-issues.

### Build Epic Context

Compile a normalized block:

```
**Epic Source**: ${SOURCE_TYPE} — ${SOURCE_REF}
**Title**: ${TITLE}
**Description**: ${DESCRIPTION}
**Children / Sub-issues**: ${CHILDREN}            # if from tracker
**Comments / Notes**: ${COMMENT_SUMMARIES}        # if available
**Initial Domain Terms**: [extracted from text]
```

Present the summary to the user before proceeding.

---

## Phase 2: Scope the Research

### Pick Repositories

If `$CLAUDE_DOCS_ROOT/projects.yaml` exists, present its project list. Otherwise default to the current working directory.

**AskUserQuestion**:
- Header: "Research scope"
- Question: "Which repositories should I research for code related to this epic?"
- Options: project entries from projects.yaml, plus "Current directory only" and "Specify paths"

Record the selected `${REPOS}` list.

### Decompose into Research Targets

Invoke `/thinking atomic-thought` to derive 3-7 independent research questions from the epic. Each must name a concrete behavior or domain concept that existing code might already address. Examples:

- "Does the codebase already model `${concept_X}`?"
- "How does the system currently handle `${flow_Y}`?"
- "Where are `${data_type_Z}` validated, persisted, displayed?"

Present the research targets to the user. Allow editing before continuing — bad targets produce shallow research.

---

## Phase 3: Parallel Codebase Research

For each `(repo, research_target)` pair, spawn a `codebase-analyzer` agent in parallel via the Task tool. Each prompt is self-contained.

### Agent Prompt Template

```markdown
# Codebase Research for Epic Slicing

You are researching `${REPO}` to ground the slicing of an epic into stories.

## Epic Context

${EPIC_CONTEXT}

## Research Target

${RESEARCH_TARGET}

## Focus

Document only what *exists today*. Do NOT propose changes or improvements.

1. **Existing implementations** — code addressing this target, with `file:line` references
2. **Domain vocabulary** — terms the codebase uses for this concept
3. **Patterns and conventions** — naming, structure, test patterns in the relevant area
4. **Gaps** — aspects of this research target NOT covered by existing code (these become candidate slices)
5. **Integration points** — external systems, APIs, schemas relevant to this target

## Output Format

### Existing Implementations
[List with `file:line` and a one-line description per item]

### Domain Vocabulary
[Canonical terms found in the code, with rejected synonyms if any]

### Patterns
[How similar features are structured]

### Gaps
[What's missing in the research target]

### Integration Points
[External contracts, schemas, services]
```

### Wait for All Agents

Do not proceed until every spawned agent returns.

### Consolidate Findings

Merge per-target findings into a single research summary. Bucket explicitly:

- **Reuse opportunities** — existing code that shortens a slice
- **Greenfield areas** — no prior art; slices here will be heavier
- **Domain glossary** — canonical terms to use in slice descriptions

Present the consolidated summary to the user.

---

## Phase 4: Carpaccio Slicing

Load the `slicing-elephant-carpaccio` skill and apply it directly. Pass BOTH the epic context AND the consolidated research as input. Use the research to inform:

- **Slice 1 (walking skeleton)**: prefer a path that reuses existing infrastructure
- **Slice ordering**: greenfield slices that unblock downstream work come earlier; polish and edge cases last
- **Slice descriptions**: use canonical domain vocabulary surfaced by research

### Validate the Backlog

Invoke `/thinking chain-of-thought` to check each slice against:

1. **INVEST + Vertical** — every slice must pass all seven validity tests from the skill
2. **Research grounding** — does each slice description reflect what research actually found? A slice claimed as "trivial because X exists" must cite the specific `file:line` finding
3. **Strict value increase** — each slice strictly increases user-visible value or reduces risk over the prior one

If any slice fails, re-slice before showing the user.

---

## Phase 5: Review

Present the backlog using the slicing skill's confirmation step.

**AskUserQuestion**:
- Header: "Slice backlog"
- Question: "Does this slice ordering look right?"
- Options:
  - "Looks good"
  - "Adjust ordering"
  - "Slices too thick — split further"
  - "Slices too thin — combine some"
  - "Re-research a target" (loops back to Phase 3 with revised targets)

Iterate until the user accepts the backlog.

---

## Phase 6: Save Artifact

Save to `${ARTIFACT_DIR}/epic--<slug>.md` per `~/.claude/guidelines/artifact-management.md` (frontmatter + slug from the epic title). Body:

```markdown
# ${TITLE}

## Description

${DESCRIPTION}

## Research Summary

${CONSOLIDATED_RESEARCH}

## Slice Backlog

[Numbered list per slicing-elephant-carpaccio output_format —
 each slice has a name, one-line description, and a Value: line]

## Domain Glossary

[Canonical terms from research — what to use, what to avoid]

## Open Questions

[Anything research could not answer — these block specific slices]

## References

- **Source**: ${SOURCE_TYPE} — ${SOURCE_REF}
- **Researched**: ${REPOS}
```

---

## Report

After saving, show the user:

- Path to the saved artifact
- Slice count and slice 1 (the walking skeleton)
- Top 3 reuse opportunities
- Top 3 greenfield risks
- Suggested follow-up:
  ```
  To turn an individual slice into a full BDD story:
  - /refine-jira-story <issue-id>     (after creating the issue)
  - /refine-linear-story <issue-id>   (after creating the issue)
  ```

If the source was a Jira/Linear epic, OFFER to create child issues for each slice — never create tickets without explicit user confirmation.

---

## Error Handling

### Empty EPIC_SOURCE

```
No epic source provided.

Usage: /epic-to-stories <Jira ID | Linear ID | file path | inline text>
```

### Tracker fetch fails

Ask the user whether to retry, paste the epic content directly, or abort.

### Research returns nothing actionable

If every research target comes back empty, the codebase has no relevant prior art. Note this explicitly in the artifact's Research Summary and proceed — slices will be heavier and slice 1 will require a real walking-skeleton build, not a thin reuse path.

### Slice backlog never converges

If the user rejects the backlog three times in a row with conflicting feedback, stop and ask: "The slicing keeps shifting. Is the epic itself too broad? Should we split it into multiple epics first?" Do not keep re-slicing in a loop.
