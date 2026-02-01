# Testing ExUnit Reference

Expert guidance for Test-Driven Development with ExUnit in Elixir applications.

## Quick Start

```elixir
defmodule MyApp.OrderTest do
  use ExUnit.Case, async: true

  describe "discount/2" do
    test "applies gold tier discount" do
      assert Order.discount(100, :gold) == 80
    end

    test "applies silver tier discount" do
      assert Order.discount(100, :silver) == 90
    end
  end
end
```

## Core Testing Expertise

- ExUnit setup, configuration, and best practices
- Test organization with describe blocks and contexts
- Setup and setup_all callbacks for test preparation
- Tags and conditional test execution strategies
- Async vs sync test decisions and isolation patterns
- Test naming conventions that communicate intent
- Managing side effects and ensuring test independence

## TDD Phase Guidance

For general TDD phase definitions, see [SKILL.md](../SKILL.md#tdd-phase-awareness).

**Testing-specific guidance by phase:**

| Phase | Focus | Avoid |
|-------|-------|-------|
| RED | Smallest test, one assertion, hard-coded values | Edge cases, factories, helpers |
| GREEN | Don't modify tests, minimal data | Adding assertions, refactoring tests |
| REFACTOR | Describe blocks, setup patterns, edge cases | Over-abstracting test helpers |

## Progressive Test Development Strategy

Advocate this progression:
1. Single concrete example first
2. Add another example only if it drives new code
3. Extract commonalities after 3 similar tests
4. Add edge cases after happy path works
5. Consider property tests after examples work
6. Add integration tests after units work

## Anti-Patterns to Prevent

Actively discourage:
- Writing multiple assertions before any pass
- Creating elaborate test fixtures prematurely
- Testing implementation details
- Adding error case tests too early
- Over-specifying with exact error messages
- Building test helpers before patterns emerge
- Writing integration tests first
- Tests that mirror the implementation structure
- Highly coupled tests that break together
- Mocking the subject under test

## Assertion Strategies

### RED PHASE Assertions
- Simple `assert actual == expected`
- Basic pattern matches
- Truthy/falsy checks

### REFACTOR PHASE Assertions
- Custom assertions for domain clarity
- Pattern matching for partial matches
- Approximate assertions for floats
- Descriptive error messages

## Test Data Management

### RED PHASE Approach
- Hard-coded values directly in tests
- Minimal valid data only
- No factories or builders

### REFACTOR PHASE Approach
- Extract to module attributes or helpers
- Consider ExMachina for complex scenarios
- Shared fixtures for common cases

## Mocking & Stubbing Guidance

Recommend:
- Avoiding mocks in RED phase entirely
- Using real objects when possible
- Only mocking external services and boundaries
- Preferring functional core, imperative shell architecture
- Using Mox when mocking is necessary

## Communication Approach

- In RED: Emphasize "Just assert the exact value you want"
- In GREEN: Insist "Don't touch the test, make it pass"
- In REFACTOR: Encourage "Now we can improve the test structure"
- Always ask: "What's the minimal test that drives the code?"
- Celebrate test code deletion and simplification
- Be direct and specific about which phase applies

## Special Considerations

When to write comprehensive tests first:
- Reproducing specific reported bugs
- Critical security boundaries
- Complex algorithms with known requirements
- Regulatory compliance needs
- Performance requirements

## Always

- Identify the current TDD phase from context
- Provide phase-appropriate advice only
- Resist premature test complexity
- Focus on tests that drive design
- Ensure tests can actually fail
- Promote test independence and clarity
- Guide toward sociable unit tests over heavy mocking
- Encourage descriptive test names that explain "what" not "how"

## Goal

Help developers write better tests by writing less test code initially, then improving strategically during refactoring phases.
