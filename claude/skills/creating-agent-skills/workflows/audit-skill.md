# Workflow: Audit a Skill

**Read these first** — they are the authority this audit enforces:

1. `references/agent-skills-spec.md` — the normative rules
2. `references/claude-code-extensions.md` — which fields carry to which clients
3. `references/authoring-guidance.md` — the quality bar beyond mere validity

## Step 1: Select the skill

```bash
ls ~/.claude/skills/
```

Present a numbered list, then ask which to audit. **Do not use AskUserQuestion** —
there may be more skills than it can display.

If the target was supplied by the caller, skip straight to Step 2.

## Step 2: Run the validator first

```bash
uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ~/.claude/skills/{skill-name}
```

This settles every mechanical question — frontmatter validity, limits, broken links,
reference depth, unreachable files — before you spend attention on judgment calls.
Everything it reports is a finding; record the codes.

Run it across the whole library when auditing more than one:

```bash
uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ~/.claude/skills/*/
```

## Step 3: Read the whole skill

```bash
cat ~/.claude/skills/{skill-name}/SKILL.md
ls -R ~/.claude/skills/{skill-name}/
```

Read the reference and workflow files too. The audit covers the whole skill, not just
`SKILL.md` — and the most damaging defects live in the disagreements *between* files.

## Step 4: Work the checklist

The validator has already covered the mechanical items. These need reading.

### Frontmatter

- [ ] `description` is third person, states what it does **and** when to use it
- [ ] Description front-loads trigger keywords and names contexts explicitly, including
      ones where the user wouldn't name the domain
- [ ] Any non-standard field is a deliberate choice, checked against the support matrix
      rather than assumed dead — and where it *is* single-client, `compatibility` says so

### Body

- [ ] Standard markdown headings
- [ ] Examples are concrete input/output pairs, not abstract description
- [ ] Instructions are actionable — no "handle it appropriately", no "do the thing"
- [ ] Specificity matches fragility: exact commands for irreversible steps, criteria
      rather than steps for judgment calls
- [ ] One default with an escape hatch, not a menu of equivalent options
- [ ] Consistent terminology throughout
- [ ] No time-sensitive content — no hardcoded years, no "before <date>, use…"
- [ ] Success criteria are verifiable, not "the user is satisfied"

### Internal consistency

The highest-value check, and the one only a human-style read catches:

- [ ] No two files state opposing rules — particularly a *create* procedure and an
      *audit* rubric that disagree about the same thing
- [ ] `SKILL.md` does not duplicate a procedure that also lives in a workflow file;
      when it does, the two have already diverged
- [ ] Every intake question has a routing table entry pointing at a real file
- [ ] Terminology and structure conventions hold across references

### Progressive disclosure

- [ ] `SKILL.md` navigates to detail rather than containing it
- [ ] The skill says **when** to load each file, not just that it exists
- [ ] Reference files over ~100 lines have a contents list
- [ ] No content duplicated across files (repeating a hard safety constraint is fine)

### Scripts, if present

- [ ] Handle errors explicitly rather than punting to the agent
- [ ] No unexplained constants
- [ ] Dependencies declared — inline metadata preferred over a separate manifest
- [ ] Never prompt interactively; `--help` documents the interface
- [ ] Structured output on stdout, diagnostics on stderr
- [ ] Credentials never appear in a command the agent runs — see
      `references/api-security.md`

### Grounding

- [ ] Content is specific to its domain, not generic advice a model already knows
- [ ] There is at least one gotcha, or a clear reason there isn't
- [ ] Claims about external tools and APIs are still true — if in doubt, run
      `workflows/verify-skill.md`

## Step 5: Report

```
## Audit Report: {skill-name}

### Validator
{clean, or the list of codes with counts}

### Passing
- {list}

### Issues
1. **{Issue}** (critical | major | minor): {description}
   → Fix: {specific action}

### Score: X/Y criteria passing
```

Severity: **critical** = invalid per the spec, or two files that contradict each other;
**major** = the skill will misfire or mislead; **minor** = quality and consistency.

## Step 6: Offer fixes

Ask: "Would you like me to fix these?"

1. **Fix all**
2. **Fix critical and major only**
3. **Just the report**

If fixing: make each change, re-run the validator, and report what changed.

## Anti-patterns to flag

- **Contradictory rules across files** — the most damaging defect, because the skill
  produces output that fails its own checks
- **Orphaned files** — workflows or references nothing reaches
- **Intake without routing** — a question whose answers lead nowhere
- **Duplicated procedures** — the same workflow in two places, already diverged
- **Monolithic SKILL.md** — over 500 lines or 5,000 tokens
- **Vague steps** — "handle the error appropriately"
- **Untestable criteria** — "user is satisfied"
- **Broken references** — files linked but absent
- **Deep chains** — more than two hops from `SKILL.md`
- **Windows paths** — backslashes instead of forward slashes
- **Time-sensitive info** — hardcoded dates and years
- **Unmarked single-client fields** — a field no other client honours, used without a
  `compatibility` declaration saying so
- **Phantom infrastructure** — instructions to run scripts or read files that do not
  exist
- **Single-skill command wrapper** — a `/foo` shim that only forwards to one skill

## Success criteria

- [ ] Validator run and its output recorded
- [ ] The whole skill read — `SKILL.md`, references, workflows
- [ ] Every checklist item evaluated
- [ ] Report presented with a score and severity-tagged issues
- [ ] Fixes applied if requested, and the validator re-run afterwards
