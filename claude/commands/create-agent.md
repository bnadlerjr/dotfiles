---
description: Create or improve a Claude Code agent through guided requirements gathering and delegated authoring
argument-hint: "[agent description, existing agent name, or 'audit <agent-name>']"
model: opus
allowed-tools: Read, Bash, Task, AskUserQuestion, Glob
---

# Create Agent

**Level 4 (Delegation)** — Gathers requirements in the orchestrator (where AskUserQuestion works), then delegates to a sub-agent that invokes the `creating-agents` skill.

## Variables

- **INPUT**: `$ARGUMENTS` — A description of a new agent, an existing agent name, or `audit <agent-name>`

## Initial Response

When invoked:

1. **If input was provided**: Detect intent and begin Phase 1
2. **If no input provided**, respond with:

```
I'll help you create or improve a Claude Code agent.

You can provide:
- A description of what the agent should do (creates new)
- An existing agent name (offers improve or audit)
- `audit <agent-name>` (runs quality audit)

Usage: /create-agent "Analyze test coverage and suggest missing test cases"
```

---

## Phase 1: Intent Detection

Determine what the user wants by examining `INPUT`.

### Detection Logic

1. **Check for audit prefix**: If INPUT starts with "audit " (case-insensitive), extract the agent name after "audit " and set intent to **audit**.

2. **Check for existing agent**: Run `ls ~/.claude/agents/` and `ls .claude/agents/ 2>/dev/null` and check if INPUT matches a filename (exact or fuzzy match, with or without `.md`). If it matches, set intent to **improve**.

3. **Otherwise**: Set intent to **create**.

### Confirm Intent (improve only)

If intent is **improve**, read the existing agent's `.md` file and present a summary, then confirm:

**AskUserQuestion**:
- Header: "Intent"
- Question: "I found the `${AGENT_NAME}` agent. What would you like to do?"
- Options:
  - "Improve it" — Enhance or extend this existing agent
  - "Audit it" — Run a quality audit against best practices
  - "Create something new" — The name match was coincidental

---

## Phase 2: Requirements Gathering (create/improve only)

Skip this phase for **audit** intent — go directly to Phase 4.

### Decompose Input

Invoke `/thinking atomic-thought` to decompose the user's input into independent questions:

```
Independent dimensions to clarify for this agent:

1. **Primary job**: What is this agent's one clear mission?
2. **Archetype**: Analyst, Scout, Builder, Researcher, Simplifier, or Validator?
3. **Tools needed**: Read-only? Code modifier? Web access?
4. **Constraints**: What should the agent NOT do?
5. **Output format**: What does the agent produce?
6. **Storage**: Personal (~/.claude/agents/) or project (.claude/agents/)?

Answer each from the user's input. Mark gaps that need clarification.
```

### Ask About Gaps

Based on gaps identified above, ask 2-4 targeted questions using AskUserQuestion. Only ask about genuine gaps — skip anything obvious from the input.

Example questions:
- "Should this agent be read-only or able to modify files?"
- "What should the agent's output look like?"
- "Where should this agent live — personal or project-scoped?"

### Decision Gate

After gathering requirements:

**AskUserQuestion**:
- Header: "Ready?"
- Question: "I have enough context to build the agent. Shall I proceed, or is there more to clarify?"
- Options:
  - "Proceed to building" — Start building the agent
  - "Let me add details" — I want to provide additional context

---

## Phase 3: Delegation

### Build Sub-Agent Prompt

Construct a comprehensive prompt for the sub-agent that embeds all gathered context so it can proceed without user interaction.

#### For create intent:

Use the Task tool to spawn a `general-purpose` agent (model: `opus`):

