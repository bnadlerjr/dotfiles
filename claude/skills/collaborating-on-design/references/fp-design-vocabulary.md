# FP Design Vocabulary

Reference for functional programming design concepts used at each level of
the design framework. Emphasis on Elixir/OTP but applicable to other FP
languages.

## Component Types

| Component | Purpose | When to Use |
|---|---|---|
| Module | Namespace for related functions | Core organizational unit |
| Context module | Public API boundary (Phoenix) | Domain boundary in Phoenix apps |
| Behaviour | Callback contract for polymorphism | Swappable implementations |
| Protocol | Type-based dispatch | Extending behavior for new types |
| GenServer | Stateful process | Mutable state, serialized access |
| Supervisor | Process lifecycle management | Fault tolerance, restart strategies |
| Agent | Simple state wrapper | Shared state without complex logic |
| Task | One-off async computation | Fire-and-forget or async/await |
| Oban Worker | Background job processing | Persistent async work with retries |
| Plug/Middleware | Request pipeline step | HTTP request transformation |
| Schema | Data structure definition (Ecto) | Database-backed data shapes |

## Responsibility Patterns

### Data Transformation Pipelines

The fundamental FP unit of work: data in, transformed data out.

```elixir
input
|> validate()
|> transform()
|> persist()
|> notify()
```

Each step is a pure function where possible. Side effects are pushed to
the edges (persist, notify).

### Pure Functions

A function is pure when:
- Same inputs always produce same outputs
- No observable side effects
- No dependency on external mutable state

Test: can you call this function in isolation with just its arguments?

### Side-Effect Boundaries

Separate pure computation from side effects:

```
Pure core:     validate, transform, calculate, format
Side effects:  database, HTTP, file I/O, logging, messaging
Boundary:      context module functions that orchestrate both
```

### Functional Core, Imperative Shell

Keep the core logic pure. Push I/O and state to the outer layer.
Context modules serve as the imperative shell in Phoenix.

## Interaction Patterns

| Pattern | Mechanism | When to Use |
|---|---|---|
| Pipe chain | `data \|> f1() \|> f2()` | Sequential transformation |
| Function composition | `f = g \|> h` | Building reusable pipelines |
| Message passing | `send/receive`, `GenServer.call/cast` | Process communication |
| PubSub | `Phoenix.PubSub.broadcast` | Loose coupling between processes |
| Event streaming | `GenStage`, `Broadway` | Backpressure-aware data flow |
| With chain | `with {:ok, x} <- f1()` | Sequential operations that may fail |
| Recursion | Self-referential functions | Iterative data processing |
| Pattern matching | Function clauses, case/cond | Branching on data shape |

### Message Passing

Use when:
- Components run in separate processes
- Work needs to be serialized (GenServer)
- Fault isolation is needed (supervision)

Prefer `call` (synchronous) when caller needs the result.
Prefer `cast` (async) when caller doesn't wait for result.

### With Chains for Error Handling

```elixir
with {:ok, user} <- find_user(id),
     {:ok, order} <- create_order(user, params),
     {:ok, _} <- send_confirmation(order) do
  {:ok, order}
end
```

Each step can fail independently. Pattern matching on tagged tuples
provides clear error propagation.

## Contract Patterns

| Contract Type | Elixir | Haskell | Purpose |
|---|---|---|---|
| Typespec | `@spec f(a) :: b` | Type signature | Document function shape |
| Behaviour | `@callback f(a) :: b` | Typeclass | Define swappable interface |
| Protocol | `defprotocol` | Typeclass | Type-based polymorphism |
| Struct | `defstruct` | `data` / record | Named data shape |
| Changeset | `Ecto.Changeset` | — | Validated data transformation |
| Schema | `Ecto.Schema` | — | Persistent data definition |

### Typespec Design

Define for each public function:
- Input types (parameter specs)
- Return type (including error tuples)
- Use `@type` for complex/reused types

```elixir
@type result :: {:ok, Order.t()} | {:error, Changeset.t()}
@spec create(User.t(), map()) :: result()
```

### Behaviour Design

Define when you need swappable implementations:

```elixir
defmodule NotificationSender do
  @callback send(recipient(), message()) :: :ok | {:error, term()}
end
```

Implementations: `EmailSender`, `SmsSender`, `SlackSender`

### Protocol Design

Define when you need type-based dispatch:

```elixir
defprotocol Renderable do
  @spec render(t()) :: String.t()
  def render(data)
end
```

Implementations for each type that needs rendering.

## Common FP Patterns by Level

### Level 2 — Components

| Pattern | Purpose | Challenge If... |
|---|---|---|
| Context module | Domain API boundary | Only wraps Repo calls without logic |
| GenServer | Stateful process | An Agent or ETS table would suffice |
| Supervisor | Fault tolerance | Only one child, no restart benefit |
| Behaviour | Swappable implementations | Only one implementation exists |

### Level 3 — Interactions

| Pattern | Purpose | Challenge If... |
|---|---|---|
| Pipeline | Sequential data transformation | Only one step in the pipe |
| PubSub | Decoupled event broadcast | Only one subscriber |
| GenStage/Broadway | Backpressure-aware streaming | Volume doesn't warrant it |
| Task.async | Parallel computation | Sequential would be fast enough |

### Level 4 — Contracts

| Pattern | Purpose | Challenge If... |
|---|---|---|
| Typespec | Document function shape | Types add noise without clarity |
| Behaviour | Define callback contract | Only one module implements it |
| Protocol | Type-based dispatch | Only used with one type |
| Schema | Database-backed data | In-memory data needs no schema |

## OTP-Specific Patterns

### Supervision Trees

Design supervision hierarchies based on failure domains:

- **One-for-one**: Children are independent. Restart only the failed child.
- **One-for-all**: Children are interdependent. Restart all on any failure.
- **Rest-for-one**: Later children depend on earlier ones. Restart the
  failed child and everything started after it.

### Process Architecture Questions

Ask during design:
- Does this need its own process, or can it be a function call?
- What happens when this process crashes?
- What is the restart strategy?
- What state does this process hold?
- Can this state live in ETS instead?

### Let It Crash

Design for failure recovery, not failure prevention:
- Supervisors restart failed processes
- Processes should start in a known good state
- Avoid defensive programming inside processes
- Use supervisors for reliability, not try/rescue

## Anti-Patterns to Challenge

| Anti-Pattern | Symptom | Resolution |
|---|---|---|
| Unnecessary GenServer | GenServer with no state or serialization need | Use plain module functions |
| Impure Core | Side effects mixed into transformation logic | Push I/O to boundaries |
| God Module | One module with 30+ public functions | Split by responsibility |
| Process-per-Request | New process for every operation | Use Task or pooling |
| Shared Mutable State | Multiple processes writing same ETS table | Designate a single owner process |
| Over-Supervision | Supervisor tree deeper than needed | Flatten where restart semantics allow |
| Stringly-Typed | Atoms/strings instead of structs | Define structs for domain data |
| Premature Broadway | Broadway/GenStage for low-volume work | Simple Oban jobs or Task.async |
| Callback Soup | Deeply nested with/case chains | Extract named functions, use pipelines |
