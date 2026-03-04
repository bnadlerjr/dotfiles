# Project Documentation Workflow

Write READMEs, getting started guides, CLAUDE.md files, and agent instructions that serve both human developers and LLMs.

## Inputs

One or more of:
- Project path to document
- Natural language description of what needs documenting
- Specific doc type requested (README, getting started, CLAUDE.md)

## Output Placement

Project docs are standalone markdown files:
- README: project root as `README.md`
- Getting started: `docs/getting-started.md` or project root
- CLAUDE.md: project root or `.claude/CLAUDE.md`
- Agent instructions: `.claude/CLAUDE.md`, `AGENTS.md`, or similar

## Doc Type Detection

| Request Contains | Doc Type | Section |
|-----------------|----------|---------|
| "README", "project overview" | README | README section below |
| "getting started", "setup guide", "onboarding" | Getting Started Guide | Getting Started section below |
| "CLAUDE.md", "agent instructions", "coding guidelines" | Agent Instructions | Agent Instructions section below |

## Procedure

### Step 1: Gather Context

Examine the project:

1. Read the directory structure (identify language, framework, key directories)
2. Find existing docs to understand current state and avoid duplication
3. Read package manifests (package.json, mix.exs, Cargo.toml, etc.) for project metadata
4. Identify key commands (build, test, lint, run)
5. Find configuration files that reveal project conventions

### Step 2: Select Template

Choose the appropriate template based on doc type detection above.

### Step 3: Write the Draft

Follow the selected template. Apply these dual-audience principles throughout:

**For human readers**:
- Lead with what the reader needs to do, not background
- Use concrete examples with copy-pasteable commands
- Keep paragraphs short (2-4 sentences)
- Provide the "happy path" first, edge cases after

**For LLM readers** (from `references/llm-doc-patterns.md`):
- Use explicit, keyword-rich headings
- Front-load context in each section
- Make each section self-contained
- Use fully qualified names for all code references
- State relationships explicitly

### Step 4: Post-Process with writing-for-humans

READMEs and getting started guides are user-facing prose. After drafting, post-process with the `writing-for-humans` skill:

1. Read `~/.claude/skills/writing-for-humans/SKILL.md`
2. Apply its rewriting methodology to the draft
3. Return only the rewritten text — no meta-commentary

**Apply writing-for-humans to**:
- READMEs
- Getting started guides
- Tutorials
- Any user-facing prose sections

**Do NOT apply writing-for-humans to**:
- CLAUDE.md / agent instructions (these are machine-consumed directives, not prose)
- Inline code examples within docs
- Configuration snippets

### Step 5: Validate

Run through the quality checklist at the bottom of this file.

---

## README Template

```markdown
# [Project Name]

[One sentence: what this project does and who it is for.]

## Quick Start

[Minimal steps to get running. Copy-pasteable commands.]

```bash
[clone/install/run commands]
```

## What It Does

[2-5 bullet points describing key capabilities. Each bullet is one behavior,
not a vague feature claim.]

## Project Structure

[Key directories and what they contain. Skip obvious ones.]

```
src/
  auth/       # Authentication and session management
  billing/    # Payment processing and invoicing
  api/        # REST and GraphQL endpoints
```

## Development

### Prerequisites

[List exact versions: Node 20+, Elixir 1.16+, PostgreSQL 15+]

### Setup

```bash
[step-by-step commands]
```

### Common Tasks

| Task | Command |
|------|---------|
| Run tests | `mix test` |
| Lint | `mix credo --strict` |
| Format | `mix format` |

## Architecture

[Brief description or link to architecture doc. Focus on the mental model
a new developer needs, not exhaustive details.]

## Contributing

[Branch naming, PR process, commit conventions. Keep brief — link to a
CONTRIBUTING.md if detailed.]
```

---

## Getting Started Guide Template

```markdown
# Getting Started with [Project Name]

[One sentence: what the reader will be able to do after completing this guide.]

## Prerequisites

[Exact tool versions needed. Include installation links.]

- [Tool] [version]: [install link]

## Setup

### Step 1: [Action Verb First]

```bash
[command]
```

[One sentence explaining what this does, if not obvious.]

### Step 2: [Action Verb First]

```bash
[command]
```

### Step 3: Verify Setup

```bash
[verification command]
```

Expected output:
```
[what they should see]
```

## First Task

[Walk through a concrete task the developer will actually do.
Not abstract concepts — a real action with real output.]

### [Specific Action]

[Step-by-step with commands and expected results.]

## What to Read Next

- [Link to architecture doc] — understand how the system fits together
- [Link to API reference] — reference for available endpoints
- [Link to testing guide] — how to write and run tests
```

---

## Agent Instructions Template (CLAUDE.md)

Agent instructions follow different rules than human-facing prose. They are machine-consumed directives optimized for consistent agent behavior.

```markdown
# [Project Name]

[One sentence: what this project is.]

## Commands

- `[test command]`
- `[lint command]`
- `[format command]`
- `[single test command pattern]`

## Rules

- [NEVER/ALWAYS directives — critical constraints]
- [NEVER/ALWAYS directives]

## Guidelines

- [Coding Standards](guidelines/coding-standards.md)
- [Testing](guidelines/testing.md)
- [Git Workflow](guidelines/git-workflow.md)
```

**Agent instruction rules**:
- Root file under 50 lines — link to `guidelines/*.md` for details
- Use NEVER/ALWAYS for hard constraints (these are strong signals for agents)
- Commands section lists exact commands the agent can run
- No prose explanations — every line is either a command or a directive
- Follow progressive disclosure: root has essentials, linked files have details

**Do NOT apply writing-for-humans post-processing to agent instructions.** They are not prose.

---

## Post-Processing Decision Matrix

| Doc Type | writing-for-humans? | Reason |
|----------|---------------------|--------|
| README | Yes | User-facing prose |
| Getting Started Guide | Yes | User-facing prose |
| CLAUDE.md | No | Machine-consumed directives |
| Agent Instructions | No | Machine-consumed directives |
| Tutorials | Yes | User-facing prose |

## Quality Checklist

- [ ] A new developer can get the project running by following the doc alone
- [ ] All commands are copy-pasteable and correct
- [ ] Prerequisites list exact versions, not vague ranges
- [ ] Headings are specific and action-oriented
- [ ] Each section is self-contained (LLM chunking friendly)
- [ ] No ambiguous pronouns across section boundaries
- [ ] README is under 200 lines (link to other docs for depth)
- [ ] CLAUDE.md root is under 50 lines (link to guidelines for depth)
- [ ] User-facing docs have been post-processed with writing-for-humans
- [ ] Agent instructions use NEVER/ALWAYS for hard constraints
