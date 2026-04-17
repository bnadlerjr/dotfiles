---
name: planning-tdd
description: Creates TDD implementation plans where tests ARE the plan. Specifies test specs and structural context per phase — implementation emerges during execution, not planning. Verification is fully automated; no manual verification step. Use when planning features test-first, creating TDD plans from design artifacts, or when the user asks for a test-driven implementation plan.
allowed-tools: Read, Glob, Grep, Agent
---

# TDD Planning

Create test-driven implementation plans where every phase is organized
around TDD cycles with both automated and manual testing.

## Dependencies (soft)

These skills enhance the planning process but are not required. The skill
functions without them using standard reasoning and TDD principles.

- **practicing-tdd** skill: Provides TDD methodology (Iron Law, cycle rules)
- **thinking-patterns** skill: Structured reasoning at each planning gate
- **reviewing-test-design** skill: Dave Farley's 8 properties of good tests. When shaping RED test specs, keep these properties in mind (especially Atomic, Necessary, Granular) so specs don't force the Tester to diverge from the plan to satisfy them during implementation.

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
- User references a design artifact from `/whiteboard` for implementation planning
- User wants explicit test specifications in their implementation plan
- User mentions "test-first plan", "TDD plan", or "plan with tests"

## Core Principles

1. **Tests ARE the Plan**: The plan specifies what to test, not how to implement. Implementation emerges from tests during execution. Including implementation code in the plan presupposes design and defeats the purpose of TDD.
2. **Structural Context, Not Solutions**: The plan identifies which modules, files, and contracts are in play — enough to know *where* to work, not *what* to write.
3. **Interactive**: Never dump a complete plan. Gather context -> verify understanding -> align on approach -> detail phases.
4. **Grounded**: Every claim verified against actual code. Include `file:line` references.
5. **Bounded**: Every plan MUST include "What We're NOT Doing" section.
6. **Automated Verification**: Every phase is verified by automated tests. No manual-verification step exists in the plan or the implementation flow. Behavior that cannot be asserted by an automated test must be called out explicitly in the plan and escalated — not deferred to a manual check.
7. **Incremental Confidence**: Each TDD cycle builds on the confidence established by previous passing tests.

## Process

### Step 1: Context Gathering

1. Apply `/thinking atomic-thought` to decompose the task into key
   questions: What is the goal? What exists today? What changes? What
   constraints apply? What design artifacts exist?

2. **Read all mentioned files FULLY** (stories, designs, tickets, specs)
   - **NEVER** read files partially

3. **Extract design contracts** if a `/whiteboard` artifact exists:
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
   apply `/thinking tree-of-thoughts` to compare on:
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

1. Apply `/thinking skeleton-of-thought` to break the work into testable
   behavioral increments.

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

Each TDD cycle in the plan contains exactly 3 parts:

1. **RED test spec** — A code block with the exact test to write first
2. **Expected failure** — What the failure message looks like when run
3. **Structural context** — `file:line` references for modules/files in play

Each cycle MUST NOT contain:
- **GREEN** sections or implementation code
- **REFACTOR** sections or "None needed" commentary
- Code that is not a test

GREEN and REFACTOR emerge during execution via `practicing-tdd` and `refactoring-code` skills. They do not belong in a plan.

### Step 4: Detailed Plan

When user approves structure, write the complete plan using the template
at [templates/plan-template.md](templates/plan-template.md).

For each phase, detail:

1. **TDD Cycles** (the heart of the plan):
   - **RED**: The exact test to write, with expected failure message.
     Include test name, inputs, expected outputs, and assertion focus.
   - **Structural Context**: Which modules/files are in play, where
     the test file lives, relevant contracts or interfaces. Do NOT
     include implementation or refactoring guidance — both emerge
     during execution via `practicing-tdd` and `refactoring-code`.

2. **Automated Testing** (summary for the phase):
   - All unit tests with descriptions
   - Integration tests with scenarios
   - The exact command to run them
   - Expected pass/fail count

After writing the plan, apply `/thinking self-consistency` to validate:
- Does every phase start with failing tests?
- Does every phase have clear "done when" criteria?
- Is automated testing covered in every phase with an exact run command?
- Are dependencies between phases correct?
- Is scope properly bounded?
- Does any cycle contain a GREEN or implementation section? -> Remove it
- Does any cycle contain a REFACTOR section or "None needed" commentary? -> Remove it
- Does any cycle contain code that is NOT a test? -> Replace with structural context

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

When a `/whiteboard` design artifact is available, use this mapping:

| Design Level | Test Type | What to Extract |
|---|---|---|
| Level 1: Capabilities | Scope boundaries | What NOT to test (out of scope) |
| Level 2: Components | Module structure | Test file organization |
| Level 3: Interactions | Integration tests | Sequence diagrams -> test scenarios |
| Level 4: Contracts | Unit tests | Function signatures -> test cases |

**Example**: A Level 4 contract like `calculate_total(items :: [Item.t()]) :: Money.t()` becomes:
- RED: `test "calculate_total returns Money for a list of items"`
- RED: `test "calculate_total handles empty list"`
- RED: `test "calculate_total sums item prices correctly"`

## Related Skills

- **practicing-tdd**: Enforces Red-Green-Refactor cycle during execution (handles GREEN + REFACTOR)
- **refactoring-code**: Provides refactoring patterns during execution (not during planning)
- **reviewing-test-design**: Dave Farley's 8 test properties — guidance for shaping RED test specs so they're Farley-compatible from the start
- **code-simplifier** agent: Post-implementation review for unnecessary complexity
- **thinking-patterns**: Structured reasoning at planning gates
- **breaking-down-stories**: Decomposing stories before planning
- **collaborating-on-design**: Producing design artifacts that feed into this skill

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
- [ ] Every phase starts with RED test specifications (no implementation code)
- [ ] Every test spec includes expected inputs, outputs, and failure modes
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
| Implementation before tests | Violates TDD Iron Law | Always specify RED step first |
| Tests that mock everything | Tests verify mocks, not behavior | Use real dependencies; mock only at boundaries |
| Vague test descriptions | Can't write tests from descriptions | Include expected inputs, outputs, and failure modes |
| One giant phase | Too much to hold in a single TDD cycle | Decompose into small behavioral increments |
| Missing run commands | Developer can't verify independently | Include exact test commands per phase |
