# Sociable Testing Philosophy

How and why to write sociable tests in Elixir, and when stubbing is appropriate.

## What Are Sociable Tests?

Sociable tests exercise a unit (function or module) together with its real collaborators. The unit under test is not isolated from the modules it calls.

```elixir
# Sociable: Orders.checkout/1 calls real Inventory and Pricing modules
test "checkout deducts inventory and calculates total" do
  product = insert(:product, stock: 10, price: 25_00)
  order = insert(:order, items: [build(:line_item, product: product, quantity: 2)])

  assert {:ok, confirmed} = Orders.checkout(order)
  assert confirmed.total == 50_00
  assert Inventory.stock(product.id) == 8
end
```

Contrast with an isolated test that stubs every collaborator:

```elixir
# Isolated: stubs everything, tests very little real behavior
test "checkout calls inventory and pricing" do
  # Multiple stubs just to test glue code
  stub(InventoryMock, :deduct, fn _, _ -> :ok end)
  stub(PricingMock, :calculate, fn _ -> 50_00 end)

  assert {:ok, _} = Orders.checkout(order)
end
```

## Why Sociable Tests Win

**Catch integration bugs.** Mismatched function signatures, wrong argument order, or incorrect data shapes between modules are caught immediately.

**Survive refactors.** Rename an internal module, change a function signature, or restructure code -- sociable tests keep passing as long as the behavior is preserved.

**Test real behavior.** You're testing what actually happens, not a simulated version.

**Less test code.** No mock setup boilerplate, no verification of call counts, no stub return values to maintain.

## When to Use Real Collaborators

Use real modules for:
- Your own context modules (`Accounts`, `Orders`, `Inventory`)
- Ecto Repo operations (the sandbox handles isolation)
- Pure function modules (calculations, transformations, validations)
- Phoenix contexts and schemas
- Internal GenServers (use `start_supervised` for lifecycle management)

## When Stubbing Is Appropriate

Stub only at true system boundaries -- places where your application talks to the outside world:

- External HTTP APIs (use Bypass or Req.Test)
- Email delivery services (use a behaviour + stub)
- SMS/push notification providers
- Payment gateways
- System clock (`DateTime.utc_now/0` -- inject a clock function or module)
- File system operations in cloud storage
- Message queues (external brokers)

## Stubs vs Mocks

**Stubs** provide canned answers. They implement a behaviour and return predetermined data.

**Mocks** verify interactions. They assert that specific functions were called with specific arguments in a specific order.

**Prefer stubs.** They test what your code does with the response, not whether it made the right call. This makes tests more resilient to refactoring.

```elixir
# Stub: provides canned data, tests behavior
defmodule MyApp.WeatherAPI.Stub do
  @behaviour MyApp.WeatherAPI

  @impl true
  def fetch_forecast(city) do
    case city do
      "Portland" -> {:ok, %Forecast{temp_f: 55, condition: :rainy}}
      "Phoenix" -> {:ok, %Forecast{temp_f: 110, condition: :sunny}}
      _ -> {:error, :city_not_found}
    end
  end
end
```

```elixir
# Usage in config/test.exs
config :my_app, :weather_api, MyApp.WeatherAPI.Stub
```

## Behaviours as the Dependency Injection Mechanism

Define a behaviour for any external dependency you need to stub.

### Step 1: Define the behaviour

```elixir
defmodule MyApp.PaymentGateway do
  @callback charge(amount :: integer(), card_token :: String.t()) ::
              {:ok, %{transaction_id: String.t()}} | {:error, atom()}

  @callback refund(transaction_id :: String.t(), amount :: integer()) ::
              {:ok, %{refund_id: String.t()}} | {:error, atom()}
end
```

### Step 2: Implement the real module

```elixir
defmodule MyApp.PaymentGateway.Stripe do
  @behaviour MyApp.PaymentGateway

  @impl true
  def charge(amount, card_token) do
    # Real Stripe API call
  end

  @impl true
  def refund(transaction_id, amount) do
    # Real Stripe API call
  end
end
```

