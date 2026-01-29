# Level 5: Higher-Order Prompt

Accepts another prompt (file) as input. Provides consistent structure while the input varies.

**When to use:** Decoupling planning from execution. Same prompt works with different plan inputs.

**Builds on:** Levels 2-4 + accepts prompt files as input parameters.

## Example

```markdown
---
description: Build the codebase based on the plan
argument-hint: [path-to-plan]
allowed-tools: Read, Write, Edit, Bash
---

# Build

Implement the plan at PATH_TO_PLAN then report the completed work.

## Variables

PATH_TO_PLAN: $ARGUMENTS

## Workflow

- If no PATH_TO_PLAN is provided, STOP immediately and ask the user to provide it.
- Read the plan at PATH_TO_PLAN.
- Think hard about the plan and implement it into the codebase.

## Report

- Summarize the work in a concise bullet point list.
- Report files changed with `git diff --stat`
```

## Example: Context Bundle Loading

```markdown
---
description: Load context from a previous agent's work
argument-hint: [bundle-path]
allowed-tools: Read, Bash(ls*)
---

# Load Context Bundle

Understand the previous agent's context and continue the work.

## Variables

BUNDLE_PATH: $ARGUMENTS

## Instructions

- Deduplicate file entries and read the most comprehensive version
- Each line in the JSONL is a separate JSON object
- For operation: prompt, just read the 'prompt' key value
- Think about the story of the work done as you read

## Workflow

1. Read the context bundle JSONL file at BUNDLE_PATH
2. Deduplicate and optimize file reads:
   - Group all entries by file_path
   - For each unique file, determine optimal read parameters
3. Read each unique file ONLY ONCE with optimal parameters
4. Synthesize understanding of previous work

## Report

Summarize the context loaded and your understanding of the work state.
```

## The Power of Higher-Order Prompts

### Decoupling Planning from Execution

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  /plan      │ ──▶ │  spec.md    │ ──▶ │  /build     │
│  (creates)  │     │  (artifact) │     │  (consumes) │
└─────────────┘     └─────────────┘     └─────────────┘
```

The **plan** prompt creates a specification file.
The **build** prompt consumes any specification file.
They're independent—you can use different planners with the same builder.

### Modular Workflow Chains

```markdown
/quick-plan "Add user authentication"
  → specs/add-user-auth.md

/build specs/add-user-auth.md
  → Implementation

/review specs/add-user-auth.md
  → Code review against spec
```

## Characteristics

- **Prompt file as input**: `$ARGUMENTS` points to a plan/spec file
- **Flexible**: Same execution prompt works with any compatible input
- **Enables modularity**: Plan → Build → Review chains
- **Reusable infrastructure**: The higher-order prompt is stable; inputs vary

## When to Level Up

Move to Level 6 (Template Meta) when:
- You want to generate new prompts programmatically
- You have consistent prompt formats to template
- You're scaling prompt creation across a team
