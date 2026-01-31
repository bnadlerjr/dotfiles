# Thinking Patterns for Story Writing

Apply structured thinking patterns at each phase for better outcomes.

## Phase 1: Discovery

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Requirements span multiple domains | `atomic-thought` | Decompose into independent facts from each area |
| Multiple stakeholder perspectives | `atomic-thought` | Understand each viewpoint separately |
| Unclear which need is primary | `tree-of-thoughts` | Explore different framings of the problem |

## Phase 2: Drafting

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Multiple valid story framings | `tree-of-thoughts` | Evaluate alternatives before committing |
| Synthesizing from multiple sources | `graph-of-thoughts` | Combine discovery findings coherently |
| Story seems too large | `skeleton-of-thought` | Outline split options before detailing |

## Phase 3: Acceptance Criteria

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Identifying all scenarios | `skeleton-of-thought` | Outline scenario types first, then detail |
| Complex business logic | `chain-of-thought` | Trace each path step-by-step |
| Verifying completeness | `chain-of-thought` | Walk through each scenario systematically |

## Phase 4: Review

| Situation | Pattern | Application |
|-----------|---------|-------------|
| High-stakes or complex story | `self-consistency` | Multiple reasoning paths to validate |
| Verifying scenario coverage | `chain-of-thought` | Systematic walkthrough |
| Checking language consistency | `atomic-thought` | Isolate each term and verify usage |

## Quick Reference

- `atomic-thought` → Complex multi-domain requirements
- `tree-of-thoughts` → Multiple valid framings
- `skeleton-of-thought` → Outlining scenarios
- `chain-of-thought` → Tracing business logic
- `graph-of-thoughts` → Synthesizing discovery findings
- `self-consistency` → Final validation

## When to Invoke

Use `/thinking` to auto-select or `/thinking <pattern>` for explicit selection.

Invoke patterns when:
- Discovery reveals complex, multi-stakeholder needs
- Multiple valid ways to frame the story exist
- Business logic has many branches
- High confidence in story quality is needed
