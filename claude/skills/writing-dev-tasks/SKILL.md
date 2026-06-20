---
name: writing-dev-tasks
description: Write well-scoped, verifiable development tasks for non-user-facing work — refactors, test work, and dependency/tooling changes. Use to "write a dev task", create a "refactor task", a "tech-debt ticket", a "test task", or a "dependency upgrade task"; to capture "non-user-facing work" or a "technical task"; or to write a "definition of done for a refactor". Produces an implementation-focused task with a verifiable Definition of Done. For user-facing behavior, use writing-agile-stories instead.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
---

# Writing Dev Tasks

Reference for well-scoped, verifiable development tasks covering non-user-facing work: refactors, test work, and dependency/tooling changes. Dev tasks describe **what changes in the code and how we verify it's done and safe** — naming modules, files, dependencies, and structure is the subject, not a leak.

This is the technical-work counterpart to the `writing-agile-stories` skill. Where stories capture **user-facing behavior** (Given-When-Then, no implementation detail), dev tasks capture **non-user-facing change** (implementation-first, verifiable Definition of Done). If the work produces observable behavior a user would notice, write a story instead. If it restructures code, hardens tests, or moves dependencies without changing observable behavior, write a dev task.

This is a **non-interactive reference skill**. Callers — direct users, orchestrator commands, and sub-agents — supply context and apply this guidance directly. Do not use `AskUserQuestion`. If context is thin, ask the user in plain prose for what's missing (see [discovery-dimensions.md](references/discovery-dimensions.md)).

## Quick Start

A complete dev task:

```markdown
## Task: Extract auth checks out of the legacy module

The `auth/` package reaches into `legacy/` for session validation, which blocks
us from deleting `legacy/` and forces a circular build dependency. Move the
session-validation logic into `auth/session.ts` and have `legacy/` call into
`auth/` instead, with no change to who is allowed in.

### Scope
In: `auth/session.ts`, `auth/index.ts`, the `legacy/gatekeeper.ts` call sites.
Out: token format, password hashing, the public `authenticate()` signature.

### Invariants
- Observable auth behavior is unchanged: the same requests are allowed/denied.
- `authenticate()` keeps its current signature and return type.

### Definition of Done
- [ ] Full test suite passes, no new failures
- [ ] `auth/` no longer imports from `legacy/`
- [ ] No public API signatures changed
- [ ] Typecheck + lint clean
```

This is an illustrative teaser. For the canonical version of this task with full sections, see [templates.md](references/templates.md). For additional worked examples spanning all three task types, see [examples.md](references/examples.md).

## When This Skill Applies

- **Refactors** — restructuring code without changing observable behavior (extracting modules, breaking dependencies, renaming, deduplicating).
- **Test work** — adding coverage, updating or migrating tests, fixing flaky tests, writing characterization tests before a change.
- **Dependency & tooling changes** — dependency upgrades, build/CI/config changes, adopting a linter or formatter.
- User asks to "write a dev task", "tech-debt ticket", "refactor task", or "definition of done for a refactor".

If the request is about something a user can see or do — a feature, a flow, a screen, a public API contract changing — route to `writing-agile-stories`. Performance optimization and data/infra migrations are out of scope for this skill; the framing may generalize, but it does not have sections built for them.

## Core Principles

1. **Implementation is the subject** — name the modules, files, dependencies, and structure. Concreteness here is correct, not a leak.
2. **Behavior is the invariant** — for refactors especially, state what must NOT change and how that is verified.
3. **Done by verifiable outcome** — define the end state as objectively checkable conditions, not a list of editing steps. Steps belong in a plan.
4. **Invariants are first-class** — capture what must not change (behavior, public API, contracts, on-disk formats) explicitly.
5. **Bounded blast radius** — state what's in scope and what's explicitly out, so the reviewer can reason about risk.

## Process Overview