### Step 3: Create a stub for tests

```elixir
defmodule MyApp.PaymentGateway.Stub do
  @behaviour MyApp.PaymentGateway

  @impl true
  def charge(_amount, _card_token) do
    {:ok, %{transaction_id: "txn_test_#{System.unique_integer([:positive])}"}}
  end

  @impl true
  def refund(_transaction_id, _amount) do
    {:ok, %{refund_id: "ref_test_#{System.unique_integer([:positive])}"}}
  end
end
```

### Step 4: Configure per environment

```elixir
# config/config.exs
config :my_app, :payment_gateway, MyApp.PaymentGateway.Stripe

# config/test.exs
config :my_app, :payment_gateway, MyApp.PaymentGateway.Stub
```

### Step 5: Use the configured module

```elixir
defmodule MyApp.Orders do
  def checkout(order) do
    gateway = Application.fetch_env!(:my_app, :payment_gateway)

    case gateway.charge(order.total, order.card_token) do
      {:ok, %{transaction_id: txn_id}} ->
        order
        |> Ecto.Changeset.change(status: :confirmed, transaction_id: txn_id)
        |> Repo.update()

      {:error, reason} ->
        {:error, :payment_failed, reason}
    end
  end
end
```

## Functional Core / Imperative Shell

The most powerful pattern for testable Elixir code. Pure business logic in the core, side effects at the boundaries.

```elixir
# Functional core: pure, easy to test sociably
defmodule MyApp.Pricing do
  def calculate(items, discount_code \\ nil) do
    subtotal = Enum.reduce(items, 0, &(&1.price * &1.quantity + &2))
    discount = apply_discount(subtotal, discount_code)
    tax = calculate_tax(subtotal - discount)

    %{subtotal: subtotal, discount: discount, tax: tax, total: subtotal - discount + tax}
  end

  defp apply_discount(subtotal, nil), do: 0
  defp apply_discount(subtotal, "SAVE20"), do: trunc(subtotal * 0.20)
  defp apply_discount(_subtotal, _unknown), do: 0

  defp calculate_tax(taxable), do: trunc(taxable * 0.0825)
end
```

```elixir
# Imperative shell: orchestrates side effects
defmodule MyApp.Checkout do
  def process(order) do
    pricing = Pricing.calculate(order.items, order.discount_code)
    gateway = Application.fetch_env!(:my_app, :payment_gateway)

    with {:ok, charge} <- gateway.charge(pricing.total, order.card_token),
         {:ok, order} <- save_order(order, pricing, charge) do
      Notifications.send_confirmation(order)
      {:ok, order}
    end
  end
end
```

Test the functional core sociably with no stubs. Test the imperative shell with stubs only for the true external boundary (payment gateway).

## Anti-Patterns

**Mocking the module under test:**
```elixir
# Bad: what are you even testing?
stub(OrdersMock, :checkout, fn _ -> {:ok, %Order{}} end)
assert {:ok, _} = OrdersMock.checkout(order)
```
Instead, test the real module with real collaborators.

**Mocking internal modules:**
```elixir
# Bad: Pricing is your own code, not an external boundary
stub(PricingMock, :calculate, fn _ -> 42_00 end)
assert {:ok, order} = Orders.checkout(order)
```
Instead, let `Orders.checkout/1` call real `Pricing.calculate/1`.

**Verifying call counts:**
```elixir
# Bad: testing how, not what
verify!(InventoryMock, :deduct, 1)
```
Instead, assert on the observable outcome: check that inventory was actually deducted.

**Creating mocks for pure functions:**
```elixir
# Bad: why mock a pure calculation?
stub(TaxCalculatorMock, :calculate, fn amount -> trunc(amount * 0.08) end)
```
Instead, call the real tax calculator. It's fast, deterministic, and side-effect-free.
