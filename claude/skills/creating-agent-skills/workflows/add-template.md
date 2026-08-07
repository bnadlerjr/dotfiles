# Workflow: Add a Template to a Skill

**Read first:** the "Templates for output format" section of
`references/instruction-patterns.md`.

Templates are reusable output structures the agent copies and fills. They live in
**`assets/`** — the directory the Agent Skills specification names for templates and
static resources. (Older skills may use `templates/`; rename it to `assets/` while
you're here.)

## Step 1: Identify the skill and the output

Ask, if not already supplied: which skill, and what output should this template shape?

## Step 2: Confirm a template is the right answer

- [ ] The output has a consistent structure across uses
- [ ] Structure matters more than creative generation
- [ ] Filling placeholders is more reliable than starting from blank

If the output genuinely needs to vary, a template will fight the task. Describe the
shape in the workflow instead.

**Short templates belong inline** in `SKILL.md` or the workflow. Move a template into
`assets/` when it is long, or when it is only needed in some cases — that is what makes
on-demand loading worth the indirection.

## Step 3: Create the directory

```bash
mkdir -p ~/.claude/skills/{skill-name}/assets
```

## Step 4: Design the structure

- What sections does the output need?
- What varies between uses? → placeholders
- What stays constant? → static structure

## Step 5: Write the template

Create `assets/{name}.md`:

- Clear section markers
- One consistent placeholder syntax — `{{PLACEHOLDER}}` throughout, not mixed with
  `[PLACEHOLDER]`
- Brief inline guidance where a section could be misread
- **Minimal example content.** Anything concrete you write will be copied verbatim
  sooner or later, so keep examples to the shape, not the substance.

Complete but minimal. Over-constraining with too many required sections produces
padded output.

## Step 6: Wire it into the workflow

Tell the agent when to use it and what to do with it:

```markdown
1. Read `assets/{name}.md`
2. Copy the structure
3. Fill each placeholder from the gathered context
4. Confirm no placeholders remain unfilled
```

The workflow supplies *when*; the template supplies *what shape*.

## Step 7: Validate

```bash
uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ~/.claude/skills/{skill-name}
```

A template nothing references is an orphan; the validator will flag it.

## Step 8: Test

Run the workflow and check that the template is read at the right step, every
placeholder is filled, the output matches the structure, and nothing was copied
verbatim that should have been adapted.

## Success criteria

- [ ] A template genuinely fits the output
- [ ] Lives in `assets/`, not `templates/`
- [ ] Consistent placeholder syntax; minimal example content
- [ ] Referenced from at least one workflow, with instructions on when and how
- [ ] `validate_skill.py` exits 0 with no new orphans
- [ ] Tested, with no placeholders left unfilled
