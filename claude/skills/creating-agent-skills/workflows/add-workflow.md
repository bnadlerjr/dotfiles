# Workflow: Add a Workflow to an Existing Skill

**Read first:** `references/skill-structure.md`.

## Step 1: Select the skill

**Do not use AskUserQuestion** — there may be more skills than it can display.

```bash
ls ~/.claude/skills/
```

Present a numbered list and ask which skill needs a new workflow.

## Step 2: Read the current structure

```bash
cat ~/.claude/skills/{skill-name}/SKILL.md
ls ~/.claude/skills/{skill-name}/workflows/ 2>/dev/null
```

- **No `workflows/`** → the skill is single-file and needs restructuring first (Step 4).
- **Has `workflows/` but no routing table in `SKILL.md`** → stop and repair that first
  via `workflows/upgrade-to-router.md`. Adding a workflow to a skill whose routing is
  broken just creates another unreachable file.
- **Has both** → proceed.

Report what exists so the new workflow doesn't duplicate one.

## Step 3: Define the workflow

Ask:

- What should it do?
- When would someone choose it over the existing workflows?

That second question is the important one. If the answer is fuzzy, the intents overlap
and the routing table will be ambiguous — either sharpen the boundary or extend an
existing workflow instead.

## Step 4: Restructure first, if needed

If the skill is currently single-file, ask whether to upgrade it to the router pattern,
and if so follow `workflows/upgrade-to-router.md` to completion before continuing.

## Step 5: Write the workflow file

Create `workflows/{name}.md`:

````markdown
# Workflow: {Name}

**Read these first:**
1. `references/{relevant}.md`

## Step 1: {Name}
{What to do}

## Step 2: {Name}
{What to do}

## Success criteria

- [ ] {Verifiable outcome}
````

Pick the filename deliberately and keep it stable — callers may target workflow files
directly, so renaming later is a breaking change.

## Step 6: Wire it into SKILL.md

Both of these, or the workflow is unreachable:

1. **Intake question** — add the option
2. **Routing table** — map the answer to the file

Then, **if the skill keeps a separate workflow index**, add the row there too. Many
routers don't — a routing table that already names every file makes the index a second
copy to keep in sync. Don't add one just to have one.

## Step 7: Add references it needs

If it requires knowledge that doesn't exist yet, follow `workflows/add-reference.md`.

## Step 8: Validate and test

```bash
uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ~/.claude/skills/{skill-name}
```

Then invoke the skill: does the new option appear, does it route correctly, does the
workflow load its declared references, does it run through?

## Success criteria

- [ ] The new workflow's boundary against existing ones is clear
- [ ] Workflow file created with required reading, steps, and verifiable criteria
- [ ] Intake question and routing table updated; workflow index too, if the skill has one
- [ ] Any needed references created and wired in
- [ ] `validate_skill.py` exits 0 with no unreachable files
- [ ] Tested end to end
