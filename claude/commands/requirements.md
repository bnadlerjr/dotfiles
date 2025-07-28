# Requirements Command

Generate a comprehensive requirements document for the feature: $ARGUMENTS

## Instructions

1. Use the following format for the requirements document:

```markdown
# Requirements: $ARGUMENTS

## Overview
[Provide a brief description of the feature, its purpose, and business value]

## User Stories
[Format each as: "As a [role], I want [feature], so that [benefit]"]

1. As a user, I want...
2. As an admin, I want...

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

### Security
- Authentication requirements
- Authorization requirements
- Data encryption needs

### Usability
- Accessibility standards (WCAG 2.1 AA)
- Mobile responsiveness
- Browser compatibility

## Acceptance Criteria
[Specific, measurable criteria for each user story]

## Edge Cases and Error Scenarios
1. What happens when...
2. Error handling for...

## Dependencies
- External services required
- Other features this depends on
```

2. Present the document using the ExitPlanMode tool

3. After the user approves the document:
- Generate a slug based on $ARGUMENTS (i.e. "add user auth" -> "add-user-auth")
- Create the directory structure if it doesn't exist:
```bash
mkdir -p ai_specs/{{slug}}
```
- Create ai_specs/{{slug}}/requirements.md

4. After creating the document:
 - Ask: "I've created the requirements document. Please review it and let me know if any scenarios are missing or need clarification."
