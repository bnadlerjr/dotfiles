---
name: skeleton-of-thought
description: "INVOKE for planning and outlining before implementation. Produces visible skeleton then expansion. Use before implementing features or creating structured documents. Triggers: planning, outlining, structuring approaches, roadmaps, breaking into phases."
---

# Skeleton of Thought (SoT)

Generates structure before content—outline first, then parallel expansion.

## MUST Invoke When

- Planning implementation of a feature
- User asks for a "plan", "outline", or "roadmap"
- Creating multi-section documents or responses
- Structuring complex output before writing
- Breaking work into phases or components

## Output Commitment

This skill produces **visible structured output**:
- Phase 1: Skeleton only (major sections, no details)
- Phase 2: Expansion of each skeleton point
- Clear separation between structure and content

Do NOT jump to implementation—invoke this skill to show skeleton first.

## Core Mechanism

Two distinct phases:
1. **Skeleton phase**: Generate only the high-level structure (headers, key points, sequence)
2. **Expansion phase**: Flesh out each skeleton point independently

## Process

```
Phase 1 - Skeleton:
1. Identify the major components/sections needed
2. Determine logical ordering and dependencies
3. Output ONLY the skeleton (no details yet)
4. Validate: Does this structure cover the full scope?

Phase 2 - Expansion:
1. Take each skeleton point in order
2. Expand with full detail
3. Maintain coherence with adjacent sections
4. Check: Does expansion stay true to skeleton's intent?
```

## Key Principles

- **Separation of concerns**: Structure and content are distinct cognitive tasks
- **Parallelization potential**: Skeleton points can be expanded concurrently
- **Drift prevention**: Skeleton constrains expansion, preventing tangents
- **Dependency visibility**: Structure reveals what must come before what

## When to Apply

- Implementation planning (see full scope before diving in)
- Document/report creation
- Presentations and structured communication
- Any multi-part output where order matters
- Complex responses that need organization

## Skeleton Pattern

```
Phase 1 - Generate skeleton only:

For [TASK], create a skeleton outline:
- Major sections/components only
- One line per item (no elaboration)
- Include sequencing/dependencies
- Do NOT expand yet

[Generate skeleton]

---

Phase 2 - Expand sequentially:

Now expand each skeleton point:
- Full detail for this section only
- Stay within the skeleton's scope
- Note dependencies on prior sections
- [Process in dependency order]
```

## Planning Application

```
Skeleton:
1. Database schema changes
2. API endpoint modifications  
3. Frontend component updates
4. Integration tests
5. Migration script

Expansion (each becomes detailed task list with acceptance criteria)
```

## Anti-Patterns

- Expanding during skeleton phase (defeats the purpose)
- Skeleton too detailed (it's not a full outline, just structure)
- Skeleton too vague (should still capture all major components)
- Ignoring dependencies during expansion
- Not validating skeleton covers full scope before expanding
