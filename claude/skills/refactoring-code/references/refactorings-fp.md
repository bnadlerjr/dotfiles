# Refactoring Catalog (Functional Programming)

Refactoring techniques for functional codebases, with Elixir mechanics and examples.

## Extract Pure Function

**Motivation**: Business logic is tangled with side effects (IO, process state, database calls). Pure functions are easier to test, reason about, and compose.

**Mechanics**:
1. Identify the pure computation within the impure function
2. Create a new function in a separate module (or the same module if small)
3. Move the pure computation to the new function
4. Have the original function call the pure function and handle side effects around it
5. Test the pure function independently
6. Test

**Elixir Sketch**:
```elixir
# Before: logic mixed with side effects in GenServer
def handle_call({:checkout, cart}, _from, state) do
  subtotal = Enum.reduce(cart.items, 0, &(&1.price * &1.qty + &2))
  discount = if subtotal > 100, do: subtotal * 0.1, else: 0
  total = subtotal - discount
  Logger.info("Checkout total: #{total}")
  {:reply, {:ok, total}, %{state | last_total: total}}
end

# After: pure function extracted
defmodule Checkout do
  def calculate_total(items) do
    subtotal = Enum.reduce(items, 0, &(&1.price * &1.qty + &2))
    discount = if subtotal > 100, do: subtotal * 0.1, else: 0
    subtotal - discount
  end
end

def handle_call({:checkout, cart}, _from, state) do
  total = Checkout.calculate_total(cart.items)
  Logger.info("Checkout total: #{total}")
  {:reply, {:ok, total}, %{state | last_total: total}}
end
```

## Replace Conditional with Pattern Match

**Motivation**: `if`/`cond` chains obscure the structure of the data being checked. Pattern matching in function heads makes the branching explicit and lets the compiler verify exhaustiveness.

**Mechanics**:
1. Identify the conditional and the value being tested
2. Convert each branch into a separate function clause with a pattern in the head
3. Move the branch body into the corresponding clause
4. Remove the original conditional
5. Test

**Elixir Sketch**:
```elixir
# Before: if/else chain
def describe(shape) do
  if shape.type == :circle do
    "Circle with radius #{shape.radius}"
  else
    if shape.type == :rectangle do
      "Rectangle #{shape.width}x#{shape.height}"
    else
      "Unknown shape"
    end
  end
end

# After: pattern matching in function heads
def describe(%{type: :circle, radius: r}), do: "Circle with radius #{r}"
def describe(%{type: :rectangle, width: w, height: h}), do: "Rectangle #{w}x#{h}"
def describe(_shape), do: "Unknown shape"
```

## Replace Conditional with Function Clauses

**Motivation**: A single function with internal branching (guards, `cond`, `case` on its own arguments) can be split into multiple clauses. Each clause is independently readable and testable.

**Mechanics**:
1. Identify the internal conditional (guard, cond, or case on a parameter)
2. Create a new function clause for each branch
3. Move each branch body into its clause
4. Use guards for conditions that can't be expressed as patterns
5. Remove the original conditional
6. Test

**Elixir Sketch**:
```elixir
# Before: internal branching
def ticket_price(age) do
  cond do
    age < 5 -> 0
    age < 13 -> 10
    age < 65 -> 20
    true -> 15
  end
end

# After: function clauses with guards
def ticket_price(age) when age < 5, do: 0
def ticket_price(age) when age < 13, do: 10
def ticket_price(age) when age < 65, do: 20
def ticket_price(_age), do: 15
```

## Introduce `with` Chain

**Motivation**: Nested `case` expressions matching `{:ok, _}`/`{:error, _}` create a rightward drift. A `with` expression flattens the happy path into a linear sequence.

**Mechanics**:
1. Identify nested `case` expressions that all follow `{:ok, val} -> ... ; {:error, _} -> ...`
2. Replace the outermost `case` with `with`
3. Convert each `{:ok, val} <-` match into a `with` clause
4. Gather all error cases in the `else` block (or rely on pass-through)
5. Test

**Elixir Sketch**:
```elixir
# Before: nested case staircase
def register(params) do
  case validate_params(params) do
    {:ok, validated} ->
      case create_user(validated) do
        {:ok, user} ->
          case send_welcome_email(user) do
            {:ok, _} -> {:ok, user}
            {:error, reason} -> {:error, reason}
          end
        {:error, reason} -> {:error, reason}
      end
    {:error, reason} -> {:error, reason}
  end
end

# After: with chain
def register(params) do
  with {:ok, validated} <- validate_params(params),
       {:ok, user} <- create_user(validated),
       {:ok, _} <- send_welcome_email(user) do
    {:ok, user}
  end
end
```

