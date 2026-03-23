# Use Case Document Template

Structure for use case documents. See SKILL.md for the interactive process and metadata gathering conventions.

## Template

```markdown
[YAML frontmatter per CLAUDE-PERSONAL.md "Artifact Management" schema]

# Use Case: [Goal in Active Verb Form]

## Summary

| Field | Value |
|-------|-------|
| **Goal Level** | [☁️ Summary / 🌊 User-Goal / 🐟 Subfunction] |
| **Primary Actor** | [Who initiates and has the goal] |
| **Scope** | [System Under Design — the system boundary] |
| **Trigger** | [What event starts this use case] |

## Stakeholders and Interests

| Stakeholder | Interest | Implied Requirement |
|-------------|----------|---------------------|
| [Actor/Role] | [What they need from this use case] | [Non-functional concern: logging, rate limiting, analytics, etc.] |
| [Actor/Role] | [What they need] | [Implied requirement] |

## Preconditions

[What must be true before this use case begins. Each precondition maps to a guard clause or setup in implementation.]

- [Precondition 1 — specific and verifiable]
- [Precondition 2]

## Main Success Scenario

[The happy path as numbered actor-system steps. Each step is one sentence following Cockburn's grammar.]

1. The [actor] [action].
2. The system [response].
3. The [actor] [next action].
4. The system [validates/processes/responds].
5. ...

## Extensions

[Deviations from the main scenario. Keyed to step numbers. Each extension states the condition and the system's response.]

**[N]a. [Condition at step N]:**
1. The system [response].
2. [Recovery path or "Use case ends."]

**[N]b. [Another condition at step N]:**
1. The system [response].
2. Use case continues at step [M].

**[M]a. [Condition at step M]:**
1. The system [response].

## Postconditions

### Success Guarantees
[What must be true after the main success scenario completes. These become assertion targets in tests.]

- [Observable outcome 1]
- [Observable outcome 2]

### Minimum Guarantees
[What must be true even if the use case fails at any point. These become invariant tests.]

- [Data integrity constraint]
- [Audit/security requirement]

## Acceptance Criteria Coverage

[Cross-reference every acceptance criterion from the originating ticket to verify nothing was missed.]

| Acceptance Criterion | Covered By |
|---------------------|------------|
| [Criterion from ticket] | Main scenario step [N] |
| [Criterion from ticket] | Extension [Na] |
| [Criterion from ticket] | Precondition [N] |

## TDD Mapping

[How this use case maps to test discovery. Implementation agents use this as their test checklist.]

### From Main Scenario
| Step | Test Description |
|------|-----------------|
| Step [N] | [What the test verifies — stated as behavior] |
| Step [M] | [What the test verifies] |

### From Extensions
| Extension | Test Description |
|-----------|-----------------|
| [Na] | [What the failing/edge case test verifies] |
| [Mb] | [What the alternate path test verifies] |

### From Preconditions
| Precondition | Test Description |
|--------------|-----------------|
| [Precondition 1] | [Guard clause / setup verification test] |

### From Postconditions
| Postcondition | Test Description |
|---------------|-----------------|
| [Success guarantee 1] | [Assertion target test] |
| [Minimum guarantee 1] | [Invariant test — must hold even on failure paths] |

## References

- Ticket: [ticket reference or path]
- Research: [research document path, if applicable]
- Related Use Cases: [links to related use case documents]
```

## Section Guidelines

### Summary Table
- Goal level determined during classification (Step 2 of SKILL.md process)
- Primary actor is who initiates, not who benefits
- Scope names the system boundary, not the feature

### Stakeholders and Interests
- Go beyond the primary actor — include ops, security, product, support
- Each interest implies a non-functional requirement
- This section catches requirements that acceptance criteria miss

### Main Success Scenario
- 3-9 steps is typical for user-goal level
- Each step is one observable action or response
- Technology-neutral — no UI controls, no API endpoints
- Present tense, active voice

### Extensions
- Keyed to step numbers with lowercase letters (3a, 3b, 4a)
- State the condition first, then the response
- Extensions can redirect to other steps ("continues at step 3")
- Extensions can end the use case ("Use case ends.")
- Extensions can have their own sub-extensions for complex recovery

### Postconditions
- Success guarantees are what tests assert after happy path
- Minimum guarantees are invariants — they hold even when extensions fire
- Both must be observable, not implementation-dependent

### TDD Mapping
- This section is unique to this template — not standard Cockburn
- It bridges the use case directly to the TDD cycle
- Each row becomes a candidate for a failing test in the RED phase
- Implementation agents consume this as their test discovery checklist

### Acceptance Criteria Coverage
- Every criterion from the originating ticket must appear
- If a criterion doesn't map, the use case is incomplete
- This is the completeness verification gate

## Format Selection

### Casual Format
For simple stories. Omit: Stakeholders table, Trigger, Minimum Guarantees, TDD Mapping detail. Keep: Summary, Preconditions, Main Scenario, Extensions, Success Guarantees, AC Coverage.

### Fully Dressed Format
For complex stories. Use the complete template above. Required when: 3+ actors, non-obvious stakeholder interests, complex failure modes, or the story touches security/payments/compliance.
