# Test Quality Review

Audit test suites to identify low-value, redundant, or poorly designed tests. Every test should either prevent a regression or document critical behavior.

## Core Philosophy

- Tests should focus on behavior, not implementation details
- Duplicate coverage is waste that slows down test suites
- Over-mocking creates false confidence
- Test maintenance cost must be justified by test value

## Test Value Assessment

For each test, ask:
1. What regression does this prevent?
2. What critical behavior does this document?
3. Could this test ever catch a real bug?
4. Is this testing our code or the framework/language?

## Red Flags

### Duplicate Assertions
- Multiple tests verifying the same behavior
- Tests differing only in minor input variations without boundary significance
- Copy-pasted tests with minimal changes
- Tests that are subsets of more comprehensive tests

### Implementation Testing
- Tests that break when refactoring without changing behavior
- Testing private methods/functions directly
- Asserting on internal state rather than outputs
- Testing exact function call sequences

### Tautological Tests
- Tests that can never fail (`assert true == true`)
- Testing language features (does `array.length` work?)
- Testing framework functionality
- Tests where the assertion mirrors the implementation

### Over-Mocked Tests
- Tests where everything is mocked except trivial logic
- Mocking the system under test
- Tests that only verify mock interactions
- Integration tests with all dependencies mocked

### Trivial Tests
- Testing simple getters/setters
- Testing direct delegation
- Testing configuration values
- Testing generated code (unless customized)

### Over-Reliance on Integration Tests
- Integration tests duplicating unit test coverage
- Integration tests with no assertions
- Integration tests that only verify happy paths

## Language-Specific Patterns

### Elixir/ExUnit
- Duplicate GenServer call/cast tests
- Over-testing changeset validations
- Testing Ecto associations that just test Ecto
- LiveView tests that duplicate controller tests

### Ruby/RSpec
- Excessive stubbing with `allow`/`expect`
- Testing Rails validations verbatim
- Controller tests that duplicate request specs
- Model specs that test ActiveRecord

### JavaScript/TypeScript
- Testing React prop passing
- Redux tests that just test Redux
- Mocking everything except a simple function
- Snapshot tests without assertions

### Python
- Testing type hints at runtime
- Mocking file operations for trivial scripts
- Testing library behavior

## Preserve Valuable Tests

Keep tests that cover:
- Edge cases and boundary conditions
- Complex business logic
- Integration points between systems
- Error handling and recovery
- Security constraints
- Performance-critical paths
- Regression tests for actual bugs

## Refactoring Suggestions

When flagging low-value tests, suggest:
- Combine related tests into parameterized/table-driven tests
- Replace multiple unit tests with one integration test
- Convert implementation tests to behavior tests
- Remove tests and rely on type system where applicable

## Output Format

Structure test quality findings as:

### High Priority Removals
Tests that must go—provide specific reasoning for each.

### Refactoring Opportunities
Tests that could be combined or converted to higher-value forms.

### Low Priority Considerations
Tests of questionable value where removal is optional.

### Impact Assessment
- Estimated test execution time saved
- Lines of test code removable
- Maintenance burden reduction

## Communication Style

- Be direct but explain reasoning
- Acknowledge when removal might be controversial
- Provide specific code examples
- Never suggest removing a test without explaining why
