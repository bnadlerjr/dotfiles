---
description: Refine a task overview into a behavior-focused technical task with BDD acceptance criteria. For work with no user-visible change — a refactor, test work, a dependency bump, or new machine-facing behavior.
argument-hint: "[task overview | empty for interactive]"
---

# Refine Task

Turns a task overview into a technical task shaped like a story: a narrative an engineer can read cold, and Given-When-Then criteria they can write tests from without asking a follow-up question. The one thing that makes it a task and not a story is that the observable outcome faces another module, job, or service rather than a person.

## Rules

1. **Task altitude is fixed.** One change that lands and reverts as a unit. Work a user can see or do is a story and belongs in a different workflow. Several changes with different risk profiles are several tasks — a dependency bump and an architectural refactor fail and revert independently, so they never share a task.

2. **Behavior, never implementation.** The defect that ruins tasks, and the one every other rule was failing to catch. A criterion leaks when it names:

   | Leak | Example |
   |---|---|
   | Modules, classes, functions | "`OrderService.place()` is called", "add a `Crossing` schema" |
   | Storage | "the row is inserted", a named table, column, or migration |
   | Wire and transport | "publishes to the `orders` topic", "the `POST /v2/orders` handler" |
   | Test code | "`refute_enqueued(worker: …)`", a named assertion, helper, or test file |
   | Scheduling and infrastructure | "a worker on a new queue", "a crontab entry", "the cron fires" |
   | Tooling | "typecheck and lint clean", any named lint, build, or format command |

   **Farley's substitution test.** Imagine the whole system replaced by a different implementation that fulfills the same behavior. Every scenario should still make sense. Any that would break describes construction, and the fix is to rewrite it in observable terms, not to soften the wording.

   Real names are not banned outright. The narrative may carry **one anchor** — the subsystem in words people say out loud, "automations", "the AR summary", "the scheduler" — so an engineer knows which corner of the system this is. Never a module path, never a symbol. On a dependency task the library and its versions are that anchor, since they are the subject. The criteria carry no technical names at all, and nothing anywhere names something that does not exist yet.

   - Bad: *Given no crossing has been recorded / When the balance sweep worker runs / Then an `aged_into_bucket` event is published to the automations topic*
   - Good: *Given Dana's account has $240 unpaid for 59 days / When the debt reaches 60 days unpaid / Then automations are notified once, and the notice says the money is $240*

3. **A refactor preserves behavior, and the scenarios prove it.** The headline defect is a behavior change smuggled in under the banner of cleanup: a "while I'm in here" fix, a tightened validation, a changed default, ordering, or error message folded into a restructure.

   **Substitution test.** Revert to the old structure: every test passing now should still pass, and every test passing then should still pass now. If a test had to change to describe *new* behavior, the behavior changed. Split it out — it is its own task, and a story too if a user can see it.

   Preservation is a set of scenarios, not an assertion about code. "The same requests are allowed and denied as before" is three scenarios pretending to be a bullet; written out, they become the characterization tests the refactor needs anyway. **Every task carries at least one scenario pinning what must not change**, and on a refactor that is most of the set.

   - Bad: *Refactor the date parser and, while we're in there, default the missing-offset case to UTC.*
   - Good: *Given a timestamp with no offset / When it is parsed / Then it resolves exactly as it does today.* The missing-offset change is a separate task with its own tests.

4. **Concrete, never abstract.** Real amounts, real day counts, real status names, a named actor where one helps. Placeholders hide the edge cases the task exists to surface, and two engineers read them two ways.

   - Bad: *Given an account with [some balance] / When [time passes] / Then [an event fires]*
   - Good: *Given Dana's account has $240 unpaid for 59 days / When the debt reaches 60 days unpaid / Then automations are notified once for her account*

   Vague outcomes fail the same way. "Then the system handles it appropriately" and "Then the event is published correctly" are not testable. Name what the consumer can now observe, and how many times.

