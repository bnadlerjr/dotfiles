---
description: Create or improve a Claude Code skill through guided requirements gathering and delegated authoring
argument-hint: "[skill description, existing skill name, or 'audit <skill-name>']"
model: opus
allowed-tools: Read, Bash, Task, AskUserQuestion, Glob
---

# Create Skill

**Level 4 (Delegation)** - Gathers requirements in the orchestrator (where AskUserQuestion works), then delegates to a sub-agent that invokes the `creating-agent-skills` skill.

## Variables

- **INPUT**: `$ARGUMENTS` - A description of a new skill, an existing skill name, or `audit <skill-name>`

## Dependencies

- **creating-agent-skills skill**: Core skill-authoring methodology (invoked by sub-agent)
- **thinking-patterns skill**: atomic-thought, tree-of-thoughts, self-consistency
- **general-purpose agent** (model: opus): Sub-agent that invokes the skill and writes files

## Initial Response

When invoked:

1. **If input was provided**: Detect intent and begin Phase 1
2. **If no input provided**, respond with:

```
I'll help you create or improve a Claude Code skill.

You can provide:
- A description of what the skill should do (creates new)
- An existing skill name (offers improve or audit)
- `audit <skill-name>` (runs quality audit)

Usage: /create-skill "Format and lint Terraform files"
```

---

## Phase 1: Intent Detection

Determine what the user wants by examining `INPUT`.

### Detection Logic

1. **Check for audit prefix**: If INPUT starts with "audit " (case-insensitive), extract the skill name after "audit " and set intent to **audit**.

2. **Check for existing skill**: Run `ls ~/.claude/skills/` and check if INPUT matches a directory name (exact or fuzzy match). If it matches, set intent to **improve**.

3. **Otherwise**: Set intent to **create**.

### Confirm Intent (improve only)

If intent is **improve**, read the existing skill's SKILL.md and present a summary, then confirm:

**AskUserQuestion**:
- Header: "Intent"
- Question: "I found the `${SKILL_NAME}` skill. What would you like to do?"
- Options:
  - "Improve it" - Enhance or extend this existing skill
  - "Audit it" - Run a quality audit against best practices
  - "Create something new" - The name match was coincidental

---

## Phase 2: Requirements Gathering (create/improve only)

Skip this phase for **audit** intent — go directly to Phase 4.

### Decompose Input

Invoke `/thinking atomic-thought` to decompose the user's input into independent questions:

```
Independent dimensions to clarify for this skill:

1. **Core purpose**: What specific operations should this skill handle?
2. **Scope boundaries**: What is explicitly out of scope?
3. **Inputs**: What does the user provide when invoking the skill?
4. **Outputs**: What should the skill produce?
5. **Domain knowledge**: What expert knowledge does this skill encode?
6. **Tool requirements**: What tools (Bash, Read, Write, WebSearch, etc.) does this skill need?

Answer each from the user's input. Mark gaps that need clarification.
```

### Ask About Gaps

Based on gaps identified above, ask 2-4 targeted questions using AskUserQuestion. Only ask about genuine gaps — skip anything obvious from the input.

Example questions (adapt to the specific skill being created):

**AskUserQuestion** (up to 4 questions):
- Focus on scope, complexity, outputs, and boundaries
- Each question should have 2-4 specific options with descriptions
- Do NOT ask things that are obvious from the input

### Decision Gate

After gathering requirements:

**AskUserQuestion**:
- Header: "Ready?"
- Question: "I have enough context to build the skill. Shall I proceed, or is there more to clarify?"
- Options:
  - "Proceed to building" - Start building the skill
  - "Let me add details" - I want to provide additional context

---

## Phase 3: Structure Decision (create only)

Skip this phase for **improve** and **audit** intents.

### Evaluate Structure Options

Invoke `/thinking tree-of-thoughts` to evaluate skill structure:

```
Evaluate three structural approaches for this skill:

Branch A: Simple skill (single SKILL.md)
- Pros: Easy to maintain, fast to load, low complexity
- Cons: Limited to ~500 lines, no workflow separation
- Best when: Single purpose, straightforward guidance

Branch B: Router skill (SKILL.md + workflows/ + references/)
- Pros: Multiple entry points, shared knowledge, scalable
- Cons: More files to maintain, routing overhead
- Best when: Multiple user intents, shared domain knowledge

Branch C: Domain expertise skill (SKILL.md + references/ only)
- Pros: Deep knowledge base, progressive disclosure
- Cons: May not need workflows if guidance is consistent
- Best when: Single workflow but extensive reference material

Select the best branch based on the requirements gathered.
```

