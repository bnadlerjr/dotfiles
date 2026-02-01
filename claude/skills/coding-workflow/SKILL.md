---
name: coding-workflow
description: Use when user asks to build a feature, implement something new, or make significant code changes. Recognizes requests like "build", "implement", "create a new feature", "add functionality", "develop", "I need to build X", "let's implement", "new feature request", "make these changes". Orchestrates a four-stage workflow (Research → Brainstorm → Plan → Implement) using the appropriate thought pattern skill at each stage.
---

# Coding Workflow

Four-stage development workflow with optimized thought patterns for each stage.

## Quick Start

When a user asks to build something:

1. **Research** - Understand the problem space using `/thinking atomic-thought`
2. **Brainstorm** - Explore approaches using `/thinking tree-of-thoughts`
3. **Plan** - Structure the implementation using `/thinking skeleton-of-thought`
4. **Implement** - Write verified code using `/thinking program-of-thoughts`

Each stage produces visible output before transitioning to the next.

## Workflow Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                        CODING WORKFLOW                           │
└──────────────────────────────────────────────────────────────────┘

  ┌─────────┐      ┌───────────┐      ┌────────┐      ┌───────────┐
  │ RESEARCH│ ───▶ │ BRAINSTORM│ ───▶ │  PLAN  │ ───▶ │ IMPLEMENT │
  └─────────┘      └───────────┘      └────────┘      └───────────┘
       │                 │                 │                │
       ▼                 ▼                 ▼                ▼
   atomic-           tree-of-         skeleton-of-     program-of-
   thought           thoughts         thought →        thoughts +
                        or            chain-of-        self-
                   graph-of-          thought          consistency
                   thoughts
```

## Dependencies

This workflow depends on the `thinking-patterns` skill for pattern execution. Invoke patterns using `/thinking <pattern>` or apply the pattern methodology inline if the context is clear.

## When to Use

Use this full workflow when:
- Building a new feature with multiple components
- Making significant architectural changes
- The implementation path is unclear
- Multiple valid approaches exist
- The task touches 3+ files

## When NOT to Use

Skip this workflow for:
- Single-line fixes or typos
- Adding a single function with clear requirements
- Bug fixes with obvious causes
- Tasks where the user has given detailed step-by-step instructions

For simpler tasks, apply individual patterns as needed without the full workflow.

## Stage Overview

| Stage | Primary Pattern | Purpose |
|-------|----------------|---------|
| Research | atomic-thought | Gather facts without context pollution |
| Brainstorm | tree-of-thoughts / graph-of-thoughts | Explore or synthesize approaches |
| Plan | skeleton-of-thought → chain-of-thought | Structure then detail |
| Implement | program-of-thoughts + self-consistency | Separate reasoning from code; verify |

---

## Stage 1: Research

**Pattern**: `atomic-thought`

**Goal**: Gather information across independent knowledge areas without accumulated context interfering.

```
Apply atomic-thought:
- Decompose research topic into independent questions
- Answer each self-contained
- Contract into synthesized findings
```

**Transition criteria** - Move to Brainstorm when:
- All research questions have been answered
- You can articulate the problem space clearly
- Existing patterns and constraints are documented
- You have enough context to evaluate approaches

**Transition signal**: "Research complete. Key findings: [summary]"

---

## Stage 2: Brainstorm

**Pattern**: `tree-of-thoughts` (divergent) or `graph-of-thoughts` (convergent)

**Goal**: Generate and evaluate solution approaches.

**Use tree-of-thoughts when**:
- Exploring multiple distinct approaches
- Need to evaluate and possibly backtrack
- "What are the alternatives?"

**Use graph-of-thoughts when**:
- Synthesizing research into approaches
- Combining insights from multiple sources
- Refining ideas iteratively

```
Apply tree-of-thoughts:
- Generate 3 distinct approaches (different perspectives)
- Evaluate each for feasibility
- Abandon approaches with fatal flaws
- Select or hybridize best approach

