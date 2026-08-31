---
name: collaborating-on-design
description: |
  Design-first collaboration using a five-level progressive framework (Capabilities → Components → Interactions → Contracts → Summary). Adapts to OOP or FP paradigms based on project language. Produces design output with mermaid diagrams.

  Use when designing features before implementation, planning architecture, aligning on design decisions, or when the user mentions "design first", "design session", or wants to think through a feature before coding.
---

# Collaborating on Design

Five-level progressive design framework based on Martin Fowler's design-first
collaboration. No code until the design is agreed. Each level is a checkpoint
requiring explicit user approval before advancing.

## Dependencies

- `thinking-patterns` skill — used for structured reasoning at each level.
  If unavailable, perform equivalent structured reasoning without the specific pattern invocations.

## Variables

- **TASK**: `$ARGUMENTS` — the story, requirements, or feature description

If TASK is empty, STOP immediately and ask the user what they want to design.

## Paradigm Detection

Auto-detect the project's paradigm before starting:

1. **Check project language files:**
   - `.ex`, `.exs`, `.erl`, `.hrl`, `.hs`, `.clj`, `.cljs` → **FP**
   - `.java`, `.cs`, `.rb` → **OOP**
   - `.ts`, `.tsx`, `.py`, `.kt`, `.scala` → **detect from patterns** (step 2)

2. **Pattern detection for hybrid languages:**
   - Scan for `class` declarations, inheritance, `this`/`self` → OOP signals
   - Scan for `pipe`, `|>`, `compose`, pure functions, pattern matching → FP signals
   - If mixed or unclear → **Hybrid** (use both vocabularies)

3. **Tell the user** which paradigm was detected and why. If they disagree, adjust.

4. **Load the matching reference:**
   - OOP → reference [oop-design-vocabulary.md](references/oop-design-vocabulary.md)
   - FP → reference [fp-design-vocabulary.md](references/fp-design-vocabulary.md)
   - Hybrid → reference both

Use [mermaid-patterns.md](references/mermaid-patterns.md) for diagram syntax at all levels.

## Complexity Calibration

Assess TASK complexity and determine the starting level:

| Complexity | Starting Level | Example |
|---|---|---|
| Trivial utility | Level 4 (Contracts) | Single function, clear interface |
| Single component | Level 2 (Components) | One module with clear boundaries |
| Multi-component feature | Level 1 (Capabilities) | Feature spanning multiple modules |
| System integration | Level 1 (Capabilities) | Cross-service, deep Level 3 work |

Tell the user which level you're starting at and why. If they disagree, adjust.

## The Five Levels

### Level 1: Capabilities

**What to produce:** Core requirements and scope boundaries. What the system
needs to do without saying how.

- List capabilities as user-facing behaviors
- Define what's in scope and what's explicitly out
- Identify constraints (performance, security, compliance)
- Use `/thinking atomic-thought` to decompose requirements independently

**OOP guidance:** Frame capabilities as behaviors the system exposes.
See [oop-design-vocabulary.md](references/oop-design-vocabulary.md) for vocabulary.

**FP guidance:** Frame capabilities as data transformations the system performs.
See [fp-design-vocabulary.md](references/fp-design-vocabulary.md) for vocabulary.

**Diagrams:** Generally not needed at this level. Use a simple bulleted list.

**Checkpoint:** Present the capabilities summary. Wait for explicit approval
before advancing. If the user pushes back, revise at this level.

---

### Level 2: Components

**What to produce:** The building blocks, their responsibilities, and
relationships.

- Identify major abstractions, services, modules
- Assign a single clear responsibility to each component
- IMPORTANT: Challenge unnecessary abstractions. Only introduce components that
  earn their existence. Flag anything that wraps an existing library without
  adding value.
- Before proposing a custom solution for a capability, check whether an
  already-imported library provides it natively. Prefer library-native APIs
  over custom reimplementations — they're maintained, documented, and
  integrate with the library's other features.
- Use `/thinking tree-of-thoughts` to evaluate component alternatives

**OOP guidance:** Components are classes, services, repositories, factories,
controllers. Apply SRP. Define collaborator relationships.
See [oop-design-vocabulary.md](references/oop-design-vocabulary.md).

**FP guidance:** Components are modules, behaviours, GenServers, supervisors,
data pipelines. Define transformation responsibilities and data ownership.
See [fp-design-vocabulary.md](references/fp-design-vocabulary.md).

**Diagrams:** Use mermaid class diagrams (OOP) or module/component diagrams (FP).
See [mermaid-patterns.md](references/mermaid-patterns.md) for syntax.

**Checkpoint:** Present the component list with one-line responsibilities and
a diagram. Wait for explicit approval.

---

### Level 3: Interactions

**What to produce:** How components communicate, data flow, and operation
sequences for key scenarios.

- Map data flow between components
- Define API calls, events, message passing
- Walk through key scenarios step by step
- Identify failure modes and recovery paths
- Use `/thinking chain-of-thought` to trace through scenarios

