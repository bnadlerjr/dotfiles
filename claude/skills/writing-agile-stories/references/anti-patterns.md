# Anti-Patterns in Agile Stories

Common mistakes to avoid when writing behavior-focused stories.

## Template Smell

Using the rigid "As a [user], I want [X], so that [Y]" format instead of narrative prose.

```
❌ As a user, I want to click cancel so that my order is cancelled.

✅ When customers change their mind before shipment, they can cancel
   and receive an immediate refund confirmation.
```

## Implementation Leak

Including technical details that belong in implementation, not requirements.
Farley's test: "Imagine replacing your system with something else that fulfills
the same function—the tests you are writing should still make sense."

```
❌ Given the order status is "PENDING" in the orders table
   When the cancel button onClick handler fires
   Then the Redux store is updated

✅ Given a customer has a pending order
   When they request cancellation
   Then the order is cancelled and refund initiated
```

## UI-Focused Criteria

Describing button clicks and screen flows instead of business rules. Farley warns
that criteria referencing UI elements break whenever the interface changes.
Shore: "Don't describe button clicks and workflows. Focus on business rules."

```
❌ Given the user is on the order detail page
   When they click the red "Cancel" button
   Then a modal appears with a "Confirm" button

✅ Given a customer has a pending order
   When they request cancellation
   Then the order is cancelled and they receive a refund confirmation
```

## Vague Outcome

Outcomes that can't be tested because they're too abstract.

```
❌ Then the system handles it appropriately
❌ Then an error is shown

✅ Then they see which items were cancelled and the refund amount
✅ Then they are informed why cancellation failed and what to do next
```

## Missing Failure Modes

Only covering the happy path without considering what goes wrong.

```
❌ [Only happy path—what happens when things go wrong?]

✅ Include scenarios for:
   - Order already shipped
   - Payment refund fails
   - Partial fulfillment
```

## Giant Story

Trying to capture too much in a single story. Cohn's rule of thumb: if acceptance
criteria have different priorities or would make the story too large for a sprint,
split the story instead of adding more criteria.

```
❌ "User can manage their entire account including profile,
    preferences, security, billing, and notifications"

✅ Split into focused stories:
   - Profile updates
   - Security settings
   - Billing management
   (each with focused acceptance criteria)
```

## Criteria Overload

Too many acceptance criteria signal the story needs splitting, not more detail.

**When to add criteria** (Cohn): all criteria have similar priority and the story
still fits within a sprint.

**When to split instead** (Cohn): criteria have different priorities, or together
they make the story too large. Use SPIDR—split by Spike, Path, Interfaces, Data,
or Rules.

```
❌ Story with 12 acceptance criteria covering login, password recovery,
   MFA setup, session management, and account lockout

✅ Split into:
   - Basic authentication (login with credentials)
   - Password recovery flow
   - Multi-factor authentication setup
   (each with 2–4 focused criteria)
```

## Criteria as Requirements

Treating acceptance criteria as exhaustive specifications rather than conversation
starters. Cohn: "Think of user stories as pointers to a requirement, not
requirements themselves." Shore: stories are "promissory notes for future
conversation."

```
❌ 15 detailed criteria covering every edge case, field validation rule,
   and error message—written before any team conversation

✅ High-level conditions of satisfaction that prompt discussion:
   - Cancellation confirmed within the same session
   - Refund initiated for all payment methods
   - Customer notified of cancellation status
   (details emerge through team conversation)
```

## Over-Specifying Too Early

Adding precision before the team has had the conversation. Cohn: "By waiting until
the work begins to discuss specific solutions and acceptance criteria, the team is
more likely to get things right." Premature detail limits creativity and wastes time.

```
❌ (Written months before development)
   "Must authenticate via Facebook OAuth 2.0 with PKCE flow"

✅ (Written early, refined later)
   "Customers can sign in with their social media accounts"
   → specific providers and auth flows decided when work begins
```

## Technical Stories

Framing stories around technical tasks instead of user value. Farley: "Inside every
technical story there is a user value trying to escape." Technical decisions are a
cost of building features, not separate work items.

```
❌ "Migrate user table to new schema"
❌ "Set up Redis caching layer"

✅ "Customers see their order history load within one second"
   (schema migration and caching are implementation details)
```

## Dependent Scenarios

Scenarios that require other scenarios to run first.

```
❌ Scenario: View order details
   Given the user completed Scenario 1...

✅ Each scenario should be independently testable with its own setup
```

## Abstract Examples

Using placeholders instead of concrete values. Shore: "Be completely specific.
It's tempting to create generic examples, but those get confusing quickly."
Concrete examples reveal edge cases that generic ones hide.

```
❌ Given a customer with [some status]
   When they do [some action]
   Then [something happens]

✅ Given a customer has an order in "confirmed" status
   When they request to cancel the order
   Then the order status changes to "cancelled"
```

---

**How many acceptance criteria?** See [criteria-quantity.md](criteria-quantity.md)
for heuristics from Farley, Cohn, and Shore on when to add criteria vs. split the
story.
