---
description: Surface design decisions and scope before codebase research begins
argument-hint: [ticket reference or task description]
allowed-tools: Read, Skill, AskUserQuestion, Write, Bash(gh), Bash(ls), Bash(grep)
model: opus
---

# Questions

Identify the design decisions a human must make before codebase research can be targeted. No researching. No planning. Just the right questions.

## Variables

TASK_INPUT: $ARGUMENTS
ARTIFACT_DIR: $CLAUDE_DOCS_ROOT/research/

## Instructions

- Do NOT spawn codebase research agents or search the codebase
- Do NOT suggest implementations or solutions
- Do NOT give opinions on which option is better — present tradeoffs neutrally
- Keep questions focused on decisions that affect WHERE research should look
- Limit to 3–7 questions — more means you don't understand the task yet

## Workflow

1. **Gather input**
   - If TASK_INPUT contains a file path, read it completely
   - If TASK_INPUT references a Jira ticket, use the `managing-jira` skill to read the ticket, comments, and related issues
   - If TASK_INPUT references a Linear issue, use the `managing-linear` skill to read the issue, comments, and related issues
   - If TASK_INPUT is a plain description, use it directly

2. **Formulate questions** — from the gathered input, identify:
   - **Goal**: One sentence — what does "done" look like?
   - **Design decisions**: Concrete questions with 2–3 options each, where the answer changes what you'd research
   - **Scope boundaries**: What is explicitly NOT part of this work?
   - **Unknowns**: What must research answer that can't be decided now?

3. **Present and wait** — deliver questions in the report format below, then STOP and wait for answers

4. **If the task is simple enough that no design decisions exist**, say so — skip the questions and tell the user to proceed to research

5. **After the user answers**, save the resolved decisions as an artifact:
   - Check for existing artifacts: `ls $CLAUDE_DOCS_ROOT/research/`
   - Read `$CLAUDE_DOCS_ROOT/projects.yaml` for project context
   - Write to `ARTIFACT_DIR/research--<slug>-questions.md` with full frontmatter per artifact-management guidelines
   - Body structure below in Artifact Format

## Report

> Based on [source], the goal is: **[one sentence]**.
>
> Before I research the codebase, I need your input on these decisions:
>
> **Q1**: [Decision that changes where research looks]
> - Option A: [approach] — [tradeoff]
> - Option B: [approach] — [tradeoff]
>
> **Q2**: [Decision that changes where research looks]
> - Option A: [approach] — [tradeoff]
> - Option B: [approach] — [tradeoff]
>
> **Scope boundaries** (confirm these are correct):
> - NOT doing: [out of scope item]
>
> **Unknowns for research**:
> - [thing we can't decide now — research must answer]
>
> Once you answer these, I'll target my research accordingly.

## Artifact Format

```markdown
## Goal

[One sentence]

## Resolved Decisions

### Q1: [Decision]
**Choice**: [Option chosen]
**Rationale**: [Why the user chose this]

### Q2: [Decision]
**Choice**: [Option chosen]
**Rationale**: [Why the user chose this]

## Scope Boundaries

- NOT doing: [item]

## Research Targets

Based on the decisions above, research should focus on:
- [Specific area/component to investigate]
- [Specific area/component to investigate]
```
