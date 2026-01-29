# Level 6: Template Meta-Prompt

A prompt that creates other prompts in a specific format. The most powerful prompt you can write.

**When to use:** Scaling prompt creation. Once you have consistent formats, template their generation.

**Builds on:** All previous levels + adds Template section for prompt generation.

## Example

```markdown
---
allowed-tools: Write, Edit, WebFetch, Task
description: Create a new prompt
argument-hint: [high-level description]
---

# MetaPrompt

Based on the High Level Prompt, create a new prompt in the Specified Format.

## Variables

HIGH_LEVEL_PROMPT: $ARGUMENTS

## Documentation

- Slash Command Documentation: https://docs.anthropic.com/en/docs/claude-code/slash-commands
- Available Tools Reference: https://docs.anthropic.com/en/docs/claude-code/settings

## Workflow

- We're building a new prompt to satisfy HIGH_LEVEL_PROMPT.
- Save to `.claude/commands/<name_of_prompt>.md`
  - Name should make sense based on HIGH_LEVEL_PROMPT
- VERY IMPORTANT: Use the Specified Format exactly
  - Do not create sections not in the Specified Format
- Replace every `<placeholder>` with appropriate content
- Use Task tool to fetch documentation if needed

## Specified Format

```md
---
allowed-tools: <comma separated tools needed>
description: <one-line description for identification>
argument-hint: [<arg1>], [<arg2>]
model: sonnet
---

# <name_of_prompt>

<purpose: 1-2 sentences describing what the prompt does>

## Variables

<DYNAMIC_VAR>: $1
<DYNAMIC_VAR_2>: $2
<STATIC_VAR>: <fixed value>

## Workflow

<numbered step-by-step execution plan>

## Report

<how to present results back to user>
```

## Report

Provide the path to the created prompt file.
```

## Example: Domain-Specific Template

```markdown
---
description: Create a plan for a Vue application
argument-hint: [task-id] [description]
---

# Plan Vue App

Create a detailed plan for building a Vue 3 + TypeScript application.

## Variables

TASK_ID: $1
DESCRIPTION: $2
APP_NAME: <derive concise name from DESCRIPTION>

## Instructions

- If TASK_ID or DESCRIPTION not provided, stop and ask
- Create concise APP_NAME from DESCRIPTION
- Follow the Plan Format exactly

## Workflow

1. Parse inputs and generate APP_NAME
2. Analyze DESCRIPTION for requirements
3. Design component structure
4. Write plan following Plan Format
5. Save to `specs/<TASK_ID>-<APP_NAME>.md`

## Plan Format

```md
# Plan: <task name>

## Metadata
task_id: `{TASK_ID}`
description: `{DESCRIPTION}`
app_name: `{APP_NAME}`
complexity: <simple|medium|complex>

## Objective
<what will be accomplished>

## Solution Approach
<proposed solution>

## Implementation Phases

### Phase 1: Foundation
<setup steps>

### Phase 2: Core Features
<implementation steps>

### Phase 3: Polish
<refinement steps>

## Acceptance Criteria
<how to verify success>
```
```

## The Template Section

The Template (or "Specified Format") section is the key differentiator:
- Defines exact structure of generated artifacts
- Uses `<placeholder>` syntax for variable parts
- Agent fills in placeholders based on context

### Placeholder Patterns

```markdown
<name_of_prompt>           # Derive from context
<comma separated>          # Format instruction
<one-line description>     # Length constraint
{VARIABLE_NAME}            # Reference a variable
<simple|medium|complex>    # Enumerated options
```

## Characteristics

- **Template section**: Exact format to generate
- **Placeholder replacement**: `<placeholder>` syntax filled by agent
- **Documentation links**: Context for format decisions
- **Meta-level thinking**: "A prompt that builds prompts"

## Why This Is Powerful

Once you have this:
1. Your prompt format is codified
2. New prompts follow consistent structure
3. Team members generate compatible prompts
4. You scale prompt creation with compute

## When to Level Up

Move to Level 7 (Self-Improving) when:
- You want prompts that accumulate knowledge
- You're building domain experts that learn
- You need Plan → Build → Improve cycles
