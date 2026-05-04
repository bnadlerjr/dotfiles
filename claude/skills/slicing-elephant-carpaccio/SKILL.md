---
name: slicing-elephant-carpaccio
description: "Breaks features into ultra-thin vertical slices using Alistair Cockburn's Elephant Carpaccio methodology. Use when planning new features, breaking down epics, slicing work across layers, or when a story feels too large. Produces an ordered backlog of 10-20 thin slices, each independently working, testable, and demoable."
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
---

# Slicing Elephant Carpaccio

## Objective

Break features into the thinnest possible vertical slices — each one cutting across all necessary layers (UI, logic, data) to produce an independently working, testable, demoable increment. Slicing decisions are based on the business situation, not the technology. The output is an ordered slice backlog, not implementation.

## When to Use

- Planning a new feature that spans multiple layers or components
- Breaking down an epic or large story into deliverable increments
- User asks to "slice", "thin-slice", or "carpaccio" a feature
- A story feels too large but isn't ready for task decomposition yet

## Workflow

```
Understand Behavior Scope  -->  Produce Slice Backlog
What users see/do today        Ordered thin slices
```

**Step 1: Understand the Behavior Scope**

If the caller has already supplied behavior context (a wrapping command, a prior research artifact), confirm the supplied scope and skip ahead to Step 2. Otherwise, read the feature description and any linked product documentation (PRDs, READMEs, ADRs about user-facing capabilities). Establish:

- What users can currently see or do in this domain
- What the feature changes from the user's point of view
- The domain vocabulary the business uses for these concepts

Ask clarifying questions if the user-visible scope is ambiguous.

Do NOT read implementation code, identify components/layers/integration points, or invoke deep-code agents (e.g., `codebase-analyzer`) at this step. Slicing operates on behavior; implementation knowledge belongs in planning, not slicing.

When product documentation is sparse, use the `capability-locator` agent to inventory existing user-facing entry points (routes, pages, CLI commands, public APIs) at the capability level — never at the implementation level.

**Step 2: Produce the Slice Backlog**

Create a numbered, ordered list of slices. Each slice gets a one-line description and a note on what value it delivers.

Aim for 10-20 slices for typical features. If a feature naturally yields fewer than 6 or more than 25, treat that as a signal to surface — the feature itself may be mis-sized (too small to need carpaccio, or too large and should be split into multiple features first).

**Slice Validity Rules**

Every slice MUST pass ALL eight tests below: Vertical (Cockburn), the six INVEST criteria (Wake), and a Behavior-described check.

- **Vertical** — Cuts from a user-visible action through whatever supports it, end to end. Not just one internal piece in isolation.
- **Independent** — The system could ship after this slice without requiring any later slice. Post-slice state is coherent and demoable.
- **Negotiable** — Can be reordered, deferred, or dropped without breaking earlier slices in the backlog.
- **Valuable** — Delivers more user-visible value or risk reduction than the previous slice. A stakeholder can see or benefit from the change.
- **Estimable & Small** — Scope is concrete; sizes in minutes-to-hours, fits one focused coding session (hours, not days). If it doesn't, split it using the heuristics below.
- **Testable** — Has verifiable acceptance criteria; tests pass after the slice lands.
- **Behavior-described** — The slice description names a change in what users can *see* or *do*, not a change in how the system is *built*. Verbs like *cache, validate, persist, migrate, refactor, integrate, decouple, normalize* and nouns like *schema, table, endpoint, middleware, service, layer* indicate the slice is described by construction, not by behavior. Re-slice.

**Ordering Principles**

- **Slice 1 is always end-to-end** — either a walking skeleton (greenfield — thinnest possible path through all layers, hard-coded values OK) or the thinnest extension of an existing user-visible capability (brownfield). Its value is risk reduction — proving the path connects.
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

## Anti-Patterns

If you catch yourself producing any of these, re-slice:

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| **Horizontal slices** | Backend-only or frontend-only chunks deliver no user-visible value until a later slice integrates them |
| **Slicing by technical layer or service boundary** | "All endpoints, then all UI" is horizontal slicing in disguise. Slice on business value, not architecture. |
| **Gold-plating early slices** | Adding validation/error handling/polish to slice 2 when core paths in slices 8-12 don't exist yet |
| **Speculative infrastructure** | Abstractions or frameworks beyond what the current slice requires |
| **Task decomposition as slices** | "Set up the database" and "write the migration" are tasks within a slice, not slices themselves — each slice must have user-visible value |

## Examples

Feature: *Add CSV export to user list.*

**Bad slice** — "Build CSV serializer module."
Fails the Behavior-described test. The description names a construction artifact (a module), not a change to what users can see or do. A stakeholder cannot demo a serializer in isolation; it delivers no user-visible value until something later wires it up. This is a task, not a slice.

**Good slice (rewritten)** — "User on /users page clicks Export and downloads a CSV containing hard-coded columns: name, email."
Passes all eight tests: vertical (UI button through to file download), independent (ships standalone), valuable (a real download exists), estimable/small (one session), testable (file downloads with two columns), and behavior-described (what the user does and sees). Hard-coded columns are fine — later slices generalize.

## Output Format

Present the backlog as a numbered list:

```markdown
## Slice Backlog: [Feature Name]

1. **Walking skeleton** — [thinnest end-to-end path].
   Value: Proves the path connects end-to-end.

2. **[Slice name]** — [one-line description of what changes].
   Value: [what a stakeholder can now see or do].

3. ...
```

## Success Criteria

The skill has been applied successfully when:

- [ ] The backlog is an ordered list of thin slices (typically 10-20; counts outside that range are surfaced as a feature-sizing signal)
- [ ] Slice 1 is end-to-end — a walking skeleton (greenfield) or the thinnest extension of an existing capability (brownfield)
- [ ] Every slice passes all eight validity tests: Vertical + INVEST (Independent, Negotiable, Valuable, Estimable & Small, Testable) + Behavior-described
- [ ] No slice is a horizontal chunk (backend-only or frontend-only) or pure task decomposition
- [ ] Slicing decisions are grounded in business value, not technology or architecture
