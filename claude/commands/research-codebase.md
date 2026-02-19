---
description: Research and document existing codebase implementations
argument-hint: [topic or question]
model: opus
---

# Research Codebase

Research and document how the codebase works by spawning parallel
agents and synthesizing their findings.

Read and follow the methodology in the `researching-codebase` skill:
`~/dotfiles/claude/skills/researching-codebase/SKILL.md`

## Variables

TOPIC: $ARGUMENTS

## Instructions

- If TOPIC is empty, STOP immediately and respond:
  "I'm ready to research the codebase. Please provide your research
  question or area of interest, and I'll analyze it thoroughly by
  exploring relevant components and connections."
- If TOPIC is provided, begin decomposing the research question.
- Follow the `researching-codebase` skill methodology throughout.
- Focus on documentation — describe what exists, not what to improve.
- Include specific `file:line` references for all findings.

## Workflow

1. **Decomposition** — Break the question into composable research areas.
   Confirm the plan with the user before spawning agents.
2. **Research** — Spawn specialized agents in parallel to gather findings.
   Wait for ALL agents to complete.
3. **Synthesis** — Compile findings into a research document with
   concrete code references and architecture documentation.
4. **Follow-up** — Present findings, handle additional questions,
   update the document as needed.
