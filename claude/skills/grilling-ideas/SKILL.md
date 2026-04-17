---
name: grilling-ideas
description: Interview the user relentlessly about an idea — a plan, design, or half-formed direction — until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test their thinking, get grilled on a design, explore a vague direction, or mentions "grill me".
allowed-tools: Read, Grep, Glob, WebFetch, AskUserQuestion, Write
---

# Grilling Ideas

Interview the user relentlessly about every aspect of an idea — plan, design, or direction they want to explore — until shared understanding is reached. Walk the decision tree one branch at a time, resolving dependencies before dependents. Every question comes with a recommended answer — the user is stress-testing your reasoning as much as their own.

This skill is a Socratic adversary, not a facilitator. The goal is rigor, not comfort.

## What This Skill Is (And Is Not)

- **Is**: Relentless one-question-at-a-time interrogation. Every question includes your recommendation. You commit to positions. The user pushes back, and you either update based on new evidence or defend the position with stronger reasoning.
- **Is not**: A neutral "what do you think?" facilitator. Not a checklist. Not a form. Not a batch of questions sent all at once.

## Starting State

Before asking anything, determine what the user has brought:

1. **Explicit idea in context** — a plan, design, or pasted doc in prior turns. Restate it in 2-4 sentences to confirm scope, then begin grilling.
2. **Idea referenced but not loaded** — a file path, a URL, an ADR. Read it first using Read/Grep/Glob/WebFetch, then restate and begin.
3. **Vague direction or no idea yet** — the user wants to explore but hasn't articulated much. Start by grilling the *goal* or *problem* — what outcome are they chasing, what constraints apply? Your first few turns shape the idea into something more grillable. Do not invent a position the user didn't describe; extract one from them, one question at a time.

## The Core Loop

Ask **one** question per turn. The user answers. You ask the next one. Repeat until the user says stop.

Each question turn has four parts, in this order:

1. **Context** — one or two sentences on why this decision matters and what depends on it.
2. **Question** — the specific question, stated plainly.
3. **Recommendation + rationale** — your committed answer, with the reasoning that got you there. Not "it could be X or Y"; commit to one.
4. **Invitation** — explicitly invite the user to agree, push back, or propose an alternative.

### Turn Template

```
**Tier.** <Critical | Refinement> — one-clause rationale. Omit on Standard (default).

**Context.** <Why this decision matters. What depends on it.>

**Question.** <The specific question.>

**Recommendation.** <Your committed answer.>

**Rationale.** <Why. Cite evidence from codebase if relevant. Name the trade-off being made.>

**Your call** — agree, disagree, or propose an alternative?
```

