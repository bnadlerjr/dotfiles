[YAML frontmatter per CLAUDE-PERSONAL.md "Artifact Management" schema]

# [Feature/Task Name] TDD Implementation Plan

## Overview

[Brief description of what we're implementing and why]

## Current State Analysis

[What exists now, what's missing, key constraints discovered]

### Key Discoveries
- [Finding with `file:line` reference]
- [Existing test pattern to follow]
- [Constraint to work within]

### Testing Infrastructure
- **Framework**: [e.g., ExUnit, Vitest, pytest]
- **Helpers**: [existing factories, fixtures, helpers with `file:line`]
- **Integration patterns**: [database sandbox, API mocking approach]
- **Run command**: [e.g., `mix test`, `npm test`, `pytest`]

## Design Inputs

[If design artifacts from /whiteboard exist, otherwise omit this section]

- **Source**: [path to design artifact]
- **Contracts extracted**: [summary of Level 4 contracts driving tests]
- **Interactions mapped**: [summary of Level 3 sequences driving integration tests]

## Desired End State

[Specification of the end state — what passes, what's observable, what's verified]

## What We're NOT Doing

- [Explicit out-of-scope item]
- [Another boundary]
- [Prevents scope creep]

## TDD Strategy

[What behavioral increments to test, in what order, and why that order.
Do NOT describe implementation — that emerges from the tests.]

## Phase Dependencies

[Optional — include only if phases have non-linear dependencies]

| Phase | Depends On | Blocks | TDD Cycles |
|-------|------------|--------|------------|
| Phase 1 | - | Phase 2, 3 | 3 |
| Phase 2 | Phase 1 | Phase 3 | 2 |

---

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes — the behavioral slice it delivers]

### TDD Cycles

#### Cycle 1: [Behavior Name]
- [ ] Complete

**RED — Write Failing Test**

```language
# Test to write FIRST — expected to fail
```

**Expected failure**: [What the failure message should look like]

**Structural context**: [Which modules/files are in play, where the test file lives, relevant contracts or interfaces with `file:line` refs. Do NOT include implementation or refactoring guidance.]

<!-- Cycle ends here. Do NOT add GREEN, REFACTOR, or implementation sections. -->

#### Cycle 2: [Behavior Name]
- [ ] Complete

**RED — Write Failing Test**

```language
# Test to write FIRST
```

**Expected failure**: [Failure description]

**Structural context**: [Modules/files in play with `file:line` refs]

<!-- Cycle ends here. Do NOT add GREEN, REFACTOR, or implementation sections. -->

### Automated Testing

All automated tests for this phase:

- [ ] Unit: [test description] — `path/to/test:line`
- [ ] Unit: [test description] — `path/to/test:line`
- [ ] Integration: [test description] — `path/to/test:line`

**Run**: `[exact command to run this phase's tests]`
**Expected**: [N tests, 0 failures]

### Done When

- [ ] All tests pass: `[run command]`
- [ ] [Behavior-based criterion, e.g., "User can create a new account"]
- [ ] [Another observable outcome]
- [ ] Type checking and linting pass

### Manual Verification

Before proceeding to next phase:
- [ ] [Specific thing to verify in UI/API/CLI]
- [ ] [Step-by-step scenario to walk through]
- [ ] [What to observe at each step]

---

## Phase 2: [Descriptive Name]

### Overview
[What this phase accomplishes]

### TDD Cycles

#### Cycle 1: [Behavior Name]
- [ ] Complete

**RED — Write Failing Test**

```language
# Test to write FIRST
```

**Expected failure**: [Failure description]

**Structural context**: [Modules/files in play with `file:line` refs]

<!-- Cycle ends here. Do NOT add GREEN, REFACTOR, or implementation sections. -->

### Automated Testing

- [ ] Unit: [test description] — `path/to/test:line`
- [ ] Integration: [test description] — `path/to/test:line`

**Run**: `[exact command to run this phase's tests]`
**Expected**: [N tests, 0 failures]

### Done When

- [ ] All tests pass: `[run command]`
- [ ] [Behavior-based criterion]
- [ ] Type checking and linting pass

### Manual Verification

Before proceeding to next phase:
- [ ] [Specific thing to verify]
- [ ] [Another manual check]

---

## Performance Considerations

[Any performance implications, including test suite performance]

## Migration Notes

[If applicable, how to handle existing data]

## References

- Story: `path/to/story.md`
- Design: `path/to/design.md`
- Research: `path/to/research.md`
- Test patterns: `file:line`
