---
description: Create detailed implementation plans through interactive research and iteration
model: opus
---

# Implementation Plan

Read and follow the methodology in the implementation-planning skill:
`~/dotfiles/claude/skills/implementation-planning/SKILL.md`

This command extends that skill with execution-specific instructions for writing plan files.

## Initial Response

When this command is invoked:

1. **Check if parameters were provided**:
   - If a file path or ticket reference was provided, skip the default message
   - Immediately read any provided files FULLY
   - Begin the research process (per the skill)

2. **If no parameters provided**, respond with:
```
I'll help you create a detailed implementation plan. Let me start by understanding what we're building.

Please provide:
1. The task/ticket description (or reference to a ticket file)
2. Any relevant context, constraints, or specific requirements
3. Links to related research or previous implementations

I'll analyze this information and work with you to create a comprehensive plan.

Tip: For deeper analysis, try: `/plan think deeply about thoughts/allison/tickets/eng_1234.md`
```

Then wait for the user's input.

## Process

Follow Steps 1-3 from the implementation-planning skill, then continue here for Step 4.

