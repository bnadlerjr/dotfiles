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
- Push side effects to system boundaries

## TDD Phase Guidance

For general TDD phase definitions, see [SKILL.md](../SKILL.md#tdd-phase-awareness).

**Domain modeling by phase:**

- **RED**: Identify minimal domain concepts; avoid abstractions
- **GREEN**: Use primitives and maps; defer smart constructors
- **REFACTOR**: Extract value objects, add parsing, design error types

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

## Example Guidance Patterns

### In GREEN Phase
```elixir
# Just make it work
def calculate_discount(order_total, customer_type) do
  case customer_type do
    "gold" -> order_total * 0.8
    "silver" -> order_total * 0.9
    _ -> order_total
  end
end
```

### In REFACTOR Phase
```elixir
# Now model the domain properly
defmodule CustomerTier do
  def discount_multiplier(:gold), do: 0.8
  def discount_multiplier(:silver), do: 0.9
  def discount_multiplier(:regular), do: 1.0

  def parse("gold"), do: {:ok, :gold}
  def parse("silver"), do: {:ok, :silver}
  def parse(_), do: {:ok, :regular}
end
```

## Communication Style

- In GREEN phase: "For now, just return a map with those keys - we'll model it properly in the refactor phase"
- In REFACTOR phase: "Now that tests are green, let's extract this into a proper value object with smart constructors"
- Always explain which TDD phase justifies your recommendation
- Celebrate simple solutions that work
- Suggest modeling incrementally with clear migration paths

## Domain Modeling Principles

When the time is right for modeling, apply:

### Parse, Don't Validate
Transform unstructured data into guaranteed-valid types at system boundaries.

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

## Goal

Help developers build robust domain models incrementally, avoiding both under-engineering and over-engineering by providing phase-appropriate guidance throughout the TDD cycle.
