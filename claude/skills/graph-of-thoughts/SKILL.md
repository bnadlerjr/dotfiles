---
name: graph-of-thoughts
description: "INVOKE after research or brainstorming to synthesize findings. Produces visible aggregation with conflict resolution. Use when multiple inputs need combining into coherent output. Triggers: synthesizing research, combining ideas, merging approaches, integrating findings."
---

# Graph of Thoughts (GoT)

Models reasoning as an arbitrary graph with aggregation, refinement, and feedback operations.

## MUST Invoke When

- Synthesizing research from multiple sources
- Combining brainstormed ideas into a coherent plan
- User asks to "combine", "synthesize", or "integrate" findings
- Merging partial solutions from different approaches
- After divergent exploration (ToT) when convergence is needed
- Multiple inputs need to become one coherent output

## Output Commitment

This skill produces **visible structured output**:
- Extracted insights from each source
- Identified agreements and conflicts
- Resolution of conflicts with reasoning
- Unified synthesis with provenance

Do NOT just pick one input—invoke this skill to show synthesis process.

## Core Mechanism

Unlike trees (divergent) or chains (linear), graphs support:
- **Aggregation**: Combining multiple thoughts into one
- **Refinement**: Iteratively improving a thought
- **Splitting**: Breaking a thought into components for parallel processing
- **Loops**: Feedback cycles for iterative improvement

## Process

```
1. Identify input thoughts/sources to synthesize
2. For each input, extract key insights and constraints
3. Identify conflicts or tensions between inputs
4. Aggregate compatible insights into unified positions
5. Resolve conflicts through:
   - Prioritization (which source is more authoritative?)
   - Synthesis (can both be true in different contexts?)
   - Refinement (iterate until coherent)
6. Output synthesized result with clear provenance
```

## Operations

### Aggregate
Combine multiple reasoning chains into a single coherent output:
```
Chain A conclusion: X
Chain B conclusion: Y  
Chain C conclusion: Z
→ Aggregated insight: [unified position incorporating X, Y, Z]
```

### Refine
Iteratively improve a thought through feedback:
```
Draft 1 → Critique → Draft 2 → Critique → Final
```

### Split-then-Aggregate
Parallelize then recombine:
```
Complex problem → Split into A, B, C → Solve each → Aggregate solutions
```

## When to Apply

- Synthesizing research from multiple sources
- Combining brainstormed ideas into a coherent plan
- Merging partial solutions from different approaches
- Iterative refinement through self-critique
- Any task where insights must converge rather than diverge

## Synthesis Pattern

```
I have these inputs to synthesize:
- Source 1: [insight]
- Source 2: [insight]
- Source 3: [insight]

Step 1 - Extract: What is the core claim/finding from each?
Step 2 - Align: Where do they agree?
Step 3 - Conflict: Where do they disagree? Why?
Step 4 - Resolve: For each conflict, determine resolution
Step 5 - Integrate: Produce unified output with:
   - Synthesized position
   - Confidence level
   - Remaining uncertainties
```

## Anti-Patterns

- Using when inputs don't need integration (just present separately)
- Forcing false synthesis when sources genuinely conflict
- Losing provenance (which insight came from where)
- Aggregating without resolving contradictions
