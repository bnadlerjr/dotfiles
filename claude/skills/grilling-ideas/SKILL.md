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
**Context.** <Why this decision matters. What depends on it.>

**Question.** <The specific question.>

**Recommendation.** <Your committed answer.>

**Rationale.** <Why. Cite evidence from codebase if relevant. Name the trade-off being made.>

**Your call** — agree, disagree, or propose an alternative?
```

### Examples

A single filled-in turn from a grilling session on a plan to add caching to an API endpoint:

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

Track the decision tree internally — in your working memory across turns, not as a file. Keep two implicit lists:

- **Resolved**: decisions the user has agreed to (or agreed after push-back).
- **Open**: decisions surfaced but not yet grilled.

When the user's answer to a question opens new sub-branches, add them to Open. When you pick the next question, scan Open and choose the node with the most children still depending on it.

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
- **Expands scope** — add new branches to Open. Return to dependency-first ordering when picking the next question.
- **Says stop** — stop. Go to End State.

## Relentless By Default, Respect Stop

Keep going until the user explicitly stops. Stop words include: "done", "enough", "that's enough", "stop", "I'm good", "we're good", "let's wrap", "let's stop", or obvious equivalents.

**Do not preemptively declare "shared understanding reached."** That call belongs to the user. Your job is to keep surfacing decisions until they tell you to stop. When they do, stop immediately — mid-branch is fine.

## End State

When the user stops:

1. **Summarize briefly** — list resolved decisions as bullets, then list any open branches the user chose to skip. Keep it to one short block; the conversation already contains the details.
2. **Offer the artifact** — this is the only turn in the skill that uses `AskUserQuestion`; grilling turns themselves stay plain prose. Call it with:
   - Header: "Summary"
   - Question: "Want me to write the resolved decisions to a summary doc in $CLAUDE_DOCS_ROOT?"
   - Options:
     - "Yes, write it" — Save markdown summary.
     - "No, we're good" — End without writing.
3. **If yes**: write a markdown doc to `$CLAUDE_DOCS_ROOT/grilling-ideas-<slug>-<YYYY-MM-DD>.md` containing the idea restatement, resolved decisions (with recommendation + final outcome), open branches, and any notable dissents. If `$CLAUDE_DOCS_ROOT` is unset, fall back to `~/claude-docs/` and mention the fallback to the user.
4. **If no**: acknowledge and end. No file written.

## Anti-Patterns

- **Batching multiple questions into one turn.** One question per turn. Always.
- **Naked questions with no recommendation.** Every turn commits to a position.
- **Asking the user what the codebase can answer.** Read first.
- **Declaring "shared understanding reached" preemptively.** Only the user ends the session.
- **Caving on a position because the user pushed back with force rather than evidence.** Update on evidence, not pressure.
- **Dumping thinking-pattern scaffolding into the user-facing turn.** Use patterns silently; present the recommendation.
- **Writing the summary doc without being asked.** The artifact is opt-in.
- **Starting the grill without confirming the plan scope.** Restate first; grill after.

## Success Criteria

A good grilling session:

- [ ] One question per turn, every turn.
- [ ] Every question includes a committed recommendation with rationale.
- [ ] Codebase questions are answered by reading code, not asking the user.
- [ ] Decisions are surfaced dynamically, not enumerated up front.
- [ ] Dependency-root decisions are grilled before their dependents.
- [ ] The session ends when the user says stop — not before, not after.
- [ ] The summary doc is offered, not forced.
