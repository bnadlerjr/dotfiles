# Database Testing

Ecto sandbox, factories, and patterns for testing database-backed code.

## Ecto.Adapters.SQL.Sandbox

The sandbox wraps each test in a database transaction that is rolled back when the test ends. No data persists between tests.

### How it works

1. `test_helper.exs` sets sandbox mode: `Ecto.Adapters.SQL.Sandbox.mode(Repo, :manual)`
2. `DataCase` checks out a connection in `setup`: `Ecto.Adapters.SQL.Sandbox.checkout(Repo)`
3. Each test runs inside a transaction
4. After the test, the transaction is rolled back automatically

### DataCase module

```elixir
defmodule MyApp.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias MyApp.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import MyApp.DataCase
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
end
```

### async: true with sandbox

Each test gets its own database connection and transaction. Tests run in parallel safely.

```elixir
defmodule MyApp.AccountsTest do
  use MyApp.DataCase, async: true

  test "creates a user with valid attributes" do
    assert {:ok, %User{}} = Accounts.create_user(%{name: "Alice", email: "a@b.com"})
  end
end
```

### When you need async: false

Use shared sandbox mode when an external process (not the test process) needs database access:

- **Tests that spawn processes**: If spawned processes make Repo calls
- **Oban job tests**: When testing jobs that run in separate processes

```elixir
defmodule MyApp.CheckoutFlowTest do
  use MyApp.DataCase, async: false  # Shared sandbox mode

  # The shared sandbox allows other processes to use this test's DB connection
end
```

## ExMachina Factories

### Defining factories

```elixir
defmodule MyApp.Factory do
  use ExMachina.Ecto, repo: MyApp.Repo

  def user_factory do
    %MyApp.Accounts.User{
      name: "Jane",
      email: sequence(:email, &"user-#{&1}@example.com"),
      hashed_password: Bcrypt.hash_pwd_salt("password123")
    }
  end

  def order_factory do
    %MyApp.Orders.Order{
      status: :pending,
      user: build(:user),
      total: 0
    }
  end

  def line_item_factory do
    %MyApp.Orders.LineItem{
      sku: sequence(:sku, &"SKU-#{&1}"),
      quantity: 1,
      price: 10_00,
      order: build(:order)
    }
  end
end
```

### build vs insert

```elixir
# build: creates struct in memory, no DB hit
user = build(:user)
user = build(:user, name: "Bob")

# insert: persists to DB via Repo.insert!
user = insert(:user)
user = insert(:user, email: "custom@example.com")

# build_pair / insert_pair: create exactly 2
[u1, u2] = insert_pair(:user)

# build_list / insert_list: create N
users = insert_list(5, :user)
```

### Sequences

Use sequences for fields with unique constraints.

```elixir
def user_factory do
  %User{
    email: sequence(:email, &"user-#{&1}@example.com"),
    username: sequence(:username, &"user_#{&1}")
  }
end
```

### Traits via function parameters

ExMachina doesn't have built-in traits, but you can use factory functions.

```elixir
def admin_factory do
  struct!(user_factory(), %{role: :admin})
end

def confirmed_user_factory do
  struct!(user_factory(), %{confirmed_at: DateTime.utc_now()})
end

# Or use build with overrides:
def user_with_orders_factory do
  user = build(:user)
  orders = build_list(3, :order, user: user)
  %{user | orders: orders}
end
```

### Factory best practices

- **Minimal valid factories**: Include only required fields. Override in tests for what matters.
- **Override only what matters**: `insert(:user, email: "test@example.com")` -- only specify fields relevant to the test.
- **Avoid deeply nested factories**: If a factory requires 5 associated records, the schema is probably too coupled or the test is too broad.

## Testing Ecto Schemas and Changesets

```elixir
describe "changeset/2" do
  test "valid attributes produce a valid changeset" do
    attrs = %{name: "Alice", email: "alice@example.com"}
    changeset = User.changeset(%User{}, attrs)
    assert changeset.valid?
  end

  test "requires email" do
    changeset = User.changeset(%User{}, %{name: "Alice"})
    refute changeset.valid?
    assert %{email: ["can't be blank"]} = errors_on(changeset)
  end

  test "validates email format" do
    changeset = User.changeset(%User{}, %{name: "Alice", email: "not-an-email"})
    refute changeset.valid?
    assert %{email: ["has invalid format"]} = errors_on(changeset)
  end

  test "enforces unique email" do
    insert(:user, email: "taken@example.com")

    assert {:error, changeset} =
             %User{}
             |> User.changeset(%{name: "Bob", email: "taken@example.com"})
             |> Repo.insert()

    assert %{email: ["has already been taken"]} = errors_on(changeset)
  end
end
```

