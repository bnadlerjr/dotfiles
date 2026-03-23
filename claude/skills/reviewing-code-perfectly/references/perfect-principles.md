# PERFECT Principles — Detailed Reference

Source: Daniil Bastrich's PERFECT code review methodology.

Each principle is applied in strict priority order. Earlier principles have higher impact — a PR that fails on Purpose has zero value regardless of how clean the code is.

---

## 1. Purpose — Code Solves the Task

**Priority**: Highest. Without this, the review has zero value.

### How to evaluate

1. **Understand the task first.** Read the PR description, linked ticket, or infer from the diff context. If the task is unclear, flag this immediately — you cannot review code without knowing what it should do.

2. **Outline your own approach.** Before diving into implementation details, roughly consider how you would solve the task. This creates a mental baseline for comparison.

3. **Compare.** Does the implementation actually solve the stated task? Look for:
   - Missing requirements
   - Over-engineering beyond the task scope
   - Solving a different problem than described
   - Partial implementation (task half-done)

### Common issues

- PR description says "add validation" but only adds it to one of three entry points
- Code handles the happy path but ignores stated error requirements
- Implementation adds features not in the task scope (scope creep)
- Refactoring PR that changes behavior when it should not

### What to report

- Gaps between requirements and implementation
- Unstated assumptions that affect correctness
- If the task itself is unclear, request clarification before continuing

---

## 2. Edge Cases — Corner Cases Are Handled

**Priority**: High. A significant portion of production bugs comes from overlooked edge cases.

### Categories of edge cases

**Business edge cases:**
- Unusual but valid input combinations
- Boundary values for business rules (exactly at threshold, one above, one below)
- Omitted requirements ("what happens when the user has no orders?")
- Race conditions in concurrent workflows

**Technical edge cases:**
- Null/nil/undefined/empty values where presence is assumed
- Empty collections (arrays, maps, strings)
- Type limits (integer overflow, float precision)
- Extremely large or extremely small inputs
- Unicode, special characters, whitespace-only strings
- Time zones, daylight saving transitions, leap years
- Network failures, timeouts, partial responses

**"Impossible" cases:**
- States that appear unreachable but are inherently dangerous
- Accessing optional values without checking presence
- Assuming enum/union types are exhaustive (what about future additions?)
- Default branches in switches that silently swallow unexpected values

### How to evaluate

1. For each function or logic branch in the diff, ask: "What inputs would break this?"
2. Check boundary values explicitly
3. Look for missing nil/null checks on values that come from external sources (DB, API, user input)
4. Verify error paths are handled, not just happy paths

### What to report

- The specific edge case scenario
- Why it matters (what breaks, what data is corrupted)
- Proposed handling approach

---

## 3. Reliability — No Performance or Security Issues

**Priority**: High. Even basic checks prevent costly production issues.

### Performance checks

- **Time complexity**: Is it appropriate for expected data volume? O(n^2) on a list of 10 is fine; O(n^2) on a list of 100,000 is not.
- **Memory**: Does it load entire datasets into memory when streaming would work?
- **N+1 queries**: Database queries inside loops
- **Missing indexes**: Queries on unindexed columns with large tables
- **Cache invalidation**: Is cached data invalidated when the source changes?
- **Unnecessary work**: Repeated computations, redundant API calls

### Security checks

- **Input validation**: Is user input validated before use?
- **SQL injection**: Raw string interpolation in queries
- **XSS**: User content rendered without sanitization
- **Credential exposure**: Secrets in code, logs, or error messages
- **Authorization**: Are permission checks in place for sensitive operations?
- **Path traversal**: User-controlled file paths without sanitization
- **Broken integrations**: API calls without timeout, retry, or error handling

### What to report

- The specific concern with data about expected scale
- Concrete impact (slow page load, data leak, crash under load)
- Proposed fix or mitigation

---

## 4. Form — Code Aligns with Design Principles

**Priority**: Medium. Standardized design reduces cost of changes, debugging, and maintenance.

### Core principle: High Cohesion / Low Coupling

This is the foundational design principle. SOLID, KISS, DRY are specific interpretations:

