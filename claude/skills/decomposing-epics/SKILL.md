---
name: decomposing-epics
description: "Breaks an epic into an ordered backlog of vertical, sprint-sized user stories. Use when splitting an epic into stories, planning a feature's story backlog, or when a story feels too large but isn't ready for task breakdown. Produces 4-8 demoable stories, each independently shippable and grounded in user-visible behavior. NOT for sub-story implementation slicing (see slicing-elephant-carpaccio) or for writing one story's full BDD spec (see writing-agile-stories)."
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
---

# Decomposing Epics

## Objective

Break an epic into an ordered backlog of **vertical, sprint-sized user stories** — each cutting through whatever layers it needs to deliver one coherent, demoable change in what users can see or do. Decomposition decisions are based on the business situation, not the technology. The output is an ordered story backlog, not implementation tasks and not sub-story slices.

This is a **non-interactive reference skill**. Callers — direct users, orchestrator commands, and sub-agents — supply context and apply this guidance directly. Do not use `AskUserQuestion`. If the user-visible scope is thin, ask the user in plain prose for what's missing.

## Granularity: This Skill's Whole Point

A **story** is the unit here, and a story is bigger than a carpaccio slice and smaller than an epic:

| Unit | Size | Owner | Skill |
|------|------|-------|-------|
| Epic | Weeks; many behaviors | Product | (input to this skill) |
| **Story** | **One coherent demoable behavior; ~1-3 days / fits a sprint** | **This skill** | **decomposing-epics** |
| Slice | A demo increment within a story; minutes-to-hours | Dev, during build | slicing-elephant-carpaccio |
| Task | A construction step with no standalone user value | Dev | (not a backlog item) |

Most over-decomposition comes from confusing these. If you produce items sized in minutes-to-hours, or items that hard-code a value now and "generalize it later" as a *separate* item, or items that split a behavior from its inseparable validation — you have produced **slices, not stories**. Merge up. Sub-story slicing is a real technique, but it belongs to `slicing-elephant-carpaccio` during implementation, not to an epic's story backlog.

## When to Use

- Splitting an epic or large feature into deliverable stories
- Building the ordered story backlog for a feature before any single story is refined
- A story feels too large but isn't ready for task decomposition

Do NOT use this to write the full BDD spec for one story (use `writing-agile-stories`) or to slice a single story into demo increments during a build (use `slicing-elephant-carpaccio`).

## Workflow

```
Understand Behavior Scope  -->  Produce Story Backlog
What users see/do today        Ordered sprint-sized stories
```

**Step 1: Understand the Behavior Scope**

If the caller has already supplied behavior context (a wrapping command, a prior research artifact), confirm the supplied scope and skip to Step 2. Otherwise establish, from the epic description and any linked product documentation (PRDs, READMEs, ADRs about user-facing capabilities):

- What users can currently see or do in this domain
- What the epic changes from the user's point of view
- The domain vocabulary the business uses for these concepts

Ask the user in plain prose if the user-visible scope is ambiguous.

Do NOT read implementation code, identify components/layers/integration points, or invoke deep-code agents (e.g., `codebase-analyzer`) at this step. Decomposition operates on behavior; implementation knowledge belongs in planning, not story breakdown. When supplied context is thin, prefer in this order: (1) ask the user in plain prose; (2) read product documentation (PRDs, READMEs, user-facing docs); (3) use the `capability-locator` agent to inventory existing user-facing entry points (routes, pages, CLI commands, public APIs) at the capability level — never at the implementation level. If all you have is code-level context, push back to the caller for behavior-level input rather than reverse-engineering behavior from implementation.

**Step 2: Produce the Story Backlog**

Create a numbered, ordered list of stories. Each story gets a one-line behavior description and a note on what value it delivers.

Aim for **4-8 stories** for a typical epic. Fewer than 3 may mean the work isn't really an epic — it might be a single story. More than ~12 usually means the epic itself is too broad and should be split into multiple epics first. Treat counts outside that band as a sizing signal to surface, not a backlog to force.

**Story Validity Rules**

Every story MUST pass ALL eight tests: Vertical (Cockburn), the six INVEST criteria (Wake), and a Behavior-described check.

- **Vertical** — Cuts from a user-visible action through whatever supports it, end to end. Not one internal layer in isolation.
- **Independent** — The system could ship after this story without requiring any later story. Post-story state is coherent and demoable.
- **Negotiable** — Can be reordered, deferred, or dropped without breaking earlier stories in the backlog.
- **Valuable** — Delivers user-visible value or risk reduction a stakeholder can see or benefit from.
- **Estimable & Sprint-sized** — Scope is concrete and fits roughly **1-3 days / one sprint as one coherent behavior**, not minutes-to-hours. If it's larger than a sprint, split it (see heuristics). If it's a step with no standalone user value, or sized in minutes, **merge it up** into the behavior it serves — that's a slice or a task, not a story.
- **Testable** — Has verifiable acceptance criteria; the behavior can be demonstrated when the story lands.
- **Behavior-described** — Names a change in what users can *see* or *do*, not how the system is *built*. Verbs like *cache, validate, persist, migrate, refactor, integrate, decouple, normalize* and nouns like *schema, table, endpoint, middleware, service, layer* indicate construction, not behavior. Re-describe.

**A story keeps its essential validation.** Unlike sub-story slicing, do NOT split a happy path from the validation and error handling that make it a coherent, shippable behavior. "User exports the visible user list as CSV" includes handling an empty list — that is one story. Split an edge case into its own story only when it is independently valuable, separately demoable, or large enough to stand alone.

**Ordering Principles**

