# Code Smells (Functional Programming)

Elixir-focused functional programming smells. Each smell includes detection criteria, evidence, recommended refactorings, and a before/after sketch.

## Side Effect Smells

### Impure Functions
**Detection**: Function modifies external state, does IO, or depends on mutable state when it doesn't need to.
**Evidence**: Function reads/writes process dictionary, sends messages as a side effect, modifies ETS without it being the function's stated purpose.
**Refactorings**: Extract Pure Function, Push Side Effects to Boundary

```elixir
# Smell: business logic mixed with side effects
def calculate_discount(order) do
  discount = order.total * 0.1
  Logger.info("Calculated discount: #{discount}")
  :ets.insert(:discount_cache, {order.id, discount})
  discount
end

# Clean: pure calculation, caller handles effects
def calculate_discount(order) do
  order.total * 0.1
end
```

### Hidden Side Effects
**Detection**: Function name suggests purity but performs IO or state mutation.
**Evidence**: Function named `calculate_*`, `transform_*`, `build_*` but calls `IO.puts`, sends messages, or writes to database.
**Refactorings**: Rename to Reveal Side Effect, Extract Pure Function

```elixir
# Smell: name says "build" but writes to DB
def build_report(data) do
  report = Enum.map(data, &format_row/1)
  Repo.insert!(%Report{rows: report})
  report
end

# Clean: separate pure building from persistence
def build_report(data) do
  Enum.map(data, &format_row/1)
end

def save_report!(report) do
  Repo.insert!(%Report{rows: report})
end
```

## Data & Type Smells

### Primitive Obsession (FP)
**Detection**: Using raw strings, integers, or atoms for domain concepts instead of structured types.
**Evidence**: Passing raw strings for emails, phone numbers; using integers for money; atoms where a struct would be clearer.
**Refactorings**: Introduce Value Struct, Replace Atom with Tagged Tuple

```elixir
# Smell: primitives everywhere
def process_order(order_id, "pending", 1500) do
  # What is 1500? Cents? Dollars? What currency?
end

# Clean: domain types
def process_order(order_id, :pending, %Money{amount: 1500, currency: :USD}) do
  # Self-documenting
end
```

### Boolean Blindness
**Detection**: Functions returning `true`/`false` where the caller immediately matches on the result; boolean parameters that change behavior.
**Evidence**: `if authorized?(user), do: ...` pattern where the reason for failure is lost.
**Refactorings**: Replace Boolean with Tagged Tuple, Replace Boolean Parameter with Separate Functions

```elixir
# Smell: boolean return loses context
def authorized?(user) do
  cond do
    user.banned -> false
    user.role not in [:admin, :editor] -> false
    true -> true
  end
end

# Usage loses the "why"
if authorized?(user), do: perform_action(), else: deny()

# Clean: tagged tuple preserves reason
def authorize(user) do
  cond do
    user.banned -> {:error, :banned}
    user.role not in [:admin, :editor] -> {:error, :insufficient_role}
    true -> {:ok, user}
  end
end

# Usage can act on the reason
case authorize(user) do
  {:ok, _user} -> perform_action()
  {:error, :banned} -> show_banned_message()
  {:error, :insufficient_role} -> show_permission_error()
end
```

### Stringly-Typed Data
**Detection**: Using strings where atoms, structs, or enums should be used.
**Evidence**: String comparisons like `status == "active"`, string keys in maps where atom keys would work.
**Refactorings**: Replace String with Atom, Introduce Enum Module

```elixir
# Smell: stringly-typed
def activate(user) do
  %{user | status: "active", role: "admin"}
end

def active?(user), do: user.status == "active"

# Clean: atoms
def activate(user) do
  %{user | status: :active, role: :admin}
end

def active?(user), do: user.status == :active
```

### Naked Maps
**Detection**: Using plain maps for structured domain data instead of structs.
**Evidence**: `map["key"]` or `map.key` access patterns on domain data, pattern matching on arbitrary map keys, no struct enforcement.
**Refactorings**: Introduce Struct, Introduce Typed Struct

```elixir
# Smell: naked map, no enforced shape
def create_user(params) do
  user = %{name: params["name"], email: params["email"], role: "user"}
  # No compile-time key checking, typos silently produce nil
  send_welcome(user[:emial])  # Typo goes unnoticed
end

# Clean: struct with enforced keys
defmodule User do
  @enforce_keys [:name, :email]
  defstruct [:name, :email, role: :user]
end

def create_user(params) do
  %User{name: params["name"], email: params["email"]}
end
```

