---
name: coding-workflow
description: Use when user asks to build a feature, implement something new, or make significant code changes. Recognizes requests like "build", "implement", "create a new feature", "add functionality", "develop", "I need to build X", "let's implement", "new feature request", "make these changes". Orchestrates a four-stage workflow (Research → Brainstorm → Plan → Implement) using the appropriate thought pattern skill at each stage.
---

# Coding Workflow

Four-stage development workflow with optimized thought patterns for each stage.

## Stage Overview

| Stage | Primary Pattern | Purpose |
|-------|----------------|---------|
| Research | atomic-thought | Gather facts without context pollution |
| Brainstorm | tree-of-thoughts / graph-of-thoughts | Explore or synthesize approaches |
| Plan | skeleton-of-thought → chain-of-thought | Structure then detail |
| Implement | program-of-thoughts + self-consistency | Separate reasoning from code; verify |

## Stage 1: Research

**Pattern**: `atomic-thought`

**Goal**: Gather information across independent knowledge areas without accumulated context interfering.

```
Apply atomic-thought:
- Decompose research topic into independent questions
- Answer each self-contained
- Contract into synthesized findings
```

**Transition signal**: "Research complete. Key findings: [summary]"

## Stage 2: Brainstorm

**Pattern**: `tree-of-thoughts` (divergent) or `graph-of-thoughts` (convergent)

**Goal**: Generate and evaluate solution approaches.

**Use tree-of-thoughts when**:
- Exploring multiple distinct approaches
- Need to evaluate and possibly backtrack
- "What are the alternatives?"

**Use graph-of-thoughts when**:
- Synthesizing research into approaches
- Combining insights from multiple sources
- Refining ideas iteratively

```
Apply tree-of-thoughts:
- Generate 3 distinct approaches (different perspectives)
- Evaluate each for feasibility
- Abandon approaches with fatal flaws
- Select or hybridize best approach

Apply graph-of-thoughts:
- Take research findings as input nodes
- Aggregate compatible insights
- Resolve conflicts
- Output synthesized approach
```

**Transition signal**: "Decided on [approach] because [rationale]"

## Stage 3: Plan

**Pattern**: `skeleton-of-thought` → `chain-of-thought`

**Goal**: Create actionable implementation plan.

```
Phase 1 - Apply skeleton-of-thought:
- Generate high-level structure only
- Major components and their order
- Dependencies between components
- Do NOT expand yet

Phase 2 - Apply chain-of-thought:
- Expand each skeleton item sequentially
- Specific tasks with acceptance criteria
- Process in dependency order
```

**Transition signal**: "Plan complete. Starting with [first component]"

## Stage 4: Implement

**Pattern**: `program-of-thoughts` + `self-consistency`

**Goal**: Generate correct, verified code.

```
Apply program-of-thoughts:
- Explain logic before writing code
- Generate executable code for calculations
- Separate reasoning from implementation

Apply self-consistency (for complex/critical code):
- Generate two implementations (clarity vs efficiency)
- Compare outputs
- Identify and resolve discrepancies
```

## Stage Transitions

### Research → Brainstorm
```
Research complete. Key findings:
- [Finding 1]
- [Finding 2]
- [Finding 3]

Now brainstorming approaches. [Apply tree-of-thoughts or graph-of-thoughts]
```

### Brainstorm → Plan
```
Selected approach: [approach]
Rationale: [why this approach]

Now creating implementation plan. [Apply skeleton-of-thought]
```

### Plan → Implement
```
Implementation plan:
[skeleton + expanded details]

Starting implementation. [Apply program-of-thoughts for first component]
```

## Quick Reference

**Research question**: Use `atomic-thought` to decompose and answer independently

**"What approach should we take?"**: Use `tree-of-thoughts` with three experts

**"Combine these findings"**: Use `graph-of-thoughts` to synthesize

**"Create a plan"**: Use `skeleton-of-thought` then expand with `chain-of-thought`

**"Implement this"**: Use `program-of-thoughts`; add `self-consistency` if critical

**"Verify this"**: Use `self-consistency` with multiple approaches
