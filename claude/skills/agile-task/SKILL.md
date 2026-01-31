---
description: Break down a user story into small, actionable tasks
argument-hint: [story or ticket reference]
---

# Task Breakdown

Decompose a user story into small, actionable tasks using simultaneous brainstorming. Tasks should be completable in a few hours each.

## Variables

STORY_INPUT: $ARGUMENTS

## Instructions

- Each task should be 1-4 hours of work
- Include ALL work needed to complete the story (code, tests, builds, design, docs)
- Keep task descriptions brief—leave room for implementers to work out details
- Task planning should take 10-30 minutes max; if longer, you're over-detailing
- Do NOT sequence tasks or assign owners—just brainstorm the work
- Focus on "what" not "how"

### TDD Guardrails

- NEVER create standalone test tasks (e.g., "Write tests for User class")
- Code tasks include both production and test code—implementers follow TDD (test first, then implement)
- Valid: "Add User class with validation" (tests are implicit)
- Invalid: "Add User class" + "Write tests for User class" (redundant split)
- Test-only tasks are acceptable ONLY for: test infrastructure, test fixtures/factories, or test configuration

### Optional: For Complex Stories

- If the story spans multiple systems or has unclear boundaries, use `/thinking atomic` to decompose requirements first
- If verification keeps finding gaps, use `/thinking self-consistency` to evaluate completeness from multiple perspectives

### Optional: For Modification-Heavy Stories

- If the story primarily modifies existing code (vs. greenfield), quickly scan relevant modules to identify integration points
- Keep this lightweight—5 minutes max—don't get pulled into implementation details

### Handling Open Questions

- If the story has open questions, create an explicit task: "Resolve: [question]"
- Skip tasks that depend on open questions—don't speculate on work that may not exist
- Note dependencies in the output so reviewers know the list is intentionally incomplete

## Workflow

1. **Gather the Story**
   - If STORY_INPUT is a ticket reference (e.g., "PROJ-123"), fetch the ticket details
   - If STORY_INPUT is prose, use it directly
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

## Report

Output tasks as a simple list:

```
## Tasks for: [Story Title]

- [ ] Task description
- [ ] Task description
- [ ] Task description
...
```

Keep descriptions to one line. No estimates, no assignments, no details.