## Replace Exception with Result Tuple

**Motivation**: Exceptions should signal unexpected failures, not expected outcomes. Using `{:ok, value}`/`{:error, reason}` for expected cases makes error handling explicit and composable with `with`.

**Mechanics**:
1. Identify `try`/`rescue` blocks around expected failure modes
2. Replace the raising function with one that returns `{:ok, value}` or `{:error, reason}`
3. Update callers to pattern match on the result tuple
4. Remove the `try`/`rescue` block
5. Test

**Elixir Sketch**:
```elixir
# Before: exceptions for expected failures
def fetch_config!(key) do
  case System.get_env(key) do
    nil -> raise "Missing config: #{key}"
    val -> val
  end
end

def init do
  try do
    db_url = fetch_config!("DATABASE_URL")
    port = fetch_config!("PORT") |> String.to_integer()
    {:ok, %{db_url: db_url, port: port}}
  rescue
    e in RuntimeError -> {:error, e.message}
  end
end

# After: result tuples
def fetch_config(key) do
  case System.get_env(key) do
    nil -> {:error, {:missing_config, key}}
    val -> {:ok, val}
  end
end

def init do
  with {:ok, db_url} <- fetch_config("DATABASE_URL"),
       {:ok, port_str} <- fetch_config("PORT"),
       {port, ""} <- Integer.parse(port_str) do
    {:ok, %{db_url: db_url, port: port}}
  else
    {:error, reason} -> {:error, reason}
    :error -> {:error, :invalid_port}
  end
end
```

## Compose Pipeline

**Motivation**: Temporary variables that just shuttle data from one transformation to the next add noise. A pipe chain makes the data flow explicit.

**Mechanics**:
1. Identify a sequence of temporary variables where each is the input to the next
2. Check that each function takes its primary input as the first argument
3. Chain the calls with `|>`
4. Remove the temporary variables
5. Test

**Elixir Sketch**:
```elixir
# Before: temporary variables
def format_names(users) do
  active = Enum.filter(users, & &1.active)
  names = Enum.map(active, & &1.name)
  sorted = Enum.sort(names)
  Enum.join(sorted, ", ")
end

# After: pipeline
def format_names(users) do
  users
  |> Enum.filter(& &1.active)
  |> Enum.map(& &1.name)
  |> Enum.sort()
  |> Enum.join(", ")
end
```

## Split Pipeline

**Motivation**: A pipeline with 7+ stages is hard to read in one glance. Extracting named segments turns the pipeline into a readable summary.

**Mechanics**:
1. Identify logical groups of stages within the pipeline
2. Extract each group into a named private function
3. Rebuild the top-level pipeline using the named functions
4. Test

**Elixir Sketch**:
```elixir
# Before: long pipeline
def process(records) do
  records
  |> Enum.filter(&valid?/1)
  |> Enum.reject(&duplicate?/1)
  |> Enum.map(&normalize/1)
  |> Enum.map(&enrich/1)
  |> Enum.group_by(& &1.category)
  |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
  |> Map.new()
  |> Jason.encode!()
end

# After: named segments
def process(records) do
  records
  |> clean_records()
  |> count_by_category()
  |> Jason.encode!()
end

defp clean_records(records) do
  records
  |> Enum.filter(&valid?/1)
  |> Enum.reject(&duplicate?/1)
  |> Enum.map(&normalize/1)
  |> Enum.map(&enrich/1)
end

defp count_by_category(records) do
  records
  |> Enum.group_by(& &1.category)
  |> Enum.map(fn {k, v} -> {k, Enum.count(v)} end)
  |> Map.new()
end
```

## Introduce Struct

**Motivation**: Plain maps offer no compile-time guarantees about their shape. A struct enforces required keys, provides defaults, and enables pattern matching on the struct type.

**Mechanics**:
1. Create a new module with `defstruct`
2. Add `@enforce_keys` for required fields
3. Replace map literals with struct construction (`%MyStruct{}`)
4. Update pattern matches to use the struct pattern
5. Test

