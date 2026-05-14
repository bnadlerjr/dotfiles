# PRD Authoring Guide

Detailed guidance for the three sections of a PRD: High-Level Requirements, Use Case Compendium, and Milestone Definition. Use this alongside [workflow-phases.md](workflow-phases.md), which sequences the work. See [kabletown-example.md](kabletown-example.md) for a complete worked PRD.

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

**Do**:
- Reference the Product Brief explicitly
- Call out trade-offs between competing principles
- State which persona/scenario is prioritized first
- Set expectations for guardrails and limitations

**Don't**:
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

**CRITICAL**: Extract ALL requirements from ALL scenarios, but only assign milestone values to the first milestone. See [Prioritization Strategy](#prioritization-strategy) below.

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

Notice: Only 5 of 7 requirements have milestone values. The last 2 are left blank — they'll be prioritized when planning a future milestone.

### Output Format

**IMPORTANT**: All requirements from all scenarios are combined into a **single table**. Do not create separate tables for each north star scenario.

| Column | Description |
|--------|-------------|
| **Requirement** | The specific behavior from user's perspective |
| **Milestone** | 1.0 (MVP), 1.5 (MLP stretch), or **blank** (prioritize later) |
| **Persona** | Which persona benefits |
| **North Star** | Which scenario this derives from |

The North Star column provides traceability to the source scenario, making separate tables unnecessary.

**Milestone values are sparse, not dense.** Most requirements should have a blank milestone. If you find yourself assigning 1.0 or 1.5 to most rows, stop — you're not prioritizing.

---

## Milestone Definition

Milestones select which features ship in each release.

### Milestone Criteria

For the first milestone:
- Focus on one persona if multiple exist
- Target frequent/common tasks over edge cases
- Prioritize safety and guardrails over maximum capability
- Include feedback/measurement mechanisms early

### Format

**Only define Milestone 1.** Future milestones are NOT defined — their requirements are already captured with blank milestone values in the Use Case Compendium.

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

## Prioritization Strategy

Prioritization is one of the most challenging and consequential parts of product work. **If everything is prioritized, nothing is prioritized.** You need a strategy.

### The Bang-for-Buck Strategy

Optimize **bang-for-the-buck**: prioritize scenarios and features by combining user impact (bang) with all-up company effort (buck).

**User Impact = Scale × Value per User** (over your chosen time horizon)

- **Scale/Reach**: How many users will this affect?
- **Value per User**: How much does each user benefit?
- **Effort**: Engineering, design, ops, support — all costs

High bang, low buck = prioritize aggressively.
High bang, high buck = consider carefully.
Low bang, any buck = defer.

### Four Brutal Truths

Building something valuable for users is hard. Keep these realities in mind:

1. **Scale is hard.** Products with high impact AND high scale are rare achievements.
2. **User value is back-loaded.** The utility function is non-linear — products are useless until they gain critical mass of functionality.
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

**The north star scenario defines milestone 1.** Requirements from other scenarios get blank milestones — they'll be prioritized when planning future milestones.

### Milestone Values

Only assign milestone values for the first milestone. Everything else stays blank.

**1.0 - MVP (Must ship)**
Can't ship or get user feedback without it. These are non-negotiable for the north star scenario to work.

**1.5 - MLP (Stretch)**
Super compelling stretch goals executed closer to ship time. If the schedule slips, you'll ship something viable without these — but you won't be happy about it.

**Blank - Everything else**
Prioritize when you plan the next milestone. Don't waste time ranking what won't ship soon.

### Expected Distribution

A well-prioritized compendium should look like:

| Milestone | Expected % of Requirements |
|-----------|----------------------------|
| 1.0 | 15-25% (the minimum needed for north star) |
| 1.5 | 10-15% (stretch goals for polish) |
| Blank | 60-75% (everything else) |

**If more than 40% of requirements have milestone values, you're not prioritizing — you're listing.**

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

**Do**:
- Focus milestone 1 on ONE north star scenario
- Use 1.0 only for requirements without which the north star fails
- Use 1.5 sparingly for polish that makes the north star shine
- Leave 60%+ of requirements with blank milestone
- Capture all requirements — just don't prioritize them yet

**Don't**:
- Prioritize everything — it defeats the purpose
- Mark most items as 1.0 (if everything is priority, nothing is)
- Assign milestone values to non-north-star scenarios
- Feel pressure to "complete" the milestone column
