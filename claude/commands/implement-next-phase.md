---
description: Implement and commit the next phase of a plan, then open a draft pull request
argument-hint: "<plan-file-path>"
---

# Implement Next Phase

Implement exactly one phase from a `plan-feature` or `plan-task` implementation plan.

## Input

Treat `$ARGUMENTS` as the path to the plan file.

If it is empty, stop and respond:

`Usage: /implement-next-phase <plan-file-path>`

Read the file fully. Stop if it does not exist or is not a regular file.

## Plan contract

Accept only the format emitted by `plan-feature` or `plan-task`. The plan must
contain one or more `## Phase N:` sections, and every phase must contain these
subsections:

- `### Pull Request Description`
- exactly one of `### TDD Cycles`, with `#### Cycle N:` entries, or `### Steps`,
  with `#### Step N:` entries, each with `- [ ] Complete` or `- [x] Complete`
  state;
- `### Automated Testing`, with a `**Run:**` command;
- `### Done When`, with checkboxes.

Stop with a validation error that names every missing required section. Do not infer
phases or progress from other Markdown formats.

## Preflight

Complete every check before modifying the repository or plan:

1. Run `git status --porcelain`. Stop unless it is empty. The plan is expected to be
   outside version control and therefore absent from this output.
2. Read the current branch with `git branch --show-current`. Stop if detached.
3. Determine `BASE` with `git machete show up`. Discard the result if it is empty,
   does not name a valid branch, or equals the current branch. If no valid result
   remains, use `master` when it exists, otherwise `main`. Stop if neither fallback
   exists or if the resolved `BASE` equals the current branch; the user must prepare
   the branch or worktree.
4. Run `gh auth status`. Stop with the command's remediation message if the
   authentication check fails.
5. Check `gh pr list --head "$BRANCH" --state all`. Stop if a pull request already
   exists for the current branch.

Do not create or switch branches during preflight.

## Select the phase

Scan phases in document order. Select the first phase containing an unchecked TDD,
step, automated-testing, or done-criteria checkbox. A partially completed phase
remains the next phase.

If no phase has an unchecked required checkbox, stop and respond that the plan has
no next phase. Do not modify the plan, commit, push, or create a pull request.

Hold the selected phase's boundaries in memory. Never implement, verify, or update a
later phase during this invocation, even when the selected phase unblocks it.

Record `START_HEAD=$(git rev-parse HEAD)` before beginning the selected phase. Use
this exact commit later to decide whether this invocation produced code commits.

## Implement the selected phase

For a `### Steps` phase, follow "Implement a Steps phase" below instead. For a
`### TDD Cycles` phase, invoke the `practicing-tdd` skill and follow it strictly.
Process only unchecked cycles in the selected phase, in order:

1. Read the cycle's Behavior, Assertion focus, Expected failure category, and
   Structural context. Inspect the named production and test code before editing.
2. Write or extend one behavioral test, then run the narrowest command that proves
   RED. Confirm it fails for the expected reason, not from setup or syntax errors.
3. If existing tests already establish the behavior, or no valid new check can be
   made to fail because the behavior exists, run the scoped test to verify it. Undo
   only a newly added passing check, mark the cycle's `Complete` checkbox, and
   continue without an empty commit.
4. Otherwise, write the minimum production change for GREEN. Run the scoped tests
   and confirm all are green with no new warnings.
5. Refactor only when useful, without adding behavior, and rerun the scoped tests.
6. Stage only the test and implementation changes for this cycle. Inspect the staged
   diff and unstage anything unrelated.
7. Invoke `writing-git-commits`, follow any repository commit template, and create
   one logical commit for the cycle. Never add AI attribution.
8. After the commit succeeds, change only this cycle's `- [ ] Complete` checkbox to
   `- [x] Complete` in the external plan.

Never stage or commit the plan file. Do not start another cycle until the current
cycle is committed and its plan checkbox is current.

### Implement a Steps phase

Do not invoke `practicing-tdd`. Process only unchecked steps in the selected phase,
in order. A step with a `**Behavior pinned:**` field is a Pin; a step with a
`**Change:**` field is a Change.

For a Pin:

1. Read the Behavior pinned, Assertion focus, and Structural context. Inspect the
   named production and test code, then write the characterization test.
2. Run it against the current code. It must pass. If it fails, stop and report
   that the plan's reading of current behavior is wrong. Never change production
   code to make a Pin pass.
3. Stage only the Pin, invoke `writing-git-commits`, and commit it alone. Then mark
   its `Complete` checkbox.

For a Change:

1. Read the Change, Verification, and Structural context. Inspect the named code
   before editing.
2. Make the change. If the Change is already true, run its Verification to confirm
   it, mark its `Complete` checkbox, and continue without an empty commit.
3. Run the step's Verification command(s) and every earlier Pin in the phase.
   Confirm the Pins pass and each command shows what the Verification states, with
   no new warnings and no existing test edited to describe new behavior. If an
   existing test seems to need editing, stop and ask; that is a behavior change.
4. Stage only this step's changes and inspect the staged diff. Invoke
   `writing-git-commits` and create one logical commit. Then mark its `Complete`
   checkbox.

The plan-file and one-at-a-time rules above apply to steps as they do to cycles.

### Failed cycle or step

If a cycle or step cannot reach or remain green, stop immediately. Preserve its
uncommitted test and implementation changes, leave its `Complete` checkbox
unchecked, and report the exact failing command plus its output. Do not reset,
commit, continue to another cycle or step, or create a pull request.

### Plan differences

Stop and ask for human direction before changing approved scope or behavior. Do not
silently redesign a cycle or step or move work across phase boundaries.

Minor implementation choices may proceed. When committed work differs from a
cycle's or step's structural context without changing its behavior or scope,
preserve the original text and add a concise `**Implementation note:**` beneath
that cycle or step in the plan before continuing.

## Verify the phase

After every selected-phase cycle or step is complete:

1. Run the exact command under the phase's `### Automated Testing` section and check
   its documented expected test count and zero-failure requirement.
2. Run each lint and type-check command named under `### Done When`.
3. Mark an automated-testing or done-criteria checkbox only after its own statement
   is true. Leave failed or unverified items unchecked.
4. Confirm the phase's documented safe stopping point still holds.

If any required check fails, stop with the command and output. Keep completed
cycle or step commits and current plan checkboxes, but do not push or create a pull
request.

Compare `git rev-parse HEAD` with `START_HEAD`. If they are equal, report that the
phase required no code changes and stop without pushing or creating a pull request.
Do not reuse commits that predate this invocation.

## Prepare the pull request

Set `TITLE` to the selected phase heading's pull request title, excluding the
`## Phase N:` prefix. Set `BODY` to the exact contents of the selected phase's
`### Pull Request Description`. Preserve both values verbatim; do not rewrite,
humanize, or otherwise alter them.

Compare the selected phase's approved pull request title and description with the
commits and diff, which are the source of truth for what was built. If either is
inaccurate, stop before pushing and report the discrepancy to the user. Do not edit
or replace the approved text.

Push the branch with `git push -u origin HEAD`. Then create the pull request with the
base, title, and body established above:

`gh pr create --draft --base "$BASE" --title "$TITLE" --body "$BODY"`

Stop and report the failing command if either operation fails. Never omit `--draft`
and never fall back to a non-draft pull request.

## Report

Report only the work from this invocation:

- selected phase and completion status;
- cycle or step commits created, or cycles or steps verified as already complete;
- final test, lint, and type-check results;
- plan checkboxes and implementation notes updated;
- draft pull request URL.

Do not begin or propose implementation of the next phase.
