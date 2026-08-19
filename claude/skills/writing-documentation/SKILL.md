---
name: writing-documentation
description: Write documentation for code, architecture, and projects.
---

# Writing Documentation

Write documentation for code, architecture, and projects. The reason for writing documentation is that statements in a programming language can't capture all of the important information that was in the mind of the developer when the code was written. Documentation should describe things that are not obvious from the code.

## Workflow

### Step 1: Detect Doc Type

Detect the doc type from the request.

| Signal in Request | Doc Type | Workflow |
|-------------------|----------|----------|
| file path, function name, "add docs", "add comments", "module docs", "docstring" | Code-Level | `references/code-level-docs.md` |
| "ADR", "design doc", "architecture", "system overview", "how modules interact" | Architecture | `references/architecture-docs.md` |
| "README", "getting started", "CLAUDE.md", "agent instructions", "guide" | Project | `references/project-docs.md` |

### Step 2: Read the Workflow

Load the matching workflow file. It contains the full procedure, templates, and quality checklist for that doc type.

### Step 3: Follow the Workflow

Each workflow covers:
1. **Gather context** — Read the code or project to understand what needs documenting
2. **Select template** — Choose the right structure for the doc type
3. **Write the doc** — Apply `references/ousterhout-principles.md`
4. **Validate** — Run the quality checklist

### Step 4: Place the Output

Output placement depends on doc type:

| Doc Type | Placement |
|----------|-----------|
| Code-level | Inline with source code (docstrings, comments, module headers) |
| Architecture | Separate markdown file (docs/adr/, docs/design/, docs/) |
| Project | Separate markdown file (project root or docs/) |

## Anti-Patterns

- Restating the code in comments ("increment counter" above `counter += 1`)
- Generic headings ("Overview", "Details", "Miscellaneous")
- Implementation details in interface docs ("uses a hash map internally")
- Ambiguous pronouns across section boundaries ("it handles this by...")
- Documentation that is longer than the code it describes (for code-level docs)
