---
name: self-consistency
description: Generates multiple independent reasoning paths and selects the answer by majority vote or consensus. Use for verification, catching edge cases, high-stakes decisions, or any problem where multiple valid approaches exist. Triggers on "verify", "double-check", "are you sure", or when confidence in a single approach is insufficient.
---

# Self-Consistency

Samples multiple reasoning paths and aggregates for reliability.

## Core Mechanism

Instead of one reasoning chain, generate several independent chains and vote:
```
Problem → Chain A → Answer A
        → Chain B → Answer B
        → Chain C → Answer C
        → Majority vote → Final Answer
```

## Process

```
1. Generate multiple diverse reasoning paths (3-5 typically)
2. Ensure independence: each path should approach differently
3. Extract the answer from each path
4. Aggregate:
   - Majority vote for categorical answers
   - Consensus check for open-ended responses
   - Flag significant disagreements for review
```

## Key Principles

- **Independence**: Paths should not influence each other
- **Diversity**: Different approaches, not just different wordings
- **Aggregation**: The wisdom of crowds, but for reasoning
- **Discrepancy detection**: Disagreements surface edge cases or errors

## When to Apply

- High-stakes decisions where errors are costly
- Problems with multiple valid solution approaches
- Verification of important conclusions
- When single-path confidence is insufficient
- Edge case detection

## Implementation Patterns

### Simple Multi-Path
```
Solve this problem three different ways:

Approach 1 (algebraic):
[reasoning → answer]

Approach 2 (geometric/visual):
[reasoning → answer]

Approach 3 (estimation/sanity check):
[reasoning → answer]

Consensus check: Do all approaches agree? If not, identify the discrepancy.
```

### Implementation Verification
```
Generate two implementations:

Implementation A (optimize for clarity):
[code]

Implementation B (optimize for efficiency):
[code]

Verification:
- Do they produce the same output for test cases?
- If different, which is correct and why?
```

### Decision Verification
```
Evaluate this decision from three perspectives:

Perspective 1 (short-term impact):
[analysis → recommendation]

Perspective 2 (long-term impact):
[analysis → recommendation]

Perspective 3 (risk assessment):
[analysis → recommendation]

Synthesis: What does the consensus suggest?
```

## Handling Disagreements

When paths disagree:
1. Identify where the reasoning diverges
2. Check each path for errors at the divergence point
3. If both seem valid, the problem may be ambiguous
4. Report the disagreement and reasoning for each

## Anti-Patterns

- Paths that aren't actually independent (just rephrased)
- Ignoring disagreements (they're the valuable signal)
- Too many paths (diminishing returns after 5)
- Using for simple problems where one path suffices
