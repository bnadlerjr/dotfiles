# Tool Selection Guide

How to choose which tools an agent needs — and which to exclude.

## Principle: Least Privilege

Grant only the tools the agent needs for its job. Extra tools create risk (accidental file modification, unnecessary API calls) and waste context on tool descriptions the agent won't use.

## Common Tool Sets by Archetype

### Read-Only (Analyst / Scout)

```yaml
tools: [Read, Grep, Glob, LS]
```

For agents that examine code without modifying it. Safest configuration.

**Use when**: analyzing, documenting, locating, auditing, researching (local files)

**Examples**: codebase-analyzer, codebase-navigator, docs-analyzer, docs-locator

### Read + MCP (Semantic Search)

```yaml
tools: [Serena, Read, Grep, Glob, LS]
```

Adds semantic code search via MCP. Use when the agent needs to understand code meaning, not just text patterns.

**Use when**: navigating large codebases, finding implementations by concept

**Examples**: codebase-navigator, codebase-pattern-finder

### Code Modifier (Builder)

```yaml
tools: [Read, Write, Edit, Grep, Glob, Bash]
```

Full file modification capability. The agent can create, edit, and delete files, and run shell commands.

**Use when**: implementing features, refactoring, fixing bugs, creating files

**Examples**: code-simplifier (uses Read + Edit only — a focused variant)

### Web Researcher

```yaml
tools: [WebSearch, WebFetch, Read, Grep, Glob, LS]
```

Web access plus local file reading. For agents that research online and cross-reference with local files.

**Use when**: researching documentation, finding solutions, comparing approaches

**Examples**: web-search-researcher

### Orchestrator

```yaml
tools: [Read, Bash, Task, AskUserQuestion, Glob]
```

Can spawn sub-agents and interact with the user. For coordinator agents that delegate work.

**Use when**: multi-step workflows requiring user input and sub-agent delegation

**Note**: AskUserQuestion only works in the top-level context, not in sub-agents.

## Decision Tree

```
Does the agent need to modify files?
├─ Yes → Include Write, Edit
│   └─ Does it also need shell commands?
│       ├─ Yes → tools: [Read, Write, Edit, Grep, Glob, Bash]
│       └─ No  → tools: [Read, Write, Edit, Grep, Glob]
│
└─ No → Read-only base
    └─ Does it need web access?
        ├─ Yes → tools: [WebSearch, WebFetch, Read, Grep, Glob, LS]
        └─ No  → Does it need semantic search?
            ├─ Yes → tools: [Serena, Read, Grep, Glob, LS]
            └─ No  → tools: [Read, Grep, Glob, LS]
```

## Tool Reference

| Tool | Purpose | Risk Level |
|------|---------|------------|
| `Read` | Read file contents | None |
| `Grep` | Search file contents by regex | None |
| `Glob` | Find files by name pattern | None |
| `LS` | List directory contents | None |
| `Serena` | Semantic code search via MCP | None |
| `WebSearch` | Search the web | Low (external calls) |
| `WebFetch` | Fetch web page content | Low (external calls) |
| `Write` | Create or overwrite files | **Medium** |
| `Edit` | Modify existing files | **Medium** |
| `Bash` | Execute shell commands | **High** |
| `Task` | Spawn sub-agents | Medium |
| `AskUserQuestion` | Prompt the user | Low (only works top-level) |
| `NotebookEdit` | Edit Jupyter notebooks | **Medium** |

## `tools` vs `disallowedTools`

### Use `tools` (allowlist) when:
- The agent has a focused, well-defined role
- You can enumerate exactly which tools it needs
- Safety is a priority (read-only agents, analyzers)

### Use `disallowedTools` (blocklist) when:
- The agent needs most tools but not a few specific ones
- You want "everything except file modification"
- The tool set may grow and you don't want to update the list

### Use neither when:
- The agent should inherit all parent tools
- You're prototyping and haven't decided on restrictions yet

## Permission Hygiene Checklist

- [ ] Can the agent accomplish its job with fewer tools?
- [ ] If `Bash` is included, does the agent actually need shell access?
- [ ] If `Write`/`Edit` are included, does the agent need to create/modify files?
- [ ] If web tools are included, does the agent need internet access?
- [ ] Would `disallowedTools` be simpler than `tools` for this agent?
- [ ] Are MCP tools only included when the MCP server is actually configured?
