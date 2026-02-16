# Assertion Patterns

Comprehensive guide to ExUnit assertions for clear, expressive, and maintainable tests.

## assert and refute Basics

```elixir
# Truthy assertion
assert User.active?(user)

# Falsy assertion
refute User.suspended?(user)

# Equality
assert Orders.total(order) == 42_00

# Inequality
assert Orders.total(order) != 0
```

## Pattern Matching in Assertions

Pattern matching is the most powerful assertion technique in Elixir. Use it to assert on structure while ignoring irrelevant fields.

```elixir
# Match tagged tuples
assert {:ok, %User{name: "Alice"}} = Accounts.create_user(%{name: "Alice", email: "a@b.com"})

# Match partial structure - ignore fields you don't care about
assert {:ok, %Order{status: :confirmed, total: 42_00}} = Orders.confirm(order)

# Match list head
assert [%LineItem{sku: "WIDGET"} | _rest] = Orders.line_items(order)

# Match on map keys
assert %{errors: [_ | _]} = Accounts.validate(%{})

# Pin values in patterns
expected_id = user.id
assert {:ok, %User{id: ^expected_id}} = Accounts.get_user(user.id)
```

## assert_raise

Assert that a function raises a specific exception.

```elixir
test "raises on negative quantity" do
  assert_raise ArgumentError, fn ->
    Orders.add_item(order, %{sku: "A", quantity: -1})
  end
end

test "raises with specific message" do
  assert_raise ArgumentError, "quantity must be positive", fn ->
    Orders.add_item(order, %{sku: "A", quantity: -1})
  end
end

test "raises with message matching pattern" do
  assert_raise Ecto.NoResultsError, ~r/could not find/, fn ->
    Repo.get!(User, -1)
  end
end
```

## Custom Assertion Helpers

Extract repeated assertion patterns into private helper functions for domain clarity.

```elixir
defmodule MyApp.OrdersTest do
  use MyApp.DataCase, async: true

  describe "checkout/1" do
    test "creates confirmed order with correct total" do
      order = insert(:order, items: [build(:item, price: 10_00)])

      assert {:ok, confirmed} = Orders.checkout(order)
      assert_confirmed_order(confirmed, expected_total: 10_00)
    end
  end

  defp assert_confirmed_order(order, expected_total: total) do
    assert %Order{status: :confirmed, total: ^total} = order
    assert order.confirmed_at != nil
    assert order.confirmation_number != nil
  end

  defp assert_validation_error(changeset, field, message) do
    assert {^message, _opts} =
             changeset.errors
             |> Keyword.get(field)
  end
end
```

Keep helpers private (`defp`) and co-located with the test module unless shared across multiple test files. For shared helpers, place them in `test/support/`.

## assert_receive and refute_receive

For testing messages sent to the test process. Essential for PubSub, GenServer callbacks, and async workflows.

```elixir
test "publishes order_confirmed event" do
  Phoenix.PubSub.subscribe(MyApp.PubSub, "orders:#{order.id}")

  Orders.confirm(order)

  assert_receive {:order_confirmed, %Order{id: id}}
  assert id == order.id
end

test "does not publish event for invalid orders" do
  Phoenix.PubSub.subscribe(MyApp.PubSub, "orders:#{order.id}")

  Orders.confirm(%{order | status: :cancelled})

  refute_receive {:order_confirmed, _}
end
```

### Timeout configuration

```elixir
# Default timeout is 100ms. Increase for slow operations:
assert_receive {:batch_complete, _result}, 5_000

# refute_receive waits the full timeout before passing (default 100ms)
# Keep it short to avoid slow tests:
refute_receive {:should_not_happen, _}, 200
```

## Approximate Assertions

### Floats

```elixir
test "calculates tax rate" do
  rate = Tax.effective_rate(order)
  assert_in_delta rate, 0.0825, 0.0001
end
```

### Dates and times within range

```elixir
test "sets confirmed_at to roughly now" do
  {:ok, order} = Orders.confirm(order)

  now = DateTime.utc_now()
  diff = DateTime.diff(now, order.confirmed_at, :second)
  assert diff >= 0 and diff < 2
end
```

### Alternative: compare with tolerance

```elixir
defp assert_recent(datetime, tolerance_seconds \\ 5) do
  diff = DateTime.diff(DateTime.utc_now(), datetime, :second)
  assert diff >= 0 and diff < tolerance_seconds,
    "Expected #{inspect(datetime)} to be within #{tolerance_seconds}s of now, was #{diff}s ago"
end
```

## Assertion Messages

Add custom messages to assertions that might be ambiguous when they fail.

```elixir
test "all line items have positive prices" do
  order = build_order_with_items()

  for item <- order.items do
    assert item.price > 0,
      "Expected positive price for item #{item.sku}, got #{item.price}"
  end
end
```

Use messages when:
- Asserting inside loops (which item failed?)
- The default failure message is unclear
- Testing multiple similar conditions

Skip messages when:
- The assertion is self-explanatory (`assert user.active?`)
- Pattern matching already shows what was expected

## Asserting on Collections

```elixir
# Check membership
assert :admin in User.roles(user)

# Check length
assert length(order.items) == 3

# Check all elements satisfy condition
assert Enum.all?(order.items, & &1.price > 0)

# Check at least one element matches
assert Enum.any?(order.items, &(&1.sku == "WIDGET"))

# Match specific elements (order matters)
assert [%{sku: "A"}, %{sku: "B"}] = Enum.sort_by(items, & &1.sku)

# Use MapSet for order-independent comparison
assert MapSet.new(actual_skus) == MapSet.new(["A", "B", "C"])
```

## Anti-Patterns

**Over-asserting on exact values when structure matters more:**
```elixir
# Bad: brittle, breaks if any field changes
assert result == %Order{id: 1, status: :confirmed, total: 42_00, user_id: 5, ...}
```
Instead, pattern match on the fields you care about:
```elixir
assert %Order{status: :confirmed, total: 42_00} = result
```

**Asserting on string representations:**
```elixir
# Bad: fragile, depends on inspect format
assert inspect(result) =~ "confirmed"
```
Instead, assert on the actual data:
```elixir
assert result.status == :confirmed
```

**Asserting implementation details:**
```elixir
# Bad: tests how, not what
assert length(Repo.all(AuditLog)) == 1
```
Instead, assert on the observable outcome:
```elixir
assert {:ok, _order} = Orders.confirm(order)
assert [%AuditLog{action: :order_confirmed}] = AuditLog.for_order(order.id)
```

**Using assert with side-effect-only functions:**
```elixir
# Bad: assert on :ok return is weak
assert :ok = Notifications.send(user, :welcome)
```
Instead, verify the observable effect:
```elixir
Notifications.send(user, :welcome)
assert_receive {:email_sent, %{to: "alice@example.com", template: :welcome}}
```
