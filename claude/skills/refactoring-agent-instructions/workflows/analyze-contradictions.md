# Phase 1: Analyze Contradictions

Scan all discovered agent instruction files for conflicting, contradictory, or incompatible instructions.

## Inputs

- List of discovered agent instruction files (from discovery step)
- Full content of each file

## Procedure

### 1. Build an Instruction Index

Read every discovered file and extract individual instructions. An "instruction" is any directive that tells the agent what to do, how to behave, or what to produce.

For each instruction, record:
- **Source file** and line range
- **Category** (style, testing, git, architecture, tooling, workflow, etc.)
- **Directive** (the specific behavior being requested)
- **Strength** (MUST, SHOULD, prefer, avoid, NEVER)

### 2. Cross-Reference for Conflicts

Compare instructions across files and within files. Look for these contradiction types:

| Type | Example |
|------|---------|
| **Direct contradiction** | File A: "Use tabs" / File B: "Use spaces" |
| **Incompatible workflows** | File A: "Always write tests first" / File B: "Prototype without tests" |
| **Conflicting tool preferences** | File A: "Use npm" / File B: "Use yarn" |
| **Style conflicts** | File A: "Use semicolons" / File B: "No semicolons" |
| **Scope overlap** | Two files defining the same behavior differently |
| **Strength mismatch** | File A: "MUST use X" / File B: "Prefer Y over X" |

### 3. Present Contradictions

For each contradiction found, present to the user:

```
### Contradiction #N: [Brief Description]

**File A** (`path/to/file:lines`):
> [Quoted instruction]

**File B** (`path/to/file:lines`):
> [Quoted instruction]

**Conflict type**: [Direct contradiction | Incompatible workflow | ...]

**Resolution options**:
1. Keep File A's version
2. Keep File B's version
3. Merge into: [suggested merged wording]
```

### 4. Record Resolutions

After the user resolves each contradiction, record the resolution for use in later phases:

```
Resolution #N: [Description]
- Winner: [which version to keep]
- Final wording: [exact instruction text to use]
- Applies to category: [category name]
```

## Outputs

- **Contradiction report**: All contradictions found with resolutions
- **Resolved instruction set**: The authoritative set of instructions with contradictions resolved
- **Clean signal**: Confirmation that all contradictions have been addressed

## Edge Cases

- **No contradictions found**: Report this and proceed to Phase 2
- **User defers resolution**: Mark as "unresolved" and flag for revisit in Phase 5
- **Same instruction appears in multiple files**: Not a contradiction — flag as duplication for Phase 5

## Transition

When all contradictions are resolved (or none found), proceed to Phase 2: Extract Essentials.
