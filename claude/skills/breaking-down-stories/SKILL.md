---
name: breaking-down-stories
description: Break down a user story into small, actionable tasks. Use when decomposing user stories, planning sprint work, creating task lists from tickets, or when the user mentions story breakdown, task decomposition, or sprint planning.
argument-hint: [story or ticket reference]
---

# Task Breakdown

Decompose a user story into small, actionable tasks using simultaneous brainstorming. Tasks should be completable in a few hours each.

## Quick Start

Given a story, generate a flat task list:

```markdown
## Tasks for: User Resets Forgotten Password

- [ ] Add password reset request endpoint with email lookup
- [ ] Create reset token generation with secure random and expiration
- [ ] Add email template for password reset link
- [ ] Add password reset confirmation endpoint with token validation
- [ ] Add rate limiting for reset requests
- [ ] Update login page with "Forgot password?" link
- [ ] Add error handling for expired/invalid tokens
```

## Instructions

- Each task should be 1-4 hours of work
- Include ALL work needed to complete the story (code, tests, builds, design, docs)
- Keep task descriptions brief—leave room for implementers to work out details
- Do NOT sequence tasks or assign owners—just brainstorm the work
- Focus on "what" not "how"

### TDD Guardrails

- NEVER create standalone test tasks (e.g., "Write tests for User class")
- Code tasks include both production and test code—implementers follow TDD (test first, then implement)
- Valid: "Add User class with validation" (tests are implicit)
- Invalid: "Add User class" + "Write tests for User class" (redundant split)
- Test-only tasks are acceptable ONLY for: test infrastructure, test fixtures/factories, or test configuration

### For Complex Stories

- If the story spans multiple systems or has unclear boundaries, use `/thinking atomic` to decompose requirements first
- If verification keeps finding gaps, use `/thinking self-consistency` to evaluate completeness from multiple perspectives

### For Modification-Heavy Stories

- If the story primarily modifies existing code (vs. greenfield), quickly scan relevant modules to identify integration points
- Keep reconnaissance lightweight—don't get pulled into implementation details

### Handling Open Questions

- If the story has open questions, create an explicit task: "Resolve: [question]"
- Skip tasks that depend on open questions—don't speculate on work that may not exist
- Note dependencies in the output so reviewers know the list is intentionally incomplete

## Workflow

1. **Gather the Story**
   - If input is a ticket reference (e.g., "PROJ-123"), fetch the ticket details
   - If input is prose, use it directly
   - Identify: who is the user, what do they want, why do they want it

2. **Brainstorm Tasks Simultaneously**
   - Generate all tasks at once (not sequentially)
   - Think across categories: code changes, configuration, documentation, deployment, infrastructure
   - Include non-obvious work: "Update build script", "Add migration", "Update API docs"

3. **Right-Size Each Task**
   - Split anything larger than ~4 hours
   - Combine anything smaller than ~30 minutes
   - Each task should be independently completable

4. **Verify Completeness**
   - Walk through the story end-to-end
   - Ask: "If all these tasks are done, is the story shippable?"
   - Add any missing tasks

5. **Check TDD Compliance**
   - Scan for any "write tests for X" tasks
   - Merge test tasks into their corresponding implementation tasks
   - Confirm test infrastructure tasks (if any) are truly standalone concerns

## Example

**Input Story:**

```markdown
## Story: User Resets Forgotten Password

When users cannot remember their password or suspect their account may be
compromised, they need a secure way to reset their credentials and regain
access. The process must verify their identity while remaining accessible.

### Context
Available from the login page when a user cannot authenticate.

### Acceptance Criteria

#### Scenario: Successful password reset
- Given a user with a verified email address
- When they request a password reset
- Then they receive an email with a secure reset link
- And the link expires after 1 hour
- And they can set a new password using the link

#### Scenario: Reset for unregistered email
- Given the email address is not in the system
- When someone requests a reset for that email
- Then the same "check your email" message is shown
- And no email is sent (prevents account enumeration)

#### Scenario: Expired reset link
- Given a user received a reset link more than 1 hour ago
- When they try to use the link
- Then they are informed the link has expired
- And they can request a new reset link

#### Scenario: Multiple reset requests
- Given a user has requested reset 3 times in 10 minutes
- When they request another reset
- Then they are asked to wait before trying again
```

**Output:**

```markdown
## Tasks for: User Resets Forgotten Password

- [ ] Add password reset request endpoint with email lookup
- [ ] Create reset token generation with secure random and 1-hour expiration
- [ ] Store reset tokens with user association and expiration timestamp
- [ ] Add email template for password reset link
- [ ] Integrate email sending for reset requests
- [ ] Add password reset confirmation endpoint with token validation
- [ ] Invalidate token after successful password change
- [ ] Add rate limiting: max 3 requests per 10 minutes per email
- [ ] Return consistent response regardless of email existence
- [ ] Add error handling for expired tokens with re-request guidance
- [ ] Update login page with "Forgot password?" link
- [ ] Add password validation on reset (same rules as registration)
```

## Output Format

Output tasks as a simple list:

```markdown
## Tasks for: [Story Title]

- [ ] Task description
- [ ] Task description
- [ ] Task description
...
```

Keep descriptions to one line. No estimates, no assignments, no implementation details.
