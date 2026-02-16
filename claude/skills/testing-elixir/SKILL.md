---
name: testing-elixir
description: |
  Provides expert guidance for writing ExUnit tests in Elixir. Covers core ExUnit patterns,
  assertions, sociable testing philosophy, Ecto sandbox and database testing, Phoenix
  controller/LiveView/channel tests, and external API testing with Bypass and Req.Test.

  Use when working with ExUnit tests, assertions, describe blocks, test
  organization, Bypass, Req.Test, factories, ExMachina, Ecto sandbox, ConnTest, LiveViewTest,
  ChannelTest, or test helpers.
---

# Testing Elixir

Expert guidance for writing great ExUnit tests in Elixir applications.

## Quick Start

| Testing... | Reference File | Key Topics |
|------------|----------------|------------|
| Core ExUnit setup, tags, async | [core-exunit](references/core-exunit.md) | Case setup, describe, callbacks, tags, async |
| Assertions and pattern matching | [assertions](references/assertions.md) | assert, refute, pattern match, assert_receive |
| Sociable tests, stubs, behaviours | [sociable-testing](references/sociable-testing.md) | Stubs over mocks, behaviours, functional core |
| Ecto sandbox, factories, DB tests | [database-testing](references/database-testing.md) | Sandbox, ExMachina, async: true, changesets |
| Phoenix controllers, LiveView, channels | [phoenix-testing](references/phoenix-testing.md) | ConnTest, LiveViewTest, ChannelTest |
| External HTTP APIs (Bypass, Req.Test) | [external-api-testing](references/external-api-testing.md) | Bypass, Req.Test, behaviour stubs |
| Test architecture, helpers, tagging | [test-organization](references/test-organization.md) | File structure, support modules, coverage |

## Testing Philosophy

These principles are non-negotiable defaults for all ExUnit testing advice.

### Sociable Tests by Default

Use real collaborators. A test for `Orders.checkout/1` should call real `Inventory` and `Pricing` modules, not stubs. Sociable tests catch integration bugs, survive refactors, and test actual behavior.

### Stubs Over Mocks

When you must replace a dependency, prefer stubs (modules that return canned data) over mocks (modules that verify call sequences). Use Elixir behaviours to define the contract, then swap implementations via application config or function parameters.

### Test Behavior, Not Implementation

Assert on outputs and side effects observable to the caller. Never assert on internal function calls, message ordering between modules, or private state.

### Only Stub at True System Boundaries

Real boundaries: external HTTP APIs, payment gateways, email delivery, SMS providers, system clock. Not boundaries: your own context modules, Ecto repos, internal GenServers.

### async: true by Default

Every test module should start with `async: true` unless it requires shared sandbox mode or touches global state. Parallel tests keep the suite fast.

## Anti-Patterns

- **Mock-heavy tests**: If a test has 3+ mocks, rethink the design. Push side effects to boundaries.
- **Testing private functions**: If you need to test a private function, extract it to its own module.
- **Shared mutable state**: Tests that depend on order or seed data are fragile. Each test sets up its own data.
- **Asserting implementation details**: `assert_called MyModule.internal_fn()` couples tests to internals.
- **Overly complex factories**: Factories with 10+ overrides signal a design problem, not a testing problem.
- **async: false by default**: Only disable async when you genuinely need shared sandbox mode.

## Reference File IDs

`core-exunit` . `assertions` . `sociable-testing` . `database-testing` . `phoenix-testing` . `external-api-testing` . `test-organization`
