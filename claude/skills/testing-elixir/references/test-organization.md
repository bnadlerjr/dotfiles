# Test Organization

Test architecture, file structure, shared helpers, tagging strategies, and suite management.

## File Naming and Directory Structure

Test files mirror the `lib/` structure exactly.

```
lib/
  my_app/
    accounts/
      user.ex
    orders/
      checkout.ex
    orders.ex
test/
  my_app/
    accounts/
      user_test.exs
    orders/
      checkout_test.exs
    orders_test.exs
  my_app_web/
    controllers/
      order_controller_test.exs
    live/
      order_live_test.exs
    channels/
      order_channel_test.exs
  support/
    conn_case.ex
    data_case.ex
    channel_case.ex
    factory.ex
    fixtures/
      sample_data.json
  test_helper.exs
```

Convention: `lib/my_app/orders.ex` -> `test/my_app/orders_test.exs`.

## Shared Test Helpers in test/support/

Place reusable test utilities in `test/support/`. These files are compiled by ExUnit before tests run (configured in `mix.exs`).

### mix.exs configuration

```elixir
def project do
  [
    # ...
    elixirc_paths: elixirc_paths(Mix.env())
  ]
end

defp elixirc_paths(:test), do: ["lib", "test/support"]
defp elixirc_paths(_), do: ["lib"]
```

### Common support modules

```elixir
# test/support/data_case.ex - for tests that need the database
defmodule MyApp.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MyApp.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import MyApp.DataCase
      import MyApp.Factory
    end
  end

  setup tags do
    MyApp.DataCase.setup_sandbox(tags)
    :ok
  end

  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(MyApp.Repo, shared: !tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end

  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
```

### Custom assertion helpers (shared)

When assertion patterns appear in 3+ test files, extract to a shared module.

```elixir
# test/support/assertions.ex
defmodule MyApp.TestAssertions do
  import ExUnit.Assertions

  def assert_recent(datetime, tolerance_seconds \\ 5) do
    diff = DateTime.diff(DateTime.utc_now(), datetime, :second)

    assert diff >= 0 and diff < tolerance_seconds,
      "Expected #{inspect(datetime)} to be within #{tolerance_seconds}s of now"
  end

  def assert_email_sent(to, subject) do
    assert_receive {:email_sent, %{to: ^to, subject: ^subject}},
      500,
      "Expected email to #{to} with subject #{inspect(subject)}"
  end
end
```

Import in the case templates that need them:

```elixir
using do
  quote do
    import MyApp.TestAssertions
  end
end
```

## When to Use Describe Blocks

### Group by function

```elixir
describe "create_user/1" do
  test "with valid attributes" do
    # ...
  end

  test "with duplicate email" do
    # ...
  end
end

describe "authenticate/2" do
  test "with correct credentials" do
    # ...
  end

  test "with wrong password" do
    # ...
  end
end
```

### Group by scenario

```elixir
describe "checkout as guest user" do
  test "requires email address" do
    # ...
  end

  test "creates a new account" do
    # ...
  end
end

describe "checkout as returning customer" do
  test "uses saved payment method" do
    # ...
  end
end
```

### Do not nest describes

ExUnit does not support nested describes. Flatten with descriptive test names.

```elixir
# Good: flat structure
describe "checkout/1" do
  test "with valid cart creates an order" do
    # ...
  end

  test "with empty cart returns error" do
    # ...
  end

  test "with expired coupon ignores the discount" do
    # ...
  end
end
```

## Test Tagging Strategies

### Categorize by test type

```elixir
# test/test_helper.exs
ExUnit.start(exclude: [:skip])

# Optionally exclude slow tests by default:
# ExUnit.start(exclude: [:skip, :slow])
```

```elixir
@moduletag :integration

@tag :slow
test "processes 10k records" do
  # ...
end

@tag :external
test "verifies webhook signature with real key" do
  # ...
end

@tag :skip
test "not yet implemented" do
  # ...
end
```

### Running tagged subsets

```bash
# Run only integration tests
mix test --only integration

# Exclude slow tests
mix test --exclude slow

# Combine filters
mix test --only integration --exclude external

# Run everything including normally excluded
mix test --include slow
```

