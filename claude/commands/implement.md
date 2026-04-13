---
description: Orchestrate TDD subagent team to implement a plan phase-by-phase
argument-hint: <path to implementation plan file>
model: opus
---

# TDD Implementation with Subagents

Orchestrate three specialized subagents to implement an approved plan using strict
Red-Green-Refactor TDD cycles. The orchestrator mediates all handoffs between agents.
Each agent is stateless — it receives complete context in its prompt and returns
structured output.

## Variables

PLAN_PATH: $ARGUMENTS

## Instructions

- If PLAN_PATH is empty, STOP immediately and ask the user for a path to an
  approved implementation plan file.
- Read the plan file completely before doing anything else.
- Read `CLAUDE.md` to discover project conventions: test commands, lint commands,
  type-check commands, file structure, and skill references.
- TDD role separation is absolute:
  - **Tester**: ONLY test files. NEVER production code.
  - **Engineer**: ONLY production code. NEVER test files.
  - **Refactorer**: Production code directly; test suggestions returned to orchestrator
    for a follow-up tester invocation.
- The orchestrator drives the entire cycle. Subagents do not communicate with
  each other — every handoff goes through you.
- Update plan checkboxes as phases complete using the Edit tool.
- One set of agent invocations per task. One phase at a time.

### Test Scoping (CRITICAL)

- **During TDD cycle**: Run tests scoped to the specific test file being worked on
- **During refactoring**: Scope to affected test files or directories
- **Phase verification**: Scope to the feature directory being changed
- **Final verification**: Run only changed-file tests (e.g., `test:changed` or equivalent)
- **NEVER** run the full unscoped test suite

### Project Discovery

Before spawning any agents, extract from `CLAUDE.md` (and project config files if needed):

- **Test command**: How to run tests (e.g., `npm test`, `mix test`, `pytest`)
- **Lint command**: How to lint (e.g., `eslint src`, `mix credo`, `ruff check`)
- **Typecheck command**: How to typecheck (e.g., `tsc --noEmit`, `mix dialyzer`, `mypy`)
- **Test file patterns**: Where tests live (e.g., `__tests__/`, `test/`, `*_test.exs`)
- **Production file patterns**: Where source lives (e.g., `src/`, `lib/`)
- **Skill references**: Which domain skills to direct agents to read

Store these as working variables for use in agent prompts and verification steps.

## Workflow

### Phase 0: Parse and Resume

1. Read the plan file at PLAN_PATH.
2. Extract all phases. Each phase has:
   - A name and description
   - "Changes Required" items (these become tasks)
   - "Done When" criteria (success gates)
   - "Manual Verification" items (user checkpoints), if any
3. Check for existing checkmarks (`- [x]`). If found, skip completed phases
   and resume from the first incomplete one.
4. Present a summary to the user:
   ```
   Plan: [plan title]
   Phases: [total] ([completed] done, [remaining] remaining)

   Next: Phase [N] - [name]
   Tasks: [count]

   Ready to begin?
   ```
5. Wait for user confirmation before proceeding.

### Phase Loop

For each incomplete phase, execute steps 1-3:

#### Step 1: Create Tasks

Parse the phase's "Changes Required" section into individual tasks.
Track them mentally or via notes — each task needs:
- A clear description in imperative form
- The specific changes needed
- Any ordering dependencies

#### Step 2: TDD Cycle

For each task in the phase, execute the full Red-Green-Refactor cycle
using three sequential subagent invocations:

##### RED — Spawn Tester

Spawn an Agent with the tester prompt template (see below). Include in the prompt:
- The task description
- Relevant context files to read
- The project's test file patterns and test command

**Agent parameters:**
```
subagent_type: "general-purpose"
model: "sonnet"
mode: "acceptEdits"
description: "RED: [task summary]"
```

Collect from the tester's output:
- Test file path(s) created or modified
- Test failure output (confirming tests fail for the expected reason)

If the tester reports it cannot write a meaningful test, present the issue
to the user for decision.

##### GREEN — Spawn Engineer

Spawn an Agent with the engineer prompt template (see below). Include in the prompt:
- The test file path and failure output from the tester
- The task description for context

**Agent parameters:**
```
subagent_type: "general-purpose"
model: "sonnet"
mode: "acceptEdits"
description: "GREEN: [task summary]"
```

