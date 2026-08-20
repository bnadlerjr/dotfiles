---
description: Decompose an epic into an ordered backlog of vertical, sprint-sized stories.
argument-hint: "[epic description]"
---

# Epic to Stories

Turns an epic into an ordered backlog of vertical, sprint-sized stories, each grounded in what users can already see or do. Every story is later refinable into a full BDD spec on its own.

**How review works.** This command drives no browser. It emits each draft as a bare assistant message and stops. The user reviews that message with `/annotate-last`, and the annotations come back into the session as feedback, which drives the next draft. The loop ends when the user approves. This note is for whoever opens this file. Do not repeat it to the user.

## Rules

1. **Story altitude is fixed.** A story is one coherent demoable behavior, about 1-3 days of work. The units above and below it are someone else's job.

| Unit | Size | Belongs to |
|---|---|---|
| Epic | Weeks, many behaviors | the input to this command |
| **Story** | **One coherent demoable behavior, ~1-3 days** | **this command's output** |
| Slice | A demo increment inside one story, minutes to hours | the developer, during the build |
| Task | A construction step with no standalone user value | the developer, and never a backlog item |

Most over-decomposition comes from confusing these. An item sized in minutes-to-hours is a slice, not a story. Merge it up.

2. **Every story passes all eight tests.** Vertical (Cockburn), the six INVEST criteria (Wake), and a behavior check.

   - **Vertical.** Cuts from a user-visible action through whatever supports it, end to end. Never one internal layer alone.
   - **Independent.** The system could ship after this story and need no later one. The state it leaves is coherent and demoable.
   - **Negotiable.** Can be reordered, deferred, or dropped without breaking an earlier story.
   - **Valuable.** Delivers user-visible value or risk reduction a stakeholder can see.
   - **Estimable and sprint-sized.** Concrete scope, one coherent behavior, roughly 1-3 days. Larger, split it. Smaller, or no standalone user value, merge it up.
   - **Testable.** Has verifiable acceptance criteria and can be demonstrated the day it lands.
   - **Behavior-described.** Names a change in what users see or do, not how the system is built. The verbs *cache, validate, persist, migrate, refactor, integrate, decouple, normalize* and the nouns *schema, table, endpoint, middleware, service, layer* describe construction. Re-describe.

3. **Story 1 is always end-to-end.** When research surfaced a real capability to extend, story 1 is the thinnest extension of it. When research surfaced nothing, story 1 is a walking skeleton: the thinnest real path through every layer the behavior needs, hard-coded values allowed inside this one story. Its value is risk reduction, proving the path connects.

4. **A story keeps its essential validation.** "User exports the visible report as CSV" includes the empty report. Do not split a happy path from the validation that makes it coherent and shippable. Split an edge case out only when it is independently valuable, separately demoable, or big enough to stand alone.

   Below story altitude, inside one story while building it, the opposite rules hold: hard-coding a value first and deferring polish are correct there, and an increment of a few minutes is legitimate. Across a backlog they are not. A story keeps its validation, and "replace the literal with real logic" is not its own story. Same technique, different unit.

5. **Prefer the simpler thing that delivers value sooner.** Accept a typed-in value before building the lookup that derives it. The simpler version is a real story; the derivation is a later one.

6. **Cross-story references use the quoted title.** Never a number, never "the previous story", never the word "slice". A story travels downstream as a standalone ticket where sibling numbering and backlog jargon are absent, and a description that leans on either stops making sense the moment it is lifted out.

   - Good: *"Extends 'User exports the visible report as CSV' so the export can recur on a schedule."*
   - Bad: *"Extends story 2."* / *"Builds on the previous story."*

   The numbering stays in the backlog for human readers. The rule governs prose inside descriptions and Value lines, which is what travels.

7. **Never ask a naked question.** Every question, in Phase 1 or in Open Questions, carries a committed recommendation and the reasoning behind it. A bare "what should we do about X?" pushes the work back onto the user.

8. **A draft message contains the backlog and nothing else.** First character is the `#` of the title, last character is the end of the final Open Question. No preamble, no sign-off, no explanation of the workflow.