Present the recommendation to the user:

**AskUserQuestion**:
- Header: "Structure"
- Question: "Based on the requirements, I recommend a ${RECOMMENDED} skill. Does this sound right?"
- Options:
  - "${RECOMMENDED} (Recommended)" - Use the recommended structure
  - "${ALTERNATIVE_1}" - Brief description of alternative
  - "${ALTERNATIVE_2}" - Brief description of alternative

---

## Phase 4: Delegation

### Build Sub-Agent Prompt

Construct a comprehensive prompt for the sub-agent that embeds all gathered context so it can proceed without user interaction.

#### For create intent:

Use the Task tool to spawn a `general-purpose` agent (model: `opus`):

```markdown
# Build a New Claude Code Skill

You are building a new Claude Code skill. All requirements have been gathered — proceed directly to building without asking the user any questions.

## Requirements

${REQUIREMENTS_SUMMARY}

- **Skill name**: ${SKILL_NAME}
- **Purpose**: ${PURPOSE}
- **Scope**: ${SCOPE}
- **Inputs**: ${INPUTS}
- **Outputs**: ${OUTPUTS}
- **Domain knowledge**: ${DOMAIN_KNOWLEDGE}
- **Tool requirements**: ${TOOLS}
- **Structure**: ${STRUCTURE_CHOICE} (simple | router | domain-expertise)

## Instructions

1. Invoke the `creating-agent-skills` skill using the Skill tool:
   - Skill: `creating-agent-skills`

2. The skill will present an intake question. Based on the requirements above, select the **create-new-skill** workflow.

3. When the create-new-skill workflow asks questions via AskUserQuestion, you already have all the answers from the requirements above. Answer them directly in your reasoning and proceed to building.

4. **IMPORTANT**: Since you are a sub-agent, AskUserQuestion will NOT reach the user. Do NOT use AskUserQuestion. Instead, use the requirements above to make all decisions and proceed directly to writing files.

5. Follow the skill's workflow to:
   - Create the skill directory at `~/.claude/skills/${SKILL_NAME}/`
   - Write SKILL.md with valid frontmatter
   - Write workflow files (if router structure)
   - Write reference files (if needed)
   - Create the slash command at `~/.claude/commands/${SKILL_NAME}.md`

## Thinking Patterns

- Use `/thinking atomic-thought` to decompose implementation into independent components
- After building, use `/thinking self-consistency` to validate the skill from three perspectives:
  1. **User perspective**: Is it easy to invoke and understand?
  2. **Author perspective**: Is it well-structured and maintainable?
  3. **Consumer perspective**: Does it produce the right outputs?

## Report

When complete, provide a summary:

### Files Created
- [List all files created with paths]

### Skill Structure
- [Describe the structure chosen and why]

### Slash Command
- [Show the command that was created]

### Validation Results
- [Results from self-consistency check]

### Suggestions for Testing
- [2-3 example invocations to test the skill]
```

#### For improve intent:

Read the existing skill's full content first. Then use the Task tool to spawn a `general-purpose` agent (model: `opus`):

```markdown
# Improve an Existing Claude Code Skill

You are improving the `${SKILL_NAME}` skill. All requirements have been gathered — proceed directly to making changes without asking the user any questions.

## Current Skill Content

${EXISTING_SKILL_CONTENT}

## Requested Changes

${REQUIREMENTS_SUMMARY}

## Instructions

1. Invoke the `creating-agent-skills` skill using the Skill tool:
   - Skill: `creating-agent-skills`

2. The skill will present an intake question. Select the workflow that best matches the requested changes (create-new-skill for major rewrites, add-workflow/add-reference for additions).

3. **IMPORTANT**: Since you are a sub-agent, AskUserQuestion will NOT reach the user. Do NOT use AskUserQuestion. Use the requirements above to make all decisions.

4. Apply the requested changes while preserving existing functionality.

5. After changes, use `/thinking self-consistency` to validate:
   1. **User perspective**: Do existing invocations still work?
   2. **Author perspective**: Is the structure still clean?
   3. **Consumer perspective**: Are the new capabilities properly exposed?

## Report

When complete, provide a summary:

### Files Modified
- [List all files changed with descriptions of changes]

### Files Created
- [List any new files, if applicable]

### Validation Results
- [Results from self-consistency check]

### Before/After
- [Key differences in skill behavior]
```

