---
name: chain-of-thought
description: Sequential step-by-step reasoning where each step builds on the previous. Use for mathematical problems, logical deductions, debugging, or any task with a clear single-path solution. Triggers on "step by step", "walk through", "show your work", or multi-step problems requiring explicit reasoning traces.
---

# Chain of Thought (CoT)

Linear reasoning that makes intermediate steps explicit.

## Core Mechanism

Instead of jumping to an answer, generate a sequence of reasoning steps:
```
Problem → Step 1 → Step 2 → Step 3 → ... → Answer
```

Each step:
- Builds explicitly on previous steps
- Is independently verifiable
- Creates an audit trail for debugging

## Activation Methods

**Zero-shot**: Append trigger phrase
```
[Problem statement]
Let's work through this step by step.
```

**Few-shot**: Provide worked examples
```
Example 1: [problem] → [step 1] → [step 2] → [answer]
Example 2: [problem] → [step 1] → [step 2] → [answer]
Now solve: [new problem]
```

## Process

```
1. Restate the problem in own words
2. Identify what is given and what is asked
3. Break into sequential sub-steps
4. Execute each step, showing work
5. Verify the final answer against the original question
```

## Key Principles

- **Explicitness**: Every reasoning step is visible
- **Forward-only**: Once committed, cannot revise earlier steps
- **Context accumulation**: Full chain remains in context
- **Transparency**: Reasoning is traceable and debuggable

## When to Apply

- Mathematical calculations
- Logical deductions
- Code debugging (trace execution)
- Causal reasoning
- Any problem with clear sequential dependencies
- When interpretability/auditability matters

## Enhanced Variants

**Structured CoT**: Force specific step format
```
Given: [extract knowns]
Find: [state goal]
Step 1: [first operation]
Step 2: [second operation]
...
Therefore: [conclusion]
```

**Verification CoT**: Add self-check
```
[Normal CoT steps]
Verification: Does this answer satisfy the original constraints?
```

## Anti-Patterns

- Using for problems requiring exploration (use ToT instead)
- Very long chains without intermediate verification (errors propagate)
- Skipping steps that seem "obvious" (defeats transparency goal)
- Using when decomposition would be cleaner (use AoT for multi-hop)
