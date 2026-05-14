# PRD Workflow Phases

Detailed instructions for each phase of building a Product Requirements Document from a Product Brief.

---

## Phase 1: Extraction

**Goal**: Read and understand the Product Brief to identify key elements.

### What to Extract

1. **Product Thesis**: The core claims about why this will work
2. **Personas**: Named users with distinct needs
3. **Metrics**: Adoption, value, and business metrics
4. **North Star Scenarios**: Narrative stories to break down
5. **Risks/Antithesis**: Constraints that shape requirements

### Extraction Output

```
**Product**: [Name]
**Thesis Summary**: [1-2 sentence summary of main claims]

**Personas**:
- [Persona 1]: [Brief description and primary goal]
- [Persona 2]: [Brief description and primary goal]

**Key Metrics**:
- Adoption: [Current → Target]
- Value: [Current → Target]
- Business: [Expected direction]

**Scenarios to Process**:
1. [Scenario 1 title] - [Persona]
2. [Scenario 2 title] - [Persona]
...

**Key Risks**:
- [Risk 1 that shapes requirements]
- [Risk 2 that shapes requirements]
```

### User Confirmation

Present extraction summary, then use **AskUserQuestion**:

- Header: "Extraction"
- Question: "Does this capture the key elements from the Product Brief?"
- Options:
  - "Yes, proceed to high-level requirements" → Continue to Phase 2
  - "Missing important context" → Ask what's missing
  - "Incorrect interpretation" → Clarify and re-extract

**Sub-agent fallback**: If `AskUserQuestion` is unavailable, proceed to Phase 2 using the extraction as-is and note any uncertainties under an "Assumptions" line in the output.

---

## Phase 2: High-Level Requirements

**Goal**: Establish design principles and priority decisions.

### Questions to Answer

1. **Primary goal**: What's the main thing we're optimizing for?
2. **Persona priority**: Which persona do we serve first?
3. **Scope priority**: Which scenarios are in-scope for milestone 1?
4. **Trade-offs**: Where do we break ties between competing goods?
5. **Guardrails**: How conservative vs. aggressive is our approach?

### High-Level Requirements Format

```markdown
## High-Level Requirements

- Per the Product Brief, [primary goal from thesis]
- We're focusing on [persona/scenario type] for the first milestone
- We're prioritizing [thing A] over [thing B] because [rationale]
- When [situation], we will [conservative/aggressive choice] even if [trade-off]
```

### Guidelines

**Calling out trade-offs is valuable because**:
- It sparks discussion and surfaces disagreement early
- It sets clear expectations for reviewers
- It makes the rest of the document easier to follow

**Common trade-offs to address**:
- Which persona comes first if resources are limited
- Safety/guardrails vs. maximum capability
- Frequent tasks vs. edge cases
- Automation vs. human escalation
- Revenue impact vs. user experience

### User Confirmation

Present high-level requirements, then use **AskUserQuestion**:

- Header: "Principles"
- Question: "Do these design principles capture the right priorities?"
- Options:
  - "Yes, proceed to use cases" → Continue to Phase 3
  - "Adjust priorities" → Discuss changes
  - "Missing key trade-off" → Add and re-confirm

**Sub-agent fallback**: If `AskUserQuestion` is unavailable, proceed to Phase 3 and surface chosen trade-offs explicitly so the caller can challenge them on review.

---

## Phase 3: Use Case Compendium

**Goal**: Break down each north star scenario into fine-grained requirements. **All requirements from all scenarios are combined into a single unified table.**

### Process Per Scenario

For each north star scenario:

1. **Read the scenario** narrative carefully
2. **Identify each interaction** the user has with the product
3. **Write a requirement** for each interaction
4. **Assign milestone** based on priority decisions
5. **Verify traceability** back to the scenario

### Requirement Writing Checklist

For each requirement, verify:

- [ ] Written from user's perspective (not system's)
- [ ] Concrete enough to be unambiguous
- [ ] Express intent, not just feature
- [ ] Allows design latitude for implementation
- [ ] References source scenario

### Breakdown Template

For each scenario step, ask:
- "What must [persona] be able to do here?"
- "What outcome must [persona] receive?"
- "What must the system remember or learn?"

### Example Breakdown Process

**Scenario**: Customer hardware problem

```
"Sad Lisa's internet is slow, and she blames Kabletown. She sees the
Helpy 'get support' button at kabletown.com and clicks it."
```

**Requirements extracted**:
1. **Entry point**: Lisa can easily find Helpy on the home page without first logging in when looking for tech support
2. **Discoverability**: Helpy is visible and clearly labeled for support (e.g., chatbot button)

```
"Helpy asks her questions about her setup, discovering that she's on a
PC laptop on wireless. It figures out there's no outage..."
```

**Requirements extracted**:
3. **Diagnostics**: Helpy can gather setup information through guided questions
4. **Context awareness**: Helpy can check outage status for user's location

And so on through the scenario...

### Milestone Assignment Criteria

**Milestone 1.0** (MVP) — assign if:
- Required for the prioritized persona's north star to work end-to-end
- Part of the happy path for the chosen north star
- Needed for measurement/feedback
- Safety-critical guardrails

**Milestone 1.5** (MLP stretch) — assign if:
- Polish that makes the north star shine
- Compelling but slippable if the schedule tightens

