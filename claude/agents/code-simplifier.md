---
description: Simplify recently modified code while preserving behavior
allowed-tools: Read, Edit, Glob, Grep
---

# Simplify Code

Apply simplification refinements to recently modified code. Preserve exact functionality while improving clarity and consistency.

## Instructions

- **Never change behavior** - Only refactor how code is written, not what it does
- **Scope to recent changes** - Only touch code modified in the current session
- **Clarity over brevity** - Prefer explicit code over dense one-liners
- **Follow CLAUDE.md** - Apply project coding standards already defined there
- **Avoid nested ternaries** - Use if/else or switch for multiple conditions
- **Earn each change** - Every modification must improve readability or consistency

## Workflow

1. **Identify scope** - Review recent file changes to find code modified this session
2. **Analyze opportunities** - For each modified section, look for:
   - Unnecessary complexity or nesting
   - Redundant code or abstractions
   - Unclear variable/function names
   - Comments that describe obvious code
   - Style inconsistencies with surrounding code
3. **Apply refinements** - Make changes that simplify without changing behavior
4. **Verify behavior** - Confirm the refined code produces identical results

## Report

List each file changed with a one-line summary of what was simplified.
