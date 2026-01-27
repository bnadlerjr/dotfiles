---
name: tree-of-thoughts
description: "INVOKE when multiple approaches exist and exploration is valuable. Produces visible branching with evaluation and recommendation. Use before implementation when comparing options. Triggers: comparing approaches, exploring alternatives, brainstorming solutions, pros/cons analysis."
---

# Tree of Thoughts (ToT)

Explores multiple reasoning paths as a tree, evaluating candidates and backtracking from dead ends.

## MUST Invoke When

- Multiple valid implementation approaches exist
- User asks "what are my options" or "how should I approach this"
- Comparing alternatives or trade-offs
- Brainstorming where diverse options are valuable
- The first solution might not be optimal
- Design decisions with significant consequences

## Output Commitment

This skill produces **visible structured output**:
- 2-4 distinct approaches with reasoning
- Evaluation of each (feasibility, trade-offs, risks)
- Clear recommendation with justification

Do NOT pick the first approach—invoke this skill to explore alternatives visibly.

## Core Mechanism

At each reasoning step:
1. **Generate**: Produce multiple candidate thoughts/approaches
2. **Evaluate**: Assess each candidate (promising / uncertain / dead-end)
3. **Search**: Pursue promising paths, abandon dead ends, backtrack when stuck

## Process

```
1. Frame the problem and identify the decision space
2. Generate 2-4 distinct initial approaches
3. For each approach, evaluate:
   - Feasibility: Can this work given constraints?
   - Progress: Does this move toward the goal?
   - Reversibility: Can we recover if wrong?
4. Expand the most promising path(s)
5. If stuck, backtrack to last branch point and try alternative
6. Continue until solution or all paths exhausted
```

## Evaluation Heuristics

Rate each candidate thought:
- **Sure** (pursue): Clear progress, no obvious blockers
- **Maybe** (explore cautiously): Potential but uncertain
- **Impossible** (abandon): Violates constraints or leads nowhere

## When to Apply

- Problems where >60% of failures occur at the first step (puzzles, planning)
- Design decisions with multiple valid approaches
- Brainstorming where diverse options are valuable
- Tasks requiring strategic lookahead (games, negotiations)

## Three Experts Pattern

```
Imagine three experts with different perspectives approaching this problem:

Expert A (prioritizes simplicity): [approach + reasoning]
Expert B (prioritizes performance): [approach + reasoning]  
Expert C (prioritizes extensibility): [approach + reasoning]

Each expert evaluates their approach:
- What are the key trade-offs?
- What could go wrong?
- [If fatal flaw discovered, expert acknowledges and withdraws]

Synthesis: Which approach (or hybrid) best fits the constraints?
```

## Search Strategies

- **BFS**: When solution depth is unknown, explore breadth first
- **DFS**: When deep exploration is needed before switching paths
- **Best-first**: When evaluation function reliably ranks candidates

## Anti-Patterns

- Using for simple sequential problems (CoT is simpler)
- Generating too many branches (3-4 is usually optimal)
- Failing to actually backtrack when paths fail
- Shallow evaluation that doesn't catch fatal flaws early
