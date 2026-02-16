# Core ExUnit Patterns

Foundational ExUnit setup, configuration, and test structure patterns.

## ExUnit.Case Setup

Every test module uses `ExUnit.Case`. For Phoenix apps, use the appropriate case template instead.

```elixir
defmodule MyApp.OrdersTest do
  use ExUnit.Case, async: true

  describe "total/1" do
    test "sums line item prices" do
      order = %{items: [%{price: 10_00}, %{price: 20_00}]}
      assert Orders.total(order) == 30_00
    end
  end
end
```

For Phoenix apps, replace `ExUnit.Case` with `MyApp.DataCase`, `MyApp.ConnCase`, or `MyApp.ChannelCase` as appropriate. These already include `async: true` support.

## Describe and Test Blocks

Use `describe` to group tests by function or scenario. Nest tests inside, never nest `describe` blocks.

```elixir
describe "calculate_discount/2" do
  test "applies percentage discount to subtotal" do
    assert Orders.calculate_discount(100_00, 10) == 90_00
  end

  test "returns original price when discount is zero" do
    assert Orders.calculate_discount(100_00, 0) == 100_00
  end
end

describe "validate_coupon/1" do
  test "accepts valid coupon codes" do
    assert {:ok, _coupon} = Orders.validate_coupon("SAVE20")
  end

  test "rejects expired coupons" do
    assert {:error, :expired} = Orders.validate_coupon("OLD_CODE")
  end
end
```

## Setup Callbacks

### setup

Runs before each test in the describe block (or module if outside describe). Returns a map merged into the test context.

```elixir
describe "membership benefits" do
  setup do
    user = %User{name: "Alice", tier: :gold}
    %{user: user}
  end

  test "gold members get free shipping", %{user: user} do
    assert Orders.shipping_cost(user) == 0
  end

  test "gold members get priority support", %{user: user} do
    assert User.support_tier(user) == :priority
  end
end
```

### setup_all

Runs once before all tests in the module. Use for expensive, read-only setup. Cannot use Ecto sandbox (it's per-test).

```elixir
setup_all do
  config = MyApp.Config.load_test_defaults()
  %{config: config}
end
```

### on_exit

Register cleanup that runs after the test, even if the test fails. Defined inside `setup` or `test`.

```elixir
setup do
  tmp_dir = Path.join(System.tmp_dir!(), "myapp_test_#{:rand.uniform(1000)}")
  File.mkdir_p!(tmp_dir)

  on_exit(fn ->
    File.rm_rf!(tmp_dir)
  end)

  %{tmp_dir: tmp_dir}
end
```

## Tags

Tags filter and configure test execution.

### Module-level tags

```elixir
@moduletag :integration

# All tests in this module get the :integration tag
```

### Test-level tags

```elixir
@tag :slow
test "processes large batch" do
  # ...
end

@tag timeout: 120_000
test "long-running import" do
  # ...
end
```

### Filtering with tags

```bash
# Run only integration tests
mix test --only integration

# Exclude slow tests
mix test --exclude slow

# Run a specific tag value
mix test --only feature:checkout
```

### Common tag patterns

```elixir
# Skip in CI
@tag :skip

# Mark as work-in-progress
@tag :wip

# Increase timeout for slow tests
@tag timeout: 60_000

# Custom categorization
@tag feature: :checkout
```

## async: true vs async: false

**Default to `async: true`**. Tests run in parallel, each in its own process.

Use `async: false` only when:
- The test module needs shared Ecto sandbox mode (e.g., tests that spawn processes making Repo calls)
- Tests touch global mutable state (ETS tables, application env, named processes)
- Tests modify the filesystem at shared paths

```elixir
# Default: parallel execution
use ExUnit.Case, async: true

# Only when required: serial execution
use MyApp.DataCase, async: false
```

## Test Naming Conventions

Name tests by the behavior they verify, not the implementation.

```elixir
# Good: describes behavior
test "expired subscriptions cannot place orders"
test "returns error when email is already taken"
test "sends welcome email after registration"

# Bad: describes implementation
test "calls Mailer.send/1"
test "inserts into users table"
test "sets the status field to expired"
```

## Capture Log and Capture IO

### capture_log

Captures Logger output during a test. Useful for asserting log messages or suppressing expected log noise.

```elixir
import ExUnit.CaptureLog

test "logs warning when inventory is low" do
  log =
    capture_log(fn ->
      Inventory.check_stock(%{sku: "WIDGET", quantity: 2})
    end)

  assert log =~ "Low inventory warning"
  assert log =~ "WIDGET"
end
```

### capture_io

Captures IO output (stdout).

```elixir
import ExUnit.CaptureIO

test "prints report to stdout" do
  output =
    capture_io(fn ->
      Reports.print_summary(%{total: 42})
    end)

  assert output =~ "Total: 42"
end
```

### Suppressing expected log output

Use `@tag :capture_log` to silently capture all log output for a test or module, keeping test output clean.

```elixir
@tag :capture_log
test "handles connection failure gracefully" do
  # This logs an error internally, but we don't want it in test output
  assert {:error, :connection_refused} = Client.connect("bad_host")
end
```

## Running Specific Tests

```bash
# Run a single file
mix test test/my_app/orders_test.exs

# Run a specific test by line number
mix test test/my_app/orders_test.exs:42

# Run with a seed for reproducibility
mix test --seed 12345

# Run only previously failed tests
mix test --failed

# Increase max concurrent cases
mix test --max-cases 16

# Run with tracing (show test names as they run)
mix test --trace
```

## Anti-Patterns

**Sharing state between tests via module attributes:**
```elixir
# Bad: mutable state shared across tests
@users []
test "first test" do
  @users = [build_user()]  # This doesn't even work in Elixir
end
```
Instead, use `setup` callbacks to create fresh data for each test.

**Using setup_all for mutable data:**
```elixir
# Bad: inserting DB records in setup_all
setup_all do
  user = insert(:user)  # This row persists across tests
  %{user: user}
end
```
Instead, use `setup` with per-test sandbox transactions.

**Nested describe blocks:**
```elixir
# Bad: deeply nested describes
describe "checkout" do
  describe "with valid cart" do
    describe "and gold membership" do
      # Too deep
    end
  end
end
```
Instead, flatten to a single describe with descriptive test names: `test "checkout with valid cart and gold membership applies discount"`.
