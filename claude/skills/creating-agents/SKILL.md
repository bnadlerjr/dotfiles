---
name: creating-agents
description: Expert guidance for creating, auditing, and improving Claude Code agent definition files (.md). Use when working with ~/.claude/agents/ files, authoring new sub-agents, improving existing agents, or understanding agent configuration and system prompt best practices.
---

# Creating Agents

This skill teaches how to create effective Claude Code agent definition files (`.md` files in `~/.claude/agents/` or `.claude/agents/`).

## Quick Start

Create a new agent at `~/.claude/agents/`:

```markdown
# ~/.claude/agents/my-agent.md
---
name: my-agent
description: Analyzes test coverage gaps and suggests missing test cases.
  Use when reviewing test suites or when the user asks about test coverage.
tools: [Read, Grep, Glob, LS]
model: sonnet
color: teal
---

You are a test coverage analyst. Your job is to identify untested code paths
and suggest specific test cases to fill gaps.

## CRITICAL: You analyze tests, you don't write them
- DO NOT modify any files
- DO NOT write test code
- ONLY identify gaps and suggest what to test

## Core Responsibilities

1. **Find Untested Code**
   - Trace code paths without matching tests
   - Identify edge cases missing coverage

2. **Suggest Test Cases**
   - Describe specific scenarios to test
   - Include expected inputs and outputs

## Output Format

## Coverage Analysis: [Component]

### Untested Paths
- `file:line` - Description of untested path

### Suggested Tests
1. Test [scenario] - expects [outcome]
```

## Essential Principles

### 1. Description Drives Delegation

The `description` field is the highest-leverage part of an agent. It determines when Claude's Task tool selects this agent. Write it as instructions to a dispatcher: what the agent does AND when to send work to it.

### 2. Context Isolation

Agents start with a fresh context window. The system prompt is all they know. Make prompts self-contained — don't assume the agent has access to prior conversation or project context.

### 3. Single Responsibility

One agent, one clear mission. If you're writing "and also handles X," make a second agent. Single-purpose agents are easier to test, improve, and compose.

### 4. Token Economy

Agent definitions are loaded in full every time the agent is spawned. Keep definitions concise (under ~200 lines). Delegate deep knowledge to skills via the `skills` frontmatter field. The agent defines *what it is*; skills carry the *detailed how-to*.

### 5. Permission Hygiene

Only grant tools the agent needs. A read-only analyst shouldn't have `Write` or `Bash`. Use `tools` (allowlist) for focused agents, `disallowedTools` (blocklist) for broad ones.

### 6. Constraint-First Prompting

Place DO NOT constraints near the top of the system prompt, right after the role statement. Constraints buried at the bottom get less attention from the model.

## What Would You Like To Do?

1. **Create a new agent** — Build an agent from scratch
   → Read [workflows/create-new-agent.md](workflows/create-new-agent.md)

2. **Audit an existing agent** — Check against best practices
   → Read [workflows/audit-agent.md](workflows/audit-agent.md)

3. **Improve an existing agent** — Make targeted improvements
   → Read [workflows/improve-agent.md](workflows/improve-agent.md)

## Audit Checklist (Quick Reference)

Use this checklist for both creating and auditing agents. For the full detailed audit with severity scoring, see [workflows/audit-agent.md](workflows/audit-agent.md).

### Frontmatter
- [ ] `name` present (lowercase-with-hyphens, unique)
- [ ] `description` says what it does AND when to use it
- [ ] `tools` scoped appropriately (not over-permissioned)
- [ ] `model` specified
- [ ] `color` specified

### System Prompt
- [ ] Role statement present (first 1-3 sentences)
- [ ] CRITICAL constraints section near the top
- [ ] Core responsibilities defined (2-4 items)
- [ ] Workflow / strategy section present
- [ ] Output format template defined
- [ ] Guidelines (do/don't) present
- [ ] Closing reminder anchors the role

### Token Economy
- [ ] Definition under ~200 lines
- [ ] Deep knowledge delegated to skills
- [ ] No inline reference material

### Design Quality
- [ ] Single responsibility — one clear mission
- [ ] Self-contained — prompt works without external context
- [ ] Constraint coverage — clear boundaries on what agent does NOT do
- [ ] Tool justification — every tool in `tools` has a use case

## Reference Files

For detailed guidance on specific topics:

- [Frontmatter Specification](references/frontmatter-spec.md) — All 12 fields with guidance
- [System Prompt Patterns](references/system-prompt-patterns.md) — Body structure best practices
- [Tool Selection Guide](references/tool-selection.md) — Tool combos and permission hygiene
- [Agent Archetypes](references/agent-archetypes.md) — Common agent types with real examples

## Templates

Start from a template matching your archetype:

- [Read-Only Agent](templates/read-only-agent.md) — Analyst, Scout, Validator
- [Code Modifier Agent](templates/code-modifier-agent.md) — Builder, Simplifier
- [Researcher Agent](templates/researcher-agent.md) — Web research specialist

## Success Criteria

A well-designed agent:
- Has a description that gets it selected for the right tasks
- Stays within its tool permissions and role boundaries
- Produces consistent, structured output
- Fits under ~200 lines, delegating depth to skills
- Passes the audit checklist above
