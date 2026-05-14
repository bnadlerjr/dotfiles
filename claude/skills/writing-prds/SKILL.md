---
name: writing-prds
description: "Build Product Requirements Documents from Product Briefs. Use when transforming product vision into actionable requirements for engineers and designers. Produces high-level design principles, use case compendiums, and milestone definitions. A PRD focuses on 'what' not 'how'."
allowed-tools:
  - AskUserQuestion
  - Read
  - Write
---

# Writing Product Requirements Documents

Transform Product Briefs into actionable PRDs that unblock engineers and UI designers. A PRD captures the "what" while leaving the "how" to implementation teams.

## Quick Start

Point me at a Product Brief and I'll extract personas, scenarios, and metrics, then walk through five phases (Extraction → High-Level Requirements → Use Case Compendium → Milestone Definition → Review) to produce a PRD. If no path is provided, paste the Brief inline.

## When This Skill Applies

- Converting a Product Brief into requirements
- Creating fine-grained use case specifications
- Defining milestone scope for releases
- User asks for "PRD", "requirements document", or "use case compendium"
- Need to unblock engineering/design work after product discovery

## Invocation

### Initial Response

When invoked:

1. **If a Product Brief path was provided**: Read the brief and begin extraction
2. **If no path provided**, respond with:

```
I'll help you build a Product Requirements Document from a Product Brief.

Please provide:
- A path to your Product Brief, OR
- Paste the Product Brief content directly

A PRD includes:
1. High-level requirements and design principles
2. Use case compendium (fine-grained requirements)
3. Milestone definitions

I'll guide you through extracting requirements from your north star scenarios.
```

### Sub-agent Fallback

When `AskUserQuestion` is unavailable (e.g., running as a sub-agent), do not stall waiting for user confirmation. Proceed using best-judgment defaults at each phase boundary and surface assumptions explicitly in the output (e.g., an "Assumptions" note above the section, or inline italics on chosen priorities). The caller will review the full document and request changes.

## Core Principles

1. **What over How**: Describe required behavior, not implementation
2. **Intent over Prescription**: Express goals while allowing design latitude
3. **Concrete over Vague**: Be specific enough to be unambiguous
4. **Prioritized over Comprehensive**: Define milestones to focus effort
5. **Traceable over Isolated**: Every requirement traces to a scenario

## PRD Structure

A complete PRD has three sections:

1. **High-Level Requirements** — design principles and priority decisions
2. **Use Case Compendium** — fine-grained requirements by scenario, in one unified table
3. **Milestone Definition** — which features ship in the first release

## Five-Phase Quick Reference

The workflow has five phases. For full details, see [workflow-phases.md](references/workflow-phases.md). For section-level authoring guidance (formats, examples, prioritization strategy), see [authoring-guide.md](references/authoring-guide.md).

**Phase 1 — Extraction**: Read the Product Brief; identify personas, metrics, north star scenarios, and risks.

**Phase 2 — High-Level Requirements**: State design principles and priority trade-offs.

**Phase 3 — Use Case Compendium**: Break each north star scenario into atomic requirements; combine into one unified table.
- Use `/thinking atomic-thought` to decompose scenarios systematically.

**Phase 4 — Milestone Definition**: Choose one north star to define milestone 1; mark requirements `1.0` / `1.5` / blank.
- Use `/thinking tree-of-thoughts` for north star selection and prioritization.

**Phase 5 — Review**: Verify coverage, check quality, save or hand off.
- Use `/thinking self-consistency` to validate before finalizing.

## Milestone Values

Use these values in the Use Case Compendium:

- **1.0** — MVP. Required for the north star scenario to work.
- **1.5** — MLP stretch. Polish that makes the north star shine.
- **(blank)** — Defer prioritization to a future milestone.

Target distribution: 15–25% at `1.0`, 10–15% at `1.5`, **60–75% blank**. If more than 40% have milestone values, you're listing, not prioritizing.

## Anti-Patterns

### Implementation in requirements

Bad: "Helpy uses a WebSocket connection to maintain chat state"
Bad: "A React modal component displays the chat interface"
Good: "Lisa can continue her support conversation across page navigation"

### Vague requirements

Bad: "Helpy is discoverable"
Bad: "Users can get support"
Good: "Lisa can easily find Helpy on the home page without first logging in"

### Missing intent

Bad: "Helpy is on the home page"
Good: "Lisa can easily find Helpy on the home page without first logging in when she's looking for tech support."

### Orphan requirements

Bad: Requirements that don't trace to any scenario
Good: Every requirement references its source scenario via the North Star column

## Thinking Pattern Integration

PRD prioritization is consequential — wrong decisions waste engineering effort. Visible reasoning surfaces assumptions, documents trade-offs, and enables course-correction.

| Phase | Pattern | Why |
|-------|---------|-----|
| Phase 3 — extracting requirements | `/thinking atomic-thought` | Decompose each scenario into independent requirement atoms |
| Phase 4 — choosing the north star | `/thinking tree-of-thoughts` | Compare trade-offs between candidate scenarios |
| Phase 4 — assigning `1.0` vs `1.5` | `/thinking tree-of-thoughts` | Evaluate bang-for-buck across requirements |
| Phase 5 — final review | `/thinking self-consistency` | Validate coverage and prioritization decisions |

## Integration with Other Skills

**From**: `writing-product-briefs` → `writing-prds`. Thesis informs high-level requirements; personas and scenarios carry over directly.

**To**: `writing-prds` → `slicing-elephant-carpaccio` (slice features into thin vertical increments), `writing-agile-stories` (each use case becomes a story candidate), or `planning-tdd` (use cases define what to build; milestones define scope).

## Reference Files

- [workflow-phases.md](references/workflow-phases.md) — Detailed phase-by-phase instructions
- [authoring-guide.md](references/authoring-guide.md) — Section formats, examples, prioritization strategy
- [kabletown-example.md](references/kabletown-example.md) — Complete PRD example

## Output Template

```markdown
# Product Requirements Document: [Product Name]

## High-Level Requirements

- [Primary goal and constraints from Product Brief]
- [Persona/scenario priority for first milestone]
- [Key trade-off decisions]
- [Safety/guardrail stance]

## Use Case Compendium

| Requirement | Milestone | Persona | North Star |
|-------------|-----------|---------|------------|
| [North star requirement 1] | 1.0 | [Persona] | [North star scenario] |
| [North star requirement 2] | 1.0 | [Persona] | [North star scenario] |
| [North star stretch goal] | 1.5 | [Persona] | [North star scenario] |
| [Future requirement] | | [Persona] | [North star scenario] |
| [Other scenario requirement] | | [Persona] | [Other scenario] |
| ... | | ... | ... |

*Note: 60–75% of requirements should have blank milestone values.*

## Milestone Definitions

### Milestone 1: [Theme]
**Goal**: [What this proves]
**Persona focus**: [Primary persona]
**North star scenario**: [The scenario that defines this milestone]
**Scope**: [Capabilities included]
**Excluded**: [What's deferred and why]
```

**CRITICAL**: Only define Milestone 1. Do NOT create placeholder sections for future milestones (Milestone 2, 3, etc.) with "To be defined" or "Anticipated scope" content. Requirements for future work are already captured in the Use Case Compendium with blank milestone values — that's sufficient. Future milestone definitions happen when planning actually begins for those milestones.
