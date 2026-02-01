# Level 2: Workflow Prompt

Sequential workflow with the **Input → Workflow → Output** pattern. This is the most important level—the workflow section is where the real power lives.

**When to use:** Any task requiring multiple steps executed in order.

**Builds on:** Level 1 + adds Variables, Workflow, Report sections.

## Example

```markdown
---
allowed-tools: Read, Write, Edit, Glob, Grep
description: Creates a concise implementation plan
argument-hint: [user prompt]
---

# Quick Plan

Create a detailed implementation plan based on the user's requirements.

## Variables

USER_PROMPT: $ARGUMENTS
PLAN_OUTPUT_DIRECTORY: `specs/`

## Instructions

- Carefully analyze the user's requirements
- Create a concise implementation plan
- Generate a descriptive, kebab-case filename

## Workflow

1. Analyze Requirements - Parse USER_PROMPT thoroughly
2. Design Solution - Develop technical approach
3. Document Plan - Structure a comprehensive markdown document
4. Save & Report - Write the plan to PLAN_OUTPUT_DIRECTORY

## Report

After creating the plan, provide a concise report with the file path.
```

## Characteristics

- **Variables**: Dynamic (`$ARGUMENTS`, `$1`, `$2`) and static (hardcoded paths)
- **Workflow**: Numbered step-by-step play
- **Report**: Specifies output format
- **Metadata**: Tool restrictions, description, argument hints

## Variable Syntax

```markdown
## Variables

DYNAMIC_VAR: $ARGUMENTS           # Full argument string
FIRST_ARG: $1                     # Positional argument
SECOND_ARG: $2                    # Positional argument
STATIC_VAR: `some/fixed/path/`    # Hardcoded value
WITH_DEFAULT: $2 or 3 if not provided
```

## When to Level Up

Move to Level 3 (Control Flow) when:
- You need conditional logic (if X, do Y)
- You need to loop over items
- You need early returns for validation
