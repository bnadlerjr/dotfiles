# Story Templates

## Complete Story Template

```markdown
## Story: [Descriptive Title]

[Narrative: 2-4 sentences describing situation, behavior, and outcome
in domain language]

### Context
[When this behavior is relevant]

### Acceptance Criteria

#### Scenario: [Happy path]
- Given [context]
- When [action]
- Then [outcome]

#### Scenario: [Alternative path]
- Given [different context]
- When [action]
- Then [different outcome]

#### Scenario: [Failure case]
- Given [failure context]
- When [action]
- Then [graceful handling]

---

### Notes
[Optional: Domain terms defined, open questions, related stories]
```

## Discovery Output Template

```markdown
**Understanding**: [1-2 sentence summary of the user need]

**Actor**: [Who experiences this need]
**Trigger**: [What situation prompts this behavior]
**Outcome**: [What they want to achieve]
**Constraints**: [Business rules that apply]
**Failure Modes**: [What could go wrong]

**Domain Terms**:
- [Term]: [Definition in business language]
```

## Quality Check Template

Present with final story:

```markdown
Quality checks:
- ✅ Behavior-focused (no implementation details)
- ✅ Domain language throughout
- ✅ Narrative form (no template)
- ✅ Small and testable
- ✅ Failure modes included
- ✅ Scenarios are independent
```

## Canonical Example

### Story: Customer Cancels Order Before Shipment

When customers change their mind about a purchase, they need to cancel it
and receive confirmation that their refund is being processed. This must
happen before the order ships, since the returns process applies afterward.

#### Context
Available for orders in "confirmed" or "processing" status that haven't
been handed off to shipping.

#### Acceptance Criteria

##### Scenario: Successful cancellation of unshipped order
- Given a customer has an order in "confirmed" status
- When they request to cancel the order
- Then the order status changes to "cancelled"
- And a refund is initiated for the full order amount
- And they receive a cancellation confirmation

##### Scenario: Attempting to cancel an already-shipped order
- Given an order has already left the warehouse
- When the customer attempts to cancel
- Then they are informed the order cannot be cancelled
- And they are directed to the returns process
