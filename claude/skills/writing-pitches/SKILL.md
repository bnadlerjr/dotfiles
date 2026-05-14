---
name: writing-pitches
description: "Write Shape Up style pitches (Basecamp / Ryan Singer). Use when shaping a raw idea, refining a draft pitch, distilling notes into a pitch, or when the user mentions Shape Up, pitch, shaping, appetite, rabbit holes, no-gos, or fixed time / variable scope. Produces a pitch document with Problem, Appetite, Solution, Rabbit holes, and No-gos."
allowed-tools: Read, Grep, Glob, Skill, Task
---

# Writing Shape Up Pitches

Shape a raw concept and write the pitch that bets get placed on. This skill covers the shaping work (setting boundaries, roughing out elements, exposing rabbit holes, declaring no-gos) and the document that results. Betting-table prep, cool-down, and scope-hammering-during-build are out of scope.

## What A Pitch Is (And Is Not)

A pitch is **shaped work ready to be bet on** — a concrete problem, a fixed appetite, a sketched-but-rough solution, identified rabbit holes, and explicit no-gos. It is not a spec. It is not a fully designed feature. It is not a backlog item.

If the concept has no appetite, no rabbit holes identified, or the solution is either (a) a vague wish or (b) pixel-perfect design, it is **not yet shaped** — do shaping work first, write the pitch after.

## Quick Start

If no input was provided with the invocation, respond with:

```
I'll help you write a Shape Up pitch. What do you have?

- A rough idea or problem statement
- An existing draft pitch to tighten
- Meeting notes or research to distill

Also — what's your appetite? Small batch (~2 weeks) or big batch (~6 weeks)?
Appetite is a constraint, not an estimate. Pick one before we shape.
```

Once the user answers, consult Routing below to pick the workflow.

## Routing — Pick The Workflow

Route on what the user brought:

| Input the user brought | Workflow | When to pick |
|---|---|---|
| Rough idea / problem statement (few sentences) | [workflows/shape-from-idea.md](workflows/shape-from-idea.md) | No draft exists yet. Need to shape first, then write. |
| Existing draft pitch (any fidelity) | [workflows/refine-draft.md](workflows/refine-draft.md) | Draft exists but is weak — missing appetite, hiding unknowns, too-detailed UI, etc. |
| Meeting notes, research docs, Slack threads | [workflows/distill-notes.md](workflows/distill-notes.md) | Raw material exists but not yet a pitch. Signal needs to be extracted before shaping. |

**Heuristic** for borderline inputs: section headings resembling a pitch → `refine-draft`; transcript / bullet / timeline form → `distill-notes`; otherwise → `shape-from-idea`.

If the input is still ambiguous after applying the heuristic, ask one clarifying question as plain conversation text in your response, then stop and wait for the user's reply — do not guess.

## Non-Negotiables

These apply in every workflow. Violating them produces a spec or a wish, not a pitch.

