---
description: Write documentation for human developers and LLMs (code docs, architecture docs, READMEs, ADRs, CLAUDE.md)
argument-hint: "[file/module path or description of what to document]"
---

# Write Documentation

Write documentation that serves both human developers and LLMs, covering code-level docs, architecture docs, and project docs.

## Variables

- TARGET: $ARGUMENTS (required — file path, module name, or description of what to document)

## Instructions

Invoke the `writing-documentation` skill and follow its router workflow:

1. **Detect doc type** from TARGET — code-level, architecture, or project docs
2. **Read the matching workflow** for the detected doc type
3. **Gather context** — examine the code or project structure
4. **Write the documentation** applying dual-audience principles (Ousterhout + LLM patterns)
5. **Post-process** — apply `writing-for-humans` to user-facing prose (READMEs, guides only)
6. **Validate** — run the quality checklist from the workflow

If TARGET is empty, STOP immediately and respond:
"Provide a file path, module name, or description of what to document. Examples:
- `lib/my_app/auth/session_manager.ex` (code-level docs)
- `Write an ADR for choosing PostgreSQL` (architecture docs)
- `Create a README for this project` (project docs)"

## Report

When complete, show:
- Doc type detected and workflow used
- Files created or modified
- Audience-specific decisions made (what was optimized for humans vs. LLMs)
- Quality checklist results
