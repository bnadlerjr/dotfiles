# Discovery Dimensions

Before drafting, gather these six dimensions. If the caller has supplied context (Jira/Linear ticket, an ADR, a failing build, a flaky-test report, prior conversation), extract from that. If context is thin, ask the user in plain prose for what's missing — do NOT use `AskUserQuestion`. Discovery is open-ended; option chips force contrived choices.

Unlike story writing, implementation-level codebase research is **appropriate** here — dev tasks are about implementation. Read the modules in scope, map imports and call sites, and check the coverage baseline. The limit is: map the blast radius, don't design the implementation. The step-by-step *how* belongs in a plan. See "Task-List Dump" in [anti-patterns.md](anti-patterns.md).

## The Six Dimensions

| Dimension | What it answers | Example |
|---|---|---|
| **Motivation** | Why now? What debt, risk, or friction drives this? | "`auth/` → `legacy/` import blocks deleting `legacy/` and forces a circular build dependency" |
| **Scope & Blast Radius** | What's in, what's explicitly out, which modules/paths are touched? | "In: `auth/session.ts`, `legacy/gatekeeper.ts` call sites. Out: token format, `authenticate()` signature" |
| **Invariants** | What must NOT change — behavior, public API, contracts, on-disk formats? | "Same requests allowed/denied; `authenticate()` signature unchanged" |
| **Verification** | How do we know it's done AND safe? | "Existing suite passes unchanged; `auth/` no longer imports `legacy/`; typecheck + lint clean" |
| **Risks & Rollback** | What could break, how is it detected, how do we back out? | "Hidden call site in `legacy/` → caught by suite; revert is a single-commit git revert" |
| **Definition of Done** | The verifiable end state (this drives the task's done checklist) | "Suite green, no new failures; no `legacy/` import; no signature change; gates clean" |

## Coverage Baseline (a discovery output, not a seventh dimension)

For refactors and test work, check whether the touched code is currently tested. This isn't a separate dimension — it feeds Verification and Definition of Done. If coverage is thin, the finding turns into a "characterization tests first" item: pin current behavior with tests, then change under their protection.

## Discovery Output Scratchpad

Once gathered:

```
**Understanding**: [1-2 sentence summary]
**Motivation**: [Why now — debt/risk/friction]
**Scope**: In: [paths/modules] | Out: [explicitly excluded]
**Invariants**: [What must NOT change]
**Verification**: [How we know it's done AND safe]
**Risks & Rollback**: [What could break | detect | back out]
**Coverage baseline**: [Tested? Characterization tests needed?]
```

## Asking About Missing Dimensions

When a dimension is unresolved, ask in prose:

- "What's driving this now — a blocked deletion, a build cycle, a flaky test, or an EOL dependency?"
- "Which modules are in scope, and what should this task explicitly NOT touch?"
- "What must stay identical — the public API, the on-disk format, the observable behavior?"
- "Is the touched code covered by tests today, or do we need characterization tests first?"
- "If this lands and breaks something, how would we notice, and how do we roll it back?"

Avoid `AskUserQuestion` option chips for these — discovery is open-ended; option chips would force contrived choices and constrain the user's answer.

## What Goes Wrong When a Dimension is Missing

| Missing | Symptom in the resulting task |
|---|---|
| Motivation | Reviewers can't judge whether the change is worth the risk; debt isn't prioritized |
| Scope & Blast Radius | Open-ended "clean up the code"; reviewer can't reason about risk; scope creep |
| Invariants | Behavior changes sneak in unnoticed; contracts silently broken |
| Verification | "Done" is a matter of opinion; no gate proves safety |
| Risks & Rollback | A breakage ships with no detection plan and no exit |
| Definition of Done | Task ends in a vague "looks better" with nothing objectively checkable |

If a draft is ready and the quality checklist fails, the missing dimension is usually the diagnosis.
