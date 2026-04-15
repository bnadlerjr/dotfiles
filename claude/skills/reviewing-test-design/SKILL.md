---
name: reviewing-test-design
description: Evaluates test quality using Dave Farley's 8 properties. Use when reviewing tests, assessing test suite quality, or analyzing test effectiveness against TDD best practices.
argument-hint: <test file, directory, or glob pattern>
context: fork
agent: Explore
model: sonnet
---

# Reviewing Test Design

Evaluate test quality using Dave Farley's 8 properties of good tests.

## Quick Start

```
/reviewing-test-design test/models/user_test.exs
```

1. Read the test file(s) specified in $ARGUMENTS
2. Score each of the 8 properties on a 1-10 scale
3. Calculate the weighted Farley Score
4. Provide prioritized recommendations

## Your Expertise

You specialize in evaluating test quality using Dave Farley's testing principles. You understand that great tests are not just about code coverage, but about creating maintainable, reliable, and meaningful verification of system behavior.

## Inputs

- $ARGUMENTS: test file paths, directories, or glob patterns to review

If $ARGUMENTS is empty, ask which test files to review.

## Review Process

1. **Read the tests thoroughly** before examining implementation code
2. **Evaluate each property** independently with specific evidence
3. **Provide concrete examples** from the code for each score
4. **Suggest specific improvements** with code examples where helpful
5. **Calculate and present the Farley Score** with breakdown
6. **Prioritize recommendations** by impact

## Evaluation Framework

Score each test file or test suite against these eight properties on a 1-10 scale.

### 1. Understandable (U)

- **10**: Tests read like specifications; behavior is crystal clear without reading implementation
- **7-9**: Tests are clear with minor ambiguities; intent is mostly obvious
- **4-6**: Tests require some code inspection to understand purpose
- **1-3**: Tests are cryptic; heavy reliance on implementation details

### 2. Maintainable (M)

- **10**: Tests use proper abstractions; changes to implementation rarely break tests
- **7-9**: Good separation of concerns; occasional brittleness
- **4-6**: Some coupling to implementation; moderate refactoring pain
- **1-3**: Tightly coupled to implementation; tests break with minor changes

### 3. Repeatable (R)

- **10**: Tests are deterministic; same result every time, anywhere
- **7-9**: Rarely flaky; minimal environmental dependencies
- **4-6**: Occasional flakiness; some timing or state dependencies
- **1-3**: Frequently inconsistent; relies on external state or timing

### 4. Atomic (A)

- **10**: Tests are completely isolated; no shared state; parallelizable
- **7-9**: Mostly isolated; minor dependencies between tests
- **4-6**: Some shared state; test order sometimes matters
- **1-3**: Heavy interdependencies; tests must run in specific order

### 5. Necessary (N)

- **10**: Every test adds value; no redundancy; guides development decisions
- **7-9**: Most tests are valuable; minor redundancy
- **4-6**: Some tests feel like checkbox exercises; moderate redundancy
- **1-3**: Many tests add little value; significant redundancy

### 6. Granular (G)

- **10**: Each test asserts one thing; failures pinpoint exact issues
- **7-9**: Tests are focused; occasional multiple assertions with clear purpose
- **4-6**: Tests cover multiple behaviors; failure diagnosis takes effort
- **1-3**: Tests are sprawling; failures require significant investigation

### 7. Fast (F)

- **10**: Tests execute in milliseconds; entire suite runs quickly
- **7-9**: Tests are quick; minor optimization opportunities
- **4-6**: Some slow tests; suite takes noticeable time
- **1-3**: Tests are slow; significant impact on development flow

### 8. First (T — for TDD)

- **10**: Clear evidence of test-first approach; tests drive design
- **7-9**: Likely written test-first; good design influence
- **4-6**: Unclear if test-first; tests feel like afterthoughts
- **1-3**: Clearly written after code; tests follow implementation structure

## The Farley Score

Calculate the final score using this weighted formula:

```
Farley Score = (U*1.5 + M*1.5 + R*1.25 + A*1.0 + N*1.0 + G*1.0 + F*0.75 + T*1.0) / 9
```

**Weight rationale:**

- Understandable (1.5x): Tests as documentation is paramount
- Maintainable (1.5x): Long-term value depends on maintainability
- Repeatable (1.25x): Reliability is critical for trust
- Atomic, Necessary, Granular, First (1.0x): Core principles equally important
- Fast (0.75x): Important but can be optimized later

**Score interpretation:**

| Range | Rating | Meaning |
|-------|--------|---------|
| 9.0-10.0 | Exemplary | Model for the industry |
| 7.5-8.9 | Excellent | High quality with minor improvements possible |
| 6.0-7.4 | Good | Solid foundation with clear improvement opportunities |
| 4.5-5.9 | Fair | Functional but needs significant attention |
| 3.0-4.4 | Poor | Limited value; major refactoring needed |
| Below 3.0 | Critical | Tests may be harmful; consider rewriting |

## Output Format

```markdown
## Test Design Review: [File/Suite Name]

### Property Scores

| Property | Score | Evidence |
|----------|-------|----------|
| Understandable | X/10 | [Brief justification] |
| Maintainable | X/10 | [Brief justification] |
| Repeatable | X/10 | [Brief justification] |
| Atomic | X/10 | [Brief justification] |
| Necessary | X/10 | [Brief justification] |
| Granular | X/10 | [Brief justification] |
| Fast | X/10 | [Brief justification] |
| First (TDD) | X/10 | [Brief justification] |

### Farley Score: X.X/10 [Rating]

### Detailed Analysis

[Expand on each property with specific code examples]

### Top Recommendations

1. [Highest impact improvement]
2. [Second priority]
3. [Third priority]

### Reference

This review is based on Dave Farley's Properties of Good Tests:
https://www.linkedin.com/pulse/tdd-properties-good-tests-dave-farley-iexge/
```

## Guidelines

- Be constructive and specific; vague feedback helps no one
- Acknowledge what's done well before critiquing
- Provide actionable suggestions, not just problems
- Consider the context and constraints of the project
- When uncertain about TDD adherence, note it and score conservatively
- If reviewing multiple test files, provide both individual and aggregate scores
- Always include the reference link to Dave Farley's article in your output
