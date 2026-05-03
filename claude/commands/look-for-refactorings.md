---
description: Look for refactoring opportunities in code changes between two refs
argument-hint: [start] [end]
allowed-tools: Bash, Read, Grep, Glob, Skill
---

# Look for Refactorings

Audit source code changes holistically against the `refactoring-code` skill — surface code smells and refactoring opportunities. Compares an end ref against a start ref — works for a single branch (`/look-for-refactorings`), a feature branch off a non-default trunk (`/look-for-refactorings develop`), or a stack of dependent branches (`/look-for-refactorings main top-of-stack`).

## Variables

ARGS: $ARGUMENTS
SCOPE_GLOBS: `'*' ':(exclude)*_test.*' ':(exclude)*test_*.*' ':(exclude)*.test.*' ':(exclude)*.spec.*' ':(exclude)test/**' ':(exclude)tests/**' ':(exclude)spec/**' ':(exclude)__tests__/**' ':(exclude)package-lock.json' ':(exclude)yarn.lock' ':(exclude)pnpm-lock.yaml' ':(exclude)Gemfile.lock' ':(exclude)mix.lock' ':(exclude)Cargo.lock' ':(exclude)poetry.lock' ':(exclude)composer.lock' ':(exclude)*.min.js' ':(exclude)*.min.css' ':(exclude)dist/**' ':(exclude)build/**' ':(exclude)node_modules/**' ':(exclude)vendor/**' ':(exclude)*.generated.*' ':(exclude)*.pb.go' ':(exclude)*.svg' ':(exclude)*.png' ':(exclude)*.jpg' ':(exclude)*.jpeg' ':(exclude)*.gif' ':(exclude)*.ico' ':(exclude)*.pdf' ':(exclude)*.lock' ':(exclude)*.lockb'`

## Instructions

- Report findings in chat only. Do not write artifact files.
- The audit is **holistic**: evaluate the diff as a single body of work, including cross-file duplication.
- **Scope**: non-test source code only. Test design and structure is out of scope — see `/audit-tests`.
- STOP conditions (report message and halt without invoking the skill):
  - Default START unresolvable: `Cannot determine default start ref (no main or master). Pass one explicitly: /look-for-refactorings <start> [end]`.
  - Default END unresolvable (detached HEAD): `Detached HEAD — pass an explicit end ref: /look-for-refactorings <start> <end>`.
  - START or END does not resolve: `Cannot resolve <ref>`.
  - No common ancestor: `<start> and <end> have no common ancestor`.
  - No source files in the diff: `No source changes detected in <range>`.
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

6. **List changed source files** — expand `$SCOPE_GLOBS` as positional pathspecs:
   ```bash
   eval "git diff --name-only --diff-filter=AMR \"\$BASE...\$END\" -- $SCOPE_GLOBS"
   ```
   Capture as `CHANGED_SOURCES`. If empty, STOP per Instructions (report `No source changes detected in $BASE...$END`).

7. **Invoke `refactoring-code`** via the Skill tool. Pass:
   - The diff range (`$BASE...$END`)
   - `CHANGED_SOURCES` (full paths)
   - Instruction to evaluate the entire set as a single body of work — surface code smells and refactoring opportunities holistically, including cross-file duplication
   - Instruction to **omit any smell category with no observations** rather than emit empty headers

8. **Render the Report below** using only the categories the skill returned findings for.

## Report

```
# Refactoring Audit

**Range**: <START>...<END> (base: <BASE>)
**Sources audited**: <N> files

## Files
- <path/to/source.ext>
- ...

## Findings by Category

(One section per smell/refactoring category that had observations. Categories with nothing to flag are omitted. Examples: Duplicated Code, Long Method, Large Class, Feature Envy, Primitive Obsession, Data Clumps, Shotgun Surgery.)

### <Category name>
- <observation with file:line refs>

## Prioritized Recommendations

1. **[High]** <action>
2. **[Med]** <action>
3. **[Low]** <action>
```
