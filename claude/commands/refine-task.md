---
description: Refine a Jira or Linear issue into a well-scoped, verifiable development task with a Definition of Done through iterative review
argument-hint: "<issue ID> [--tool jira|linear]"
model: opus
allowed-tools: Read, Bash, Task, AskUserQuestion
---

# Refine Task

**Level 4 (Delegation)** - Orchestrates sub-agents for blast-radius research and independent review cycles. Tool-agnostic core delegates issue fetch and write-back to a tracker adapter (Jira or Linear).

Take a Jira or Linear issue describing non-user-facing work — a refactor, test work, or a dependency/tooling change — gather context from the tracker and the codebase, then produce a well-scoped, verifiable development task with a Definition of Done. Two independent review cycles ensure quality from different engineering perspectives.

This is the technical-work counterpart to `/refine-story`. `/refine-story` turns an issue into user-facing behavior (Given-When-Then, no implementation detail). `/refine-task` turns an issue into an implementation-focused task with a verifiable Definition of Done — naming modules, files, dependencies, and structure is the subject, not a leak. If the work produces observable behavior a user would notice, use `/refine-story` instead.

## Variables

- **ISSUE_KEY**: First positional argument - issue identifier (e.g., POPS-123 for Jira, ENG-123 for Linear)
- **TOOL**: Resolved from `--tool jira|linear` flag, or via Phase 0 dispatch if absent
- **TOOL_SKILL**: `managing-${TOOL}` — the skill that documents the tracker's CLI

## Dependencies

- **managing-jira skill**: Parallel reference docs for the `jira` CLI (ankitpokhrel/jira-cli) — not loaded at runtime; consult when TOOL=jira and you need setup, flag, or best-practice details beyond the dispatch table
- **managing-linear skill**: Parallel reference docs for `npx -y linearis` (czottmann/linearis) — not loaded at runtime; consult when TOOL=linear and you need setup, flag, or best-practice details beyond the dispatch table
- **writing-dev-tasks skill**: Dev-task format, the six discovery dimensions, the behavior-change-leak anti-pattern, the verifiable Definition of Done
- **thinking-patterns skill**: atomic-thought, chain-of-thought, self-consistency
- **codebase-analyzer agent**: Maps the blast radius of the change — modules in scope, inbound/outbound dependencies, call sites, public surface, and the test-coverage baseline. Primary research agent for Phase 3.
- **Explore agent**: Locates the files/modules in scope when the issue names a symbol or concept but not a path. Use to bound where the change lives before analyzing it.
- **codebase-pattern-finder agent**: Surfaces existing patterns the task should follow (e.g., how similar extractions, migrations, or test setups are done in this repo). Use only when an existing pattern bounds the work.
- **general-purpose agent** (model: sonnet): Review sub-agents — sonnet suits structured checklist evaluation; opus orchestrates synthesis and drafting
- **Project registry**: `$CLAUDE_DOCS_ROOT/projects.yaml`

## Initial Response

When invoked:

1. **If an issue key was provided**: Validate format and begin Phase 0
2. **If no issue key provided**, respond with:

```
I'll help you refine a Jira or Linear issue into a well-scoped, verifiable development task with a Definition of Done.

Please provide an issue ID (e.g., POPS-123 for Jira, ENG-123 for Linear).

Optionally specify --tool jira|linear; otherwise I'll ask.
```

## Parallel Execution Contract

Tasks under the same epic CAN be run in parallel when they're truly independent: file paths are isolated per run (Phase 9 uses a per-PID temp file), tracker writes are issue-scoped, and DECISIONS logs do not cross-contaminate.

Practical guidance:

- Expect ~6 `AskUserQuestion` gates per task. Running 2-3 in parallel is comfortable; more becomes hard to attend to.
- A common pattern: batch-launch through the draft phase, then walk review phases one task at a time.
- If tasks touch overlapping modules, refine the one that establishes the Scope boundary first, then run the rest — DECISIONS logs are isolated, so independent runs may otherwise draw different in/out scope lines for the shared module.

---

## Phase 0: Tool Dispatch

### Resolve TOOL

1. If `--tool jira` or `--tool linear` was passed, set TOOL accordingly.
2. Otherwise, ask via AskUserQuestion:

**AskUserQuestion**:
- Header: "Tracker"
- Question: "Which tracker is `${ISSUE_KEY}` from?"
- Options:
  - "Jira" — Use the `managing-jira` skill (`jira` CLI)
  - "Linear" — Use the `managing-linear` skill (`linearis` CLI)

3. Set `TOOL_SKILL = managing-${TOOL}`.

### Tool Dispatch Table

This table binds tool-specific commands and field names referenced throughout the workflow. The relevant skill (`${TOOL_SKILL}`) documents these in detail; this table is the contract this command relies on.

