---
description: Shape notes or an idea into a Shape Up pitch, then run an interactive review loop.
argument-hint: "[rough idea | path to draft | path to notes | empty for interactive]"
---

# Shape Pitch

Shapes a raw idea, an existing draft, or a pile of notes into a Shape Up pitch.

**How review works.** Before the first user interaction, invoke the `running-human-review-loops` skill and use the transport it selects for the whole run. The command owns the shaping workflow; the skill owns Plannotator availability, fallback behavior, continuity, waiting, and feedback classification. This note is for whoever opens this file. Do not repeat it to the user.

## Rules

1. **Appetite is fixed before the solution is shaped.** Appetite is a time budget, not an estimate. Small batch is about 2 weeks, big batch about 6. Variable scope, fixed time. A 2-week appetite and a 6-week appetite produce different solutions, not more or less of the same one.
2. **Solutions stay at fat-marker fidelity.** Name places, affordances, and connections. No component names, no copy, no layout, no pixel values. If it looks like a spec, it is one.
3. **Every rabbit hole carries a mitigation.** One of: decide now, spike first, or rule out. An unknown with no mitigation is logged, not addressed.
4. **No-gos are specific.** "Not supporting bulk actions, single-item only" works. "Performance is out of scope" is a dodge.
5. **Never ask a naked question.** Every question to the user, in the gate or in Open Questions, carries a committed recommendation and the reasoning behind it. A bare "what should we do about X?" pushes the work back onto the user.
6. **A pitch message contains the pitch and nothing else.** First character is the `#` of the title. During review, the last character is the end of the final Open Question; after approval, it is the end of the final no-go. No preamble, review controls, sign-off, or workflow explanation.
7. **The review channel is chosen once.** Follow `running-human-review-loops` for every question, draft, review round, closure, and final pitch. Do not mix its Inbox and native transports.
8. **Review semantics stay here.** This command defines what to ask, what the choices mean, and how the pitch changes. Do not duplicate the skill's transport mechanics here.

## Phase 1. Classify the input

Inspect `$ARGUMENTS`. It is raw text, a path to a draft, a path to notes, or empty.

- **Empty.** Ask through the selected review channel what the user has: a rough idea, a draft to tighten, or notes to distill. Recommend rough idea as the lowest-commitment starting point. End the turn.
- **Starts with `/`, `~`, or `./`.** A path. `Read` it, then route on content.
- **Anything else.** A rough idea.

For a path, route on whether the standard headers (Problem, Appetite, Solution, Rabbit Holes, No-gos) are present. Section headings resembling a pitch mean a draft. Transcript, bullet, or timeline form means notes. If it is still ambiguous, ask through the review channel whether it is a draft or notes, include your recommendation and reasoning, then end the turn.

| Input | Route | Delta |
|---|---|---|
| Rough idea | Shape from scratch | Nothing extra |
| Existing draft | Refine | Critique first against the self-check list at the bottom of this file. Present the findings through the review channel, one line each, before the revised bare pitch. Preserve what already works |
| Notes or transcript | Distill | Read in full, do not skim. Separate problems, proposed solutions, stated constraints, settled decisions, and open questions. If several pitchable threads exist, ask which one through the review channel, recommend the thread with the clearest concrete problem, then end the turn. Do not invent rabbit holes or no-gos the notes do not support |

## Phase 2. Gate on what is missing

Ask through the selected review channel only for what the input still requires. Skip the phase entirely when the input fixes both. End the turn after asking.

- **Appetite.** Offer choices in this order: small batch (about 2 weeks), big batch (about 6 weeks). Appetite is blocking because every element is scoped against it. Recommend a size based on how many elements the input implies, and explain why in 1-3 sentences.
- **Concrete motivating case.** Ask only when the input names a category rather than an instance. Request a named person, a specific moment, and what broke. Recommend using the most recent real case the user observed, because a representative abstraction will hide the workaround and its cost.

Everything else that is uncertain goes into the draft as an Open Question. Do not hold the draft hostage to it.

## Phase 3. Shape and draft

Shape in this order. Do not reorder it. Writing before the rabbit holes are addressed produces a document that hides them.

1. **Set boundaries.** Problem, appetite, known constraints.
2. **Rough out elements.** The key conceptual parts. Places, affordances, connections. If you are describing buttons or colors, stop, that is design.
3. **Address rabbit holes.** For each element ask what could blow the appetite. Common sources: integration behavior, data-model shape, permission and tenancy boundaries, migration of existing data. Assign each one a mitigation.
4. **Declare no-gos.** What the team will not do even if asked mid-cycle.

Then write the pitch.

