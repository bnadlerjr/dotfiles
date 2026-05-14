# Product Brief Workflow Phases

Detailed instructions for each phase of the product brief workflow.

Several phases below suggest applying named thinking patterns (e.g., `atomic-thought`, `tree-of-thoughts`). See the `thinking-patterns` skill for pattern details.

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

Present your understanding and confirm with the user before proceeding. Ask whether the framing captures the problem correctly, whether anything needs adjustment, and whether any key context is missing. Return to discovery questions if gaps emerge; otherwise advance to Phase 2.

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

Present the thesis and antithesis and ask for feedback before moving on. Confirm that the claims capture the user's core beliefs about why this will work, ask whether any claims should be adjusted, added, or removed, and check whether the risks list is complete. Advance to Phase 3 only when the user is satisfied.

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

Present the audience and metrics and confirm with the user before proceeding. Ask whether the personas and metrics capture what matters, whether any persona or metric needs adjustment, and whether a key user segment is missing. Advance to Phase 4 once the user is satisfied.

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

Present the scenarios and ask for feedback before finalizing. Confirm whether the scenarios make the vision concrete, ask whether any are missing, whether existing ones should be adjusted, and whether the level of detail is calibrated correctly. Proceed to Review once the user is satisfied.

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

### Readability Polish

Product briefs are circulated to execs, designers, engineers, and stakeholders. After the brief passes the quality checks above, run the prose through the `writing-for-humans` skill to remove LLM tics, hedging, and structural bloat. North star scenarios especially benefit — narrative reads better when it isn't hedged.

**What to polish**:
- Vision statement at the top
- Thesis claim explanations (the 2-3 sentences under each bolded claim)
- Antithesis bullets
- Persona descriptions
- Product Goals summary and metric explanations
- North Star Scenario narratives

**What to preserve verbatim**:
- Section headings
- Bolded claim titles and persona names (e.g., `**Tinker Tia**`)
- Metric values, baselines, and targets (e.g., `15% → 65%`)
- Present-tense narrative voice in scenarios — do not retrospect or future-tense
- Value-capture endings (the survey, metric event, or outcome that closes each scenario)

Invoke the `writing-for-humans` skill on the assembled brief, passing the preserve/transform contract above so persona names, metric values, headings, and present-tense narrative voice survive the rewrite.

Replace the draft with the polished output. Spot-check persona names, metric values, and present-tense voice in scenarios before saving.

**Fallback**: If `writing-for-humans` is unavailable, skip the polish step and note "Readability polish deferred — recommend running `writing-for-humans` on the prose sections before circulation." in the handoff.
