---
name: writing-documentation
description: |
  Writes documentation for two audiences: human developers and LLMs. Covers three
  doc types: code-level docs (module headers, function docs, inline comments),
  architecture docs (ADRs, design docs, system overviews), and project docs
  (READMEs, guides, CLAUDE.md). Language-agnostic.

  Use when asked to "document", "add docs", "write a README", "create an ADR",
  "add module docs", "document this function", "write architecture docs",
  "create a getting started guide", "write CLAUDE.md", or "add comments".
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
---

# Writing Documentation

Write documentation that serves two audiences: human developers who need to understand and use code, and LLMs that need to retrieve, chunk, and reason about code.

## Quick Start

Provide a code reference (file, module, function) or describe what needs documenting:

```
"Document the auth module in lib/my_app/auth/"
"Write an ADR for choosing PostgreSQL"
"Create a README for this project"
"Add function docs to UserController"
"Write a getting started guide"
```

## Doc Type Router

Detect the doc type from the request, then read the matching workflow.

| Signal in Request | Doc Type | Workflow |
|-------------------|----------|----------|
| file path, function name, "add docs", "add comments", "module docs", "docstring" | Code-Level | `workflows/code-level-docs.md` |
| "ADR", "design doc", "architecture", "system overview", "how modules interact" | Architecture | `workflows/architecture-docs.md` |
| "README", "getting started", "CLAUDE.md", "agent instructions", "guide" | Project | `workflows/project-docs.md` |

**If ambiguous**: Ask the user which doc type they need. If you cannot ask (sub-agent context), default to code-level docs when given a file path, architecture docs when given a system description, and project docs when given a project path.

## Workflow

### Step 1: Detect Doc Type

Read the user's request. Match against the router table above to select the workflow.

### Step 2: Read the Workflow

Load the matching workflow file. It contains the full procedure, templates, and quality checklist for that doc type.

### Step 3: Follow the Workflow

Each workflow covers:
1. **Gather context** — Read the code or project to understand what needs documenting
2. **Select template** — Choose the right structure for the doc type
3. **Write the doc** — Apply both Ousterhout and LLM-friendly principles
4. **Post-process** — Apply writing-for-humans to user-facing prose (project docs only)
5. **Validate** — Run the quality checklist

### Step 4: Place the Output

Output placement depends on doc type:

| Doc Type | Placement |
|----------|-----------|
| Code-level | Inline with source code (docstrings, comments, module headers) |
| Architecture | Separate markdown file (docs/adr/, docs/design/, docs/) |
| Project | Separate markdown file (project root or docs/) |

## Dual-Audience Principles

Every doc produced by this skill serves two audiences simultaneously.

### For Human Developers

Based on Ousterhout's "A Philosophy of Software Design" (see `references/ousterhout-principles.md`):

- Reduce cognitive load — make the reader's job easier, not harder
- Separate interface from implementation — document WHAT, not HOW
- Document non-obvious things — skip what the code already says
- Use documentation as a design tool — writing docs reveals design problems
- Document cross-module interactions — not just individual components
- Low-level comments add precision; high-level comments provide intuition

### For LLMs

Based on retrieval and chunking patterns (see `references/llm-doc-patterns.md`):

- Consistent structure — same heading hierarchy across docs of the same type
- Explicit headings — keyword-rich, not generic
- Front-loaded context — most important information first (BLUF)
- Self-contained sections — each section understandable when extracted
- Explicit relationships — state dependencies by fully qualified name
- Grep-friendly identifiers — consistent naming, full qualified names
- No ambiguous pronouns — use explicit nouns across chunk boundaries

## writing-for-humans Composition

User-facing prose (READMEs, guides, tutorials) goes through `writing-for-humans` post-processing. The project-docs workflow handles this automatically.

**Applies to**: READMEs, getting started guides, tutorials

**Does not apply to**: Code-level docs, architecture docs, CLAUDE.md, agent instructions

## Examples

### Code-Level: Documenting a Module

**Input**: "Document lib/my_app/auth/session_manager.ex"

**Action**: Read the file, write `@moduledoc` and `@doc` annotations inline. Follow `workflows/code-level-docs.md`.

### Architecture: Writing an ADR

**Input**: "Write an ADR for why we chose Phoenix over Rails"

**Action**: Create `docs/adr/NNN-use-phoenix-framework.md` using the ADR template. Follow `workflows/architecture-docs.md`.

### Project: Creating a README

**Input**: "Create a README for this project"

**Action**: Examine the project structure, write `README.md`, post-process with writing-for-humans. Follow `workflows/project-docs.md`.

## References

| Reference | When to Load |
|-----------|--------------|
| `references/ousterhout-principles.md` | When deciding what to document and at what level of detail |
| `references/llm-doc-patterns.md` | When structuring docs for retrieval and chunking |

Load references when the workflow instructions tell you to, or when you need to resolve a judgment call about documentation content or structure.

## Anti-Patterns

- Restating the code in comments ("increment counter" above `counter += 1`)
- Generic headings ("Overview", "Details", "Miscellaneous")
- Implementation details in interface docs ("uses a hash map internally")
- Ambiguous pronouns across section boundaries ("it handles this by...")
- Documentation that is longer than the code it describes (for code-level docs)
- Prose in agent instructions (CLAUDE.md should be directives, not paragraphs)
