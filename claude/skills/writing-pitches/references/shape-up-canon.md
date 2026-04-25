# Shape Up Canon — Reference

Expert notes on Ryan Singer's Shape Up methodology (Basecamp). Consult as needed; don't inline.

---

## Shaped vs. Unshaped Work

**Unshaped** — a raw idea, a complaint, a problem statement. Not ready for a team. No boundaries, no appetite, unknowns not examined.

**Shaped** — concrete enough to bet on, rough enough to leave room. Has a problem, an appetite, a rough solution, identified rabbit holes, and explicit no-gos. Decisions a team *shouldn't have to make* have already been made; decisions a team *should own* have been left open.

A well-shaped pitch trusts the team to design and build within the fences — it doesn't hand them a spec.

---

## Appetite

**Appetite = the fixed time budget you're willing to spend.** It is a *constraint*, not an estimate.

Two standard sizes:

| Size | Duration | For |
|---|---|---|
| Small batch | ~2 weeks | Contained, well-understood work. One or two elements. |
| Big batch | ~6 weeks | Meaningful new capability. Multiple elements, integration surface. |

Appetite sets the shape. A 2-week appetite and a 6-week appetite produce fundamentally different solutions — not just more or less of the same thing.

**The critical mental move**: don't ask "how long will this take?" (estimate). Ask "how much is this worth?" (appetite). Then scope to fit.

### Appetite, not estimate — why it matters

An estimate asks the team to predict the future. An appetite declares what the business will spend. Estimates always stretch; appetites don't, because when the work doesn't fit, you cut scope or kill the pitch — you don't extend the deadline.

---

## The Circuit Breaker

**The fixed deadline is the circuit breaker.** If the team can't ship within the appetite, the project *dies* — it doesn't roll over, doesn't extend, doesn't become a quiet taxing-of-attention. Kill it and free the team.

This is what makes appetite real. Without the circuit breaker, "appetite" is just another word for "estimate."

---

## Elements

The **elements** are the key parts of the solution. Not screens, not components — conceptual parts.

For an inbox triage feature, elements might be:

- The inbox view
- The triage action (mark-as-reviewed, request-changes, escalate)
- The audit trail
- The notification out

Elements are named at the fat-marker level. They are not detailed enough to hand to an engineer; they are detailed enough to verify that the appetite fits.

---

## Fat Marker Sketches and Breadboards

Two low-fidelity representations Singer advocates:

**Breadboard** — like an electrical breadboard. Names **places** (views, pages, modal states) and **connections** (what leads to what) and **affordances** (buttons/controls, labeled by function). No layout, no visual.

```
Inbox ─(item click)→ Detail ─(approve)→ (back to Inbox, item removed)
                            ─(request)→ Compose note → (back to Inbox)
                            ─(escalate)→ Assignment picker → (back to Inbox)
```

**Fat marker sketch** — a drawing made with a literal fat marker so the medium forbids detail. Blobs and arrows, not pixels.

Both are deliberately rough. The purpose is to resist UI polish so the underlying decisions stay visible.

---

## Rabbit Holes

A **rabbit hole** is a risky unknown — something that, if it goes sideways, blows the appetite. Rabbit holes must be addressed *at shaping time*, not discovered during the build.

Addressing a rabbit hole means doing one of:

1. **Decide now.** Cut the scope. Pick one side. Pre-commit.
2. **Spike first.** Timebox a pre-cycle investigation to reduce uncertainty.
3. **Rule out.** Declare it a no-go.

A pitch with no rabbit holes is either trivial or lying. Most work has them; most drafters hide them.

---

## No-gos

Explicit out-of-scope. A no-go says: "we will not do this, even if asked, during this cycle." No-gos prevent scope creep. They are specific, not categorical:

- Good: "Not supporting bulk actions — single-item only"
- Bad: "Performance is out of scope"

The first is actionable. The second is a dodge.

---

## The Shaping Sequence

Singer's canonical sequence:

1. **Set boundaries.** Problem, appetite, constraints.
2. **Rough out elements.** Fat-marker sketch. Breadboard.
3. **Address rabbit holes.** Decide, spike, or rule out.
4. **Declare no-gos.**
5. **Write the pitch.**

The sequence matters. Writing the pitch before addressing rabbit holes produces a document that hides unknowns. Rough-out before boundaries produces solutions chasing problems.

---

## Pitch Sections (Canonical)

Singer's pitch has five parts:

1. **Problem** — the raw motivating case. Specific. Concrete.
2. **Appetite** — how much time we're willing to spend.
3. **Solution** — the shaped concept at fat-marker fidelity.
4. **Rabbit Holes** — identified unknowns and how we addressed them.
5. **No-gos** — explicit out-of-scope.

Some teams add a short "Why now?" or "Why this?" line at the top. Optional. Everything else is optional too.

---

## What Is Out Of Scope Here

This skill covers shaping + pitch writing only. Adjacent Shape Up activities that are **not** part of this skill:

- **Betting table** — the meeting where shaped pitches are selected for the next cycle.
- **Cool-down** — the 2-week gap between cycles.
- **Scope hammering** — the mid-cycle practice of cutting scope to fit the appetite.
- **Hill charts** — the progress-tracking tool used during execution.

Don't try to do these in the pitch. The pitch is the input to the betting table, not a substitute for it.