| Variable | TOOL=jira | TOOL=linear |
|---|---|---|
| `${AUTH_CHECK}` | `jira me` | `npx -y linearis teams list` |
| `${FETCH_CMD}` | `jira issue view ${ISSUE_KEY} --comments 10` and `jira issue view ${ISSUE_KEY} --raw` | `npx -y linearis issues read ${ISSUE_KEY}` |
| `${FETCH_RELATED}` | linked issues + comments | sub-issues + up-to-5 sibling issues under same parent |
| `${COMMENTS_AVAILABLE}` | yes | no — compensate with siblings + parent context |
| `${UPDATE_DESC_CMD}` | `jira issue edit ${ISSUE_KEY} --no-input --body "$(cat "$TASK_FILE")"` | `npx -y linearis issues update ${ISSUE_KEY} --description "$(cat "$TASK_FILE")"` |
| `${ADD_COMMENT_CMD}` | `jira issue comment add ${ISSUE_KEY} --no-input -b"$(cat "$TASK_FILE")"` | `npx -y linearis comments create ${ISSUE_KEY} --body "$(cat "$TASK_FILE")"` |

If a future tracker is added (e.g., GitHub Issues, Asana), extend this table and the Phase 0 question — phases 2–8 are tool-agnostic and require no changes.

---

## Phase 1: Tracker Context

### Authentication Check

Run `${AUTH_CHECK}`. If it fails, tell the user: "${TOOL} authentication failed. Run `/skill ${TOOL_SKILL}` or read `~/.claude/skills/${TOOL_SKILL}/SKILL.md` for setup steps." Then stop.

### Fetch Issue Details

Run `${FETCH_CMD}` and extract:

- **Identifier**: Issue ID (e.g., POPS-123, ENG-123)
- **Title / Summary**: Issue title
- **Description**: Full description text
- **Status**: Current workflow state
- **Type / Priority**: Tool-specific metadata (issue type for Jira; priority name for Linear — see managing-linear for the priority scale)
- **Parent**: Epic (Jira) or parent issue (Linear), if any
- **Related work**: per `${FETCH_RELATED}`
- **Comments**: only if `${COMMENTS_AVAILABLE}` = yes

### Fetch Parent Context (if parent exists)

Re-run `${FETCH_CMD}` against the parent identifier to capture the parent's title and description. For a dev task this often names the umbrella debt or migration the work belongs to.

### Fetch Related Issues

The dispatch table covers single-command fetches; sibling discovery requires structural traversal of parent data, so this step branches by TOOL:

- TOOL=jira: For each linked issue, fetch with `${FETCH_CMD}`. Linked issues often name a blocking refactor or a dependency this task must order against.
- TOOL=linear: From the parent's `.subIssues` array, fetch up to 5 siblings (excluding the current issue). 5 keeps context tractable without overwhelming Phase 3 synthesis; tune if signal is thin. Siblings under the same parent provide "related work" context that compensates for Linear's missing comments.

### Build Context Summary

Compile into a structured context block:

```
**Issue**: ${ISSUE_KEY} - ${TITLE}
**Status**: ${STATUS} | **Type/Priority**: ${TYPE_OR_PRIORITY}
**Description**: ${DESCRIPTION}
**Parent**: ${PARENT_KEY} - ${PARENT_TITLE} (if any)
**Related work**: linked issues (Jira) | sub-issues + siblings (Linear)
**Comments**: ${COMMENT_SUMMARIES} | "Not available via CLI" (Linear)
**Technical Terms**: [Module names, paths, dependencies, tooling mentioned in the description and any available comments/related issues]
**Apparent task type**: [refactor | test work | dependency/tooling change | unclear]
```

Present the context summary to the user before proceeding.

### Behavior-Change Triage

`writing-dev-tasks` is for non-user-facing work. If the issue describes something a user can see or do differently — a feature, a flow, a public API contract changing — this is the wrong command. Flag it and offer to route to `/refine-story` instead (or split: a behavior-preserving dev task plus a separate story for the user-facing change). Do not silently force user-facing work into a dev task.

### Thin-Context Check

If the description is empty AND there's no parent AND no related work AND comments are unavailable or empty, warn the user and offer to push back for the missing discovery dimensions (per `writing-dev-tasks` discovery-dimensions: Motivation, Scope, Invariants, Verification, Risks & Rollback) rather than inventing a task from the codebase alone. Code research maps the blast radius; it does not tell you *why now* or *what must not change* — those come from the user.

### Initialize DECISIONS

Create the `${DECISIONS}` block per the Decision Log format below. Populate Scope IN/OUT and Invariants only if the issue, parent, or related work explicitly states them. Leave the rest empty until later phases produce real decisions.

---

## Decision Log

Maintain a structured `${DECISIONS}` block throughout the workflow. Reviewers receive this block alongside the task so they can distinguish real gaps from closed decisions. Append a decision when:

- The user answers an `AskUserQuestion` (tracker selection, project selection, draft adjustments, feedback acceptance/rejection).
- The user gives a free-form clarification or edit instruction.
- Blast-radius research surfaces a constraint that bounds the task (a call site that becomes an invariant, a coverage gap that forces characterization tests first).
- A reviewer suggestion is accepted (record what changed) or rejected (record why).

Format:

```
## DECISIONS

### Scope
- IN: [module / path in scope for this task]
- OUT: [explicitly excluded module / path / concern] — Reason: [why]

### Invariants
- [What must NOT change: observable behavior, public API signature, contract, on-disk format]

### Coverage Baseline
- [Module]: [tested? which paths/branches are covered vs. uncovered] — Implication: [characterization tests first? safe to refactor under existing suite?]

### Constraints (from blast-radius research)
- [Fact]: [where it was found and what it implies for scope, invariants, or verification]

### Verification Gates
- [Objective check that proves done AND safe — command, path, or condition]

### User Clarifications
- [Decision]: [what was being chosen between, what the user picked, why if stated]

### Review Outcomes
- Review 1 — Accepted: [suggestion → resulting task change]
- Review 1 — Rejected: [suggestion] — Reason: [why]
- Review 2 — Accepted / Rejected: [same format, populated after Phase 7]
```

Only record decisions actually made — by user choice, research finding, or review outcome. Do NOT infer decisions. A missing entry means "not yet decided," which lets reviewers raise it. Pass the current `${DECISIONS}` block verbatim to every review sub-agent.

---

## Phase 2: Repository Discovery

### Load Project Registry

Read `$CLAUDE_DOCS_ROOT/projects.yaml` to get the list of known projects.

### Project Selection