- **Story 1 is always end-to-end** — either a walking skeleton (greenfield: thinnest real path through all layers, hard-coded values OK *within* this first story) or the thinnest extension of an existing user-visible capability (brownfield). Its value is risk reduction — proving the path connects.
- Core happy-path behaviors next, ordered by value — the highest-value coherent behavior first.
- Legal/compliance requirements before nice-to-haves.
- All core behaviors before any single one is polished.
- Substantial, independently valuable error/edge-case handling later (essential validation stays inside its parent story — see above).
- UI polish and optimization last.

**Splitting Heuristics**

When a story is larger than a sprint, split it using these patterns:

| Heuristic | Strategy |
|-----------|----------|
| **By workflow path** | One complete user flow end-to-end before the next |
| **By data variation** | One data type or category as a coherent story; add other categories as separate stories |
| **By business rule** | Simplest complete rule first; materially different rules as later stories |
| **By interface** | One platform, device, or UI variant first; others as later stories |
| **By user role** | One actor's complete flow first; other roles as later stories |
| **Simple before complex** | All core behaviors shipped before standalone edge-case stories |

Each fragment must independently pass all eight validity tests. If a "split" produces a piece with no standalone user value, you've split below story altitude — merge it back.

## Anti-Patterns

If you catch yourself producing any of these, re-decompose:

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| **Stories sized in minutes-to-hours** | That's a slice or task. A story is one coherent demoable behavior, ~1-3 days. Merge up. |
| **Hardcode-now / generalize-later as separate stories** | Sub-story sequencing. Hard-coding is fine *within* the walking skeleton; "replace the literal with real logic" is not its own story. |
| **Splitting a behavior from its essential validation** | "Export CSV" and "handle empty list on export" are one story, not two. Over-splitting validation is the most common too-small symptom. |
| **Horizontal stories** | Backend-only or frontend-only chunks deliver no user-visible value until something later integrates them. |
| **Splitting by technical layer or service boundary** | "All endpoints, then all UI" is horizontal in disguise. Split on business value, not architecture. |
| **Task decomposition as stories** | "Set up the database", "write the migration" are tasks within a story, not backlog items. Each story has user-visible value. |
| **Cross-referencing by number or "story N"** | Numbers break when the backlog reorders and lose meaning when a story propagates downstream as a standalone ticket. Reference other stories by title in quotes — see Cross-Story References. |

## Examples

Epic: *Let users export and share their saved reports.*

**Too small (a slice, not a story)** — "User clicks Export and downloads a CSV with hard-coded columns name and email" followed by a separate "Generalize the export to include all visible columns."
These are two carpaccio slices of one behavior. As backlog stories they fragment a single coherent capability and trip the minutes-to-hours and hardcode-then-generalize anti-patterns.

**Right altitude (rewritten as one story)** — "User exports the currently visible report as a CSV containing all columns shown on screen, including when the report is empty."
Passes all eight tests: vertical (action through to download), independent (ships standalone), valuable (a real, complete export exists), estimable/sprint-sized (one coherent behavior, ~1-2 days), testable (file downloads with the visible columns; empty report handled), behavior-described (what the user does and sees). Essential validation (empty report) stays inside the story.

**A sibling story, correctly separate** — "User shares a saved report with a teammate by email, and the teammate opens a read-only view."
Independently valuable and separately demoable — a distinct behavior, so a distinct story, ordered after the core export behaviors.

## Output Format

Present the backlog as a numbered list:

```markdown
## Story Backlog: [Epic Name]

1. **Walking skeleton** — [thinnest real end-to-end behavior].
   Value: Proves the path connects end-to-end.

2. **[Story name]** — [one-line description of what users can now see or do].
   Value: [what a stakeholder can now see or benefit from].

3. ...
```

### Cross-Story References

When a story description or Value line must point to another story in the backlog, refer to it by its title in quotes — never by number, and never with the word "story" or "slice". Stories propagate downstream as standalone Jira/Linear tickets where sibling numbering and backlog jargon are absent; a description that depends on either becomes incomprehensible the moment it is lifted out of the backlog.

- Good: *"Extends 'User exports the visible report as CSV' so the export can be scheduled to recur."*
- Bad: *"Extends story 2."*
- Bad: *"Builds on the previous story."*

The numbered ordering remains in the artifact for human readers; the rule applies only to *prose references* inside descriptions and Value lines, which travel with the story when it becomes a ticket.

## Relationship to Adjacent Skills

- **slicing-elephant-carpaccio** — the same intellectual core (vertical, behavior-described, INVEST, walking skeleton, value-ordered) at a *smaller* unit. Carpaccio produces minutes-to-hours demo increments *within a story during implementation*. Use it when building a story, not when decomposing an epic.
- **writing-agile-stories** — the *downstream* skill. This skill produces the ordered set of story stubs; `writing-agile-stories` turns one stub into a full narrative + Given-When-Then spec. Each backlog item here is an input to that skill.

## Success Criteria

The skill has been applied successfully when:

- [ ] The backlog is an ordered list of sprint-sized stories (typically 4-8; counts outside that range are surfaced as an epic-sizing signal)
- [ ] Story 1 is end-to-end — a walking skeleton (greenfield) or the thinnest extension of an existing capability (brownfield)
- [ ] Every story passes all eight validity tests: Vertical + INVEST (Independent, Negotiable, Valuable, Estimable & Sprint-sized, Testable) + Behavior-described
- [ ] No item is sized in minutes-to-hours, splits a behavior from its essential validation, or is pure task/slice decomposition
- [ ] Decomposition decisions are grounded in business value, not technology or architecture
