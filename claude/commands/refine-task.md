---
description: Refine a task overview into an implementation-focused technical task — the approach, the real code it touches, and a technical Done-when checklist. For work with no user-visible change — a refactor, test work, a dependency bump, building to a spec, or new machine-facing behavior.
argument-hint: "[task overview | empty for interactive]"
---

# Refine Task

Turns a task overview into an implementation task: a narrative and approach that name the real code being changed, and a Done-when checklist an engineer can verify without asking a follow-up question. It stops at the approach. Ordering the edits belongs to downstream planning.

## Rules

1. **Task altitude is fixed.** One change that lands and reverts as a unit. Work a user can see or do is a story and belongs in a different workflow. Several changes with different risk profiles are several tasks — a dependency bump and an architectural refactor fail and revert independently, so they never share a task.

2. **Name the real code, and commit to an approach.** The narrative and Approach name the modules, files, schemas, tables, endpoints, queues, and symbols the change touches, as research found them. Anything the task creates is marked `(new)` where it first appears; nothing else is named unless it exists today. The Approach states the chosen shape, its constraints, and the trade-off that decided it. It is not a plan: no numbered steps, no edit order. Downstream planning owns sequencing.

   - Bad: *1. Extract `verify/1` from `Legacy.Auth.SessionCheck`. 2. Point `RequireSession` at it. 3. Delete the old call.*
   - Good: *Move `verify/1` into `Accounts.SessionToken` (new), which `RequireSession` calls directly; `SessionCheck` stays as a one-line delegate until its last caller goes.*

3. **Criteria are outcomes, not edits.** Every Done-when item is something that is true afterward and can be checked: a response, an emitted event, a row, a passing test, a command's output. An item that describes a change to the code is a plan step wearing a checkbox.

   - Bad: *Add an `archived` clause to `AccountQuery`.*
   - Good: *`GET /v2/accounts/:id` returns 404 for an archived account.*

4. **Concrete, never abstract.** Real amounts, counts, status codes, field values, event names. Placeholders hide the edge cases the task exists to surface, and two engineers read them two ways. "Errors are handled appropriately" and "the event is emitted correctly" are not checkable. Name what is observed, and how many times.

5. **A refactor preserves behavior, and the checklist proves it.** The headline defect is a behavior change smuggled in under the banner of cleanup: a "while I'm in here" fix, a tightened validation, a changed default, ordering, or error message folded into a restructure.

   **Substitution test.** Revert to the old structure: every test passing now should still pass, and every test passing then should still pass now. If a test had to change to describe *new* behavior, the behavior changed. Split it out — it is its own task, and a story too if a user can see it.

   **Every task carries a "Nothing else changes" item** naming the existing behavior that shares the touched code. On a refactor, preservation items are most of the list.

   - Bad: *Move the date parser into `Time.Parse` and default a missing offset to UTC.*
   - Good: *Timestamps with no offset parse to the same value before and after the move.* The UTC default is a separate task with its own tests.

6. **A spec is linked, never restated.** When an API doc, wire spec, or upstream contract already defines the interface, the task links it as the source of truth and carries a Done-when item saying the implementation conforms to it. Copying its fields or rules into the task creates a second source of truth that drifts. The task adds only what the spec does not settle: where the code lives, what it reuses, and what must not change around it.

7. **One vocabulary, declared.** One code name and one domain word per concept, used the same way in the narrative, the Approach, and every item. Where they differ — the domain says "band", the code says `bucket` — record the pairing in Notes. Where the domain has competing words, pick one and record the rejected synonym. Declare only terms that were ambiguous or contested.

8. **Failures are criteria, and every item is checkable alone.** The list covers the change working, the alternatives that end differently, and what happens when it fails: the sweep that finds nothing, the call that times out, the retry after a crash. Each item is one somebody can write a test or a check for, without depending on another item's setup. Items with different priorities, or more than the task can hold, are a splitting signal.

9. **Never refactor blind.** Establish what the touched code is covered by before proposing to change it. Where coverage is thin, the Approach says what gets characterization tests first, and a Done-when item requires them to pass against the current code. The substitution test proves nothing if no test exercises the behavior.

10. **Never ask a naked question.** Every question, in Phase 1 or in Open Questions, carries a committed recommendation and the reasoning behind it. A bare "what should we do about X?" pushes the work back onto the user. An approach choice the overview leaves open is a fair question: commit to one in the draft and say why. Internals below the approach — helper names, signatures, a module's private layout — are the implementer's call. Neither ask about them nor decide them.