Auto-matching by tracker key is unreliable (Jira's `jira_epic` is only populated for one project; Linear has no equivalent registered). Present the project list and let the user choose.

**AskUserQuestion**:
- Header: "Project"
- Question: "Which project does ${ISSUE_KEY} belong to? I'll map the blast radius of the change in the associated repositories."
- Options: Build from projects.yaml entries, showing project name and repository list for each. Include a "None of these" option description.

### Extract Repositories

From the selected project entry, extract the `repositories` list.

If user picks "None of these" (Other), ask:

```
Which repository paths should I research? Provide absolute paths or org/repo identifiers, separated by commas.
```

### Record Project Selection

Append to `${DECISIONS}` → User Clarifications: which tracker was selected, which project, which repositories will be researched. This locks the research scope so reviewers don't propose pulling unrelated repos into the blast radius.

---

## Phase 3: Parallel Blast-Radius Research

### Blast-Radius Research Contract

A dev task is about implementation, so code-level research is **expected and appropriate** here — this is the deliberate inverse of `/refine-story`, which forbids reading implementation to avoid leaking it into user-facing behavior. Here the implementation *is* the subject: the modules in scope, what they depend on, who depends on them, and what protects against regression all feed the task's Scope, Invariants, and Definition of Done.

Two hard limits keep this bounded, and both must appear in every research-agent prompt:

1. **Map the blast radius; do NOT design the implementation or propose the fix.** Discovery establishes what's in scope, what's coupled, what callers depend on, and what's tested. The step-by-step *how* belongs in a downstream implementation plan, not in this task. A research agent that returns a refactoring strategy has overstepped.
2. **Establish the coverage baseline.** For refactors and test work, report whether the touched code is currently tested and which paths/branches are covered. Thin coverage is a first-class finding: it becomes a "characterization tests first" item in the Definition of Done, because the substitution test that proves behavior preservation is meaningless if no test exercises the behavior.

Each research agent maps, for its assigned area: the modules/files in scope; inbound and outbound dependencies; the call sites and public surface that callers depend on (these become **invariants**); and the existing test-coverage baseline.

Research layers, in order of use:

1. **Locate (if needed)** via `Explore` — when the issue names a symbol or concept but not a path, bound where the change lives first.
2. **Blast-radius analysis** via `codebase-analyzer` (primary) — for each in-scope area, map dependencies, call sites, public surface, and coverage baseline.
3. **Pattern reference** via `codebase-pattern-finder` (only when an existing pattern bounds the work) — surface how similar extractions, migrations, or test setups are already done in this repo, so the task can require consistency with them.

If research returns thin results (the named modules don't exist, or coupling can't be determined), push back to the user for the missing discovery dimensions rather than guessing the blast radius.

### Layer 0: Locate (only if scope paths are unknown)

If the issue and tracker context do not already name concrete files/modules, spawn an `Explore` agent (breadth "medium") per repository to find them. Skip this layer when the issue already names paths. Each agent gets a self-contained prompt:

```markdown
# Locate In-Scope Modules

Find where the following concept lives in `${REPO}` so a dev task can bound its scope. Report file paths and module names only — do NOT analyze internals or propose changes.

## Issue Context
- **Issue**: ${ISSUE_KEY} - ${TITLE}
- **Description**: ${DESCRIPTION}
- **Technical terms to locate**: ${TECHNICAL_TERMS}

## Output
- **Candidate in-scope files/modules**: [paths, with a one-line note on what each contains]
- **Adjacent files likely in the blast radius**: [paths that import or are imported by the candidates]
```

### Layer 1: Blast-Radius Analysis (primary)

For each repository in the selected project (scoped to the located paths if Layer 0 ran), spawn a `codebase-analyzer` agent in parallel. Each agent gets a self-contained prompt with all context embedded (no references to parent conversation).

For each `${REPO}`, use the Task tool to spawn a `codebase-analyzer` agent:

```markdown
# Blast-Radius Map for Dev-Task Refinement

You are mapping the blast radius of a proposed non-user-facing change in `${REPO}` to ground a development task's Scope, Invariants, and Definition of Done. This is NOT an implementation design.

## Issue Context

- **Issue**: ${ISSUE_KEY} - ${TITLE}
- **Description**: ${DESCRIPTION}
- **Apparent task type**: ${TASK_TYPE} (refactor | test work | dependency/tooling change)
- **In-scope paths (if known)**: ${SCOPE_PATHS}
- **Comments / Related work**: ${RELATED_SUMMARIES}

## Hard Boundary

**Map the blast radius; do NOT design the implementation or propose the fix.** Report what exists, what depends on what, and what is tested. Do NOT recommend a refactoring strategy, a sequence of edits, or a target structure. If you catch yourself writing "we should…", stop — that belongs in a plan, not this map.

## What to Map

### 1. Modules in Scope
- The files/modules the change would touch, with a one-line description of each.
- The size and shape of each (rough line count, key exported symbols) so the task can be sized.

### 2. Outbound Dependencies
- What the in-scope modules import or call into (other modules, packages, services).
- Flag any dependency that is itself legacy, deprecated, or slated for removal.

### 3. Inbound Dependencies and Public Surface (→ INVARIANTS)
- Who imports or calls the in-scope modules, and through which exported symbols.
- The public surface callers depend on: exported function/type signatures, return shapes, on-disk or wire formats, documented contracts.
- State these as candidate invariants: "callers depend on `X`, so `X` must not change."

### 4. Coverage Baseline
- Which test files exercise the in-scope modules, and what they cover.
- Which paths/branches/edge cases are covered vs. uncovered.
- Verdict: is coverage sufficient to refactor safely under the existing suite, or are characterization tests needed first? Name the specific uncovered paths that would need pinning.

### 5. Existing Patterns (only if relevant)
- If the repo already has an established way to do this kind of change (an extraction convention, a migration pattern, a test-setup idiom), name it and point to one example. Otherwise omit.

## Output Format

### Modules in Scope [Task input]
[Paths + one-line descriptions + rough size]

### Outbound Dependencies [Task input]
[What the in-scope code depends on; flag legacy/deprecated ones]

### Inbound Dependencies & Invariants [Task input]
[Callers + the public surface they depend on, stated as candidate invariants]

### Coverage Baseline [Task input]
[Covered vs. uncovered paths; verdict on characterization-tests-first]

### Existing Patterns [Task input — optional]
[Named convention + one example, or omit]
```

### Layer 2: Pattern Reference (only when a pattern bounds the work)

Invoke only if the task should follow an established repo convention and Layer 1 flagged one (its "Existing Patterns" output). Skip otherwise. Carry that flagged convention forward as `${PATTERN_DESCRIPTION}` — the name of the pattern to find plus any example Layer 1 already pointed to. For the relevant `${REPO}`, spawn a `codebase-pattern-finder` agent:

```markdown
# Pattern Reference for Dev-Task Refinement

Find existing examples in `${REPO}` of how this kind of change is already done, so a dev task can require consistency with them. Report concrete examples only — do NOT design the new change.

## Issue Context
- **Issue**: ${ISSUE_KEY} - ${TITLE}
- **Pattern to find**: ${PATTERN_DESCRIPTION} (e.g., "how modules are extracted out of a barrel file", "how a dependency upgrade is gated in CI", "how characterization tests are structured")

## Output
### Existing Pattern [Task input]
[Concrete example(s) with file paths and a short excerpt showing the convention. State the invariant the pattern implies, if any.]
```

### Wait for All Agents

Collect research results from all repositories (and any pattern scans) before proceeding.

### Present Research Summary

Combine findings from all repositories into a consolidated blast-radius summary. Present to user before drafting.

### Capture Constraints, Invariants, and Coverage

From the consolidated research:

- Append concrete bounding facts to `${DECISIONS}` → Constraints (e.g., "`legacy/gatekeeper.ts` is the only inbound caller of `validateSession`", "the export format is consumed by an external job — wire format is an invariant").
- Append candidate invariants to `${DECISIONS}` → Invariants: public signatures, contracts, on-disk/wire formats, and observable behavior the inbound callers depend on.
- Append the coverage verdict to `${DECISIONS}` → Coverage Baseline, including the specific uncovered paths that would need characterization tests first.

---

## Phase 4: Task Drafting

### Synthesis

Invoke the `thinking-patterns` skill with atomic-thought (`/thinking atomic-thought`) to decompose tracker context + blast-radius research into the dev-task discovery dimensions:

```
Independent questions to answer from gathered context:

1. **Motivation**: Why now — what debt, risk, or friction drives this? (from tracker description + parent/related)
2. **Scope & Blast Radius**: Which modules/paths are IN, and what is explicitly OUT? (from blast-radius map + tracker)
3. **Invariants**: What must NOT change — observable behavior, public signatures, contracts, on-disk/wire formats? (from inbound dependencies & public surface)
4. **Verification**: How do we know it's done AND safe? (from coverage baseline + invariants)
5. **Risks & Rollback**: What could break, how is it detected, how do we back out? (from outbound/inbound deps + coverage)
6. **Definition of Done**: The verifiable end state — what objective conditions confirm completion? (synthesis of the above)

Answer each independently, then synthesize.
```

### Draft Task

Load the `writing-dev-tasks` skill for the task format (Title, Narrative, Scope, Invariants, Definition of Done), the six discovery dimensions, the behavior-change-leak anti-pattern, and the rules for a verifiable Definition of Done. Apply the skill's guidance directly. Then add the flow-specific classification step below before drafting.

#### Pre-write classification (specific to this flow)

This classification is the deliberate inverse of `/refine-story`'s. There, technical detail is the thing to reject; here, technical detail is required content and a smuggled *behavior change* is the thing to reject.

| Bucket | Source | Use in task? |
|--------|--------|--------------|
| Implementation detail | Modules, file paths, dependency names/versions, structure (from blast-radius map) | YES — this is the subject; name it concretely in Narrative and Scope |
| Invariant | Public surface, contracts, on-disk/wire formats, observable behavior callers depend on | YES — assert each as an Invariant and as a checkable Definition-of-Done item |
| Coverage gap | Uncovered paths from the coverage baseline | YES — as a "characterization tests first" Definition-of-Done item |
| Verifiable end state | Outcome + gates (suite green, no import, typecheck/lint clean, version pinned) | YES — as the Definition of Done |
| Smuggled behavior change | A "while I'm in here" fix, tightened validation, changed default/ordering/error message folded into a refactor | NO — split it out into its own task (and a story if user-observable). For a refactor, the behavior is the invariant. |
| Step-by-step edit list | "Open X, cut Y, paste into Z" | NO — steps belong in a plan; define the verifiable end state instead |

Apply the substitution test from `writing-dev-tasks` to any candidate Definition-of-Done item: if reverting to the old structure would make a currently-passing test fail (or vice versa), the draft has changed behavior — split it out.

### Present Draft

Show the complete task draft to the user.

**AskUserQuestion**:
- Header: "Draft"
- Question: "Here's the initial dev-task draft. Ready to send it for expert review?"
- Options:
  - "Yes, proceed to review" - Continue to Phase 5
  - "Make adjustments first" - Ask what to change, apply edits, re-present

When the user provides edit instructions, append each substantive change to `${DECISIONS}` (Scope, Invariants, or User Clarifications as appropriate) with the change made and the reason if stated. Trivial wording fixes can be skipped; anything that adjusts scope, changes an invariant, or alters a Definition-of-Done item must be recorded.

---

## Phase 5: First Review (Charter-Aware)

**CRITICAL**: Launch a sub-agent that does NOT see the orchestrator's reasoning (so it can't rubber-stamp), but DOES see the user's closed decisions (so it can't accidentally reverse them).

