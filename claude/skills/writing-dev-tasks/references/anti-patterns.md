# Anti-Patterns in Dev Tasks

Common mistakes to avoid when writing well-scoped, verifiable development tasks.

## Contents

- [Behavior-Change Leak in a Refactor](#behavior-change-leak-in-a-refactor)
- [Task-List Dump (Steps Instead of Outcome)](#task-list-dump-steps-instead-of-outcome)
- [Unverifiable Done](#unverifiable-done)
- [Open-Ended Scope](#open-ended-scope)
- [Implicit Invariants](#implicit-invariants)
- [Refactoring Blind (No Coverage Baseline)](#refactoring-blind-no-coverage-baseline)
- [Tooling Change That Silently Rewrites Code](#tooling-change-that-silently-rewrites-code)
- [Dependency Upgrade With No Compatibility Gate](#dependency-upgrade-with-no-compatibility-gate)
- [Feature Disguised as a Dev Task](#feature-disguised-as-a-dev-task)
- [Oversized Task](#oversized-task)

## Behavior-Change Leak in a Refactor

The headline anti-pattern. A refactor must preserve observable behavior. It leaks when a behavior change is smuggled in under the banner of "cleanup": a "while I'm in here" bug fix, a tightened validation, a changed default, a new edge-case return value.

The substitution test (the refactor mirror of Farley's behavior test): if you reverted to the old structure, every test that passes now should still pass, and vice versa. If a test had to change to describe *new* behavior, you changed behavior — split it out into its own task (and a story if user-observable).

```
❌ ## Task: Refactor the date parser and fix the timezone bug

   Extract the parser into date/parse.ts, and while we're at it make it
   handle the missing-offset case by defaulting to UTC.

✅ ## Task: Extract the date parser into date/parse.ts

   Move parsing out of the 800-line utils.ts into date/parse.ts. No change
   to parse results for any input the current suite covers.

   ### Invariants
   - Parsing the same input yields the same result (incl. the missing-offset case)

   (The missing-offset behavior change is a separate task with its own tests.)
```

## Task-List Dump (Steps Instead of Outcome)

The dominant failure mode: defining the task as a sequence of edits ("edit X, then Y, then Z") with no Definition of Done. Steps are a plan; they belong in the implementation plan, not the task definition. Define the verifiable end state and let the steps emerge during execution.

```
❌ ### Steps
   1. Open auth/index.ts
   2. Cut the validateSession function
   3. Paste it into auth/session.ts
   4. Update the import in legacy/gatekeeper.ts

✅ ### Definition of Done
   - [ ] Full test suite passes, no new failures
   - [ ] auth/ no longer imports from legacy/
   - [ ] No public API signatures changed
```

## Unverifiable Done

Done conditions that can't be objectively checked. "Cleaner", "more maintainable", "better structured" are judgments, not gates. Every item must be pass/fail, present/absent, true/false.

```
❌ - [ ] Code is cleaner
   - [ ] Architecture is improved
   - [ ] Tests are better

✅ - [ ] No function in payments/ exceeds 50 lines
   - [ ] payments/ has no import from legacy/
   - [ ] Line coverage on payments/ ≥ 85%
```

## Open-Ended Scope

No statement of what's in and what's explicitly out. The reviewer can't reason about blast radius, and the change sprawls.

```
❌ ## Task: Clean up the auth code

✅ ## Task: Break the auth → legacy import

   ### Scope
   In: auth/session.ts, auth/index.ts, legacy/gatekeeper.ts call sites
   Out: token format, password hashing, the authenticate() signature
```

## Implicit Invariants

Assuming "obviously nothing breaks" instead of stating what must NOT change. Public API, contracts, on-disk formats, and observable behavior are first-class — name them so the reviewer and CI can guard them.

```
❌ (no invariants section — "it's just a refactor")

✅ ### Invariants
   - authenticate() keeps its current signature and return type
   - The session cookie format on disk is unchanged
   - The same requests are allowed/denied
```

## Refactoring Blind (No Coverage Baseline)

Restructuring code that has thin or no test coverage, with nothing to catch a regression. The substitution test is meaningless if no test exercises the behavior.

```
❌ ## Task: Rewrite the pricing engine to use the strategy pattern
   (pricing/ currently has 3 tests covering 1 of 9 branches)

✅ ## Task: Restructure the pricing engine to the strategy pattern

   ### Definition of Done
   - [ ] Characterization tests added for all 9 pricing branches BEFORE refactor
   - [ ] Those tests pass unchanged after the refactor
   - [ ] No change to computed price for any covered input
```

## Tooling Change That Silently Rewrites Code

Adopting a formatter or linter and folding the resulting code churn into the same task as the config change, so a real behavior change can hide in a 4,000-line diff. Separate the config from the bulk reformat; make the reformat a no-op-behavior commit.

```
❌ ## Task: Add Prettier
   (PR touches 600 files; reviewers can't tell config from logic changes)

✅ ## Task: Adopt Prettier formatting

   ### Definition of Done
   - [ ] Config + CI check added in one commit
   - [ ] Bulk reformat in a separate commit touching only whitespace/layout
   - [ ] git diff -w shows no substantive change in the reformat commit
   - [ ] Full suite passes, no new failures
```

## Dependency Upgrade With No Compatibility Gate

Bumping a dependency without stating how breaking changes are detected. "Upgrade React to 19" with no gate ships whatever breaks.

```
❌ ## Task: Upgrade to React 19

✅ ## Task: Upgrade React 18 → 19

   ### Definition of Done
   - [ ] react + react-dom at ^19.0.0 in package.json and lockfile
   - [ ] No remaining deprecated APIs (ReactDOM.render, etc.) — grep clean
   - [ ] Full test suite passes, no new failures
   - [ ] Typecheck clean against @types/react 19
```

## Feature Disguised as a Dev Task

Wrapping user-facing behavior in technical language to avoid writing a story. If a user can see or do something different, it needs a story with acceptance criteria, not (only) a dev task.

```
❌ ## Task: Add a retry queue to the export service
   (so users now get a "retrying…" status they didn't have before)

✅ This has observable user behavior → write an Agile story for the user-facing
   "export retries automatically and shows status" behavior. A separate dev
   task can cover any non-user-facing queue refactor.
```

## Oversized Task

Trying to land too much as one change so it can't be verified or reverted cleanly. If the Definition of Done has conditions with different risk profiles, or the change spans many unrelated modules, split it.

```
❌ ## Task: Modernize the backend
   (upgrade 6 deps, migrate the test runner, refactor auth, adopt a linter)

✅ Split into independently verifiable tasks:
   - Upgrade the HTTP client (one dep, isolated)
   - Migrate Jest → Vitest
   - Break the auth → legacy import
   - Adopt the linter
   (each with its own Definition of Done; note ordering)
```

---

**How many done conditions, and when to split?** See [task-sizing.md](task-sizing.md) for heuristics on adding conditions vs. splitting the task.