### The errors_on helper

Defined in DataCase (Phoenix generates this):

```elixir
def errors_on(changeset) do
  Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
    Regex.replace(~r"%{(\w+)}", message, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end)
end
```

## Testing Repo Operations

```elixir
describe "list_active_users/0" do
  test "returns only active users" do
    active = insert(:user, status: :active)
    _inactive = insert(:user, status: :inactive)

    assert [returned] = Accounts.list_active_users()
    assert returned.id == active.id
  end

  test "returns empty list when no active users" do
    insert(:user, status: :inactive)
    assert [] = Accounts.list_active_users()
  end
end
```

## Testing Transactions and Multi

```elixir
describe "transfer_funds/3" do
  test "atomically transfers between accounts" do
    from = insert(:account, balance: 100_00)
    to = insert(:account, balance: 50_00)

    assert {:ok, result} = Banking.transfer_funds(from, to, 30_00)
    assert result.from_account.balance == 70_00
    assert result.to_account.balance == 80_00
  end

  test "rolls back when insufficient funds" do
    from = insert(:account, balance: 10_00)
    to = insert(:account, balance: 50_00)

    assert {:error, :insufficient_funds} = Banking.transfer_funds(from, to, 30_00)

    # Verify nothing changed
    assert Repo.get!(Account, from.id).balance == 10_00
    assert Repo.get!(Account, to.id).balance == 50_00
  end
end
```

### Testing Ecto.Multi

```elixir
describe "checkout/1" do
  test "creates order, deducts inventory, and charges payment" do
    product = insert(:product, stock: 10)
    cart = insert(:cart, items: [build(:cart_item, product: product, quantity: 2)])

    assert {:ok, %{order: order, inventory: _inv}} = Checkout.process(cart)
    assert order.status == :confirmed
    assert Repo.get!(Product, product.id).stock == 8
  end

  test "rolls back everything if payment fails" do
    product = insert(:product, stock: 10)
    cart = insert(:cart, items: [build(:cart_item, product: product, quantity: 2)])

    # Configure stub to reject payment
    stub_payment_failure()

    assert {:error, :payment, _reason, _changes} = Checkout.process(cart)
    assert Repo.get!(Product, product.id).stock == 10
  end
end
```

## Data Setup Patterns

### Prefer factories over raw maps

```elixir
# Good: factory with override
user = insert(:user, role: :admin)

# Avoid: raw map insertion
{:ok, user} = Repo.insert(%User{name: "Admin", email: "a@b.com", role: :admin, ...})
```

### Setup blocks for shared context

```elixir
describe "admin operations" do
  setup do
    admin = insert(:user, role: :admin)
    org = insert(:organization, owner: admin)
    %{admin: admin, org: org}
  end

  test "admin can invite members", %{admin: admin, org: org} do
    assert {:ok, _invite} = Orgs.invite_member(org, admin, "new@example.com")
  end

  test "admin can change org settings", %{admin: admin, org: org} do
    assert {:ok, _org} = Orgs.update_settings(org, admin, %{name: "New Name"})
  end
end
```

## Anti-Patterns

**Relying on seed data:**
```elixir
# Bad: assumes a specific user exists from seeds
test "looks up the default admin" do
  admin = Repo.get_by!(User, email: "admin@example.com")  # Where did this come from?
end
```
Instead, insert the data you need in each test or setup block.

**Shared test data across tests:**
```elixir
# Bad: module attribute with DB record
@user insert(:user)  # This runs at compile time, outside the sandbox
```
Instead, use `setup` callbacks for per-test data.

**Overly complex factories:**
```elixir
# Bad: factory that builds an entire object graph
def order_factory do
  user = build(:user)
  org = build(:org, owner: user)
  products = build_list(5, :product, org: org)
  # ... 20 more lines
end
```
Instead, keep factories minimal. Build the graph in the specific test that needs it.

**Testing Ecto internals:**
```elixir
# Bad: testing that Ecto generates the right SQL
test "uses a join" do
  query = Accounts.list_users_query()
  assert inspect(query) =~ "JOIN"
end
```
Instead, test the result: `assert [%User{org: %Org{name: "Acme"}}] = Accounts.list_users_with_org()`.
