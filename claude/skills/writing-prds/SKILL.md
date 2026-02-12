---
name: writing-prds
description: "Build Product Requirements Documents from Product Briefs. Use when transforming product vision into actionable requirements for engineers and designers. Produces high-level design principles, use case compendiums, and milestone definitions. A PRD focuses on 'what' not 'how'."
allowed-tools:
  - AskUserQuestion
---

# Writing Product Requirements Documents

Transform Product Briefs into actionable PRDs that unblock engineers and UI designers. A PRD captures the "what" while leaving the "how" to implementation teams.

## When This Skill Applies

- Converting a Product Brief into requirements
- Creating fine-grained use case specifications
- Defining milestone scope for releases
- User asks for "PRD", "requirements document", or "use case compendium"
- Need to unblock engineering/design work after product discovery

## Invocation

**Command**: `/writing-prds` or `/writing-prds [product-brief-path]`

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

## Core Principles

1. **What over How**: Describe required behavior, not implementation
2. **Intent over Prescription**: Express goals while allowing design latitude
3. **Concrete over Vague**: Be specific enough to be unambiguous
4. **Prioritized over Comprehensive**: Define milestones to focus effort
5. **Traceable over Isolated**: Every requirement traces to a scenario

## PRD Structure

A complete PRD has three sections:

```
┌─────────────────────┐
│  High-Level Reqs    │  ← Design principles, priority decisions
├─────────────────────┤
│  Use Case           │  ← Fine-grained requirements by scenario
│  Compendium         │
├─────────────────────┤
│  Milestone          │  ← Which features ship when
│  Definition         │
└─────────────────────┘
```

## Process Overview

```
Product Brief  ──▶  High-Level  ──▶  Use Cases  ──▶  Milestones  ──▶  Review
                    Principles       Extraction       Definition
```

For detailed phase instructions, see [workflow-phases.md](references/workflow-phases.md).

---

## Quick Reference

**Phase 1 - Extraction**: Read Product Brief, identify personas, metrics, scenarios

**Phase 2 - High-Level Requirements**: Design principles, priority trade-offs

**Phase 3 - Use Case Compendium**: Break down scenarios into requirements
→ Use `/thinking atomic-thought` to decompose scenarios systematically

**Phase 4 - Milestone Definition**: Scope first release, sequence features
→ Use `/thinking tree-of-thoughts` for north star selection and prioritization

**Phase 5 - Review**: Verify coverage, check quality, save or proceed
→ Use `/thinking self-consistency` to validate before finalizing

---

## High-Level Requirements

High-level requirements establish what you're "going for" with the design. They communicate priority decisions and build trust with stakeholders who won't read every use case.

### Format

```markdown
## High-Level Requirements

Per the Product Brief:
- [Primary goal from product thesis]
- [Which persona or metric is prioritized for first milestone]
- [Key trade-off decision - what you're optimizing for vs. against]
- [Safety/risk stance - how conservative vs. aggressive]
```

### Guidelines

**DO**:
- Reference the Product Brief explicitly
- Call out trade-offs between competing principles
- State which persona/scenario is prioritized first
- Set expectations for guardrails and limitations

**DON'T**:
- Repeat the entire Product Brief
- Avoid controversial priority decisions
- Leave ambiguity about what comes first

### Example

```markdown
## High-Level Requirements

- Per the Product Brief, we're trying to increase user satisfaction and
  lower support burden while being revenue neutral.
- We're focusing on technical support interactions for the first milestone.
- We're going to target the frequent tasks, such as slow internet diagnosis,
  first. When Helpy detects something outside its expertise, it will delegate
  to a human rather than trying to help.
- We'll be focused on safety early to keep Helpy within clear guardrails
  even if that means sometimes not being as helpful as it could.
```

---

## Use Case Compendium

The use case compendium lists each requirement from the user's perspective. Each requirement is a snippet of a north star scenario. **All requirements from all scenarios are presented in a single unified table**, not separate tables per scenario.

