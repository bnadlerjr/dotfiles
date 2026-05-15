# Universal Test Anti-Patterns

**Load this reference when:** scoring tests against Farley's Necessary property, or reviewing any test code for tautological patterns. These rules are language-agnostic — they apply in every stack.

## Mirror / Change-Detector / Tautological Tests

**Symptom:** The assertion text appears verbatim in the source under test, separated only by simple property access (`.field`, `[:key]`, `Enum.find`, etc.). No transformation, no branching, no I/O between source and assertion.

**Examples:**

```elixir
# Source:
@config %{timeout: 5000, retries: 3}
def config, do: @config

# Tautological test:
assert MyModule.config().timeout == 5000
```

```javascript
// Source:
export const OPTIONS = [{ value: 'a', label: 'A' }, { value: 'b', label: 'B' }];

// Tautological test:
expect(OPTIONS.map(o => o.value)).toEqual(['a', 'b']);
```

```python
# Source:
DEFAULT_TIMEOUT = 30

# Tautological test:
def test_default_timeout():
    assert config.DEFAULT_TIMEOUT == 30
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
| "It serves as documentation." | Documentation belongs in `@moduledoc` / `@doc` / docstrings, not in a test that breaks on every cosmetic change. |
| "It's TDD: I wrote the test first." | TDD requires a transformation under test. A test you satisfy by writing a literal is mis-scoped. |

**Genuine exception** — keep the test only if **both** hold:
- The contract is consumed by a system outside this codebase (an external API client, a serialized schema, a published artifact), AND
- No higher-level test (integration, end-to-end, snapshot) already pins it.

If the test was added as a regression for an actual reported bug, see `preservation.md` before deleting.
