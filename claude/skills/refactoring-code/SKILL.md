---
name: refactoring-code
description: |
  Identifies code smells and applies refactoring patterns for OOP and FP codebases.
  Use when improving code structure, reducing technical debt, cleaning up messy code,
  or when the user mentions refactoring, code smells, or "make this cleaner".
---

# Refactoring Code

A skill for systematic code improvement using Martin Fowler's refactoring discipline and functional programming refactoring patterns.

## Quick Start

```
"Analyze this file for code smells"
"Refactor lib/my_app/orders.ex"
"This code is messy, help me clean it up"
```

## Paradigm Detection

Detect the paradigm from file extensions and project context to load only the relevant references:

| Signal | Paradigm | Smell Reference | Refactoring Reference |
|--------|----------|-----------------|----------------------|
| `.ex`, `.exs`, `mix.exs` | FP | `code-smells-fp.md` | `refactorings-fp.md` |
| `.erl`, `.hrl` | FP | `code-smells-fp.md` | `refactorings-fp.md` |
| `.ts`, `.tsx`, `.js`, `.jsx` | OOP* | `code-smells-oop.md` | `refactorings-oop.md` |
| `.py`, `.java`, `.rb` | OOP | `code-smells-oop.md` | `refactorings-oop.md` |
| User specifies | As specified | Matching file | Matching file |

*TS/JS codebases using a functional style (e.g., pure functions, immutable data, pipelines) may benefit from FP smell and refactoring patterns instead.

If the paradigm is ambiguous (e.g., mixed codebase), ask the user.

## Core Principles

### The Two Hats Rule
Never add functionality while refactoring. Switch between two distinct activities:
1. **Adding function** - Add new capabilities without cleaning up structure
2. **Refactoring** - Improve structure without changing behavior

### The Rule of Three
1. First time: Just do it
2. Second time: Wince at duplication, do it anyway
3. Third time: Refactor

### Small Steps with Verification
Each refactoring is a small behavior-preserving transformation. After each step:
- Run tests
- Commit if green
- If tests fail, revert and try smaller steps

### Functional Programming Principles
When refactoring functional codebases (Elixir, Erlang, etc.):
- **Functions are the unit of composition** — extract, compose, and name functions as the primary refactoring unit
- **Push side effects to boundaries** — keep core logic pure; IO, database, and process interactions belong at the edges
- **Make illegal states unrepresentable** — use structs, tagged tuples, and pattern matching to enforce invariants at the type level

### Preparatory Refactoring
> "Make the change easy, then make the easy change." — Kent Beck

Before adding features, refactor to create a clean insertion point.

## Workflow Selection

Read `references/workflows.md` and select the appropriate workflow:

| Workflow | When to Use |
|----------|-------------|
| **TDD Refactoring** | Third step of Red-Green-Refactor |
| **Litter-Pickup** | Small improvements while passing through |
| **Comprehension** | Refactor to understand unfamiliar code |
| **Preparatory** | Clear the way for a new feature |
| **Planned** | Dedicated time to address accumulated debt |
| **Long-Term** | Gradual replacement over weeks/months |

## Phase 1: Analysis (Sub-Agent)

Spawn a sub-agent to detect code smells without cluttering main context. Load **only the paradigm-appropriate reference file**.

### For OOP codebases

```
Use the Task tool with:
  subagent_type: general-purpose
  description: "Detect OOP code smells"
  prompt: |
    You are analyzing code for refactoring opportunities using Martin Fowler's taxonomy.

    First, read the code smell reference:
    Read: ~/.claude/skills/refactoring-code/references/code-smells-oop.md

    Then analyze these files:
    - [list files to analyze]

    For each smell found, report:
    1. **Smell Name** with `file:line` reference
    2. **Severity**: critical | high | medium | low
    3. **Evidence**: Brief quote or description
    4. **Suggested Refactoring**: From the catalog

    Group findings by file. Prioritize by severity.
    Be specific—cite line numbers and code snippets.
```

### For FP codebases (Elixir)

```
Use the Task tool with:
  subagent_type: general-purpose
  description: "Detect FP code smells"
  prompt: |
    You are analyzing Elixir code for functional programming code smells.

    First, read the code smell reference:
    Read: ~/.claude/skills/refactoring-code/references/code-smells-fp.md

    Then analyze these files:
    - [list files to analyze]

    For each smell found, report:
    1. **Smell Name** with `file:line` reference
    2. **Severity**: critical | high | medium | low
    3. **Evidence**: Brief quote or description
    4. **Suggested Refactoring**: From the catalog

    Pay special attention to:
    - Side effect smells (impure functions, hidden side effects)
    - Data/type smells (boolean blindness, naked maps, primitive obsession)
    - Control flow smells (missing pattern match, nested cases, exceptions for control flow)
    - Pipeline smells (broken pipeline, pipeline too long)
    - Process smells (fat GenServer, missing supervision)
    - Module organization (god module, chatty context, leaky abstraction)

    Group findings by file. Prioritize by severity.
    Be specific—cite line numbers and code snippets.
```