## Control Flow Smells

### Missing Pattern Match
**Detection**: Using `if/cond` where pattern matching would be clearer.
**Evidence**: `if Map.get(map, :key)`, `cond` chains testing same variable, `case x do` with only `true`/`false` branches.
**Refactorings**: Replace Conditional with Pattern Match, Decompose into Function Clauses

```elixir
# Smell: conditional chain
def handle_response(response) do
  if response.status == 200 do
    {:ok, response.body}
  else
    if response.status == 404 do
      {:error, :not_found}
    else
      {:error, :server_error}
    end
  end
end

# Clean: pattern matching
def handle_response(%{status: 200, body: body}), do: {:ok, body}
def handle_response(%{status: 404}), do: {:error, :not_found}
def handle_response(%{status: _}), do: {:error, :server_error}
```

### Nested Case Expressions
**Detection**: 3+ levels of `case` nesting, `with` chains longer than 5 clauses.
**Evidence**: Deep indentation from nested `case`/`with` blocks, hard to follow the happy path.
**Refactorings**: Extract Function, Introduce `with` Chain, Flatten with Function Clauses

```elixir
# Smell: nested cases
def create_order(params) do
  case validate(params) do
    {:ok, validated} ->
      case find_user(validated.user_id) do
        {:ok, user} ->
          case check_inventory(validated.items) do
            {:ok, items} ->
              save_order(user, items)
            {:error, reason} ->
              {:error, reason}
          end
        {:error, reason} ->
          {:error, reason}
      end
    {:error, reason} ->
      {:error, reason}
  end
end

# Clean: with chain
def create_order(params) do
  with {:ok, validated} <- validate(params),
       {:ok, user} <- find_user(validated.user_id),
       {:ok, items} <- check_inventory(validated.items) do
    save_order(user, items)
  end
end
```

### Exception for Control Flow
**Detection**: Using `raise`/`rescue` for expected outcomes instead of `{:ok, value}`/`{:error, reason}`.
**Evidence**: `try/rescue` around expected failures like not-found or validation; `!` functions used where error tuples would be appropriate.
**Refactorings**: Replace Exception with Result Tuple, Introduce Error Tuple

```elixir
# Smell: exceptions for expected cases
def get_user!(id) do
  try do
    Repo.get!(User, id)
  rescue
    Ecto.NoResultsError -> nil
  end
end

# Clean: result tuples for expected outcomes
def get_user(id) do
  case Repo.get(User, id) do
    nil -> {:error, :not_found}
    user -> {:ok, user}
  end
end
```

### Callback Spaghetti
**Detection**: 3+ nested `fn -> fn -> fn ->` patterns, `Enum.map` with a 10+ line anonymous function.
**Evidence**: Complex callback chains, deeply nested anonymous functions that are hard to read.
**Refactorings**: Extract Named Function, Replace Anonymous with Named Function Reference

```elixir
# Smell: deeply nested anonymous functions
Enum.map(orders, fn order ->
  Enum.map(order.items, fn item ->
    Enum.reduce(item.discounts, item.price, fn discount, acc ->
      acc - (acc * discount.percentage / 100)
    end)
  end)
end)

# Clean: named functions
def discounted_prices(orders) do
  Enum.map(orders, &item_prices/1)
end

defp item_prices(order) do
  Enum.map(order.items, &apply_discounts/1)
end

defp apply_discounts(item) do
  Enum.reduce(item.discounts, item.price, &apply_discount/2)
end

defp apply_discount(discount, price) do
  price - (price * discount.percentage / 100)
end
```

## Pipeline & Composition Smells

### Broken Pipeline
**Detection**: Temporary variables interrupting a natural data flow.
**Evidence**: `temp = Enum.map(...)`, `result = Enum.filter(temp, ...)` where a pipeline would be cleaner.
**Refactorings**: Compose Pipeline, Introduce Pipe Operator

```elixir
# Smell: broken pipeline
def active_user_emails(users) do
  active = Enum.filter(users, & &1.active)
  verified = Enum.filter(active, & &1.email_verified)
  emails = Enum.map(verified, & &1.email)
  Enum.sort(emails)
end

# Clean: composed pipeline
def active_user_emails(users) do
  users
  |> Enum.filter(& &1.active)
  |> Enum.filter(& &1.email_verified)
  |> Enum.map(& &1.email)
  |> Enum.sort()
end
```