The workflow has four phases. The task document has a Title, Narrative, Scope, Invariants, and Definition of Done — discovery and review are workflow phases, not document sections.

```
┌───────────┐   ┌───────────┐   ┌───────────┐   ┌───────────┐
│ Discovery │──▶│ Drafting  │──▶│ Definition│──▶│  Review   │
│           │   │           │   │  of Done  │   │           │
│ Six       │   │ Narrative │   │ Verifiable│   │ Quality   │
│ dimens.   │   │ + Scope   │   │ checklist │   │ + polish  │
│           │   │ + Invar.  │   │           │   │           │
└───────────┘   └───────────┘   └───────────┘   └───────────┘
```

## The Primary Anti-Pattern: Behavior-Change Leak in a Refactor

The single most common defect in a refactor task. A refactor must preserve observable behavior; the task leaks if it quietly smuggles in a behavior change under the banner of "cleanup":

- Renaming a method *and* changing what it returns in an edge case
- "While I'm in here" bug fixes folded into a move
- Tightening or loosening validation during an extraction
- Changing defaults, ordering, or error messages during a restructure

A behavior change might be desirable — but it is a separate task with its own verification (and, if user-observable, its own story). A refactor task must state the **behavior-preservation invariant** and how it is verified: the existing suite passes unchanged. If coverage over the touched code is thin, the task's first move is to **add characterization tests** that pin current behavior, then refactor under their protection.