Apply graph-of-thoughts:
- Take research findings as input nodes
- Aggregate compatible insights
- Resolve conflicts
- Output synthesized approach
```

**Transition criteria** - Move to Plan when:
- A single approach is selected (or a clear hybrid)
- You can explain why this approach over alternatives
- Major risks and trade-offs are acknowledged
- The user has approved the direction (if needed)

**Transition signal**: "Decided on [approach] because [rationale]"

---

## Stage 3: Plan

**Pattern**: `skeleton-of-thought` → `chain-of-thought`

**Goal**: Create actionable implementation plan.

```
Phase 1 - Apply skeleton-of-thought:
- Generate high-level structure only
- Major components and their order
- Dependencies between components
- Do NOT expand yet

Phase 2 - Apply chain-of-thought:
- Expand each skeleton item sequentially
- Specific tasks with acceptance criteria
- Process in dependency order
```

**Transition criteria** - Move to Implement when:
- All components have detailed tasks
- Dependencies are mapped
- Each task has clear acceptance criteria
- You know which file to edit first

**Transition signal**: "Plan complete. Starting with [first component]"

---

## Stage 4: Implement

**Pattern**: `program-of-thoughts` + `self-consistency` + TDD

**Goal**: Generate correct, verified code using strict test-driven development.

### TDD Integration

Follow the `test-driven-development` skill for all implementation:

```
RED:    Write failing test first
GREEN:  Minimal code to pass
REFACTOR: Clean up while green
```

**The Iron Law**: No production code without a failing test first. Invoke `/test-driven-development` if you need the full methodology.

### Thinking Patterns

```
Apply program-of-thoughts:
- Explain logic before writing code
- Generate executable code for calculations
- Separate reasoning from implementation

Apply self-consistency (for complex/critical code):
- Generate two implementations (clarity vs efficiency)
- Compare outputs
- Identify and resolve discrepancies
```

**Completion criteria**:
- Every new function/method has a test that failed first
- All tests pass with pristine output
- Code follows existing patterns in the codebase
- Critical paths have been verified

---

## Stage Transitions

### Research → Brainstorm
```
Research complete. Key findings:
- [Finding 1]
- [Finding 2]
- [Finding 3]

Now brainstorming approaches using tree-of-thoughts.
```

### Brainstorm → Plan
```
Selected approach: [approach]
Rationale: [why this approach]

Now creating implementation plan using skeleton-of-thought.
```

### Plan → Implement
```
Implementation plan:
[skeleton + expanded details]

Starting implementation with [first component] using program-of-thoughts.
```

---

## State Tracking

For long conversations, track your current state explicitly:

```
[WORKFLOW STATE]
- Current stage: Plan
- Completed: Research, Brainstorm
- Selected approach: [approach name]
- Next action: Expand skeleton item 3
```

Update this when:
- Transitioning between stages
- Resuming after interruption
- Context has been summarized

---

## Recovery Patterns

### User Interrupts Mid-Workflow
If the user asks an unrelated question or changes topic:
1. Answer their question
2. Ask: "Would you like to continue with [feature] where we left off?"
3. If yes, state current stage and resume

### User Wants to Change Approach
If the user disagrees with the selected approach:
1. Acknowledge and return to Brainstorm stage
2. Incorporate their feedback into approach evaluation
3. Re-select and continue

### Context Was Summarized
If earlier workflow stages are no longer in context:
1. State your current understanding of: research findings, selected approach, plan
2. Ask user to confirm before continuing
3. Proceed from confirmed state

---

## Guidelines

**DO:**
- Produce visible output at each stage before transitioning
- State which pattern you're applying and why
- Ask for user confirmation when selecting approaches with significant trade-offs
- Track state explicitly in long conversations
- Use `/thinking <pattern>` to invoke patterns clearly

**DON'T:**
- Skip stages even if the task seems simple (use "When NOT to Use" criteria instead)
- Stay in one stage indefinitely without asking for help
- Transition without stating findings/decisions from current stage
- Apply patterns silently - make the methodology visible
- Implement before having a clear plan

**When Stuck:**
- If stuck in Research: Ask the user what specific questions need answering
- If stuck in Brainstorm: Present the approaches you have and ask for guidance
- If stuck in Plan: Show the skeleton and ask which parts are unclear
- If stuck in Implement: Describe the blocker and ask for help

---

## Example: Building a User Authentication Feature

**User request**: "Build user authentication for our Phoenix app"

### Stage 1: Research (atomic-thought)

```
Applying atomic-thought to decompose research questions:

