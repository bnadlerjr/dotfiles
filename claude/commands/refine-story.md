---
description: Refine a story overview into a behavior-focused story with BDD acceptance criteria.
argument-hint: "[story overview | empty for interactive]"
---

# Refine Story

Turns a story overview into a full behavior-focused story: a narrative a stakeholder can read, and Given-When-Then criteria a developer can write tests from without asking a follow-up question.

## Rules

1. **Story altitude is fixed.** One coherent demoable behavior, roughly 1-3 days of work, described by what a user can see or do. The units either side belong elsewhere: several behaviors at once is an epic, which is a higher-altitude unit, and work with no user-visible change is a technical task. This command refines exactly one story.

2. **Narrative, never the template.** Prose covering the situation, the behavior, and the value, in present tense. Never "As a [user], I want [X], so that [Y]" — the template flattens every story into the same three slots and drops the situation that made the story worth writing.

   - Bad: *As a user, I want to click cancel so that my order is cancelled.*
   - Good: *When customers change their mind before shipment, they cancel the order and see that a refund is on its way.*

3. **Behavior, never implementation.** The defect that ruins stories, and it hides in the criteria rather than the narrative. A scenario leaks when it names:

   | Leak | Example |
   |---|---|
   | HTTP or API behavior | "the API returns 200", "POST /orders" |
   | Storage | "the row is inserted", "the cache is invalidated", a named table |
   | UI elements | "clicks the red Cancel button", "a modal appears", "the page loads" |
   | Code paths or services | "OrderService is called", "the handler fires" |
   | Technical mechanisms | "retries 3 times", "publishes a Kafka event", "Redis is updated" |

   **Farley's substitution test.** Imagine the whole system replaced by a different implementation that fulfills the same behavior. Every scenario should still make sense. Any that would break describes construction, and the fix is to rewrite it in observable terms, not to soften the wording.

   - Bad: *Given the order status is "PENDING" in the orders table / When the cancel button onClick handler fires / Then the Redux store is updated*
   - Good: *Given a customer has an order in "confirmed" status / When they request to cancel it / Then the order is cancelled and a refund is initiated*

4. **Concrete, never abstract.** Real statuses, real amounts, a named actor where one helps. Placeholders hide the edge cases the story exists to surface, and two testers read them two ways.

   - Bad: *Given a customer with [some status] / When they do [some action] / Then [something happens]*
   - Good: *Given Dana has an order in "confirmed" status totalling $84.50 / When she requests to cancel it / Then she sees the order marked "cancelled" and a $84.50 refund in progress*

   Vague outcomes fail the same way. "Then the system handles it appropriately" and "Then an error is shown" are not testable. Name what the user sees and what they can do next.

5. **One vocabulary, declared.** The same term for the same concept in the narrative, the Context, and every scenario. Where the domain has competing words — appointment, visit, encounter — pick one, use it everywhere, and record the choice and the rejected synonym in Notes. Declare only terms that were ambiguous or contested; a full dictionary is noise.

6. **Failures are scenarios, and every scenario stands alone.** The set covers the happy path, the valid alternatives that end differently, and the failures. A happy-path-only story ships a QA gap. And no scenario may depend on another having run first — each carries its own Given.