**CRITICAL**: Extract ALL requirements from ALL scenarios, but only assign milestone values to the first milestone. See [Prioritizing Requirements](#prioritizing-requirements-for-the-first-milestone) for the strategy.

### Requirement Format

Template: `"[Product] provides [feature] so that [user] can [achieve value]."`

Or simply: `"[User] can [do something specific] when [situation]."`

### Writing Guidelines

| Principle | Do | Don't |
|-----------|-----|-------|
| **Concrete** | "on the home page without logging in" | "discoverable" |
| **Intent-revealing** | "so Lisa can find support quickly" | (feature only, no why) |
| **Design latitude** | "discoverable (e.g., chatbot button in lower right)" | "button at coordinates 800,600" |
| **Traceable** | Reference the scenario it came from | Orphan requirements |

### Breaking Down a Scenario

For each north star scenario:

1. **Identify the trigger**: What situation creates the need?
2. **Extract each interaction step**: What must the user be able to do?
3. **Capture outcomes**: What results must the user receive?
4. **Include learning/feedback loops**: How does the system improve?

### Example Breakdown

**Scenario**: Customer hardware problem (Sad Lisa)

| Requirement | Milestone | Persona | North Star |
|-------------|-----------|---------|------------|
| Lisa can easily find Helpy on the home page without first logging in when looking for tech support | 1.0 | Sad Lisa | Customer hardware problem |
| Helpy can efficiently guide Lisa through diagnostics of slow internet, with causes ranging from software to hardware outages | 1.0 | Sad Lisa | Customer hardware problem |
| Helpy suggests the most successful interventions learned from the support database | 1.0 | Sad Lisa | Customer hardware problem |
| When remediations are inconclusive, Helpy suggests future follow-ups before signing off | 1.5 | Sad Lisa | Customer hardware problem |
| Lisa is presented satisfaction surveys to track results | 1.5 | Sad Lisa | Customer hardware problem |
| Helpy asks Lisa what worked so it can keep learning as technology changes | | Sad Lisa | Customer hardware problem |
| Helpy can be trained on satisfaction surveys to become more effective | | Sad Lisa | Customer hardware problem |

Notice: Only 5 of 7 requirements have milestone values. The last 2 are left blank—they'll be prioritized when planning a future milestone.

---

## Use Case Compendium Output Format

**IMPORTANT**: All requirements from all scenarios are combined into a **single table**. Do not create separate tables for each north star scenario.

| Column | Description |
|--------|-------------|
| **Requirement** | The specific behavior from user's perspective |
| **Milestone** | 1.0 (MVP), 1.5 (MLP stretch), or **blank** (prioritize later) |
| **Persona** | Which persona benefits |
| **North Star** | Which scenario this derives from |

The North Star column provides traceability to the source scenario, making separate tables unnecessary.

**Milestone values are sparse, not dense.** Most requirements should have a blank milestone. If you find yourself assigning 1.0 or 1.5 to most rows, stop—you're not prioritizing.

---

## Milestone Definition

Milestones select which features ship in each release.

### Milestone Criteria

For the first milestone (M1):
- Focus on one persona if multiple exist
- Target frequent/common tasks over edge cases
- Prioritize safety and guardrails over maximum capability
- Include feedback/measurement mechanisms early

### Format

**Only define Milestone 1.** Future milestones are NOT defined—their requirements are already captured with blank milestone values in the Use Case Compendium.

```markdown
## Milestone Definitions

### Milestone 1: [Theme]
**Goal**: [What this milestone proves or achieves]
**Persona focus**: [Primary persona]
**Scope**:
- [High-level capability 1]
- [High-level capability 2]
- [Measurement/feedback mechanisms]

**Explicitly excluded**:
- [What's deferred]
- [Why it's deferred]
```

**NEVER** include placeholder sections like:
```markdown
### Milestone 2: [Theme]
*To be defined when planning begins for this milestone.*
**Anticipated scope**: ...
```

This is waste. The blank-milestone requirements in the compendium already capture future work.

---

## Prioritizing Requirements for the First Milestone

Prioritization is one of the most challenging and consequential parts of product work. **If everything is prioritized, nothing is prioritized.** You need a strategy.

### The Bang-for-Buck Strategy

Optimize **bang-for-the-buck**: prioritize scenarios and features by combining user impact (bang) with all-up company effort (buck).

**User Impact = Scale × Value per User** (over your chosen time horizon)

- **Scale/Reach**: How many users will this affect?
- **Value per User**: How much does each user benefit?
- **Effort**: Engineering, design, ops, support—all costs

High bang, low buck = prioritize aggressively.
High bang, high buck = consider carefully.
Low bang, any buck = defer.

### Four Brutal Truths

Building something valuable for users is hard. Keep these realities in mind:

1. **Scale is hard.** Products with high impact AND high scale are rare achievements.
2. **User value is back-loaded.** The utility function is non-linear—products are useless until they gain critical mass of functionality.
3. **Competitive differentiation is even more back-loaded.** Unless you're inventing something novel, you need feature parity before anyone takes you seriously.
4. **Sustaining value over time is hard.** Enduring user value is harder than temporary wins.

### MVP vs. MLP

| Approach | Focus | When to Use |
|----------|-------|-------------|
| **MVP** (Minimum Viable Product) | Truth #2: User value | You need early feedback on whether users want this at all |
| **MLP** (Minimum Lovable Product) | Truth #3: Differentiated value | You're entering an established market and need to compete |

### North Star Prioritization Strategy

Define your MVP or MLP by prioritizing requirements for **one north star scenario** (or minimal set if one isn't enough). This approach has key advantages:

- **Positive utility**: North stars are complete stories, so we deliver real value
- **Product vision**: They embody our best thinking, so we ship something with impact
- **Focus**: One persona and story lets us defer extraneous features and push generalizations to later

**The north star scenario defines milestone 1.** Requirements from other scenarios get blank milestones—they'll be prioritized when planning future milestones.

### Milestone Values

Only assign milestone values for the first milestone. Everything else stays blank.

**1.0 - MVP (Must ship)**
Can't ship or get user feedback without it. These are non-negotiable for the north star scenario to work.

**1.5 - MLP (Stretch)**
Super compelling stretch goals executed closer to ship time. If the schedule slips, you'll ship something viable without these—but you won't be happy about it.

**Blank - Everything else**
Prioritize when you plan the next milestone. Don't waste time ranking what won't ship soon.

### Expected Distribution

A well-prioritized compendium should look like:

| Milestone | Expected % of Requirements |
|-----------|----------------------------|
| 1.0 | 15-25% (the minimum needed for north star) |
| 1.5 | 10-15% (stretch goals for polish) |
| Blank | 60-75% (everything else) |

**If more than 40% of requirements have milestone values, you're not prioritizing—you're listing.**

### Prioritization Table Format

| Requirement | Milestone | Persona | North Star |
|-------------|-----------|---------|------------|
| Lisa can find Helpy on home page without logging in | 1.0 | Sad Lisa | Customer hardware |
| Helpy guides Lisa through slow internet diagnostics | 1.0 | Sad Lisa | Customer hardware |
| Helpy asks Lisa what worked to keep learning | 1.5 | Sad Lisa | Customer hardware |
| Helpy learns from satisfaction surveys | | Sad Lisa | Customer hardware |
| Admin can configure Helpy's knowledge base | | Admin Andy | Admin management |
| Helpy escalates billing issues to human agents | | Sad Lisa | Billing dispute |

Notice: Only north star scenario requirements get milestone values. Other scenarios are captured but left blank.

### Prioritization Guidelines

**DO**:
- Focus milestone 1 on ONE north star scenario
- Use 1.0 only for requirements without which the north star fails
- Use 1.5 sparingly for polish that makes the north star shine
- Leave 60%+ of requirements with blank milestone
- Capture all requirements—just don't prioritize them yet

**DON'T**:
- Prioritize everything—it defeats the purpose
- Mark most items as 1.0 (if everything is priority, nothing is)
- Assign milestone values to non-north-star scenarios
- Feel pressure to "complete" the milestone column

---

## Thinking Pattern Integration

Use `/thinking` patterns at key decision points to produce visible, auditable reasoning.

| PRD Phase | Pattern | Why |
|-----------|---------|-----|
| Extracting requirements from scenarios | `atomic-thought` | Decompose each scenario into independent requirement atoms |
| Choosing which north star to prioritize | `tree-of-thoughts` | Compare trade-offs between candidate scenarios |
| Assigning milestone values (1.0 vs 1.5) | `tree-of-thoughts` | Evaluate bang-for-buck across requirements |
| Final review before saving | `self-consistency` | Validate coverage and prioritization decisions |

### When to Invoke

**Extracting requirements** (Phase 3):
```
/thinking atomic-thought
Break down the "Sad Lisa - Customer hardware problem" scenario into atomic requirements.
```

**Prioritization decisions** (Phase 4):
```
/thinking tree-of-thoughts
Which north star scenario should define Milestone 1? Consider scale, value, effort.
```

**Validating the PRD** (Phase 5):
```
/thinking self-consistency
Verify: Does every 1.0 requirement trace to the north star? Are we under 40% prioritized?
```

### Why This Matters

PRD prioritization is consequential—wrong decisions waste engineering effort. Visible reasoning:
- Surfaces assumptions for stakeholder review
- Documents the "why" behind trade-offs
- Enables course-correction before implementation

---

## Integration with Other Skills

### From Product Brief
`writing-product-briefs` → `writing-prds`
- Thesis informs high-level requirements
- Personas carry over directly
- Scenarios become use case sources

### To Feature Slicing
`writing-prds` → `slicing-elephant-carpaccio`
- Slice features from the use case compendium into thin vertical increments before writing stories

### To User Stories
`writing-prds` → `writing-agile-stories`
- Each use case becomes a story candidate
- Milestone assignment guides sprint planning

### To Implementation
`writing-prds` → `implementation-planning`
- Use cases define what to build
- Milestones define scope boundaries

---

## Anti-Patterns

### Implementation in Requirements
```
❌ "Helpy uses a WebSocket connection to maintain chat state"
❌ "A React modal component displays the chat interface"

✅ "Lisa can continue her support conversation across page navigation"
```

### Vague Requirements
```
❌ "Helpy is discoverable"
❌ "Users can get support"

✅ "Lisa can easily find Helpy on the home page without first logging in"
```

### Missing Intent
```
❌ "Helpy is on the home page"

✅ "Lisa can easily find Helpy on the home page without first logging in
    when she's looking for tech support."
```

### Orphan Requirements
```
❌ Requirements that don't trace to any scenario

✅ Every requirement references its source scenario
```

---

## Reference Files

- [workflow-phases.md](references/workflow-phases.md) - Detailed phase instructions
- [kabletown-example.md](references/kabletown-example.md) - Complete PRD example

---

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
| [Other scenario requirement] | | [Persona] | [Other scenario] |
| ... | | ... | ... |

*Note: ~60-75% of requirements should have blank milestone values.*

## Milestone Definitions

### Milestone 1: [Theme]
**Goal**: [What this proves]
**Persona focus**: [Primary persona]
**North star scenario**: [The scenario that defines this milestone]
**Scope**: [Capabilities included]
**Excluded**: [What's deferred and why]
```

**CRITICAL**: Only define Milestone 1. Do NOT create placeholder sections for future milestones (Milestone 2, 3, etc.) with "To be defined" or "Anticipated scope" content. Requirements for future work are already captured in the Use Case Compendium with blank milestone values—that's sufficient. Future milestone definitions happen when planning actually begins for those milestones.
