# Product Brief Workflow Phases

Detailed instructions for each phase of the product brief workflow.

---

## Phase 1: Discovery

**Goal**: Understand the problem space and business context.

### Questions to Ask (2-3 at a time)

**Round 1 - Problem & Context**
- What problem are you trying to solve?
- Who experiences this problem today?
- What's the current situation (status quo)?

**Round 2 - Motivation & Stakes**
- Why solve this now? What's changed or changing?
- What happens if you don't solve it?
- What's the scope—greenfield product, new feature, or improvement?

**Round 3 - Success & Constraints**
- How will you know you've succeeded?
- What constraints exist (technical, business, regulatory)?
- Who are the key stakeholders that need to align?

### Thinking Pattern Integration

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Problem spans multiple domains | `atomic-thought` | Decompose into independent aspects |
| Multiple valid problem framings | `tree-of-thoughts` | Explore different angles |
| Synthesizing stakeholder input | `graph-of-thoughts` | Combine perspectives |

### Discovery Output

```
**Problem Space**: [2-3 sentence summary of the core problem]

**Current State**: [What exists today and why it's insufficient]
**Desired State**: [What success looks like at a high level]
**Stakes**: [Why this matters, what happens if unsolved]
**Constraints**: [Known limitations]
```

### User Confirmation

Present your understanding, then use **AskUserQuestion** to confirm:

- Header: "Problem"
- Question: "Does this capture the problem correctly?"
- Options:
  - "Yes, proceed to thesis" → Continue to Phase 2
  - "Adjust the framing" → Ask what to change, re-confirm
  - "Missing key context" → Return to discovery questions

---

## Phase 2: Product Thesis

**Goal**: Articulate the core claims about why this product will work.

### Thesis Structure

The thesis answers: "Why will this product succeed where others haven't?"

Each claim should be:
- **Specific**: Not "will be better" but "will do X because Y"
- **Falsifiable**: Could be proven wrong—that's the point
- **Value-focused**: About outcomes, not features

### Thesis Format

```markdown
## Product Thesis

We make [N] basic claims:

**[Claim 1 Title]**
[2-3 sentences explaining the claim. What specifically will improve?
Why will your approach work? What's the mechanism of value?]

**[Claim 2 Title]**
[2-3 sentences for the second claim...]
```

### Antithesis/Risks

Every thesis needs its antithesis. Ask: "What might cause this to not work?"

```markdown
## Antithesis/Risks

What might cause this to not work as we expect?

- [Risk 1: Specific concern that could invalidate a thesis claim]
- [Risk 2: External factor that could undermine success]
- [Risk 3: Assumption that might be wrong]
```

### Guidelines

**DO**:
- State claims as beliefs to be validated
- Connect claims to specific value mechanisms
- Include honest risks that could invalidate the thesis

**DON'T**:
- Make claims you can't imagine being wrong
- Hide risks to make the brief look better
- Confuse features with value claims

### Thinking Pattern Integration

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Formulating thesis claims | `skeleton-of-thought` | Outline claims before detailing |
| Stress-testing claims | `self-consistency` | Validate through multiple angles |
| Identifying risks | `tree-of-thoughts` | Explore failure modes systematically |

### User Feedback

Present thesis and antithesis, then use **AskUserQuestion**:

- Header: "Thesis"
- Question: "Do these claims capture your core beliefs about why this will work?"
- Options:
  - "Yes, proceed to audience & metrics" → Continue to Phase 3
  - "Adjust claims" → Ask what to change
  - "Add/remove claims" → Discuss and revise
  - "Risks are incomplete" → Add more risks

---

## Phase 3: Audience & Metrics

**Goal**: Define who benefits and how to measure success.

### Target Audience

Create named personas that represent distinct user segments:

```markdown
## Target Audience

We have [N] target personas:

**[Persona Name]**
[Descriptive nickname] is a [role/situation description] who wants to
[primary goal]. [Optional: Additional context about their situation,
pain points, or what makes them distinct.]

**[Second Persona Name]**
[Similar format...]
```

### Naming Guidelines

- Use alliterative or memorable names (Tinker Tia, Sad Lisa)
- Names should hint at the persona's situation
- Keep descriptions focused on relevant context

### Product Goals

Structure goals around adoption, value, and business impact:

```markdown
## Product Goals

[1-2 sentence summary of primary goals]

**Adoption metric**
[How do you measure usage/uptake? Be specific about current vs. target.]

**Value metric**
[How do you measure actual value delivered? This is the most important metric.]

**KPI**
[Business impact metric—revenue, cost, retention. Include expected direction.]
```

### Metrics Guidelines

**DO**:
- Define current baseline and target
- Focus value metrics on outcomes, not outputs
- Acknowledge tradeoffs (e.g., "profit-neutral because...")