1. **Appetite is set before the solution.** Appetite is the fixed time budget (small ~2w, big ~6w). Variable scope, fixed time. If you don't know the appetite, don't start shaping — ask.
2. **Grill the shaped concept before writing the pitch.** Actively invoke the `grilling-ideas` skill via the Skill tool once the shape feels coherent and before drafting. This is not optional. The grill surfaces hidden rabbit holes and validates the appetite against the elements.
3. **Solutions are fat-marker sketches, not screens.** Breadboards and rough sketches only. Pixel-perfect UI at pitch time is a Shape Up anti-pattern — it hides decisions inside design polish.
4. **Rabbit holes are named, not hidden.** An unknown that could blow the appetite must appear in the Rabbit Holes section with a mitigation — even if the mitigation is "we ruled this out of scope."
5. **No-gos are explicit.** What the team will **not** do, even if asked. This prevents scope creep during build.
6. **The skill does not save files.** It returns the pitch as markdown in the conversation. Saving is the slash command's job.
7. **Polish for human readers before returning.** Pitches are read aloud at betting tables and circulated to the team. After writing the draft, run it through the `writing-for-humans` skill — see [Polish For Human Readers](#polish-for-human-readers) below. Not optional.

## Process — High Level

```
Raw input ──▶ Shape ──▶ Grill ──▶ Write pitch ──▶ Polish ──▶ Return markdown
                ▲         │                       (writing-for-humans)
                └─────────┘
                (back to Shape if the grill invalidates the shape)

Shape decomposes into:
  ├─ Set boundaries (problem, appetite)
  ├─ Rough out elements (fat-marker sketch)
  ├─ Address rabbit holes
  └─ Declare no-gos
```

The shaping steps are the same in every workflow — only the starting material differs. See the routed workflow file for the specific sequence.

## Thinking Patterns — When To Use Each

Reason in the style of these patterns internally. Do not dump the scaffolding into the user's turn. These are reasoning styles, not skills to invoke — do not call the `thinking-patterns` skill from this skill. The only sanctioned Skill/Task calls this skill makes are the grill (see [Grill The Shape](#grill-the-shape)) and the readability polish (see [Polish For Human Readers](#polish-for-human-readers)).

| Pattern | When in shaping |
|---|---|
| `atomic-thought` | Decomposing a rabbit hole into independent unknowns. Splitting a fuzzy element into concrete sub-elements. |
| `tree-of-thoughts` | Multiple viable solution shapes. Pick one, present it as the recommendation, note the alternatives considered in one line. |
| `self-consistency` | Final validation before returning the pitch — check appetite vs. elements, problem vs. solution, rabbit holes addressed. |

## Grill The Shape

Mandatory before writing any pitch. Every workflow calls this same step — the only thing that changes is what the grill is focused on.

Invoke the `grilling-ideas` skill via the Skill tool:

```
Skill: grilling-ideas
args: "Focus on: <the specific weaknesses or assumptions you want stress-tested>"
```

Wait for the grill to complete before drafting. The goal is to surface hidden rabbit holes, challenge the appetite against the elements, and catch implicit assumptions. When the grill resolves or the user calls stop, carry the resolved decisions into the pitch.

The routed workflow picks the focus — e.g., `shape-from-idea` grills the shape, `refine-draft` grills the gaps in the existing draft, `distill-notes` grills the assumptions baked into the source notes.

If the grill surfaces a Critical that invalidates the shape (e.g., the appetite doesn't fit the elements), return to the shaping steps before writing — do not paper over it in the pitch.

**Skill fallback**: If the Skill tool is unavailable (e.g., running inside a sub-agent), inline the grilling questions yourself using the patterns in the `grilling-ideas` skill — ask the user the hardest 3-5 questions about the shape, appetite, and rabbit holes, then wait for answers before drafting.

## Polish For Human Readers

The last step before returning the pitch. Apply the `writing-for-humans` methodology to remove LLM tics, hedging, and structural bloat. A pitch read at a betting table cannot afford "leverage", "comprehensive", or "in order to".

Invoke via the `Task` tool with a `general-purpose` sub-agent:

```
Task tool:
  subagent_type: general-purpose
  description: "Polish pitch for human readers"
  prompt: |
    Read: ~/.claude/skills/writing-for-humans/SKILL.md

    Apply the writing-for-humans methodology to the Shape Up pitch below.

    PRESERVE verbatim:
    - Section headings (Problem, Appetite, Solution, Rabbit Holes, No-gos)
    - ASCII breadboards / fat-marker sketches inside the Solution section
    - Code blocks and inline code
    - Specific names, numbers, week counts, and time budgets
    - Rabbit-hole mitigations and no-go bullets — tighten wording but do
      not drop items or change their meaning

    Do NOT invent rabbit holes, no-gos, or constraints. Do NOT soften
    appetite into an estimate. Do NOT add UI detail to the Solution.

    Return ONLY the rewritten pitch as a complete markdown document. No
    meta-commentary.

    ---
    [paste pitch draft here]
```

Replace the draft with the sub-agent's output. Spot-check that breadboards, week counts, and no-go bullets survived before returning.

**Sub-agent fallback**: If `Task` is unavailable (e.g., running inside another sub-agent), inline the polish: read `~/.claude/skills/writing-for-humans/SKILL.md`, run the diagnostic checklist against the draft, apply the top three fixes (banned words, hedging, passive voice), and return the result. Note "Inline polish — Task tool unavailable" in your return so the caller knows.

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

## Example

**Input:** "I want to let users archive old projects, ~2 weeks."

**Output (skeleton — actual pitches go deeper per section):**

```markdown
# Archive Old Projects

## Problem
Active project lists are cluttered with finished work. Users scroll past
dozens of dead projects to find the two they care about. Concrete case:
@alice has 47 projects, 6 are live.

## Appetite
Small batch — 2 weeks. Fixed. If elements don't fit, we cut scope.

## Solution
Fat-marker sketch:

  [Project list] --archive--> [Archived view]
                  <--restore--

Places: project list, archived view. Affordances: archive, restore.
No bulk actions in v1.

## Rabbit Holes
- Permissions: who can archive? → Decide now: project owner only.
- Search indexing of archived projects → Spike day 1, 4-hour timebox.

## No-gos
- No bulk archive (single-item only).
- No auto-archive by age.
- No separate "deleted" state — archive is reversible-only.
```

The example is illustrative — real sections carry more substance. See
[references/pitch-template.md](references/pitch-template.md) for the full
structure and per-section guidance.

## Anti-Patterns

- Writing the pitch before grilling the shape. The grill is the forcing function that surfaces hidden rabbit holes — skip it and the pitch ships with landmines.
- Stating appetite as an estimate ("~3 weeks, maybe 4"). Appetite is fixed. If the work can't fit, change the scope or change the appetite — don't hedge.
- Pitches with no rabbit holes. Either the work is trivial (in which case it doesn't need a pitch) or you haven't looked hard enough. Look harder.
- Screens and flows at pitch fidelity. If it looks like a spec, it is one.
- Omitting no-gos. An empty no-gos section means every adjacent request becomes in-scope during build. Name what's out.
- Saving the pitch to disk. The skill returns markdown; the caller saves.
- Returning the unpolished first draft. LLM tics ("leverage", "comprehensive", "in order to") and hedging slip into pitches without a polish pass. Skip the polish and the pitch reads like a memo, not a bet.
