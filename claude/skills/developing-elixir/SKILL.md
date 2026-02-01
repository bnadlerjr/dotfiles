---
name: developing-elixir
description: |
  Comprehensive Elixir/Phoenix development expertise covering Phoenix controllers, routing, channels; LiveView components and real-time features; Ecto schemas, queries, migrations; OTP patterns (GenServer, Supervisor); functional domain modeling; GraphQL with Absinthe; and ExUnit testing.

  Use when working with .ex/.exs files, mix projects, Phoenix applications, or when the user mentions Elixir, Phoenix, Ecto, LiveView, OTP, GenServer, Supervisor, Absinthe, or ExUnit. Also use for defmodule, mix.exs, umbrella apps, or iex sessions.
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
| GenServer, Supervisor, processes | [otp-patterns](references/otp-patterns.md) | Fault tolerance, state management |
| Domain modeling, value objects | [functional-modeling](references/functional-modeling.md) | Parse-don't-validate, DDD |
| GraphQL schemas, resolvers | [graphql-absinthe](references/graphql-absinthe.md) | Subscriptions, dataloader |
| ExUnit tests, TDD workflow | [testing-exunit](references/testing-exunit.md) | Test organization, assertions |

## TDD Phase Awareness

All guidance in this skill is phase-aware. Identify your current phase:

### RED Phase (Writing Failing Tests)
- Write the smallest test that captures intent
- Use hard-coded values directly in tests
- Skip edge cases and parameterization initially
- Focus on what behavior the test demands

### GREEN Phase (Making Tests Pass)
- RESIST over-engineering at all costs
- Start with pure functions and simple data structures
- Recommend primitives and maps before structs
- Defer abstractions, smart constructors, and validations
- Focus only on making the current test pass

### REFACTOR Phase (Improving Design)
- NOW apply proper patterns and abstractions
- Extract value objects from primitives
- Add comprehensive error handling
- Introduce OTP patterns if genuinely needed
- Improve test structure and coverage

## Cross-Cutting Principles

These principles apply across all Elixir development:

### Functional-First Approach
1. Prefer pure functions over stateful processes
2. Use explicit state passing through function parameters
3. Only introduce OTP patterns when tests require them
4. Push side effects to system boundaries

### Progressive Abstraction
1. Start with primitives and maps
2. Introduce structs when structure is genuinely needed
3. Add type specs when interfaces stabilize
4. Extract domain modules when concepts are proven

### Parse, Don't Validate
- Transform unstructured data into guaranteed-valid types at boundaries
- Once data is parsed, it's always valid throughout the system
- Prefer constructors that return `{:ok, value} | {:error, reason}`

### Error Handling Philosophy
- Use tagged tuples consistently: `{:ok, result}` or `{:error, reason}`
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
→ Identify TDD phase (likely REFACTOR), consult functional-modeling.md
```

**Adding background job processing:**
```
User: "Process order confirmations asynchronously"
→ Consult otp-patterns.md for process decisions, phoenix-framework.md for Oban
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

### Testing Anti-Patterns
- Writing multiple assertions before any pass
- Creating elaborate test fixtures prematurely
- Testing implementation details
- Adding error case tests too early

## Reference File IDs

For programmatic access (e.g., parallel reviews), use these identifiers:

`phoenix-framework` · `liveview` · `ecto-database` · `otp-patterns` · `functional-modeling` · `graphql-absinthe` · `testing-exunit`