### Reviewer Agent Prompt

Use the Task tool to spawn a `general-purpose` agent (model: `sonnet`). Substitute `${DECISIONS}` with the current decision log block and `${TASK_CONTENT}` with the complete task text:

```markdown
# Dev-Task Expert Review

You are a senior engineer reviewing a development task for scope,
verifiability, and safety before anyone picks it up.

You have NOT seen the orchestrator's reasoning that produced this draft —
that prevents you from echoing it back. You DO see the DECISIONS block
below: these are closed questions the user has already resolved. Do not
propose suggestions that reverse a decision. If you believe a decision
is unsafe, surface it as a CHARTER CHALLENGE in the dedicated section
with concrete justification — never as an ordinary suggestion.

Use `/thinking chain-of-thought` to work through each review criterion systematically.

## DECISIONS (already settled — treat as fixed unless you can justify a Charter Challenge)

${DECISIONS}

## The Task to Review

${TASK_CONTENT}

## Step 1 — Dev-Task Defect Hunt (do this BEFORE the general checklist)

Hunt for these defects, in this order. The first found at each severity drives a concrete fix in your suggestion.

1. **Behavior-change leak in a refactor (Critical)** — Does the task smuggle a behavior change into work that should preserve behavior? Look for "while I'm in here" fixes, tightened/loosened validation, changed defaults, ordering, or error messages folded into a restructure. Apply the substitution test: if you reverted to the old structure, would every currently-passing test still pass and vice versa? If a test would have to change to describe *new* behavior, behavior changed. Required fix: state the behavior-preservation invariant explicitly AND a Definition-of-Done item that verifies it (existing suite passes unchanged); recommend splitting the behavior change into its own task.

2. **Unverifiable Done (Critical/Major)** — Any Definition-of-Done item that can't be checked pass/fail ("code is cleaner", "more maintainable", "better structured"). Required fix: rewrite as an objective condition with a named command, path, or measurable threshold.

3. **Task-list dump (Major)** — Work defined as steps to perform ("open X, cut Y, paste into Z") instead of a verifiable end state. Required fix: convert each step into an outcome + verification; note that steps belong in the implementation plan, not the task.

4. **Missing/implicit invariants (Major)** — Public API, contracts, on-disk/wire formats, or observable behavior that must not change but isn't stated. Required fix: name the invariant explicitly and add a Definition-of-Done item asserting it.

5. **Open-ended scope (Major)** — Unbounded blast radius ("clean up the module", no OUT list). Required fix: state what's IN and what's explicitly OUT.

Record each finding in **Issues Within Scope** with severity, a location pointing to the specific line/section, and the concrete fix above as the suggestion.

## Step 2 — Quality Checklist (from writing-dev-tasks)

Evaluate against each criterion:

| Check | What to Look For | Anti-Pattern |
|-------|------------------|--------------|
| No behavior change smuggled in | Refactor preserves behavior; behavior changes are split out | "While I'm in here" fix folded into a refactor |
| Implementation named concretely | Real modules, paths, dependencies, versions | Vague "clean up the code" |
| Scope bounded (in + out) | Explicit IN and OUT lists | Open-ended blast radius |
| Invariants stated explicitly | Public surface, contracts, formats named | Implicit "obviously nothing breaks" |
| Done is verifiable | Every item pass/fail, present/absent, true/false | "Is cleaner" / "improved" items |
| Defined by outcome, not steps | Verifiable end state | Task-list dump of edits |
| Safety gate present | Behavior-preservation check; characterization tests first where coverage thin | Refactor with no regression protection |

## Review Questions

Answer each explicitly. Evaluate *within* the DECISIONS scope:

1. **Verifiability**: Could CI or a reviewer objectively confirm every Definition-of-Done item without judgment?
2. **Behavior preservation**: For a refactor, is the behavior-preservation invariant stated and gated by a verification item?
3. **Coverage**: If the coverage baseline in DECISIONS shows thin coverage on touched code, does the task add characterization tests first?
4. **Scope clarity**: Is what's explicitly OUT of scope clear enough that a developer won't sprawl?
5. **Outcome vs. steps**: Is the task defined by a verifiable end state rather than a list of edits?
6. **Sized to land**: Given the DECISIONS scope, is this small enough to implement, verify, and revert as one focused change?

## Output Format

### Checklist Results
[Pass/Concern/Fail for each checklist item with explanation]

### Review Question Answers
[Detailed answer for each of the 6 questions]

### Strengths
[What's done well — be specific]

### Issues Within Scope
Gaps inside the DECISIONS scope that need fixing. For each:
- **Location**: [Which part of the task]
- **Severity**: [Critical/Major/Minor]
- **Issue**: [What's wrong]
- **Suggestion**: [Specific fix that does NOT contradict any DECISION]

### Charter Challenges
Disagreements with closed DECISIONS. Surface only with concrete justification — these reopen settled questions and must not be raised speculatively. If you have none, write "None." For each:
- **Decision being challenged**: [Quote the relevant entry from DECISIONS verbatim]
- **Why it may be unsafe**: [Evidence-based argument citing the task content or a known constraint]
- **Alternative**: [What you'd propose if the decision were reopened]

### Out of Scope (FYI)
Items that look like gaps but are already excluded by DECISIONS. List for awareness only; not actionable. If none, write "None."

### Overall Assessment
- **Quality Score (within charter)**: [1-10]
- **Ready to pick up?**: [Yes / Yes with minor fixes / No — needs revision]
- **Top 3 Improvements (within charter)**: [Prioritized list — exclude charter challenges]
```

