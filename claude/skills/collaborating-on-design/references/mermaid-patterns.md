# Mermaid Diagram Patterns

Templates for mermaid diagrams used at each design level. Includes both
OOP and FP variants where they differ.

## Level 2: Components

### Class Diagram (OOP)

Use to show components, their attributes, methods, and relationships.

```mermaid
classDiagram
    class OrderService {
        -repository: OrderRepository
        -notifier: Notifier
        +create(params) Order
        +cancel(orderId) void
    }

    class OrderRepository {
        <<interface>>
        +save(order) Order
        +findById(id) Order
        +findByUser(userId) List~Order~
    }

    class PostgresOrderRepository {
        +save(order) Order
        +findById(id) Order
        +findByUser(userId) List~Order~
    }

    class Notifier {
        <<interface>>
        +notify(event) void
    }

    OrderService --> OrderRepository : depends on
    OrderService --> Notifier : depends on
    PostgresOrderRepository ..|> OrderRepository : implements
```

### Module Diagram (FP)

Use to show modules, their public functions, and relationships.

```mermaid
classDiagram
    class Orders {
        +create(params) result
        +cancel(order_id) result
        +list_for_user(user_id) list
    }

    class Orders.Validator {
        +validate_create(params) result
        +validate_cancel(order) result
    }

    class Orders.Notifier {
        <<behaviour>>
        +notify(event) ok_or_error
    }

    class Orders.EmailNotifier {
        +notify(event) ok_or_error
    }

    Orders --> Orders.Validator : calls
    Orders --> Orders.Notifier : calls
    Orders.EmailNotifier ..|> Orders.Notifier : implements
```

### Component Diagram

Use for high-level system overview when class/module detail is too granular.

```mermaid
graph TB
    subgraph "Web Layer"
        API[API Controller]
        LiveView[LiveView]
    end

    subgraph "Domain Layer"
        Orders[Orders Context]
        Inventory[Inventory Context]
        Notifications[Notification Service]
    end

    subgraph "Infrastructure"
        DB[(Database)]
        Queue[Job Queue]
        Email[Email Provider]
    end

    API --> Orders
    LiveView --> Orders
    Orders --> Inventory
    Orders --> Notifications
    Orders --> DB
    Notifications --> Queue
    Queue --> Email
```

## Level 3: Interactions

### Sequence Diagram

Use to show the order of operations between components for a specific scenario.

**OOP variant:**

```mermaid
sequenceDiagram
    actor User
    participant Controller
    participant OrderService
    participant Repository
    participant Notifier

    User->>Controller: POST /orders
    Controller->>OrderService: create(params)
    OrderService->>Repository: save(order)
    Repository-->>OrderService: saved order
    OrderService->>Notifier: notify(order_created)
    Notifier-->>OrderService: ok
    OrderService-->>Controller: order
    Controller-->>User: 201 Created
```

**FP variant:**

```mermaid
sequenceDiagram
    actor User
    participant Router
    participant OrderController
    participant Orders
    participant Repo
    participant Oban

    User->>Router: POST /orders
    Router->>OrderController: create(conn, params)
    OrderController->>Orders: create(params)
    Orders->>Orders: validate(params)
    Orders->>Repo: insert(changeset)
    Repo-->>Orders: {:ok, order}
    Orders->>Oban: insert(NotificationWorker, order)
    Orders-->>OrderController: {:ok, order}
    OrderController-->>User: 201 Created
```

### Flowchart

Use for decision logic, branching paths, or process flows.

```mermaid
flowchart TD
    A[Receive Event] --> B{Event type?}
    B -->|order.created| C[Validate webhook URL]
    B -->|order.cancelled| C
    B -->|unknown| D[Log and discard]

    C --> E{URL valid?}
    E -->|yes| F[Sign payload]
    E -->|no| G[Mark webhook inactive]

    F --> H[POST to webhook URL]
    H --> I{Response?}
    I -->|2xx| J[Log success]
    I -->|4xx| K[Log failure, no retry]
    I -->|5xx/timeout| L[Schedule retry]

    L --> M{Retry count < max?}
    M -->|yes| H
    M -->|no| N[Log permanent failure]
```

### Data Flow Diagram (FP)

Use to show data transformation pipelines.

```mermaid
flowchart LR
    Input[Raw Params] --> Validate[Validate]
    Validate --> Transform[Transform]
    Transform --> Enrich[Enrich with defaults]
    Enrich --> Persist[Persist to DB]
    Persist --> Notify[Broadcast event]
    Notify --> Output[Return result]

    Validate -.->|invalid| Error[Return error]
```