**OOP guidance:** Method calls, observer/pub-sub patterns, dependency injection,
event dispatch. Show object collaboration.
See [oop-design-vocabulary.md](references/oop-design-vocabulary.md).

**FP guidance:** Function composition, pipe chains, message passing, event
streams, supervision strategies. Show data transformation flow.
See [fp-design-vocabulary.md](references/fp-design-vocabulary.md).

**Diagrams:** Use mermaid sequence diagrams for workflows, flowcharts for
decision logic, data flow diagrams for pipelines.
See [mermaid-patterns.md](references/mermaid-patterns.md).

**Checkpoint:** Present interaction diagrams and scenario walkthroughs. Wait
for explicit approval.

---

### Level 4: Contracts

**What to produce:** Function signatures, types, schemas, and interfaces at
every component boundary.

- Define input/output types for each boundary
- Specify error cases and edge conditions
- Establish validation rules and invariants
- Present contracts in the project's language conventions
- Use `/thinking skeleton-of-thought` to outline contract structure

**OOP guidance:** Interfaces, abstract classes, protocols, method signatures.
Define what each collaborator expects and provides.
See [oop-design-vocabulary.md](references/oop-design-vocabulary.md).

**FP guidance:** Typespecs, behaviours, protocols, data schemas, function
signatures. Define input/output shapes for each transformation.
See [fp-design-vocabulary.md](references/fp-design-vocabulary.md).

**Diagrams:** Use mermaid class diagrams showing interfaces and type
relationships. See [mermaid-patterns.md](references/mermaid-patterns.md).

**Checkpoint:** Present contracts in the project's language. Wait for explicit
approval.

---

### Level 5: Summary

**What to produce:** The design is complete. No code is written in this session.

- Summarize all approved levels into a coherent design document
- Flag risks or open questions discovered during design

## Guidelines

**DO:**
- Produce visible output at each level before pausing
- State which paradigm was detected and which level you're starting at
- Challenge unnecessary abstractions at Level 2
- Use mermaid diagrams where they aid understanding
- Keep each level focused on its concern only
- Match depth to complexity — not every task needs all five levels

**DON'T:**
- Write implementation code — type signatures and contracts at Level 4 are expected
- Leak implementation details into Capabilities
- Discuss data flow in Components (that's Interactions)
- Skip the approval checkpoint at any level
- Introduce components that don't earn their existence
- Force the design toward implementation concerns

**When Stuck:**
- If stuck on Capabilities: Ask the user what behaviors matter most
- If stuck on Components: Present what you have, ask what's missing
- If stuck on Interactions: Walk through a concrete scenario together
- If stuck on Contracts: Start with the happiest path, then add edge cases

## Example

**User**: "Design a webhook delivery system for our Elixir app"

**Paradigm**: FP detected (`.ex` files, pipe operators, GenServer patterns)

**Complexity**: Multi-component feature → Start at Level 1

### Level 1: Capabilities
```
In scope:
- Accept webhook registration (URL, events, secret)
- Queue outbound deliveries when events fire
- Retry failed deliveries with exponential backoff
- Provide delivery status and history

Out of scope:
- Webhook signature verification on the receiving end
- Real-time delivery streaming (polling/API only)

Constraints:
- Must handle 10k+ events/minute
- Delivery attempts timeout after 30 seconds
```
→ Wait for approval

### Level 2: Components
```
- Webhooks context module — CRUD for webhook registrations
- Dispatcher — receives events, fans out to matching webhooks
- DeliveryWorker — performs HTTP delivery with retry logic (Oban job)
- DeliveryLog — records attempt results for status/history queries
```
→ Includes component diagram. Wait for approval.

### Level 3: Interactions
```
Event fired → Dispatcher matches registered webhooks
  → Enqueues DeliveryWorker job per webhook
  → DeliveryWorker POSTs payload, records result in DeliveryLog
  → On failure: Oban retries with backoff schedule
```
→ Includes sequence diagram. Wait for approval.

### Level 4: Contracts
```elixir
# Webhooks context
@spec register(map()) :: {:ok, Webhook.t()} | {:error, Changeset.t()}
@spec list_for_event(String.t()) :: [Webhook.t()]

# Dispatcher
@spec dispatch(Event.t()) :: :ok

# DeliveryWorker (Oban job)
@spec perform(Oban.Job.t()) :: :ok | {:error, term()}

# DeliveryLog
@spec record(Webhook.t(), Event.t(), :success | :failure, map()) :: {:ok, DeliveryLog.t()}
@spec history(webhook_id(), keyword()) :: [DeliveryLog.t()]
```
→ Wait for approval.

### Level 5: Summary
```
Design complete. Risks and open questions:
- Delivery volume may require connection pooling at scale
- Webhook secret rotation strategy TBD
```
→ Confirm the user is satisfied with the design.

## Report

Provide:
- A one-line summary of what was designed
- Any open risks or questions surfaced during design