- **High Cohesion**: Does each module/class/function have a single, focused purpose? Are related things grouped together?
- **Low Coupling**: Can modules change independently? Are dependencies explicit and minimal?

### What to look for

- **Single Responsibility**: Does a new class or function do too many unrelated things?
- **Dependency direction**: Do higher-level modules depend on lower-level abstractions, not concrete implementations?
- **DRY violations**: Is the same logic duplicated in multiple places? (But only flag true duplication — similar-looking code that varies for different reasons is not a DRY violation.)
- **Premature abstraction**: Is code abstracted before there are multiple concrete use cases? (AHA — Avoid Hasty Abstraction)
- **Layering violations**: Does UI code reach directly into the database? Does business logic depend on HTTP request details?

### Subjectivity warning

Design questions are inherently subjective. When raising a Form concern:

- **Require clear arguments**: "This violates SRP" is not enough. Explain the concrete cost: "If billing rules change, you also have to modify the notification module because they share mutable state."
- **Propose alternatives**: At least describe the direction, even if not a complete solution.
- **Acknowledge trade-offs**: "Extracting this adds a file but decouples X from Y."

If no project conventions exist for a particular design question, and the current approach works, defer to the author.

---

## 5. Evidence — Tests and CI Pass

**Priority**: Medium. Changes should be covered by tests. Tests themselves should be reviewed with the same principles.

### What to verify

1. **CI status**: Do all checks pass? If not, the PR is not ready for review.
2. **Test coverage**: Are the changes covered by tests? New logic should have new tests. Modified logic should have updated tests.
3. **Test quality**: Apply the same PERFECT principles to test code:
   - Do tests test actual behavior, not implementation details?
   - Do tests cover edge cases from Principle 2?
   - Are test names descriptive of the scenario and expected outcome?
   - Are assertions meaningful (not just "does not throw")?

### Anti-patterns in tests

- **Testing implementation**: Tests break when you refactor without changing behavior
- **Over-mocking**: Everything is mocked except trivial logic — the test proves nothing
- **Production test hooks**: Special `if (process.env.TEST)` branches in production code. Design the code to be testable naturally.
- **Missing negative tests**: Only happy-path scenarios

### What to report

- Missing test coverage with specific scenarios that should be tested
- Test quality issues with reasoning
- CI failures that need resolution

---

## 6. Clarity — Code Communicates Intent

**Priority**: Lower. Code should be understandable without reading every line ("readable diagonally").

### What to look for

- **Naming**: Do variable, function, and class names communicate purpose? Can you understand a function's role from its name without reading its body?
- **File structure**: Are files organized logically? Can you find related code by navigating the directory tree?
- **Function length**: Functions over 50 lines may need decomposition (but not always — algorithms are an exception)
- **Nesting depth**: More than 3 levels of nesting hurts readability. Early returns and guard clauses help.
- **Statement order**: Are related statements grouped? Is the code organized top-down (public API first, private helpers after)?
- **Comments**: Are comments explaining WHY, not WHAT? Is the code clear enough to not need comments?

### Subjectivity warning

If no agreed conventions exist and the code is not explicitly unclear, defer to the author. Different developers have different reading preferences.

### What to report

- Specific locations where intent is ambiguous
- Suggested renaming or restructuring with reasoning
- Keep clarity suggestions proportional — do not rewrite the entire PR for style

---

## 7. Taste — Personal Preferences

**Priority**: Lowest. These are opinions, not requirements.

### Rules

- **Always mark as non-blocking**: The author may decline without justification.
- **Must include reasoning**: Even taste items need clear reasoning and a constructive proposal. "I'd prefer X because..." not just "I'd prefer X."
- **Never block a PR on taste alone.**
- **Limit quantity**: 1-3 taste items maximum. More than that becomes noise.

### Examples of taste items

- "I personally prefer extracting this into a named constant, but the inline value is clear enough."
- "A different data structure might read more naturally here, but the current one works correctly."
- "I'd order these parameters differently, but that's just my preference."

### Promotion path

Valuable taste items can become shared agreements over time. If you notice a pattern worth standardizing, propose it as a team convention separately from the PR review.
