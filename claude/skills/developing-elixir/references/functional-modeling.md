# Functional Domain Modeling Reference

Expert guidance for applying Domain-Driven Design principles to create robust, type-safe domain models in Elixir.

## Quick Start

```elixir
# Parse, don't validate - transform at boundaries
defmodule Money do
  defstruct [:amount, :currency]

  def parse(amount, currency) when is_number(amount) and amount >= 0 do
    {:ok, %__MODULE__{amount: amount, currency: currency}}
  end
  def parse(_, _), do: {:error, :invalid_money}

  # Once parsed, always valid - no runtime checks needed
  def add(%__MODULE__{currency: c} = a, %__MODULE__{currency: c} = b) do
    %__MODULE__{amount: a.amount + b.amount, currency: c}
  end
end
```

## Core Philosophy

- Make illegal states unrepresentable
- Use types as documentation
- Parse instead of validating
- Treat errors as values
- Prefer total functions
- Push side effects to the Lifecycle and Workers layers

## Layers

Six layers, from *Designing Elixir Systems with OTP* (Tate and Gray). The mnemonic is
"Do Fun Things with Big Loud Workerbees".

| Layer | Holds | Purity |
|-------|-------|--------|
| Data | Structs and types | pure |
| Functions | Transformations over that data | pure, total |
| Tests | Coverage of Data and Functions | pure |
| Boundary | Public interface, validation, contracts | pure, but answers "no" |
| Lifecycle | Supervision, startup, child specs | effectful |
| Workers | Processes doing concurrent work | effectful |

Three rules follow from the table.

- **Uncertainty and I/O are separate layers.** `{:ok, v} | {:error, r}` records a
  question that could be answered "no". That is Boundary work, and it needs no I/O.
  A pure function that rejects an illegal move belongs at Boundary, not in Functions
  and not in Workers.
- **Functions stay total and type-preserving.** A step that transforms state should be
  `T -> T`, so it pipes: `state |> step_a() |> step_b()`. A `with {:ok, x} <- ...`
  spine as the backbone of a Functions module means the parsing belongs one layer out,
  at Boundary.
- **Carry a wrapper, do not compose over it.** Threading a changeset
  `changeset -> changeset` is fine. The indicator is data along for the ride. Forking
  the pipeline on `valid?` is Boundary control flow that leaked inward.

Two cautions.

- This is a layer inventory, not a write order. Under TDD, Functions and Tests
  interleave.
- Most components stop at Boundary. A Phoenix context has Data, Functions, Tests and
  Boundary, and no Lifecycle or Workers. Add those only when the requirements in
  [otp-patterns](otp-patterns.md) justify a process.

## Progressive Modeling Approach

Advocate for incremental domain modeling:
1. Start with primitives and maps
2. Introduce structs when structure is needed
3. Add type specs when interfaces stabilize
4. Extract value objects when rules emerge
5. Build smart constructors when invariants are clear
6. Create domain modules when concepts are proven

## Anti-Pattern Detection

Actively warn against:
- Creating types for single-use values
- Building generic solutions for specific problems
- Introducing abstractions without duplication
- Modeling future requirements
- Complex type hierarchies too early
- Unnecessary indirection

## When to Model Immediately

Recommend immediate modeling for:
- Core domain invariants that tests explicitly check
- Security boundaries (user input parsing)
- Money, time, or other error-prone domains
- External API contracts
- When test names include domain terms

## Domain Modeling Principles

When the time is right for modeling, apply:

### Parse, Don't Validate
Transform unstructured data into guaranteed-valid types at the Boundary layer.

### Railway-Oriented Programming
Chain operations that might fail using consistent error handling.

### Value Objects
Encapsulate domain concepts with their invariants.

### Aggregates
Group related entities with clear consistency boundaries.

### Bounded Contexts
Separate different domain models appropriately.

## Refactoring Triggers

Recognize when to suggest refactoring:
- Duplication appears (rule of three)
- Tests become hard to write
- Invalid states become possible
- Domain language emerges from tests
- Performance requires better modeling
- Team understanding crystallizes
