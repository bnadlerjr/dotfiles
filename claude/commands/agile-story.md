---
description: Write behavior-focused Agile user stories with BDD acceptance criteria
---

# Agile Story

Read and follow the methodology in the agile-story skill:
`~/dotfiles/claude/skills/agile-story/SKILL.md`

## Initial Response

When this command is invoked:

1. **If a description was provided**: Begin discovery by asking clarifying questions about the provided topic

2. **If no description provided**, respond with:
```
I'll help you write a behavior-focused user story. Let me understand what we're building.

What user need or feature would you like to define?

You can provide:
- A brief description of the need
- A ticket reference to expand
- A vague idea to explore together

I'll guide you through discovery, drafting, and acceptance criteria.
```

## Workflow

### Phase 1: Discovery

Ask clarifying questions in small batches (2-3 at a time) using prose:

**Round 1**: Who experiences this need? What triggers it?
**Round 2**: What outcome do they want? How do they know they succeeded?
**Round 3**: What constraints apply? What could go wrong?
**Round 4**: What domain terms should we use?

**Apply thinking patterns when needed**:
- Complex requirements spanning domains → `atomic-thought`
- Unclear primary need → `tree-of-thoughts`
- Multiple stakeholder perspectives → `atomic-thought`

Present your understanding, then use **AskUserQuestion** to confirm:

```
**My Understanding**:
[Summary of the need]

**Actor**: [Who]
**Trigger**: [What prompts this]
**Outcome**: [What they achieve]
**Constraints**: [Rules that apply]
```

**AskUserQuestion**:
- Header: "Understanding"
- Question: "Does this capture the user need correctly?"
- Options:
  - "Yes, proceed to drafting" → Continue to Phase 2
  - "Mostly, minor adjustments" → Ask what to adjust, then re-confirm
  - "No, significant gaps" → Return to discovery questions

### Phase 2: Story Drafting

Write the narrative-form story. NEVER use "As a [user], I want [X], so that [Y]".

**Apply thinking patterns when needed**:
- Multiple valid framings → `tree-of-thoughts`
- Story too large → `skeleton-of-thought` to outline splits
- Synthesizing multiple inputs → `graph-of-thoughts`

Present the draft, then use **AskUserQuestion** to get feedback:

```
## Story: [Title]

[Narrative]

### Context
[When this applies]
```

**AskUserQuestion**:
- Header: "Story draft"
- Question: "How does this story draft look?"
- Options:
  - "Good, write acceptance criteria" → Continue to Phase 3
  - "Adjust the narrative" → Ask what to change, revise, re-confirm
  - "Story is too large, split it" → Use `skeleton-of-thought` to propose splits
  - "Start over" → Return to Phase 1

### Phase 3: Acceptance Criteria

Use `skeleton-of-thought` to outline scenarios first:
```
I'll outline the scenarios we need:
1. [Happy path]
2. [Alternative: ...]
3. [Failure: ...]
4. [Edge case: ...]
```

**AskUserQuestion** to confirm scenario coverage:
- Header: "Scenarios"
- Question: "Are these the right scenarios to detail?"
- Options:
  - "Yes, detail them" → Write Given-When-Then for each
  - "Add more scenarios" → Ask which scenarios are missing
  - "Remove some" → Ask which to remove

Use `chain-of-thought` when tracing complex business logic.

After detailing scenarios, use **AskUserQuestion**:

```
### Acceptance Criteria
[Full Given-When-Then scenarios]
```

- Header: "Criteria"
- Question: "Are these acceptance criteria complete?"
- Options:
  - "Yes, finalize the story" → Continue to Phase 4
  - "Adjust scenarios" → Ask what to change
  - "Add edge cases" → Discuss and add

### Phase 4: Review

Apply quality checklist from the skill. For high-stakes stories, use `self-consistency`.

Present final story with quality checks:

```
## Story: [Title]

[Narrative]

### Context
[When this applies]

### Acceptance Criteria
[All scenarios]

---

Quality checks:
- ✅ Behavior-focused (no implementation details)
- ✅ Domain language throughout
- ✅ Narrative form (no template)
- ✅ Small and testable
- ✅ Failure modes included
- ✅ Scenarios are independent
```

**AskUserQuestion** for next action:
- Header: "Next step"
- Question: "Story is complete. What would you like to do?"
- Options:
  - "Create Jira ticket" → Use `jira-cli-expert` to create ticket
  - "Save to file" → Write to `$(claude-docs-path tickets)/`
  - "Write related story" → Start new story with shared context
  - "Done" → End workflow

## Tips for Better Stories

- Stories are conversation starters, not complete specs
- If you can't test it, rewrite it
- Smaller is almost always better
- Domain experts should understand every word
- Implementation details belong in the plan, not the story
