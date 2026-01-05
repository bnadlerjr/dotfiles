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

## Step 4: Writing the Plan File

After structure approval:

1. **Run `git metadata`** to get current metadata

2. **Write the plan** to `$(claude-docs-path plans)/YYYY-MM-DD-ENG-XXXX-description.md`
   - Format: `YYYY-MM-DD-ENG-XXXX-description.md` where:
     - YYYY-MM-DD is today's date
     - ENG-XXXX is the ticket number (omit if no ticket)
     - description is a brief kebab-case description
   - Examples:
     - With ticket: `2025-01-08-ENG-1478-parent-child-tracking.md`
     - Without ticket: `2025-01-08-improve-error-handling.md`

3. **Use the template** from `~/dotfiles/claude/skills/implementation-planning/templates/plan-template.md`

4. **Include this frontmatter**:
   ```yaml
   ---
   tags: [plan, ai]
   Area: <Area name from git metadata>
   Created: [[<YYYY-MM-DD>]]
   Modified: <YYYY-MM-DD>
   Project: [[<prompt user or infer from research>]]
   AutoNoteMover: disable
   ---
   ```

## Step 5: Sync and Review

1. **Present the draft plan location**:
   ```
   I've created the initial implementation plan at:
   `$(claude-docs-path plans)/YYYY-MM-DD-ENG-XXXX-description.md`

   Please review it and let me know:
   - Are the phases properly scoped?
   - Are the success criteria specific enough?
   - Any technical details that need adjustment?
   - Missing edge cases or considerations?
   ```

2. **Iterate based on feedback** until the user is satisfied
