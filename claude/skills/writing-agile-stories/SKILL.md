---
name: writing-agile-stories
description: "Write behavior-focused Agile user stories with BDD-style acceptance criteria. Use when defining features, clarifying requirements, creating development tickets, writing acceptance criteria, converting requirements to testable specs, or discussing user needs. Produces narrative-form stories with Given-When-Then scenarios."
---

# Writing Agile Stories

Reference for behavior-focused user stories using BDD principles. Stories describe desired behavior from the user's perspective, focusing on "what" rather than "how."

This is a **non-interactive reference skill**. Callers — direct users, orchestrator commands, and sub-agents — supply context and apply this guidance directly. Do not use `AskUserQuestion`. If context is thin, ask the user in plain prose for what's missing (see [discovery-dimensions.md](references/discovery-dimensions.md)).

## Quick Start

A complete story:

```markdown
## Story: Customer Cancels Order Before Shipment

When customers change their mind about a purchase, they need to cancel it
and receive confirmation that their refund is being processed. This must
happen before the order ships, since the returns process applies afterward.

### Context
Available for orders in "confirmed" or "processing" status.

### Acceptance Criteria

#### Scenario: Successful cancellation
- Given a customer has an order in "confirmed" status
- When they request to cancel the order
- Then the order status changes to "cancelled"
- And a refund is initiated for the full order amount

#### Scenario: Order already shipped
- Given an order has left the warehouse
- When the customer attempts to cancel
- Then they are informed cancellation is unavailable
- And they are directed to the returns process
```

## When This Skill Applies

- Defining new features or user needs
- Clarifying requirements before implementation
- Creating tickets for development work
- Converting vague requirements into testable specifications
- User asks to "write a story" or "create acceptance criteria"

## Core Principles

1. **Behavior over Implementation** — describe what users experience, not how it's built
2. **Narrative over Template** — use prose, NOT "As a [user], I want [feature], so that [benefit]"
3. **Concrete over Abstract** — use specific examples (Specification by Example)
4. **Conversation Starter** — stories facilitate discussion, not replace it
5. **Ubiquitous Language** — use terms from the problem domain, not technical jargon

## The Primary Anti-Pattern: Implementation Leak

The single most common defect. A scenario leaks if it references:

- HTTP/API behavior ("the API returns 200", "POST /orders endpoint")
- Database or storage ("the row is inserted", "the cache is invalidated", named tables)
- UI elements ("the button is clicked", "the modal appears", "the page loads")
- Code paths or services ("OrderService is called", "the handler fires")
- Technical mechanisms ("retries 3 times", "publishes a Kafka event", "Redis is updated")

**Farley's test**: imagine the entire system replaced with a different implementation that fulfills the same behavior. The acceptance criteria should still make sense. If they would break, they describe implementation, not behavior.

See [anti-patterns.md](references/anti-patterns.md) for concrete leak examples and rewrites.

---

## Phase 1: Discovery

**Goal**: Gather the dimensions needed to draft.

The six dimensions: **Actor, Trigger, Outcome, Constraints, Failure Modes, Domain Terms**. See [discovery-dimensions.md](references/discovery-dimensions.md) for definitions, examples, and what each missing dimension does to the story.

If the caller has supplied context (Jira/Linear ticket, codebase research, prior conversation), extract the dimensions from that context. If the dimensions are thin, ask the user in plain prose for the missing ones — open-ended discovery questions don't fit `AskUserQuestion` option chips.

### Discovery Output (internal scratchpad)

```
**Understanding**: [1-2 sentence summary]
**Actor**: [Who] | **Trigger**: [What prompts this]
**Outcome**: [What they achieve] | **Constraints**: [Rules]
**Failure Modes**: [What could go wrong]
**Domain Terms**: [Key vocabulary]
```

---

## Phase 2: Story Drafting

**Goal**: Write a narrative-form story that captures the essence of the need.

### Story Format

```markdown
## Story: [Descriptive Title]

[2-4 sentence narrative describing:
 - The user's situation
 - The behavior they need
 - The value they get
Written in domain language, present tense]

### Context
[When this behavior is relevant — the business preconditions]
```

