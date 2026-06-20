# Thinking Patterns for Dev Task Writing

Apply structured thinking patterns at each phase for better outcomes. The patterns referenced below (`atomic-thought`, `tree-of-thoughts`, etc.) are provided by the `thinking-patterns` skill, surfaced as the `/thinking` slash command. Phase names below match the phases in `../SKILL.md`.

## Phase 1: Discovery

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Coupling spans several modules | `atomic-thought` | Decompose the blast radius into independent facts per module/import |
| Multiple plausible motivations for the work | `tree-of-thoughts` | Explore which debt/risk/friction is the real driver |
| Tracing what's coupled to the touched code | `chain-of-thought` | Walk imports and call sites step by step |

## Phase 2: Drafting

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Multiple valid seams to cut along | `tree-of-thoughts` | Evaluate alternative scope boundaries before committing |
| Synthesizing context from ticket + code + ADR | `graph-of-thoughts` | Combine discovery findings into one coherent scope |
| Task seems too large to verify as one change | `skeleton-of-thought` | Outline split options before detailing |

## Phase 3: Definition of Done

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Identifying all done conditions | `skeleton-of-thought` | Outline the categories (safety, outcome, invariant, gates) first |
| Asserting that an invariant truly holds | `chain-of-thought` | Trace how each invariant is observably guarded |
| Checking every condition is verifiable | `chain-of-thought` | Walk each item and name the command/condition that confirms it |

## Phase 4: Review

| Situation | Pattern | Application |
|-----------|---------|-------------|
| High-risk or wide-blast-radius task | `self-consistency` | Multiple reasoning paths to validate the task is safe and complete |
| Hunting a smuggled behavior change | `chain-of-thought` | Apply the substitution test systematically |
| Checking identifier/path fidelity after polish | `atomic-thought` | Isolate each technical identifier and verify it survived verbatim |

## Quick Reference

- `atomic-thought` → Decomposing blast radius / verifying identifiers
- `tree-of-thoughts` → Multiple valid seams or motivations
- `skeleton-of-thought` → Outlining done conditions or split options
- `chain-of-thought` → Tracing coupling, invariants, the substitution test
- `graph-of-thoughts` → Synthesizing multi-source discovery context
- `self-consistency` → Final validation of a high-risk task

## When to Invoke

Use `/thinking` to auto-select or `/thinking <pattern>` for explicit selection.

Invoke patterns when:
- Discovery reveals coupling across many modules
- Multiple valid ways to scope or split the task exist
- A refactor's behavior-preservation needs careful checking
- High confidence in task safety and verifiability is needed
