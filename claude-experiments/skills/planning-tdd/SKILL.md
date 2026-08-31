---
name: planning-tdd
description: Creates TDD implementation plans where tests ARE the plan. Specifies test specs and structural context per phase — implementation emerges during execution, not planning. Verification is fully automated; no manual verification step. Use when planning features test-first, creating TDD plans from design artifacts, or when the user asks for a test-driven implementation plan. NOT for executing a plan test-first (the Red-Green-Refactor cycle during implementation) — that is practicing-tdd.
allowed-tools: Read, Glob, Grep, Agent
---

# TDD Planning

Create test-driven implementation plans where every phase is organized
around TDD cycles with both automated and manual testing.

The skills listed under [Related Skills](#related-skills) enhance planning but
are soft dependencies — this skill functions without them using standard
reasoning and TDD principles.

## Quick Start

Given a task, design artifact, or ticket:

1. **Read** all referenced documents FULLY
2. **Research** by spawning `codebase-navigator` + `codebase-analyzer` + `codebase-pattern-finder` in parallel
3. **Discover** the testing stack (framework, helpers, patterns)
4. **Present** understanding with `file:line` references, ask only unanswerable questions
5. **Decompose** into testable behavioral increments (TDD cycles)
6. **Outline** the phase structure, get approval
7. **Detail** each phase with TDD cycles and automated tests

## When This Skill Applies

- User asks to plan a feature using TDD
- User references a design artifact (e.g., from `collaborating-on-design`) for implementation planning
- User wants explicit test specifications in their implementation plan
- User mentions "test-first plan", "TDD plan", or "plan with tests"

## Core Principles

1. **Tests ARE the Plan**: The plan specifies what to test, not how to implement. Implementation emerges from tests during execution. Including implementation code in the plan presupposes design and defeats the purpose of TDD.
2. **Structural Context, Not Solutions**: The plan identifies which modules, files, and contracts are in play — enough to know *where* to work, not *what* to write.
3. **Just-In-Time Detail**: Exact test code is design — it pins module names, signatures, and data shapes that go stale before execution reaches them: earlier phases legitimately reshape contracts, and concurrent work ships changes planning never saw. Every phase gets behavioral cycles (Given/When/Then, assertion focus, expected failure category); exact RED test code is written at execution time, phase by phase, against the codebase state that actually exists when each phase starts.
4. **Interactive**: Never dump a complete plan. Gather context -> verify understanding -> align on approach -> detail phases.
5. **Grounded**: Every claim verified against actual code. Include `file:line` references.
6. **Bounded**: Every plan MUST include "What We're NOT Doing" section.
7. **Automated Verification**: Every phase is verified by automated tests. No manual-verification step exists in the plan or the implementation flow. Behavior that cannot be asserted by an automated test must be called out explicitly in the plan and escalated — not deferred to a manual check.
8. **Incremental Confidence**: Each TDD cycle builds on the confidence established by previous passing tests.

## Process

### Step 1: Context Gathering

1. Decompose the task into key questions (apply `/thinking atomic-thought`
   if thinking-patterns is available): What is the goal? What exists today?
   What changes? What constraints apply? What design artifacts exist?

2. **Read all mentioned files FULLY** (stories, designs, tickets, specs)
   - **NEVER** read files partially

3. **Extract design contracts** if a design artifact exists (e.g., from `collaborating-on-design`):
   - Level 1 (Capabilities): Scope boundaries -> what NOT to test
   - Level 3 (Interactions): Sequence diagrams -> integration test scenarios
   - Level 4 (Contracts): Function signatures, typespecs -> unit test targets

4. **Spawn research agents in parallel** (if available):
   - **codebase-navigator** -> Find all relevant files
   - **codebase-analyzer** -> Understand current implementation
   - **codebase-pattern-finder** -> Find existing test patterns to model after
   - **docs-locator** -> Find existing documentation
   - If agents are unavailable, use Glob/Grep/Read directly.

5. **Discover testing infrastructure**:
   - Test framework and runner (ExUnit, Vitest, pytest, etc.)
   - Test helpers, factories, fixtures with `file:line` references
   - Integration test patterns (database sandboxing, API mocking)
   - Coverage tools and configuration
   - How to run tests (command, flags, configuration)

6. **Present informed understanding**:
   ```
   Based on the requirements and my research:

   **Goal**: [summary]

   **Design contracts driving tests**:
   - [Contract from design artifact -> test target]

   **Testing infrastructure**:
   - Framework: [name] at [file:line]
   - Helpers: [list with file:line]
   - Run: [command]

   **Current state**:
   - [Implementation detail with file:line]

   Questions my research couldn't answer:
   - [Question requiring human judgment]
   ```

### Step 2: Research & Discovery

After clarifications:

1. **Verify corrections**: If user corrects you, spawn new research tasks. Don't just accept -- verify.

2. **Evaluate testability of approaches**: If multiple valid approaches exist,
   compare them (apply `/thinking tree-of-thoughts` if available) on:
   - How easily can each approach be tested?
   - Does it require complex mocking or can tests use real dependencies?
   - How many integration seams exist?

3. **Present findings and options**:
   ```
   **Design Options** (ranked by testability):
   1. [Option A] - [testability: high/medium/low, pros/cons]
   2. [Option B] - [testability: high/medium/low, pros/cons]

   **Test approach**: [unit-heavy, integration-heavy, or balanced]

   Which approach aligns best?
   ```

### Step 3: Decompose into TDD Cycles

This is the key differentiator from standard implementation planning.

1. Break the work into testable behavioral increments (apply
   `/thinking skeleton-of-thought` if available).

2. **Identify testable behaviors**: Each behavior becomes one TDD cycle. A behavior is testable when:
   - It has a clear input and observable output
   - It can fail independently
   - It can be verified with a single assertion focus

3. **Order by dependency**: Foundation first, composition later
   - Data structures and types
   - Core business logic
   - Integration points
   - Composition and orchestration
   - Edge cases and error handling

4. **Group into phases**: Related cycles that deliver a coherent slice
   ```
   Proposed phases:

   **Phase 1: [Name]** (3 TDD cycles)
   - Cycle 1: [behavior] -> [test target]
   - Cycle 2: [behavior] -> [test target]
   - Cycle 3: [behavior] -> [test target]

   **Phase 2: [Name]** (2 TDD cycles)
   - Cycle 1: [behavior] -> [test target]
   - Cycle 2: [behavior] -> [test target]

   Does this phasing make sense?
   ```

5. **Get approval** before detailing.

### Cycle Output Format

Cycles take one of two forms depending on lifecycle stage (Core Principle 3). At planning time, every cycle in every phase is behavioral. The detailed form is produced during execution, when `/implement` details each phase just-in-time against the codebase state that actually exists.

**Behavioral cycle (planning-time form — all phases)** — exactly 4 parts, no code:

1. **Behavior** — Given/When/Then at the behavior level
2. **Assertion focus** — the single thing the test asserts
3. **Expected failure category** — e.g., "function undefined", "assertion mismatch", "constraint missing"
4. **Structural context** — module-level references; `file:line` only where the reference is stable across phases

**Detailed cycle (execution-time form — produced when a phase is detailed)** — exactly 3 parts:

1. **RED test spec** — A code block with the exact test to write first
2. **Expected failure** — What the failure message looks like when run
3. **Structural context** — `file:line` references for modules/files in play

The behavioral cycle is the contract: its intent and assertion focus must survive detailing unchanged. Shape — names, signatures, setup, file paths — is resolved at execution time by whoever details the phase.

Each cycle (either form) MUST NOT contain:
- **GREEN** sections or implementation code
- **REFACTOR** sections or "None needed" commentary
- Code that is not a test
- At planning time: any test code at all

GREEN and REFACTOR emerge during execution via `practicing-tdd` and `refactoring-code` skills. They do not belong in a plan.

### Step 4: Detailed Plan

When user approves structure, write the complete plan using the template
at [templates/plan-template.md](templates/plan-template.md).

The skill's deliverable is the rendered plan; persistence is the caller's
responsibility. If a calling command specifies a save path or frontmatter
schema, follow that guidance after rendering.

For each phase, detail:

1. **TDD Cycles** (the heart of the plan): behavioral cycles per the
   Cycle Output Format — Behavior, Assertion focus, Expected failure
   category, Structural context. No test code blocks anywhere in the
   plan. The implementation workflow (`/implement`) details each phase
   into exact RED test specs just-in-time as execution reaches it.

2. **Automated Testing** (summary for the phase):
   - All unit tests with descriptions
   - Integration tests with scenarios
   - The exact command to run them — test file paths marked as
     resolved at detailing time
   - Expected pass/fail count

After writing the plan, validate it (apply `/thinking self-consistency` if
thinking-patterns is available, otherwise reason through it directly):
- Does every phase start with failing tests?
- Does every phase have clear "done when" criteria?
- Is automated testing covered in every phase with an exact run command?
- Are dependencies between phases correct?
- Is scope properly bounded?
- Does every cycle conform to the [Cycle Output Format](#cycle-output-format) (Behavior + Assertion focus + Expected failure category; no GREEN/REFACTOR sections, no code that isn't a test, no test code at planning time) and the [Test Cycle Validity](#test-cycle-validity) rule? -> Fix any cycle that doesn't

## Guidelines

### Do
- Start every phase with tests, never with implementation
- Derive test specs from design contracts when available
- Include `file:line` references for all claims
- Use custom agents for research
- Verify claims against code
- Get buy-in at each step
- Match existing test patterns in the codebase
- Specify exact test run commands per phase

### Don't
- Write complete plans before alignment
- Accept corrections without verification
- Leave open questions in final plan
- Write tests that test mock behavior (see `practicing-tdd` anti-patterns)
- Include implementation code in the plan — it presupposes design and defeats TDD
- Propose test patterns that conflict with existing codebase conventions

### Test Cycle Validity

A test cycle must define **a transformation under test**: an input that goes through a function which branches, computes, queries, or transforms before producing the asserted output. If the RED-phase test would pass by writing a literal into the source — with no transformation between the literal and the assertion — the cycle is mis-specified.

**Before adding a cycle to the plan, answer:** *What production defect would this test catch that would not also be caught by an integration test of the consumer?*

If the only answer is "the static catalog has the wrong shape," replace the cycle with:

- A higher-level cycle that tests the consumer's behavior over the catalog (the runtime evaluator, the renderer, the GraphQL resolver — whatever actually transforms the data).
- No cycle at all, **only when** a higher-level test already pins the relevant behavior. Record that test's `file:line` in the plan as the source of coverage. The static data is documented by the source itself and the type checker pins its shape, but the wiring is not free coverage — it needs a named test.

This is the one carve-out from Core Principle 6: tautological cycles may be removed silently. Every other coverage gap — including "no downstream test pins this yet" — must be escalated, not dropped.

**"Pinning the registered shape of a static catalog" is not a TDD cycle. It is a tautology with `test` as a keyword.**

### No Open Questions Rule

If you encounter open questions during planning:
1. STOP
2. Research or ask for clarification immediately
3. Do NOT present a plan with unresolved questions
4. Every decision must be made before finalizing

### Handling Edge Cases

- **No existing test patterns found**: Document this explicitly; propose a test structure with justification
- **Design artifact missing**: Plan can proceed without it, but note that test specs will be derived from requirements rather than contracts
- **Complex external dependencies**: Propose integration test strategy (sandbox, fake, contract test) -- get alignment before including in plan
- **Conflicting information**: Escalate to user with specific details about what conflicts
- **User corrections conflict with code**: Present the discrepancy -- don't silently accept either
- **Scope ambiguity**: Default to smaller scope; list what's deferred in "What We're NOT Doing"

## Deriving Tests from Design Artifacts

When a design artifact is available (e.g., from `collaborating-on-design`), use this mapping:

| Design Level | Test Type | What to Extract |
|---|---|---|
| Level 1: Capabilities | Scope boundaries | What NOT to test (out of scope) |
| Level 2: Components | Module structure | Test file organization |
| Level 3: Interactions | Integration tests | Sequence diagrams -> test scenarios |
| Level 4: Contracts | Unit tests | Function signatures -> test cases |

**Example**: A Level 4 contract like `calculate_total(items :: [Item.t()]) :: Money.t()` becomes three behavioral cycles:
- "calculate_total returns Money for a list of items"
- "calculate_total handles empty list"
- "calculate_total sums item prices correctly"

## Related Skills

All are soft dependencies — planning proceeds without them.

**Planning-time (enhance this skill):**
- **thinking-patterns**: Structured reasoning at planning gates
- **collaborating-on-design**: Produces the design artifacts that feed into this skill
- **reviewing-test-design**: Dave Farley's 8 test properties. When shaping behavioral cycles, keep these in mind (especially Atomic, Necessary, Granular) so cycles don't force the Tester to diverge from the plan during implementation

**Execution-time (take over where this skill leaves off):**
- **practicing-tdd**: Enforces the Red-Green-Refactor cycle during execution (handles GREEN + REFACTOR)
- **refactoring-code**: Provides refactoring patterns during execution (not during planning)
- **code-simplifier** agent: Post-implementation review for unnecessary complexity

## Common Patterns

### New Feature (with design artifact)
1. Extract contracts from design -> test targets
2. Data layer tests -> implementation
3. Business logic tests -> implementation
4. Integration tests -> wiring

### New Feature (without design artifact)
1. Identify behaviors from requirements
2. Core behavior tests -> implementation
3. Edge case tests -> implementation
4. Integration tests -> wiring

### Bug Fix
1. Write failing test that reproduces the bug
2. Fix minimally to pass
3. Add regression tests for related edge cases

### Refactoring
1. Characterization tests for current behavior
2. Incremental structural changes (tests stay green)
3. New tests for improved design

## Success Criteria

A TDD plan is well-formed when:
- [ ] Every phase has behavioral cycles only — no test code anywhere in the plan
- [ ] Every cycle includes a Behavior, Assertion focus, and Expected failure category
- [ ] Every phase has an automated testing summary with an exact run command
- [ ] Structural context uses `file:line` references to real code
- [ ] Phases are ordered by dependency (foundational behaviors first)
- [ ] "What We're NOT Doing" section is present and specific
- [ ] All open questions are resolved (no TBD items)
- [ ] Test run commands are included per phase

## Examples

See [references/examples.md](references/examples.md) for concrete, multi-phase examples covering:

1. **New Feature** (email verification) -- 2 phases, 5 TDD cycles, full automated verification
2. **Bug Fix** (duplicate webhooks) -- 2 phases, reproducing the bug then fixing with regression tests
3. **Refactoring** (extract module) -- Characterization tests before structural changes

## Common Mistakes

| Mistake | Why It's Wrong | Do This Instead |
|---------|----------------|-----------------|
| Implementation code in plan | Presupposes design, defeats TDD | Specify tests + structural context only |
| Exact test code in the plan | Pins names/signatures that execution and concurrent work will reshape — specs go stale, causing confusion and rework | Behavioral cycles in every phase; detail just-in-time during execution |
| Implementation before tests | Violates TDD Iron Law | Always specify RED step first |
| Tests that mock everything | Tests verify mocks, not behavior | Use real dependencies; mock only at boundaries |
| Vague test descriptions | Can't write tests from descriptions | Include expected inputs, outputs, and failure modes |
| One giant phase | Too much to hold in a single TDD cycle | Decompose into small behavioral increments |
| Missing run commands | Developer can't verify independently | Include exact test commands per phase |
