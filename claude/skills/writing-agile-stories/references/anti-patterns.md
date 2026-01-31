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

```
❌ Given the order status is "PENDING" in the orders table
   When the cancel button onClick handler fires
   Then the Redux store is updated

✅ Given a customer has a pending order
   When they request cancellation
   Then the order is cancelled and refund initiated
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

Trying to capture too much in a single story.

```
❌ "User can manage their entire account including profile,
    preferences, security, billing, and notifications"

✅ Split into focused stories:
   - Profile updates
   - Security settings
   - Billing management
   (each with focused acceptance criteria)
```

## Dependent Scenarios

Scenarios that require other scenarios to run first.

```
❌ Scenario: View order details
   Given the user completed Scenario 1...

✅ Each scenario should be independently testable with its own setup
```

## Abstract Examples

Using placeholders instead of concrete values.

```
❌ Given a customer with [some status]
   When they do [some action]
   Then [something happens]

✅ Given a customer has an order in "confirmed" status
   When they request to cancel the order
   Then the order status changes to "cancelled"
```