5. **One vocabulary, declared.** The same term for the same concept in the narrative, the Context, and every scenario. Where the domain has competing words — bucket, band, bracket; account, client, owner — pick one, use it everywhere, and record the choice and the rejected synonym in Notes. Declare only terms that were ambiguous or contested; a full dictionary is noise.

6. **Failures are scenarios, and every scenario stands alone.** The set covers the behavior working, the alternatives that end differently, and what happens when it fails. A task whose scenarios all succeed ships a gap: the sweep that finds nothing, the call that times out, the consumer that is not listening. And no scenario may depend on another having run first — each carries its own Given.

7. **Criteria point at a test plan, they are not one.** Enough to settle what "done" means and to prompt the conversation, not every field rule and error string. Every criterion needs at least one acceptance test (Farley), and that is the check to run: not "can CI assert this fact about the codebase", but "can somebody write a test for this sentence". Criteria with different priorities, or that together overflow the task, are a splitting signal.

8. **Never refactor blind.** Establish what the touched code is covered by before proposing to change it. Where coverage is thin, the scenarios pinning current behavior come first and are written to be implemented first. The substitution test proves nothing if no test exercises the behavior.

9. **Never ask a naked question, and never ask a design question.** Every question, in Phase 1 or in Open Questions, carries a committed recommendation and the reasoning behind it. A bare "what should we do about X?" pushes the work back onto the user. And the question is about sequencing or a behavioral choice — the internals of something this task creates are the implementer's call, not the user's.

10. **A draft message contains the task and nothing else.** First character is the `#` of the task title, last character is the end of the final Open Question. No preamble, no sign-off, no explanation of the workflow.

## Phase 1. Read the overview

`$ARGUMENTS` is the task overview. It is prose, not a reference to fetch: no tracker lookup, no file path routing. Ticket context arrives by being pasted in.

If it is empty, ask what the work covers and wait.

Otherwise triage before drafting. The first two rows decide whether this command is the right one at all:

| What you were handed | Action |
|---|---|
| A **user** can see or do something different | Say it is a story, name the user-observable behavior, and stop. Where both exist, offer the split: a behavior-preserving task plus a separate story |
| An interface **already specified elsewhere** — an API doc, wire spec, or upstream contract — and the work is to build to it | Say it is an implementation task, point at the spec as the source of truth, and stop. This command adds nothing a spec-driven task does not already have |
| Another **module or system** can observe something different, and **this task decides what** | Stays here, as a technical-behavior task. Do not draft it as a refactor: the observable behavior changed, so the scenarios describe something new rather than something preserved |
| Several changes with different risk profiles, or many unrelated modules | Say it is oversized, name the split by seam, and wait |
| Performance work or a data migration | Say these sections were not built for it, commit to the closest framing, and log the mismatch as an Open Question |

Two words separate those rows. **Observable** means visible outside the unit being changed: a user is one audience, another module, service, or job is another. Only the user-observable half leaves for a story. And **specified** decides the second row: has someone already written down what this looks like? If yes, the spec is the task, and repeating it here only invites the two to drift.

Then settle three things for yourself. The task's title. Which of the four types it is, since the type decides what the scenario set covers:

- **Refactor** — structure changes, behavior does not.
- **Test work** — coverage or test-suite change, production code untouched.
- **Dependency or tooling** — a version, config, or build change.
- **Technical behavior** — something outside the unit can observe something new, and this task decides what.

And the domain vocabulary the overview uses. Do not emit this reading as a message. The draft is where the user sees your reading and corrects it.

## Phase 2. Ground the behavior

A task is only as testable as its grasp of what the system does today. And unlike a story, this grounding cannot skip the code: the behavior that must survive comes from the callers who depend on it, and the coverage baseline decides whether characterization scenarios come first. Neither can be inferred from the overview.

