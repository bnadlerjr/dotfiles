# Preservation and Action-Oriented Review

**Load this reference when:** Farley scoring suggests tests should be removed, combined, or refactored. These guidelines guard against over-enthusiastic culling and structure the action portion of the review.

## Preserve Valuable Tests

Before recommending removal, confirm the test does *not* cover any of these. Tests covering these categories should be preserved even if their Farley scores are imperfect:

- Edge cases and boundary conditions
- Complex business logic
- Integration points between systems
- Error handling and recovery
- Security constraints
- Performance-critical paths
- Regression tests for actual bugs

A test with a weak `Granular` score but protecting a real regression is more valuable than a clean, small test that asserts nothing load-bearing.

## Mocking Hygiene

Mocking concerns are covered partially by `Atomic` and `Repeatable` properties, but deserve specific attention:

- **Tests where everything is mocked except trivial logic**: The test verifies the mocks, not the system. Strong signal of low `Necessary` score.
- **Mocking the system under test**: Invalid — you're asserting on the mock. Strong signal to remove or rewrite.
- **Tests that only verify mock interactions**: Testing plumbing, not behavior. Low `Necessary`.
- **Integration tests with all dependencies mocked**: No integration is actually tested; the "integration" label is misleading. Either restore real dependencies or reclassify as unit tests.

## Refactoring Suggestions

When flagging tests that score poorly but cover real value, prefer refactoring over removal:

- **Combine related tests into parameterized/table-driven tests** — improves `Granular` and `Necessary` simultaneously.
- **Replace multiple narrow unit tests with one integration test** — when the unit tests test plumbing rather than behavior.
- **Convert implementation tests to behavior tests** — improves `Maintainable`.
- **Remove tests and rely on type system** — applicable when a static guarantee subsumes the test.

## Action-Oriented Output

When the review identifies tests to remove, combine, or restructure, supplement the default output format with an action summary:

```markdown
### High Priority Removals

Tests that must go — specific reasoning for each, with `file:line` references.

### Refactoring Opportunities

Tests that could be combined or converted to higher-value forms.

### Low Priority Considerations

Tests of questionable value where removal is optional.

### Impact Assessment

- Estimated test execution time saved
- Lines of test code removable
- Maintenance burden reduction
```

## Communication Style

- Be direct but explain reasoning
- Acknowledge when removal might be controversial
- Provide specific code examples
- Never suggest removing a test without explaining why
- When a test has a low Farley Score but high preservation value, say so explicitly — don't let the score alone dictate the recommendation
