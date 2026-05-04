---
description: Slice an epic into an ordered backlog of thin vertical stories, grounded in existing user-facing capabilities
argument-hint: "<Jira ID | Linear ID | file path | inline epic text>"
model: opus
allowed-tools: Read, Write, Bash, Task, AskUserQuestion
---

# Epic to Stories

**Level 4 (Delegation)** — Orchestrates parallel behavior-surface research, then applies the carpaccio slicing skill to produce an ordered backlog of 10-20 thin slices.

Take an epic, research existing user-facing capabilities related to it, and produce an ordered backlog of thin vertical slices using the elephant-carpaccio methodology. Each slice is a candidate story that can later be refined into a full BDD story via `/refine-jira-story` or `/refine-linear-story`.

Slicing decisions are anchored in behavior, never implementation. Research surfaces capabilities (what users can see or do); deep code research belongs in `/create-implementation-plan` and `/implement`, not here.

## Variables

- **EPIC_SOURCE**: `$ARGUMENTS` — Jira ID (e.g., POPS-123), Linear ID (e.g., ENG-45), file path, or inline epic text
- **ARTIFACT_DIR**: `$CLAUDE_DOCS_ROOT/stories/`
- **REPOS**: Repositories to research (default: current working directory)

## Dependencies

- **slicing-elephant-carpaccio skill**: Slicing methodology, INVEST + Vertical + Behavior-described validity rules, ordering principles
- **thinking-patterns skill**: `atomic-thought` for research-target decomposition, `chain-of-thought` for slice validation
- **managing-jira skill** (conditional): `jira issue view` for Jira-sourced epics
- **managing-linear skill** (conditional): Linear CLI for Linear-sourced epics
- **docs-locator agent**: Locate product docs (PRDs, READMEs, ADRs) describing existing user-facing capabilities
- **docs-analyzer agent**: Extract behavioral context from located product docs
- **capability-locator agent**: Inventory existing user-facing entry points when product docs are sparse — never invokes deep-code agents
- **Project registry**: `$CLAUDE_DOCS_ROOT/projects.yaml` (for multi-repo epics)
- **Artifact management**: `~/.claude/guidelines/artifact-management.md` — frontmatter and naming conventions

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

Invoke `/thinking atomic-thought` to derive 3-7 independent research questions from the epic. Each must name a concrete user-facing behavior or domain concept that the existing system might already support. Frame questions in user-visible terms — "what can users see or do", not "how is it built". Examples:

- "What can users currently see or do related to `${concept_X}`?"
- "What user-facing capabilities exist today for `${flow_Y}`?"
- "What user-facing vocabulary does the product use for `${data_type_Z}`?"

Present the research targets to the user. Allow editing before continuing — bad targets produce shallow research. Reject any target framed in implementation language — apply the same Implementation Leak rule the `slicing-elephant-carpaccio` skill uses for slice descriptions.

---

## Phase 3: Parallel Behavior-Surface Research

For each `(repo, research_target)` pair, spawn behavior-surface research agents in parallel via the Task tool.

### Agent Selection

- **Primary**: `docs-locator` followed by `docs-analyzer` for product documentation (PRDs, READMEs, ADRs about user-facing capabilities). Docs are written in user language; the translation distance to behavior is zero.
- **Secondary**: `capability-locator` for entry-point inventory — used when the area has sparse product documentation. The agent reads only entry points (routes, pages, CLI commands, public APIs) and reports capability statements with no implementation detail.
- **Forbidden**: `codebase-analyzer` and any other agent that returns deep implementation context. Slicing operates on behavior; implementation knowledge belongs in `/create-implementation-plan` and `/implement`. Mixing substrates contaminates slice descriptions.

### Agent Prompt Template

Each agent prompt is self-contained.

```markdown
# Behavior-Surface Research for Epic Slicing

You are researching `${REPO}` to surface existing user-facing capabilities related to an epic. Your job is to describe what users can currently *see* or *do* — never how it is built.

## Epic Context

${EPIC_CONTEXT}

## Research Target

${RESEARCH_TARGET}

## Focus

Document only what *exists today* at the behavioral surface. Do NOT propose changes or improvements. Do NOT include file paths, line numbers, function names, internal classes, patterns, schemas, middleware, services, or any other implementation detail in your output. If you find yourself describing how something is built, stop and re-frame to what users observe.

1. **Existing capabilities** — what users can currently see or do in this domain, expressed as "A user can [verb] [noun] [conditions]"
2. **Domain vocabulary** — user-facing terms the product uses canonically for these concepts
3. **Capability gaps** — what users CANNOT yet do that the epic would enable
4. **Adjacent capabilities** — related user-facing capabilities outside the epic's scope but inside its vocabulary (useful for slice ordering and vocabulary alignment)

## Output Format

### Existing Capabilities
[Capability statements only — no file:line, no internals]

### Domain Vocabulary
[Canonical user-facing terms]

### Capability Gaps
[Behavioral gaps the epic should close]

### Adjacent Capabilities
[Related user-facing capabilities outside this epic's scope]
```

### Wait for All Agents

Do not proceed until every spawned agent returns.

### Consolidate Findings

Merge per-target findings into a single research summary. Bucket explicitly:

- **Capability adjacencies** — existing user-visible capabilities a slice can extend or compose
- **Net-new capabilities** — capabilities the epic introduces with no behavioral precedent (slices here will be heavier; slice 1 must be a real walking skeleton rather than an extension)
- **Domain glossary** — canonical user-facing terms to use in slice descriptions

Present the consolidated summary to the user.

---

## Phase 4: Carpaccio Slicing

Load the `slicing-elephant-carpaccio` skill and apply it directly. Behavior context has already been established by Phases 1-3, so the skill's Step 1 is satisfied — pass BOTH the epic context AND the consolidated research as the supplied scope; the skill confirms rather than re-researches. The skill produces and validates the backlog; this command owns the user-confirmation gate (Phase 5).

Use the research to inform:

- **Slice 1 (walking skeleton)**: Slice 1 should extend an existing user-visible capability when research surfaces one — otherwise build a real walking skeleton.

### Validate the Backlog

Invoke `/thinking chain-of-thought` to check each slice against:

1. **INVEST + Vertical + Behavior-described** — every slice must pass all eight validity tests from the slicing skill
2. **Research grounding** — does each slice description reflect what research actually found? A slice claimed as "extending capability X" must cite the specific capability statement from research, not implementation detail
3. **Cross-slice references** — if a description or Value line points to another slice, it must use that slice's title in quotes, not its number and not the word "slice" (per the slicing skill's Cross-Slice References rule). Slices propagate downstream as standalone Jira/Linear stories where numbering and slice-jargon lose meaning. Reword any violation before showing the user.

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
- Top 3 capability adjacencies (existing capabilities slices extend)
- Top 3 net-new capabilities (introduced by the epic)
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

If every research target comes back empty, the system has no relevant existing capabilities (no docs and no entry points found). Note this explicitly in the artifact's Research Summary and proceed — slices will be heavier and slice 1 will require a real walking-skeleton build, not a thin extension of an existing capability.

### Slice backlog never converges

If the user rejects the backlog three times in a row with conflicting feedback, stop and ask: "The slicing keeps shifting. Is the epic itself too broad? Should we split it into multiple epics first?" Do not keep re-slicing in a loop.
