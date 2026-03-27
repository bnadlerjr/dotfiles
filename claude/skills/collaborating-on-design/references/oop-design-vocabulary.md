# OOP Design Vocabulary

Reference for object-oriented design concepts used at each level of the
design framework.

## Component Types

| Component | Purpose | When to Use |
|---|---|---|
| Class | Encapsulates state and behavior | Core domain entities |
| Service | Stateless business logic orchestration | Cross-cutting operations |
| Repository | Data access abstraction | Persistence boundaries |
| Factory | Complex object construction | When constructors aren't enough |
| Controller | Request handling and delegation | API/web entry points |
| Adapter | External system integration | Third-party API wrappers |
| Value Object | Immutable data with behavior | Money, dates, coordinates |
| Entity | Identity-based domain object | Users, orders, accounts |
| Aggregate | Consistency boundary | Transaction scope grouping |
| DTO | Data transfer between layers | API boundaries |

## Responsibility Patterns

### Single Responsibility Principle (SRP)

Each component should have one reason to change. Test: can you describe
the component's purpose in one sentence without "and"?

**Good:** "UserRepository manages user persistence."
**Bad:** "UserService handles authentication and sends welcome emails."

### Collaborator Relationships

- **Depends on** — uses another component's interface
- **Delegates to** — passes work to a specialized component
- **Observes** — reacts to another component's events
- **Composes** — contains and manages sub-components

### Tell, Don't Ask

Components should tell collaborators what to do, not ask for data and
act on it themselves. Push behavior to the object that owns the data.

## Interaction Patterns

| Pattern | Mechanism | When to Use |
|---|---|---|
| Direct method call | `service.doThing(args)` | Synchronous, same process |
| Dependency injection | Constructor/setter injection | Decoupling, testability |
| Observer/Pub-Sub | Event emitter + listeners | Loose coupling, side effects |
| Mediator | Central coordinator | Complex multi-object workflows |
| Command | Encapsulated request object | Queuing, undo, logging |
| Strategy | Swappable algorithm | Multiple approaches to same task |
| Chain of Responsibility | Handler pipeline | Request processing, middleware |

### Dependency Injection

Prefer constructor injection. Inject interfaces, not concrete classes.

```
class OrderService
  constructor(repository: OrderRepository, notifier: Notifier)
```

### Event-Driven Communication

Use when:
- The sender shouldn't know about receivers
- Multiple components react to the same event
- Side effects should be decoupled from the triggering action

## Contract Patterns

| Contract Type | Language Examples | Purpose |
|---|---|---|
| Interface | Java `interface`, TypeScript `interface`, C# `interface` | Define expected behavior |
| Abstract class | Java `abstract class`, Ruby abstract module | Shared base with extension points |
| Protocol | Swift `protocol`, Kotlin `interface` | Capability declaration |
| Type alias | TypeScript `type`, Kotlin `typealias` | Named shapes for data |

### Interface Design Principles

- **Interface Segregation**: Prefer many small interfaces over one large one
- **Liskov Substitution**: Subtypes must be substitutable for their base types
- **Dependency Inversion**: Depend on abstractions, not concretions

### Method Signatures

Define for each boundary:
- Input types (parameters)
- Return type (including error cases)
- Preconditions (what must be true before calling)
- Postconditions (what is guaranteed after calling)
- Side effects (what changes outside the return value)

## Common Design Patterns by Level

### Level 2 — Components

| Pattern | Purpose | Challenge If... |
|---|---|---|
| Repository | Abstract persistence | Only wrapping ORM without added value |
| Service | Orchestrate business logic | Contains only delegation with no logic |
| Factory | Build complex objects | Constructor works fine |
| Facade | Simplify complex subsystem | Only one client uses it |

### Level 3 — Interactions

| Pattern | Purpose | Challenge If... |
|---|---|---|
| Observer | Decouple event producers/consumers | Only one consumer exists |
| Mediator | Coordinate complex workflows | Only two components interact |
| Command | Encapsulate requests | No queuing, undo, or logging needed |
| Strategy | Swap algorithms | Only one algorithm exists today |

### Level 4 — Contracts

| Pattern | Purpose | Challenge If... |
|---|---|---|
| Interface | Define expected behavior | Only one implementation exists |
| Abstract class | Share base implementation | Composition would work better |
| Generic/Template | Type-safe reuse | Adds complexity without reuse |

## Anti-Patterns to Challenge

| Anti-Pattern | Symptom | Resolution |
|---|---|---|
| God Object | One class does everything | Split by responsibility |
| Anemic Domain Model | Data classes + separate logic classes | Move behavior to entities |
| Unnecessary Abstraction | Interface with single implementation | Remove until second impl needed |
| Over-Engineering | Patterns without current need | YAGNI — add when needed |
| Service Explosion | Dozens of tiny services | Merge related responsibilities |
| Shotgun Surgery | One change touches many classes | Consolidate related behavior |
| Feature Envy | Method uses another class's data heavily | Move method to data owner |
| Premature Generalization | Abstract base before second case | Keep concrete until pattern emerges |
