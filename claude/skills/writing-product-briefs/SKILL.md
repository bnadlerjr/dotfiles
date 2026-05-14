---
name: writing-product-briefs
description: "Write Product Briefs that align teams on goals before discovery. Use when defining a new product vision, articulating problem statements, creating one-pagers, or crafting north star scenarios. Produces vision documents with thesis/antithesis, target audience, metrics, and narrative scenarios."
---

# Product Brief Writing

Create vision documents that get everyone aligned on goals. A Product Brief unblocks discovery by giving a clear, intuitive idea of what we're trying to accomplish—before diving into requirements or solutions.

## When This Skill Applies

- Starting a new product or major initiative
- Articulating a problem statement or vision
- Creating a "one-pager" or "problem brief"
- User asks for "north star scenarios" or "product thesis"
- Need to align stakeholders before writing requirements
- Converting vague product ideas into clear direction

## Quick Start

Minimum viable path:

1. Ask the user about the problem, current state, and stakes.
2. Draft a thesis (specific, falsifiable claims) and an antithesis (honest risks).
3. Name 1-3 personas and define adoption, value, and business metrics with baselines and targets.
4. Write 3-5 north star scenarios in narrative form, including at least one failure or escalation case.
5. Present, iterate, and stop when the brief enables action.

Fall through to the detailed phases below for prompts, anti-patterns, and review checks.

## When Invoked

This skill is auto-loaded when its description matches the user's request, can be invoked directly via the Skill tool, or is triggered indirectly when the user runs the companion `/product-brief` slash command.

When the skill loads without an explicit topic, ask the user what product or initiative they want to define. Accept any of:

- A problem they're trying to solve
- A product idea to explore
- An existing initiative needing clarity

Then guide them through thesis, audience, metrics, and north star scenarios using the phases below.

## Core Principles

1. **Vision over Requirements**: Describe what success looks like, not how to build it
2. **Narrative over Lists**: Use stories (north star scenarios) to make goals intuitive
3. **Honest Assessment**: Include antithesis/risks—what could cause this to fail
4. **Outcome-Focused Metrics**: Track value delivered, not features shipped
5. **Focus over Breadth**: A complete brief is one that enables action, not one that covers everything

## Process Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Discovery  │ ──▶ │   Thesis    │ ──▶ │   Metrics   │ ──▶ │  Scenarios  │
│             │     │             │     │             │     │             │
│ Problem &   │     │ Claims &    │     │ Goals &     │     │ North star  │
│ context     │     │ risks       │     │ tracking    │     │ stories     │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

Phase 5 (Review) follows Scenarios and checks completeness before saving. For detailed phase instructions, see [workflow-phases.md](references/workflow-phases.md). Several phases recommend named thinking patterns (atomic-thought, tree-of-thoughts, skeleton-of-thought, chain-of-thought, graph-of-thoughts, self-consistency); see the `thinking-patterns` skill for pattern details.

---

## Output Template

```markdown
# Product Brief for [Product Name]

[Brief vision statement—what this product will do and why it matters.]

## Product Thesis

We make [N] basic claims:

**[Claim 1 Title]**
[Explanation of claim and why it will work]

**[Claim 2 Title]**
[Explanation of second claim]

## Antithesis/Risks

What might cause this to not work as we expect?

- [Risk 1]
- [Risk 2]
- [Risk 3]

## Target Audience

We have [N] target personas:

**[Persona Name]**
[Description of persona, their situation, and primary goal]

**[Second Persona]**
[Description]

## Product Goals

[Summary of primary goals]

**Adoption metric**
[Specific metric with baseline → target]

**Value metric**
[Outcome metric with baseline → target]

**KPI**
[Business metric and expected direction]

## North Star Scenarios

**[Scenario 1 Title]**
[Narrative story with persona, situation, interaction, resolution, value capture]

**[Scenario 2 Title]**
[Second narrative story]

**[Scenario 3 Title]**
[Third narrative story, including at least one failure/escalation case]
```

---

## Example

For a complete example, see [kabletown-example.md](references/kabletown-example.md).

Key elements demonstrated:
- Two clear thesis claims (reduced frustration, lowered toil)
- Specific, falsifiable risks
- Named personas (Tinker Tia, Sad Lisa)
- Metrics with current baselines and targets
- Five scenarios covering happy paths, edge cases, and escalation

---

## Anti-Patterns

### Vague Thesis
```
Bad: "Our product will be better than competitors"
Bad: "Users will love it"

Good: "Users will resolve issues faster because the assistant
       understands intent better, getting handoff decisions right
       80% more often than the current system"
```

### Missing Antithesis
```
Bad: [No risks section]
Bad: "Minor risks: timeline might slip"

Good: "The assistant might take actions it shouldn't, causing users
       to be unpleasantly surprised—which would increase frustration
       instead of reducing it"
```

### Feature-as-Goal
```
Bad: "Launch feature X by Q2"
Bad: "Ship mobile app"

Good: "Increase fully automated support interactions from 15% to 65%"
```

### Scenario Without Value Capture
```
Bad: "User does the thing and it works. The end."

Good: "Once the technician reports install complete, Helpy checks
       back with her to do a survey."
```

### Implementation in Scenario
```
Bad: "She clicks the blue 'Help' button which opens a modal with
      a WebSocket connection to our support API..."

Good: "She sees the Helpy button and asks what's going on. Helpy
       checks her address against the outage map..."
```

---

## Tips for Better Briefs

- The brief is complete when it enables action, not when it's comprehensive
- Thesis claims should make you slightly nervous—if they're too safe, dig deeper
- Every scenario should reveal at least one requirement you hadn't explicitly listed
- If you can't demo a scenario, it's too abstract
- Revisit the brief when scenarios reveal gaps in thesis or metrics
