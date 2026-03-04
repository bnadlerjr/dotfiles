# Documentation Principles from "A Philosophy of Software Design"

Key principles from John Ousterhout's book, adapted for practical documentation work.

## 1. Reduce Cognitive Load

Documentation should reduce the complexity a reader must manage, not add to it.

- Every comment, docstring, or doc section should make the reader's job easier
- If documentation restates what the code already says, it adds noise without reducing complexity
- Good documentation answers questions the reader would otherwise need to trace through code to answer

**Test**: After reading the doc, can the reader use the module/function without reading the implementation?

## 2. Interface vs. Implementation Documentation

Clearly separate what a thing does from how it does it.

### Interface Documentation (Essential)

Describes the abstraction — what callers need to know:
- What the function/module does (behavior)
- Parameters, return values, side effects
- Preconditions and postconditions
- Error conditions and how they surface
- Performance guarantees (if relevant)

### Implementation Documentation (Supplementary)

Describes internal mechanics — what maintainers need to know:
- Algorithm choice and why
- Data structure invariants
- Non-obvious control flow
- Performance trade-offs made

**Rule**: Interface docs are mandatory. Implementation docs are added only when the implementation is non-obvious.

## 3. Document Non-Obvious Things

Do not repeat the code. Document what the code cannot express:

- **Why**: The reasoning behind a design decision
- **Design decisions**: Why this approach over alternatives
- **Edge cases**: Behavior at boundaries that is not immediately obvious
- **Invariants**: Conditions that must always hold true
- **Constraints**: External requirements that shaped the implementation
- **Coupling**: Why this module depends on that one

**Anti-pattern**: `# increment counter` above `counter += 1`. This adds nothing.

**Good pattern**: `# Use insertion sort here because n < 10 in all real cases, and it's faster than quicksort for tiny arrays` above a sort call.

## 4. Documentation as Design Tool

Write documentation before or alongside code, not after:

- Writing interface docs first forces you to think about abstraction boundaries
- If you cannot describe what a function does in one sentence, the function may be doing too much
- The difficulty of writing docs reveals design problems early
- Updating docs as code changes keeps the design intentional

**Practice**: Write the module docstring and function signatures before writing the implementation.

## 5. Cross-Module Documentation

Document how modules interact, not just individual modules in isolation:

- Where does data flow between modules?
- What are the contracts between caller and callee?
- Which module owns which responsibility?
- What happens when module A calls module B — what assumptions does each make?

Cross-module docs often live in architecture documents, not in individual module headers.

## 6. Low-Level vs. High-Level Comments

Both serve different purposes. Use each appropriately.

### Low-Level Comments — Add Precision

- Units of measurement (`timeout` is in milliseconds, not seconds)
- Boundary conditions (inclusive vs. exclusive ranges)
- Null/nil semantics (does `nil` mean "not set" or "explicitly empty"?)
- Thread safety guarantees
- Ownership semantics (who frees this memory? who closes this connection?)

### High-Level Comments — Provide Intuition

- The mental model for how a subsystem works
- The overall algorithm strategy before the step-by-step code
- Why a class/module exists and what problem it solves
- How to think about the abstraction

## 7. No Implementation Leakage in Interface Docs

Interface documentation should describe WHAT, not HOW:

| Leaky (bad) | Clean (good) |
|------------|-------------|
| "Uses a hash map internally to store sessions" | "Stores sessions with O(1) lookup by session ID" |
| "Iterates through the list and filters" | "Returns items matching the predicate" |
| "Calls the Redis SETNX command" | "Acquires a distributed lock, returning true if successful" |

Implementation details in interface docs create false coupling — readers start depending on the internal mechanism instead of the abstraction.

## Applying These Principles

When writing any documentation, run through this checklist:

1. Does this reduce cognitive load, or add noise?
2. Am I documenting the interface or the implementation? Is that the right choice here?
3. Am I documenting something non-obvious, or restating the code?
4. Would writing this doc first have improved the design?
5. Have I documented cross-module interactions, not just this module in isolation?
6. Are my low-level comments precise? Are my high-level comments intuitive?
7. Do my interface docs leak implementation details?
