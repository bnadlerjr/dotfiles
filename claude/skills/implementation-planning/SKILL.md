---
name: implementation-planning
description: Create detailed implementation plans through interactive research and iteration. Use when in plan mode, planning features, designing implementations, breaking down tasks into phases, or when the user asks "how should I implement X", "plan this feature", or wants a technical specification.
---

# Implementation Planning

Create detailed implementation plans through an interactive, iterative process. Be skeptical, thorough, and collaborative.

## Quick Start

1. User provides context (ticket, feature request, or task)
2. Claude researches with agents, presents understanding with `file:line` references
3. User clarifies/corrects → Claude verifies corrections
4. Claude presents structure outline → user approves
5. Claude details each phase → exits with ExitPlanMode

## When This Skill Applies

- You're in plan mode (`permission_mode: plan`)
- User asks to create an implementation plan
- User references a ticket/task to plan

## Core Principles

1. **Interactive**: Never dump a complete plan. Gather context → verify understanding → align on approach → detail phases.
2. **Grounded**: Every claim verified against actual code. Include `file:line` references.
3. **Bounded**: Every plan MUST include "What We're NOT Doing" section.
4. **TDD-First**: Plans describe *what* to build, not *how to test*. Automated testing is implicit—every implementation follows TDD (write failing test → implement → refactor). Never include explicit "testing phases" or "write tests" steps.
5. **Manual Verification**: Each phase ends with manual verification to ensure we're on track. This is separate from TDD—it validates the feature works as expected before proceeding.

## Process

### Step 1: Context Gathering

1. **Read all mentioned files FULLY** (tickets, research, existing plans)
   - Use `$(claude-docs-path tickets)/` for tickets
   - Use `$(claude-docs-path research)/` for research docs
   - Use `$(claude-docs-path plans)/` for existing plans
   - **NEVER** read files partially

2. **Spawn research agents in parallel**:
   - **serena-codebase-locator** → Find all relevant files
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

When user approves structure, present the complete plan. Use the template in [templates/plan-template.md](templates/plan-template.md).

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
- Assume TDD for automated tests—don't add explicit "write tests" steps
- Include manual verification checkpoints at phase boundaries

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
| `serena-codebase-locator` | Find relevant files |
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

## Examples

**Example 1: User references a ticket**

Input: "Plan the implementation for PROJ-123"

Expected behavior:
1. Read ticket from `$(claude-docs-path tickets)/`
2. Spawn `serena-codebase-locator` + `codebase-analyzer` agents in parallel
3. Present findings:
   ```
   Based on PROJ-123, I understand we need to add rate limiting to the API.

   I've found:
   - Current API handlers at `src/api/handlers.py:45-120`
   - No existing rate limiting middleware
   - Redis already configured at `src/config/redis.py:12`

   Questions my research couldn't answer:
   - Should rate limits be per-user or per-API-key?
   ```
4. After clarification, present structure outline
5. Detail phases after user approves structure

**Example 2: User asks to plan a feature**

Input: "I need to add user authentication to this app"

Expected behavior:
1. Research existing auth patterns in codebase
2. Present understanding:
   ```
   I found no existing authentication. The app uses Express.js (`package.json:8`).

   Design Options:
   1. JWT tokens - Stateless, scales well, requires refresh token handling
   2. Session cookies - Simpler, requires session store (Redis available)

   Questions:
   - OAuth integration needed, or just email/password?
   ```
3. After clarification, present structure outline
4. Detail phases after approval

**Example 3: Planning from research document**

Input: "Plan implementation based on the auth research doc"

Expected behavior:
1. Read research doc FULLY from `$(claude-docs-path research)/`
2. Extract key decisions already made
3. Present understanding without re-asking resolved questions
4. Proceed to structure outline faster (context already gathered)

## Common Mistakes

Avoid these pitfalls:

| Mistake | Why It's Wrong | Do This Instead |
|---------|----------------|-----------------|
| Dumping a complete plan immediately | User can't course-correct early | Present understanding first, get buy-in at each step |
| Accepting user corrections blindly | User may be wrong or outdated | Verify corrections against code before proceeding |
| Leaving "TBD" or "TODO" in final plan | Plan should be actionable | Resolve all questions before finalizing |
| Missing `file:line` references | Claims become unverifiable | Every code reference needs a location |
| Skipping "What We're NOT Doing" | Scope creep inevitable | Always define boundaries explicitly |
| Adding explicit "testing" phases | TDD is implicit in all implementation | Describe what to build; tests come with implementation |