11. **A draft message contains the task and nothing else.** First character is the `#` of the task title, last character is the end of the final Open Question. No preamble, no sign-off, no explanation of the workflow.

## Phase 1. Read the overview

`$ARGUMENTS` is the task overview. It is prose, not a reference to fetch: no tracker lookup, no file path routing. Ticket context and spec links arrive by being pasted in.

If it is empty, ask what the work covers and wait.

Otherwise triage before drafting:

| What you were handed | Action |
|---|---|
| A **user** can see or do something different | Say it is a story, name the user-observable behavior, and stop. Where both exist, offer the split: a behavior-preserving task plus a separate story |
| Several changes with different risk profiles, or many unrelated modules | Say it is oversized, name the split by seam, and wait |
| Performance work or a data migration | Commit to the closest type, draft it, and log the mismatch as an Open Question — the checklist rules fit, but the type table below was not built for these |
| Anything else | Stays here |

**Observable** decides the first row: visible outside the unit being changed. A user is one audience, another module, service, or job is another. Only the user-observable half leaves.

Then settle three things for yourself. The task's title. Which type it is, since the type decides what the checklist covers:

- **Refactor** — structure changes, behavior does not.
- **Test work** — coverage or test-suite change, production code untouched.
- **Dependency or tooling** — a version, config, or build change.
- **Spec-driven** — build to an interface someone already wrote down.
- **Technical behavior** — something outside the unit can observe something new, and this task decides what.

And whether a spec exists. Do not emit this reading as a message. The draft is where the user sees your reading and corrects it.

## Phase 2. Ground the change

An Approach that names code is only as good as its grasp of that code. The touched modules, what depends on them, and the coverage baseline come from the repository; none can be inferred from the overview.

| Dimension | What it answers | Missing it produces |
|---|---|---|
| **Motivation** | Why now — what debt, risk, or friction drives this | Reviewers cannot judge whether the change is worth the risk |
| **Touched code** | Which modules, files, tables, endpoints, and symbols the change lands in | Invented names, or an Approach too vague to act on |
| **Dependents** | Who calls or consumes that code, and for what | A "Nothing else changes" item that names the wrong behavior |
| **Behavior that must survive** | What dependents observe today, including on failure | Behavior changes slip in under the banner of cleanup |
| **Failure modes** | What goes wrong, and what happens then | A happy-path-only checklist; a gap ships |
| **Existing patterns** | How the codebase already solves the nearest similar problem | An Approach that fights the codebase's conventions |
| **Coverage baseline** | What is tested today, and whether characterization comes first | Refactoring blind |
| **Spec** | Whether an external document already defines the interface | Restating a contract that then drifts |

When a draft fails the Self-check, the cause is almost always a missing dimension. This table is the diagnostic.

Motivation and the spec link come from the user; the rest come from the code. Whatever neither settles becomes a committed assumption in Open Questions.

### Research contract

Where the host supports parallel agents, send each area as a self-contained brief in one batch and wait for all of them. Where it does not, work the same briefs yourself, in order. Repositories default to the working directory; do not ask, and if the scope is genuinely ambiguous, commit to the working directory and say so in Open Questions.

```markdown
# Implementation grounding

Map the code this task touches and what depends on it. Do not design the change.

## Task overview

<the overview>

## Spec

<link, or "none">

## Area

<the repository, module, or path tree assigned>

## Hard boundary

Report what exists today. Do not recommend an approach, a target structure, or a
sequence of edits, and do not propose code. Name only things that exist, with
their paths.

## Report

**Touched code** — the modules, files, schemas, tables, endpoints, queues, and
symbols this change would land in, with paths.
**Dependents** — callers and consumers of that code, and what each relies on.
**Behavior that must survive** — what those dependents observe today, including
on failure, timeout, or empty input.
**Relevant tests** — test files that exercise the touched code, and which
behaviors they cover.
**Patterns to follow** — how the codebase already solves the nearest similar
problem, with one path as the example.
**Coverage verdict** — safe under the existing suite, or characterization first,
naming the behaviors to pin.
**Vocabulary** — where code names and domain words differ for one concept.
```

If research comes back thin, say so in Notes and commit to assumptions in Open Questions. That is a finding, not a failure. What comes back grounds the draft; it is not copied into it as an inventory.

## Phase 3. Draft

Work in this order. Detailing items before the list is outlined produces overlapping criteria and a missing failure mode.