Q1: What authentication exists currently? [independent]
→ None - this is greenfield

Q2: What auth library should we use? [independent]
→ Project uses phx_gen_auth pattern

Q3: What user fields are needed? [independent]
→ Email, password, confirmed_at minimum

Q4: What routes need protection? [depends on codebase exploration]
→ Found: /dashboard/*, /settings/*, /api/* need auth

Research complete. Key findings:
- Greenfield auth implementation
- Use phx_gen_auth pattern (project standard)
- User schema: email, hashed_password, confirmed_at
- Protected routes: dashboard, settings, API
```

### Stage 2: Brainstorm (tree-of-thoughts)

```
Applying tree-of-thoughts with three approaches:

Approach A (phx.gen.auth generator):
- Run generator, customize output
- Pros: Fast, battle-tested
- Cons: May include features we don't need

Approach B (Manual implementation):
- Build from scratch following phx_gen_auth patterns
- Pros: Only what we need
- Cons: More work, potential security mistakes

Approach C (Third-party library like Guardian):
- Use JWT-based auth
- Pros: Good for API-first
- Cons: Overkill for this app, different pattern

Evaluation:
- Approach A: Feasible, matches project patterns
- Approach B: Risky, no benefit over A
- Approach C: Wrong fit for server-rendered app

Decided on Approach A (phx.gen.auth generator) because it's battle-tested,
matches existing project patterns, and we can customize the output.
```

### Stage 3: Plan (skeleton-of-thought → chain-of-thought)

```
Applying skeleton-of-thought:

Skeleton:
1. Run phx.gen.auth generator
2. Customize User schema
3. Add protected route plugs
4. Create login/register LiveViews
5. Add tests

Applying chain-of-thought to expand:

1. Run phx.gen.auth generator
   - Command: mix phx.gen.auth Accounts User users
   - Accept: migration, schema, context, controllers
   - Criteria: Generator runs without error

2. Customize User schema
   - Add: confirmed_at field
   - Add: email confirmation logic
   - Criteria: User.changeset/2 validates all fields

3. Add protected route plugs
   - Create: require_authenticated_user plug
   - Apply to: /dashboard/*, /settings/*, /api/*
   - Criteria: Unauthenticated requests redirect to /login

4. Create login/register LiveViews
   - Replace generated controllers with LiveView
   - Follow existing LiveView patterns in codebase
   - Criteria: Forms work, errors display properly

5. Add tests
   - Unit: User changeset validations
   - Integration: Login/logout flow
   - Criteria: All tests pass

Plan complete. Starting with Step 1: Run phx.gen.auth generator.
```

### Stage 4: Implement (program-of-thoughts + TDD)

```
Step 1: Run phx.gen.auth generator (no TDD - generated code)

[Execute: mix phx.gen.auth Accounts User users]
[Review generated files]
[Run migration]

Step 1 complete. Moving to Step 2: Customize User schema.

Step 2: Customize User schema (TDD)

RED - Write failing test:
test "changeset requires confirmed_at for confirmed users" do
  changeset = User.confirmation_changeset(%User{}, %{confirmed_at: nil})
  assert %{confirmed_at: ["can't be blank"]} = errors_on(changeset)
end

[Run test - verify it fails: "function User.confirmation_changeset/2 is undefined"]

GREEN - Minimal implementation:
def confirmation_changeset(user, attrs) do
  user
  |> cast(attrs, [:confirmed_at])
  |> validate_required([:confirmed_at])
end

[Run test - verify it passes]

REFACTOR - None needed for now.

[Continue with next test...]
```

---

## Quick Reference

**Research question**: Use `atomic-thought` to decompose and answer independently

**"What approach should we take?"**: Use `tree-of-thoughts` with three experts

**"Combine these findings"**: Use `graph-of-thoughts` to synthesize

**"Create a plan"**: Use `skeleton-of-thought` then expand with `chain-of-thought`

**"Implement this"**: Use `program-of-thoughts`; add `self-consistency` if critical

**"Verify this"**: Use `self-consistency` with multiple approaches