### Narrative Guidelines

**DO**:
- Describe the situation that creates the need
- Focus on observable behavior
- Use domain language consistently
- Keep it small enough for one iteration

**DON'T**:
- Use "As a [user], I want [X], so that [Y]" template
- Include implementation details (APIs, databases, buttons)
- Write epic-sized stories
- Use technical jargon outside the domain

---

## Phase 3: Acceptance Criteria

**Goal**: Define testable scenarios using Given-When-Then format.

### Scenario Types Required

1. **Happy Path** — the primary success scenario
2. **Alternative Paths** — valid variations with different outcomes
3. **Failure Modes** — how errors are handled gracefully

### Criteria Format

```markdown
### Acceptance Criteria

#### Scenario: [Description]
- Given [business context/state]
- When [user action or system event]
- Then [observable outcome]
- And [additional outcomes if needed]
```

### Criteria Guidelines

**DO**:
- Use business language in Given-When-Then
- Focus on observable outcomes
- Include concrete examples (specific values, not placeholders)
- Make each scenario independently testable

**DON'T**:
- Reference implementation details (see Implementation Leak above)
- Write scenarios that depend on each other
- Only include happy path
- Use vague outcomes ("handles appropriately")

### Outline First

List scenario types before detailing:
```
1. Happy path: [description]
2. Alternative: [description]
3. Failure: [description]
```

How many criteria are right? See [criteria-quantity.md](references/criteria-quantity.md).

---

## Phase 4: Review

**Goal**: Validate the story against quality criteria.

### Quality Checklist

| Check | Anti-Pattern to Avoid |
|-------|----------------------|
| Behavior-focused | Implementation details, feature lists |
| Domain language only | "user clicks", "API returns" |
| Narrative form | "As a [user], I want..." template |
| Small & testable | Epic-sized, vague outcomes |
| Failure modes included | Only happy path scenarios |
| Scenarios independent | Scenarios requiring sequence |

### Verification Questions

1. Can a developer write tests directly from these scenarios?
2. Can a business stakeholder understand every term?
3. Is each scenario independently verifiable?
4. Are all failure modes covered?
5. Is the story small enough for one iteration?

### Final Presentation

When presenting the finished story, accompany it with the quality checklist showing which items pass.

---

## Handling Edge Cases

### Caller Provides Implementation-Focused Requirements

Reframe toward behavior:
- "What outcome does the user want from this button/API/feature?"
- "If we ignore how it's built, what should the user experience?"

### Discovery Reveals an Epic

When a "story" is too large:
1. Acknowledge it's epic-sized
2. Use `skeleton-of-thought` to propose 3-5 smaller stories
3. Note dependencies between stories

### Caller Insists on Template Format

Briefly explain the narrative approach. If the caller still prefers template, accommodate but encourage behavior focus.

### Unclear When Story is "Done"

A story is ready when:
- All quality checks pass
- Scenarios are testable without implementation knowledge

---

## Reference Files

- [discovery-dimensions.md](references/discovery-dimensions.md) — six dimensions to gather before drafting
- [anti-patterns.md](references/anti-patterns.md) — common mistakes with examples
- [examples.md](references/examples.md) — complete story examples with discovery and criteria
- [templates.md](references/templates.md) — output templates and canonical example
- [criteria-quantity.md](references/criteria-quantity.md) — when to add criteria vs. split the story
- [thinking-patterns.md](references/thinking-patterns.md) — structured reasoning by phase

---

## Quick Reference

| Phase | Goal | Key Output |
|-------|------|------------|
| Discovery | Gather dimensions | Actor, trigger, outcome, constraints, failure modes, domain terms |
| Drafting | Narrative story | 2-4 sentence description + context |
| Criteria | Testable scenarios | Given-When-Then for happy/alt/failure |
| Review | Quality check | Validated story ready for use |

**Anti-patterns to avoid**: Template smell, implementation leak, vague outcomes, missing failures, giant stories. See [anti-patterns.md](references/anti-patterns.md).
