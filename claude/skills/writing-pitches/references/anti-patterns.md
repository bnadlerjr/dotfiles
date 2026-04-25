# Pitch Anti-Patterns — Reference

Common failure modes in pitch writing and shaping. Each entry: the smell, why it matters, and what to do instead.

---

## Appetite-as-estimate

**Smell**: "About 3 weeks, maybe 4." Ranges, hedges, qualifiers.

**Why it matters**: Appetite is a constraint. A range is a prediction. Predictions stretch; constraints force cuts. If you're ranging, the team has no pressure to cut scope — they'll just take the upper end (and overrun it).

**Instead**: Pick one size and commit. Small batch (2 weeks) or big batch (6 weeks). If the work doesn't fit, cut scope, not appetite.

---

## Spec masquerading as pitch

**Smell**: Screens, component names, specific copy, layouts, pixel values. Pages of detail.

**Why it matters**: A pitch is shaped work — rough enough to give the team room to design. A spec is fully designed work — leaves no room. Specs at pitch time freeze the wrong decisions early and rob the team of ownership.

**Instead**: Fat-marker sketch. Breadboard. Describe elements, not interfaces. If your pitch looks like a Figma export, you're past shaping.

---

## Wish-list pitch

**Smell**: Vague solution. "We need a better way to X." No elements named.

**Why it matters**: The other failure mode. Not shaped *enough*. Gives the team no boundaries, so they'll either freeze (no shape to build from) or reinvent the problem (they'll shape it themselves mid-cycle).

**Instead**: Rough out concrete elements. Name places, affordances, connections. "Fat-marker" is not "no marker."

---

## Hidden rabbit holes

**Smell**: Rabbit Holes section is missing, trivial, or full of handwaves. "We'll figure out the integration during the cycle."

**Why it matters**: Unknowns don't go away by omission — they detonate at week 3 of a 6-week cycle. Naming a rabbit hole and declaring how it's addressed is how you keep the appetite real.

**Instead**: For each unknown, name it and pick one:
- Decide now (cut scope, pre-commit)
- Spike first (timeboxed pre-cycle investigation)
- Rule out (becomes a no-go)

---

## Empty no-gos

**Smell**: No No-gos section, or bullets like "scope creep is out of scope."

**Why it matters**: During the cycle, every adjacent ask will test the boundary. Without explicit no-gos, the team has to re-litigate boundaries mid-build — wasting time and usually losing ground.

**Instead**: Name the specific things you know will be asked for. "Not supporting X." "Not integrating with Y." "Not building admin UI."

---

## Problem is generic

**Smell**: "Users want faster performance." "Our UX is confusing." No concrete case.

**Why it matters**: Generic problems produce generic solutions. A pitch rests on a motivating case — a specific person, a specific moment, a specific failure. Without it, you can't tell if the solution solves the actual problem.

**Instead**: Name the person, the moment, and what broke. "Last Tuesday, Sarah couldn't find the stale PRs buried in her 12-item review queue."

---

## Solution solves a different problem

**Smell**: Problem section talks about X. Solution section is about Y. Often a sign of drift between drafts.

**Why it matters**: Obvious in hindsight, easy to miss while writing. The team will notice, lose confidence in the pitch, and start second-guessing the whole frame.

**Instead**: Self-consistency check before returning the pitch — does the Solution's first paragraph directly address the Problem's first paragraph? If not, one of them needs to change.

---

## Skipping the grill

**Smell**: Writing the pitch straight through without stress-testing the shape.

**Why it matters**: Solo shaping misses rabbit holes. The drafter already believes in the idea — they won't surface its weaknesses alone. Grilling is the forcing function that exposes what the solo write-up hides.

**Instead**: Grill the shape (invoke `grilling-ideas`) *before* drafting the pitch. Every workflow in this skill requires it — not optional.

---

## Pitch as ticket

**Smell**: Short, directive, checklist-style. "Implement X with Y and Z."

**Why it matters**: A pitch is a bet — a compressed case for why this is worth a cycle. A ticket is a work-order. Treating the pitch as a ticket skips the framing that gets buy-in and leaves decisions unmade.

**Instead**: A pitch argues, briefly. Problem + appetite + solution + rabbit holes + no-gos, in prose. Tickets come later, after the bet is placed.

---

## Scope inflation under "small"

**Smell**: "Small batch" appetite with a solution that has five elements and three rabbit holes.

**Why it matters**: The appetite doesn't fit. Either the work is actually a big batch, or the scope needs cutting. Pretending it's small won't make it small.

**Instead**: Run the self-consistency check — does the solution fit the appetite? If not, either change the appetite or cut the solution. Don't split the difference.

---

## Treating the skill as a file-writer

**Smell**: Skill writes the pitch to disk instead of returning markdown.

**Why it matters**: This skill's contract is "return pitch markdown." The slash command handles saving. Writing to disk inside the skill creates race conditions with the command and violates the separation.

**Instead**: Return markdown in the conversation. Let `/shape-pitch` save it.
