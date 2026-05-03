---
description: Create or improve a Claude Code slash command through guided requirements gathering and delegated authoring
argument-hint: "[command description | existing command name | 'audit <command-name>[: <focus>]']"
model: opus
allowed-tools: Read, Bash, Task, AskUserQuestion, Glob
---

# Create Command

**Level 4 (Delegation)** — Gathers requirements in the orchestrator (where AskUserQuestion works), then delegates to a sub-agent that invokes the `writing-prompts` skill.

## Variables

- **INPUT**: `$ARGUMENTS` — A description of a new command, an existing command name, or `audit <command-name>[: <focus>]`
- **AUDIT_FOCUS**: For audit intent only — optional free-text hypothesis or emphasis after the command name (e.g., `audit foo: I think it should leverage skill X`). Empty if not provided.

## Dependencies

- **writing-prompts skill**: Core prompt-authoring methodology — the 7 levels and composable sections (invoked by sub-agent)
- **thinking-patterns skill**: atomic-thought, tree-of-thoughts, self-consistency
- **general-purpose agent** (model: opus): Sub-agent that invokes the skill and writes files

## Initial Response

When invoked:

1. **If input was provided**: Detect intent and begin Phase 1
2. **If no input provided**, respond with:

```
I'll help you create or improve a Claude Code slash command.

You can provide:
- A description of what the command should do (creates new)
- An existing command name (offers improve or audit)
- `audit <command-name>` (runs quality audit)

Usage: /create-command "Summarize my git changes for the day"
```

---

## Phase 1: Intent Detection

Determine what the user wants by examining `INPUT`.

### Detection Logic

1. **Check for audit prefix**: If INPUT starts with "audit " (case-insensitive):
   - Set intent to **audit**
   - Split the remainder on the first `:`, `.`, or newline. The first segment is the command name (trimmed of quotes/punctuation); anything after is captured as `AUDIT_FOCUS`.
   - Example: `audit create-command: I think X` → name=`create-command`, focus=`I think X`

2. **Check for existing command**: Run `ls ~/.claude/commands/` and `ls .claude/commands/ 2>/dev/null` and check if INPUT matches a filename exactly (with or without `.md` extension). If it matches, set intent to **improve**. Substring/typo matches do NOT count — fall through to create.

3. **Otherwise**: Set intent to **create**.

### Confirm Intent (improve only)

If intent is **improve**, read the existing command's `.md` file and present a summary, then confirm:

**AskUserQuestion**:
- Header: "Intent"
- Question: "I found the `${COMMAND_NAME}` command. What would you like to do?"
- Options:
  - "Improve it" — Enhance or extend this existing command
  - "Audit it" — Run a quality audit against best practices
  - "Create something new" — The name match was coincidental

---

## Phase 2: Requirements Gathering (create/improve only)

Skip this phase for **audit** intent — go directly to Phase 3.

### Decompose and Recommend

Reason in the style of the `atomic-thought` pattern from the `thinking-patterns` skill to decompose the input into independent dimensions, **then commit to a recommendation on each one before asking about it**:

```
Dimensions to clarify for this command:

1. **Core purpose**: What single task does this command automate?
2. **Level (1-7)**: Which writing-prompts level fits? (Most land at 2-4.)
   - 1: Static ad-hoc       — simple repeat task
   - 2: Workflow            — sequential steps
   - 3: Control flow        — conditionals/loops
   - 4: Delegation          — spawns sub-agents
   - 5: Higher-order        — accepts a prompt/plan as input
   - 6: Template meta       — generates other prompts
   - 7: Self-improving      — domain expertise that grows
3. **Inputs**: What does $ARGUMENTS carry, if anything? Static inputs (file refs)?
4. **Tools**: Which tools must be allowed? Which restricted?
5. **Output**: Should the result be a structured Report, a file artifact, or chat output?
6. **Sections**: Which composable sections earn a place — Variables, Instructions, Examples, Report?

For each dimension:
- Form a committed answer based on the input (not "it depends" or "either could work")
- Capture a one-sentence rationale tied to the input
- Mark the dimension RESOLVED if the input forces the answer; otherwise GAP
```

If you cannot form a recommendation on more than half the dimensions, the input is too vague — surface that to the user before continuing rather than asking many naked questions:

> "Your description leaves these dimensions open: <list>. Can you say more about <one most-load-bearing dimension>, or would you like a Socratic walkthrough?"

