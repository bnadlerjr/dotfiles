# Skill Structure

Choosing a file layout, and the router pattern for skills that outgrow one file.

## Contents

- [The two shapes](#the-two-shapes) — single file vs. router
- [What the router solves](#what-the-router-solves)
- [Division of labour](#division-of-labour) — what belongs in each directory
- [SKILL.md as a router](#skillmd-as-a-router)
- [Workflow files](#workflow-files)
- [Reference files](#reference-files)
- [Depth](#depth) and [Reachability](#reachability)
- [Growing from single file to router](#growing-from-single-file-to-router)

## The two shapes

### Single file

```
skill-name/
└── SKILL.md
```

Use when there is one workflow, a small amount of knowledge, and no principles that
must survive being skipped. Most skills should start here.

### Router

```
skill-name/
├── SKILL.md              # principles + intake + routing (always loaded)
├── workflows/            # procedures — FOLLOW
├── references/           # domain knowledge — READ
├── assets/               # output structures — COPY AND FILL
└── scripts/              # executable code — RUN
```

Use when there are multiple distinct user intents (create vs. audit vs. debug),
different intents need different knowledge, essential principles must not be skipped,
or the skill has grown past roughly 200 lines and is still growing.

`workflows/` and the split into four directories are **conventions of this skill**, not
the spec. The spec names only `scripts/`, `references/`, and `assets/`, and permits any
additional directories — see [agent-skills-spec.md](agent-skills-spec.md).

## What the router solves

**Essential context gets skipped.** Guidance in a separate file may never be read.
→ Put principles directly in `SKILL.md`. It always loads; use that guarantee.

**The wrong context gets loaded.** A "build" task pulls in debugging references.
→ An intake question determines intent, routing sends the agent to one workflow, and
that workflow names the references it needs.

**Monolithic skills overwhelm.** 500+ lines of mixed content buries the relevant part.
→ Small router, focused workflows, a reference library loaded on demand.

**Procedures and knowledge get tangled.** "How to do X" mixed with "what X means".
→ Workflows are procedures (steps). References are knowledge (patterns, facts).

## Division of labour

| Directory | Contains | The agent... |
|---|---|---|
| `SKILL.md` | Principles, intake, routing table, indexes | always loads it |
| `workflows/` | Ordered procedures, each declaring what to read | follows one |
| `references/` | Patterns, technical detail, domain knowledge | reads what a workflow names |
| `assets/` | Templates and static resources | copies and fills |
| `scripts/` | Executable code | runs it; the code never enters context |

## SKILL.md as a router

````markdown
---
name: skill-name
description: What it does and when to use it.
---

# Skill Name

## How this skill works

Principles that apply to ALL workflows. Inline, because they cannot be skipped.

## What would you like to do?

Ask the user:

1. First option
2. Second option
3. Third option

**Wait for the response before proceeding.**

### Routing

| Answer | Workflow |
|---|---|
| 1, "keyword" | [workflows/option-a.md](workflows/option-a.md) |
| 2, "keyword" | [workflows/option-b.md](workflows/option-b.md) |
| anything else | Clarify, then route |

**After reading the workflow, follow it exactly.**

## Reference index

| Reference | Read it when |
|---|---|
| [thing.md](references/thing.md) | ...the condition that makes it relevant |
````

Two things make a routing table work: **every branch names a file**, and **the file
names are stable**, because callers may target them directly.

### Non-interactive callers

A router that only works by asking a question breaks for any caller that cannot ask —
a subagent, an automated pipeline, or a request that already contains the requirements.
State the contract in `SKILL.md` itself rather than making callers patch around it:

> If the request already contains the requirements, skip the intake question, choose
> the workflow yourself, and do not ask.

## Workflow files

````markdown
# Workflow: Name

**Read these first:**
1. references/relevant-file.md
2. references/another-file.md

## Step 1: Name
What to do.

## Step 2: Name
What to do.

## Success criteria

- [ ] Verifiable criterion
- [ ] Verifiable criterion
````

Required reading goes at the top so it loads before the steps that need it. Success
criteria must be checkable — "output validates with zero errors", not "user is
satisfied".

## Reference files

- **Keep them focused.** Agents load them whole; smaller files cost less context.
- **Give files over ~100 lines a contents list.** It lets the agent find the relevant
  section without reading everything.
- **One topic per file.** A reference that covers three unrelated things gets loaded
  three times as often as it needs to be.
- **Don't duplicate across files.** The exception is a hard safety constraint, which is
  worth repeating where it applies.

## Depth

The spec says keep references **one level deep** from `SKILL.md`, because agents may
only partially read files reached indirectly.

The router pattern is inherently two levels — `SKILL.md` → workflow → reference — and
that is fine, because the workflow *declares* its required reading explicitly rather
than leaving the agent to follow a link it may ignore.

Three levels is too many. `SKILL.md` → `a.md` → `b.md` → `c.md` means `c.md` is
effectively invisible. The bundled validator warns past two hops.

## Reachability

Every file in a skill must be reachable from `SKILL.md` — directly, or through a
workflow that names it. A file nothing references is dead weight that still ships,
still needs maintaining, and silently drifts out of agreement with the rest of the
skill.

This is the failure mode that turns a router into a broken skill: the intake question
survives a refactor but the routing table does not, and every workflow becomes
unreachable while `SKILL.md` grows its own duplicate copy of the same procedures.

```bash
uv run scripts/validate_skill.py path/to/skill
```

reports unreachable files, chains too deep, and links pointing at nothing.

## Growing from single file to router

When a single-file skill passes ~200 lines or acquires a second distinct intent:

1. Identify the distinct intents — these become workflows.
2. Extract each procedure into `workflows/<intent>.md`.
3. Extract shared knowledge into `references/`.
4. Reduce `SKILL.md` to principles, intake, routing, and the indexes.
5. **Delete the extracted content from `SKILL.md`.** Leaving a copy behind is how the
   two versions start contradicting each other.
6. Run the validator.

See [workflows/upgrade-to-router.md](../workflows/upgrade-to-router.md) for the full
procedure.
