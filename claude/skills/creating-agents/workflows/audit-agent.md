# Workflow: Audit an Agent

<required_reading>
**Read these reference files NOW:**
1. references/frontmatter-spec.md
2. references/system-prompt-patterns.md
3. references/tool-selection.md
</required_reading>

<process>
## Step 1: List Available Agents

**DO NOT use AskUserQuestion** — there may be many agents.

Enumerate agents from both locations:
```bash
ls ~/.claude/agents/
ls .claude/agents/ 2>/dev/null
```

Present as:
```
Available agents:
1. codebase-analyzer (personal)
2. web-search-researcher (personal)
3. my-project-agent (project)
...
```

Ask: "Which agent would you like to audit? (enter number or name)"

## Step 2: Read the Agent

After user selects, read the full `.md` file:
```bash
cat ~/.claude/agents/{agent-name}.md
# or
cat .claude/agents/{agent-name}.md
```

## Step 3: Run Audit Checklist

Evaluate against every criterion:

### Frontmatter
- [ ] Has `name` field
- [ ] Name is lowercase-with-hyphens
- [ ] Name is unique across personal + project agents
- [ ] Has `description` field
- [ ] Description says what agent does
- [ ] Description says when to use it (trigger conditions)
- [ ] Description is action-oriented ("Use this agent when...")
- [ ] `tools` field present and scoped appropriately
- [ ] `model` field specified

### System Prompt Structure
- [ ] Role statement present (first 1-3 sentences)
- [ ] Role statement uses "You are a..." pattern
- [ ] CRITICAL constraints section exists
- [ ] Constraints placed near the top (not buried)
- [ ] Constraints use DO NOT / ONLY language
- [ ] Core responsibilities defined (2-4 numbered items)
- [ ] Workflow / strategy section present
- [ ] Output format template defined
- [ ] Guidelines section present (do/don't)
- [ ] Closing reminder present (role anchor)

### Token Economy
- [ ] Definition under ~200 lines total
- [ ] No inline reference material that belongs in a skill
- [ ] No detailed how-to procedures that belong in a skill
- [ ] Agent body defines identity and behavior, not encyclopedic knowledge

### Tool Permission Hygiene
- [ ] Every tool in `tools` has a clear use case for this agent
- [ ] No tools granted that the agent doesn't need
- [ ] `Write`/`Edit` only if agent modifies files
- [ ] `Bash` only if agent runs shell commands
- [ ] Web tools only if agent needs internet access
- [ ] `tools` (allowlist) preferred for focused agents
- [ ] `disallowedTools` used appropriately (if present)

### Description Quality
- [ ] Description is specific enough to differentiate from similar agents
- [ ] Contains trigger phrases a dispatcher would recognize
- [ ] Includes examples if the agent's use cases are nuanced
- [ ] Not too short (< 20 chars) or too long (> 500 chars)

### Constraint Coverage
- [ ] Role boundary is clear (what agent does NOT do)
- [ ] Constraints are specific (not vague platitudes)
- [ ] Number of constraints is reasonable (4-7, not 20+)
- [ ] Constraints don't contradict each other
- [ ] The most important constraint is listed first

### Design Quality
- [ ] Single responsibility — agent has one clear mission
- [ ] Self-contained — prompt works without external context
- [ ] No placeholder text or TODO items
- [ ] Consistent formatting throughout

## Step 4: Evaluate Description Quality

The description is the highest-leverage field. Evaluate:

1. **Trigger recognition**: Would a dispatcher know when to use this agent?
2. **Differentiation**: Is it distinguishable from similar agents?
3. **Completeness**: Does it cover both WHAT and WHEN?
4. **Action orientation**: Does it use "Use this agent when..." patterns?

## Step 5: Check Tool Permissions

Compare the agent's tools against its responsibilities:

1. List every tool the agent has
2. For each tool, verify a responsibility requires it
3. Flag any tool without a matching responsibility (over-permissioned)
4. Flag any responsibility that needs a tool not listed (under-permissioned)

## Step 6: Check Constraint Coverage

For each core responsibility, verify:

1. Is there a matching constraint that defines the boundary?
2. Are the constraints prominent (near the top)?
3. Do any constraints overlap or conflict?

## Step 7: Generate Report

Present findings as:

```
## Audit Report: {agent-name}

### Passing
- [list passing items with brief context]

### Issues Found
1. **[Issue name]** (severity: critical/major/minor)
   Description of the issue
   Fix: [Specific action to take]

2. **[Issue name]** (severity: critical/major/minor)
   Description of the issue
   Fix: [Specific action to take]

### Score: X/Y criteria passing

### Summary
[1-2 sentence overall assessment]
```

Severity levels:
- **Critical**: Agent won't function correctly (missing required fields, broken constraints)
- **Major**: Agent works but has significant quality issues (missing output format, vague description)
- **Minor**: Polish items (missing color, could be more concise)

## Step 8: Offer Fixes

If issues found, ask:
"Would you like me to fix these issues?"

Options:
1. **Fix all** - Apply all recommended fixes
2. **Fix one by one** - Review each fix before applying
3. **Just the report** - No changes needed

If fixing:
- Make each change
- Verify file validity after each change
- Report what was fixed
</process>

<success_criteria>
Audit is complete when:
- [ ] Agent fully read and analyzed
- [ ] All checklist items evaluated
- [ ] Report presented with passing items, issues, and score
- [ ] Fixes applied (if requested)
- [ ] User has clear picture of agent quality
</success_criteria>
