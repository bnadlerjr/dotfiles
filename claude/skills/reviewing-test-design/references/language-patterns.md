# Language-Specific Test Anti-Patterns

**Load this reference when:** reviewing tests in one of the listed language/framework stacks. These are concrete instantiations of low-value test patterns — specific red flags that often manifest as low scores on Farley's `Necessary`, `Maintainable`, or `Granular` properties but may be invisible to a purely abstract review.

## Universal: Mirror / Change-Detector / Tautological Tests

**Symptom:** The assertion text appears verbatim in the source under test, separated only by `Enum.find` / `[:key]` / `.field` access. No transformation, no branching, no I/O between source and assertion.

**Examples:**

```elixir
# Source:
@config %{timeout: 5000, retries: 3}
def config, do: @config

# Tautological test:
assert MyModule.config().timeout == 5000
```

```elixir
# Source:
@options [%{value: :a, label: "A"}, %{value: :b, label: "B"}]

# Tautological test:
assert Enum.map(@options, & &1.value) == [:a, :b]
```

**Discriminator question:** "Would deleting this test cause any real bug to go undetected?"
- If the answer is "only if I changed one literal and forgot the matching one" → tautological. Delete.
- If the answer is "an integration test would catch it anyway" → tautological. Delete.
- If the answer names a real branching / transformation defect → keep.

**Maps to:** Necessary ≤4, Maintainable ≤5 (couples to source layout, not behavior).

**Common excuses to override (and why they fail):**

| Excuse | Why it fails |
|---|---|
| "It pins the contract for the GraphQL/UI." | If true, the integration test that consumes the contract pins it more durably. Delete the unit-level mirror. |
| "It catches typos in the literal." | The type system or compiler is the right tool. A runtime test that the literal you wrote equals the literal you wrote catches nothing. |
| "It serves as documentation." | Documentation belongs in `@moduledoc` / `@doc`, not in a test that breaks on every cosmetic change. |
| "It's TDD: I wrote the test first." | TDD requires a transformation under test. A test you satisfy by writing a literal is mis-scoped. See `planning-tdd`. |

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