#### For audit intent:

Use the Task tool to spawn a `general-purpose` agent (model: `opus`):

```markdown
# Audit a Claude Code Skill

You are auditing the `${SKILL_NAME}` skill for quality and best-practice compliance.

## Instructions

1. Invoke the `creating-agent-skills` skill using the Skill tool:
   - Skill: `creating-agent-skills`

2. The skill will present an intake question. Select the **audit-skill** workflow.

3. When the audit workflow asks which skill to audit, target: `${SKILL_NAME}`

4. **IMPORTANT**: Since you are a sub-agent, AskUserQuestion will NOT reach the user. Do NOT use AskUserQuestion. Read the skill files directly and perform the audit checklist yourself.

5. Run the full audit checklist from the workflow.

6. Generate the audit report with passing items, issues found, and score.

## Report

Provide the complete audit report including:

### Audit Report: ${SKILL_NAME}

#### Passing
- [List passing checklist items]

#### Issues Found
- [Each issue with severity, description, and suggested fix]

#### Score
- [X/Y criteria passing]

#### Recommended Fixes
- [Prioritized list of fixes to apply]
```

---

## Phase 5: Results

When the sub-agent completes, present the results to the user.

### For create/improve:

Display the sub-agent's report, then:

**AskUserQuestion**:
- Header: "Next steps"
- Question: "The skill has been created. What would you like to do next?"
- Options:
  - "Run an audit" - Audit the new skill against best practices
  - "Test it now" - Try invoking the skill to verify it works
  - "Done" - Everything looks good

If "Run an audit": Re-enter Phase 4 with audit intent for the newly created skill.

### For audit:

Display the audit report, then:

**AskUserQuestion**:
- Header: "Fixes"
- Question: "Would you like me to apply the recommended fixes?"
- Options:
  - "Fix all issues" - Apply all recommended fixes
  - "Fix critical only" - Apply only critical/major fixes
  - "No fixes needed" - Just wanted the report

If fixes requested: Re-enter Phase 4 with improve intent, embedding the audit findings as the requirements.

---

## Error Handling

### No Input Provided

```
No input provided. Please specify what you'd like to do:

Usage:
  /create-skill "Format and lint Terraform files"  — create a new skill
  /create-skill developing-elixir                  — improve an existing skill
  /create-skill audit reviewing-code               — audit an existing skill
```

### Skill Not Found (improve/audit)

```
Skill "${SKILL_NAME}" not found in ~/.claude/skills/.

Available skills:
${SKILL_LIST}

Did you mean one of these, or would you like to create a new skill named "${SKILL_NAME}"?
```

### Sub-Agent Failure

```
The skill-building agent encountered an issue. Here's what happened:
${ERROR_DETAILS}

Options:
1. Retry with the same parameters
2. Adjust requirements and try again
3. Build manually using the creating-agent-skills skill directly
```

---

## Example Sessions

### Create a new skill
```bash
/create-skill "Format and lint Terraform files"
```

1. Detects "create" intent (no matching skill directory)
2. Decomposes requirements, asks about scope (HCL only? Terragrunt?), output format, etc.
3. Recommends simple skill structure
4. Delegates to sub-agent which invokes creating-agent-skills
5. Presents created files and slash command
6. Offers audit or testing

### Improve an existing skill
```bash
/create-skill developing-elixir
```

1. Detects "improve" intent (matches existing skill)
2. Reads current skill, confirms user wants to improve
3. Gathers requirements for the improvement
4. Delegates to sub-agent with existing content + changes
5. Presents modified files

### Audit an existing skill
```bash
/create-skill audit reviewing-code
```

1. Detects "audit" intent (starts with "audit")
2. Skips requirements gathering
3. Delegates to sub-agent which runs audit-skill workflow
4. Presents audit report with score
5. Offers to fix issues
