# Language-Specific Test Anti-Patterns

**Load this reference when:** reviewing tests in one of the listed language/framework stacks. These are concrete instantiations of low-value test patterns — specific red flags that often manifest as low scores on Farley's `Necessary`, `Maintainable`, or `Granular` properties but may be invisible to a purely abstract review.

## Elixir / ExUnit

- Duplicate GenServer call/cast tests — covering the same message in multiple forms
- Over-testing changeset validations — tests that reassert Ecto's built-in behavior
- Testing Ecto associations that just test Ecto itself
- LiveView tests that duplicate controller tests without exercising live behavior

## Ruby / RSpec

- Excessive stubbing with `allow`/`expect` that removes real behavior
- Testing Rails validations verbatim (re-asserting what the framework already guarantees)
- Controller tests that duplicate request specs
- Model specs that test ActiveRecord rather than domain behavior

## JavaScript / TypeScript

- Testing React prop passing (exercises React, not the component)
- Redux tests that just test Redux's reducer semantics
- Mocking everything except a trivial function, such that the test verifies mocks
- Snapshot tests without assertions about meaningful structure

## Python

- Testing type hints at runtime
- Mocking file operations for trivial scripts where real I/O would be simpler
- Testing library behavior instead of your code's use of it

## How to Use

When reviewing a test file in one of these stacks, check for these specific patterns first — they map directly to Farley property scores:

- Duplicates and framework re-testing → lower `Necessary`
- Over-mocking → lower `Atomic` and `Repeatable`
- Framework-coupled tests → lower `Maintainable`

If any of these patterns appear, cite them in the Evidence column of the Property Scores table.