1. **Name the change.** A title that says what becomes true, not what gets built.
2. **Write the narrative.** 2-4 sentences: what the code does today, why that is a problem, what changes. Real names.
3. **Write the Approach.** One paragraph: the chosen shape, what it reuses, what is `(new)`, the constraint or trade-off that decided it, and what gets characterized first if coverage is thin.
4. **Outline the checklist.** One line each, per the type's guide below.
5. **Detail each item** with concrete values.
6. **Run the edit hunt.** Read every item against Rules 3 and 4, and every name against research. Rewrite any item that describes an edit; remove or mark `(new)` any name research did not find. Do this before emitting, every round.

What the checklist covers depends on the type:

| Type | What the checklist covers |
|---|---|
| **Refactor** | Characterization passing before the move, the same tests passing unchanged after it, the structural goal checked by a command, and preservation. Mostly preservation |
| **Test work** | The behaviors that become covered — each item is a test somebody will write — and production code untouched |
| **Dependency or tooling** | The behavior most at risk: what the library is actually used for, exercised end to end |
| **Spec-driven** | Conformance to the linked spec, the failure cases the spec leaves to the implementer, and preservation |
| **Technical behavior** | The new observable behavior, its alternatives and failures, and preservation |

```markdown
## Task: <Descriptive Title — what becomes true>

<2-4 sentences: what the code does today, why that is a problem, what changes.
 Real names, present tense.>

### Approach

<One paragraph: the chosen shape, what it reuses, what is (new), the constraint
 or trade-off that decided it, what gets characterized first. No steps.>

### Done when

- [ ] <checkable outcome of the change>
- [ ] <alternative that ends differently>
- [ ] <failure case, and what the caller observes>
- [ ] Conforms to <spec link>; where this task and the spec disagree, the spec wins
- [ ] Nothing else changes: <named existing behavior> is exactly as before

### Notes

- **<Domain word>** = `<code name>`; not <rejected synonym>.
- <Ordering against other tasks, work left to another ticket, or anything
  grounding could not settle.>

## Open Questions

- **<Topic>.** Assuming <the position this draft already commits to>, because <reason>. Annotate if wrong.
```

The spec item appears only when a spec exists. Each Open Question states a position the draft already takes, so the user attacks a claim instead of answering a survey. The draft takes the risk of being wrong in public rather than interrogating the user before they have seen anything.

**Worked example — a refactor**

```markdown
## Task: Break the cycle between Accounts and the legacy package

On every authenticated request, `Accounts.authenticate/1` calls
`Legacy.Auth.SessionCheck.verify/1`, and `SessionCheck` calls back into
`Accounts.get_user/1`. That cycle is the last thing keeping `Legacy` alive. Move
session verification into `Accounts` so the dependency runs one way, with no
change to who gets in.

### Approach

Move `verify/1` and its cookie-decoding helpers into `Accounts.SessionToken`
(new), which `Accounts.authenticate/1` calls directly. `SessionCheck.verify/1`
becomes a one-line delegate to it, so `Legacy.Auth.LegacySignIn` keeps working
untouched until its own retirement task. The cookie format
and signing salt do not change: cookies issued before deploy must keep
verifying, so no key rotation rides along. `session_check_test.exs` covers only
the valid and expired cases, so tampering and the `LegacySignIn` path get
characterization tests before anything moves.

### Done when

- [ ] Characterization tests for valid, expired, and tampered cookies and for `LegacySignIn` pass against the current code
- [ ] The same tests pass after the move, none edited to describe new behavior
- [ ] `mix xref graph --format cycles` no longer reports a cycle through `Accounts` and `Legacy.Auth`
- [ ] A cookie issued by the pre-change code verifies after the change
- [ ] A tampered cookie returns 401 and writes exactly one `session_tampered` audit event, as today
- [ ] Nothing else changes: a request to `/invoices` with an expired cookie still redirects to `/sign-in?return_to=/invoices`, and no status code, redirect, or audit event differs from before

### Notes

- Deleting `SessionCheck` waits on `LegacySignIn`'s retirement and is not part of this task.
```

**Worked example — technical behavior**