## Phase 1. Read the epic

`$ARGUMENTS` is the epic. It is prose, not a reference to fetch: no tracker lookup, no file path routing.

If it is empty, ask what the epic covers and wait. Do not research an epic you do not have.

Otherwise read it and settle three things for yourself: the epic's title, what it changes from the user's point of view, and the vocabulary it uses for the domain. Do not emit this reading as a message. Phase 3's Grounding section is where the user sees your reading of the epic and corrects it.

## Phase 2. Ground in existing behavior

A story backlog is only as good as its grasp of what already exists. Story 1 in particular cannot be "the thinnest extension of an existing capability" unless you know which capabilities exist.

Derive 3-7 independent research questions from the epic. Each names a concrete user-facing behavior or domain concept the system might already support, framed in user-visible terms:

- "What can users see or do today related to `<concept>`?"
- "What user-facing vocabulary does the product use for `<data type>`?"

Reject any question framed in implementation language, by the same behavior test the stories answer to.

### Dispatch

Where the host supports parallel agents, send each question to a general-purpose agent as a self-contained brief, all in one batch, and wait for every one to return. Where it does not, work the same briefs yourself, in order. The brief is the contract either way, and nothing in it depends on the identity of a named agent.

Repositories default to the working directory. Do not ask. If the scope is genuinely ambiguous, commit to the working directory and say so in Open Questions.

```markdown
# Behavior-surface research

Describe what users can currently see or do in this domain. Never describe how it is built.

## Epic

<epic context>

## Question

<one research question>

## How to research

Read product documentation first — PRDs, READMEs, ADRs about user-facing capabilities. Docs are
written in user language, so the translation distance to behavior is zero. Where docs are sparse,
inventory entry points only: routes, pages, screens, CLI commands, public APIs. Report what they
let a user do.

Never open implementation code. Never report a file path, line number, function or class name,
schema, service, or pattern. If you find yourself describing how something is built, stop and
re-frame to what a user observes. Document only what exists today. Do not propose changes.

## Report

**Existing capabilities** — one line each, as "A user can <verb> <noun> <conditions>".
**Domain vocabulary** — the canonical user-facing terms for these concepts.
**Capability gaps** — what users cannot yet do that this epic would let them do.
**Adjacent capabilities** — related capabilities outside this epic but inside its vocabulary.
```

### Consolidate

Merge the returns into three buckets:

- **Capability adjacencies** — existing capabilities a story can extend or compose. These are the candidates for story 1.
- **Net-new capabilities** — what the epic introduces with no behavioral precedent. Stories here are heavier, and if every bucket entry lands here, story 1 must be a real walking skeleton.
- **Domain glossary** — the canonical terms to use in story descriptions, and the ones to avoid.

If every question comes back empty, the system has no relevant capabilities today. Say so in Grounding and carry on. That is a finding, not a failure.

## Phase 3. Decompose and draft

Work in this order. Do not reorder it.

1. **State the behavior delta.** What users can do after the epic that they cannot do now, in the glossary's words.
2. **Place story 1.** A thin extension of a named adjacency, or a walking skeleton. Rule 3 decides which.
3. **Order the rest.** Core happy-path behaviors next, highest value first. Legal and compliance work before nice-to-haves. Every core behavior before any one of them is polished. Substantial, independently valuable edge-case handling later. UI polish and optimization last.
4. **Check the count.** Aim for 4-8 stories. Under 3 suggests the epic is really one story. Over about 12 suggests the epic is too broad and should be split into several epics first. A count outside the band is a sizing signal to surface, not a backlog to force.
5. **Split what overflows a sprint**, then re-test every fragment against all eight tests. A fragment with no standalone user value means you split below story altitude. Merge it back.

| Splitting heuristic | Strategy |
|---|---|
| By workflow path | One complete user flow end to end before the next |
| By data variation | One data type or category as a coherent story, other categories later |
| By business rule | The simplest complete rule first, materially different rules later |
| By interface | One platform, device, or UI variant first, others later |
| By user role | One actor's complete flow first, other roles later |
| Simple before complex | Every core behavior shipped before any standalone edge-case story |

