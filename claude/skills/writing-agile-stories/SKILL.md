---
name: writing-agile-stories
description: "Write behavior-focused Agile user stories with BDD-style acceptance criteria. Use when defining features, clarifying requirements, creating development tickets, writing acceptance criteria, converting requirements to testable specs, or discussing user needs. Produces narrative-form stories with Given-When-Then scenarios."
allowed-tools:
  - AskUserQuestion
---

# Writing Agile Stories

Create behavior-focused user stories using BDD principles. Stories describe desired behavior from the user's perspective, focusing on "what" rather than "how."

## Quick Start

Describe the user need in 2-4 sentences, then add Given-When-Then scenarios:

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

1. **Behavior over Implementation**: Describe what users experience, not how it's built
2. **Narrative over Template**: Use prose, NOT "As a [user], I want [feature], so that [benefit]"
3. **Concrete over Abstract**: Use specific examples (Specification by Example)
4. **Conversation Starter**: Stories facilitate discussion, not replace it
5. **Ubiquitous Language**: Use terms from the problem domain, not technical jargon

## Process Overview

```
Discovery  ──▶  Drafting  ──▶  Criteria  ──▶  Review
Understand      Narrative      Given-When-   Quality
the need        form story     Then          check
```

---

## Phase 1: Discovery

**Goal**: Understand the user need before writing anything.

When invoked without context, ask what user need or feature to define. Accept descriptions, ticket references, or vague ideas to explore together.

### Discovery Questions (ask 2-3 at a time)

**Round 1 - Actor & Context**
- Who experiences this need? (their situation/role in the domain)
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

### Discovery Output

```
**Understanding**: [1-2 sentence summary]
**Actor**: [Who] | **Trigger**: [What prompts this]
**Outcome**: [What they achieve] | **Constraints**: [Rules]
**Failure Modes**: [What could go wrong]
**Domain Terms**: [Key vocabulary]
```

### Confirm Understanding

Use **AskUserQuestion**:
- Header: "Understanding"
- Question: "Does this capture the user need correctly?"
- Options: "Yes, proceed" | "Minor adjustments" | "Significant gaps"

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

### Get Feedback

Use **AskUserQuestion**:
- Header: "Story draft"
- Question: "How does this story draft look?"
- Options: "Good, write criteria" | "Adjust narrative" | "Too large, split it" | "Start over"

---

## Phase 3: Acceptance Criteria

**Goal**: Define testable scenarios using Given-When-Then format.

### Scenario Types Required

1. **Happy Path**: The primary success scenario
2. **Alternative Paths**: Valid variations with different outcomes
3. **Failure Modes**: How errors are handled gracefully

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
- Include concrete examples
- Make each scenario independently testable

**DON'T**:
- Reference implementation details
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

Use **AskUserQuestion** to confirm coverage before writing details.

### Confirm Criteria

Use **AskUserQuestion**:
- Header: "Criteria"
- Question: "Are these acceptance criteria complete?"
- Options: "Yes, finalize" | "Adjust scenarios" | "Add edge cases"

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

### Review Questions

1. Can a developer write tests directly from these scenarios?
2. Can a business stakeholder understand every term?
3. Is each scenario independently verifiable?
4. Are all failure modes covered?
5. Is the story small enough for one iteration?

### Final Presentation

Present the complete story with quality checks:
```
✅ Behavior-focused (no implementation details)
✅ Domain language throughout
✅ Narrative form (no template)
✅ Small and testable
✅ Failure modes included
✅ Scenarios are independent
```

### Next Action

Use **AskUserQuestion**:
- Header: "Next step"
- Question: "Story is complete. What would you like to do?"
- Options: "Create Jira ticket" | "Save to file" | "Write related story" | "Done"

Actions:
- **Create Jira ticket**: Use `jira-cli-expert` agent
- **Save to file**: Write to `$(claude-docs-path tickets)/` (see [managing-claude-docs](../managing-claude-docs/SKILL.md) for path resolution)
- **Write related story**: Start new story with shared context

---

## Handling Edge Cases

### User Provides Implementation-Focused Requirements

Reframe toward behavior:
- "What outcome does the user want from this button/API/feature?"
- "If we ignore how it's built, what should the user experience?"

### Discovery Reveals an Epic

When a "story" is too large:
1. Acknowledge it's epic-sized
2. Use `skeleton-of-thought` to propose 3-5 smaller stories
3. Ask which to write first
4. Note dependencies between stories

### User Insists on Template Format

Explain the narrative approach briefly, then offer:
- "Would you like to try narrative form for this story?"
- If they prefer template, accommodate but encourage behavior focus

### Unclear When Story is "Done"

A story is ready when:
- All quality checks pass
- User confirms criteria are complete
- Scenarios are testable without implementation knowledge

---

## Integration with Other Skills

**Before Implementation**: Stories feed into `/plan` or `implementation-planning`
- Story defines WHAT to build
- Plan defines HOW to build it

**With Jira**: Create tickets via `jira-cli-expert`
- Title = Story title
- Description = Narrative + context
- Acceptance Criteria = Checklist

**With Testing**: Criteria map to test cases
- Each scenario = one or more tests
- Given = test setup
- When = action under test
- Then = assertions

---

## Reference Files

- [examples.md](references/examples.md) - Complete story examples with discovery and criteria
- [anti-patterns.md](references/anti-patterns.md) - Common mistakes with examples
- [templates.md](references/templates.md) - Output templates and canonical example
- [thinking-patterns.md](references/thinking-patterns.md) - Structured reasoning by phase

---

## Quick Reference

| Phase | Goal | Key Output |
|-------|------|------------|
| Discovery | Understand need | Actor, trigger, outcome, constraints |
| Drafting | Narrative story | 2-4 sentence description + context |
| Criteria | Testable scenarios | Given-When-Then for happy/alt/failure |
| Review | Quality check | Validated story ready for use |

**Anti-patterns to avoid**: Template smell, implementation leak, vague outcomes, missing failures, giant stories. See [anti-patterns.md](references/anti-patterns.md).