**Elixir Sketch**:
```elixir
# Before: naked map
def new_order(user_id, items) do
  %{user_id: user_id, items: items, status: :pending, total: 0}
end

def complete(order) do
  %{order | status: :completed}
end

# After: struct
defmodule Order do
  @enforce_keys [:user_id, :items]
  defstruct [:user_id, :items, status: :pending, total: 0]

  def new(user_id, items) do
    %__MODULE__{user_id: user_id, items: items}
  end

  def complete(%__MODULE__{} = order) do
    %{order | status: :completed}
  end
end
```

## Replace Boolean with Tagged Tuple

**Motivation**: A boolean return discards the reason for failure. Tagged tuples preserve context that callers need for error handling and reporting.

**Mechanics**:
1. Identify a function returning `true`/`false`
2. Change the return to `{:ok, value}` for success and `{:error, reason}` for failure
3. Update all callers to match on the tagged tuple
4. Rename the function to drop the `?` suffix (convention: `?` implies boolean)
5. Test

**Elixir Sketch**:
```elixir
# Before: boolean return
def valid_age?(age) do
  age >= 0 and age <= 150
end

# Caller
if valid_age?(age), do: save(age), else: show_error()

# After: tagged tuple
def validate_age(age) when age >= 0 and age <= 150, do: {:ok, age}
def validate_age(age) when age < 0, do: {:error, :negative_age}
def validate_age(_age), do: {:error, :age_too_large}

# Caller
case validate_age(age) do
  {:ok, age} -> save(age)
  {:error, reason} -> show_error(reason)
end
```

## Extract Module

**Motivation**: A module with too many responsibilities is hard to navigate and change. Splitting it along responsibility boundaries creates focused, cohesive modules.

**Mechanics**:
1. Identify clusters of related functions within the module
2. Create a new module for each cluster
3. Move functions to their new module
4. Update all callers to reference the new module
5. If functions share private helpers, move the helper to the most appropriate module or to a shared utility
6. Test

**Elixir Sketch**:
```elixir
# Before: god module
defmodule Utils do
  def format_currency(amount), do: "$#{:erlang.float_to_binary(amount / 1, decimals: 2)}"
  def format_date(date), do: Calendar.strftime(date, "%Y-%m-%d")
  def validate_email(email), do: String.match?(email, ~r/@/)
  def hash_password(pw), do: Bcrypt.hash_pwd_salt(pw)
end

# After: focused modules
defmodule Formatting do
  def currency(amount), do: "$#{:erlang.float_to_binary(amount / 1, decimals: 2)}"
  def date(date), do: Calendar.strftime(date, "%Y-%m-%d")
end

defmodule Validation do
  def email(email), do: String.match?(email, ~r/@/)
end

defmodule Auth do
  def hash_password(pw), do: Bcrypt.hash_pwd_salt(pw)
end
```

## Replace Anonymous with Named Function

**Motivation**: Anonymous functions obscure intent and can't be reused. Named function references are clearer, testable, and composable.

**Mechanics**:
1. Identify the anonymous function
2. Create a named private function with the same body
3. Replace the anonymous function with `&module.function/arity` or `&function/arity`
4. Test

**Elixir Sketch**:
```elixir
# Before: anonymous functions
def process(items) do
  items
  |> Enum.filter(fn item -> item.active and item.qty > 0 end)
  |> Enum.map(fn item -> %{name: item.name, total: item.price * item.qty} end)
end

# After: named function references
def process(items) do
  items
  |> Enum.filter(&available?/1)
  |> Enum.map(&line_item/1)
end

defp available?(item), do: item.active and item.qty > 0

defp line_item(item), do: %{name: item.name, total: item.price * item.qty}
```

## Separate Business Logic from Process

**Motivation**: GenServer callbacks that contain business logic are hard to test (you need to start a process) and hard to reuse. Extracting logic into a pure companion module makes it independently testable.

**Mechanics**:
1. Create a companion module (e.g., `Order` alongside `OrderServer`)
2. Move business logic from callbacks into pure functions in the companion
3. Have callbacks delegate to the companion, handling only process concerns (replies, state updates)
4. Write unit tests for the companion module (no process needed)
5. Keep integration tests for the GenServer
6. Test