| Anti-pattern | Why it is wrong |
|---|---|
| Items sized in minutes-to-hours | That is a slice or a task. Merge up. |
| Hardcode now, generalize later, as two stories | Sub-story sequencing. Hard-coding belongs inside the walking skeleton, and replacing the literal is not its own story. |
| Splitting a behavior from its essential validation | "Export CSV" and "handle the empty list" are one story. The most common too-small symptom. |
| Horizontal stories | Backend-only or frontend-only chunks deliver nothing a user can see until something later integrates them. |
| Splitting by technical layer or service boundary | "All endpoints, then all UI" is horizontal in disguise. Split on business value, not architecture. |
| Task decomposition as stories | "Set up the database" is a step inside a story, not a backlog item. |
| Gold-plating early stories | Polish on story 2 while core behaviors are still missing. |
| Speculative infrastructure | Abstraction beyond what the story in hand needs. |
| Referring to a story by number | Numbering breaks on reorder and vanishes when the story becomes a ticket. See Rule 6. |

**Too small, and why.** *"User clicks Export and downloads a CSV with hard-coded columns name and email"*, followed by *"Generalize the export to include all visible columns"*. These are two slices of one behavior. As backlog items they fragment a single capability and trip both the minutes-to-hours and the hardcode-then-generalize anti-patterns.

**The same work at story altitude.** *"User exports the currently visible report as a CSV containing every column shown on screen, including when the report is empty."* Vertical, independent, valuable, sprint-sized, testable, and described by behavior, with its essential validation kept inside.

Then write the draft.

```markdown
# Story Backlog: <Epic Title>

## Grounding

<3-6 bullets. What the epic changes for users, which existing capabilities the backlog
 extends, and what is net-new. Short. This exists so the user can correct a wrong premise
 before arguing about ordering.>

## Stories

1. **<name>** — <one line: what users can now see or do>.
   Value: <what a stakeholder can now see or benefit from>.

## Domain Glossary

<canonical user-facing terms, and what to use instead of what>

## Open Questions

- **<Topic>.** Assuming <the position this draft already commits to>. Annotate if wrong.
```

Each Open Question states a position the draft already takes, so the user attacks a claim instead of answering a survey. This is the stress test. The draft takes the risk of being wrong in public rather than interrogating the user before they have seen anything.

## Phase 4. Review loop

Emit the draft as the whole message, per Rule 8, and stop the turn.

When feedback returns to the session, branch on it.

| What returns | Action |
|---|---|
| Annotation feedback | Revise against it, re-emit the full backlog as a bare message, stop again. This is the loop |
| Approved | Go to Phase 5 |
| Dismissed | Say the session closed. Stop |

There is no round cap. Every round ends the turn, so the user sets the pace and the exit.

When annotations across rounds contradict each other — stories too big, then too small, then reordered back — stop absorbing it silently. The epic itself may be too broad. Put that in the next draft's Open Questions with a committed recommendation, per Rule 7.

## Phase 5. Retire the scaffold

`## Open Questions` is a review instrument, not part of a backlog. Approval settles the shape, and the scaffold comes off.

Fold each unresolved question into the one story it blocks, as an `Unresolved:` line under that story. It then travels with the story when the story becomes a ticket, which is the only place it stays useful. Keep a backlog-wide item at the bottom only when it truly blocks the whole backlog rather than one story.

Then delete the `## Open Questions` heading and emit the backlog one last time as a bare message. Stop there.

## Self-check

Run before emitting any draft.

- Story 1 is end-to-end, and Rule 3 picked its form from what research actually found
- No item is sized in minutes-to-hours
- No behavior is split from its essential validation
- Every story passes all eight tests
- Every cross-story reference is a quoted title
- The count is 4-8, or the deviation is stated as a sizing signal
- Every Open Question carries a committed recommendation
- The message contains the backlog and nothing else

On the Phase 5 emit, add one more: no `## Open Questions` section remains.
