# Deciding Task Size and How Many Done Conditions

See [anti-patterns.md](anti-patterns.md) for failure modes — "Oversized Task" and "Task-List Dump" — that often indicate "split this task" rather than "add more conditions."

There is no fixed condition count. The right size is governed by one question: **can this land and be verified as one focused, independently revertable change?** These heuristics help:

| Signal | Action |
|--------|--------|
| Conditions share one risk profile and the change reverts as a unit | Keep as one task; add conditions as needed |
| Conditions have different risk profiles (e.g., a dep bump *and* a refactor) | Split the task |
| The change spans many unrelated modules | Split by module / seam |
| Touched code has thin coverage | Add a "characterization tests first" condition before splitting |
| A behavior change is hiding in a refactor | Split the behavior change into its own task (and a story if user-observable) |
| Config change + bulk code churn in one diff | Split config from the mechanical reformat into separate commits/tasks |
| Each invariant needs its own guard | At least one verifiable condition per invariant |

## When to Add a Condition vs. Split the Task

**Add a condition** when it guards the *same* change: another invariant to assert, another gate to pass, another path to characterize. More conditions on a coherent change is good — it sharpens "done."

**Split the task** when conditions pull in different directions: different risk, different rollback unit, different reviewers' concern. A dependency upgrade and an architectural refactor do not belong in one task even if you *could* land them together — they fail and revert independently.

## Splitting Heuristics by Task Type

- **Refactor**: split by seam. One import to break, one module to extract, one rename — each independently revertable. Never bundle a behavior change in.
- **Test work**: split by suite or concern. Stabilizing flaky tests is one task; raising coverage on a module is another; migrating runners is a third.
- **Dependency & tooling**: split per dependency or per tool. One dep bump per task keeps the compatibility gate meaningful and the revert clean. Separate a tool's *config adoption* from the *bulk reformat* it triggers.

## The Verifiability Test

If you cannot write a Definition of Done where every item is objectively checkable, the task is either under-specified (missing dimensions — see [discovery-dimensions.md](discovery-dimensions.md)) or too large to verify (split it). "Done" that depends on judgment is a sizing smell, not a wording problem.

## Why This Differs From Story Criteria Counting

For Agile stories, the count question is about conversation and coverage of behavior. For dev tasks it is about **verifiability and revertability**: a task is the right size when its end state is fully checkable and it can be backed out as a unit. Optimize the split around clean verification and clean rollback, not around a target number of checkboxes.
