# Architecture Documentation Workflow

Write system overviews, ADRs, design docs, and module interaction descriptions that serve both human developers and LLMs.

## Inputs

One or more of:
- Codebase path or module names to document
- Natural language description of the system or decision to document
- Specific doc type requested (ADR, design doc, system overview)

## Output Placement

Architecture docs are standalone markdown files placed in a project-appropriate location:
- ADRs: `docs/adr/` or `adr/` (numbered: `001-use-postgresql.md`)
- Design docs: `docs/design/` or `docs/`
- System overviews: `docs/architecture.md` or `docs/`
- Module interaction docs: `docs/` alongside related architecture docs

## Doc Type Detection

| Request Contains | Doc Type | Template |
|-----------------|----------|----------|
| "ADR", "decision record", "why we chose" | ADR | ADR Template below |
| "design doc", "proposal", "RFC" | Design Doc | Design Doc Template below |
| "system overview", "architecture", "how the system works" | System Overview | System Overview Template below |
| "how X talks to Y", "module interactions", "data flow" | Module Interactions | Module Interactions Template below |

## Procedure

### Step 1: Gather Context

Use Read, Grep, and Glob to understand the system:

1. Read the project structure (directory layout, key files)
2. Identify the modules/components relevant to the doc
3. Trace data flow between components
4. Find existing architecture docs to maintain consistency

### Step 2: Select Template

Choose the appropriate template based on doc type detection above. Read the template section below, then proceed.

### Step 3: Write the Document

Follow the selected template. Apply these principles throughout:

**From Ousterhout (see `references/ousterhout-principles.md`)**:
- Document cross-module interactions, not just individual components
- Separate interface descriptions from implementation details
- Explain the WHY behind architectural decisions
- Provide high-level intuition before low-level details

**From LLM patterns (see `references/llm-doc-patterns.md`)**:
- Use explicit, keyword-rich headings
- Front-load context in each section (BLUF)
- Make each section self-contained
- Use fully qualified module names on first reference
- State relationships explicitly (depends on, called by, talks to)

### Step 4: Validate

Run through the quality checklist at the bottom of this file.

---

## ADR Template

Architecture Decision Records capture the WHY behind significant technical choices.

```markdown
# ADR-NNN: [Decision Title in Present Tense]

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-NNN]

## Context

[What problem or situation prompted this decision? Include constraints,
requirements, and forces at play. A reader should understand WHY a
decision was needed without reading any other document.]

## Decision

[What was decided. State it directly: "We will use X for Y."
Not "We decided to..." — present tense, active voice.]

## Consequences

### Positive
- [Benefit 1]
- [Benefit 2]

### Negative
- [Trade-off 1]
- [Trade-off 2]

### Neutral
- [Side effect that is neither good nor bad]

## Alternatives Considered

### [Alternative A]
[Brief description. Why it was rejected.]

### [Alternative B]
[Brief description. Why it was rejected.]
```

**ADR rules**:
- One decision per ADR
- Title should be the decision, not the problem ("Use PostgreSQL for persistence", not "Database selection")
- Context section must stand alone — a reader unfamiliar with the project should understand the problem
- Number sequentially, never reuse numbers
- Deprecated ADRs link to their replacement

---

## Design Doc Template

Design docs describe HOW a system or feature works and WHY it was designed that way.

```markdown
# [Feature/System Name] Design

## Summary

[2-3 sentences: what this is, why it exists, what problem it solves.]

## Goals and Non-Goals

### Goals
- [What this design achieves]

### Non-Goals
- [What this design explicitly does not address]

## System Context

[Where this fits in the larger system. What components surround it.
Include a text diagram if it clarifies relationships.]

## Design

### [Component/Layer 1]

[How it works. Interface first, then implementation details if needed.
Use fully qualified names for all modules referenced.]

### [Component/Layer 2]

[Same structure as above.]

### Data Flow

[How data moves through the system. Describe the path from input to output,
naming each component that touches the data.]

## Trade-Offs

| Choice | Alternative | Why This One |
|--------|-------------|-------------|
| [What was chosen] | [What was not] | [Rationale] |

## Open Questions

- [Question that needs resolution before or during implementation]

## References

- [Link to related ADR, code, or external resource]
```

---

## System Overview Template

System overviews describe the high-level structure of a system for onboarding and orientation.

```markdown
# [System Name] Architecture

## What This System Does

[2-3 sentences describing the system's purpose and primary behaviors.
Not how it works — what it does for its users/callers.]

## Component Map

[List each major component with its single responsibility.]

| Component | Responsibility | Key Module |
|-----------|---------------|------------|
| [Name] | [What it does] | `Fully.Qualified.Name` |

## Data Flow

[Describe how a typical request/operation flows through the system.
Name each component it passes through.]

```
[Request] --> ComponentA --> ComponentB --> [Database]
                              |
                              v
                         ComponentC --> [External API]
```

## Key Decisions

[Brief list of the most important architectural decisions. Link to ADRs
where they exist.]

- **[Decision]**: [One-line rationale]. See ADR-NNN.

## Module Dependencies

[Which modules depend on which. Use fully qualified names.]

- `App.Web.Router` depends on `App.Web.AuthPlug`, `App.Web.Controllers.*`
- `App.Accounts` depends on `App.Repo`, `App.Auth.TokenValidator`

## Boundaries and Contracts

[What are the rules for how modules interact?]

- [Boundary rule: e.g., "Web layer never calls Repo directly"]
- [Contract: e.g., "All context functions return {:ok, result} | {:error, changeset}"]
```

---

## Module Interactions Template

Module interaction docs describe how specific modules communicate.

```markdown
# [Module A] and [Module B] Interaction

## Relationship

[One sentence: what each module does and how they relate.]

## Contract

### [Module A] provides:
- `function_name/arity` — [what it does, what it returns]

### [Module B] expects:
- [What it calls on Module A]
- [What format it expects back]

## Data Flow

[How data moves between the two modules. Include the full path.]

## Assumptions

[What each module assumes about the other. These are coupling points.]

- Module A assumes Module B will [behavior]
- Module B assumes Module A returns [format]

## Failure Modes

[What happens when the interaction fails.]

- If Module A is unavailable: [consequence]
- If Module A returns unexpected data: [consequence]
```

---

## Post-Processing

Architecture docs do NOT go through `writing-for-humans` post-processing. They prioritize precision and completeness over scannability. They already follow BLUF and explicit headings from the LLM patterns.

## Quality Checklist

- [ ] Document stands alone — a reader unfamiliar with the project can understand the context
- [ ] All module references use fully qualified names on first use
- [ ] Cross-module interactions are explicitly described (not implied)
- [ ] Interface descriptions separate WHAT from HOW
- [ ] The WHY is documented for every significant choice
- [ ] Headings are specific and keyword-rich (not "Overview" or "Details")
- [ ] Each section is self-contained and understandable when extracted
- [ ] Text diagrams or tables clarify relationships that prose alone cannot
- [ ] No ambiguous pronouns across section boundaries
- [ ] Document follows the appropriate template structure