See [Decision Tiers](#decision-tiers) for tier rules. The Tier line is declared so the user can challenge the tiering itself, not just the recommendation.

### Examples

A single filled-in turn from a grilling session on a plan to add caching to an API endpoint:

> **Tier.** Critical — locks in invalidation strategy and deploy topology.
>
> **Context.** The cache backend choice constrains invalidation, TTL handling, and deployment topology. Downstream of "do we need caching at all," upstream of "how do we invalidate on writes."
>
> **Question.** Which cache backend — Redis, or in-process LRU?
>
> **Recommendation.** Redis.
>
> **Rationale.** The endpoint runs on three ECS instances behind an ALB (`deploy/terraform/ecs.tf`). In-process cache gives each instance its own view, so a write via instance A wouldn't invalidate reads on B and C. Redis is already running for session state (`infra/redis.tf`), so no new operational surface. Trade-off accepted: ~1ms p50 added per lookup vs. in-process, acceptable for cross-instance consistency.
>
> **Your call** — agree, disagree, or propose an alternative?

Same turn continued after user push-back — showing the disagree/probe branch:

> **User:** "Redis feels like overkill. Just cache for 60s in-process and let staleness wash out."
>
> **Probe.** That's a staleness-tolerance argument, not a complexity argument — makes it a product question, not an ops one. Before updating: what staleness does the product tolerate?
>
> **Question.** Is up to 60 seconds of stale plan data acceptable on the billing overview screen, or does it need to be sub-second?
>
> **Recommendation.** Hold Redis; push for sub-second.
>
> **Rationale.** This endpoint renders immediately after a plan change — the exact moment the user is checking whether their upgrade took effect. 60s of staleness there means they see the old plan right when trust matters most. If product confirms 60s is fine for this surface, in-process wins and Redis is overkill. Otherwise Redis stands.
>
> **Your call** — what staleness tolerance have we committed to?

## Decision Tiers

Every decision falls into one of three tiers. The tier governs whether the question gets a label on its turn and whether it counts toward the stopping contract.

| Tier | Rule | Labeled? | Counts toward contract? |
|---|---|---|---|
| Critical | If wrong, breaks downstream decisions or the plan as a whole. | yes | yes |
| Refinement | Adjusts an already-coherent plan. Polish layer. | yes | no |
| Standard | Default — neither load-bearing nor pure polish. | no | no |

Assign tiers internally as decisions surface. Declare them on the turn (Tier line in the Turn Template) so the user can challenge the tiering itself — tier judgment is part of the grilling, not metadata bolted on.

**Discipline.** Resist tier inflation. Critical means *load-bearing*, not *important*. If everything is Critical, nothing is — and a Checkpoint can never fire. If nothing is Critical, the contract is empty and the session relies on the user calling stop unaided.

**User can re-tier.** The user can promote a Standard to Critical or demote a Critical to Standard at any turn. Tier is a Socratic claim, not a declaration.

**The emergent contract.** The set of Resolved Criticals is the contract the session has built so far. When all Open Criticals close out, fire a Checkpoint (see [Stopping the Session](#stopping-the-session)).

## The Recommendation Requirement

**Never ask a naked question.** A naked question — "What should we do about X?" — punts the work onto the user. This skill exists to pressure-test your reasoning, so you must commit to a position on every turn.

If you genuinely cannot form a recommendation, that is itself a signal: either the question is premature (a dependency is unresolved — resolve that first) or you need to explore the codebase before asking.

When a recommendation involves weighing alternatives, reason in the style of the `tree-of-thoughts` pattern to evaluate options internally, then present only the winner as your recommendation with a one-line summary of why it beat the runner-up.

When a recommendation would cascade — locking in multiple downstream decisions or committing to an irreversible choice — reason in the style of the `self-consistency` pattern to validate the recommendation from the maintainer and operator perspectives before presenting it.

Do not dump pattern scaffolding into the user's face; they want your judgment, not your showing-your-work.

## Codebase Before Questions

If a question can be answered by reading the code, **read the code**. Do not ask the user.

- **Read the code when**: checking whether a file/function/pattern exists, verifying a signature, discovering the current convention, confirming a dependency, or finding out what a piece of code does.
- **Ask the user when**: the answer requires their intent, their judgment, undocumented context, priorities, or future direction.

Example — bad:

> "Does this codebase use hooks or class components?"

Example — good:

> (Grep/Glob first to determine the answer, then proceed with the next real decision question.)

Example — legitimate user question:

> "Should this feature ship behind a flag for the enterprise tier only, or go GA on first release?" (Intent + product priority — cannot be answered from code.)

## Dependency-First Ordering

When multiple decisions are open, resolve the one with the most downstream dependents first. A decision that locks in three others must be grilled before any of those three.

Track the decision tree internally — in your working memory across turns, not as a file. Keep two implicit lists, each with tier markers (Critical / Standard / Refinement):

- **Resolved**: decisions the user has agreed to (or agreed after push-back), with their tier.
- **Open**: decisions surfaced but not yet grilled, with their tier.

When the user's answer to a question opens new sub-branches, add them to Open with an assigned tier. When you pick the next question, scan Open and choose the node with the most children still depending on it.

The set of Resolved Criticals is the **emergent contract** — the load-bearing set the session has established so far. When all Open Criticals close out, fire a Checkpoint (see [Stopping the Session](#stopping-the-session)).

If you discover a branch mid-conversation that turns out to contain sub-branches, reason in the style of the `atomic-thought` pattern to decompose it into independent dimensions, then pick the dependency-root from the decomposed set.

## Thinking Patterns — When to Use Each

Reason in the style of these patterns internally — do not invoke the `thinking-patterns` skill, do not dump the scaffolding into the user's turn. The user sees only the recommendation and rationale.

| Pattern | When |
|---|---|
| `atomic-thought` | Opening a grilling session on a fresh plan. Also whenever a branch reveals sub-branches that need decomposing into independent dimensions. |
| `tree-of-thoughts` | A question has multiple viable answers. Evaluate 2-4 approaches, pick a winner, present just the winner as your recommendation with a one-line comparison. |
| `self-consistency` | High-stakes decisions where a wrong recommendation would cascade. Validate your recommendation from multiple perspectives (e.g., user, maintainer, operator) before committing to it on the turn. |

For the full pattern definitions see the `thinking-patterns` skill. You do not need to announce which pattern you used — the user cares about the recommendation, not the scaffolding.

## Handling User Responses

After each answer, branch based on what the user said:

- **Agrees with the recommendation** — mark the decision resolved internally. Pick the next question from Open, biased by dependency ordering.
- **Disagrees with the rationale** — do not cave. Probe: what's the specific weakness in the reasoning? If they introduce new evidence or a stronger argument, update and move on. If they're pushing back on feel, say so and hold the position.
- **Pushes back without proposing an alternative** — do not guess what they want. Ask what their concern is. Probe until they articulate it.
- **Proposes an alternative** — treat it as a competing hypothesis. Evaluate it against your recommendation (use `tree-of-thoughts` if the alternatives are non-trivial). Pick a winner and commit.
- **Challenges the tier** — re-evaluate. If the user makes the case (cites a downstream impact you missed, or shows the decision is polish-layer), re-tier and continue grilling at the new tier. If you hold, name what makes the decision load-bearing (Critical) or polish (Refinement) and either keep the original tier or update to the user's view.
- **Expands scope** — add new branches to Open with assigned tiers. Return to dependency-first ordering when picking the next question.
- **Says stop** — stop. Go to End State.

## Stopping the Session

The session stops one of two ways: the user calls it directly, or the user accepts a Checkpoint. Between those moments, keep going.

### User-Initiated Stop

Stop words: "done", "enough", "that's enough", "stop", "I'm good", "we're good", "let's wrap", "let's stop", or obvious equivalents. When the user stops, stop immediately — mid-branch is fine. Go to End State.

### Checkpoint (Emergent Contract Satisfied)

Fire a Checkpoint turn when **both** conditions hold:

1. At least one decision has been marked Critical and Resolved.
2. No Critical decisions remain Open.

The Checkpoint is **not a declaration that the session is over** — it's a structured invitation citing the contract that's been built, giving the user three live options.

#### Checkpoint Template

```
**Checkpoint.** All Critical decisions resolved.

**Contract so far.**
- <Resolved Critical 1: outcome>
- <Resolved Critical 2: outcome>
- ...

**Still open (Standard).**
- <Open Standard 1>
- <Open Standard 2>
- ...

**Your call** — stop here, push on, or promote a Standard to Critical first?
```

If the user picks:
- **Stop** → go to End State.
- **Push on** → resume with the next Open item, dependency-first.
- **Promote X** → re-tier the named Standard to Critical, move it to the front of Open, grill it next. The contract reopens until X resolves.

A new Critical can also surface mid-session (after a Checkpoint or before one). When it does, the contract reopens — no Checkpoint fires until that new Critical resolves.

### On-Demand Snapshot

If the user asks "what's open?", "show the queue", "where are we?", or equivalent at any turn, emit a one-shot snapshot before the next grilling turn:

```
**Snapshot.**
- Resolved (Critical): <list>
- Resolved (Standard): <list>
- Resolved (Refinement): <list>
- Open: <list with tier markers>
```

Then continue with the next grilling turn. Do not use this format unprompted — it's an escape hatch, not a default.

### Default Posture

Between Checkpoints, stop signals, and snapshot requests, keep going. **Do not preemptively declare "shared understanding reached" outside of a Checkpoint.** That call belongs to the user — directly via stop, or by accepting a Checkpoint stop.

## End State

When the user stops:

1. **Summarize briefly** — list Resolved Criticals (the contract) first, then Resolved Standards and Refinements, then any Open branches the user chose to skip. Tier groupings make the load-bearing set visible at a glance. Keep it to one short block; the conversation already contains the details.
2. **Offer the artifact** — this is the only turn in the skill that uses `AskUserQuestion`; grilling turns themselves stay plain prose. Call it with:
   - Header: "Summary"
   - Question: "Want me to write the resolved decisions to a summary doc in $CLAUDE_DOCS_ROOT?"
   - Options:
     - "Yes, write it" — Save markdown summary.
     - "No, we're good" — End without writing.
3. **If yes**: write a markdown doc to `$CLAUDE_DOCS_ROOT/grilling-ideas-<slug>-<YYYY-MM-DD>.md` containing the idea restatement, the contract (Resolved Criticals with recommendation + final outcome), other Resolved decisions grouped by tier, Open branches, and any notable dissents. If `$CLAUDE_DOCS_ROOT` is unset, fall back to `~/claude-docs/` and mention the fallback to the user.
4. **If no**: acknowledge and end. No file written.

## Anti-Patterns

- **Batching multiple questions into one turn.** One question per turn. Always.
- **Naked questions with no recommendation.** Every turn commits to a position.
- **Asking the user what the codebase can answer.** Read first.
- **Declaring "shared understanding reached" outside of a Checkpoint.** Only the user ends the session — directly via stop, or by accepting a Checkpoint.
- **Tier inflation.** Marking everything Critical so the contract never closes, or marking nothing Critical so a Checkpoint never fires. Critical means *load-bearing*, not *important*.
- **Premature Checkpoint.** Firing without satisfying both conditions (≥1 Critical Resolved AND no Open Criticals).
- **Treating the Checkpoint as "you should stop" rather than "you can stop informed."** Keep it neutral — the Checkpoint surfaces options, not a recommendation.
- **Caving on a position because the user pushed back with force rather than evidence.** Update on evidence, not pressure.
- **Dumping thinking-pattern scaffolding into the user-facing turn.** Use patterns silently; present the recommendation.
- **Writing the summary doc without being asked.** The artifact is opt-in.
- **Starting the grill without confirming the plan scope.** Restate first; grill after.

## Success Criteria

A good grilling session:

- [ ] One question per turn, every turn.
- [ ] Every question includes a committed recommendation with rationale.
- [ ] Critical and Refinement turns include a Tier line with one-clause rationale; Standard turns omit it.
- [ ] Tier inflation is avoided — Critical is reserved for load-bearing decisions only.
- [ ] Codebase questions are answered by reading code, not asking the user.
- [ ] Decisions are surfaced dynamically, not enumerated up front.
- [ ] Dependency-root decisions are grilled before their dependents.
- [ ] A Checkpoint fires when (and only when) at least one Critical is Resolved and no Criticals remain Open.
- [ ] The session ends when the user calls stop or accepts a Checkpoint stop.
- [ ] The summary doc is offered, not forced.