### Pipeline Too Long
**Detection**: Single pipeline with 7+ stages that is hard to follow, especially with unrelated transformations mixed in.
**Evidence**: Pipeline spanning many lines doing too many things at once.
**Refactorings**: Extract Function (name a pipeline segment), Split Pipeline

```elixir
# Smell: pipeline too long
def generate_report(orders) do
  orders
  |> Enum.filter(&(&1.status == :completed))
  |> Enum.reject(&(&1.total == 0))
  |> Enum.map(&enrich_with_customer/1)
  |> Enum.map(&calculate_tax/1)
  |> Enum.group_by(& &1.region)
  |> Enum.map(fn {region, orders} -> {region, sum_totals(orders)} end)
  |> Enum.sort_by(fn {_region, total} -> total end, :desc)
  |> Enum.map(&format_row/1)
  |> Enum.join("\n")
end

# Clean: named segments
def generate_report(orders) do
  orders
  |> billable_orders()
  |> summarize_by_region()
  |> format_as_text()
end

defp billable_orders(orders) do
  orders
  |> Enum.filter(&(&1.status == :completed))
  |> Enum.reject(&(&1.total == 0))
  |> Enum.map(&enrich_with_customer/1)
  |> Enum.map(&calculate_tax/1)
end

defp summarize_by_region(orders) do
  orders
  |> Enum.group_by(& &1.region)
  |> Enum.map(fn {region, orders} -> {region, sum_totals(orders)} end)
  |> Enum.sort_by(fn {_region, total} -> total end, :desc)
end

defp format_as_text(rows) do
  rows
  |> Enum.map(&format_row/1)
  |> Enum.join("\n")
end
```

### Wrong Pipe Direction
**Detection**: Functions that don't accept the piped value as first argument, requiring awkward workarounds.
**Evidence**: `|> then(&some_func(other_arg, &1))` or `|> (fn x -> f(a, x, b) end).()`.
**Refactorings**: Reorder Parameters, Introduce Wrapper Function

```elixir
# Smell: awkward pipe workarounds
def process(data) do
  data
  |> transform()
  |> then(&String.pad_leading(&1, 10, "0"))
  |> then(&Map.put(result, :value, &1))
end

# Clean: wrapper functions with pipe-friendly signatures
def process(data) do
  data
  |> transform()
  |> pad_value(10, "0")
  |> wrap_in_result()
end

defp pad_value(value, count, padding) do
  String.pad_leading(value, count, padding)
end

defp wrap_in_result(value) do
  Map.put(%{}, :value, value)
end
```

## Process & Concurrency Smells

### Fat GenServer
**Detection**: GenServer that mixes business logic with process management.
**Evidence**: `handle_call`/`handle_cast` callbacks containing complex business logic rather than delegating to pure functions.
**Refactorings**: Extract Pure Module, Separate Business Logic from Process

```elixir
# Smell: fat GenServer
defmodule OrderServer do
  use GenServer

  def handle_call({:place_order, items}, _from, state) do
    # 30 lines of validation, pricing, inventory checks...
    subtotal = Enum.reduce(items, 0, &(&1.price * &1.qty + &2))
    tax = subtotal * state.tax_rate
    total = subtotal + tax
    # ... more business logic in the callback
    {:reply, {:ok, total}, state}
  end
end

# Clean: delegate to pure module
defmodule OrderServer do
  use GenServer

  def handle_call({:place_order, items}, _from, state) do
    case Order.place(items, state.tax_rate) do
      {:ok, result} -> {:reply, {:ok, result}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end
end

defmodule Order do
  def place(items, tax_rate) do
    with {:ok, validated} <- validate(items),
         {:ok, total} <- calculate_total(validated, tax_rate) do
      {:ok, total}
    end
  end
end
```

### Synchronous Bottleneck
**Detection**: Using `GenServer.call` where `cast` or direct function calls would suffice.
**Evidence**: `call` used for fire-and-forget operations, all interactions with a GenServer are synchronous.
**Refactorings**: Replace Call with Cast, Replace GenServer with Module

```elixir
# Smell: synchronous call for fire-and-forget
def log_event(server, event) do
  GenServer.call(server, {:log, event})  # Caller blocks waiting for :ok
end

def handle_call({:log, event}, _from, state) do
  new_state = append_event(state, event)
  {:reply, :ok, new_state}
end

# Clean: cast for fire-and-forget
def log_event(server, event) do
  GenServer.cast(server, {:log, event})  # Caller continues immediately
end

def handle_cast({:log, event}, state) do
  {:noreply, append_event(state, event)}
end
```