**DON'T**:
- Use vanity metrics (page views, signups without activation)
- Set targets without baselines
- Ignore negative impacts on other metrics

### User Confirmation

Present audience and metrics, then use **AskUserQuestion**:

- Header: "Metrics"
- Question: "Do these personas and metrics capture what matters?"
- Options:
  - "Yes, proceed to scenarios" → Continue to Phase 4
  - "Adjust personas" → Discuss changes
  - "Refine metrics" → Discuss changes
  - "Missing key segment" → Add persona

---

## Phase 4: North Star Scenarios

**Goal**: Create narrative scenarios that make the vision concrete and intuitive.

### What Are North Star Scenarios?

North star scenarios are the highlighted stories you'll carry through the product lifecycle:
- You'll explain them when people ask what you're building
- They justify and feed into requirements
- You'll check them to see if you've missed something
- They become demos, guides, and marketing materials

### Crafting Scenarios

For each scenario, work through these questions:

1. **Start with a user problem**: What common situation triggers need?
2. **Follow the thread**: "What would [persona] need next?" until resolved
3. **Include value tracking**: Where do you measure success (surveys, metrics)?
4. **Look for plot holes**: Where is the story vague or risky? Add detail.
5. **Check for solution bias**: Focus on what/why, not how

### Scenario Format

```markdown
## North Star Scenarios

**[Scenario Title]**
[Persona name] [situation that creates the need]. [They take action or
interact with the product]. [Step-by-step narrative of what happens,
written in present tense]. [Resolution and how value is captured.]

**[Second Scenario Title]**
[Similar format...]
```

### Scenario Types to Include

1. **Happy path**: The ideal flow where everything works
2. **Edge case**: A variation that reveals important requirements
3. **Failure/escalation**: What happens when the product can't fully solve the problem
4. **Different personas**: At least one scenario per key persona

### Scenario Guidelines

**DO**:
- Write in present tense, narrative form
- Use persona names from your audience section
- Include enough detail to reveal requirements
- End with value capture (survey, metric event, outcome)

**DON'T**:
- Prescribe specific UI ("clicks the blue button")
- Describe implementation ("the API calls...")
- Write vague endings ("and they're satisfied")
- Include only happy paths

### Thinking Pattern Integration

| Situation | Pattern | Application |
|-----------|---------|-------------|
| Generating scenario ideas | `tree-of-thoughts` | Brainstorm multiple situations per persona |
| Detailing a scenario | `chain-of-thought` | Step through "what happens next?" |
| Checking completeness | `atomic-thought` | Verify each claim/metric has a scenario |
| Finding gaps | `self-consistency` | Multiple passes to catch missing cases |

### Scenario Review Questions

For each scenario, verify:
- Does it map to a thesis claim?
- Does it involve a defined persona?
- Does it contribute to a metric?
- Could you demo this?
- Are there hidden requirements revealed?

### User Feedback

Present scenarios, then use **AskUserQuestion**:

- Header: "Scenarios"
- Question: "Do these scenarios make the vision concrete?"
- Options:
  - "Yes, finalize the brief" → Continue to Review
  - "Add more scenarios" → Discuss what's missing
  - "Adjust existing scenarios" → Ask what to change
  - "Too detailed / not detailed enough" → Calibrate level

---

## Phase 5: Review

**Goal**: Validate the complete brief against quality criteria.

### Completeness Checklist

| Section | Check |
|---------|-------|
| Product Thesis | Clear, falsifiable claims about why this works |
| Antithesis | Honest risks that could invalidate claims |
| Target Audience | Named personas with distinct needs |
| Product Goals | Adoption + value + business metrics with targets |
| North Star Scenarios | Narrative stories covering personas and claims |

### Quality Checks

| Check | Anti-Pattern to Avoid |
|-------|----------------------|
| Vision-focused | Feature lists, implementation details |
| Falsifiable claims | Vague "will be better" statements |
| Honest risks | No risks or only minor ones listed |
| Outcome metrics | Vanity metrics, no baselines |
| Narrative scenarios | Bulleted requirements, UI specs |
| Complete coverage | Scenarios missing for key personas |

### Review Questions

1. Could a new team member understand what we're building and why?
2. Are the thesis claims specific enough to be proven wrong?
3. Do the scenarios reveal requirements we haven't documented?
4. Is any persona or claim missing a scenario?
5. Can we actually measure the metrics we defined?

### Next Action

Use **AskUserQuestion** for next action:

- Header: "Next step"
- Question: "Brief is complete. What would you like to do?"
- Options:
  - "Save to file" → Write to `$(claude-docs-path)/` with timestamp
  - "Generate user stories" → Use `agile-story` for each scenario
  - "Create implementation plan" → Use `implementation-planning`
  - "Done" → End workflow