### Custom tag for feature flags

```elixir
@tag feature: :new_checkout
test "uses new checkout flow" do
  # ...
end
```

```bash
mix test --only feature:new_checkout
```

## Test Isolation

Each test must be independent. No test should depend on another test having run first.

### Rules for isolation

1. **No shared mutable state.** Each test creates its own data via `setup` or inline.
2. **No test ordering.** Tests must pass when run individually or in any order.
3. **No shared processes.** Use `start_supervised/1` for processes scoped to a test.
4. **No shared files.** Use unique temp paths per test if writing files.

### start_supervised for process isolation

```elixir
test "cache stores and retrieves values" do
  cache = start_supervised!({MyApp.Cache, name: :"cache_#{System.unique_integer()}"})

  MyApp.Cache.put(cache, :key, "value")
  assert MyApp.Cache.get(cache, :key) == "value"
end
```

`start_supervised!/1` links the process to the test, ensuring cleanup after the test.

### Application env isolation

If you must modify application env in a test, restore it afterward.

```elixir
setup do
  original = Application.get_env(:my_app, :feature_flags)

  on_exit(fn ->
    Application.put_env(:my_app, :feature_flags, original)
  end)

  :ok
end

test "enables beta features when flag is on" do
  Application.put_env(:my_app, :feature_flags, %{beta: true})
  assert Features.beta_enabled?()
end
```

Note: Tests that modify application env should use `async: false` since env is global.

## Property-Based Testing with StreamData

Use property tests when:
- The function has a wide input domain (strings, numbers, lists)
- You can express an invariant that holds for all inputs
- You've already covered specific examples with standard tests

```elixir
use ExUnitProperties

property "sorting is idempotent" do
  check all list <- list_of(integer()) do
    sorted = Enum.sort(list)
    assert Enum.sort(sorted) == sorted
  end
end

property "encoding and decoding are inverse operations" do
  check all data <- map_of(string(:alphanumeric), string(:alphanumeric)) do
    assert data == data |> Jason.encode!() |> Jason.decode!()
  end
end
```

Keep property tests alongside your standard tests. They complement examples, they don't replace them.

## Code Coverage

```bash
# Run tests with coverage report
mix test --cover

# Generate detailed HTML report (with mix_test_watch or similar)
mix test --cover --export-coverage default
mix test.coverage
```

### Coverage philosophy

- Coverage identifies untested code. It does not prove tested code is correct.
- 100% coverage is not a goal. Diminishing returns set in around 85-90%.
- Focus coverage efforts on business logic, not boilerplate.
- Never write tests solely to increase a coverage number.

## test_helper.exs Setup

```elixir
# test/test_helper.exs
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, :manual)
```

For Phoenix apps with additional configuration:

```elixir
# test/test_helper.exs
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, :manual)

# Optional: exclude tags by default
# ExUnit.configure(exclude: [:slow, :external])
```

## Anti-Patterns

**Test files that don't mirror lib/ structure:**
```
# Bad: flat test directory
test/
  user_tests.exs
  order_tests.exs
  everything_else_tests.exs
```
Instead, mirror the lib/ structure exactly.

**Giant support modules that do everything:**
```elixir
# Bad: 500-line TestHelpers module
defmodule MyApp.TestHelpers do
  def create_user(...) ...
  def create_order(...) ...
  def assert_email(...) ...
  def setup_stripe(...) ...
  def build_conn_with_auth(...) ...
end
```
Instead, split into focused modules: `Factory`, `TestAssertions`, `AuthHelpers`.

**Tests that depend on execution order:**
```elixir
# Bad: second test depends on first test's side effect
test "creates user" do
  Accounts.create_user(%{email: "a@b.com"})
end

test "finds created user" do
  assert Accounts.get_by_email("a@b.com")  # Depends on previous test
end
```
Instead, each test sets up its own data.

**Using mix test --seed 0 to fix ordering issues:**
```bash
# Bad: fixing the seed to mask order-dependent tests
mix test --seed 0
```
Instead, fix the tests to be truly independent. Random seed ordering is a feature.
