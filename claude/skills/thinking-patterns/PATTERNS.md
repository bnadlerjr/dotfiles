# Thinking Pattern Quick Reference

Quick selection guide for `/thinking` patterns.

## Selection Guide

| Task Type | Pattern | Key Trigger |
|-----------|---------|-------------|
| Research/understanding | `atomic-thought` | Need to combine facts from multiple areas |
| Debugging/tracing logic | `chain-of-thought` | Step-by-step problem solving |
| Calculations/data processing | `program-of-thoughts` | Generate code instead of computing mentally |
| Planning/outlining | `skeleton-of-thought` | Need high-level structure before details |
| Comparing approaches | `tree-of-thoughts` | Multiple valid solutions exist |
| High-stakes decisions | `self-consistency` | Errors would be costly, need validation |
| Synthesizing findings | `graph-of-thoughts` | Combining multiple inputs/research |

## Pattern Summaries

### Chain of Thought (CoT)
**Use**: Sequential reasoning with explicit steps
**Aliases**: `cot`, `chain`
**Avoid**: When exploration needed (use ToT) or multi-hop (use AoT)

### Atomic Thought (AoT)
**Use**: Research tasks decomposed into independent sub-questions
**Aliases**: `aot`, `atomic`
**Avoid**: Simple single-hop questions

### Tree of Thoughts (ToT)
**Use**: Exploring 2-4 approaches with evaluation and backtracking
**Aliases**: `tot`, `tree`
**Avoid**: Simple sequential problems (use CoT)

### Skeleton of Thought (SoT)
**Use**: Outline-first then expand for plans and documents
**Aliases**: `sot`, `skeleton`
**Avoid**: When full content is needed immediately

### Program of Thoughts (PoT)
**Use**: Any calculation with >2 operations or precision needed
**Aliases**: `pot`, `program`
**Avoid**: Simple arithmetic (overhead not justified)

### Self-Consistency
**Use**: Verifying important conclusions via multiple paths
**Aliases**: `sc`, `verify`
**Avoid**: Simple problems where one path suffices

### Graph of Thoughts (GoT)
**Use**: Synthesizing multiple sources into coherent output
**Aliases**: `got`, `graph`
**Avoid**: When inputs don't actually need integration

## Invocation Examples

```
/thinking                      # Auto-select based on context
/thinking chain-of-thought     # Explicit pattern
/thinking cot                  # Short alias
/thinking verify               # Self-consistency alias
```

## Composition Patterns

| Workflow Phase | Pattern Sequence |
|----------------|------------------|
| Research → Synthesis | AoT → GoT |
| Planning → Selection | SoT → ToT |
| Implementation → Verify | CoT/PoT → Self-Consistency |
| Brainstorm → Converge | ToT → GoT |
