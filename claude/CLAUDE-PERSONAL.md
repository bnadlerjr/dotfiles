# Claude Code Guidelines by Bob Nadler

## Implementation Best Practices

### Purpose  

These rules ensure maintainability, safety, and developer velocity. 
**MUST** rules are enforced by CI; **SHOULD** rules are strongly recommended.

---

### Before Coding

- **MUST** Ask the user clarifying questions.
- **SHOULD** Draft and confirm an approach for complex work.  
- **SHOULD** If ≥ 2 approaches exist, list clear pros and cons.

---

### While Coding

- **MUST** Follow TDD: scaffold stub -> write failing test -> implement.
- **SHOULD NOT** Add comments except for critical caveats; rely on self‑explanatory code.

1. ALWAYS match the existing code style of the file you're editing
2. NEVER introduce new syntax variations for the same operations (e.g. don't switch from hash rockets to colons, don't introduce 'render partial:' if plain 'render' is used)
3. NEVER refactor code that isn't broken without explicit permission
4. NEVER make cosmetic or stylistic changes without explicit permission
5. If you need to add code, copy the exact style from surrounding code

---

### Testing

- **SHOULD** Prefer sociable unit tests over heavy mocking.  
- **SHOULD** Unit-test complex algorithms thoroughly.

---

### Git

- **SHOULD NOT** Refer to Claude or Anthropic in commit messages.

---

## Writing Tests Best Practices

When evaluating whether a test you've implemented is good or not, use this checklist:

1. SHOULD parameterize inputs; never embed unexplained literals such as 42 or "foo" directly in the test.
2. SHOULD NOT add a test unless it can fail for a real defect. Trivial asserts (e.g., expect(2).toBe(2)) are forbidden.
3. SHOULD ensure the test description states exactly what the final expect verifies. If the wording and assert don’t align, rename or rewrite.
4. SHOULD compare results to independent, pre-computed expectations or to properties of the domain, never to the function’s output re-used as the oracle.
5. SHOULD follow the same lint, type-safety, and style rules as prod code (rubocop, credo, prettier, etc.).
6. ALWAYS use strong assertions over weaker ones e.g. `expect(x).toEqual(1)` instead of `expect(x).toBeGreaterThanOrEqual(1)`.
7. SHOULD test edge cases, realistic input, unexpected input, and value boundaries.
8. SHOULD NOT test conditions that are caught by the type checker.