## Phase 2: Decision (Main Context)

Present analysis results and get user decisions:

1. **Summarize findings** grouped by severity
2. **Recommend priority** based on:
   - Impact on current work (preparatory refactoring)
   - Risk level (prefer safe, mechanical refactorings)
   - Test coverage (higher coverage = lower risk)
3. **Ask user** which smells to address

### Decision Questions

- "Which of these would you like to address?"
- "Do you want to tackle the [critical smell] first?"
- "Should we do a preparatory refactoring before [upcoming feature]?"

## Phase 3: Execution (Main Context)

Apply refactorings using the mechanics from the paradigm-appropriate refactoring reference (`references/refactorings-oop.md` or `references/refactorings-fp.md`).

### Execution Pattern

For each refactoring:

1. **State the transformation**
   ```
   Applying: Extract Function
   From: [file:lines]
   New function: [name]
   ```

2. **Apply mechanics step-by-step**
   - Follow the steps in the refactoring catalog
   - Make one change at a time
   - Keep changes small and reversible

3. **Verify after each step**
   - Run tests
   - If tests fail: revert and try smaller steps
   - If tests pass: commit with descriptive message

4. **Confirm completion**
   ```
   Extracted `calculateTotal` from `processOrder`
   Tests: 47 passed
   ```

### Refactoring Commit Messages

Use present tense, describe the transformation:
```
Extract calculateTotal from processOrder
Inline redundant validateInput helper
Move Customer to dedicated module
```

## When to Stop

Stop refactoring when:
- The immediate goal is achieved (feature can be added cleanly)
- Tests start failing and the fix isn't obvious
- You've been refactoring for more than the planned time
- The code is "good enough" for current needs

> "Leave the code better than you found it, but don't gold-plate."

## Integration with TDD

In the TDD cycle, refactoring is the third step:

```
RED    → Write failing test
GREEN  → Make it pass (quick and dirty is fine)
REFACTOR → Clean up while tests are green
```

Use this skill during the REFACTOR phase to identify what needs cleaning.

## Common Patterns

### "This code is messy but I don't know where to start"
1. Run analysis sub-agent
2. Start with the highest-severity smell
3. Apply one refactoring
4. Re-assess

### "I need to add a feature but the code is hard to work with"
1. Identify the insertion point
2. Run analysis on that area
3. Apply preparatory refactoring
4. Add the feature

### "I want to understand this unfamiliar code"
1. Run analysis to find the worst smells
2. Refactor to clarify (rename, extract, inline)
3. Your understanding improves as you refactor

## Example

An Elixir function with a couple of smells:

```elixir
def process_order(order_id) do
  order = Repo.get!(Order, order_id)
  user = Repo.get!(User, order.user_id)
  if order.status == "pending" do
    tax = order.subtotal * 0.08
    total = order.subtotal + tax + order.shipping
    if user.email != nil do
      Mailer.send_receipt(user.email, %{order_id: order.id, total: total})
    end
    order
    |> Ecto.Changeset.change(%{status: "completed", total: total})
    |> Repo.update!()
  else
    {:error, "Order is not pending"}
  end
end
```

### Analysis output

1. **Long Function** at `orders.ex:1` — Severity: **high**
   - Evidence: `process_order/1` handles fetching, calculation, notification, and persistence in one body.
   - Suggested Refactoring: Extract Function — pull calculation and notification into named helpers.

2. **Primitive Obsession (magic string)** at `orders.ex:4,14` — Severity: **medium**
   - Evidence: Status compared as raw string `"pending"` / `"completed"` instead of a structured type.
   - Suggested Refactoring: Replace with module attribute or a dedicated status type.

### After refactoring

```elixir
@pending "pending"
@completed "completed"

def process_order(order_id) do
  order = Repo.get!(Order, order_id)
  user = Repo.get!(User, order.user_id)

  with :ok <- validate_status(order, @pending) do
    total = calculate_total(order)
    maybe_send_receipt(user, order, total)
    complete_order(order, total)
  end
end

defp validate_status(%{status: expected}, expected), do: :ok
defp validate_status(_, _), do: {:error, "Order is not pending"}

defp calculate_total(order) do
  tax = order.subtotal * 0.08
  order.subtotal + tax + order.shipping
end

defp maybe_send_receipt(%{email: nil}, _order, _total), do: :ok
defp maybe_send_receipt(user, order, total) do
  Mailer.send_receipt(user.email, %{order_id: order.id, total: total})
end

defp complete_order(order, total) do
  order
  |> Ecto.Changeset.change(%{status: @completed, total: total})
  |> Repo.update!()
end
```

## References

### OOP (Martin Fowler)
- `references/code-smells-oop.md` — 24 code smells with detection criteria
- `references/refactorings-oop.md` — 15 refactoring techniques with mechanics

### FP (Elixir-focused)
- `references/code-smells-fp.md` — 19 code smells with detection criteria and Elixir examples
- `references/refactorings-fp.md` — 15 refactoring techniques with Elixir mechanics and sketches

### Shared
- `references/workflows.md` — 6 workflow types and when to use each
