# Agent Frontmatter Specification

All 12 fields available in agent `.md` definition files.

## Required Fields

### `name`

**Required.** The agent's display name, used in Task tool `subagent_type` and team coordination.

- Lowercase letters, numbers, hyphens only
- Max 64 characters
- Must be unique across all agents (personal + project)

```yaml
# Good
name: codebase-analyzer
name: web-search-researcher

# Bad
name: My Cool Agent    # spaces, uppercase
name: analyzer         # too generic, collision risk
```

### `description`

**Required. Highest-leverage field.** Determines when Claude delegates to this agent via the Task tool. Write it as if explaining to a dispatcher when to send this specialist.

Must include:
- **What** the agent does (capabilities)
- **When** to use it (trigger conditions)
- Action-oriented language ("Use this agent when...")

```yaml
# Good — specific triggers, clear capabilities
description: "Analyzes codebase implementation details. Call the codebase-analyzer
  agent when you need to find detailed information about specific components.
  As always, the more detailed your request prompt, the better! :)"

# Bad — vague, no triggers
description: "Helps with code"
```

**Advanced technique**: Include `<example>` blocks in the description to show delegation scenarios. Claude uses these to pattern-match when choosing agents.

```yaml
description: "Use this agent when... <example>Context: The user wants to
  analyze their codebase.\\nuser: \"Can you check our codebase?\"\\nassistant:
  \"I'll use the pattern-recognition-specialist...\"</example>"
```

## Tool Configuration

### `tools`

**Optional.** Allowlist of tools the agent can use. If omitted, the agent inherits all tools available to the parent.

Accepts a YAML list or comma-separated string:

```yaml
# List format
tools: [Read, Grep, Glob, LS]

# String format
tools: Read, Grep, Glob, LS
```

Common tool sets by archetype:

| Archetype | Tools |
|-----------|-------|
| Read-only | `Read, Grep, Glob, LS` |
| Code modifier | `Read, Write, Edit, Grep, Glob, Bash` |
| Researcher | `WebSearch, WebFetch, Read, Grep, Glob, LS` |
| MCP-powered | `Serena, Read, Grep, Glob, LS` |

See [tool-selection.md](tool-selection.md) for detailed guidance.

### `disallowedTools`

**Optional.** Blocklist of tools the agent cannot use. Use instead of `tools` when you want "everything except X."

```yaml
# Allow everything except file modification
disallowedTools: [Write, Edit, NotebookEdit]
```

**Rule**: Use `tools` (allowlist) for focused agents. Use `disallowedTools` (blocklist) for broad agents that need most tools but not a few dangerous ones.

## Model Configuration

### `model`

**Optional.** Which Claude model to use. If omitted, inherits from parent.

| Value | When to use |
|-------|-------------|
| `sonnet` | Most agents. Fast, capable, cost-effective. |
| `opus` | Complex reasoning, nuanced judgment, creative writing. |
| `haiku` | Simple, high-volume tasks. Quick classification or formatting. |
| `inherit` | Explicitly use whatever the parent uses. |

```yaml
model: sonnet   # Default choice for most agents
```

### `maxTurns`

**Optional.** Maximum number of agentic turns (API round-trips) before the agent stops. Guards against runaway agents.

```yaml
maxTurns: 15    # Reasonable default for focused tasks
```

## Permission Configuration

### `permissionMode`

**Optional.** Controls how the agent handles tool permission requests.

| Value | Effect |
|-------|--------|
| `default` | Inherits parent's permission mode |
| `bypassPermissions` | Skips all permission checks (use with caution) |
| `plan` | Requires plan approval before implementation |

```yaml
permissionMode: default   # Safest choice
```

## Skill Integration

### `skills`

**Optional.** List of skills the agent can invoke. Keeps the agent definition lean while giving it access to deep domain knowledge.

```yaml
skills: [developing-elixir, practicing-tdd]
```

**Token economy principle**: Put workflow logic and reference material in skills, not in the agent body. The agent defines *what it is*; skills carry the *detailed how-to*.

## Server Configuration

### `mcpServers`

**Optional.** MCP servers available to this agent. Format matches the MCP server configuration in Claude Code settings.

```yaml
mcpServers:
  serena:
    command: npx
    args: ["-y", "serena-mcp"]
```

## Lifecycle

### `hooks`

**Optional.** Shell commands that execute in response to agent lifecycle events.

```yaml
hooks:
  onStart: "echo 'Agent started'"
  onComplete: "echo 'Agent finished'"
```

### `memory`

**Optional.** Path to a memory file the agent can read/write for persistent state across invocations.

```yaml
memory: ~/.claude/memory/analyzer-notes.md
```

## Appearance

### `color`

**Optional.** Display color for the agent in the UI.

Valid values: `red`, `orange`, `yellow`, `green`, `teal`, `cyan`, `blue`, `purple`, `magenta`, `pink`

```yaml
color: teal   # Most common in existing agents
```

## Complete Example

```yaml
---
name: codebase-analyzer
description: Analyzes codebase implementation details. Call the codebase-analyzer
  agent when you need to find detailed information about specific components.
tools: Read, Serena, Grep, Glob, LS
model: sonnet
color: teal
---
```

## Field Priority

When designing an agent, focus effort in this order:

1. **description** — Gets the agent selected (or not)
2. **tools** — Defines what the agent can do
3. **model** — Affects quality and speed
4. **name** — Must be unique and descriptive
5. Everything else — Configure as needed