7. **Criteria point at a test plan, they are not one.** Enough to settle what "done" means and to prompt the conversation, not every field rule and error string. Add criteria when they share a priority and the story still fits an iteration; split the story when they have different priorities or together overflow it (Cohn's SPIDR: spike, path, interface, data, rules). Spend the detail where misunderstanding is likely and skip it where the team already agrees (Shore). Every criterion needs at least one acceptance test (Farley).

8. **Never ask a naked question.** Every question, in Phase 1 or in Open Questions, carries a committed recommendation and the reasoning behind it. A bare "what should we do about X?" pushes the work back onto the user.

9. **A draft message contains the story and nothing else.** First character is the `#` of the story title, last character is the end of the final Open Question. No preamble, no sign-off, no explanation of the workflow.

## Phase 1. Read the overview

`$ARGUMENTS` is the story overview. It is prose, not a reference to fetch: no tracker lookup, no file path routing. Issue context arrives by being pasted in.

If it is empty, ask what the story covers and wait.

Otherwise check altitude before anything else, because two of these produce the wrong artifact entirely rather than a weaker one:

| What you were handed | Action |
|---|---|
| Several behaviors, weeks of work | Say it is epic-sized, name the behaviors you can see, and stop. Do not draft |
| No user-visible change — a refactor, migration, dependency bump, test work | Apply Farley once: "inside every technical story there is a user value trying to escape." If a user value surfaces, draft that story instead. If none does, stop |
| Sized in minutes-to-hours, or one increment of a larger behavior | Say it merges up, name the behavior it belongs inside, and wait |

Then settle three things for yourself: the story's title, the actor and the situation they are in, and the vocabulary the overview uses. Do not emit this reading as a message. The draft is where the user sees your reading and corrects it.

## Phase 2. Ground in the six dimensions

A story is only as testable as its grasp of what users can already see and do. Invented status names read as authoritative and are worse than an admitted gap.

| Dimension | What it answers | Missing it produces |
|---|---|---|
| **Actor** | Who experiences this need, and their situation in the domain | Vague Givens: "a user", with no situated role |
| **Trigger** | What event or situation creates the need | Whens with no cause; the story floats free of context |
| **Outcome** | What result they want, and how they know they got it | Vague Thens: "the system handles it appropriately" |
| **Constraints** | What business rules bound the behavior | Every scenario looks like the happy path |
| **Failure Modes** | What goes wrong, and how it is handled | Happy path only; a QA gap |
| **Domain Terms** | The vocabulary the business uses, and which synonyms lose | Technical jargon leaks in; stakeholders cannot read it |

When a draft fails the Self-check, the cause is almost always a missing dimension. This table is the diagnostic.

Resolve each dimension in this order. Note that it differs from the usual advice to ask the user first: here the review loop **is** the asking, so the draft commits to a position instead.

1. Harvest from the overview. An overview that already carries its own grounding and domain glossary needs no further research — take both and skip to Phase 3.
2. Read product documentation: PRDs, READMEs, ADRs about user-facing capabilities. Docs are written in user language, so the translation distance to behavior is zero.
3. Inventory the user-facing surface, capability level only.
4. Whatever is still open becomes a committed assumption in Open Questions.

### Research depth

Entry points only: routes, pages, screens, CLI commands, public APIs. Report what they let a user do. Never open implementation code, never trace a call graph, and never carry a file path, schema, service, or class name into a finding. A capability-level inventory is the right instrument. Deep code analysis is the wrong one: it answers at the wrong altitude and biases the draft toward how the system happens to be built today.

Farley's substitution test applies to the input as well. If your grounding could be swapped for behavior-equivalent context — a PRD, a screenshot, a stakeholder's description — and the story would come out the same, you researched at the right level. If the story would change, you over-researched.

Where the host supports parallel agents, send each question as a self-contained brief in one batch and wait for all of them. Where it does not, work the same briefs yourself, in order. Repositories default to the working directory; do not ask, and if the scope is genuinely ambiguous, commit to the working directory and say so in Open Questions.

```markdown
# Behavior-surface research

Describe what users can currently see or do in this area. Never describe how it is built.

## Story overview

<the overview>

## Question

<one question: an observable state, a vocabulary choice, or a user-visible failure>

## Report

**Observable states** — the status, mode, and state names a user encounters, verbatim.
**Domain vocabulary** — the canonical user-facing terms, and any legacy term they replaced.
**User-visible failures** — the error, validation, and rejection text a user is shown.
**Boundaries** — what is gated, hidden, or absent, and under what conditions.

If you cannot answer without naming a file, function, service, or schema, say
"insufficient user-visible signal" and stop.
```

If every question comes back thin, say so in the draft's Notes and commit to assumptions in Open Questions. That is a finding, not a failure.

## Phase 3. Draft

Work in this order. Do not reorder it — detailing scenarios before the set is outlined produces overlapping criteria and a missing failure mode.

1. **Name the behavior.** A title that says what the actor achieves, not what the system does.
2. **Write the narrative.** 2-4 sentences: the situation, the behavior needed, the value gained.
3. **State the Context.** The business preconditions that make this behavior relevant.
4. **Outline the scenario set.** One line each — happy path, alternatives, failures — before writing a single Given.
5. **Detail each scenario** with concrete values, each independently set up.
6. **Run the leak hunt.** Read every Given, When, and Then against Rule 3's table and the substitution test. Rewrite what leaks. Do this before emitting, every round.

```markdown
## Story: <Descriptive Title>

<2-4 sentences: the situation that creates the need, the behavior, and the value.
 Domain language, present tense.>

### Context

<When this behavior is relevant — the business preconditions.>

### Acceptance Criteria

#### Scenario: <Happy path>
- Given <business state, concrete>
- When <user action or business event>
- Then <observable outcome>
- And <further observable outcome>

#### Scenario: <Alternative path that ends differently>
- Given <different state>
- When <action>
- Then <different outcome>

#### Scenario: <Failure>
- Given <failure state>
- When <action>
- Then <what the user is told, and what they can do next>

### Notes

- **<Term>** = <meaning>; not <rejected synonym>.
- <Anything grounding could not establish.>

## Open Questions

- **<Topic>.** Assuming <the position this draft already commits to>. Annotate if wrong.
```

Each Open Question states a position the draft already takes, so the user attacks a claim instead of answering a survey. This is the stress test. The draft takes the risk of being wrong in public rather than interrogating the user before they have seen anything.

**Worked example**

```markdown
## Story: Customer Cancels Order Before Shipment

When customers change their mind about a purchase, they cancel the order and see
that their refund is on its way. Cancellation only makes sense before the order
ships, since the returns process applies once it has left the warehouse.

### Context

Available while an order is in "confirmed" or "processing" status.

### Acceptance Criteria

#### Scenario: Cancelling an unshipped order
- Given Dana has an order in "confirmed" status totalling $84.50
- When she requests to cancel it
- Then the order is marked "cancelled"
- And a $84.50 refund is initiated
- And she receives a cancellation confirmation

#### Scenario: The order has already shipped
- Given Dana's order has left the warehouse
- When she attempts to cancel it
- Then she is told the order can no longer be cancelled
- And she is directed to the returns process
```

Rough proportions: narrative 2-4 sentences, Context 1-2 lines, typically 3-6 scenarios at 3-5 clauses each. More than about eight scenarios is a splitting signal, not thoroughness — say so rather than trimming quietly.

## Phase 4. Review loop

Emit the story as the whole message, per Rule 9, and stop the turn.

When feedback returns to the session, branch on it.

| What returns | Action |
|---|---|
| Annotation feedback | Revise against it, re-emit the full story as a bare message, stop again. This is the loop |
| Approved | Go to Phase 5 |
| Dismissed | Say the session closed. Stop |

There is no round cap. Every round ends the turn, so the user sets the pace and the exit.

When annotations across rounds contradict each other — criteria too thin, then too many, then back — stop absorbing it silently. The story is probably two stories. Put that in the next draft's Open Questions with a committed recommendation, per Rule 8.

## Phase 5. Retire the scaffold

`## Open Questions` is a review instrument, not part of a story. Approval settles the shape, and the scaffold comes off.

Fold each unresolved question into `### Notes` as an `Unresolved:` line, so it travels with the story when the story becomes a ticket. An unanswered assumption that vanishes at approval is the one that resurfaces mid-sprint.

Then polish the prose, and only the prose. Run the narrative paragraph and the Context line through the `writing-for-humans` skill under this contract:

- **Polish**: the narrative, the Context line.
- **Leave untouched**: the title, every heading, every `Given / When / Then / And` clause, and Notes. The criteria are testability-critical specs and must come back byte-identical.
- **Preserve**: the domain vocabulary. Never substitute a generic synonym for a declared term.
- **Never introduce**: UI, API, or storage language, or "As a... I want... so that..." phrasing. The polish must not re-create the leak.

If the polish changes what a sentence means, keep the approved wording — the user approved that text, not a rewrite of it. If `writing-for-humans` is unavailable, skip the polish and say "readability polish deferred".

Then delete the `## Open Questions` heading and emit the story one last time as a bare message. Stop there.

## Self-check

Run before emitting any draft.

- One coherent demoable behavior, not an epic and not an increment
- Narrative prose, no "As a... I want..." template
- Zero leaks: every clause survives the substitution test
- Concrete statuses and values, no placeholders, no "handled appropriately"
- One term per concept across narrative, Context, and every scenario
- Happy path, alternatives, and failures all present
- Every scenario carries its own Given and needs no other scenario first
- Scenario count is 3-6, or the deviation is stated as a splitting signal
- Every Open Question carries a committed recommendation
- The message contains the story and nothing else

On the Phase 5 emit, add two more: no `## Open Questions` section remains, and the acceptance criteria are byte-identical to the approved draft.
