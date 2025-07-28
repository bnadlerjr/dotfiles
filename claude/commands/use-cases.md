# Use-Cases Command

## Research Phase Instructions
1. Enter plan mode to research and develop use cases using Alistair Cockburn's methodology for the following:

$ARGUMENTS

2. Use any relevant custom agents (i.e. `use-case-writer`, etc.)

3. Present findings using the ExitPlanMode tool before proceeding

## Use Cases

### UC-001: [Use Case Name - Active Verb Phrase]

**Goal in Context:** [Brief description of what the actor wants to achieve]  
**Scope:** [System boundary - Organization/System/Subsystem]  
**Level:** [User Goal / Summary / Subfunction]  

**Primary Actor:** [Role/person with the goal]  
**Stakeholders and Interests:**
- [Stakeholder 1]: [Their interest in this use case]
- [Stakeholder 2]: [Their interest in this use case]
- [System/Support actors]: [Their role and interest]

**Preconditions:** [What must be true before the use case can start]  
**Success Guarantee (Postconditions):** [What will be true after successful completion]  
**Minimal Guarantee:** [What the system protects even if the use case fails]  

**Trigger:** [Event that initiates the use case]

**Main Success Scenario:**
1. [Actor does something / System responds]
2. [Next step showing forward progress]
3. [Continue numbered steps from trigger to goal]
4. [Each step in simple active voice]
5. [Show "who has the ball" in each step]
6. [System validates/processes as needed]
7. [Goal achieved]

**Extensions:**
- 3a. [Condition that causes alternative flow]:
  - 3a1. [System/Actor response]
  - 3a2. [Additional steps if needed]
  - 3a3. [Where to continue - return to step X or end]
- 3b. [Another alternative at step 3]:
  - 3b1. [Handling steps]
- 5a. [Alternative at step 5]:
  - 5a1. [Response and resolution]
- *a. [Can happen at any time during use case]:
  - *a1. [How it's handled]

**Technology & Data Variations:**
- Step 2: [Alternative technology/format options]
- Step 4: [Different ways to achieve same goal]

**Special Requirements:**
- [Performance constraints]
- [Security requirements]
- [Usability requirements]

**Frequency:** [How often this use case occurs]  
**Open Issues:** [Unresolved questions or decisions]

### UC-002: [Second Use Case Name]
[Repeat structure for additional use cases]

## Functional Requirements (EARS Notation)

### Ubiquitous Requirements (The system shall...)
- REQ-001: The system shall [always do X]
- REQ-002: The system shall [maintain Y]

### Event-Driven Requirements (When...)
- REQ-003: When [user does X], the system shall [do Y]
- REQ-004: When [event occurs], the system shall [respond with Z]

### State-Driven Requirements (While...)
- REQ-005: While [system is in state X], the system shall [behave as Y]
- REQ-006: While [condition is true], the system shall [maintain Z]

### Optional Feature Requirements (Where...)
- REQ-007: Where [feature X is enabled], the system shall [provide Y]
- REQ-008: Where [user has permission Z], the system shall [allow A]

### Unwanted Behavior (If... then...)
- REQ-009: If [error X occurs], then the system shall [handle it by Y]
- REQ-010: If [invalid input Z], then the system shall [reject and show error]

## Non-Functional Requirements

### Performance
- The feature shall respond within X milliseconds
- The feature shall handle Y concurrent users
- Use cases UC-001 and UC-002 shall complete within Z seconds

### Security
- Authentication requirements
- Authorization requirements
- Data encryption needs

### Usability
- Accessibility standards (WCAG 2.1 AA)
- Mobile responsiveness
- Browser compatibility

## Implementation Plan
[After research phase is complete and approved by user]

### High-Level Approach
- Architecture decisions
- Integration points
- Technology choices justified by research

### Implementation Tasks
[ ] Task 1: [Description with specific files/modules affected]
[ ] Task 2: [Description with dependencies noted]
[ ] Task 3: [Continue with checkbox format for tracking]

### Files to Create/Modify
- `path/to/file1.ext`: [What changes and why]
- `path/to/file2.ext`: [What changes and why]

### Testing Strategy
- Unit tests for [components]
- Integration tests for [use cases]
- End-to-end tests covering main scenarios and critical extensions

### Risks and Mitigations
- Risk 1: [Description and mitigation strategy]
- Risk 2: [Description and mitigation strategy]

## Acceptance Criteria
[Based on use case success guarantees and requirements]

### For UC-001:
- [ ] Main success scenario can be completed end-to-end
- [ ] Extension 3a handles [condition] correctly
- [ ] Performance meets stated requirements
- [ ] All stakeholder interests are protected

### For UC-002:
- [ ] [Specific measurable criteria]

## Edge Cases and Error Scenarios
[Derived from use case extensions]
1. What happens when [from extension 3a]
2. Error handling for [from extension 5a]
3. Boundary conditions for [specific scenarios]

## Dependencies
- External services required: [List with versions]
- Other features this depends on: [With use case references]
- Database migrations needed: [Yes/No with details]

## Plan Output Instructions
After user approval of the plan:
1. Generate a slug based on the request (e.g., "add user auth" → "add-user-auth")
2. Create the directory structure if it doesn't exist:
```bash
mkdir -p ai_specs/{{slug}}
```
3. Write the complete plan to `ai_specs/{{slug}}/use-cases.md` (or user-specified filename)
4. After creating the document:
 - Ask: "I've created the use cases document. Please review it and let me know if any scenarios are missing or need clarification."

---
*Note: Start with casual use case format and add detail as needed. Consider the "User Goal" level (2-20 minute tasks) as the default unless the feature requires Summary or Subfunction level documentation.*
