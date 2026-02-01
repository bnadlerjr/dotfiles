# Level 3: Control Flow Prompt

Adds conditionals, loops, and early returns to the workflow.

**When to use:** Tasks with branching logic, iteration, or validation requirements.

**Builds on:** Level 2 + adds control flow structures in Workflow.

## Example

```markdown
---
allowed-tools: Bash, Write, Read
description: Generate images via API
argument-hint: [prompt] [count]
---

# Create Images

Generate images based on the provided prompt.

## Variables

IMAGE_PROMPT: $1
NUMBER_OF_IMAGES: $2 or 3 if not provided
OUTPUT_DIR: output/images/<date_time>/
MODEL: stable-diffusion-xl

## Workflow

- First, check if IMAGE_PROMPT is provided. If not, STOP immediately and ask for it.
- Get current timestamp: `date +%Y-%m-%d_%H-%M-%S`
- Create output directory: OUTPUT_DIR
- IMPORTANT: Generate NUMBER_OF_IMAGES using the loop below.

<image-loop>
  - Call image generation API with IMAGE_PROMPT and MODEL
  - Wait for completion
  - Save to OUTPUT_DIR/<concise_name>.jpg
  - Log the prompt used to OUTPUT_DIR/<concise_name>.txt
</image-loop>

- After all images are generated, open the output directory.

## Report

List all generated images with their file paths.
```

## Control Flow Patterns

### Early Return / Validation

```markdown
- If no PATH_TO_PLAN is provided, STOP immediately and ask the user to provide it.
- Check prerequisites and STOP immediately if missing:
  - API_TOKEN must be set
  - Required command must be available
```

### Conditionals

```markdown
- If the file exists, read and update it. Otherwise, create a new file.
- IMPORTANT: If authentication fails, abort immediately and report the error.
```

### Loops with XML Tags

```markdown
- IMPORTANT: For each item in the list, execute the following:

<process-loop>
  - Extract the item details
  - Process the item
  - Save results
  - Report progress
</process-loop>
```

### Named Loop Sections

The XML tag pattern (`<image-loop>`, `<process-loop>`) clearly marks loop boundaries for both the agent and human readers.

## Characteristics

- **Conditionals**: `If X, STOP immediately` or `If X, do Y. Otherwise, do Z.`
- **Loops**: Named XML sections like `<image-loop>`
- **Early returns**: Validation before expensive operations
- **IMPORTANT keyword**: Signals critical instructions to the agent

## When to Level Up

Move to Level 4 (Delegation) when:
- You need multiple agents working in parallel
- You want background execution
- The task benefits from specialized sub-agents
