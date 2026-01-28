---
name: agile-story
description: "Write behavior-focused Agile user stories with BDD-style acceptance criteria. Use when defining features, clarifying requirements, or creating development tickets. Produces narrative-form stories with Given-When-Then scenarios."
---

# Agile Story Writing

Create behavior-focused user stories using BDD principles. Stories describe desired behavior from the user's perspective, focusing on "what" rather than "how."

## When This Skill Applies

- Defining new features or user needs
- Clarifying requirements before implementation
- Creating tickets for development work
- User asks to "write a story" or "create acceptance criteria"
- Converting vague requirements into testable specifications

## Invocation

**Command**: `/agile-story` or `/agile-story [description]`

### Initial Response

When invoked:

1. **If a description was provided**: Begin discovery by asking clarifying questions about the provided topic

2. **If no description provided**, respond with:
```
I'll help you write a behavior-focused user story. Let me understand what we're building.

What user need or feature would you like to define?

You can provide:
- A brief description of the need
- A ticket reference to expand
- A vague idea to explore together

I'll guide you through discovery, drafting, and acceptance criteria.
```

## Core Principles

1. **Behavior over Implementation**: Describe what users experience, not how it's built
2. **Narrative over Template**: Use prose, NOT "As a [user], I want [feature], so that [benefit]"
3. **Concrete over Abstract**: Use specific examples (Specification by Example)
4. **Conversation Starter**: Stories facilitate discussion, not replace it
5. **Ubiquitous Language**: Use terms from the problem domain, not technical jargon

## Process Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Discovery  │ ──▶ │   Drafting  │ ──▶ │  Criteria   │ ──▶ │   Review    │
│             │     │             │     │             │     │             │
│ Understand  │     │  Narrative  │     │ Given-When- │     │  Quality    │
│ the need    │     │  form story │     │ Then        │     │  check      │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

---

## Phase 1: Discovery

**Goal**: Understand the user need before writing anything.

### Questions to Ask (in small batches, 2-3 at a time)

**Round 1 - Actor & Context**
- Who experiences this need? (their situation/role in the domain, not just "user")
- What situation or event triggers this need?

**Round 2 - Outcome & Value**
- What outcome do they want to achieve?
- How will they know they succeeded?

**Round 3 - Boundaries & Failures**
- What constraints or business rules apply?
- What could go wrong? How should failures be handled?

**Round 4 - Domain Language**
- What terms does the business use for these concepts?
- Are there terms that might be ambiguous?

### Thinking Pattern Integration

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Requirements span multiple domains | `atomic-thought` | Decompose into independent facts from each area |
| Multiple stakeholder perspectives | `atomic-thought` | Understand each viewpoint separately |
| Unclear which need is primary | `tree-of-thoughts` | Explore different framings of the problem |

### Discovery Output

```
**Understanding**: [1-2 sentence summary of the user need]

**Actor**: [Who experiences this need]
**Trigger**: [What situation prompts this behavior]
**Outcome**: [What they want to achieve]
**Constraints**: [Business rules that apply]
**Failure Modes**: [What could go wrong]

**Domain Terms**:
- [Term]: [Definition in business language]
```

### User Confirmation

Present your understanding, then use **AskUserQuestion** to confirm:

- Header: "Understanding"
- Question: "Does this capture the user need correctly?"
- Options:
  - "Yes, proceed to drafting" → Continue to Phase 2
  - "Mostly, minor adjustments" → Ask what to adjust, then re-confirm
  - "No, significant gaps" → Return to discovery questions

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
[When this behavior is relevant - the business preconditions]
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

### Thinking Pattern Integration

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Multiple valid story framings | `tree-of-thoughts` | Evaluate alternatives before committing |
| Synthesizing from multiple sources | `graph-of-thoughts` | Combine discovery findings coherently |
| Story seems too large | `skeleton-of-thought` | Outline split options before detailing |

### Example Narrative

**AVOID** (template smell):
```
As a customer, I want to click a cancel button so that I can cancel my order.
```

