---
name: analyzing-use-cases
description: "Analyzes user stories into structured use cases using Cockburn's framework. Use when preparing stories for implementation, bridging research and planning, analyzing acceptance criteria, decomposing behavior before coding, or when the user mentions use case analysis, behavioral analysis, or scenario discovery. Produces a use case document that feeds directly into implementation planning and TDD."
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
  - TodoWrite
  - AskUserQuestion
---

# Analyzing Use Cases

Transform user stories into structured behavioral specifications using Alistair Cockburn's use case framework. The output is a use case document that gives implementation planning a behavioral spine and TDD a test discovery checklist.

## Quick Start

Given a story or ticket:

1. **Read** the ticket and any research document FULLY
2. **Classify** the goal level (summary, user-goal, subfunction)
3. **Identify** scope, primary actor, and stakeholders
4. **Draft** the main success scenario as numbered actor-system steps
5. **Discover** extensions at each step — get user input
6. **Define** preconditions and postconditions
7. **Map** stakeholder interests to non-functional concerns
8. **Write** the use case document from the template

## When This Skill Applies

- After research, before implementation planning
- User asks to "analyze", "break down behavior", or "write a use case"
- A story needs behavioral decomposition before an agent can plan implementation
- Acceptance criteria need expansion into step-by-step scenarios with extensions
- The typical trigger is `/analyze-jira XXX` in the research → plan → implement workflow

## Core Principles

1. **Behavioral, not structural**: Describe what actors do and what the system does in response. Never describe code, architecture, or implementation.
2. **Interactive**: Never dump a complete use case. Classify → draft main scenario → get buy-in → discover extensions → finalize.
3. **Grounded**: Every claim verified against the ticket, acceptance criteria, and research document. Don't invent requirements.
4. **Extension-driven**: The main success scenario is the spine. Extensions are where real complexity lives. Spend most effort here.
5. **TDD-ready**: Each numbered step implies a test. Each extension implies an edge case test. Preconditions become guard clauses. Postconditions become assertions.

## Process

### Step 1: Read and Absorb Inputs

1. **Read all mentioned files FULLY** — ticket, research document, existing plans
   - **NEVER** read files partially
2. **If Jira ticket referenced**, use the `managing-jira` skill to fetch details
3. **If research document exists**, extract key discoveries, patterns, and constraints

### Step 2: Classify the Goal Level

Determine where the story sits in Cockburn's goal hierarchy. For details on goal levels, see [references/cockburn-framework.md](references/cockburn-framework.md).

| Level | Icon | Description | Typical Scope |
|-------|------|-------------|---------------|
| Summary (cloud) | ☁️ | Multiple user goals, hours to days | Epic — too big for one use case |
| User-goal (sea) | 🌊 | One sitting, one goal accomplished | Story — right size |
| Subfunction (fish) | 🐟 | Part of a user goal, seconds to minutes | Sub-task — too small |

**Present classification to user:**

```
Based on the ticket, this story sits at [level]:
- [Evidence from ticket supporting classification]
- [Evidence from acceptance criteria]

[If summary-level]: This is too broad for a single use case. I recommend
slicing with `slicing-elephant-carpaccio` first.

[If subfunction-level]: This is a sub-step of a larger goal. The parent
use case is likely [X]. Should I analyze that instead?

[If user-goal]: Good scope for use case analysis. Proceeding.
```

**Wait for confirmation before proceeding.**

### Step 3: Identify Scope, Actors, and Stakeholders

From the ticket and research:

1. **System Under Design (SuD)**: What system boundary are we specifying behavior for?
2. **Primary Actor**: Who initiates the use case and has the goal?
3. **Supporting Actors**: Other systems or people the SuD interacts with during this use case
4. **Stakeholders and Interests**: Everyone with a stake in the outcome and what they need — this surfaces non-functional requirements

**Present findings:**