### Pre-filter Reviewer Output

Before presenting findings to the user, audit the reviewer's categorization:

1. For each item in **Issues Within Scope**, check whether applying the suggestion would contradict any DECISIONS entry. If yes, move it to **Charter Challenges** (the reviewer mis-categorized it).
2. For each **Charter Challenge**, pair it with the original DECISIONS entry verbatim so the user sees exactly what would be reopened.
3. Do not modify the reviewer's text — only re-categorize.

### Present Review Findings

Present in three labeled groups, in this order:

- **Issues Within Scope** — each with severity and suggested fix; default action is to address.
- **Charter Challenges (default: keep decision)** — each shown with the DECISIONS entry it would override and the reviewer's justification side-by-side. Default action is to ignore.
- **Out of Scope (FYI)** — one-line list, no action implied.

**AskUserQuestion**:
- Header: "Review 1"
- Question: "How would you like to incorporate this feedback?"
- Options:
  - "Accept all in-scope suggestions" — Apply all Issues Within Scope; ignore charter challenges
  - "Accept some" — Ask which Issues Within Scope to accept
  - "Reopen a decision" — Identify which Charter Challenge to consider; user must explicitly confirm reopening
  - "Discuss specific feedback" — Explore particular issues
  - "Skip to second review" — Keep draft as-is

---

## Phase 6: First Refinement

Based on accepted feedback:

1. **Update the task** with accepted changes
2. **Append to `${DECISIONS}` → Review Outcomes**: list each accepted Issue (briefly: what changed in the task) and each rejected suggestion (with the reason). If a Charter Challenge was reopened and a DECISION was changed, update that DECISION entry in place AND note the change in Review Outcomes (so Review 2 sees it).
3. **Invoke `/thinking self-consistency`** to verify coherence:

```
Verify the refined task for internal consistency:

Path 1 - Scope-Done Alignment:
Does every Definition-of-Done item correspond to something inside Scope IN, and nothing in Scope OUT?

Path 2 - Invariant-Verification Alignment:
Is every stated Invariant backed by a verification item that would catch its violation?

Path 3 - Safety:
For a refactor, is the behavior-preservation gate present, and does the coverage baseline justify whether characterization tests come first?

Synthesize: Any inconsistencies introduced by refinements? Any invariant now unguarded, or any Done item now unverifiable?
```

4. **Present refined task** to user

---

