---
name: domain-modeling
description: Builds and sharpens a project's domain model. Use when discussing codebase terminology, writing or editing GLOSSARY.md, GLOSSARY-MAP.md, CONTEXT.md, or CONTEXT-MAP.md files, or recording or editing an ADR.
---

# Domain Modeling

Actively build and sharpen the project's domain model as you design. This is the *active* discipline: challenging terms, inventing edge-case scenarios, and writing the domain language and decisions down the moment they crystallise. Merely reading a domain language file for vocabulary is not this skill. This skill is for changing the model, not just consuming it.

## File structure

Most repos have a single context:

```
/
├── GLOSSARY.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

Some repos use `CONTEXT.md` instead of `GLOSSARY.md`. Support both naming conventions. Resolve the files to use in this order:

1. If `GLOSSARY-MAP.md` exists, use it and the domain language files it names.
2. Otherwise, if `CONTEXT-MAP.md` exists, use it and the domain language files it names.
3. Otherwise, if a root `GLOSSARY.md` exists, use it.
4. Otherwise, if a root `CONTEXT.md` exists, use it.
5. If none exists, prefer the glossary convention: create a root `GLOSSARY.md` lazily when the first term is resolved.

If both versions exist at the same level, prefer the `GLOSSARY` version. Do not create a parallel `GLOSSARY` file merely to rename an established `CONTEXT` convention.

A map file means the repo has multiple contexts. It points to where each context lives. For example:

```
/
├── GLOSSARY-MAP.md
├── docs/
│   └── adr/                          ← system-wide decisions
├── src/
│   ├── ordering/
│   │   ├── GLOSSARY.md
│   │   └── docs/adr/                 ← context-specific decisions
│   └── billing/
│       ├── GLOSSARY.md
│       └── docs/adr/
```

Create files lazily: only when you have something to write. Use the resolution order above to choose the domain language file. If no `docs/adr/` exists, create it when the first ADR is needed.

## During the session

### Challenge against the domain language

When the user uses a term that conflicts with the existing language in the chosen `GLOSSARY.md` or `CONTEXT.md`, call it out immediately. "The domain language file defines 'cancellation' as X, but you seem to mean Y. Which is it?"

### Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical term. "You're saying 'account': do you mean the Customer or the User? Those are different things."

### Discuss concrete scenarios

When domain relationships are being discussed, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with code

When the user states how something works, check whether the code agrees. If you find a contradiction, surface it: "Your code cancels entire Orders, but you just said partial cancellation is possible. Which is right?"

### Update the domain language file inline

When a term is resolved, update the chosen `GLOSSARY.md` or `CONTEXT.md` right there. Don't batch these up: capture them as they happen. Use the format in [references/glossary-format.md](references/glossary-format.md).

The domain language file should be totally devoid of implementation details. Do not treat it as a spec, a scratch pad, or a repository for implementation decisions. It defines the domain language and nothing else.

### Offer ADRs sparingly

Only offer to create an ADR when all three are true:

1. **Hard to reverse**: the cost of changing your mind later is meaningful
2. **Surprising without context**: a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off**: there were genuine alternatives and you picked one for specific reasons

If any of the three is missing, skip the ADR. Use the format in [references/adr-format.md](references/adr-format.md).