**Substitution test (the refactor mirror of Farley's behavior test)**: if you reverted to the old structure, every test that passes now should still pass, and vice versa. If a test had to change to describe *new* behavior, you changed behavior — split it out.

For test-work and dependency/tooling tasks the same instinct applies: the change should be invisible to consumers unless the task explicitly says otherwise. See [anti-patterns.md](references/anti-patterns.md) for concrete leak examples and rewrites.

---

## Phase 1: Discovery

**Goal**: Gather the dimensions needed to draft.

The six dimensions: **Motivation, Scope & Blast Radius, Invariants, Verification, Risks & Rollback, Definition of Done**. See [discovery-dimensions.md](references/discovery-dimensions.md) for definitions, examples, and what each missing dimension does to the task.

If the caller has supplied context (Jira/Linear ticket, an ADR, prior conversation, a failing build, a flaky-test report), extract the dimensions from that context. If the dimensions are thin, ask the user in plain prose for the missing ones — open-ended discovery questions don't fit `AskUserQuestion` option chips.

### Research Depth

Unlike story writing, implementation-level codebase research is **expected and appropriate** here — dev tasks are about implementation. Read the modules in scope, check imports and call sites, and identify what's coupled. Use `Grep`/`Glob` to map the blast radius and `codebase-analyzer`-style agents to understand coupling.

Two limits keep this bounded:

1. **Map the blast radius; don't design the implementation.** Discovery establishes what's in scope, what's coupled, and what must not change. The step-by-step *how* belongs in a plan, not the task.
2. **Establish the coverage baseline.** For refactors and test work, check whether the touched code is currently tested. If coverage is thin, that's a discovery finding that turns into a "characterization tests first" item in the Definition of Done.

### Discovery Output (internal scratchpad)

```
**Understanding**: [1-2 sentence summary]
**Motivation**: [Why now — debt/risk/friction]
**Scope**: In: [paths/modules] | Out: [explicitly excluded]
**Invariants**: [What must NOT change]
**Verification**: [How we know it's done AND safe]
**Risks & Rollback**: [What could break | how to detect | how to back out]
**Coverage baseline**: [Tested? Characterization tests needed?]
```

---

## Phase 2: Task Drafting

**Goal**: Write a task that states the motivation, bounds the scope, and pins the invariants.

### Task Format

```markdown
## Task: [Descriptive Title — the change, not a feature]

[2-4 sentence narrative describing:
 - The debt/risk/friction that drives the work (why now)
 - The structural change being made
 - What stays the same (the behavior-preservation stance)
Written in concrete, technical terms — name the real modules and paths]

### Scope
In: [files/modules/paths touched]
Out: [explicitly excluded — what this task will NOT change]

### Invariants
- [What must NOT change: behavior, public API, contracts, on-disk formats]
```

For the canonical complete template and the discovery scratchpad template, see [templates.md](references/templates.md). For full worked examples (including discovery summaries), see [examples.md](references/examples.md).

### Narrative Guidelines

**DO**:
- Name the real modules, files, dependencies, and versions
- State the motivation: what debt, risk, or friction drives the work now
- State the behavior-preservation stance explicitly for refactors
- Keep it small enough to land and verify in one focused change

**DON'T**:
- Write it as a user story ("As a developer, I want…") — this is not user-facing
- Bury a behavior change inside a "cleanup" task (see Behavior-Change Leak above)
- Turn the narrative into a step-by-step edit list (steps belong in a plan)
- Leave scope open-ended ("clean up the auth code")

---

## Phase 3: Definition of Done

**Goal**: Define the verifiable end state as a checklist of objectively checkable conditions.

This is the analogue of acceptance criteria for a story, but it is a **Definition of Done**, not Given-When-Then. Each item must be something a person or CI can objectively confirm — pass/fail, present/absent, true/false — without judgment.

### Condition Types to Cover

1. **Safety** — the behavior-preservation gate (existing suite passes, no new failures; characterization tests added first where coverage was thin).
2. **Outcome** — the structural end state achieved (e.g., "`auth/` no longer imports from `legacy/`", "dependency at `^5.0.0`", "no `any` in the migrated module).
3. **Invariant** — the things that must NOT have changed, asserted (e.g., "no public API signatures changed", "on-disk format unchanged").
4. **Gates** — the standing quality bars (typecheck, lint, build, CI green, coverage threshold).

### Definition-of-Done Format

```markdown
### Definition of Done
- [ ] Full test suite passes, no new failures
- [ ] `auth/` no longer imports from `legacy/`
- [ ] No public API signatures changed
- [ ] Typecheck + lint clean
```

### Guidelines

**DO**:
- Make every item objectively verifiable — name the command, the path, the condition
- Lead with the safety/behavior-preservation gate for refactors
- Assert invariants as explicit checkboxes, not prose hopes
- Reference concrete paths, identifiers, versions, and commands

**DON'T**:
- Write editing steps ("edit X, then edit Y") — that's a plan, not a Definition of Done
- Use unverifiable items ("code is cleaner", "improves maintainability")
- Omit the behavior-preservation gate from a refactor
- Leave invariants implicit

### Outline First

List the condition categories before detailing:
```
1. Safety: [behavior-preservation gate]
2. Outcome: [structural end state]
3. Invariant: [what must not have changed]
4. Gates: [typecheck/lint/build/CI]
```

How many conditions are right, and when is the task too big to verify? See [task-sizing.md](references/task-sizing.md).

---

## Phase 4: Review

**Goal**: Validate the task against quality criteria.

### Quality Checklist

| Check | Anti-Pattern to Avoid |
|-------|----------------------|
| No behavior change smuggled in | Behavior-change leak in a refactor |
| Implementation named concretely | Vague "clean up the code" scope |
| Scope bounded (in + out) | Open-ended blast radius |
| Invariants stated explicitly | Implicit "obviously nothing breaks" |
| Done is verifiable | Unverifiable "is cleaner" items |
| Defined by outcome, not steps | Task-list dump of edits |
| Safety gate present | Refactor with no behavior-preservation check |

### Verification Questions

1. Could CI or a reviewer objectively confirm every Definition-of-Done item?
2. For a refactor, is the behavior-preservation invariant stated and verified?
3. If coverage was thin, does the task add characterization tests first?
4. Is what's explicitly *out* of scope clear?
5. Is this defined by outcome rather than a list of edit steps?
6. Is the task small enough to land and verify as one focused change?

### Readability Polish

Dev tasks are read by engineers, reviewers, and sometimes leads triaging debt. After verification, polish the **prose portions only** through the `writing-for-humans` skill. The Definition of Done and any code/path/identifier references are verification-critical structured specs — leave them byte-for-byte intact.

**Polish scope (narrow)**:
- The 2-4 sentence narrative paragraph under the task title

**Do NOT polish**:
- The task title
- `### Scope`, `### Invariants`, `### Definition of Done` headers and their contents
- Any checklist item, path, module name, identifier, version, or command
- Anything inside the Scope, Invariants, or Definition-of-Done sections

**Critical preservation rules**:
- **Technical identifiers** must survive verbatim — do not let polish genericize module names, paths, commands, or versions (`auth/session.ts` must not become "the session file")
- Do not soften the behavior-preservation stance into something vaguer
- Do not reintroduce user-story phrasing ("As a developer, I want…")

Invoke the `writing-for-humans` skill on the narrative paragraph only, passing the polish scope, do-not-polish list, and preservation rules above as the preserve/transform contract.

Replace the draft narrative with the polished output. Spot-check that the Definition of Done is byte-identical and that no technical identifier was genericized.

**Fallback**: If `writing-for-humans` is unavailable (e.g., running inside another sub-agent, or generating many tasks in a batch where the cost isn't justified), skip the polish and note "Readability polish deferred" in the handoff.

### Final Presentation

When presenting the finished task, accompany it with the quality checklist showing which items pass.

---

## Handling Edge Cases

### Caller Wants a Behavior Change Inside a Refactor

Split it. The refactor stays behavior-preserving; the behavior change becomes its own task (and a story if user-observable). Note the dependency between them.

### Touched Code Has Thin or No Test Coverage

Don't refactor blind. Make "add characterization tests that pin current behavior" the first Definition-of-Done item, then refactor under their protection.

### Discovery Reveals the Task Is Too Big

When a "task" spans too many modules or can't be verified as one change:
1. Acknowledge it's oversized.
2. Use `skeleton-of-thought` (see [thinking-patterns.md](references/thinking-patterns.md)) to propose smaller, independently verifiable tasks.
3. Note ordering and dependencies between them. See [task-sizing.md](references/task-sizing.md).

### Caller Frames It as a User Story

If the work is genuinely non-user-facing, reframe to a dev task. If it has observable user impact, route to `writing-agile-stories` instead — that's the right tool.

### Unclear When the Task Is "Done"

A task is ready when:
- Every Definition-of-Done item is objectively verifiable
- The behavior-preservation invariant (for refactors) is stated and gated
- Scope in/out is explicit

---

## Reference Files

- [discovery-dimensions.md](references/discovery-dimensions.md) — six dimensions to gather before drafting
- [anti-patterns.md](references/anti-patterns.md) — common mistakes with examples and rewrites
- [examples.md](references/examples.md) — complete worked tasks across the three task types
- [templates.md](references/templates.md) — output templates and canonical example
- [task-sizing.md](references/task-sizing.md) — when to add conditions vs. split the task
- [thinking-patterns.md](references/thinking-patterns.md) — structured reasoning by phase

---

## Quick Reference

| Phase | Goal | Key Output |
|-------|------|------------|
| Discovery | Gather dimensions | Motivation, scope, invariants, verification, risks/rollback, coverage baseline |
| Drafting | Technical narrative | 2-4 sentence motivation + scope (in/out) + invariants |
| Definition of Done | Verifiable end state | Checklist: safety, outcome, invariant, gates |
| Review | Quality check + readability polish on prose | Validated, polished task ready for use |

**Anti-patterns to avoid**: Behavior-change leak in a refactor, task-list dump, unverifiable done, open-ended scope, implicit invariants, oversized tasks. See [anti-patterns.md](references/anti-patterns.md).