### State Machine Diagram

Use for components with well-defined states and transitions.

```mermaid
stateDiagram-v2
    [*] --> Pending
    Pending --> Processing : payment_received
    Processing --> Shipped : items_packed
    Processing --> Cancelled : cancel_requested
    Shipped --> Delivered : delivery_confirmed
    Shipped --> Returned : return_initiated
    Delivered --> [*]
    Cancelled --> [*]
    Returned --> Refunded : refund_processed
    Refunded --> [*]
```

## Level 4: Contracts

### Interface Diagram (OOP)

Use to show interfaces, their methods, and implementing classes.

```mermaid
classDiagram
    class PaymentGateway {
        <<interface>>
        +charge(amount, card) PaymentResult
        +refund(transactionId) RefundResult
        +getStatus(transactionId) PaymentStatus
    }

    class StripeGateway {
        -apiKey: string
        +charge(amount, card) PaymentResult
        +refund(transactionId) RefundResult
        +getStatus(transactionId) PaymentStatus
    }

    class MockGateway {
        +charge(amount, card) PaymentResult
        +refund(transactionId) RefundResult
        +getStatus(transactionId) PaymentStatus
    }

    class PaymentResult {
        +transactionId: string
        +status: PaymentStatus
        +amount: Money
        +error?: string
    }

    class PaymentStatus {
        <<enumeration>>
        PENDING
        SUCCEEDED
        FAILED
        REFUNDED
    }

    StripeGateway ..|> PaymentGateway
    MockGateway ..|> PaymentGateway
    PaymentGateway ..> PaymentResult : returns
    PaymentResult --> PaymentStatus
```

### Type Relationship Diagram (FP)

Use to show types, specs, and behaviour contracts.

```mermaid
classDiagram
    class PaymentGateway {
        <<behaviour>>
        charge(Money.t, Card.t) result
        refund(String.t) result
        status(String.t) status_result
    }

    class Money {
        <<struct>>
        amount: integer
        currency: atom
    }

    class Card {
        <<struct>>
        number: String.t
        exp_month: integer
        exp_year: integer
    }

    class PaymentResult {
        <<struct>>
        transaction_id: String.t
        status: atom
        amount: Money.t
    }

    PaymentGateway ..> Money : input
    PaymentGateway ..> Card : input
    PaymentGateway ..> PaymentResult : returns
```

### Supervision Tree Diagram (FP/OTP)

Use to show process supervision hierarchies.

```mermaid
graph TD
    App[Application Supervisor]
    App --> Web[Phoenix Endpoint]
    App --> Domain[Domain Supervisor]
    App --> Infra[Infrastructure Supervisor]

    Domain --> Webhooks[Webhooks.Supervisor]
    Webhooks --> Dispatcher[Dispatcher GenServer]
    Webhooks --> Pool[DeliveryPool DynamicSupervisor]
    Pool --> W1[Worker 1]
    Pool --> W2[Worker 2]
    Pool --> Wn[Worker n]

    Infra --> Oban[Oban Supervisor]
    Infra --> PubSub[Phoenix.PubSub]
```

## Diagram Selection Guide

| Level | Scenario | Diagram Type |
|---|---|---|
| Level 2 | Show component responsibilities (OOP) | Class diagram |
| Level 2 | Show module responsibilities (FP) | Module diagram |
| Level 2 | High-level system overview | Component diagram |
| Level 3 | Trace a request through components | Sequence diagram |
| Level 3 | Show decision/branching logic | Flowchart |
| Level 3 | Show data transformation pipeline | Data flow diagram |
| Level 3 | Show state transitions | State machine diagram |
| Level 4 | Show interfaces and implementations (OOP) | Interface diagram |
| Level 4 | Show types and behaviour contracts (FP) | Type relationship diagram |
| Level 4 | Show process supervision (OTP) | Supervision tree diagram |

## Tips

- Keep diagrams focused. One diagram per concern, not one diagram for everything.
- Use `subgraph` to group related components visually.
- Label arrows with the interaction type (method name, message, event).
- Use dashed lines (`-.->` or `..>`) for optional or async relationships.
- Use solid lines (`-->` or `-->>`) for required/synchronous relationships.
- Prefer top-to-bottom (`TD`) for hierarchies, left-to-right (`LR`) for pipelines.
- Include a brief text description alongside each diagram for context.
