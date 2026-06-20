# Dev Task Examples

Complete examples demonstrating the writing-dev-tasks skill, one per task type. See [templates.md](templates.md) for the empty templates these examples fill, and [anti-patterns.md](anti-patterns.md) for the failure modes the examples deliberately avoid.

## Contents

- [Example 1: Refactor — Break the auth → legacy import](#example-1-refactor--break-the-auth--legacy-import)
- [Example 2: Test Work — Stabilize the flaky checkout E2E suite](#example-2-test-work--stabilize-the-flaky-checkout-e2e-suite)
- [Example 3: Dependency & Tooling — Upgrade React 18 → 19](#example-3-dependency--tooling--upgrade-react-18--19)
- [Anti-Pattern Examples](#anti-pattern-examples)
- [Task Sizing Guide](#task-sizing-guide)

---

## Example 1: Refactor — Break the auth → legacy import

A restructuring task with an explicit behavior-preservation invariant and a characterization-test note.

### Discovery Summary

**Motivation**: `auth/` imports session validation from `legacy/`, blocking deletion of `legacy/` and forcing a circular build dependency.
**Scope**: In: `auth/session.ts`, `auth/index.ts`, `legacy/gatekeeper.ts` call sites. Out: token format, password hashing, `authenticate()` signature.
**Invariants**: Same requests allowed/denied; `authenticate()` signature and return type unchanged.
**Verification**: Existing suite passes unchanged; `auth/` has no `legacy/` import; gates clean.
**Risks & Rollback**: A hidden `legacy/` call site is missed → caught by the suite; revert is a single git revert.
**Coverage baseline**: Session validation has happy-path tests only; deny/expired paths are uncovered → add characterization tests first.

### Final Task

```markdown
## Task: Break the auth → legacy import

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
- [ ] Characterization tests added for the deny and expired-session paths BEFORE the move
- [ ] Full test suite passes, no new failures
- [ ] `auth/` no longer imports from `legacy/`
- [ ] No public API signatures changed
- [ ] Typecheck + lint clean
```

---

## Example 2: Test Work — Stabilize the flaky checkout E2E suite

A test-hardening task. The "behavior" being preserved is the test's intent; the change must not weaken what the test actually asserts.

### Discovery Summary

**Motivation**: `checkout.e2e.ts` fails ~15% of CI runs on a race between the cart-update request and the assertion, eroding trust in CI and triggering needless reruns.
**Scope**: In: `checkout.e2e.ts`, the shared `waitForCart` helper. Out: production checkout code, other E2E specs.
**Invariants**: The suite still asserts the same end states (cart total, confirmation shown); no assertion is deleted or loosened to "make it green".
**Verification**: 50 consecutive CI runs green; no `sleep`/fixed-delay introduced.
**Risks & Rollback**: A masked real bug could be hidden by a better wait → mitigated by keeping every assertion; revert is per-file.
**Coverage baseline**: N/A (this is test work); the concern is not weakening coverage.

### Final Task

```markdown
## Task: Stabilize the flaky checkout E2E suite

`checkout.e2e.ts` fails about 15% of CI runs because the assertion races the
cart-update request, so the suite is rerun by reflex and no longer trusted.
Replace the implicit timing assumption with an explicit wait on the cart-update
completing, without weakening what the test asserts.

### Scope
In: `checkout.e2e.ts`, the shared `waitForCart` helper.
Out: production checkout code, all other E2E specs.

### Invariants
- The suite still asserts the same end states: final cart total and the
  confirmation screen. No assertion is deleted or loosened.
- The fix is a synchronization fix, not a `sleep`/fixed-delay.

### Definition of Done
- [ ] `waitForCart` waits on the cart-update completing, not a fixed delay
- [ ] No `sleep(` or fixed `setTimeout` delay introduced in the spec or helper
- [ ] Every existing assertion in `checkout.e2e.ts` is retained
- [ ] 50 consecutive CI runs of the spec pass (documented in the PR)
- [ ] Lint clean
```

---

## Example 3: Dependency & Tooling — Upgrade React 18 → 19

A dependency upgrade with a compatibility gate, kept separate from any behavior change.

### Discovery Summary

**Motivation**: React 18 is going EOL for security patches; staying current unblocks two libraries that now require 19.
**Scope**: In: `package.json`, lockfile, `@types/react`, deprecated-API call sites. Out: component behavior, styling, the design system's public props.
**Invariants**: No component renders differently; no public component prop signatures change.
**Verification**: Suite passes unchanged; deprecated APIs grep-clean; typecheck clean against React 19 types.
**Risks & Rollback**: A deprecated API (`ReactDOM.render`) still in use breaks at runtime → caught by typecheck + suite; revert is a lockfile + `package.json` revert.
**Coverage baseline**: Component suite is healthy; no new characterization tests needed.

### Final Task

```markdown
## Task: Upgrade React 18 → 19

React 18 is reaching end of life for security patches, and two dependencies we
want now require React 19. Move `react` and `react-dom` to 19, migrate the
remaining deprecated APIs, and update the React types — with no change to how
any component renders.

### Scope
In: `package.json`, the lockfile, `@types/react`, the deprecated-API call sites
(`ReactDOM.render`, legacy context).
Out: component behavior, styling, the design system's public prop signatures.

### Invariants
- No component renders differently from before.
- No public component prop signatures change.

### Definition of Done
- [ ] `react` and `react-dom` at `^19.0.0` in `package.json` and the lockfile
- [ ] No remaining `ReactDOM.render` / legacy-context usage — grep clean
- [ ] `@types/react` and `@types/react-dom` at 19; typecheck clean
- [ ] Full test suite passes, no new failures
- [ ] Production build succeeds; CI green
```

---

## Anti-Pattern Examples

### What NOT to Write

**Behavior-change leak in a refactor**:
```markdown
❌ ## Task: Refactor the date parser and fix the timezone bug

Extract parsing into date/parse.ts, and while we're in there, default a
missing offset to UTC instead of erroring.
```

**Task-list dump (steps instead of outcome)**:
```markdown
❌ ### Steps
1. Cut validateSession from auth/index.ts
2. Paste into auth/session.ts
3. Update the import in legacy/gatekeeper.ts
(no Definition of Done — when is this done and safe?)
```

**Unverifiable done**:
```markdown
❌ ### Definition of Done
- [ ] Code is cleaner
- [ ] Architecture is improved
```

**Open-ended scope**:
```markdown
❌ ## Task: Clean up the auth code
(no in/out — what does this touch, and what is it forbidden to touch?)
```

---

## Task Sizing Guide

### Too Large (Oversized)
```markdown
❌ Modernize the backend

Upgrade 6 dependencies, migrate Jest → Vitest, refactor auth out of legacy,
and adopt a linter — in one task.
```

### Right Size (Tasks)
```markdown
✅ Task 1: Upgrade the HTTP client (one dep, isolated)
✅ Task 2: Migrate Jest → Vitest
✅ Task 3: Break the auth → legacy import
✅ Task 4: Adopt the linter
```

Each task should land and be verified as one focused, independently revertable change with its own Definition of Done. Note ordering where one task depends on another.
