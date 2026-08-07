# Workflow: Create a New Skill

**Read these first:**

1. `references/agent-skills-spec.md` — the rules the result must satisfy
2. `references/skill-structure.md` — single file vs. router
3. `references/authoring-guidance.md` — what goes in and how prescriptive to be

Read `references/instruction-patterns.md` when writing the body, and
`references/using-scripts.md` only if the skill will bundle executable code.

## Step 1: Gather requirements

**If the request already contains context** ("build a skill for X"): analyse what is
stated, what can be inferred, and what is genuinely unclear. Ask only about real gaps.

**If invoked with no context**: ask what they want to build.

Ask 2-4 domain-specific questions with AskUserQuestion, focused on scope, boundaries,
inputs, and outputs. Do not ask what is already obvious from the request.

Then confirm: "Ready to proceed with building, or would you like me to ask more
questions?"

**Non-interactive callers**: if the requirements were supplied up front, or you are a
subagent, skip this step and the AskUserQuestion calls entirely. Derive the answers
from the context you were given and continue.

## Step 2: Ground it in real expertise

This is the step that most determines quality. A skill generated from general model
knowledge produces generic procedure — "handle errors appropriately" — instead of the
specific conventions and failure modes that make a skill worth loading.

Before writing, gather concrete material:

- Has the user just done this task manually? Extract the steps that worked and,
  especially, **the corrections they made along the way**.
- Are there existing artifacts — runbooks, style guides, API specs, schemas, code
  review comments, past incident write-ups? Read them.
- Does the skill target an external service or library? Ask whether to research current
  documentation first, then use WebSearch or WebFetch against official sources.

If none of this is available, say so plainly — the skill will be thinner, and the
user should know that before it is built.

## Step 3: Choose the structure

**Single file** — one workflow, small knowledge set, under ~200 lines.

**Router** — multiple distinct intents, shared knowledge across them, principles that
must not be skipped, or a skill likely to grow:

```
skill-name/
├── SKILL.md      # principles + intake + routing
├── workflows/    # procedures — FOLLOW
├── references/   # knowledge — READ
├── assets/       # output structures — COPY AND FILL
└── scripts/      # reusable code — RUN
```

Add `assets/` when the skill produces consistent output structures and the structure
matters more than creative generation. Add `scripts/` when the same code would
otherwise be rewritten every invocation, or when the operation is error-prone by hand.

Start smaller than feels right. Growing to a router later is easy; an over-structured
skill nobody maintains is not.

## Step 4: Create the directory

```bash
mkdir -p ~/.claude/skills/{skill-name}
# Router only, and only the directories actually needed:
mkdir -p ~/.claude/skills/{skill-name}/{workflows,references}
mkdir -p ~/.claude/skills/{skill-name}/{assets,scripts}
```

The directory name **must** equal the `name` in frontmatter.

## Step 5: Write SKILL.md

Copy the matching template and fill it in:

- Single file → `assets/simple-skill.md`
- Router → `assets/router-skill.md`

Frontmatter requirements:

- `name` — required; lowercase, hyphens, no consecutive hyphens, matches the directory
- `description` — required; third person, states what it does **and** when to use it,
  under 1024 characters
- Optional spec fields — `license`, `compatibility`, `metadata`, `allowed-tools`
- **Non-spec fields only when deliberately chosen.** Support is per field, not per
  client — check the matrix in `references/claude-code-extensions.md` before assuming
  either way. If the field you chose is single-client, say so in `compatibility` and
  tell the user why the trade was worth it.

Body: standard markdown headings. Keep it under 500 lines and 5,000 tokens.

A router's `SKILL.md` must contain a **routing table naming a file for every branch**.
An intake question with nothing to route to is the single most common way these skills
break.

## Step 6: Write the workflows (router only)

One file per intent, each with required reading at the top, numbered steps, and
verifiable success criteria. Keep the filenames stable — callers may target them
directly.

## Step 7: Write the references (router only)

Knowledge that multiple workflows need, that doesn't change based on which workflow is
running: patterns, technical detail, domain facts. Give any file over ~100 lines a
contents list.

State **when** to load each one. "Read `references/api-errors.md` if the API returns a
non-200" beats listing the file.

## Step 8: Validate

```bash
uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ~/.claude/skills/{skill-name}
```

Fix every error. Exit 0 is required before continuing.

The validator checks the spec rules, plus broken links, chains too deep to reach, and
files nothing references. Warnings about non-standard fields are expected if you chose
an extension deliberately — confirm each one was a decision, not an accident.

## Step 9: Test it on a real task

Not a hypothetical one.

1. Ask the skill to do something it was built for, phrased the way a user would.
2. Confirm it activates from the description alone — if it doesn't, the description is
   the problem, not the body. See `references/evaluating-skills.md`.
3. For a router: confirm the intake question appears and routes to the right workflow,
   and that the workflow loads the references it declared.
4. Run the same task **without** the skill. If the result is just as good, the skill
   isn't earning its context yet.
5. Read the transcript for wasted steps and ignored instructions.

Add every correction you had to make to a gotchas section, then iterate.

## Do not create a slash command

Skills are auto-discovered through their `description` — the harness routes a natural
language request to the matching skill. A `/{skill-name}` wrapper that only invokes one
skill is duplicate surface: two files to keep in sync, no composition value, and it ties
the skill's identity to one invocation path.

A command earns its place only when it composes multiple skills or adds orchestration
the skill cannot carry itself.

## Success criteria

- [ ] Requirements gathered, or derived from supplied context
- [ ] Grounded in real expertise, or the gap stated explicitly
- [ ] Directory name matches `name`
- [ ] `name` and `description` present and spec-valid; description under 1024 chars
- [ ] Non-standard fields used only deliberately, with the trade-off recorded
- [ ] Body uses markdown headings, under 500 lines and 5,000 tokens
- [ ] Router: principles inline, routing table names a file for every branch
- [ ] Every bundled file reachable, and the skill says when to load each
- [ ] `validate_skill.py` exits 0
- [ ] Tested on a real task, and against the no-skill baseline
