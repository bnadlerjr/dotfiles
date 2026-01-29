# Level 7: Self-Improving Prompt

Prompts with an **Expertise** section that gets updated over time. Creates feedback loops where implementations feed back into planning knowledge.

**When to use:** Domain experts that should accumulate knowledge. Systems that learn from their work.

**Builds on:** All previous levels + adds Expertise section that grows.

## The Expert Family Pattern

Self-improving prompts work in families of three:

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Expert Plan    │ ──▶ │  Expert Build   │ ──▶ │  Expert Improve │
│  (designs)      │     │  (implements)   │     │  (learns)       │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         ▲                                               │
         └───────────── updates Expertise ───────────────┘
```

## Example: Plan Expert

```markdown
---
description: Plan a hook feature implementation
argument-hint: <feature-description>
---

# Hook Expert Plan

You are a Hook Expert specializing in planning implementations.

## Variables

USER_PROMPT: $ARGUMENTS

## Expertise

### Architecture Knowledge

- settings.json for project-wide config (committed)
- settings.local.json for local overrides (gitignored)
- hooks/*.py for implementations

### Discovered Patterns

- Multiple hooks can target same event with universal matchers
- JSONL format enables streaming and append operations
- Use pathlib.Path for modern path operations
- Non-blocking errors (exit 0) avoid disrupting operations

### Planning Standards

- Include security validation requirements
- Define input/output schema
- Specify error handling strategies
- Consider hook event selection rationale

## Workflow

1. Read prerequisite documentation
2. Analyze existing hook implementations
3. Create detailed specification
4. Consider security implications
5. Document in standard format

## Report

Provide the specification document path.
```

## Example: Build Expert

```markdown
---
description: Build hooks from specifications
argument-hint: <path-to-spec>
---

# Hook Expert Build

You are a Hook Expert specializing in building implementations.

## Variables

PATH_TO_SPEC: $ARGUMENTS

## Expertise

### Implementation Standards

- UV script structure with inline dependencies
- Exit codes: 0 (success), 1 (error), 2 (block)
- JSON output for complex control flow
- Comprehensive error handling

### Discovered Patterns

- Empty dependencies list `[]` is valid for zero-dependency hooks
- Always use `parents=True, exist_ok=True` for mkdir
- Structure logs in session-based directories
- Use `os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())`

## Workflow

1. Read prerequisite documentation
2. Read specification at PATH_TO_SPEC
3. Analyze existing hooks for patterns
4. Implement following specification exactly
5. Test implementation
6. Document usage

## Report

Provide implementation summary and file paths.
```

## Example: Improve Expert

```markdown
---
description: Review changes and update expert knowledge
---

# Hook Expert Improve

You are a Hook Expert specializing in continuous improvement.

## Variables

None required - analyzes recent work automatically

## Instructions

- Review all recent changes to hook-related files
- Identify successful patterns and improvements
- Update ONLY the ## Expertise sections of expert commands
- Do NOT modify Workflow sections - they remain stable
- Document discovered best practices

## Workflow

1. Run `git diff` to examine uncommitted changes
2. Run `git log --oneline -10` for recent commits
3. Focus on hook-related files:
   - `.claude/hooks/*.py`
   - `.claude/settings*.json`
   - `specs/*-hook-spec.md`

4. Determine Relevance
   - New patterns or techniques discovered?
   - Better error handling found?
   - Performance optimizations?

   **If no relevant learnings → STOP and report "No updates needed"**

5. Extract and Apply Learnings

   **For Planning Knowledge** (update Expert Plan's ## Expertise):
   - New event usage patterns
   - Specification improvements
   - Security considerations

   **For Building Knowledge** (update Expert Build's ## Expertise):
   - Implementation patterns
   - Error handling techniques
   - Testing approaches

## Report

1. Changes Analyzed - files reviewed, relevance determination
2. Learnings Extracted - new patterns, improvements
3. Expert Updates Made - which sections updated, or "No updates needed"
```

## The Expertise Section

This is the key differentiator for Level 7:

```markdown
## Expertise

### Category Name

- Specific knowledge point
- Another knowledge point
- Pattern discovered from implementation

### Another Category

- More accumulated knowledge
```

**Rules for Expertise:**
- Organized into logical categories
- Contains concrete, actionable knowledge
- Updated ONLY by the Improve prompt
- Never modified during normal execution

## Characteristics

- **Expertise section**: Accumulated knowledge that grows
- **Stable Workflow**: Never modified by improvement
- **Expert families**: Plan → Build → Improve cycles
- **Feedback loops**: Implementations feed back into planning

## The Self-Improvement Cycle

1. **Plan** creates specification using current Expertise
2. **Build** implements using its Expertise
3. **Improve** reviews work, extracts learnings
4. **Improve** updates Plan and Build Expertise sections
5. Next iteration benefits from accumulated knowledge

## When to Use Level 7

- Domain experts for specific technologies
- Systems that should learn from experience
- Teams wanting to capture and share knowledge
- Complex domains with evolving best practices
