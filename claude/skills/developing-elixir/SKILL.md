---
name: developing-elixir
description: |
  Comprehensive Elixir/Phoenix development expertise covering Phoenix controllers, routing, channels; LiveView components and real-time features; Ecto schemas, queries, migrations; OTP patterns (GenServer, Supervisor); functional domain modeling; and GraphQL with Absinthe.

  Use when working with .ex/.exs files, mix projects, Phoenix applications, or when the user mentions Elixir, Phoenix, Ecto, LiveView, OTP, GenServer, Supervisor, or Absinthe. Also use for defmodule, mix.exs, umbrella apps, or iex sessions.
---

# Developing Elixir

Expert guidance for building robust, scalable Elixir/Phoenix applications.

## Quick Start

For immediate help, identify your task type and consult the relevant reference:

| Working On | Reference File | Key Topics |
|------------|----------------|------------|
| Controllers, routing, plugs, channels | [phoenix-framework](references/phoenix-framework.md) | MVC patterns, authentication, WebSockets |
| LiveView components, forms | [liveview](references/liveview.md) | Real-time UI, hooks, streams |
| Schemas, queries, migrations | [ecto-database](references/ecto-database.md) | Associations, changesets, transactions |
| Safe migrations, schema changes | [safe-ecto-migrations](references/safe-ecto-migrations.md) | Concurrent indexes, zero-downtime DDL |
| GenServer, Supervisor, processes | [otp-patterns](references/otp-patterns.md) | Fault tolerance, state management |
| Domain modeling, layering, value objects | [functional-modeling](references/functional-modeling.md) | Layers, parse-don't-validate, DDD |
| GraphQL schemas, resolvers | [graphql-absinthe](references/graphql-absinthe.md) | Subscriptions, dataloader |
| ExUnit tests, TDD workflow | `testing-elixir` skill | Delegated — ExUnit, assertions, Ecto sandbox, Phoenix test helpers |

## Cross-Cutting Principles

These principles apply across all Elixir development:

### Functional-First Approach
1. Prefer pure functions over stateful processes
2. Use explicit state passing through function parameters
3. Only introduce OTP patterns when tests require them
4. Push side effects to the Lifecycle and Workers layers

### Progressive Abstraction
1. Start with primitives and maps
2. Introduce structs when structure is genuinely needed
3. Add type specs when interfaces stabilize
4. Extract domain modules when concepts are proven

### Parse, Don't Validate
- Transform unstructured data into guaranteed-valid types at the Boundary layer
- Once data is parsed, it's always valid throughout the system
- Prefer constructors that return `{:ok, value} | {:error, reason}` at that layer.
  Constructors below it take already-parsed values and stay total.

### Error Handling Philosophy
- Tagged tuples belong where a question can be answered "no", which is the Boundary
  layer. Pure computation below it returns plain values. See
  [functional-modeling](references/functional-modeling.md#layers).
- Implement proper error types for domain-specific errors
- Never expose internal implementation details in errors

## Examples

**Creating a Phoenix context with Ecto:**
```
User: "I need to add a checkout feature for orders"
→ Consult ecto-database.md for schema design, phoenix-framework.md for controller
```

**Implementing real-time updates:**
```
User: "Show live order status updates to the customer"
→ Consult liveview.md for socket state and PubSub patterns
```

**Refactoring to proper domain model:**
```
User: "This order calculation has grown complex with many edge cases"
→ Consult functional-modeling.md
```

**Adding background job processing:**
```
User: "Process order confirmations asynchronously"
→ Consult otp-patterns.md for process decisions, phoenix-framework.md for Oban
```

**Writing a database migration:**
```
User: "I need to add an index to the posts table"
→ Consult safe-ecto-migrations.md for concurrent index creation
```

## Anti-Patterns to Avoid

### Premature OTP
- GenServer for data that could be function arguments
- Supervisors for processes that don't need restart strategies
- ETS tables for small, static datasets
- Message passing when direct function calls suffice

### Premature Abstraction
- Creating types for single-use values
- Building generic solutions for specific problems
- Introducing abstractions without duplication
- Modeling future requirements

## Reference File IDs

For programmatic access (e.g., parallel reviews), use these identifiers:

`phoenix-framework` · `liveview` · `ecto-database` · `safe-ecto-migrations` · `otp-patterns` · `functional-modeling` · `graphql-absinthe`