**Blank** (defer prioritization) — leave blank for:
- Requirements from other scenarios (not the chosen north star)
- Learning/improvement features that can ship with a manual process first
- Edge cases that don't block the main flow
- Advanced features for secondary personas
- Nice-to-have optimizations

### User Review

After processing all scenarios, present the complete use case compendium as a **single unified table** (not separate tables per scenario), then use **AskUserQuestion**:

- Header: "Use Cases"
- Question: "Are these requirements complete for all scenarios?"
- Options:
  - "Yes, proceed to milestones" → Continue to Phase 4
  - "Missing requirements" → Add missing items
  - "Adjust milestone assignments" → Discuss priority

**Sub-agent fallback**: If `AskUserQuestion` is unavailable, proceed to Phase 4. Flag any scenarios where you suspect requirements may be missing in a short "Coverage Notes" callout above the table.

**Note**: The North Star column provides traceability to source scenarios, eliminating the need for separate tables.

---

## Phase 4: Milestone Definition

**Goal**: Define scope boundaries for each release.

### Milestone 1 Definition Process

1. **Filter `1.0` requirements** from the use case compendium
2. **Group by theme**: What capability areas are covered?
3. **Verify completeness**: Can users complete key flows?
4. **Define exclusions**: What's explicitly deferred (i.e., the `1.5` and blank rows)?

### Milestone Format

```markdown
### Milestone 1: [Theme Name]

**Goal**: [What this milestone proves or enables - one sentence]

**Persona focus**: [Primary persona this milestone serves]

**Scope**:
- [Capability area 1 - high level summary]
- [Capability area 2 - high level summary]
- [Measurement mechanisms included]

**Explicitly excluded**:
- [Deferred capability 1] - [Why deferred]
- [Deferred capability 2] - [Why deferred]
```

### Exclusion Rationale

Explicitly stating what's excluded and why:
- Sets expectations with stakeholders
- Prevents scope creep
- Documents intentional decisions
- Creates backlog for future milestones

### User Confirmation

Present milestone definitions, then use **AskUserQuestion**:

- Header: "Milestones"
- Question: "Does this milestone scope look right?"
- Options:
  - "Yes, proceed to review" → Continue to Phase 5
  - "Milestone 1 scope too large" → Discuss what to defer
  - "Milestone 1 scope too small" → Discuss what to include
  - "Wrong items excluded" → Adjust assignments

**Sub-agent fallback**: If `AskUserQuestion` is unavailable, proceed to Phase 5 with the current scope and call out any boundary calls (in/out) you made unilaterally.

---

## Phase 5: Review

**Goal**: Validate the complete PRD against quality criteria.

### Completeness Checklist

| Section | Check |
|---------|-------|
| High-Level Requirements | Priority decisions are explicit |
| Use Case Compendium | All scenarios have requirements |
| Milestone Definition | Clear scope and exclusions |
| Traceability | Every requirement links to a scenario |

### Quality Checks

| Check | Anti-Pattern to Avoid |
|-------|----------------------|
| User perspective | System/implementation language |
| Concrete | Vague "discoverable", "easy" |
| Intent-revealing | Feature without why |
| Design latitude | Over-prescription |
| Traceable | Orphan requirements |
| Prioritized | No milestone assignments |

### Coverage Matrix

Verify every scenario has requirements:

```
| Scenario   | Requirements | 1.0 | 1.5 | Blank |
|------------|--------------|-----|-----|-------|
| Scenario 1 | 7            | 4   | 1   | 2     |
| Scenario 2 | 5            | 0   | 0   | 5     |
| ...        | ...          | ... | ... | ...   |
```

### Review Questions

1. Can an engineer build from these requirements without asking "what should it do?"
2. Can a designer create flows without being over-constrained?
3. Is every trade-off decision explicit in high-level requirements?
4. Does every requirement trace to a scenario?
5. Is milestone 1 scope coherent and achievable?

### Readability Polish

PRDs are consumed by humans — engineers, designers, product, and stakeholders. After the content passes the quality checks above, run the prose through the `writing-for-humans` skill to remove LLM tics, hedge phrases, and structural bloat.

**What to polish**: the prose sections only — High-Level Requirements bullets and Milestone Definition bodies (Goal, Persona focus, Scope, Excluded).

**What to preserve verbatim**:
- The Use Case Compendium table (structured data, not prose)
- Requirement wording inside the table (already constrained by the writing checklist in Phase 3)
- Section headings (preserve the canonical PRD structure)
- Code blocks, links, persona names, and metric values

Invoke the `writing-for-humans` skill on the assembled PRD, passing the preserve/transform contract above so the Use Case Compendium table, persona names, requirement wording, and metric values survive the rewrite.

Replace the draft with the polished output. Spot-check that the table and headings survived intact before saving.

**Fallback**: If `writing-for-humans` is unavailable, skip the polish step and note "Readability polish deferred — recommend running `writing-for-humans` on the prose sections before circulation." in the handoff.

### Next Action

Use **AskUserQuestion** for next action:

- Header: "Next step"
- Question: "PRD is complete. What would you like to do?"
- Options:
  - "Generate user stories" → Use `writing-agile-stories` for the `1.0` requirements
  - "Create implementation plan" → Use `planning-tdd`
  - "Done" → End workflow

**Sub-agent fallback**: If `AskUserQuestion` is unavailable, end the workflow by returning the completed PRD and noting the candidate next steps in the report. Let the caller pick.
