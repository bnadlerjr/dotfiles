# Workflow — Shape From Raw Idea

Use when the user brings a rough idea or problem statement (a few sentences) and no draft yet. The sequence: set boundaries, rough out elements, address rabbit holes, grill, write.

---

## Step 1 — Confirm The Raw Material

Restate the idea in 2-3 sentences. Ask for anything obviously missing:

- What is the problem? (Not the solution — the problem.)
- Who feels it and when?
- What is the appetite — small (~2w) or big (~6w)?

If the user pitches a solution instead of a problem, pull them back. "You've told me *what to build* — I need *what's broken*."

**Do not proceed until appetite is named.** Appetite shapes everything downstream.

---

## Step 2 — Set The Boundaries

Write down, internally:

- **Problem** (concrete, specific — not "users want X")
- **Appetite** (fixed time budget — the circuit breaker)
- **Known constraints** (tech, org, regulatory)

If the problem is still a generic "users want X", push for the specific instance. A pitch rests on a concrete motivating case, not a category.

See [../references/shape-up-canon.md](../references/shape-up-canon.md) for the appetite rules and the circuit-breaker concept.

---

## Step 3 — Rough Out Elements (Fat-Marker Sketch)

Identify the key parts of the solution at **low fidelity**. This is the fat-marker sketch / breadboard stage — a breadboard names the places and the connections, not the screens.

Produce a list like:

```
Places: inbox, detail view, approval queue
Affordances: mark-as-reviewed, request-changes, escalate
Connections: inbox → detail → (approve | request-changes | escalate)
```

If you find yourself describing buttons, colors, layouts, or component libraries — stop. That's design, not shaping.

Use `tree-of-thoughts` internally if there are 2-3 viable shapes. Pick one, note the others in a line.

---

## Step 4 — Address Rabbit Holes

For each element, ask: *what could blow the appetite?* These are rabbit holes. They must be named and addressed at shaping time, not discovered at week 4 of a 6-week cycle.

Common rabbit-hole categories:

- **Integration unknowns** — "we'd need to know how X's API behaves under load"
- **Data-model unknowns** — "we don't know if events are 1:1 or 1:N with users"
- **Permission / auth unknowns** — "does this cross tenant boundaries?"
- **Migration unknowns** — "does existing data fit the new shape?"

For each rabbit hole, name the mitigation:

- Decide now (cut the scope, pick one side)
- Spike first (timebox a pre-cycle investigation)
- Rule out (declare it a no-go)

Use `atomic-thought` internally if a rabbit hole decomposes into independent unknowns.

---

## Step 5 — Declare No-Gos

Name what the team will explicitly **not** do, even if asked mid-cycle. No-gos prevent scope creep. Good no-gos are specific:

- "Not supporting bulk actions in v1 — single-item only"
- "Not building an admin UI — config via env vars"
- "Not integrating with the legacy billing API"

A pitch with zero no-gos is suspicious. Adjacent features always want in.

---

## Step 6 — Grill The Shape (MANDATORY)

Before writing the pitch, run the grill — see [`../SKILL.md#grill-the-shape`](../SKILL.md#grill-the-shape) for the invocation pattern and fallback. For shape-from-idea, focus the grill on:

- Whether the appetite fits the elements
- Hidden rabbit holes the shaping missed
- Implicit assumptions the user hasn't tested

Carry resolved decisions into the pitch. If a Critical invalidates the shape, return to Step 2 or Step 3 before writing.

---

## Step 7 — Write The Pitch

Use [../references/pitch-template.md](../references/pitch-template.md) for the structure. Per-section:

- **Problem** — the concrete motivating case. Include a real example if you have one.
- **Appetite** — small or big batch, with the week count. State it as a constraint.
- **Solution** — the fat-marker sketch in prose + ASCII breadboard if helpful. No screens.
- **Rabbit Holes** — each named with its mitigation.
- **No-gos** — bulleted, specific.

Apply `self-consistency` internally before returning:

- Does the appetite fit the elements? If not, cut scope or change appetite.
- Does every rabbit hole have a mitigation?
- Does the solution solve the *stated* problem?

Then run the **Polish For Human Readers** step from `../SKILL.md` — invoke the `writing-for-humans` skill via the `Task` tool on the assembled draft. Replace the draft with the polished output.

Return the polished pitch as markdown in the conversation. **Do not save to disk** — that's the slash command's job.
