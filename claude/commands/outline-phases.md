---
description: Produce a phased structure outline for human approval before detailed planning
argument-hint: [path(s) to design document(s) from /align-understanding]
model: opus
---

# Outline Phases

Produce a phased structure outline — the skeleton that maps HOW to get from
the current state to the desired end state, broken into independently-verifiable
phases. Design says where we're going; this outline says how we get there.

Use the `thinking-patterns` skill for structured reasoning.

## Variables

DESIGN_PATHS: $ARGUMENTS
ARTIFACT_DIR: $CLAUDE_DOCS_ROOT/plans/

## Instructions

- If DESIGN_PATHS is empty, STOP and respond:
  "Usage: `/outline-phases <path-to-design-doc> [additional-paths...]`
  Run `/align-understanding` first to produce the design document(s)."
- Target ~2 pages maximum — this is a skeleton, not a plan
- Do NOT include code snippets — that's for /plan-implementation
- Do NOT include detailed file changes — that's for /plan-implementation
- DO name the files/components touched per phase (names only)
- DO make each phase independently verifiable
- Each phase must be completable in a single agent session
- Each phase must not break the system if you stop after completing it

## Workflow

1. **Load design documents**
   - Read ALL documents in DESIGN_PATHS completely — do not skim
   - Extract: desired end state, current state, components, design decisions,
     scope boundaries

2. **Decompose into phases** — apply `/thinking skeleton-of-thought`:
   - Identify the minimal ordered sequence of changes
   - Each phase gets its own success criteria
   - Each phase has a clear dependency chain
   - Optimize for: independent verifiability, safe stopping points,
     single-session scope

3. **Assess risk per phase** — apply `/thinking pre-mortem`:
   - Flag phases with high complexity or uncertainty
   - Note phases that touch shared interfaces or data
   - Identify phases where requirements are ambiguous

4. **Present the outline** — deliver using the report format below.
   STOP and wait for the user's response.

5. **Iterate until approved**

   <revision-loop>
   - If the user wants to reorder phases, reorder and re-present
   - If the user wants to split a phase, split and re-present
   - If the user wants to merge phases, merge and re-present
   - If the user corrects scope or dependencies, update and re-present
   - After each revision, STOP and wait for approval
   </revision-loop>

6. **Save artifact**
   - Check for existing artifacts: `ls $CLAUDE_DOCS_ROOT/plans/`
   - Read `$CLAUDE_DOCS_ROOT/projects.yaml` for project context
   - Save to `ARTIFACT_DIR/plan--<slug>-outline.md` with full frontmatter
     per artifact-management guidelines
   - Report the file path

## Report

Present the outline in this format:

> ## [Task Name] — Structure Outline
>
> [1-2 sentences: what this outline accomplishes and how many phases]
>
> ### Phase 1: [Descriptive Name]
>
> **Goal**: [One sentence]
> **Changes**: [Files/components — names only]
> **Depends on**: Nothing
> **Verification**:
> - Automated: [commands to run]
> - Manual: [what to test]
> **Risk**: Low / Medium / High — [brief rationale]
>
> ### Phase N: [Descriptive Name]
>
> [Same structure per phase]
>
> ### Sequencing Rationale
>
> Why this ordering? What would break if phases were reordered?

After approval, provide the artifact file path.
