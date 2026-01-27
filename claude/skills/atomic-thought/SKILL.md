---
name: atomic-thought
description: "INVOKE for research tasks and multi-source understanding. Produces visible dependency graphs and contracted answers. Use during research phase of workflow. Triggers: researching topics, gathering information before building, combining facts from multiple independent areas."
---

# Atomic Thought (AoT)

Decomposes problems into independent atomic units that can be reasoned about without historical context dependency.

## MUST Invoke When

- Researching a topic before implementation
- Combining facts from 2+ independent knowledge areas
- User asks to "understand", "research", "investigate", or "look into" something
- Gathering information to inform a decision
- Multi-hop queries requiring information from multiple sources

## Output Commitment

This skill produces **visible structured output**:
- Dependency graph of sub-questions
- Explicit answers to each atomic unit
- Contracted final answer with clear provenance

Do NOT use extended thinking alone—invoke this skill to show your decomposition.

## Core Mechanism

Apply a two-phase cycle until the problem is directly solvable:

1. **Decomposition**: Break the current question into a dependency graph of sub-questions
2. **Contraction**: Solve independent sub-questions, then contract answers into a simplified atomic question

## Process

```
1. Identify the question's component parts
2. Map dependencies: which sub-questions require answers from others?
3. Solve independent (leaf) sub-questions first—each answer must be self-contained
4. Contract: Reformulate the original question using obtained answers
5. Repeat until directly answerable
```

## Key Principles

- **Markov property**: Each atomic state contains everything needed to solve it
- **No context accumulation**: Solved sub-problems contract into the question, not into growing context
- **Independence first**: Prioritize sub-questions that don't depend on others

## When to Apply

- Multi-hop factual queries requiring information from multiple sources
- Research tasks with distinct knowledge areas
- Problems where irrelevant context degrades reasoning quality
- Tasks parallelizable across independent sub-problems

## Example Pattern

```
Original: "What is the GDP difference between the birthplace of the inventor of the telephone and the country where pizza originated?"

Decomposition:
├── Q1: Who invented the telephone? [independent]
├── Q2: Where was [Q1 answer] born? [depends on Q1]
├── Q3: Where did pizza originate? [independent]
├── Q4: What is GDP of [Q2 answer]? [depends on Q2]
└── Q5: What is GDP of [Q3 answer]? [depends on Q3]

Solve Q1, Q3 → Contract → Solve Q2, Q5 → Contract → Compute difference
```

## Anti-Patterns

- Using for simple single-hop questions (overhead not justified)
- Maintaining full reasoning history across atomic units
- Creating dependencies where none exist
