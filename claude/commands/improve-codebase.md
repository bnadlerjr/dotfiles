---
description: Audit all source files under a path for refactoring opportunities and code improvements
argument-hint: [path]
---

# Improve Codebase

Audit every source file under a filesystem PATH holistically against the `refactoring-code` skill — surface code smells, refactoring opportunities, and code improvements, ranked by impact and difficulty so the cheapest high-value work comes first.

## Variables

PATH: first whitespace-separated token of $ARGUMENTS, or `.` if omitted
EXCLUDE_RE (extended-regex; drops test/build/vendor/lock/generated/binary paths — matches full repo-relative paths): `(^|/)(\.git|test|tests|spec|__tests__|dist|build|node_modules|vendor)/|(_test|\.test|\.spec)\.[^/]+$|(^|/)test_[^/]*\.[^/]+$|\.min\.(js|css)$|\.generated\.[^/]+$|\.pb\.go$|(^|/)(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|Gemfile\.lock|mix\.lock|Cargo\.lock|poetry\.lock|composer\.lock)$|\.(svg|png|jpe?g|gif|ico|pdf|lock|lockb)$`
MAX_SOURCES: 75

## Instructions

- Report findings in chat only. Do not write artifact files.
- The audit is **holistic**: evaluate all source files under PATH as a single body of work, including cross-file duplication.
- **Scope**: non-test source code only. Test design and structure is out of scope — see `/audit-tests`.
- Every reported finding carries both an **Impact** and a **Difficulty** rating from `## Rating`. A finding you cannot rate is not reportable.
- **Enumerate, then filter.** List candidate files first, then drop excluded paths with `grep -Ev "$EXCLUDE_RE"`. Prefer `git ls-files` for its ignore semantics — it respects `.gitignore` and includes untracked-but-not-ignored files, so the audit skips the build and dependency directories the project already declares, and `EXCLUDE_RE` only has to cover what `find` would otherwise miss. Do NOT pass the exclusions as `git` `:(exclude)` pathspecs: combining an exclude pathspec with a *nested* positive path (one containing `/`) makes `git ls-files` return zero matches. Filtering the enumerated list avoids that quirk and behaves identically for files, top-level dirs, and nested dirs.
- STOP conditions (report message and halt without invoking the skill):
  - PATH does not exist on disk: `Path not found: <PATH>`.
  - No source files found under PATH after exclusions: `No source files found under <PATH>`.
  - More than `MAX_SOURCES` source files: `Too many source files (<N>) under <PATH>. Narrow the path to a subdirectory or specific files (~75 max for a useful holistic audit).`
- If `$ARGUMENTS` contains more than one whitespace-separated token, use the first and ignore the rest.

## Rating

Rate every finding on two independent axes.

**Impact** — how much the codebase improves:

- **High** — removes duplication at 3+ sites; untangles a module most other files depend on; eliminates a correctness or safety hazard (hidden side effect, swallowed error, illegal state left representable); unblocks work that is otherwise stuck.
- **Med** — clarifies one module's internals; removes duplication at 2 sites; shrinks a long function or large module that is edited regularly.
- **Low** — local readability, naming, dead code, or a smell in code that is rarely touched.

**Difficulty** — how hard it is to implement:

- **Low** — mechanical and behavior-preserving inside one file, covered by existing tests, no signature change (Extract Function, Rename, Inline).
- **Med** — spans 2–5 files, or changes an internal signature and its callers, or needs new tests written first.
- **High** — changes a public interface or data shape, ripples to callers outside `PATH`, has no test coverage, or cannot be done without a behavior change (Extract Class, module split, Replace Primitive with Object, process restructuring).

**Ordering rule** — score `= impact − difficulty`, scoring impact `High=3, Med=2, Low=1` and difficulty `Low=1, Med=2, High=3`. Sort by score descending, breaking ties by higher impact. That yields the cell order:

```
H/L → H/M → M/L → H/H → M/M → L/L → M/H → L/M → L/H
```

Within one cell, order by breadth descending — sites affected, then files affected.

## Workflow

1. **Resolve `PATH`.** Take the first whitespace-separated token of `$ARGUMENTS`; if there are none, set `PATH=.`. Ignore any remaining tokens.

2. **Verify `PATH` exists** — `test -e "$PATH"`. On failure, STOP per Instructions (`Path not found: $PATH`).

3. **Enumerate candidate files** under `PATH`, then filter with `EXCLUDE_RE`. Capture the result as `SOURCES`:
   ```bash
   SOURCES=$(git ls-files --cached --others --exclude-standard -- "$PATH" 2>/dev/null \
             || find "$PATH" -type f)
   SOURCES=$(printf '%s\n' "$SOURCES" | grep -Ev "$EXCLUDE_RE")
   ```
   Let `git` decide whether it can enumerate rather than testing for a work tree first. It exits 128 both outside a work tree and for a `PATH` in a repo other than the cwd's, which is exactly when `find` should take over; a `PATH` inside the repo that simply holds nothing exits 0 with no output, so the fallback never masks a genuinely empty result. Keep the two assignments separate — piping `git` straight into `grep` hands the pipeline `grep`'s exit status and swallows the 128, silently turning an unenumerable path into `No source files found`.

4. **Check for empty result.** If `SOURCES` is empty, STOP per Instructions (`No source files found under $PATH`).

5. **Apply the scale guardrail.** Count `SOURCES` as `N`. If `N` is greater than `MAX_SOURCES`, STOP per Instructions (`Too many source files ($N) under $PATH. Narrow the path to a subdirectory or specific files (~75 max for a useful holistic audit).`). Do NOT proceed with a partial audit.

6. **Invoke `refactoring-code`** via the Skill tool. Pass:
   - `PATH` and the full list of `SOURCES` (full paths)
   - Instruction to evaluate the entire set as a single body of work — surface code smells and refactoring opportunities holistically, including cross-file duplication
   - The `## Rating` rubrics, with the instruction to rate **every** finding on both axes and to return the evidence each rating rests on — sites affected and files affected

7. **Sort the findings** by the `## Rating` ordering rule. Do this explicitly: the skill returns findings grouped by file and severity, so without a sort pass the report inherits that order instead of the ranked one.

8. **Render the Report below.**

## Report

```
# Refactoring Audit

**Path**: <PATH>
**Sources audited**: <N> files

## Files
- <path/to/source.ext>
- ...

## Refactorings (ranked)

Ordered by the rule in Rating — highest impact at lowest difficulty first.

### 1. <imperative one-line action>
**Impact**: High · **Difficulty**: Low · <Smell category> · <N sites in M files>
- Evidence: <file:line refs, brief quote or description>
- Refactoring: <name from the catalog> — <one-line mechanic>

### 2. <imperative one-line action>
**Impact**: High · **Difficulty**: Med · <Smell category> · <N sites in M files>
- Evidence: ...
- Refactoring: ...
```