**PREFER** (narrative form):
```
## Story: Customer Cancels Order Before Shipment

When customers change their mind about a purchase, they need to cancel it
and receive confirmation that their refund is being processed. This must
happen before the order ships, since the returns process applies afterward.

### Context
Available for orders in "confirmed" or "processing" status that haven't
been handed off to shipping.
```

### User Feedback

Present the draft, then use **AskUserQuestion** to get feedback:

- Header: "Story draft"
- Question: "How does this story draft look?"
- Options:
  - "Good, write acceptance criteria" → Continue to Phase 3
  - "Adjust the narrative" → Ask what to change, revise, re-confirm
  - "Story is too large, split it" → Use `skeleton-of-thought` to propose splits
  - "Start over" → Return to Phase 1

---

## Phase 3: Acceptance Criteria

**Goal**: Define testable scenarios using Given-When-Then format.

### Criteria Format

```markdown
### Acceptance Criteria

#### Scenario: [Happy path description]
- Given [business context/state]
- When [user action or system event]
- Then [observable outcome]
- And [additional outcomes if needed]

#### Scenario: [Alternative path]
- Given [different context]
- When [action]
- Then [different outcome]

#### Scenario: [Failure case]
- Given [context that causes failure]
- When [action]
- Then [graceful handling]
```

### Scenario Types Required

1. **Happy Path**: The primary success scenario
2. **Alternative Paths**: Valid variations that produce different outcomes
3. **Failure Modes**: How the system handles errors gracefully
4. **Edge Cases**: Boundary conditions (optional but valuable)

### Criteria Guidelines

**DO**:
- Use business language in Given-When-Then
- Focus on observable outcomes
- Include concrete examples where helpful
- Make each scenario independently testable

**DON'T**:
- Reference implementation details ("database", "API", "button")
- Write scenarios that depend on each other
- Only include happy path
- Use vague outcomes ("handles appropriately")

### Thinking Pattern Integration

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Identifying all scenarios | `skeleton-of-thought` | Outline scenario types first, then detail |
| Complex business logic | `chain-of-thought` | Trace each path step-by-step |
| Verifying completeness | `chain-of-thought` | Walk through each scenario systematically |

### Scenario Outline

Use `skeleton-of-thought` to outline scenarios first:
```
I'll outline the scenarios we need:
1. [Happy path]
2. [Alternative: ...]
3. [Failure: ...]
4. [Edge case: ...]
```

Use **AskUserQuestion** to confirm scenario coverage:
- Header: "Scenarios"
- Question: "Are these the right scenarios to detail?"
- Options:
  - "Yes, detail them" → Write Given-When-Then for each
  - "Add more scenarios" → Ask which scenarios are missing
  - "Remove some" → Ask which to remove

### Criteria Confirmation

After detailing scenarios, use **AskUserQuestion**:
- Header: "Criteria"
- Question: "Are these acceptance criteria complete?"
- Options:
  - "Yes, finalize the story" → Continue to Phase 4
  - "Adjust scenarios" → Ask what to change
  - "Add edge cases" → Discuss and add

### Example Criteria

**AVOID** (implementation leak):
```
#### Scenario: Cancel order
- Given the order status is "PENDING" in the orders table
- When user clicks the red cancel button
- Then the /api/orders/{id}/cancel endpoint is called
- And a refund record is created
```

**PREFER** (business focus):
```
#### Scenario: Successful cancellation of unshipped order
- Given a customer has an order in "confirmed" status
- When they request to cancel the order
- Then the order status changes to "cancelled"
- And a refund is initiated for the full order amount
- And they receive a cancellation confirmation

#### Scenario: Attempting to cancel an already-shipped order
- Given an order has already left the warehouse
- When the customer attempts to cancel
- Then they are informed the order cannot be cancelled
- And they are directed to the returns process
```

---

## Phase 4: Review

**Goal**: Validate the story against quality criteria before finalizing.

### Quality Checklist

| Check | Anti-Pattern to Avoid |
|-------|----------------------|
| Behavior-focused | ❌ Implementation details, feature lists |
| Domain language only | ❌ "user clicks", "system processes", "API returns" |
| Narrative form | ❌ "As a [user], I want..." template |
| Small & testable | ❌ Epic-sized, vague outcomes |
| Failure modes included | ❌ Only happy path scenarios |
| Scenarios independent | ❌ Scenarios requiring sequence |
| Concrete examples | ❌ Abstract statements without specifics |