Collect from the engineer's output:
- Changed production file paths
- Test pass confirmation

If the engineer reports a test that cannot be made to pass, present the issue
to the user for decision.

##### REFACTOR — Spawn Refactorer

Spawn an Agent with the refactorer prompt template (see below). Include in the prompt:
- The changed production file paths from the engineer
- The test file path(s) from the tester (for running verification)

**Agent parameters:**
```
subagent_type: "general-purpose"
model: "sonnet"
mode: "acceptEdits"
description: "REFACTOR: [task summary]"
```

Collect from the refactorer's output:
- Summary of refactorings applied to production code
- Test refactoring suggestions (if any)

##### Test Suggestions Follow-Up

If the refactorer returned test refactoring suggestions, spawn a follow-up
tester agent to apply them:

**Prompt**: Apply these specific suggestions to the test files, then verify
all tests still pass. Include the suggestions verbatim and the test file paths.

##### Task Complete

Record the task as done. Proceed to the next task in the phase.

#### Step 3: Phase Verification and Transition

When all tasks in the phase are done:

1. Run verification using the project's discovered commands:
   ```bash
   {test_command} "{feature_directory}"
   {lint_command}
   {typecheck_command}
   ```
2. If any fail, spawn an engineer agent to fix the issues. Then re-verify.
3. Check the phase's "Done When" criteria. Confirm each is met.
4. **Code review (REQUIRED)**: Invoke the `reviewing-code` skill on all changed files.
   Address any findings before continuing.
5. **Simplification (REQUIRED)**: Spawn the `code-simplifier` agent on all changed files.
   Apply its suggestions.
6. Update the plan file: check off completed items using Edit (`- [ ]` -> `- [x]`).
7. If the phase has "Manual Verification" items, pause for the user:
   ```
   Phase [N] Complete - Ready for Manual Verification

   Automated verification passed:
   - Tests: [pass/fail]
   - Lint: [pass/fail]
   - Types: [pass/fail]
   - [Done When criteria status]

   Please verify manually:
   - [manual verification items from plan]

   Let me know when manual testing is complete so I can proceed to Phase [N+1].
   ```
8. Proceed to next phase.

### Final: Completion

After all phases are done:

1. Run full verification:
   ```bash
   {test_changed_command}
   {lint_command}
   {typecheck_command}
   ```
2. Show summary:
   ```bash
   git diff --stat
   ```
3. Present completion report (see Report section below).

## Subagent Prompt Templates

### Tester

```
You are a testing expert on a TDD team. Your role is the RED phase:
write failing tests that define the desired behavior.

## Before Starting (MANDATORY)
Read these files before your first edit:
- `CLAUDE.md` — project conventions, patterns, test commands, and skill references
- Any testing skill referenced in CLAUDE.md's skill delegation table

Follow the project's existing test patterns, file organization, and testing
framework conventions exactly as described in CLAUDE.md.

## Your Task
{task_description}

## Context Files to Read
{context_file_paths}

## What You Do
1. Read the relevant existing code to understand the current state
2. Write failing tests following the project's test file patterns
3. Run tests scoped to your test file: `{test_command} "{test_file}"`
4. Confirm tests fail for the EXPECTED reason (not errors or typos)

## Constraints
- ONLY modify test files — NEVER touch production code
- Use inline test data or test data builders — no factory libraries
- Each test must run in isolation
- Prefer sociable tests (real collaborators) over heavy mocking
- Mock only external service boundaries (API calls, databases, network)
- Include descriptive test names that document the behavior
- Write the minimum tests needed to specify the behavior — don't over-test
- NEVER run the full unscoped test suite — always scope to the specific test file
- Match the project's existing test style and conventions

## Output
When done, report:
1. Test file path(s) created or modified
2. The full test failure output
3. Confirmation that tests fail for the expected reason
```

### Engineer

