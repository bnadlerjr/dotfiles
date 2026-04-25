# Pitch Template — Reference

The standard Shape Up pitch structure with per-section guidance.

---

## Template

```markdown
# <Pitch Title>

## Problem

<2-4 paragraphs. The concrete motivating case. Include a specific example if you have one. State who feels the problem, when, and what breaks today.>

## Appetite

<One line declaring the fixed time budget. "Small batch — 2 weeks." or "Big batch — 6 weeks." State it as a constraint, not a range.>

## Solution

<The shaped concept at fat-marker fidelity. Breadboard or ASCII sketch if useful. Describe elements and how they connect. Resist UI detail — no component names, no copy, no layout.>

## Rabbit Holes

<Each named unknown with its mitigation. See guidance below.>

## No-gos

<Explicit out-of-scope items. Specific, not categorical.>
```

---

## Per-Section Guidance

### Problem

- **Concrete**, not generic. "Engineering leads can't see which PRs are stale for >3 days" beats "better PR visibility."
- Include a real example if you have one. Named person + specific moment.
- State the current workaround and why it fails.
- Keep it tight — 2-4 paragraphs. If it takes a page, you haven't found the core.

**Bad**
> Our users want a better experience when reviewing pull requests.

**Good**
> When Sarah, a senior engineer, has 12 PRs assigned for review, she has no way to see which ones have been waiting longest. She ends up scanning GitHub's default list (sorted by update time, which buries stale PRs behind recent commits) and manually checking timestamps. Last sprint, two PRs sat for 9 days before she noticed.

### Appetite

- **One line.** Not a paragraph.
- State the size and the week count. "Small batch — 2 weeks."
- Do not hedge ("~3-4 weeks", "maybe 6 weeks"). If you're hedging, you haven't committed to an appetite.

**Bad**
> We'd like to do this in about 3 weeks, maybe up to 4 if integration is tricky.

**Good**
> Small batch — 2 weeks.

### Solution

- **Fat-marker fidelity.** Name elements, places, affordances, connections.
- Breadboards are welcome. ASCII is fine.
- No component libraries, no pixel specs, no final copy.
- Describe the **shape** of the solution, not its surface.

**Breadboard example**
```
Inbox view
  ├─ stale-first toggle (off by default)
  └─ item row ─(click)→ Detail view
                        ├─ approve (back to inbox, item gone)
                        ├─ request changes (compose → back)
                        └─ escalate (assign picker → back)
```

### Rabbit Holes

Each rabbit hole has three parts:

1. **What's the unknown?**
2. **Why could it blow the appetite?**
3. **How did we address it?** (decide now / spike / rule out)

**Example**
> **Cross-repo PR aggregation.** If we need to pull PRs across multiple GitHub orgs, auth token scoping gets complex and rate-limit coordination becomes its own project. **Addressed by ruling out** — v1 is single-org only. Cross-org is a no-go (see below).

### No-gos

- Specific, not categorical.
- Each no-go is one line, stated flatly.
- Prefer "not X" over "X is out of scope" — be direct.

**Example**
> - Not supporting multiple GitHub orgs — single-org only.
> - Not sending email digests — in-app notifications only.
> - Not integrating with Slack — defer to a separate pitch.

---

## Length Expectations

A shaped pitch is typically 1-3 pages. Longer means you've drifted into spec. Shorter usually means rabbit holes are hidden.

| Section | Rough length |
|---|---|
| Problem | 2-4 paragraphs |
| Appetite | 1 line |
| Solution | 1-2 pages including any sketch |
| Rabbit Holes | 3-7 items, 2-4 lines each |
| No-gos | 3-8 bullets |

These are norms, not limits. If the work genuinely has 12 rabbit holes, list them — don't compress.
