# Project Documentation Workflow

Write READMEs, getting started guides, and agent instructions that serve developers.

## Inputs

One or more of:
- Project path to document
- Natural language description of what needs documenting
- Specific doc type requested (README, getting started)

## Output Placement

Project docs are standalone markdown files:
- README: project root as `README.md`
- Getting started: `docs/getting-started.md` or project root

## Doc Type Detection

| Request Contains | Doc Type | Section |
|-----------------|----------|---------|
| "README", "project overview" | README | README section below |
| "getting started", "setup guide", "onboarding" | Getting Started Guide | Getting Started section below |

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

Follow the selected template. Apply these audience principles throughout:

- Lead with what the reader needs to do, not background
- Use concrete examples with copy-pasteable commands
- Keep paragraphs short (2-4 sentences)
- Provide the "happy path" first, edge cases after

### Step 4: Validate

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

## Quality Checklist

- [ ] A new developer can get the project running by following the doc alone
- [ ] All commands are copy-pasteable and correct
- [ ] Prerequisites list exact versions, not vague ranges
- [ ] Headings are specific and action-oriented
- [ ] No ambiguous pronouns across section boundaries
- [ ] README is under 200 lines (link to other docs for depth)
