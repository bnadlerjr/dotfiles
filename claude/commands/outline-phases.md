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
- When a tracer is warranted (see tracer-check below), ALL phases follow slice-validity rules from `slicing-elephant-carpaccio` — vertical, working, distinct, valuable, small. Phase 1 is the walking skeleton; Phases 2..N keep crossing layers while broadening coverage. Hard-coded values are acceptable in the tracer; later phases replace them. Non-vertical phases (data migrations, infra setup) are allowed only with explicit justification.

## Workflow

1. **Load design documents**
   - Read ALL documents in DESIGN_PATHS completely — do not skim
   - Extract: desired end state, current state, components, design decisions,
     scope boundaries

2. **Assess tracer-bullet applicability** — before decomposing, decide whether
   Phase 1 should be a tracer bullet (end-to-end walking skeleton):

   <tracer-check>
   - **Warranted when**: work introduces unproven integration across layers
     (new feature spanning UI/service/data, new external service, new
     deployment target, first use of a library/pattern in this codebase)
   - **Not warranted when**: pure refactor, bug fix, single-module change,
     or the integration seams are already proven by existing code
   - Check the upstream design doc for a **Candidate tracer path** — if
     `/align-understanding` named one, start from it
   - If warranted:
     - Phase 1 MUST be a tracer: the thinnest end-to-end path that proves
       the architecture connects, shipped as production code (not a
       throwaway prototype)
     - Phases 2..N MUST follow slice-validity rules from
       `slicing-elephant-carpaccio` (vertical, working, distinct, valuable,
       small) — each continues to cross layers, broadening coverage or
       replacing hard-coded values from the tracer
     - Non-vertical phases (data migrations, infra setup that must precede
       user-visible work) are allowed only with explicit justification
       recorded in that phase's rationale
   - Tell the user your decision and one-sentence rationale before
     proceeding
   </tracer-check>

3. **Decompose into phases** — apply `/thinking skeleton-of-thought`:
   - If a tracer is warranted, Phase 1 is the tracer and Phases 2..N are
     vertical slices per the tracer-check rules — each keeps crossing
     layers to broaden coverage or replace hard-coded values. Flag any
     non-vertical phase with its justification.
   - Identify the minimal ordered sequence of changes
   - Each phase gets its own success criteria
   - Each phase has a clear dependency chain
   - Optimize for: independent verifiability, safe stopping points,
     single-session scope

4. **Assess risk per phase** — apply `/thinking pre-mortem`:
   - Flag phases with high complexity or uncertainty
   - Note phases that touch shared interfaces or data
   - Identify phases where requirements are ambiguous

5. **Present the outline** — deliver using the report format below.
   STOP and wait for the user's response.

6. **Iterate until approved**

   <revision-loop>
   - If the user wants to reorder phases, reorder and re-present
   - If the user wants to split a phase, split and re-present
   - If the user wants to merge phases, merge and re-present
   - If the user corrects scope or dependencies, update and re-present
   - After each revision, STOP and wait for approval
   </revision-loop>

7. **Save artifact**
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