### Ask About Gaps with Committed Recommendations

For each GAP, ask via AskUserQuestion using the grilling-ideas turn discipline:

- The recommended answer goes **first** in the options list, labeled `(Recommended)`
- Each option's `description` carries the **rationale** — one sentence on the trade-off being made
- Never ask a naked question — if you cannot mark one option recommended, the dimension isn't ready to ask about

Example (good):

```
Question: "What level should this command target?"
Options:
  - "Level 2 — Workflow (Recommended)" — Your description names a sequence of steps with no branching; Level 2 is the lowest level that fits.
  - "Level 3 — Control flow" — Use if you actually need conditional branches based on detected state.
  - "Level 4 — Delegation" — Use only if you need parallel sub-agents or background work.
```

Example (bad — naked question, do not write these):

```
"Should this command be read-only or able to modify files?"
"Does the output need a fixed structure, or is free-form fine?"
```

Cap at 4 questions. Skip any GAP whose answer is low-stakes — don't burn a question on polish.

### Decision Gate

After gathering requirements:

**AskUserQuestion**:
- Header: "Ready?"
- Question: "I have enough context to build the command. Shall I proceed, or is there more to clarify?"
- Options:
  - "Proceed to building" — Start building the command
  - "Let me add details" — I want to provide additional context

---

## Phase 3: Delegation

### Build Sub-Agent Prompt

Construct a comprehensive prompt for the sub-agent that embeds all gathered context so it can proceed without user interaction.

#### For create intent:

Use the Task tool to spawn a `general-purpose` agent (model: `opus`):

```markdown
# Build a New Claude Code Slash Command

You are building a new Claude Code slash command. All requirements have been gathered — proceed directly to building without asking the user any questions.

## Requirements

${REQUIREMENTS_SUMMARY}

- **Command name**: ${COMMAND_NAME}
- **Purpose**: ${PURPOSE}
- **Level**: ${LEVEL} (1-7, see writing-prompts)
- **Inputs**: ${INPUTS}
- **Tools**: ${TOOLS}
- **Output**: ${OUTPUT_FORMAT}
- **Sections**: ${SECTIONS}

## Instructions

1. Invoke the `writing-prompts` skill using the Skill tool.

2. The skill defines 7 levels and composable sections. Use the level and sections specified above.

3. **IMPORTANT**: Since you are a sub-agent, AskUserQuestion will NOT reach the user. Do NOT use AskUserQuestion. Use the requirements above to make all decisions and proceed directly to writing files.

4. Apply the writing-prompts methodology:
   - Start at the lowest level that solves the problem
   - Each section must earn its place — no "just in case" bloat
   - Workflow steps must be specific actions, not vague verbs
   - If a teammate could not understand the prompt in 30 seconds, tighten it

5. Write the command file to `~/.claude/commands/${COMMAND_NAME}.md` with valid frontmatter:
   - `description`: one-line description
   - `argument-hint`: if the command takes arguments
   - `allowed-tools`: if restricting tools
   - `model`: only if a non-default model is required

6. After writing, reason in the style of the `self-consistency` pattern (from the `thinking-patterns` skill — invoke via `Skill(thinking-patterns)` if you need the full reference) to validate from three perspectives:
   1. **User perspective**: Is the invocation obvious from the description?
   2. **Author perspective**: Does each section earn its place? Right level chosen?
   3. **Execution perspective**: Are workflow steps specific enough to execute reliably?

## Report

When complete, provide:

### Files Created
- [Path to command file]

### Command Summary
- Name, level, sections used, tools allowed
- Why this level was chosen

### Validation Results
- Results from self-consistency check

### Test Suggestions
- 2-3 example invocations to try
```

#### For improve intent:

Read the existing command's full content first. Then use the Task tool to spawn a `general-purpose` agent (model: `opus`):

```markdown
# Improve an Existing Claude Code Slash Command

You are improving the `${COMMAND_NAME}` command. All requirements have been gathered — proceed directly to making changes without asking the user any questions.

## Current Command Content

${EXISTING_COMMAND_CONTENT}

## Requested Changes

${REQUIREMENTS_SUMMARY}

## Instructions

1. Invoke the `writing-prompts` skill using the Skill tool.

2. **IMPORTANT**: Since you are a sub-agent, AskUserQuestion will NOT reach the user. Do NOT use AskUserQuestion. Use the requirements above to make all decisions.

3. Apply the requested changes while preserving existing functionality. Reconsider whether the level is still right — improvements sometimes warrant moving up or down a level.

4. Strip sections that no longer earn their place. Do not add sections "just in case".

5. After changes, reason in the style of the `self-consistency` pattern (from the `thinking-patterns` skill) to validate from user, author, and execution perspectives.

## Report

When complete, provide:

### Files Modified
- [Path and description of changes]

### Before/After
- Level / sections / tools — what changed and why

### Validation Results
- Results from self-consistency check
```

