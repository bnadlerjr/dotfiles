---
name: thinking-patterns
description: Provides structured reasoning patterns that produce visible, auditable output. Use when the user asks to "think through", "reason about", "work through", "show your thinking", or wants step-by-step reasoning. Also invoked with /thinking or /thinking <pattern>.
---

# Thinking Patterns

Structured reasoning that produces visible, auditable output. Use when complex reasoning benefits from explicit methodology rather than relying solely on extended thinking.

## Quick Start

```
/thinking                      # Auto-select based on context
/thinking chain-of-thought     # Explicit pattern
/thinking cot                  # Short alias
```

## Pattern Selection Guide

| Task Type | Pattern | Aliases | Key Trigger |
|-----------|---------|---------|-------------|
| Debugging/tracing | chain-of-thought | `cot`, `chain` | Step-by-step problem solving |
| Research/understanding | atomic-thought | `aot`, `atomic` | Combine facts from multiple areas |
| Comparing approaches | tree-of-thoughts | `tot`, `tree` | Multiple valid solutions exist |
| Planning/outlining | skeleton-of-thought | `sot`, `skeleton` | Need structure before details |
| Calculations | program-of-thoughts | `pot`, `program` | Generate code instead of computing |
| Verification | self-consistency | `sc`, `verify` | High stakes, need validation |
| Synthesizing | graph-of-thoughts | `got`, `graph` | Combining multiple inputs |

## What Are You Working On?

To select the right pattern, consider your task:

1. **Debugging or tracing logic?** → Chain of Thought
2. **Researching or gathering information?** → Atomic Thought
3. **Comparing multiple approaches?** → Tree of Thoughts
4. **Creating a plan or outline?** → Skeleton of Thought
5. **Doing calculations or data processing?** → Program of Thoughts
6. **Verifying an important conclusion?** → Self-Consistency
7. **Synthesizing findings from multiple sources?** → Graph of Thoughts

If unclear, describe your task and I'll recommend a pattern.

## Auto-Selection Logic

When invoked without a specific pattern:

1. **Keywords**: Match trigger words to patterns
2. **Task structure**: Sequential → CoT, Branching → ToT, Convergent → GoT
3. **Risk level**: High stakes → Self-Consistency verification
4. **Ask if unclear**: When multiple patterns apply, ask user preference

## Pattern Summaries

### Chain of Thought (CoT)
Linear reasoning with explicit intermediate steps. Use for debugging, math, causal analysis.
- Output: Numbered steps building on each other
- Invoke when: "walk through", "explain", "show your work"

### Atomic Thought (AoT)
Decomposes problems into independent sub-questions. Use for research and multi-hop queries.
- Output: Dependency graph → solve leaves → contract answers
- Invoke when: "understand", "research", "investigate"

### Tree of Thoughts (ToT)
Explores multiple reasoning paths with evaluation. Use for design decisions and brainstorming.
- Output: 2-4 approaches with trade-offs → recommendation
- Invoke when: "what are my options", "how should I approach"

### Skeleton of Thought (SoT)
Generates structure before content. Use for planning and documents.
- Output: Phase 1 skeleton → Phase 2 expansion
- Invoke when: "plan", "outline", "roadmap"

### Program of Thoughts (PoT)
Delegates computation to code execution. Use for calculations requiring precision.
- Output: Natural language explanation → executable code → results
- Invoke when: "calculate", "compute", "analyze data"

### Self-Consistency
Samples multiple reasoning paths and aggregates. Use for verification.
- Output: 3-5 independent paths → consensus check → confidence assessment
- Invoke when: "double-check", "verify", "make sure"

### Graph of Thoughts (GoT)
Models reasoning as graph with aggregation and refinement. Use for synthesis.
- Output: Extract insights → identify conflicts → resolve → unified synthesis
- Invoke when: "combine", "synthesize", "integrate"

## Workflow Integration

| Phase | Primary Pattern | Purpose |
|-------|-----------------|---------|
| Before planning | SoT or ToT | Structure or explore options |
| During research | AoT | Decompose and gather |
| When debugging | CoT | Systematic tracing |
| Before finalizing | Self-Consistency | Validate approach |
| After brainstorming | GoT | Synthesize findings |

## Composition Patterns

Patterns can be composed for complex tasks:

| Workflow Phase | Pattern Sequence |
|----------------|------------------|
| Research → Synthesis | AoT → GoT |
| Planning → Selection | SoT → ToT |
| Implementation → Verify | CoT/PoT → Self-Consistency |
| Brainstorm → Converge | ToT → GoT |

## Detailed Pattern Reference

For full pattern definitions including:
- Core mechanisms and processes
- Activation methods
- Examples and templates
- Anti-patterns to avoid

See [patterns.md](references/patterns.md).

## Success Criteria

A thinking pattern is successfully applied when:
- [ ] Appropriate pattern selected for the task type
- [ ] Visible structured output produced (not just internal reasoning)
- [ ] Each step/node explicitly shown and verifiable
- [ ] Final answer traces back to the reasoning
- [ ] User can audit and validate the reasoning process