```
Scope: [System boundary]
Primary Actor: [Who triggers this]
Supporting Actors: [External systems, services, other users]

Stakeholders:
- [Actor] needs [interest] — implies [non-functional concern]
- [Stakeholder] needs [interest] — implies [non-functional concern]
```

**Wait for confirmation or corrections.**

### Step 4: Draft the Main Success Scenario

Write the happy path as numbered steps. Each step follows Cockburn's grammar:

- **"The [actor] [action]."** — for actor steps
- **"The system [response]."** — for system steps

**Rules for steps:**
- Each step advances toward the goal
- Steps describe *observable behavior*, not implementation
- Use present tense
- Keep steps at consistent granularity — don't mix high-level and detailed
- 3-9 steps is typical; more suggests the goal level is wrong

**Present the draft:**

```
Main Success Scenario:

1. The user [action].
2. The system [validates/processes/responds].
3. The user [next action].
4. The system [response].
...

Does this capture the happy path correctly?
```

**Wait for feedback before proceeding to extensions.**

### Step 5: Discover Extensions

This is where you spend the most effort. For each step in the main scenario, ask: "What can go wrong? What alternatives exist?"

Extensions use Cockburn's notation: `step_number + letter`. Each extension states the condition and the system's response.

**Systematic discovery approach:**

For each step, consider:
- **Validation failures** — bad input, missing data, wrong format
- **Business rule violations** — unauthorized, rate limited, quota exceeded
- **External system failures** — timeout, unavailable, error response
- **Alternate paths** — legitimate different flows (not errors)
- **Timing issues** — expired, concurrent modification, stale data

**Present extensions grouped by step:**

```
Extensions:

2a. [Condition at step 2]:
    1. The system [response].
    2. The user [recovery action or end].

2b. [Another condition at step 2]:
    1. The system [response].

3a. [Condition at step 3]:
    ...
```

Cross-reference each extension against the story's acceptance criteria. Flag any acceptance criterion that isn't covered by the main scenario or an extension.

**Wait for review. Ask specifically:** "Are there failure modes or alternate paths I'm missing?"

### Step 6: Define Preconditions and Postconditions

**Preconditions** — what must be true before the use case begins:
- These become setup in tests and guard clauses in implementation
- Verify against research document for technical constraints

**Postconditions (Success Guarantees)** — what must be true after successful completion:
- These become assertion targets in tests
- Must be observable and verifiable

**Postconditions (Minimum Guarantees)** — what must be true even if the use case fails:
- Data integrity constraints
- Audit/logging requirements
- Security invariants

### Step 7: Write the Use Case Document

1. Read the template at [templates/use-case-document.md](templates/use-case-document.md)
2. Gather metadata from `$CLAUDE_DOCS_ROOT/projects.yaml` per CLAUDE-PERSONAL.md artifact management schema
3. Fill all sections — no placeholders, no TBD
4. Write to `$CLAUDE_DOCS_ROOT/use-cases/` using naming convention `use-case--<slug>.md`
5. Cross-reference the originating ticket and any research document

### Step 8: Verify Completeness

Before finalizing, check:

- [ ] Every acceptance criterion from the ticket maps to either the main scenario or an extension
- [ ] No acceptance criterion is unaccounted for
- [ ] Preconditions are verifiable (not vague)
- [ ] Postconditions are observable (not implementation-dependent)
- [ ] Extensions cover validation, authorization, and external failures at minimum
- [ ] Stakeholder interests are captured (not just the primary actor's goal)
- [ ] Goal level is correct — not too broad, not too narrow

**Present summary and ask for final approval.**

## Guidelines

### Do
- Read all inputs FULLY before starting
- Get buy-in at each step — classify, then scenario, then extensions
- Spend disproportionate effort on extensions
- Cross-reference every acceptance criterion
- Capture stakeholder interests that aren't in the acceptance criteria
- Include `file:line` references from research document where relevant

### Don't
- Dump a complete use case without interaction
- Invent requirements not in the ticket or research
- Describe implementation (database schemas, API endpoints, code)
- Skip extensions — they're the whole point
- Leave placeholders or open questions in the final document
- Mix goal levels within a single use case

### Choosing Casual vs Fully Dressed

| Format | When to Use |
|--------|-------------|
| **Casual** | Simple stories, few extensions, clear scope. Omit stakeholder table, trigger, and minimum guarantees. |
| **Fully Dressed** | Complex stories, many extensions, multiple actors, non-functional concerns. Use complete template. |

Default to **casual** unless the story has 3+ actors, non-obvious stakeholder interests, or complex failure modes.

## Mapping to Downstream Skills

### → Implementation Planning

The use case document feeds directly into `implementation-planning`:
- **Main scenario steps** → phase boundaries and implementation order
- **Extensions** → error handling within phases
- **Preconditions** → Phase 1 guard clauses and validation
- **Postconditions** → "Done When" criteria in each phase
- **Stakeholders** → non-functional requirements (logging, rate limiting, analytics)

### → TDD (practicing-tdd)

The use case is a test discovery checklist:
- **Each main scenario step** → at least one test describing expected behavior
- **Each extension** → at least one test for the failure/alternate path
- **Preconditions** → setup and guard clause tests
- **Postconditions (success guarantees)** → assertion targets
- **Postconditions (minimum guarantees)** → invariant tests that must hold even on failure

### → Breaking Down Stories

If the use case reveals the story is too large:
- Each main scenario step cluster may become its own story
- Use `slicing-elephant-carpaccio` to produce thin slices
- Then `writing-agile-stories` for each slice

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Do This Instead |
|--------------|----------------|-----------------|
| Implementation in steps | "The system calls the auth API" | "The system authenticates the user" |
| Skipping extensions | Happy path only tells half the story | Systematically discover at each step |
| Vague preconditions | "User is set up" | "User has a verified email and active subscription" |
| Testing the UI | "The user clicks the Submit button" | "The user submits the form" — technology-neutral |
| One giant step | "The system processes the order" | Break into observable sub-steps |
| Extensions without recovery | "3a. Network fails." | "3a. Network fails: system retries 3 times, then notifies user" |

## Example

**Input:** Jira ticket for "User Resets Forgotten Password"

**Step 2 output (classification):**
```
This sits at user-goal level (🌊): one user, one sitting,
one goal accomplished (regain access via new password).
```

**Step 4 output (main success scenario):**
```
Main Success Scenario:
1. The user requests a password reset from the login page.
2. The system asks for the user's email address.
3. The user provides their email address.
4. The system generates a time-limited reset token and sends a reset link.
5. The user opens the reset link from their email.
6. The system validates the token and presents the password reset form.
7. The user enters a new password.
8. The system validates and saves the new password, invalidates the token.
9. The system confirms the reset and redirects to login.
```

**Step 5 output (extensions, partial):**
```
3a. Email not found in system:
    1. The system shows the same "check your email" confirmation.
    2. The system does not send an email. (Prevents account enumeration.)
    3. Use case ends.

4a. User has requested 3+ resets in 10 minutes:
    1. The system shows a rate limit message.
    2. Use case ends.

6a. Token has expired (>1 hour):
    1. The system informs the user the link has expired.
    2. The system offers to send a new reset link.
    3. Use case continues at step 1.

7a. New password fails validation rules:
    1. The system shows specific validation errors.
    2. Use case continues at step 7.
```

## Related Skills

### Upstream (inputs to this skill)
- `researching-codebase` — Produces the research document this skill consumes
- `managing-jira` — Fetches ticket details
- `writing-agile-stories` — Writes the stories this skill analyzes

### Downstream (consumers of this skill's output)
- `implementation-planning` — Uses the use case as behavioral contract for phased plans
- `breaking-down-stories` — Uses the use case to identify tasks
- `practicing-tdd` — Uses steps and extensions as test discovery source

### Typical Workflow
`/research-jira XXX` → **`/analyze-jira XXX`** → `/plan-jira XXX` → `/implement`