### Missing Supervision
**Detection**: Processes started without proper supervision.
**Evidence**: Bare `spawn`, `Task.start` without a supervisor, GenServer started outside supervision tree.
**Refactorings**: Introduce Task.Supervisor, Add to Supervision Tree

```elixir
# Smell: unsupervised processes
def process_async(items) do
  Enum.each(items, fn item ->
    spawn(fn -> do_work(item) end)
  end)
end

# Clean: supervised tasks
def process_async(items) do
  Enum.each(items, fn item ->
    Task.Supervisor.start_child(MyApp.TaskSupervisor, fn ->
      do_work(item)
    end)
  end)
end
```

## Module & Organization Smells

### God Module
**Detection**: Module with too many responsibilities.
**Evidence**: Module > 300 lines, unrelated public functions, function clusters that don't interact.
**Refactorings**: Extract Module, Split by Responsibility

```elixir
# Smell: god module doing everything
defmodule MyApp.Helpers do
  def format_currency(amount), do: ...
  def format_date(date), do: ...
  def send_email(to, subject, body), do: ...
  def validate_email(email), do: ...
  def generate_token(), do: ...
  def hash_password(password), do: ...
  # ... 40 more unrelated functions
end

# Clean: split by responsibility
defmodule MyApp.Formatting do
  def currency(amount), do: ...
  def date(date), do: ...
end

defmodule MyApp.Email do
  def send(to, subject, body), do: ...
  def validate_address(email), do: ...
end

defmodule MyApp.Auth do
  def generate_token(), do: ...
  def hash_password(password), do: ...
end
```

### Chatty Context
**Detection**: Ecto context module that has become a dumping ground.
**Evidence**: Context module > 500 lines, functions for unrelated schemas, mixed query and business logic.
**Refactorings**: Extract Context, Split Context by Aggregate

```elixir
# Smell: chatty context
defmodule MyApp.Accounts do
  # User CRUD (lines 1-80)
  def create_user(attrs), do: ...
  def get_user(id), do: ...
  def update_user(user, attrs), do: ...

  # Authentication (lines 81-200)
  def authenticate(email, password), do: ...
  def generate_session_token(user), do: ...
  def verify_session_token(token), do: ...

  # Team management (lines 201-400)
  def create_team(attrs), do: ...
  def add_member(team, user), do: ...
  def remove_member(team, user), do: ...

  # Billing (lines 401-600)
  def create_subscription(user, plan), do: ...
  def cancel_subscription(user), do: ...
  # ... keeps growing
end

# Clean: split by aggregate
defmodule MyApp.Accounts.Users do ... end
defmodule MyApp.Accounts.Authentication do ... end
defmodule MyApp.Accounts.Teams do ... end
defmodule MyApp.Billing do ... end
```

### Leaky Abstraction
**Detection**: Internal implementation details exposed through public API.
**Evidence**: Caller needs to know internal data structures, Ecto queries leaked outside contexts, schema details used in controllers/views.
**Refactorings**: Hide Implementation, Introduce Public API Struct

```elixir
# Smell: leaky abstraction
defmodule MyAppWeb.UserController do
  def index(conn, params) do
    # Controller knows about Ecto query details
    users =
      from(u in MyApp.Accounts.User,
        where: u.active == true,
        join: p in assoc(u, :profile),
        preload: [profile: p]
      )
      |> Repo.all()

    render(conn, :index, users: users)
  end
end

# Clean: context hides implementation
defmodule MyApp.Accounts do
  def list_active_users do
    from(u in User,
      where: u.active == true,
      join: p in assoc(u, :profile),
      preload: [profile: p]
    )
    |> Repo.all()
  end
end

defmodule MyAppWeb.UserController do
  def index(conn, _params) do
    users = Accounts.list_active_users()
    render(conn, :index, users: users)
  end
end
```

## Severity Guidelines

**Critical**: Blocking current work or causing bugs
- Fat GenServer with business logic bugs
- Missing Supervision causing silent failures

**High**: Significantly impedes understanding or change
- God Module / Chatty Context
- Nested Case Expressions (3+ levels)
- Hidden Side Effects in core logic

**Medium**: Noticeable but manageable
- Broken Pipeline
- Boolean Blindness
- Naked Maps for domain data

**Low**: Minor issues, fix opportunistically
- Pipeline Too Long
- Stringly-Typed Data
- Callback Spaghetti
