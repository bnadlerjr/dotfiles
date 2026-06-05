---
description: Audit all source files under a path for refactoring opportunities and code improvements
argument-hint: [path]
allowed-tools: Bash, Read, Grep, Glob, Skill
---

# Improve Codebase

Audit every source file under a filesystem PATH holistically against the `refactoring-code` skill — surface code smells, refactoring opportunities, and code improvements. The path-based analog of `/look-for-refactorings`: instead of diffing two git refs, it enumerates source files on disk under PATH (a single file, or a directory recursively) and evaluates them as one body of work.

## Variables

PATH: first whitespace-separated token of $ARGUMENTS, or `.` if omitted
EXCLUDE_RE (extended-regex; drops test/build/vendor/lock/generated/binary paths — matches full repo-relative paths): `(^|/)(\.git|test|tests|spec|__tests__|dist|build|node_modules|vendor)/|(_test|\.test|\.spec)\.[^/]+$|(^|/)test_[^/]*\.[^/]+$|\.min\.(js|css)$|\.generated\.[^/]+$|\.pb\.go$|(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Gemfile\.lock|mix\.lock|Cargo\.lock|poetry\.lock|composer\.lock)$|\.(svg|png|jpe?g|gif|ico|pdf|lock|lockb)$`
MAX_SOURCES: 75

## Instructions

- Report findings in chat only. Do not write artifact files.
- The audit is **holistic**: evaluate all source files under PATH as a single body of work, including cross-file duplication.
- **Scope**: non-test source code only. Test design and structure is out of scope — see `/audit-tests`.
- **Enumerate, then filter.** List candidate files first (`git ls-files` when PATH is in a git work tree — respects `.gitignore` and includes untracked-but-not-ignored files; `find` otherwise), then drop excluded paths with `grep -Ev "$EXCLUDE_RE"`. Do NOT pass the exclusions as `git` `:(exclude)` pathspecs: combining an exclude pathspec with a *nested* positive path (one containing `/`) makes `git ls-files` return zero matches. Filtering the enumerated list avoids that quirk and behaves identically for files, top-level dirs, and nested dirs.
- STOP conditions (report message and halt without invoking the skill):
  - PATH does not exist on disk: `Path not found: <PATH>`.
  - No source files found under PATH after exclusions: `No source files found under <PATH>`.
  - More than `MAX_SOURCES` source files: `Too many source files (<N>) under <PATH>. Narrow the path to a subdirectory or specific files (~75 max for a useful holistic audit).`
- If `$ARGUMENTS` contains more than one whitespace-separated token, use the first and ignore the rest.

## Workflow

1. **Resolve `PATH`.** Take the first whitespace-separated token of `$ARGUMENTS`; if there are none, set `PATH=.`. Ignore any remaining tokens.

2. **Verify `PATH` exists** — `test -e "$PATH"`. On failure, STOP per Instructions (`Path not found: $PATH`).

3. **Detect git work tree** — `git -C "$(dirname "$PATH")" rev-parse --is-inside-work-tree 2>/dev/null`. If it prints `true`, enumerate with Option A in step 4; otherwise use Option B.

4. **Enumerate candidate files** under `PATH`, then filter with `EXCLUDE_RE`. Capture the result as `SOURCES`:
   - **Option A (git work tree).** Lists tracked plus untracked-but-not-ignored files at any path depth:
     ```bash
     git ls-files --cached --others --exclude-standard -- "$PATH" | grep -Ev "$EXCLUDE_RE"
     ```
   - **Option B (not in git).** Enumerate from disk; the same filter drops `.git/`, build/vendor dirs, test files, lockfiles, minified, generated, and binaries:
     ```bash
     find "$PATH" -type f | grep -Ev "$EXCLUDE_RE"
     ```

5. **Check for empty result.** If `SOURCES` is empty, STOP per Instructions (`No source files found under $PATH`).

6. **Apply the scale guardrail.** Count `SOURCES` as `N`. If `N` is greater than `MAX_SOURCES`, STOP per Instructions (`Too many source files ($N) under $PATH. Narrow the path to a subdirectory or specific files (~75 max for a useful holistic audit).`). Do NOT proceed with a partial audit.

7. **Invoke `refactoring-code`** via the Skill tool. Pass:
   - `PATH` and the full list of `SOURCES` (full paths)
   - Instruction to evaluate the entire set as a single body of work — surface code smells and refactoring opportunities holistically, including cross-file duplication
   - Instruction to **omit any smell category with no observations** rather than emit empty headers

8. **Render the Report below** using only the categories the skill returned findings for.

## Report

```
# Refactoring Audit

**Path**: <PATH>
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