```markdown
# Build a New Claude Code Agent

You are building a new Claude Code agent definition file. All requirements have been gathered — proceed directly to building without asking the user any questions.

## Requirements

${REQUIREMENTS_SUMMARY}

- **Agent name**: ${AGENT_NAME}
- **Primary job**: ${PRIMARY_JOB}
- **Archetype**: ${ARCHETYPE}
- **Tools**: ${TOOLS}
- **Constraints**: ${CONSTRAINTS}
- **Output format**: ${OUTPUT_FORMAT}
- **Storage**: ${STORAGE_LOCATION}

## Instructions

1. Invoke the `creating-agents` skill using the Skill tool.

2. The skill will present a routing question. Based on the requirements above, select the **Create a new agent** workflow.

3. **IMPORTANT**: Since you are a sub-agent, AskUserQuestion will NOT reach the user. Do NOT use AskUserQuestion. Use the requirements above to make all decisions and proceed directly to writing files.

4. Follow the skill's create workflow to:
   - Choose the archetype
   - Configure frontmatter
   - Write the system prompt
   - Write the agent file to ${STORAGE_LOCATION}

5. After writing, run the audit checklist from the skill.

## Report

When complete, provide:

### Files Created
- [Path to agent file]

### Agent Summary
- Name, description, tools, model
- Archetype chosen and why

### Audit Results
- Checklist pass/fail summary

### Test Suggestions
- 2-3 example Task tool prompts to test the agent
```

#### For improve intent:

Read the existing agent's full content first. Then use the Task tool to spawn a `general-purpose` agent (model: `opus`):

```markdown
# Improve an Existing Claude Code Agent

You are improving the `${AGENT_NAME}` agent. All requirements have been gathered — proceed directly to making changes without asking the user any questions.

## Current Agent Content

${EXISTING_AGENT_CONTENT}

## Requested Changes

${REQUIREMENTS_SUMMARY}

## Instructions

1. Invoke the `creating-agents` skill using the Skill tool.

2. Select the **Improve an existing agent** workflow.

3. **IMPORTANT**: Since you are a sub-agent, AskUserQuestion will NOT reach the user. Do NOT use AskUserQuestion. Use the requirements above to make all decisions.

4. Apply the requested changes while preserving existing functionality.

5. After changes, run the audit checklist.

## Report

When complete, provide:

### Files Modified
- [Path and description of changes]

### Before/After
- [Key differences]

### Audit Results
- Checklist pass/fail summary
```

#### For audit intent:

Use the Task tool to spawn a `general-purpose` agent (model: `opus`):

```markdown
# Audit a Claude Code Agent

You are auditing the `${AGENT_NAME}` agent for quality and best-practice compliance.

## Instructions

1. Invoke the `creating-agents` skill using the Skill tool.

2. Select the **Audit an existing agent** workflow.

3. **IMPORTANT**: Since you are a sub-agent, AskUserQuestion will NOT reach the user. Do NOT use AskUserQuestion. Read the agent file directly and perform the audit checklist yourself.

4. Target agent: `${AGENT_PATH}`

5. Run the full audit checklist and generate the report.

## Report

### Audit Report: ${AGENT_NAME}

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
- Question: "The agent has been created. What would you like to do next?"
- Options:
  - "Run an audit" — Audit the new agent against best practices
  - "Test it now" — Spawn the agent via Task tool to verify it works
  - "Done" — Everything looks good

If "Run an audit": Re-enter Phase 3 with audit intent for the newly created agent.

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
  /create-agent "Analyze test coverage gaps"     — create a new agent
  /create-agent codebase-analyzer                — improve an existing agent
  /create-agent audit web-search-researcher      — audit an existing agent
```

### Agent Not Found (improve/audit)

```
Agent "${AGENT_NAME}" not found.

Available agents:
${AGENT_LIST}

Did you mean one of these, or would you like to create a new agent named "${AGENT_NAME}"?
```

### Sub-Agent Failure

```
The agent-building sub-agent encountered an issue:
${ERROR_DETAILS}

Options:
1. Retry with the same parameters
2. Adjust requirements and try again
3. Build manually using the creating-agents skill directly
```
