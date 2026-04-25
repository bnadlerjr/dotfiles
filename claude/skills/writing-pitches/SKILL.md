---
name: writing-pitches
description: "Write Shape Up style pitches (Basecamp / Ryan Singer). Use when shaping a raw idea, refining a draft pitch, distilling notes into a pitch, or when the user mentions Shape Up, pitch, shaping, appetite, rabbit holes, no-gos, or fixed time / variable scope. Produces a pitch document with Problem, Appetite, Solution, Rabbit holes, and No-gos."
allowed-tools: Read, Grep, Glob, AskUserQuestion, Skill
---

# Writing Shape Up Pitches

Shape a raw concept and write the pitch that bets get placed on. This skill covers the shaping work (setting boundaries, roughing out elements, exposing rabbit holes, declaring no-gos) and the document that results. Betting-table prep, cool-down, and scope-hammering-during-build are out of scope.

## What A Pitch Is (And Is Not)

A pitch is **shaped work ready to be bet on** — a concrete problem, a fixed appetite, a sketched-but-rough solution, identified rabbit holes, and explicit no-gos. It is not a spec. It is not a fully designed feature. It is not a backlog item.

If the concept has no appetite, no rabbit holes identified, or the solution is either (a) a vague wish or (b) pixel-perfect design, it is **not yet shaped** — do shaping work first, write the pitch after.

## Routing — Pick The Workflow

Route on what the user brought:

| Input the user brought | Workflow | When to pick |
|---|---|---|
| Rough idea / problem statement (few sentences) | [workflows/shape-from-idea.md](workflows/shape-from-idea.md) | No draft exists yet. Need to shape first, then write. |
| Existing draft pitch (any fidelity) | [workflows/refine-draft.md](workflows/refine-draft.md) | Draft exists but is weak — missing appetite, hiding unknowns, too-detailed UI, etc. |
| Meeting notes, research docs, Slack threads | [workflows/distill-notes.md](workflows/distill-notes.md) | Raw material exists but not yet a pitch. Signal needs to be extracted before shaping. |

If the input is ambiguous, ask one clarifying question via `AskUserQuestion` — do not guess.

### Initial Response

If no input was provided with the invocation, respond with:

```
I'll help you write a Shape Up pitch. What do you have?

- A rough idea or problem statement
- An existing draft pitch to tighten
- Meeting notes or research to distill

Also — what's your appetite? Small batch (~2 weeks) or big batch (~6 weeks)?
Appetite is a constraint, not an estimate. Pick one before we shape.
```

## Non-Negotiables

These apply in every workflow. Violating them produces a spec or a wish, not a pitch.

1. **Appetite is set before the solution.** Appetite is the fixed time budget (small ~2w, big ~6w). Variable scope, fixed time. If you don't know the appetite, don't start shaping — ask.
2. **Grill the shaped concept before writing the pitch.** Actively invoke the `grilling-ideas` skill via the Skill tool once the shape feels coherent and before drafting. This is not optional. The grill surfaces hidden rabbit holes and validates the appetite against the elements.
3. **Solutions are fat-marker sketches, not screens.** Breadboards and rough sketches only. Pixel-perfect UI at pitch time is a Shape Up anti-pattern — it hides decisions inside design polish.
4. **Rabbit holes are named, not hidden.** An unknown that could blow the appetite must appear in the Rabbit Holes section with a mitigation — even if the mitigation is "we ruled this out of scope."
5. **No-gos are explicit.** What the team will **not** do, even if asked. This prevents scope creep during build.
6. **The skill does not save files.** It returns the pitch as markdown in the conversation. Saving is the slash command's job.

## Process — High Level

```
Raw input ──▶ Shape ──▶ Grill (grilling-ideas skill) ──▶ Write pitch ──▶ Return markdown
              │
              ├─ Set boundaries (problem, appetite)
              ├─ Rough out elements (fat-marker sketch)
              ├─ Address rabbit holes
              └─ Declare no-gos
```

The shaping steps are the same in every workflow — only the starting material differs. See the routed workflow file for the specific sequence.

## Thinking Patterns — When To Use Each

Reason in the style of these patterns internally. Do not dump the scaffolding into the user's turn.

| Pattern | When in shaping |
|---|---|
| `atomic-thought` | Decomposing a rabbit hole into independent unknowns. Splitting a fuzzy element into concrete sub-elements. |
| `tree-of-thoughts` | Multiple viable solution shapes. Pick one, present it as the recommendation, note the alternatives considered in one line. |
| `self-consistency` | Final validation before returning the pitch — check appetite vs. elements, problem vs. solution, rabbit holes addressed. |

## Reference Material

Consult as needed — do not inline these into responses:

- [references/shape-up-canon.md](references/shape-up-canon.md) — appetite, elements, rabbit holes, circuit breaker, shaped vs unshaped, breadboards vs fat markers
- [references/pitch-template.md](references/pitch-template.md) — the standard pitch structure with per-section guidance
- [references/anti-patterns.md](references/anti-patterns.md) — common pitch failures and what to do instead

## Output Contract

The skill's final output is **one markdown document** — the pitch — returned in the conversation. Structure per [references/pitch-template.md](references/pitch-template.md):

```markdown
# <Pitch Title>

## Problem
## Appetite
## Solution
## Rabbit Holes
## No-gos
```

Do **not** write the pitch to disk. The caller handles persistence.

## Anti-Patterns

- Writing the pitch before grilling the shape. The grill is the forcing function that surfaces hidden rabbit holes — skip it and the pitch ships with landmines.
- Stating appetite as an estimate ("~3 weeks, maybe 4"). Appetite is fixed. If the work can't fit, change the scope or change the appetite — don't hedge.
- Pitches with no rabbit holes. Either the work is trivial (in which case it doesn't need a pitch) or you haven't looked hard enough. Look harder.
- Screens and flows at pitch fidelity. If it looks like a spec, it is one.
- Omitting no-gos. An empty no-gos section means every adjacent request becomes in-scope during build. Name what's out.
- Saving the pitch to disk. The skill returns markdown; the caller saves.