| Dimension | What it answers | Missing it produces |
|---|---|---|
| **Motivation** | Why now — what debt, risk, or friction drives this | Reviewers cannot judge whether the change is worth the risk |
| **Trigger** | What makes the behavior happen — a write, a schedule passing, a call | Whens that say "when the job runs" instead of naming the event |
| **Observable outcome** | What another module, job, or person can see afterward, and how they know | Vague Thens: "the event is published correctly" |
| **Behavior that must survive** | What works today that would break if this code changed | Behavior changes slip in under the banner of cleanup |
| **Failure modes** | What goes wrong, and what happens then | Every scenario succeeds; a gap ships |
| **Coverage baseline** | What is tested today, and whether characterization comes first | Refactoring blind |
| **Domain terms** | The vocabulary the team uses, and which synonyms lose | Module names leak in for want of a domain word |

When a draft fails the Self-check, the cause is almost always a missing dimension. This table is the diagnostic, and the last row earns its place: most leaks happen because the author had no domain word and reached for the code's name instead.

Motivation and domain terms come from the user; the rest come from the code. Whatever neither settles becomes a committed assumption in Open Questions.

### Research contract

Three limits bound the research, and all three belong in every brief:

1. **Ground the behavior; do not design the fix.** Establish what happens today and what depends on it. The step-by-step *how* belongs in a downstream plan. If you catch yourself writing "we should…", stop.
2. **Return behavior, not structure.** A finding is an observable outcome, never a signature, schema, or file inventory. This is the translation the author cannot do alone, because only the researcher saw the code.
3. **Establish the coverage baseline.** Give a verdict: safe to change under the existing suite, or characterization scenarios first, naming the behaviors that need pinning.

Where the host supports parallel agents, send each area as a self-contained brief in one batch and wait for all of them. Where it does not, work the same briefs yourself, in order. Repositories default to the working directory; do not ask, and if the scope is genuinely ambiguous, commit to the working directory and say so in Open Questions.

```markdown
# Behavior grounding

Establish what this code does today, in observable terms. Do not design the change.

## Task overview

<the overview>

## Area

<the repository, module, or path tree assigned>

## Hard boundary

Report behavior, not construction. Do not recommend a strategy, a sequence of
edits, or a target structure, and do not return signatures, schemas, or a file
inventory. If you cannot answer without naming a module, symbol, table, or file,
restate it as the behavior that thing produces.

## Report

**Behavior that must survive** — what a caller, job, or person can observe today
that would break if this code changed. State each as an outcome.
**Trigger** — what currently makes this code run: a write, a schedule, a call.
**Failure behavior today** — what happens when this path fails, times out, or
finds nothing.
**Coverage verdict** — safe under the existing suite, or characterization
scenarios first, naming the behaviors that need pinning.
**Domain vocabulary** — the terms people actually use for this, and any legacy
term they replaced.
```

If research comes back thin, say so in the draft's Notes and commit to assumptions in Open Questions. That is a finding, not a failure. What comes back grounds the draft; it is not copied into it.

## Phase 3. Draft

Work in this order. Do not reorder it — detailing scenarios before the set is outlined produces overlapping criteria and a missing failure mode.

1. **Name the change.** A title that says what becomes true, not what gets built.
2. **Write the narrative.** 2-4 sentences: what happens today, why that is a problem, what changes. Domain language, at most one anchor.
3. **State the Context.** When this behavior is relevant — the preconditions.
4. **Outline the scenario set.** One line each, per the type's guide below, before writing a single Given.
5. **Detail each scenario** with concrete values, each independently set up.
6. **Run the leak hunt.** Read every Given, When, and Then against Rule 2's table and the substitution test. Rewrite what leaks. Do this before emitting, every round.

What the set covers depends on the type:

