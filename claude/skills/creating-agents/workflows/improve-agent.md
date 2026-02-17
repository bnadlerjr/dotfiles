# Workflow: Improve an Agent

<required_reading>
**Read the reference file matching the improvement category:**
- Description quality → references/frontmatter-spec.md
- Tool permissions → references/tool-selection.md
- System prompt structure → references/system-prompt-patterns.md
- Role/archetype alignment → references/agent-archetypes.md
</required_reading>

<process>
## Step 1: Select Agent and Read Current Definition

If not already specified, list available agents:
```bash
ls ~/.claude/agents/
ls .claude/agents/ 2>/dev/null
```

Read the full `.md` file of the selected agent.

## Step 2: Identify Improvement Category

Determine what needs improving. Ask the user if not clear from context:

**Categories:**
1. **Description** — Improve trigger phrases, specificity, differentiation
2. **Tools** — Add missing tools, remove unnecessary ones, fix permissions
3. **Constraints** — Add boundaries, make existing ones more specific, reorder
4. **Output format** — Add or refine the output template
5. **Workflow** — Add or restructure the step-by-step procedure
6. **Role clarity** — Sharpen the role statement and closing reminder
7. **Token economy** — Reduce bloat, move detail to skills
8. **Full overhaul** — Major restructuring (run audit first)

If the user chose "Full overhaul", run the audit workflow first to identify all issues, then return here with the findings.

## Step 3: Read Relevant Reference

Load the reference file for the identified category:

| Category | Reference file |
|----------|---------------|
| Description | references/frontmatter-spec.md (description section) |
| Tools | references/tool-selection.md |
| Constraints | references/system-prompt-patterns.md (constraints section) |
| Output format | references/system-prompt-patterns.md (output format section) |
| Workflow | references/system-prompt-patterns.md (workflow section) |
| Role clarity | references/system-prompt-patterns.md (role + closer sections) |
| Token economy | references/system-prompt-patterns.md (token economy section) |
| Full overhaul | All reference files |

## Step 4: Apply Targeted Changes

### For Description improvements:
1. Read the current description
2. Check against the good/bad examples in frontmatter-spec.md
3. Ensure it answers: What does it do? When should it be used?
4. Add trigger phrases and action-oriented language
5. Present before/after to user

### For Tool improvements:
1. List current tools
2. Map each tool to a responsibility in the system prompt
3. Add tools needed by responsibilities that lack them
4. Remove tools not justified by any responsibility
5. Present changes with rationale

### For Constraint improvements:
1. Read current constraints (if any)
2. Check placement — should be near top of system prompt
3. Verify DO NOT / ONLY language
4. Add missing boundary constraints
5. Remove redundant or conflicting constraints
6. Present changes

### For Output format improvements:
1. Check if output format template exists
2. If missing, create one based on the agent's responsibilities
3. If present, verify it covers all output the agent produces
4. Use fenced code block with `[placeholders]`
5. Present changes

### For Workflow improvements:
1. Read current workflow (if any)
2. Verify it follows `### Step N: [Verb Phrase]` pattern
3. Add missing steps
4. Reorder for logical flow
5. Present changes

### For Role clarity improvements:
1. Check role statement (first 1-3 sentences)
2. Verify "You are a [type]. Your job is to [responsibility]." pattern
3. Check closing reminder exists and restates the boundary
4. Sharpen or add as needed
5. Present changes

### For Token economy improvements:
1. Count total lines in the definition
2. Identify sections that contain reference material
3. Identify detailed procedures that could be skills
4. Propose which content to extract into skills
5. Create skill stubs if user agrees
6. Trim agent definition accordingly

## Step 5: Re-validate

After applying changes, run the audit checklist from SKILL.md:

### Quick validation:
- [ ] Frontmatter still valid (name, description, tools)
- [ ] System prompt structure intact
- [ ] Under ~200 lines
- [ ] Single responsibility maintained
- [ ] Constraints still prominent
- [ ] No broken references

### Present summary:
```
## Changes Applied to {agent-name}

### Modified
- [Section]: [What changed and why]

### Before/After
[Key differences]

### Validation
- All checklist items passing: Yes/No
- Line count: X → Y
- Issues introduced: None / [list]
```
</process>

<success_criteria>
Improvement is complete when:
- [ ] Current agent definition read and understood
- [ ] Improvement category identified
- [ ] Relevant reference file consulted
- [ ] Changes applied to the agent file
- [ ] Audit checklist re-run on modified agent
- [ ] Summary presented to user
</success_criteria>