```markdown
# <Pitch Title>

## Problem

<2-4 paragraphs. The concrete motivating case. Who feels it, when, what breaks today, and what the current workaround costs.>

## Appetite

<One line. "Small batch, 2 weeks." State it as a constraint, never a range.>

## Solution

<Fat-marker fidelity. Elements and how they connect. ASCII breadboard if it helps.>

## Rabbit Holes

<Each unknown, why it threatens the appetite, and its mitigation.>

## No-gos

<Specific out-of-scope bullets.>
```

**Problem, bad**

> Our users want a better experience when reviewing pull requests.

**Problem, good**

> When Sarah, a senior engineer, has 12 PRs assigned for review, she has no way to see which ones have been waiting longest. She scans GitHub's default list, which sorts by update time and buries stale PRs behind recent commits, then checks timestamps by hand. Last sprint two PRs sat for 9 days before she noticed.

**Breadboard example**

```
Inbox view
  |- stale-first toggle (off by default)
  `- item row --(click)--> Detail view
                            |- approve (back to inbox, item gone)
                            |- request changes (compose, back)
                            `- escalate (assign picker, back)
```

**Rabbit hole example**

> **Cross-repo PR aggregation.** Pulling PRs across multiple GitHub orgs makes token scoping complex and turns rate-limit coordination into its own project. **Addressed by ruling out**: v1 is single-org.

Then append the review scaffold. It exists only while the pitch is under review and remains part of the bare pitch message.

```markdown
## Open Questions

- **Permissions.** Assuming project owner only can archive. Annotate if wrong.
- **Cross-tenant access.** Assuming out of scope for v1.
```

Each entry states a position the draft already commits to, so the user attacks a claim rather than answering a survey. This is the stress test. The draft takes the risk of being wrong in public instead of interrogating the user before they have seen anything.

Rough proportions: Problem 2-4 paragraphs, Appetite 1 line, Solution 1-2 pages including any sketch, Rabbit Holes 3-7 items at 2-4 lines each, No-gos 3-8 bullets. Total 1-3 pages. Longer means it drifted into spec. Shorter usually means rabbit holes are hidden.

Present the full draft through the selected review channel as an artifact-only draft. Add no review control or workflow commentary to the pitch itself.

## Phase 4. Review loop

Use these review dispositions. The Inbox transport renders them as a separate control after the draft; the native transport classifies the user's next response against them:

- **Revise from my feedback.** Apply the feedback and present the full pitch again.
- **Approve the shape.** Retire the Open Questions scaffold and produce the final pitch.
- **Stop shaping.** Close the session without another draft.

Recommend **Approve the shape** only after the draft passes every self-check. If it does not pass, fix the draft before presenting it. Let `running-human-review-loops` render the choices for its selected transport and return the disposition plus all available feedback.

| What returns | Action |
|---|---|
| Revision with actionable feedback | Apply all compatible feedback, resolve conflicts explicitly in the pitch, present the full revised pitch, then request disposition again |
| Revision without actionable feedback | Ask through the review channel what should change. State the draft's riskiest current assumption as the recommended place to focus, then end the turn |
| Approval with no shape-changing feedback | Incorporate any compatible wording clarification, then go to Phase 5 |
| Approval with feedback that changes scope, appetite, elements, rabbit-hole mitigation, or no-gos | Revise the pitch and run another review round, because the approved shape would otherwise differ from the final pitch |
| Stop | Close briefly through the selected review channel and stop |
| No answer | Wait on the selected review channel. Do not infer consent or duplicate the request elsewhere |

There is no round cap. Every round that waits on the user ends the turn, so the user sets the pace and the exit.

## Phase 5. Retire the scaffold

Approval settles the shape, and one thing is left: the review scaffold has to come off, because the approved message is the deliverable and `## Open Questions` is not part of a pitch.

Fold every entry the user did not answer into Rabbit Holes rather than dropping it, because an unresolved assumption is a rabbit hole by definition.

> **Cross-tenant access.** Unclear whether archiving crosses tenant boundaries. **Addressed by deciding now**: single-tenant only in v1.

Then delete the `## Open Questions` heading and deliver the pitch one last time as an artifact-only message through the selected review channel. Do not request another disposition. Stop there.

## Self-check

Run before emitting any draft.

- Appetite is one committed size, not a range
- The Solution names elements, not screens or components or copy
- Every rabbit hole has decide-now, spike, or rule-out
- No-gos are specific, not categorical
- The Problem names a person and a moment, not a category
- The Solution's first paragraph addresses the Problem's first paragraph
- The elements fit the appetite. If not, cut scope or change appetite. Do not split the difference
- The `running-human-review-loops` skill selected one transport before the first user interaction
- Every user decision has context, naturally ordered choices, and a committed recommendation
- The pitch body contains no workflow commentary
- No decision or draft review is duplicated across transports

On the Phase 5 delivery, add two more: no `## Open Questions` section remains, and no disposition request follows the final pitch.
