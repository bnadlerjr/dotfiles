# OTP Patterns Reference

Expert guidance for Elixir's OTP patterns, process architecture, and concurrent programming with a focus on choosing the right abstraction at the right time.

## Quick Start

```elixir
# Start simple - pure function
def increment(count), do: count + 1

# Evolve to Agent when state needed
defmodule Counter do
  use Agent
  def start_link(initial), do: Agent.start_link(fn -> initial end, name: __MODULE__)
  def increment, do: Agent.update(__MODULE__, &(&1 + 1))
  def value, do: Agent.get(__MODULE__, & &1)
end

# Evolve to GenServer when callbacks needed
defmodule Counter do
  use GenServer
  def start_link(initial), do: GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  def init(initial), do: {:ok, initial}
  def handle_call(:value, _from, state), do: {:reply, state, state}
  def handle_cast(:increment, state), do: {:noreply, state + 1}
end
```

## Core Expertise

- GenServer implementation patterns and appropriate use cases
- Supervisor strategies (one_for_one, rest_for_one, one_for_all) and fault tolerance
- Process communication, message passing, and mailbox management
- ETS/DETS tables for high-performance state management
- Task, Agent, and GenStage patterns for different concurrency needs
- Application behaviour and supervision tree architecture
- Hot code reloading, releases, and deployment strategies
- Distributed Elixir and node communication

## TDD Phase Guidance

For general TDD phase definitions, see [SKILL.md](../SKILL.md#tdd-phase-awareness).

**OTP-specific guidance by phase:**

- **RED**: Focus on behavior, not process architecture
- **GREEN**: Start with pure functions; only add processes if tests demand persistent state
- **REFACTOR**: Extract GenServers, add Supervisors, introduce ETS when genuinely needed

## Progressive OTP Adoption Path

Recommend this evolution:
1. Pure functions with explicit state passing
2. Module-level functions with shared constants
3. Simple process spawning only for true concurrency needs
4. Agent for basic state (simpler than GenServer)
5. GenServer when callbacks/timeouts are required
6. Supervisor when fault tolerance is essential
7. Application when startup guarantees matter

## Pattern Recognition

### Signs of Premature OTP
Identify and discourage:
- GenServer for data that could be function arguments
- Supervisors for processes that don't need restart strategies
- ETS tables for small, static datasets
- Complex process trees for simple problems
- Message passing when direct function calls suffice
- Distributed Elixir for local problems

### When to Use OTP Immediately
Recognize when OTP is justified:
- Tests explicitly verify process crash/restart behavior
- Requirements mention "real-time" or "concurrent" operations
- External resources need lifecycle management
- Rate limiting or throttling is required
- Background work is integral to the feature
- State genuinely needs process isolation

## Practical Examples

### GREEN PHASE: Start Simple
```elixir
def counter_increment(count), do: count + 1
def counter_value(count), do: count
```

### REFACTOR PHASE: Upgrade Only If Needed
```elixir
defmodule Counter do
  use Agent

  def start_link(initial) do
    Agent.start_link(fn -> initial end, name: __MODULE__)
  end

  def increment do
    Agent.update(__MODULE__, &(&1 + 1))
  end
end
```

## Anti-Patterns to Prevent

During GREEN phase, warn against:
- Creating GenServers for stateless operations
- Adding process registry without concurrent test requirements
- Building supervision trees prematurely
- Using ETS for test fixtures
- Spawning processes for sequential work
- Adding timeouts that tests don't verify

## Refactoring Triggers

Recognize when to evolve to OTP:
- Multiple tests deal with concurrent operations
- State becomes genuinely hard to thread through functions
- Tests explicitly verify fault tolerance
- Performance tests fail without concurrency
- External resources need proper management
- Real-time features emerge from requirements

## Communication Approach

- In GREEN phase: "Just pass the state as a parameter for now"
- In REFACTOR phase: "Now a GenServer would improve this design"
- Always question: "Do you really need a process here?"
- Celebrate simple, functional solutions
- Show the evolution path from simple to complex when relevant
- Provide specific code examples for recommended patterns

## Decision Framework

When consulted:
1. Analyze the actual requirements (not assumed complexity)
2. Identify the current TDD phase
3. Recommend the simplest solution that passes tests
4. Explain when and why to evolve to more complex patterns
5. Provide specific implementation guidance with code examples
6. Warn against common over-engineering pitfalls

## Core Philosophy

Be pragmatic, favoring simplicity and only introducing OTP complexity when genuinely beneficial. Good Elixir code often doesn't need OTP at all. Guide developers to make informed decisions about when processes and supervision truly add value.
