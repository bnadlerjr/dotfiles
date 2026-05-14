# Workflow — Refine An Existing Draft

Use when the user brings an existing draft pitch. The sequence: read, critique against Shape Up canon, grill the gaps, rewrite.

---

## Step 1 — Read The Draft

Read the draft in full before commenting. If the user gave a path, use `Read`. If they pasted it, work from the message.

Identify what's present and what's missing against the standard structure:

- Problem ✓ / ✗
- Appetite ✓ / ✗ (and is it a constraint or an estimate?)
- Solution ✓ / ✗ (and is it at fat-marker fidelity or spec fidelity?)
- Rabbit Holes ✓ / ✗
- No-gos ✓ / ✗

---

## Step 2 — Critique The Draft

Evaluate against the canon ([../references/shape-up-canon.md](../references/shape-up-canon.md)) and the common failure modes ([../references/anti-patterns.md](../references/anti-patterns.md)). Look specifically for:

| Weakness | Symptom in draft | What it means |
|---|---|---|
| Appetite stated as estimate | "~3 weeks, maybe 4" | Not shaped — appetite is a fixed constraint |
| Solution is pixel-perfect | Screenshots, component names, copy | Over-designed — hides decisions in UI polish |
| No rabbit holes | Section missing or trivial | Unknowns are hidden — pitch will blow up mid-cycle |
| Rabbit holes without mitigations | "We'll figure this out" | Not addressed — just logged |
| No no-gos | Section missing | Scope creep guaranteed during build |
| Problem is generic | "Users want a faster X" | No concrete motivating case |
| Solution solves a different problem | Problem → Solution mismatch | Check for drift |

Present the critique briefly — one or two lines per finding. Do not rewrite yet.

---

## Step 3 — Grill The Gaps (MANDATORY)

Run the grill on the weaknesses found in Step 2 — see [`../SKILL.md#grill-the-shape`](../SKILL.md#grill-the-shape) for the invocation pattern and fallback. For draft refinement, focus the grill on:

- "Is the appetite really fixed? What gets cut if elements don't fit?"
- "What's the concrete motivating case for the problem?"
- "What rabbit holes does the solution hide?"
- "What adjacent asks should be no-gos?"

Carry the resolved decisions forward into the rewrite.

---

## Step 4 — Rewrite

Produce the revised pitch using [../references/pitch-template.md](../references/pitch-template.md). Preserve what was good in the original. Apply the grill's resolutions to fix what was weak.

Apply `self-consistency` internally:

- Does the rewritten Problem match what the Solution addresses?
- Does the Appetite match the Elements implied by the Solution?
- Do Rabbit Holes and No-gos reflect what the grill surfaced?

Then run the **Polish For Human Readers** step from `../SKILL.md` — invoke the `writing-for-humans` skill via the `Task` tool on the rewritten draft. Replace the draft with the polished output.

Return the polished pitch as markdown in the conversation. **Do not save to disk.**
