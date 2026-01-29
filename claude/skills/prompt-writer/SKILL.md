---
name: prompt-writer
description: "Use when writing agentic prompts - system prompts, workflow prompts, delegation prompts, or meta prompts"
---

# Prompt Writer

## Overview

The prompt is the fundamental unit of engineering. Every prompt you create becomes a force multiplier—one well-crafted prompt can generate tens to hundreds of hours of productive work. One bad prompt compounds failure at the same rate.

**The Stakeholder Trifecta:** You're engineering for three audiences:
1. **You** - Must understand the prompt months later
2. **Your Team** - Must be able to use and modify it
3. **Your Agents** - Must execute it reliably

**Core Principle:** Consistency beats complexity. Use the same format across all your prompts.

## When to Use

**Always:**
- Creating reusable agentic prompts
- Writing system prompts for agents
- Defining tool/function descriptions
- Building workflow automation

**Trigger signals:**
- "write a prompt", "create a command"
- "automate this workflow"
- "make this reusable"
- Three times marks a pattern → capture it as a prompt

## Variables

USER_REQUEST: The user's description of what prompt to create
TARGET_CONTEXT: Where the prompt will be used (Claude Code command, system prompt, tool definition)

## Instructions

- Start at the lowest level that solves the problem—don't over-engineer
- Most prompts are Level 2-4; reach for Level 5+ only when needed
- If the user says "simple" or "quick", stay at Level 1-2
- Always ask: "Could a teammate understand this in 30 seconds?"
- Avoid adding sections "just in case"—each section must earn its place

## The Seven Levels

Each level builds on the previous. Most work happens at levels 2-4.

| Level | Name | Capability | When to Use |
|-------|------|------------|-------------|
| 1 | High-Level | Static, ad-hoc | Simple repeat tasks |
| 2 | Workflow | Sequential steps | Multi-step execution |
| 3 | Control Flow | Conditionals, loops | Branching logic, iteration |
| 4 | Delegation | Agent orchestration | Parallel work, background tasks |
| 5 | Higher-Order | Prompts as input | Plan → Build chains |
| 6 | Template Meta | Creates prompts | Scaling prompt creation |
| 7 | Self-Improving | Expertise grows | Domain experts that learn |

**For detailed examples, read the appropriate level file:**
- @levels/1-high-level.md
- @levels/2-workflow.md
- @levels/3-control-flow.md
- @levels/4-delegation.md
- @levels/5-higher-order.md
- @levels/6-template-meta.md
- @levels/7-self-improving.md

## Composable Sections

Sections are swappable Lego blocks. Use only what you need.

| Section | Purpose | Usefulness | Skill |
|---------|---------|------------|-------|
| **Workflow** | Step-by-step execution play | S-tier | C-tier |
| **Variables** | Dynamic ($1) and static inputs | A-tier | B-tier |
| **Examples** | Show desired output | A-tier | C-tier |
| **Report** | Output format specification | B-tier | C-tier |
| **Purpose** | High-level description | B-tier | D-tier |
| **Instructions** | Guardrails and constraints | B-tier | C-tier |
| **Template** | Format for meta-prompts (L6) | A-tier | A-tier |
| **Expertise** | Self-improving knowledge (L7) | A-tier | S-tier |
| **Metadata** | Tool access, model, hints | C-tier | C-tier |
| **Codebase Structure** | Context map of files | C-tier | C-tier |
| **Relevant Files** | Specific file references | C-tier | C-tier |

**Always include:** Title, Purpose, Workflow (levels 2+)

**Include when needed:**
- Variables: When inputs change between runs
- Instructions: When guardrails prevent mistakes
- Report: When output format matters
- Examples: When behavior is unclear

## The Input → Workflow → Output Pattern

Every prompt follows this three-step structure:

```
┌─────────────────────────────────────────────────┐
│  INPUT                                          │
│  - Variables (dynamic and static)               │
│  - Context (codebase structure, relevant files) │
├─────────────────────────────────────────────────┤
│  WORKFLOW                                       │
│  - Step-by-step numbered execution              │
│  - Control flow (conditionals, loops)           │
│  - Delegation (spawning sub-agents)             │
├─────────────────────────────────────────────────┤
│  OUTPUT                                         │
│  - Report format                                │
│  - Artifacts created                            │
└─────────────────────────────────────────────────┘
```

**Input and Output** are for you and your team—quick understanding.
**Workflow** is the actual work—this is where you dial in the step-by-step play.

## System Prompts vs User Prompts

| Aspect | System Prompt | User Prompt |
|--------|---------------|-------------|
| Scope | Rules for ALL conversations | Instructions for ONE task |
| Persistence | Cannot change mid-conversation | Changes with each invocation |
| Mistakes | Scale to every user prompt | Isolated to single run |

**System prompts** (agent personality): Use Purpose, Instructions, Examples. Avoid prescriptive workflows.

**User prompts** (reusable commands): Use full section toolkit. This is 90% of what you'll write.

## Workflow

1. **Identify the Level**
   - Simple repeat task → Level 1
   - Sequential steps → Level 2
   - Conditionals/loops → Level 3
   - Multiple agents → Level 4
   - Plan as input → Level 5
   - Generate prompts → Level 6
   - Learn over time → Level 7

2. **Choose Sections**
   - Start minimal. Add only when needed:
   - Title + Purpose (always)
   - Workflow (levels 2+)
   - Variables (if inputs change)
   - Report (if output format matters)
   - Instructions (if guardrails needed)

3. **Write the Workflow**
   - Numbered steps with clear action verbs
   - Reference variables by name
   - Include control flow where needed
   - Read @levels/<N>-<name>.md for the appropriate level's patterns

4. **Test and Iterate**
   - Run with representative inputs
   - Check edge cases
   - Tighten where output varies
   - Add examples where behavior is unclear

## Report

Deliver the prompt in this format:

```markdown
---
description: <one-line description>
argument-hint: [<args if any>]
allowed-tools: <if restricting tools>
---

# <Prompt Name>

<Purpose: 1-2 sentences>

## Variables (if needed)
## Instructions (if needed)
## Workflow
## Report (if needed)
```

State the level used and why. If the prompt could be simpler, say so.
