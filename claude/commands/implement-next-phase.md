---
description: Implement and commit the next phase of a plan, then open a draft pull request
argument-hint: "<plan-file-path>"
---

# Implement Next Phase

Implement exactly one phase from a `plan-feature` implementation plan.

## Input

Treat `$ARGUMENTS` as the path to the plan file.

If it is empty, stop and respond:

`Usage: /implement-next-phase <plan-file-path>`

Read the file fully. Stop if it does not exist or is not a regular file.

## Plan contract

Accept only the format emitted by `plan-feature`. The plan must contain one or more
`## Phase N:` sections, and every phase must contain these subsections:

- `### Pull Request Description`
- `### TDD Cycles`, with `#### Cycle N:` entries and `- [ ] Complete` or
  `- [x] Complete` state;
- `### Automated Testing`, with a `**Run:**` command;
- `### Done When`, with checkboxes.

Stop with a validation error that names every missing required section. Do not infer
phases or progress from other Markdown formats.

## Preflight

Complete every check before modifying the repository or plan:

1. Run `git status --porcelain`. Stop unless it is empty. The plan is expected to be
   outside version control and therefore absent from this output.
2. Read the current branch with `git branch --show-current`. Stop if detached.
3. Determine `BASE` using Step 2 of the `writing-instinct-prs` skill. Stop if the
   current branch equals `BASE`; the user must prepare the branch or worktree.
4. Extract the last Jira key matching `[A-Z]+-[0-9]+` from the branch name. Stop if
   none exists.
5. Run `jira me` and `gh auth status`. Stop with the failing command's remediation
   message if either authentication check fails.
6. Check `gh pr list --head "$BRANCH" --state all`. Stop if a pull request already
   exists for the current branch.

Do not create or switch branches during preflight.

## Select the phase

Scan phases in document order. Select the first phase containing an unchecked TDD,
automated-testing, or done-criteria checkbox. A partially completed phase remains
the next phase.

If no phase has an unchecked required checkbox, stop and respond that the plan has
no next phase. Do not modify the plan, commit, push, or create a pull request.

Hold the selected phase's boundaries in memory. Never implement, verify, or update a
later phase during this invocation, even when the selected phase unblocks it.

Record `START_HEAD=$(git rev-parse HEAD)` before beginning the selected phase. Use
this exact commit later to decide whether this invocation produced code commits.

## Implement the selected phase

Invoke the `practicing-tdd` skill and follow it strictly. Process only unchecked
cycles in the selected phase, in order:

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

### Failed cycle

If a cycle cannot reach or remain green, stop immediately. Preserve its uncommitted
test and implementation changes, leave its `Complete` checkbox unchecked, and
report the exact failing command plus its output. Do not reset, commit, continue to
another cycle, or create a pull request.

### Plan differences

Stop and ask for human direction before changing approved scope or behavior. Do not
silently redesign a cycle or move work across phase boundaries.

Minor implementation choices may proceed. When committed work differs from a
cycle's structural context without changing its behavior or scope, preserve the
original cycle text and add a concise `**Implementation note:**` beneath that cycle
in the plan before continuing.

## Verify the phase

After every selected-phase cycle is complete:

1. Run the exact command under the phase's `### Automated Testing` section and check
   its documented expected test count and zero-failure requirement.
2. Run each lint and type-check command named under `### Done When`.
3. Mark an automated-testing or done-criteria checkbox only after its own statement
   is true. Leave failed or unverified items unchecked.
4. Confirm the phase's documented safe stopping point still holds.

If any required check fails, stop with the command and output. Keep completed cycle
commits and current plan checkboxes, but do not push or create a pull request.

Compare `git rev-parse HEAD` with `START_HEAD`. If they are equal, report that the
phase required no code changes and stop without pushing or creating a pull request.
Do not reuse commits that predate this invocation.

## Prepare the pull request

Invoke `writing-instinct-prs` and follow its title, Context, Changes, Concerns, and
humanization requirements. Give the selected phase's `Pull Request Description` to
the skill as approved scope context alongside its Jira context.

The commits and diff are the source of truth for what was built. If their details
differ from the planned description, correct the pull request text to match the
committed result without widening the approved scope. Never mention phase numbers,
tests, plan mechanics, or AI assistance in the title or body.

Push the branch with `git push -u origin HEAD`. Then create the pull request with the
base, title, and body established above:

`gh pr create --draft --base "$BASE" --title "$TITLE" --body "$BODY"`

Stop and report the failing command if either operation fails. Never omit `--draft`
and never fall back to a non-draft pull request.

## Report

Report only the work from this invocation:

- selected phase and completion status;
- cycle commits created, or cycles verified as already complete;
- final test, lint, and type-check results;
- plan checkboxes and implementation notes updated;
- draft pull request URL.

Do not begin or propose implementation of the next phase.