### Thinking Pattern Integration

| Situation | Pattern | Application |
|-----------|---------|-------------|
| High-stakes or complex story | `self-consistency` | Multiple reasoning paths to validate |
| Verifying scenario coverage | `chain-of-thought` | Systematic walkthrough |
| Checking language consistency | `atomic-thought` | Isolate each term and verify usage |

### Review Questions

1. Can a developer write tests directly from these scenarios?
2. Can a business stakeholder understand every term used?
3. Is each scenario independently verifiable?
4. Are all failure modes covered?
5. Is the story small enough for one iteration?

### Final Presentation

Present final story with quality checks:

```
## Story: [Title]

[Narrative]

### Context
[When this applies]

### Acceptance Criteria
[All scenarios]

---

Quality checks:
- ✅ Behavior-focused (no implementation details)
- ✅ Domain language throughout
- ✅ Narrative form (no template)
- ✅ Small and testable
- ✅ Failure modes included
- ✅ Scenarios are independent
```

### Next Action

Use **AskUserQuestion** for next action:
- Header: "Next step"
- Question: "Story is complete. What would you like to do?"
- Options:
  - "Create Jira ticket" → Use `jira-cli-expert` to create ticket
  - "Save to file" → Write to `$(claude-docs-path tickets)/`
  - "Write related story" → Start new story with shared context
  - "Done" → End workflow

---

## Complete Output Template

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

---

## Anti-Patterns

### Template Smell
```
❌ As a user, I want to click cancel so that my order is cancelled.

✅ When customers change their mind before shipment, they can cancel
   and receive an immediate refund confirmation.
```

### Implementation Leak
```
❌ Given the order status is "PENDING" in the orders table
   When the cancel button onClick handler fires
   Then the Redux store is updated

✅ Given a customer has a pending order
   When they request cancellation
   Then the order is cancelled and refund initiated
```

### Vague Outcome
```
❌ Then the system handles it appropriately
❌ Then an error is shown

✅ Then they see which items were cancelled and the refund amount
✅ Then they are informed why cancellation failed and what to do next
```

### Missing Failure Mode
```
❌ [Only happy path—what happens when things go wrong?]

✅ Scenario: Order already shipped
   Scenario: Payment refund fails
   Scenario: Partial fulfillment
```

### Giant Story
```
❌ "User can manage their entire account including profile,
    preferences, security, billing, and notifications"

✅ Split into: Profile updates, Security settings, Billing management
   (each with focused acceptance criteria)
```

---

## Integration with Other Skills

### Before Implementation Planning
Stories feed into `/plan` or `implementation-planning` skill:
- Story defines WHAT to build
- Plan defines HOW to build it

### With Jira
Stories can be created as Jira tickets via `jira-cli-expert`:
- Title → Story title
- Description → Narrative + context
- Acceptance Criteria → Checklist or description section

### With Testing
Acceptance criteria map directly to test cases:
- Each scenario → one or more test cases
- Given → test setup
- When → action under test
- Then → assertions

---

## Quick Reference

**Phase 1 - Discovery**: Ask about actor, trigger, outcome, constraints, failures, language

**Phase 2 - Drafting**: Narrative form, domain language, no implementation details

**Phase 3 - Criteria**: Given-When-Then, happy + alternative + failure scenarios

**Phase 4 - Review**: Check against anti-patterns, verify testability

**Thinking Patterns**:
- `atomic-thought` → Complex multi-domain requirements
- `tree-of-thoughts` → Multiple valid framings
- `skeleton-of-thought` → Outlining scenarios
- `chain-of-thought` → Tracing business logic
- `graph-of-thoughts` → Synthesizing discovery findings
- `self-consistency` → Final validation

---

## Tips for Better Stories

- Stories are conversation starters, not complete specs
- If you can't test it, rewrite it
- Smaller is almost always better
- Domain experts should understand every word
- Implementation details belong in the plan, not the story
