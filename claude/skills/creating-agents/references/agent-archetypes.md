# Agent Archetypes

Six common agent patterns based on the 8 existing agents in `~/.claude/agents/`. Use these as starting points — most agents map to one of these archetypes.

## 1. Analyst

**Purpose**: Deeply analyze a specific domain and produce structured reports.

**Characteristics**:
- Read-only tools
- Prominent DO NOT constraints (no suggestions, no critique)
- Structured output format with `file:line` references
- "Documentarian, not a critic" closing reminder
- Focused on *how things work*, not *how to improve them*

**Tools**: `Read, Grep, Glob, LS` (optionally `Serena`)

**Model**: `sonnet`

**Key pattern**: Strong role boundary — analyzes and documents without judging.

**Real examples**: `codebase-analyzer`, `docs-analyzer`

## 2. Scout

**Purpose**: Find and locate things without deep analysis. Returns locations, not insights.

**Characteristics**:
- Read-only tools (often includes `LS`)
- Categorized output (by file type, directory, relevance)
- Shallow reads — scans for relevance, doesn't analyze contents
- Returns organized lists, not prose

**Tools**: `Read, Grep, Glob, LS` or `Serena, Read, Grep, Glob, LS`

**Model**: `sonnet`

**Key pattern**: Breadth over depth — finds many things quickly, categorizes them.

**Real examples**: `codebase-navigator`, `docs-locator`, `codebase-pattern-finder`

## 3. Builder

**Purpose**: Modify code — create files, edit existing ones, run commands.

**Characteristics**:
- Full modification tools (Write, Edit, Bash)
- Spec-driven workflow (reads requirements, then implements)
- Verification step (confirms changes work)
- Structured change report

**Tools**: `Read, Write, Edit, Grep, Glob, Bash`

**Model**: `sonnet` or `opus` (depending on complexity)

**Key pattern**: Read → Plan → Modify → Verify cycle.

**Minimal variant**: `code-simplifier` uses only `Read, Edit, Glob, Grep` — it modifies files but doesn't create new ones or run commands.

**Real examples**: `code-simplifier`

## 4. Researcher

**Purpose**: Find information from web sources and synthesize findings.

**Characteristics**:
- Web tools (WebSearch, WebFetch) plus local file reading
- Multi-angle search strategy
- Source attribution and citation
- Findings organized by relevance and authority
- Publication date awareness

**Tools**: `WebSearch, WebFetch, Read, Grep, Glob, LS`

**Model**: `sonnet`

**Key pattern**: Search → Fetch → Synthesize → Cite cycle.

**Real examples**: `web-search-researcher`

## 5. Simplifier

**Purpose**: Review and refine existing code without changing behavior.

**Characteristics**:
- Limited modification tools (Edit only, no Write or Bash)
- Scoped to recent changes (doesn't touch unrelated code)
- Behavior-preserving constraint
- Reports what was changed and why

**Tools**: `Read, Edit, Glob, Grep`

**Model**: `inherit` (matches whatever the parent used)

**Key pattern**: Subtractive — removes complexity rather than adding features.

**Real examples**: `code-simplifier`

## 6. Validator

**Purpose**: Check code against a set of rules or patterns and report findings.

**Characteristics**:
- Read-only tools (analysis only)
- Checklist-driven evaluation
- Structured scoring report (passing/failing/score)
- Offers to fix issues (delegates to a Builder if needed)

**Tools**: `Read, Grep, Glob, LS` or all tools

**Model**: `inherit` or `sonnet`

**Key pattern**: Systematic checklist evaluation with scored report.

**Real examples**: `pattern-recognition-specialist`

## Choosing an Archetype

```
What is the agent's primary job?
├─ Understand how code works → Analyst
├─ Find where code lives → Scout
├─ Create or modify files → Builder
├─ Research information online → Researcher
├─ Clean up existing code → Simplifier
└─ Check code against rules → Validator
```

## Archetype Combinations

Some agents blend archetypes:

- **Scout + Analyst**: Finds code AND explains how it works (`codebase-pattern-finder`)
- **Validator + Builder**: Checks code AND fixes issues (`pattern-recognition-specialist` with fix mode)
- **Researcher + Analyst**: Researches online AND analyzes local code

When blending, pick a **primary** archetype for the agent's identity and tool set. The secondary archetype influences the workflow but doesn't expand the tools.

## Archetype Summary

| Archetype | Modifies? | Web? | Key constraint | Output |
|-----------|-----------|------|----------------|--------|
| Analyst | No | No | Don't suggest | Structured report |
| Scout | No | No | Don't analyze deeply | Categorized locations |
| Builder | Yes | No | Follow spec | Change report |
| Researcher | No | Yes | Cite sources | Synthesis with sources |
| Simplifier | Edit only | No | Don't change behavior | Diff report |
| Validator | No | No | Follow checklist | Score report |
