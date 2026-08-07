# Workflow: Get Guidance on Skill Design

**Read these first:**

1. `references/authoring-guidance.md` — scoping, and what belongs in a skill at all
2. `references/skill-structure.md` — single file vs. router

## Step 1: Understand the problem space

Ask:

- What task or domain are you trying to support?
- Do you do it repeatedly, or is this a one-off?
- What goes wrong when you don't have a skill for it — what does the agent get wrong?

That last question matters most. If nothing goes wrong, there may be nothing to encode.

## Step 2: Decide whether a skill is the right shape

**A skill is right when:**

- The task recurs across sessions
- The knowledge is stable enough to stay true for a while
- The agent gets it *wrong* without guidance — there is a real correction to encode
- The knowledge is specific: your conventions, your failure modes, your API's quirks

**A skill is the wrong shape when:**

- It's a one-off — just do the task
- The knowledge changes constantly — it will be stale before it's useful
- The agent already handles it well — the skill only spends context
- It's really a user-triggered action with side effects — that wants explicit
  invocation, not auto-activation

Say which of these applies, plainly, before designing anything. Talking someone out of
a skill they don't need is a good outcome.

## Step 3: Check scope

A skill should encapsulate a coherent unit of work, like a function.

- **Too narrow** — several skills must load for one task, risking overhead and
  conflicting instructions
- **Too broad** — hard to activate precisely, and half of it is irrelevant on any
  given run

"Query this database and format the results" is probably one unit. Adding database
administration to it is two.

## Step 4: Map the intents

Ask: "What are the different things someone might want to do here?"

Common shapes: create / read / update / delete · build / debug / ship ·
setup / use / troubleshoot · import / process / export.

Each distinct intent is a candidate workflow. One intent means one file.

## Step 5: Identify shared knowledge

Ask: "What must be known regardless of which intent is running?"

That becomes references — API patterns, domain facts, worked examples, configuration
detail.

## Step 6: Identify the principles that must not be skipped

Ask: "What rules always apply, no matter what?"

These go inline in `SKILL.md`, because it always loads. Anything in a separate file can
be skipped.

Examples: "Always verify before reporting success." "Never store credentials in code."
"Ask before making destructive changes."

## Step 7: Recommend a structure

| Situation | Recommendation |
|---|---|
| One task, done often, small knowledge set | Single-file skill |
| Multiple related intents | Router + workflows |
| Complex domain, lots of shared patterns | Router + workflows + references |
| Repeated code the agent would otherwise rewrite | Add `scripts/` |
| Consistent output structures | Add `assets/` |
| One-off task | No skill |

Recommend the smallest structure that fits. Growing into a router later is
straightforward; an over-structured skill nobody maintains is not.

## Step 8: Present and hand off

Summarize the recommended structure, the workflows, the references, and the essential
principles. Then ask whether it looks right and whether they're ready to build.

If yes, switch to `workflows/create-new-skill.md`. If no, iterate.

## Success criteria

- [ ] The user knows whether they need a skill at all
- [ ] Scope checked against the coherent-unit test
- [ ] Intents identified and mapped to candidate workflows
- [ ] Shared knowledge identified
- [ ] Essential principles identified
- [ ] A structure recommended and explained
- [ ] The user is ready to build, or has decided not to