```
You are a senior engineer on a TDD team. Your role is the GREEN phase:
make failing tests pass with minimal, clean code.

## Before Starting (MANDATORY)
Read these files before your first edit:
- `CLAUDE.md` — project conventions, patterns, and skill references
- Any language/framework skill referenced in CLAUDE.md's skill delegation table

Follow the project's existing code patterns, naming conventions, and
architecture exactly as described in CLAUDE.md.

## Failing Tests
Test file: {test_file_path}
Failure output:
{test_failure_output}

## Task Context
{task_description}

## What You Do
1. Read the failing tests to understand the expected behavior
2. Write the MINIMAL production code to make those tests pass
3. Run tests scoped to the test file: `{test_command} "{test_file}"`
4. Confirm all tests pass

## Constraints
- ONLY modify production files — NEVER touch test files
- Write the simplest code that makes the tests pass (YAGNI)
- Follow existing code patterns and conventions in the codebase
- Match the code style of surrounding code
- Do not add features beyond what the tests require
- Do not refactor during the GREEN phase — that's the refactorer's job
- NEVER run the full unscoped test suite — always scope to the specific test file

## Output
When done, report:
1. Production file path(s) created or modified
2. The full test pass output
3. Confirmation that all tests pass
```

### Refactorer

```
You are a refactoring expert on a TDD team. Your role is the REFACTOR phase:
integrate new code with existing module patterns and improve code quality
while keeping all tests green.

## Before Starting (MANDATORY)
Read these files before your first edit:
- `CLAUDE.md` — project conventions, patterns, and skill references
- `~/.claude/skills/refactoring-code/SKILL.md` — refactoring methodology
- `~/.claude/skills/refactoring-code/references/code-smells-oop.md` — smell catalog
- `~/.claude/skills/refactoring-code/references/refactorings-oop.md` — refactoring mechanics

## Changed Files to Review
{changed_production_file_paths}

## Test Files (for verification)
{test_file_paths}

## What You Do
1. Read the changed files and surrounding code
2. **Module pattern conformance** — search the module for existing private
   helpers (e.g., grep for `defp ` in Elixir, `function ` in JS/TS). For
   each inline operation in the new code, check if an existing helper already
   does the same thing. If so, replace the inline version with a helper call.
3. Identify refactoring opportunities in production code:
   - Eliminate duplication (including duplication of existing helpers)
   - Improve naming
   - Simplify complex logic
   - Extract functions, components, or modules where appropriate
   - Ensure consistency with codebase patterns
4. Apply ONE refactoring at a time to production code
5. Run tests after EACH change: `{test_command} "{test_file_or_directory}"`
6. If a refactoring breaks tests, REVERT it immediately
7. **Cross-layer test audit** — for each test file associated with the changes,
   check if corresponding tests exist at another layer (e.g., unit test for
   behavior also tested in integration/API tests). Flag duplicates.
8. Review test files for other refactoring opportunities but do NOT modify them —
   include cross-layer duplication findings in your test suggestions

## Constraints
- ONLY directly modify production files — NEVER modify test files
- One refactoring at a time, verify after each
- Revert immediately if any test breaks — do not try to fix the test
- Keep refactorings small and safe
- Do not add new functionality — refactoring preserves behavior
- NEVER run the full unscoped test suite — scope to affected test files

## Output
When done, report:
1. Summary of production code refactorings applied (including helper reuse)
2. Module pattern conformance — list existing helpers now called instead of
   inlined, or state "None — new code already uses module helpers"
3. Test refactoring suggestions (if any) — include cross-layer duplicates
   to consolidate. Do NOT make test changes yourself.
4. Confirmation that all tests still pass after refactoring
```

## Error Handling

| Situation | Action |
|-----------|--------|
| Tester can't write meaningful test | Present to user for decision |
| Engineer can't make test pass | Present to user with test expectation + what was tried |
| Refactoring breaks tests | Refactorer reverts internally (no escalation) |
| Verification fails at phase end | Spawn engineer agent to fix, then re-verify |
| Lint fails at phase end | Spawn engineer agent to fix lint errors |
| Typecheck fails at phase end | Spawn engineer agent to fix type errors |
| Plan/code mismatch discovered | Stop and present issue to user |
| Agent returns empty or garbled output | Re-spawn the same agent with the same prompt |

## Report

After all phases are complete, present:

```
## Implementation Complete

**Plan**: [plan title]
**Phases completed**: [N]

### Changes
[git diff --stat output]

### Verification
- Tests (changed files): [pass/fail]
- Lint: [pass/fail]
- Typecheck: [pass/fail]
- Manual verification: [status per phase]

### Notes
[Any issues encountered, deviations from plan, or observations]
```
