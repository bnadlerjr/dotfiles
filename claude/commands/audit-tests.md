---
description: Audit test changes between two refs against Farley's 8 properties
argument-hint: [start] [end]
allowed-tools: Bash, Read, Grep, Glob, Skill
---

# Audit Tests

Audit test changes holistically against the `reviewing-test-design` skill (Dave Farley's 8 properties). Compares an end ref against a start ref — works for a single branch (`/audit-tests`), a feature branch off a non-default trunk (`/audit-tests develop`), or a stack of dependent branches (`/audit-tests main top-of-stack`).

## Variables

ARGS: $ARGUMENTS
TEST_GLOBS: `'*_test.*' '*test_*.*' '*.test.*' '*.spec.*' 'test/**' 'tests/**' 'spec/**' '__tests__/**'`

## Instructions

- Report findings in chat only. Do not write artifact files.
- The audit is **holistic**: evaluate the diff as a single body of work.
- **Scope**: test files only. Production code refactoring is out of scope — see `/look-for-refactorings`.
- STOP conditions (report message and halt without invoking the skill):
  - Default START unresolvable: `Cannot determine default start ref (no main or master). Pass one explicitly: /audit-tests <start> [end]`.
  - Default END unresolvable (detached HEAD): `Detached HEAD — pass an explicit end ref: /audit-tests <start> <end>`.
  - START or END does not resolve: `Cannot resolve <ref>`.
  - No common ancestor: `<start> and <end> have no common ancestor`.
  - No test files in the diff: `No test changes detected in <range>`.
- If `$ARGS` contains more than two whitespace-separated tokens, use the first two and ignore the rest.

## Workflow

1. **Parse arguments.** Split `$ARGS` on whitespace into up to two tokens: `START` and `END`. Either or both may be empty.

2. **Default `START`** (only if empty):
   - `git show-ref --verify --quiet refs/heads/main` succeeds → `START=main`.
   - Else `git show-ref --verify --quiet refs/heads/master` succeeds → `START=master`.
   - Else STOP per Instructions.

3. **Default `END`** (only if empty):
   - `END=$(git branch --show-current)`. If empty, STOP per Instructions.

4. **Verify both refs resolve** — `git rev-parse --verify "$START^{commit}"` and same for `$END`. On failure, STOP per Instructions naming the unresolvable ref.

5. **Compute base** — `BASE=$(git merge-base "$START" "$END")`. On non-zero exit or empty output, STOP per Instructions.

6. **List changed test files** — expand `$TEST_GLOBS` as positional pathspecs:
   ```bash
   eval "git diff --name-only --diff-filter=AMR \"\$BASE...\$END\" -- $TEST_GLOBS"
   ```
   Capture as `CHANGED_TESTS`. If empty, STOP per Instructions (report `No test changes detected in $BASE...$END`).

7. **Identify production code under test** — for each path in `CHANGED_TESTS`, strip test markers (`_test`, `.spec`, `__tests__/`, `test_` prefix) and resolve to the project's source tree using Glob/Grep when the mapping is not 1:1. Capture as `PROD_CODE`.

8. **Invoke `reviewing-test-design`** via the Skill tool. Pass:
   - The diff range (`$BASE...$END`)
   - `CHANGED_TESTS` (full paths)
   - `PROD_CODE` (full paths)
   - Instruction to evaluate the entire set as a single body of work against Farley's 8 properties — not file-by-file
   - Instruction to **omit any property with no observations** rather than emit empty headers

9. **Render the Report below** using only the properties the skill returned findings for.

## Report

```
# Test Audit

**Range**: <START>...<END> (base: <BASE>)
**Tests audited**: <N> files

## Files
- <path/to/file_test.ext>
- ...

## Findings by Farley Property

(One section per property that had observations. Properties with nothing to flag are omitted.)

### <Property name>
- <observation with file:line refs>

## Prioritized Recommendations

1. **[High]** <action>
2. **[Med]** <action>
3. **[Low]** <action>
```