```markdown
## Task: Emit `ar.band_entered` when an account's debt ages into an older band

Automations fire on record writes through `Automations.Dispatcher.emit/2`, so
nothing fires when time passes. `Billing.AgingReport` computes bands on read and
stores nothing, so there is no record that a boundary was crossed. Emit an event
to automations the first time an account's debt enters an older band, changing
nothing in `AgingReport`'s output.

### Approach

A daily `Billing.BandSweep` Oban worker (new) on the existing `billing` queue
computes each account's bands with `AgingReport.bands_for/1` and compares them
against `account_band_crossings` (new table: `account_id`, `band`, `entered_at`,
`cleared_at`). A band with no open crossing row records one and emits
`ar.band_entered` through `Dispatcher.emit/2`, the path record-write events
already use. `emit/2` inserts an Oban job, so the crossing row and the event
commit in one transaction and a retried sweep cannot send twice. The first run
backfills crossings without emitting, so release does not flood automations with
historical debt. Bands stay at 30, 60, and 90 days as `AgingReport` defines them.

### Done when

- [ ] An account with $240 unpaid for 60 days and no crossing row produces exactly one `ar.band_entered` event with `band: 60` and `amount_cents: 24000`
- [ ] The next day's sweep, with that debt still unpaid, emits nothing
- [ ] After the $240 is paid, a later $100 charge reaching 60 days emits `band: 60` again
- [ ] An account with $100 at 30 days and $300 at 90 days emits two events in one sweep, `band: 30` and `band: 90`
- [ ] The first sweep after release writes crossing rows for all existing aged debt and emits zero events
- [ ] A sweep that crashes partway and is retried emits no event twice
- [ ] Nothing else changes: `invoice.finalized` automations receive the same events as before, and `AgingReport.bands_for/1` returns the same result for every account

### Notes

- **Band** = an aging bracket (30, 60, 90 days past due), `band` in code; not "bucket".
- The automation consumer that acts on `ar.band_entered` is a separate task and does not block this one.
```

Both lists end on "Nothing else changes", and that is the pattern: whatever else a task does, one item names what stayed the same. Neither Approach orders its edits.

Rough proportions: narrative 2-4 sentences, Approach one paragraph of 3-6 sentences, typically 4-8 Done-when items, at most three Open Questions of two or three sentences. More than about eight items is a splitting signal, not thoroughness — say so rather than trimming quietly.

## Phase 4. Review loop

Emit the task as the whole message, per Rule 11, and stop the turn.

When feedback returns to the session, branch on it.

| What returns | Action |
|---|---|
| Annotation feedback | Revise against it, re-emit the full task as a bare message, stop again. This is the loop |
| Approved | Go to Phase 5 |
| Dismissed | Say the session closed. Stop |

There is no round cap. Every round ends the turn, so the user sets the pace and the exit.

When annotations across rounds contradict each other — checklist too thin, then too long, then back — stop absorbing it silently. The task is probably two tasks. Put that in the next draft's Open Questions with a committed recommendation, per Rule 10.

## Phase 5. Retire the scaffold

`## Open Questions` is a review instrument, not part of a task. Approval settles the shape, and the scaffold comes off.

Fold each unresolved question into `### Notes` as an `Unresolved:` line, so it travels with the task when the task becomes a ticket. An unanswered assumption that vanishes at approval is the one that resurfaces mid-implementation.

Then polish the prose, and only the prose. Run the narrative and the Approach paragraph through the `writing-for-humans` skill under this contract:

- **Polish**: the narrative, the Approach paragraph.
- **Leave untouched**: the title, every heading, every Done-when item, and Notes. They must come back byte-identical.
- **Preserve**: every technical name exactly as written, every `(new)` marker, and the declared vocabulary. Never strip, rename, or genericize a module, path, table, endpoint, or symbol into a description of it.
- **Never introduce**: numbered steps or an edit order.

If the polish changes what a sentence means, keep the approved wording — the user approved that text, not a rewrite of it. If `writing-for-humans` is unavailable, skip the polish and say "readability polish deferred".

Then delete the `## Open Questions` heading and emit the task one last time as a bare message. Stop there.

## Self-check

Run before emitting any draft.

- One change that lands and reverts as a unit
- Every name in the narrative and Approach was found by research or is marked `(new)`
- The Approach commits to one shape and its deciding trade-off, with no numbered steps or edit order
- Every Done-when item is an outcome someone could write a test or a check for, not an edit
- Concrete values throughout; no placeholders, no "handled appropriately"
- One code name and one domain word per concept, used consistently
- The type's checklist coverage is met, including a "Nothing else changes" item
- Working, alternative, and failure cases all present
- On a refactor: the same-tests-pass item is present, and any new behavior is split out
- When a spec exists: it is linked, conformance is an item, and none of its content is restated
- Coverage baseline established, and characterization is required first where it is thin
- Item count is 4-8, or the deviation is stated as a splitting signal
- Every Open Question carries a committed recommendation, and none is about internals below the approach
- The message contains the task and nothing else

On the Phase 5 emit, add two more: no `## Open Questions` section remains, and the Done-when items are byte-identical to the approved draft.