**Elixir Sketch**:
```elixir
# Before: logic in GenServer
defmodule CartServer do
  use GenServer

  def handle_call({:add_item, item}, _from, %{items: items} = state) do
    if Enum.any?(items, &(&1.sku == item.sku)) do
      updated = Enum.map(items, fn
        %{sku: sku} = i when sku == item.sku -> %{i | qty: i.qty + item.qty}
        i -> i
      end)
      {:reply, :ok, %{state | items: updated}}
    else
      {:reply, :ok, %{state | items: [item | items]}}
    end
  end
end

# After: pure companion module
defmodule Cart do
  def add_item(items, item) do
    if Enum.any?(items, &(&1.sku == item.sku)) do
      Enum.map(items, fn
        %{sku: sku} = i when sku == item.sku -> %{i | qty: i.qty + item.qty}
        i -> i
      end)
    else
      [item | items]
    end
  end
end

defmodule CartServer do
  use GenServer

  def handle_call({:add_item, item}, _from, %{items: items} = state) do
    updated_items = Cart.add_item(items, item)
    {:reply, :ok, %{state | items: updated_items}}
  end
end
```

## Flatten with Function Clauses

**Motivation**: Nested conditionals create deep indentation and obscure the decision tree. Multiple function clauses with pattern matching make each case a top-level, independently readable unit.

**Mechanics**:
1. Identify nested conditionals in a function body
2. Determine the patterns that distinguish each branch
3. Create a function clause for each branch with the pattern in the head
4. Use guards where patterns alone aren't sufficient
5. Remove the nested conditionals
6. Test

**Elixir Sketch**:
```elixir
# Before: nested conditionals
def process_payment(payment) do
  if payment.method == :credit_card do
    if payment.amount > 1000 do
      {:ok, :requires_review}
    else
      {:ok, :approved}
    end
  else
    if payment.method == :bank_transfer do
      {:ok, :pending}
    else
      {:error, :unsupported_method}
    end
  end
end

# After: flat function clauses
def process_payment(%{method: :credit_card, amount: amt}) when amt > 1000 do
  {:ok, :requires_review}
end

def process_payment(%{method: :credit_card}) do
  {:ok, :approved}
end

def process_payment(%{method: :bank_transfer}) do
  {:ok, :pending}
end

def process_payment(_payment) do
  {:error, :unsupported_method}
end
```

## Introduce Error Tuple

**Motivation**: Functions that return `nil` on failure lose error context and force callers to check for `nil` everywhere. Returning `{:ok, value}` / `{:error, reason}` makes failure explicit and composable.

**Mechanics**:
1. Identify a function that returns `nil` on failure
2. Change the failure return to `{:error, reason}` with a descriptive atom
3. Change the success return to `{:ok, value}`
4. Update all callers to pattern match on the result tuple
5. Test

**Elixir Sketch**:
```elixir
# Before: nil on failure
def find_user(email) do
  Repo.get_by(User, email: email)
end

# Caller must nil-check
user = find_user(email)
if user do
  do_something(user)
else
  handle_missing()
end

# After: error tuple
def find_user(email) do
  case Repo.get_by(User, email: email) do
    nil -> {:error, :user_not_found}
    user -> {:ok, user}
  end
end

# Caller pattern matches
case find_user(email) do
  {:ok, user} -> do_something(user)
  {:error, :user_not_found} -> handle_missing()
end
```

## Replace Atom with Enum Module

**Motivation**: Scattered atom literals for a set of valid values (statuses, roles, types) are typo-prone and hard to discover. A dedicated module centralizes the valid values and operations.

**Mechanics**:
1. Identify atoms used as a set of valid values across the codebase
2. Create a module that defines the valid values
3. Add a validation function and any related logic
4. Replace scattered atom literals with references to the module
5. Test

**Elixir Sketch**:
```elixir
# Before: scattered atoms
def update_status(order, :pending), do: ...
def update_status(order, :processing), do: ...
def update_status(order, :shipped), do: ...
def update_status(order, :delivered), do: ...
# Typo risk: :shiped, :procesing

# After: enum module
defmodule OrderStatus do
  @statuses [:pending, :processing, :shipped, :delivered]

  def values, do: @statuses

  def valid?(status), do: status in @statuses

  def next(:pending), do: {:ok, :processing}
  def next(:processing), do: {:ok, :shipped}
  def next(:shipped), do: {:ok, :delivered}
  def next(:delivered), do: {:error, :already_delivered}
  def next(invalid), do: {:error, {:invalid_status, invalid}}
end

def update_status(order, status) do
  if OrderStatus.valid?(status) do
    %{order | status: status}
  else
    {:error, :invalid_status}
  end
end
```
