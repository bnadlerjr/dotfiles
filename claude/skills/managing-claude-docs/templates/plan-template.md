# [Feature/Task Name] Implementation Plan

## Overview

[Brief description of what we're implementing and why]

## Current State Analysis

[What exists now, what's missing, key constraints discovered]

### Key Discoveries
- [Finding with `file:line` reference]
- [Pattern to follow]
- [Constraint to work within]

## Desired End State

[Specification of the end state and how to verify it]

## What We're NOT Doing

- [Explicit out-of-scope item]
- [Another boundary]
- [Prevents scope creep]

## Implementation Approach

[High-level strategy and reasoning]

## Phase Dependencies

[Optional - include only if phases have non-linear dependencies]

| Phase | Depends On | Blocks |
|-------|------------|--------|
| Phase 2 | Phase 1 | Phase 3 |
| Phase 3 | Phase 1, Phase 2 | - |

---

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Changes Required

#### [Component/File Group]
**File**: `path/to/file.ext`

**Changes**: [Summary]

```language
// Specific code to add/modify
```

### Done When

- [ ] [Behavior-based criterion, e.g., "User can create a new account"]
- [ ] [Another observable outcome]
- [ ] Type checking and linting pass

### Manual Verification

Before proceeding to next phase:
- [ ] [Specific thing to verify in UI/API/CLI]
- [ ] [Another manual check]

**Note**: Implementation follows TDD—automated tests are written as part of each change, not as a separate step. Manual verification ensures the feature works end-to-end before proceeding.

---

## Phase 2: [Descriptive Name]

### Overview
[What this phase accomplishes]

### Changes Required

#### [Component/File Group]
**File**: `path/to/file.ext`

**Changes**: [Summary]

```language
// Specific code to add/modify
```

### Done When

- [ ] [Behavior-based criterion]
- [ ] [Another observable outcome]
- [ ] Type checking and linting pass

### Manual Verification

Before proceeding to next phase:
- [ ] [Specific thing to verify]
- [ ] [Another manual check]

---

## Performance Considerations

[Any performance implications]

## Migration Notes

[If applicable, how to handle existing data]

## References

- Ticket: `path/to/ticket.md`
- Research: `path/to/research.md`
- Similar: `file:line`
