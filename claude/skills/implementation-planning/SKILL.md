---
name: implementation-planning
description: Create detailed implementation plans through interactive research. Use when in plan mode or when creating technical specifications.
---

# Implementation Planning

Create detailed implementation plans through an interactive, iterative process. Be skeptical, thorough, and collaborative.

## When This Skill Applies

- You're in plan mode (`permission_mode: plan`)
- User asks to create an implementation plan
- User references a ticket/task to plan

## Core Principles

1. **Interactive**: Never dump a complete plan. Gather context → verify understanding → align on approach → detail phases.
2. **Grounded**: Every claim verified against actual code. Include `file:line` references.
3. **Bounded**: Every plan MUST include "What We're NOT Doing" section.
4. **Testable**: Separate automated vs manual success criteria.

## Process

### Step 1: Context Gathering

1. **Read all mentioned files FULLY** (tickets, research, existing plans)
   - Use `$(claude-docs-path tickets)/` for tickets
   - Use `$(claude-docs-path research)/` for research docs
   - Use `$(claude-docs-path plans)/` for existing plans
   - **NEVER** read files partially

2. **Spawn research agents in parallel**:
   - **codebase-locator** → Find all relevant files
   - **codebase-analyzer** → Understand current implementation
   - **docs-locator** → Find existing documentation
   - **jira-cli-expert** → Get ticket details (if Jira mentioned)

3. **Present informed understanding**:
   ```
   Based on the ticket and my research, I understand we need to [summary].

   I've found:
   - [Current implementation detail with file:line]
   - [Relevant pattern or constraint]
   - [Potential complexity identified]

   Questions my research couldn't answer:
   - [Question requiring human judgment]
   ```

   Only ask questions you genuinely cannot answer through code investigation.

### Step 2: Research & Discovery

After clarifications:

1. **Verify corrections**: If user corrects you, spawn new research tasks. Don't just accept—verify.

2. **Track with TodoWrite**: Create a research checklist

3. **Present findings and options**:
   ```
   Based on my research:

   **Current State:**
   - [Key discovery with file reference]
   - [Pattern to follow]

   **Design Options:**
   1. [Option A] - [pros/cons]
   2. [Option B] - [pros/cons]

   **Open Questions:**
   - [Technical uncertainty]
   - [Design decision needed]

   Which approach aligns best?
   ```

### Step 3: Structure First

Before detailing, present outline:

```
Proposed plan structure:

## Overview
[1-2 sentences]

## Phases:
1. [Phase name] - [what it accomplishes]
2. [Phase name] - [what it accomplishes]

Does this phasing make sense?
```

Get feedback before proceeding.

### Step 4: Detailed Plan

When user approves structure, present the complete plan. Use the template in `templates/plan-template.md`.

**Important**: In plan mode, when you exit via ExitPlanMode, the plan will be automatically:
- Saved to `$(claude-docs-path plans)/`
- Given proper Obsidian frontmatter
- Named based on the H1 header

So ensure your plan has a clear H1 header like `# [Feature Name] Implementation Plan`.

## Guidelines

### Do
- Read files FULLY before planning
- Include file:line references for all claims
- Use custom agents for research (they work in plan mode)
- Verify claims against code
- Get buy-in at each step
- Separate automated vs manual verification

### Don't
- Write complete plans before alignment
- Accept corrections without verification
- Leave open questions in final plan
- Assume—verify with code

### No Open Questions Rule

If you encounter open questions during planning:
1. STOP
2. Research or ask for clarification immediately
3. Do NOT present a plan with unresolved questions
4. Every decision must be made before finalizing

## Agent Reference

Use these agents for research (all read-only, work in plan mode):

| Agent | Purpose |
|-------|---------|
| `codebase-locator` | Find relevant files |
| `codebase-analyzer` | Understand implementation details |
| `codebase-pattern-finder` | Find similar features to model after |
| `docs-locator` | Find existing documentation |
| `docs-analyzer` | Extract insights from documents |
| `jira-cli-expert` | Jira operations (search, create, transition, etc.) |

## Common Patterns

### Database Changes
1. Schema/migration
2. Store methods
3. Business logic
4. API endpoints
5. Client updates

### New Features
1. Research existing patterns
2. Data model
3. Backend logic
4. API layer
5. UI last

### Refactoring
1. Document current behavior
2. Incremental changes
3. Backwards compatibility
4. Migration strategy
