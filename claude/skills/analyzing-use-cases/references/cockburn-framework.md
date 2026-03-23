# Cockburn's Use Case Framework

Reference for Alistair Cockburn's use case concepts as adapted for agent-driven development. Load this when you need deeper understanding of goal levels, step grammar, or extension discovery.

## Goal Levels

Cockburn defines three goal levels that determine the scope and granularity of a use case. Correct classification prevents wasted work.

### Summary (Cloud-High) ☁️

**Scope**: Multiple user sessions, hours to days to complete.
**Signal**: The story mentions multiple distinct user goals, or spans multiple user roles achieving different things.
**Action**: Too broad for a single use case. Slice with `slicing-elephant-carpaccio` first, then analyze each slice.

**Examples**: "Manage employee onboarding", "Process insurance claim end-to-end", "Set up a new customer account with all integrations."

### User-Goal (Sea-Level) 🌊

**Scope**: One actor, one sitting, one goal accomplished or abandoned.
**Signal**: A specific person wants to accomplish a specific thing and will know immediately whether they succeeded.
**Action**: Right scope. Analyze directly.

**Test**: Would the primary actor go to lunch satisfied after accomplishing this? If yes, it's sea-level.

**Examples**: "Reset forgotten password", "Submit expense report", "Cancel an order before shipment."

### Subfunction (Fish-Level) 🐟

**Scope**: A step within a larger goal, seconds to minutes.
**Signal**: Accomplishing this alone wouldn't satisfy any user goal. It's a means, not an end.
**Action**: Too granular. Identify the parent user-goal and analyze that instead.

**Examples**: "Validate email format", "Generate a token", "Log the event."

### Classification Heuristics

| Signal | Likely Level |
|--------|-------------|
| Multiple user roles mentioned | ☁️ Summary |
| "Over the course of days/weeks" | ☁️ Summary |
| "The user wants to [single verb]" | 🌊 User-Goal |
| One sitting, one outcome | 🌊 User-Goal |
| "The system validates/checks/logs" | 🐟 Subfunction |
| No user would say "I accomplished X" | 🐟 Subfunction |

## Step Grammar

Each step in the main success scenario follows one of these forms:

### Actor Steps
The subject is the actor doing something visible:
- "The user submits the registration form."
- "The customer selects a shipping method."
- "The administrator approves the request."

### System Steps
The subject is the system responding:
- "The system validates the email format."
- "The system sends a confirmation email."
- "The system records the transaction."

### Rules for Good Steps

**Consistent granularity**: Don't mix "The user clicks a button" (too detailed) with "The system processes the order" (too vague). Both should be at the same level of abstraction.

**Observable behavior**: Each step should describe something you could see or verify from outside the system. "The system updates the database" is implementation. "The system confirms the order" is behavior.

**Technology-neutral**: Avoid UI controls ("clicks", "taps", "scrolls"), API verbs ("POSTs", "calls"), or database operations ("inserts", "queries"). Describe *what* happens, not *how*.

**One action per step**: If a step has "and" in it, split it into two steps.

**Goal advancement**: Every step should move closer to the postcondition. If removing a step wouldn't change the outcome, it doesn't belong.

## Extension Discovery

Extensions capture what happens when the main scenario deviates. This is where the real implementation complexity lives.

### Notation

Extensions are keyed to the step where the deviation occurs:

```
3a. [Condition]:
    1. The system [response].
    2. Use case continues at step 4.

3b. [Different condition at same step]:
    1. The system [response].
    2. Use case ends.
```

The letter (a, b, c) distinguishes multiple extensions at the same step. Sub-steps under an extension describe the recovery or alternate path.

### Extension Outcomes

An extension can:
- **Resume the main scenario**: "Use case continues at step N"
- **Loop back**: "Use case continues at step M" (where M < current step)
- **End the use case**: "Use case ends." (goal abandoned or accomplished differently)
- **Branch to a different use case**: "Use case branches to [other use case]"

### Systematic Discovery Checklist

For EACH step in the main scenario, ask:

1. **Can the actor provide bad input?** (validation failure)
2. **Can the actor lack permission?** (authorization failure)
3. **Can an external system fail?** (timeout, error, unavailable)
4. **Can the data be in an unexpected state?** (already exists, was deleted, changed concurrently)
5. **Can a business rule prevent this?** (rate limit, quota, policy)
6. **Is there a legitimate alternate path?** (different but valid flow)
7. **Can this step time out or expire?** (session, token, deadline)

### Extension Depth

Not every extension needs a detailed recovery path. Use judgment:

- **Critical failures** (data loss, security breach): Full recovery path with sub-steps
- **User errors** (bad input): Brief — show error, retry
- **External failures** (service down): Retry strategy and user notification
- **Alternate paths** (different valid flow): Full path to alternate completion or rejoining main scenario

## Preconditions and Postconditions

### Preconditions

State what must be true *before step 1 executes*. The system does not verify these — they are assumed true.

**Good preconditions are**:
- Specific: "User has a verified email address" not "User is set up"
- Verifiable: Something a test can check in setup
- Minimal: Only what this use case requires, not general system state

**Common precondition categories**:
- Authentication state (logged in, session valid)
- Data state (record exists, status is X)
- Authorization (user has role/permission)
- System state (service available, feature enabled)

### Postconditions: Success Guarantees

What must be true after the main success scenario completes. Every success guarantee becomes an assertion in tests.

**Good success guarantees**:
- Observable from outside the system
- Directly testable
- Stated as positive facts, not negations

### Postconditions: Minimum Guarantees

What must be true *regardless of how the use case ends* — including all extensions, even failures. These are system invariants.

**Examples**:
- "No partial data remains from an abandoned operation"
- "All attempts are logged for audit"
- "User's existing data is not corrupted"

## Stakeholders and Interests

Cockburn insists on listing every stakeholder and what they need from the use case. This surfaces requirements that acceptance criteria miss.

### Beyond the Primary Actor

| Stakeholder Type | What They Typically Need |
|-----------------|------------------------|
| **Operations** | Logging, monitoring, alerting |
| **Security** | Rate limiting, audit trails, input sanitization |
| **Product** | Analytics events, feature flags, A/B test hooks |
| **Support** | Error messages that help diagnose, ticket references |
| **Compliance** | Data retention, consent records, regulatory audit |
| **Performance** | Response time budgets, resource limits |

### How Interests Become Requirements

Each stakeholder interest implies a non-functional requirement that the implementation plan must address. These don't appear in acceptance criteria but are real work:

```
Stakeholder: Security team
Interest: Prevent brute-force password resets
Implied requirement: Rate limiting on reset endpoint (max 3 per 10 min)
Where it shows up: Extension at the "user provides email" step
```

## Cockburn's Format Levels

### Brief
One-paragraph description. Useful for brainstorming or early discovery. Not sufficient for implementation.

### Casual
Main success scenario + key extensions. No formal stakeholder table. Good for straightforward stories with clear scope.

### Fully Dressed
All fields: summary table, stakeholders, preconditions, main scenario, extensions, postconditions (both success and minimum guarantees). Use for complex stories.

### Choosing the Right Level

| Story Characteristics | Format |
|----------------------|--------|
| 1 actor, few extensions, clear happy path | Casual |
| Multiple actors, security/payment concerns | Fully Dressed |
| Non-obvious stakeholder interests | Fully Dressed |
| Complex failure modes or recovery paths | Fully Dressed |
| Simple CRUD with validation | Casual |

Default to casual. Upgrade to fully dressed when discovery reveals complexity.
