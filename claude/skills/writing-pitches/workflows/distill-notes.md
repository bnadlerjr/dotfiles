# Workflow — Distill Notes Into A Pitch

Use when the user brings meeting notes, research docs, Slack transcripts, or any raw material that contains a pitch-able concept buried inside. The sequence: extract signal, shape, grill, write.

---

## Step 1 — Ingest The Raw Material

Read the source in full. If it's a path, use `Read`. If multiple files, use `Glob` / `Read` as needed. Do not skim — pitches die when a buried constraint gets missed.

Expect noise-to-signal to be low. Meeting notes typically contain:

- Multiple problems blended together
- Proposed solutions mixed with requirements mixed with complaints
- Decisions made and unmade in the same thread
- Explicit scope and implicit scope

---

## Step 2 — Extract Signal

Use `atomic-thought` internally to decompose the source into independent buckets. Produce, for your own working notes:

```
Problems mentioned:    [list — concrete, specific]
Solutions proposed:    [list — whose, and how firm]
Constraints stated:    [timeboxes, tech limits, policy]
Decisions made:        [what's settled]
Open questions:        [what's unsettled]
People / stakeholders: [who cares about what]
```

Then pick **one pitch-able concept**. A single pitch has one problem and one fixed appetite. If the notes contain multiple candidate pitches, surface them to the user and ask which one to shape:

```
Your notes contain multiple threads I could shape into a pitch:
  A. <thread 1 — one-line summary>
  B. <thread 2 — one-line summary>
  C. <thread 3 — one-line summary>

Which one? (Or: do you want separate pitches for each?)
```

---

## Step 3 — Confirm Appetite

The notes may or may not contain an appetite. If they don't, ask before shaping — appetite is a constraint on everything downstream.

```
What's the appetite for this one — small batch (~2 weeks) or big batch (~6 weeks)?
```

Do not proceed without an answer.

---

## Step 4 — Shape

Run Steps 2-5 of [shape-from-idea.md](shape-from-idea.md):

- Set boundaries (problem, appetite, constraints)
- Rough out elements (fat-marker sketch)
- Address rabbit holes
- Declare no-gos

The notes may already contain material for each — lift it. Do **not** invent rabbit holes or no-gos that the notes don't support — ask the user if something seems ambiguous.

---

## Step 5 — Grill (MANDATORY)

Invoke the `grilling-ideas` skill via the Skill tool. Notes-derived pitches especially benefit from grilling because the shape is reconstructed from secondary material — assumptions about what was "decided" in the meeting are often wrong.

```
Skill tool invocation:
  skill: grilling-ideas
  args: Focus the grill on: what the notes assume vs. what's actually decided.
```

---

## Step 6 — Write The Pitch

Use [../references/pitch-template.md](../references/pitch-template.md). Return the pitch as markdown in the conversation. **Do not save to disk.**

Apply `self-consistency` internally before returning — especially check that the pitch reflects the grilled resolutions and not just the (potentially stale) notes.