| Type | What the scenario set covers |
|---|---|
| **Refactor** | The behavior that must survive, written as characterization scenarios. Most of the set |
| **Test work** | The behavior that must become covered. The scenarios *are* the deliverable — each one is a test somebody will write |
| **Dependency or tooling** | The behavior most at risk from the change: what the library is actually used for, exercised end to end |
| **Technical behavior** | The new observable behavior, its alternatives and its failures, plus at least one scenario pinning what did not change |

```markdown
## Task: <Descriptive Title — what becomes true>

<2-4 sentences: what happens today, why that is a problem, what changes.
 Domain language, present tense, at most one subsystem anchor.>

### Context

<When this behavior is relevant — the preconditions.>

### Acceptance Criteria

#### Scenario: <the new behavior, or a behavior that must survive>
- Given <situation, concrete>
- When <the event: a write, a schedule passing, a call>
- Then <what another module, job, or person can now observe>
- And <further observable outcome>

#### Scenario: <alternative that ends differently>
- Given <different situation>
- When <event>
- Then <different outcome>

#### Scenario: <failure>
- Given <failure situation>
- When <event>
- Then <what happens instead, and what the caller sees>

#### Scenario: Nothing else changes
- Given <an existing behavior that shares this code>
- When <the change is in place>
- Then <that behavior is exactly as it was>

### Notes

- **<Term>** = <meaning>; not <rejected synonym>.
- <Ordering against other tasks, work left to another ticket, or anything
  grounding could not settle.>

## Open Questions

- **<Topic>.** Assuming <the position this draft already commits to>. Annotate if wrong.
```

Each Open Question states a position the draft already takes, so the user attacks a claim instead of answering a survey. This is the stress test. The draft takes the risk of being wrong in public rather than interrogating the user before they have seen anything.

**Worked example — a refactor**

```markdown
## Task: Stop the sign-in path depending on the legacy package

Session checking lives in the legacy package, and the sign-in path reaches into
it on every request. That circular dependency is the last thing keeping legacy
alive, so it blocks deleting the package at all. Move the checking so the
dependency runs one way, with no change to who gets in.

### Context

Applies to every request carrying a session, on all sign-in paths.

### Acceptance Criteria

#### Scenario: A valid session is accepted
- Given Dana signed in 10 minutes ago
- When she opens a page that needs her to be signed in
- Then she is let through

#### Scenario: An expired session is refused
- Given Dana's session expired an hour ago
- When she opens a page that needs her to be signed in
- Then she is refused and asked to sign in again

#### Scenario: A tampered session is refused
- Given a session whose contents have been altered since it was issued
- When it is presented
- Then it is refused, and the attempt is recorded as tampering

#### Scenario: Nothing else changes
- Given people who signed in before this change shipped
- When the checking has moved
- Then they stay signed in and are not asked for their password again
- And accounts arriving through the legacy sign-in path get in exactly as before
```

**Worked example — technical behavior**

```markdown
## Task: Notify automations when an account's debt ages

Automations fire when somebody saves a record. Nothing fires when time passes, so
an account whose debt quietly ages past 60 days goes unnoticed until a staff
member opens the AR summary. Age is worked out fresh each time that report is
read and remembered nowhere, so there is no record that a boundary was crossed.
Notify automations the first time an account's debt enters an older age band,
changing nothing on screen.

### Context

Applies to accounts carrying an unpaid balance, at practices using automations.

### Acceptance Criteria

#### Scenario: Debt ages into an older band
- Given Dana's account has $240 unpaid for 59 days
- When the debt reaches 60 days unpaid
- Then automations are notified once for Dana's account
- And the notice says which band the money entered and that it is $240

#### Scenario: The debt sits in the same band
- Given Dana's $240 was reported as entering the 60-day band yesterday
- When the debt is still 60-plus days unpaid today
- Then automations are not notified again

#### Scenario: Debt leaves a band and later returns
- Given Dana's $240 entered the 60-day band and was then paid off
- When a later $100 charge on her account ages past 60 days
- Then automations are notified for the 60-day band again

#### Scenario: The first check after release
- Given many accounts already hold debt older than 60 days
- When the check runs for the first time
- Then no notices are sent for debt that aged before release

#### Scenario: Debt crosses two boundaries at once
- Given Dana has $100 unpaid for 29 days and $300 unpaid for 89 days
- When both cross a boundary before the next check
- Then automations are notified once for the 30-day band and once for the 90-day band

#### Scenario: Nothing else changes
- Given a practice whose automations fire when an invoice is finalized
- When the aging check runs
- Then those automations receive nothing they would not have received before
- And the amounts and bands on the AR summary are unchanged

### Notes

- **Band** = an aging bracket such as 30 or 60 days past due; not "bucket".
- The consumer that acts on these notices is a separate task and does not block this one.
```

