---
description: Produce a design discussion document for human review
argument-hint: [path(s) to research document(s) from /explore-codebase]
model: opus
---

# Align Understanding

Synthesize research findings into a design discussion document — the critical
human review point before planning begins. This is where the human does "brain
surgery" on the agent's understanding: ~200 lines instead of 1,000.

Read and follow the progressive design methodology in the `collaborating-on-design`
skill: `~/dotfiles/claude/skills/collaborating-on-design/SKILL.md`

Use the `thinking-patterns` skill for structured reasoning at each section.

## Variables

RESEARCH_PATHS: $ARGUMENTS
ARTIFACT_DIR: $CLAUDE_DOCS_ROOT/research/

## Instructions

- If RESEARCH_PATHS is empty, STOP and respond:
  "Usage: `/align-understanding <path-to-research-doc> [additional-paths...]`
  Run `/explore-codebase` first to produce the research document(s)."
- Target ~200 lines for the design document — concise enough to review fully,
  complete enough that a fresh agent session could understand the task
- Do NOT include implementation details or code — that's for /plan-implementation
- Do NOT include phase breakdowns or sequencing — that's for /structure
- DO include enough context that the human can verify every claim and correct
  misunderstandings before any code is written
- If the user corrects anything, update the document and re-confirm that section
- Use mermaid diagrams where they aid understanding (see design skill references)

## Workflow

1. **Load research**
   - Read ALL documents in RESEARCH_PATHS completely — do not skim
   - Extract: findings, code references, patterns, architecture, open questions
   - Also extract: resolved decisions and scope boundaries (carried from upstream)

2. **Detect paradigm** — follow the design skill's paradigm detection:
   - Check project language files to determine OOP, FP, or Hybrid
   - Load the matching vocabulary reference from the design skill
   - Tell the user which paradigm was detected

3. **Calibrate depth** — assess complexity to determine which sections need detail:

   | Complexity | Sections to emphasize |
   |---|---|
   | Simple change | Current State, End State, Decisions, Scope |
   | Single component | Add: Patterns to Follow |
   | Multi-component feature | Add: Components, Key Interactions |
   | System integration | Full depth on all sections |

   Tell the user which depth level you're using and why.

4. **Walk through sections** — present each section, get explicit approval before
   advancing (following the design skill's checkpoint pattern):

   <section-walkthrough>
   a. **Current State** — use `atomic-thought` to decompose research findings.
      Present what exists with `file:line` references. Checkpoint: confirm.

   b. **Desired End State** — use `atomic-thought` to decompose requirements.
      Map to Level 1 Capabilities from the design skill — frame as behaviors
      (OOP) or data transformations (FP). Include verification criteria.
      Checkpoint: confirm.

   c. **Components & Patterns to Follow** — use `tree-of-thoughts` to evaluate
      which existing patterns to mirror. Map to Level 2 Components from the
      design skill. Name specific exemplar files. Challenge unnecessary
      abstractions. Checkpoint: confirm.
      SKIP if complexity is "simple change".

   d. **Key Interactions** — use `chain-of-thought` to trace scenarios through
      components. Map to Level 3 Interactions from the design skill. Include
      mermaid sequence diagrams for non-trivial flows. Identify a **candidate
      tracer path** — the thinnest scenario that exercises every layer touched
      by the desired end state, end-to-end. Name it explicitly so
      `/outline-phases` can evaluate whether Phase 1 should be a walking
      skeleton. Checkpoint: confirm.
      SKIP if complexity is below "multi-component feature".

   e. **Design Decisions** — use `graph-of-thoughts` to synthesize decisions
      from the questions step with new ones surfaced by research.
      Present as a table with Decision | Resolution | Rationale.
      Checkpoint: confirm.

   f. **Open Questions** — use `self-consistency` to verify nothing was missed.
      If any questions remain: STOP HERE and discuss until all are resolved.
      Do not proceed with unresolved questions.

   g. **What We're NOT Doing** — carry forward scope boundaries from the
      decisions artifact. Checkpoint: confirm.
   </section-walkthrough>

5. **Save artifact**
   - Check for existing artifacts: `ls $CLAUDE_DOCS_ROOT/research/`
   - Read `$CLAUDE_DOCS_ROOT/projects.yaml` for project context
   - Save to `ARTIFACT_DIR/research--<slug>-design.md` with full frontmatter
     per artifact-management guidelines

## Report

The artifact body uses these sections (include only sections that survived
complexity calibration):

```markdown
### [Task Name]

### Current State

What exists today. Pure facts with `file:line` references. How it currently
works. Key constraints or limitations discovered during research.

### Desired End State

Specific, verifiable description of "done" framed as capabilities. Verification
criteria — how to confirm completion and what observable behavior changes.

### Components & Patterns to Follow

Specific exemplar files to mirror:
- Implementation pattern: `path/to/exemplar.ext`
- Test pattern: `path/to/exemplar_test.ext`
- Naming convention: [with examples from codebase]

[Component diagram if multi-component]

### Key Interactions

How components communicate for key scenarios.
[Sequence diagram for non-trivial flows]

**Candidate tracer path**: [scenario name] — [layers/components touched end-to-end]. Feeds `/outline-phases` tracer-bullet applicability assessment.

### Design Decisions

| Decision | Resolution | Rationale |
|----------|------------|-----------|
| [From /question-me] | [Choice] | [Why] |
| [Surfaced by research] | [Choice] | [Why] |

### Open Questions

Resolved during walkthrough, or empty. If any remained, they were resolved
before this artifact was saved.

### What We're NOT Doing

Explicit scope boundaries carried forward from the decisions artifact.
```
