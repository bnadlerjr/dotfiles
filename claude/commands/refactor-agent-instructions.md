---
description: Refactor bloated agent instruction files into minimal root + categorized guidelines/ files
argument-hint: "[path to instruction file, or omit to auto-discover]"
---

# Refactor Agent Instructions

Refactor bloated agent instruction files (CLAUDE.md, AGENTS.md, COPILOT.md, .cursorrules, etc.) into a minimal root file linking to categorized files in `guidelines/`.

## Variables

- TARGET: $ARGUMENTS (optional — auto-discovers if omitted)

## Instructions

Invoke the `refactoring-agent-instructions` skill and follow its 5-phase workflow:

1. **Discover** agent instruction files in the project root (or use TARGET if provided)
2. **Analyze** for contradictions across files — resolve with user before proceeding
3. **Extract** essentials that stay in root vs. detailed content that moves to `guidelines/`
4. **Categorize** detailed content into 3-8 logical files
5. **Structure** — create `guidelines/` directory and write all files
6. **Prune** — flag redundant, vague, or obvious instructions for deletion

Present findings and get user confirmation at each phase boundary.

## Report

When complete, show:
- Before/after line counts
- Final file tree with line counts per file
- Summary of contradictions resolved
- Summary of instructions pruned
