---
name: slicing-elephant-carpaccio
description: "Breaks features into ultra-thin vertical slices using Alistair Cockburn's Elephant Carpaccio methodology. Use when planning new features, breaking down epics, slicing work across layers, or when a story feels too large. Produces an ordered backlog of 10-20 thin slices, each independently working, testable, and demoable."
allowed-tools:
  - AskUserQuestion
  - Read
  - Glob
  - Grep
  - Task
---

# Slicing Elephant Carpaccio

<objective>
Break features into the thinnest possible vertical slices — each one cutting across all necessary layers (UI, logic, data) to produce an independently working, testable, demoable increment. Slicing decisions are based on the business situation, not the technology. The output is an ordered slice backlog, not implementation.
</objective>

<context>
Carpaccio methodology and walking-skeleton concept: Alistair Cockburn (Crystal Clear 2004; Carpaccio exercise 2013). INVEST: Bill Wake (2003). Story-splitting heuristics overlap with Richard Lawrence's "Patterns for Splitting User Stories."
</context>

<quick_start>
Given a feature description, produce an ordered list of 10-20 thin vertical slices:

```markdown
## Slice Backlog: [Feature Name]

1. **Walking skeleton** — [thinnest end-to-end path].
   Value: Proves the path connects end-to-end.

2. **[Next slice]** — [one-line description of what changes].
   Value: [what a stakeholder can now see or do].

3. ...
```
</quick_start>

<when_to_use>
- Planning a new feature that spans multiple layers or components
- Breaking down an epic or large story into deliverable increments
- User asks to "slice", "thin-slice", or "carpaccio" a feature
- A story feels too large but isn't ready for task decomposition yet
</when_to_use>

<workflow>
```
Understand Scope  -->  Produce Slice Backlog
Components/layers      Ordered thin slices
```

**Step 1: Understand the Full Feature Scope**

Read all relevant files, specs, and existing code. Identify every component, layer, and integration point involved. Ask clarifying questions if the scope is ambiguous.

Use the `codebase-navigator` agent to find relevant files and entry points when the feature touches existing code.

**Step 2: Produce the Slice Backlog**

Create a numbered, ordered list of 10-20 slices. Each slice gets a one-line description and a note on what value it delivers.

**Slice Validity Rules**

Every slice MUST pass ALL of these tests — Cockburn's verticality plus the six INVEST criteria (Wake). A slice that fails any one is not a slice; it's a task or an architecture step in disguise.

- **Vertical** — Cuts through all necessary layers (UI, logic, data), not just one in isolation.
- **Independent** — The system could ship after this slice without requiring any later slice. Post-slice state is coherent and demoable.
- **Negotiable** — Can be reordered, deferred, or dropped without breaking earlier slices in the backlog.
- **Valuable** — Delivers more user-visible value or risk reduction than the previous slice. A stakeholder can see or benefit from the change.
- **Estimable** — Scope is concrete enough to size in minutes-to-hours, not days.
- **Small** — Implementable in a single focused coding pass.
- **Testable** — Has verifiable acceptance criteria; tests pass after the slice lands.

**Ordering Principles**

- **Slice 1 is always a walking skeleton** — the thinnest possible end-to-end path. Hard-code values if needed. Its value is pure risk reduction.
- Core happy-path functionality comes next, one thin business-rule increment at a time.
- Prefer simpler implementations that deliver value faster (e.g., accept user input directly before building lookup tables).
- Legal/compliance requirements before nice-to-haves.
- All core paths before any single path is polished.
- Validation, error handling, and edge cases LAST.
- UI polish and optimization LAST.

**Slicing Heuristics**

When a slice feels too large, split it further using these patterns:

| Heuristic | Strategy |
|-----------|----------|
| **By workflow path** | One user flow end-to-end before the next |
| **By data variation** | Start with one data type or category, add others as separate slices |
| **By business rule** | Simplest rule first, add complexity in later slices |
| **By interface** | One platform, device, or UI variant first |
| **Simple before complex** | Happy path across all paths before edge cases on any single path |
| **Hardcode then generalize** | Hardcode a value in slice N, replace with dynamic logic in slice N+1 |

</workflow>

<anti_patterns>
If you catch yourself producing any of these, re-slice:

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| **Horizontal slices** | Backend-only or frontend-only chunks deliver no user-visible value until a later slice integrates them |
| **Slicing by technical layer or service boundary** | "All endpoints, then all UI" is horizontal slicing in disguise. Slice on business value, not architecture. |
| **Gold-plating early slices** | Adding validation/error handling/polish to slice 2 when core paths in slices 8-12 don't exist yet |
| **Speculative infrastructure** | Abstractions or frameworks beyond what the current slice requires |
| **Task decomposition as slices** | "Set up the database" and "write the migration" are tasks within a slice, not slices themselves — each slice must have user-visible value |
</anti_patterns>

<output_format>
Present the backlog as a numbered list:

```markdown
## Slice Backlog: [Feature Name]

1. **Walking skeleton** — [thinnest end-to-end path].
   Value: Proves the path connects end-to-end.

2. **[Slice name]** — [one-line description of what changes].
   Value: [what a stakeholder can now see or do].

3. ...
```
</output_format>

<confirmation>
After presenting the backlog, ask the user to confirm or adjust before any implementation begins.

Use **AskUserQuestion**:
- Header: "Slice backlog"
- Question: "Does this slice ordering look right?"
- Options: "Looks good" | "Adjust ordering" | "Slices too thick — split further" | "Slices too thin — combine some"

If running as a sub-agent without user access, present the backlog and proceed without confirmation.
</confirmation>

<success_criteria>
The skill has been applied successfully when:

- [ ] The backlog contains 10-20 numbered, ordered slices
- [ ] Slice 1 is a walking skeleton — the thinnest end-to-end path
- [ ] Every slice passes all seven validity tests: Vertical + INVEST (Independent, Negotiable, Valuable, Estimable, Small, Testable)
- [ ] No slice is a horizontal chunk (backend-only or frontend-only) or pure task decomposition
- [ ] Slicing decisions are grounded in business value, not technology or architecture
- [ ] The user has confirmed the ordering before any implementation begins
</success_criteria>
