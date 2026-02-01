# Level 4: Delegation Prompt

Kicks off other agents to do work. Your primary agent becomes a prompt engineer for sub-agents.

**When to use:** Tasks that benefit from parallelization, background execution, or specialized agents.

**Builds on:** Level 3 + adds agent spawning and orchestration.

## Example: Parallel Agents

```markdown
---
description: Launch parallel agents to accomplish a task
argument-hint: [prompt request] [count]
---

# Parallel Subagents

Launch COUNT agents in parallel to accomplish a task.

## Variables

PROMPT_REQUEST: $1
COUNT: $2

## Workflow

1. Parse Input Parameters
   - Extract PROMPT_REQUEST
   - Determine COUNT (or infer from task complexity)

2. Design Agent Prompts
   - Create detailed, self-contained prompts for each agent
   - Include specific instructions
   - Define clear output expectations
   - Remember: agents are stateless and need complete context

3. Launch Parallel Agents
   - Use Task tool to spawn COUNT agents simultaneously
   - Ensure all agents launch in a single parallel batch

4. Collect & Summarize Results
   - Gather outputs from all completed agents
   - Synthesize findings into cohesive response

## Report

Summarize the combined findings from all agents.
```

## Example: Background Execution

```markdown
---
description: Fire off a Claude Code instance in the background
argument-hint: [prompt] [model] [report-file]
allowed-tools: Bash, Read, Write
---

# Background Agent

Run a Claude Code instance in the background for autonomous work.

## Variables

USER_PROMPT: $1
MODEL: $2 (defaults to 'sonnet' if not provided)
REPORT_FILE: $3 (defaults to './agents/background/report-<timestamp>.md')

## Instructions

- Capture timestamp FIRST before any operations
- Create the initial report file BEFORE launching
- Pass USER_PROMPT exactly as provided

## Workflow

1. Generate timestamp for report file naming
2. Create report file with initial header
3. Construct and execute background command:

<primary-agent-delegation>
  Execute using Bash with run_in_background=true:
  - claude --model MODEL
  - --append-system-prompt "Write progress to REPORT_FILE"
  - Pass USER_PROMPT as the task
</primary-agent-delegation>

4. Report the background task ID and report file path

## Report

Provide the task ID and path to the report file for monitoring.
```

## Key Concepts

### Agents Are Stateless

Sub-agents have no context from the primary agent. Every sub-agent prompt must be self-contained:
- Include all necessary context
- Specify exact expectations
- Define output format

### Parallel vs Sequential

**Parallel**: Use when tasks are independent
```markdown
- Use Task tool to spawn N agents simultaneously
- Ensure all agents launch in a single parallel batch
```

**Sequential**: Use when tasks depend on each other
```markdown
- Launch first agent, wait for result
- Use result to configure second agent
- Continue chain
```

### Agent Configuration

Pass configuration through:
- Model selection (`--model sonnet`)
- Tool restrictions (`allowed-tools:`)
- System prompt modifications (`--append-system-prompt`)

## Characteristics

- **Task tool**: Primary mechanism for spawning agents
- **Context passing**: Sub-agents need complete, self-contained prompts
- **Orchestration**: Primary agent designs and coordinates sub-agent work
- **Background execution**: `run_in_background=true` for async work

## When to Level Up

Move to Level 5 (Higher-Order) when:
- You want to decouple planning from execution
- The same execution prompt should work with different inputs
- You're building Plan → Build → Review chains
