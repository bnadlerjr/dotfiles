# Workflow: Add a Reference to an Existing Skill

**Read first:** `references/skill-structure.md`.

## Step 1: Select the skill

```bash
ls ~/.claude/skills/
```

Present a numbered list and ask which skill needs a reference. If the caller named one,
skip ahead.

## Step 2: Read the current structure

```bash
cat ~/.claude/skills/{skill-name}/SKILL.md
ls ~/.claude/skills/{skill-name}/references/ 2>/dev/null
```

Report what already exists. If there is no `references/` directory, the skill is
single-file — adding one reference may be fine, but if this is the third thing being
bolted on, `workflows/upgrade-to-router.md` is the better move.

## Step 3: Check it belongs in a reference at all

Ask:

- What knowledge should this contain?
- Which workflows need it?
- Is it reusable across workflows, or specific to one?

**If it serves exactly one workflow, put it in that workflow instead.** A reference read
by one caller is indirection with no benefit. References earn their place by being
shared, or by being large enough that loading them conditionally saves real context.

Also check it isn't already covered. Overlapping references are how a skill starts
contradicting itself.

## Step 4: Write the file

Create `references/{name}.md` with markdown headings. Keep it to one topic.

Give any file over ~100 lines a contents list near the top so the agent can find the
relevant section without reading all of it.

## Step 5: Register it in SKILL.md

Add a row to the reference index, and say **when** to read it:

```markdown
| [{name}.md](references/{name}.md) | ...the condition that makes it relevant |
```

"Read it when the API returns a non-200" is useful. "Additional details" is not.

## Step 6: Point the workflows at it

For each workflow that needs it, add the file to that workflow's required reading at the
top, then re-read the workflow to confirm it still hangs together.

A reference that no workflow reads is an orphan — the validator will say so.

## Step 7: Validate

```bash
uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ~/.claude/skills/{skill-name}
```

## Success criteria

- [ ] The content is genuinely reusable, not workflow-specific
- [ ] File created with markdown headings, one topic, contents list if long
- [ ] Listed in the SKILL.md reference index **with a load condition**
- [ ] Read by at least one workflow
- [ ] `validate_skill.py` exits 0 with no new orphans