## Phase 7: Second Review (Charter-Aware)

**CRITICAL**: Fresh sub-agent that has NOT seen the orchestrator's reasoning or the first reviewer's report — but DOES see the current `${DECISIONS}` block (now including Review 1 outcomes), so it cannot accidentally reverse what was just settled.

### Reviewer Agent Prompt (Skeptical Tech Lead)

Use the Task tool to spawn a `general-purpose` agent (model: `sonnet`). Substitute `${DECISIONS}` with the updated decision log (post-Phase 6) and `${TASK_CONTENT}` with the complete refined task text:

```markdown
# Dev-Task Validation — Tech Lead Perspective

You are a skeptical tech lead validating that a development task is ready
to be picked up. Your job is to find what would cause problems during
implementation, review, or merge: an unestimable task, an unsafe change,
or a regression that wouldn't be caught.

You have NOT seen previous review reports or the orchestrator's reasoning,
so you cannot rubber-stamp them. You DO see the DECISIONS block below —
including which Review 1 suggestions were accepted or rejected. Do not
re-litigate decisions. If you believe a closed decision is unsafe, raise
it as a CHARTER CHALLENGE in the dedicated section, with concrete
justification — never as an ordinary suggestion.

Use `/thinking chain-of-thought` to work through each validation area systematically.

## DECISIONS (already settled — treat as fixed unless you can justify a Charter Challenge)

${DECISIONS}

## The Task to Review

${TASK_CONTENT}

## Validation Focus

Evaluate within the DECISIONS scope. Run the dev-task defect hunt as your lens — behavior-change leak, unverifiable Done, task-list dump, missing invariants, open-ended scope — but frame each finding around pickup readiness.

### 1. Estimable
- Is the scope bounded tightly enough that an engineer could estimate this confidently?
- Are there hidden in-scope modules the blast-radius map implies but the task omits?
- Is this one task, or several bundled together that should be split?

### 2. Safe to Merge
- Is the behavior-preservation invariant (for a refactor) stated AND backed by a verification gate?
- If coverage was thin per the baseline, are characterization tests required first?
- Does every Definition-of-Done item objectively confirm done or safe — could CI run it?

### 3. Regression-Protected
- What could break that no Definition-of-Done item would catch?
- Are inbound callers' invariants (signatures, contracts, formats) all asserted?
- Is there a rollback path if it lands and breaks something?

### 4. Clarity
- Are module names, paths, versions, and commands concrete and correct?
- Is the "why now" clear enough to survive scope negotiation?
- Could an engineer unfamiliar with this code start without a follow-up meeting?

### 5. Outcome, Not Steps
- Is the task a verifiable end state rather than an edit list?
- Would two engineers agree on whether the task is "done"?

## Output Format

### Validation Results
For each focus area:
- **Status**: [Pass/Concern/Fail]
- **Finding**: [What you observed]
- **Risk**: [If concern/fail, what could go wrong at implementation or merge time]
- **Recommendation**: [How to address — must not contradict DECISIONS]

### Issues Within Scope
Real gaps that need fixing without changing any DECISION. For each:
- **Location**, **Severity**, **Issue**, **Suggestion**

### Charter Challenges
Disagreements with closed DECISIONS. Surface only with concrete justification. If none, write "None." For each:
- **Decision being challenged**: [Quote verbatim from DECISIONS]
- **Why it may be unsafe**: [Evidence-based]
- **Alternative**: [What you'd propose if reopened]

### Out of Scope (FYI)
Items that look like gaps but are excluded by DECISIONS. List for awareness; not actionable. If none, write "None."

### Final Verdict
- **Task Quality (within charter)**: [Strong/Adequate/Weak]
- **Ready to pick up?**: [Yes / Yes with minor edits / No — needs revision]
- **Confidence Level**: [High/Medium/Low]
- **Top 3 Risks (within charter)**: [If the task ships as-is and DECISIONS hold, what could go wrong at merge]
```

### Pre-filter Reviewer Output

Audit the reviewer's categorization the same way as Phase 5: anything in **Issues Within Scope** that contradicts a DECISIONS entry must be moved to **Charter Challenges** before presenting.

### Present Validation Findings

Present in three labeled groups: Issues Within Scope, Charter Challenges (default: keep decision, paired with the original DECISIONS entry), Out of Scope (FYI).

**AskUserQuestion**:
- Header: "Review 2"
- Question: "Final feedback received. How would you like to proceed?"
- Options:
  - "Accept all in-scope suggestions" — Apply all Issues Within Scope; ignore charter challenges
  - "Accept some" — Ask which Issues Within Scope to accept
  - "Reopen a decision" — Pick a Charter Challenge to consider; user must explicitly confirm reopening
  - "Task is ready as-is" — Skip refinement, proceed to output

---

## Phase 8: Final Refinement

1. **Incorporate any final feedback**
2. **Append to `${DECISIONS}` → Review Outcomes**: log Review 2 acceptances and rejections (with reasons). Update any DECISION whose challenge was reopened.
3. **Invoke `/thinking self-consistency`** for final coherence check:

```
Final verification of the complete task:

Path 1 - Read as the implementer: Could I do this without asking what's in scope or how "done" is judged?
Path 2 - Read as the reviewer: Could I objectively confirm every Definition-of-Done item, and would a violated invariant be caught?
Path 3 - Read as the tech lead: Is this safe to merge — behavior preserved, regressions protected, rollback clear?

Synthesize: Is the task ready to pick up?
```

4. **Prepare final task**

---

## Phase 9: Output

### Present Final Task

Display the complete refined task with quality check results:

```
## Final Task

[Complete task content: Title, Narrative, Scope, Invariants, Definition of Done]

---

## Quality Summary

### Review 1 (Senior Engineer)
- Score: [X/10]
- Key improvements made: [List]

### Review 2 (Tech Lead)
- Verdict: [Strong/Adequate/Weak]
- Final adjustments: [List]

### Quality Checks
[Pass/Fail for each check from the writing-dev-tasks quality checklist:
 - No behavior change smuggled in
 - Implementation named concretely
 - Scope bounded (in + out)
 - Invariants stated explicitly
 - Done is verifiable
 - Defined by outcome, not steps
 - Safety gate present]
```

### Tracker Update

**AskUserQuestion**:
- Header: "${TOOL} update"
- Question: "How should I update ${ISSUE_KEY}?"
- Options:
  - "Update description" - Replace issue description with the task
  - "Add as comment" - Add the task as a comment
  - "Both" - Update description AND add a comment with the task
  - "Don't update" - Display only, no tracker changes

### Tracker Update Execution

For multi-line task content, write to a per-run temp file first (CLIs choke on inline multi-line strings). The path includes both `${ISSUE_KEY}` and `$$` (PID) so parallel runs cannot collide:

```bash
TASK_FILE="/tmp/task-${ISSUE_KEY}-$$.md"
cat > "$TASK_FILE" <<'EOF'
${FINAL_TASK_CONTENT}
EOF
```

Then run the appropriate tool dispatch command:

- **Update description**: Run `${UPDATE_DESC_CMD}`
- **Add as comment**: Run `${ADD_COMMENT_CMD}`
- **Both**: Run both, in that order

After the tracker write succeeds, clean up:

```bash
rm -f "$TASK_FILE"
```

---

## Error Handling

### Empty ISSUE_KEY

```
No issue ID provided. Please provide an issue key (e.g., POPS-123 for Jira, ENG-123 for Linear).

Usage: /refine-task POPS-123
       /refine-task ENG-123 --tool linear
```

### Unknown --tool value

```
Unknown tool "${VALUE}". Supported values: jira, linear.
```

### Authentication Failure

Tell the user: "${TOOL} authentication failed. Run `/skill ${TOOL_SKILL}` or read `~/.claude/skills/${TOOL_SKILL}/SKILL.md` for setup steps." Then stop.

### Issue Not Found

```
Issue ${ISSUE_KEY} was not found. Please check:
1. The issue key is correct (case-sensitive)
2. You have permission to view this issue
3. The project/team prefix exists in your ${TOOL} workspace
4. You selected the correct --tool (current: ${TOOL})
```

### Issue Describes User-Facing Behavior

When the Behavior-Change Triage in Phase 1 finds the issue is about something a user can see or do:

```
${ISSUE_KEY} describes user-facing behavior (a user can see or do something different).
writing-dev-tasks is for non-user-facing work. Options:
1. Refine this as a user story instead — /refine-story ${ISSUE_KEY}
2. Split it — a behavior-preserving dev task PLUS a separate story for the user-facing change
3. Proceed anyway (only if you're confident the behavior is genuinely non-user-facing)
```

### No Matching Project

When user selects "None of these" and doesn't provide repository paths:

```
I need at least one repository path to map the blast radius.
Without code research, the task will rely solely on tracker context and may
miss invariants and coverage gaps.

Would you like to:
1. Provide repository paths
2. Continue without blast-radius research (Scope, Invariants, and coverage will be best-effort from the tracker only)
```

### Research Agent Timeout

```
Blast-radius research for ${REPO} is taking longer than expected. Options:
1. Wait for completion (recommended)
2. Skip this repository and proceed with available research
3. Cancel research and draft from tracker context only
```

### Thin Blast-Radius Results

When research returns thin results (named modules don't exist, coupling can't be determined):

```
Blast-radius research for ${REPO} returned thin results — I couldn't confirm
the in-scope modules or their dependencies. Drafting now risks inventing scope.
Could you confirm the modules/paths in scope, or the missing discovery
dimensions (motivation, what must NOT change, current test coverage)?
```

---

## Example Sessions

```bash
# Jira refactor task — explicit tracker
/refine-task POPS-456 --tool jira

# Linear dependency-upgrade task — no --tool flag, the command will prompt for tracker
# Linear flow compensates for missing comments via siblings under the same parent
/refine-task ENG-456

# Test-work task (add characterization coverage before a planned refactor)
/refine-task POPS-789 --tool jira
```

**Contrast — route to `/refine-story` instead**: An issue like "Users should see a 'retrying…' status when an export fails and is retried" describes observable user behavior. That belongs in `/refine-story` (Given-When-Then acceptance criteria), not `/refine-task`. A non-user-facing queue refactor underneath it could be a separate `/refine-task`.
```