#### For audit intent:

Use the Task tool to spawn a `general-purpose` agent (model: `opus`):

```markdown
# Audit a Claude Code Slash Command

You are auditing the `${COMMAND_NAME}` command for quality and best-practice compliance against the `writing-prompts` skill.

## User's Audit Focus (optional)

${AUDIT_FOCUS}

If non-empty, treat this as a hypothesis or area of emphasis the user wants pressure-tested. Lead the report with an explicit evaluation of it (accept / partially accept / reject) with rationale, then run the standard checklist. If empty, run the standard checklist only.

## Instructions

1. Invoke the `writing-prompts` skill using the Skill tool to load the methodology.

2. Read the target command file: `${COMMAND_PATH}`

3. **IMPORTANT**: Since you are a sub-agent, AskUserQuestion will NOT reach the user. Do NOT use AskUserQuestion. Run the audit yourself.

4. Audit checklist:
   - **Level fit**: Is the chosen level the lowest that solves the problem? Over-engineered (Level 5+ for a Level 2 task)?
   - **Section economy**: Does every section earn its place? Any "just in case" bloat?
   - **Workflow specificity**: Are steps concrete actions or vague verbs ("analyze the code")?
   - **Variables**: Are inputs clearly named and referenced?
   - **Frontmatter**: Is description tight? argument-hint accurate? allowed-tools right-sized (least privilege)?
   - **30-second test**: Could a teammate understand this in 30 seconds?
   - **Common mistakes** (per writing-prompts):
     - Over-engineering
     - Section bloat
     - Wrong prompt type (workflow in a system prompt)
     - Missing context for sub-agents (stateless assumptions broken)
     - Vague workflows

5. Score and recommend fixes.

## Report

### Audit Report: ${COMMAND_NAME}

#### On the user's focus (if AUDIT_FOCUS was provided)
- Verdict (accept / partially accept / reject) with rationale tied to the command's actual content

#### Passing
- [List passing checklist items]

#### Issues Found
- [Each issue with severity, description, and suggested fix]

#### Score
- [X/Y criteria passing]

#### Recommended Fixes
- [Prioritized list]
```

---

## Phase 4: Results

When the sub-agent completes, present the results to the user.

### For create/improve:

Display the sub-agent's report, then:

**AskUserQuestion**:
- Header: "Next steps"
- Question: "The command has been created. What would you like to do next?"
- Options:
  - "Run an audit" — Audit the new command against best practices
  - "Test it now" — Try invoking the command to verify it works
  - "Done" — Everything looks good

If "Run an audit": Re-enter Phase 3 with audit intent for the newly created command.

### For audit:

Display the audit report, then:

**AskUserQuestion**:
- Header: "Fixes"
- Question: "Would you like me to apply the recommended fixes?"
- Options:
  - "Fix all issues" — Apply all recommended fixes
  - "Fix critical only" — Apply only critical/major fixes
  - "No fixes needed" — Just wanted the report

If fixes requested: Re-enter Phase 3 with improve intent, embedding the audit findings as the requirements.

---

## Error Handling

### No Input Provided

```
No input provided. Please specify what you'd like to do:

Usage:
  /create-command "Summarize my git changes for the day"  — create a new command
  /create-command bugfix                                  — improve an existing command
  /create-command audit review                            — audit an existing command
  /create-command audit review: focus on output format    — audit with a specific hypothesis
```

### Command Not Found (improve/audit)

```
Command "${COMMAND_NAME}" not found.

Available commands:
${COMMAND_LIST}

Did you mean one of these, or would you like to create a new command named "${COMMAND_NAME}"?
```

### Sub-Agent Failure

```
The command-building sub-agent encountered an issue:
${ERROR_DETAILS}

Options:
1. Retry with the same parameters
2. Adjust requirements and try again
3. Build manually using the writing-prompts skill directly
```