Both examples end on the same scenario, and that is the pattern: whatever else a task does, one scenario says what stayed the same. On the refactor it carries the on-disk session format without ever naming a format.

Rough proportions: narrative 2-4 sentences, Context 1-2 lines, typically 3-6 scenarios at 3-5 clauses each, at most three Open Questions of two or three sentences. More than about eight scenarios is a splitting signal, not thoroughness — say so rather than trimming quietly.

## Phase 4. Review loop

Emit the task as the whole message, per Rule 10, and stop the turn.

When feedback returns to the session, branch on it.

| What returns | Action |
|---|---|
| Annotation feedback | Revise against it, re-emit the full task as a bare message, stop again. This is the loop |
| Approved | Go to Phase 5 |
| Dismissed | Say the session closed. Stop |

There is no round cap. Every round ends the turn, so the user sets the pace and the exit.

When annotations across rounds contradict each other — criteria too thin, then too many, then back — stop absorbing it silently. The task is probably two tasks. Put that in the next draft's Open Questions with a committed recommendation, per Rule 9.

## Phase 5. Retire the scaffold

`## Open Questions` is a review instrument, not part of a task. Approval settles the shape, and the scaffold comes off.

Fold each unresolved question into `### Notes` as an `Unresolved:` line, so it travels with the task when the task becomes a ticket. An unanswered assumption that vanishes at approval is the one that resurfaces mid-implementation.

Then polish the prose, and only the prose. Run the narrative paragraph and the Context line through the `writing-for-humans` skill under this contract:

- **Polish**: the narrative, the Context line.
- **Leave untouched**: the title, every heading, every `Given / When / Then / And` clause, and Notes. The criteria are testability-critical specs and must come back byte-identical.
- **Preserve**: the declared vocabulary. Never substitute a generic synonym for a declared term.
- **Never introduce**: module, API, storage, or tooling language. The polish must not re-create the leak.

If the polish changes what a sentence means, keep the approved wording — the user approved that text, not a rewrite of it. If `writing-for-humans` is unavailable, skip the polish and say "readability polish deferred".

Then delete the `## Open Questions` heading and emit the task one last time as a bare message. Stop there.

## Self-check

Run before emitting any draft.

- One change that lands and reverts as a unit
- Narrative in domain language, carrying at most one subsystem anchor
- Zero leaks: every clause survives the substitution test
- No module, table, symbol, test-code, or tooling name in any criterion, and nothing named that does not exist yet
- Concrete amounts, counts, and statuses; no placeholders, no "handled appropriately"
- One term per concept across narrative, Context, and every scenario
- The type's scenario set is covered, including at least one scenario pinning what must not change
- Working, alternative, and failure scenarios all present
- Every scenario carries its own Given and needs no other scenario first
- Every criterion is one somebody could write a test for
- Coverage baseline established, and pinning scenarios come first where it is thin
- Scenario count is 3-6, or the deviation is stated as a splitting signal
- Every Open Question carries a committed recommendation, and is about sequencing or behavior rather than internals
- The message contains the task and nothing else

On the Phase 5 emit, add two more: no `## Open Questions` section remains, and the acceptance criteria are byte-identical to the approved draft.
