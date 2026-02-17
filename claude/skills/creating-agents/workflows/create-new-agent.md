# Workflow: Create a New Agent

<required_reading>
**Read these reference files NOW:**
1. references/frontmatter-spec.md
2. references/system-prompt-patterns.md
3. references/tool-selection.md
4. references/agent-archetypes.md
</required_reading>

<process>
## Step 1: Adaptive Requirements Gathering

**If user provided context** (e.g., "build an agent for X"):
- Analyze what's stated, what can be inferred, what's unclear
- Skip to asking about genuine gaps only

**If user just invoked skill without context:**
- Ask what they want to build

### Using AskUserQuestion

Ask 2-4 domain-specific questions based on actual gaps. Each question should:
- Have specific options with descriptions
- Focus on purpose, tools, constraints, output format
- NOT ask things obvious from context

Example questions:
- "What is this agent's primary job?" (with archetype-aligned options)
- "Should this agent modify files, or is it read-only?"
- "Does it need web access or just local files?"
- "What should the agent produce as output?"

### Decision Gate

After initial questions, ask:
"Ready to proceed with building, or would you like me to ask more questions?"

Options:
1. **Proceed to building** - I have enough context
2. **Ask more questions** - There are more details to clarify
3. **Let me add details** - I want to provide additional context

## Step 2: Choose Archetype

Read `references/agent-archetypes.md` and select the closest match.

The 6 archetypes are:
- **Analyst** — Deep analysis, structured reports, read-only
- **Scout** — Find and locate, breadth over depth, read-only
- **Builder** — Modify code, create files, run commands
- **Researcher** — Web search, synthesize findings, cite sources
- **Simplifier** — Refine existing code, edit-only, subtractive
- **Validator** — Check against rules, scored report

Present the recommended archetype and let the user confirm or adjust.

## Step 3: Write Frontmatter

Read `references/frontmatter-spec.md` and configure all fields.

**Required decisions:**
1. **name** — lowercase-with-hyphens, unique, descriptive
2. **description** — Action-oriented, includes trigger conditions
3. **tools** — Based on archetype from Step 2, refined per `references/tool-selection.md`
4. **model** — Usually `sonnet` unless complex reasoning needed

**Optional decisions:**
5. **color** — UI display color
6. **skills** — Skills the agent can invoke
7. **maxTurns** — Turn limit for safety
8. **permissionMode** — Usually `default`

## Step 4: Write System Prompt

Read `references/system-prompt-patterns.md` and follow the standard structure:

1. **Role Statement** — "You are a [specialist type]. Your job is to [primary responsibility]."
2. **CRITICAL Constraints** — DO NOT rules, placed prominently at the top
3. **Core Responsibilities** — 2-4 numbered items with sub-bullets
4. **Workflow / Strategy** — Step-by-step procedure
5. **Output Format** — Template in a fenced code block
6. **Guidelines** — Do / Don't paired lists
7. **Closing Reminder** — Restate role boundary with metaphor

### Token Economy Check

Before writing, verify:
- Definition will be under ~200 lines
- No inline reference material (delegate to skills)
- No detailed how-to procedures (delegate to skills)
- Agent body defines *what it is*, not *everything it knows*

## Step 5: Choose Storage Location

Present the two options:

**Personal agent** (`~/.claude/agents/AGENT_NAME.md`):
- Available across all projects
- Good for general-purpose agents

**Project agent** (`.claude/agents/AGENT_NAME.md` in repo root):
- Scoped to one project
- Shared with team via version control
- Good for project-specific agents

## Step 6: Write the File

Use the appropriate template from `templates/` as a starting point:
- `templates/read-only-agent.md` — for Analyst, Scout, Validator archetypes
- `templates/code-modifier-agent.md` — for Builder, Simplifier archetypes
- `templates/researcher-agent.md` — for Researcher archetype

Replace all PLACEHOLDER values with real content. Remove any template sections that don't apply.

## Step 7: Validate

Run the audit checklist from SKILL.md against the new agent:

### Frontmatter
- [ ] Has `name` field (lowercase-with-hyphens, unique)
- [ ] Has `description` field (says what it does AND when to use it)
- [ ] `tools` scoped appropriately (not over-permissioned)
- [ ] `model` specified
- [ ] `color` specified

### System Prompt
- [ ] Role statement present (first 1-3 sentences)
- [ ] CRITICAL constraints section near the top
- [ ] Core responsibilities defined (2-4 items)
- [ ] Workflow / strategy section present
- [ ] Output format template defined
- [ ] Guidelines (do/don't) present
- [ ] Closing reminder anchors the role

### Token Economy
- [ ] Definition under ~200 lines
- [ ] No inline reference material
- [ ] Deep knowledge delegated to skills (if applicable)

### Design Quality
- [ ] Single responsibility — one clear mission
- [ ] Self-contained — prompt works without external context
- [ ] Constraints are specific and prominent
- [ ] Every tool in `tools` has a justified use

## Step 8: Test

Spawn the new agent via the Task tool and verify:
1. Does it understand its role?
2. Does it follow its constraints?
3. Does it produce output in the expected format?
4. Does it stay within its tool permissions?

If issues are found, iterate on the definition.
</process>

<success_criteria>
Agent is complete when:
- [ ] Requirements gathered with appropriate questions
- [ ] Archetype selected and confirmed
- [ ] Frontmatter configured with all required fields
- [ ] System prompt follows standard structure
- [ ] File written to correct storage location
- [ ] Audit checklist passes
- [ ] Agent tested via Task tool
</success_criteria>
