# Workflow: Upgrade a Skill to the Router Pattern

**Read first:** `references/skill-structure.md`.

## Step 1: Select the skill

```bash
ls ~/.claude/skills/
```

Present a numbered list and ask which to upgrade. If the caller named one, skip ahead.

## Step 2: Confirm it needs upgrading

```bash
cat ~/.claude/skills/{skill-name}/SKILL.md
ls -R ~/.claude/skills/{skill-name}/
```

**Already a router** (has `workflows/` and an intake question) → say so, and offer
`workflows/add-workflow.md` instead.

**Has workflows but no routing table** → this is not an upgrade, it is a *repair*. The
routing table is missing and every workflow is unreachable. Go to Step 7, and check
whether `SKILL.md` has grown duplicate copies of the workflow procedures — if it has,
they have already diverged, and you must reconcile them before deleting either.

**Small and single-purpose** (under ~200 lines, one intent) → say the router is likely
overkill, and ask whether to proceed anyway.

**Good candidate** → over ~200 lines, multiple distinct intents, principles that
shouldn't be skipped, still growing.

## Step 3: Identify the components

Analyse the current skill and separate:

1. **Essential principles** — rules that apply to every intent
2. **Distinct intents** — the different things a user might want
3. **Reusable knowledge** — patterns, examples, technical detail

Present the breakdown and ask whether it looks right before moving anything.

```
## Analysis

**Essential principles:**
- ...

**Distinct intents (→ workflows):**
- {name}: {description}

**Knowledge (→ references):**
- {topic}
```

## Step 4: Create the directories

```bash
mkdir -p ~/.claude/skills/{skill-name}/{workflows,references}
```

## Step 5: Extract the workflows

For each intent, create `workflows/{name}.md` with required reading at the top, the
steps moved from the original, and verifiable success criteria.

Choose the filenames deliberately and keep them stable — callers may target them
directly, so renaming later is a breaking change.

## Step 6: Extract the references

For each knowledge topic, create `references/{name}.md` and move the content. Give any
file over ~100 lines a contents list.

## Step 7: Rewrite SKILL.md as a router

Use `assets/router-skill.md`. It must contain:

- The essential principles, **inline**
- The intake question
- **A routing table naming a file for every branch** — this is the part that gets lost
- The non-interactive caller contract
- Reference and workflow indexes

## Step 8: Delete what you moved

**This is the step that gets skipped, and skipping it is what breaks the skill.**

Remove the extracted procedures and knowledge from `SKILL.md`. A copy left behind does
not stay a copy: the two versions drift, and eventually the skill tells the agent to do
one thing in `SKILL.md` and the opposite in a workflow.

## Step 9: Verify nothing was lost

- [ ] Every principle preserved, now inline
- [ ] Every procedure preserved, now in exactly one workflow
- [ ] Every piece of knowledge preserved, now in a reference
- [ ] No content duplicated between `SKILL.md` and a workflow
- [ ] Nothing orphaned

```bash
uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ~/.claude/skills/{skill-name}
```

Exit 0 required. The validator's reachability check is the direct test that Step 7's
routing table actually reaches everything Step 5 created.

## Step 10: Test

Invoke the upgraded skill and confirm the intake question appears, each routing option
reaches the right workflow, workflows load the references they declare, and behaviour
matches the original.

## Success criteria

- [ ] `workflows/` created and populated
- [ ] `references/` created if needed
- [ ] `SKILL.md` rewritten as a router with a complete routing table
- [ ] Essential principles inline
- [ ] Extracted content **deleted** from `SKILL.md`
- [ ] All original content preserved somewhere
- [ ] `validate_skill.py` exits 0 with no unreachable files
- [ ] Tested end to end
