# Workflow: Create a Domain Expertise Skill

**Read these first:**

1. `references/skill-structure.md` — the router pattern this uses
2. `references/authoring-guidance.md` — especially "start from real expertise"
3. `references/agent-skills-spec.md` — the rules the result must satisfy

## What makes this different

A regular skill does one task. A domain expertise skill covers a whole practice area
across its full lifecycle — build, debug, test, optimize, ship — and serves two callers:
a user invoking it directly, and another skill loading its references for knowledge.

Use this workflow when the skill is **mostly knowledge with procedures attached**. Use
`workflows/create-new-skill.md` when it is mostly procedure.

Be honest about whether the domain warrants it. An exhaustive skill nobody maintains
goes stale faster than a small one, and staleness in a knowledge skill is worse than
absence — the agent trusts it.

## Step 1: Define the domain

Ask what domain to cover, and get specific. "Python games" and "Python games with
Pygame" produce very different skills; the narrower one will be better.

Check the scope is a coherent unit. If the answer to "when would someone load this?"
has three unrelated branches, it is three skills.

## Step 2: Name and locate it

Skills live **flat** in the skills directory, one directory per skill:

```
~/.claude/skills/{skill-name}/
```

Do not nest them under a category directory. Discovery expects
`<skills-dir>/<name>/SKILL.md`, and the spec requires `name` to match the immediate
parent directory. A category folder breaks both.

Name it for what it does, in gerund or noun-phrase form — `developing-elixir`,
`building-macos-apps` — not `expertise-macos`.

## Step 3: Identify the workflows

Domain skills cover the full lifecycle. Typical set:

| Workflow | Purpose |
|---|---|
| `build-new-{thing}.md` | Create from scratch |
| `add-feature.md` | Extend something existing |
| `debug-{thing}.md` | Find and fix defects |
| `write-tests.md` | Verify correctness |
| `optimize-performance.md` | Profile and speed up |
| `ship-{thing}.md` | Deploy or distribute |

Plus whatever the domain specifically needs. Only create the ones that describe work
people actually do here — an empty `optimize-performance.md` is worse than none.

## Step 4: Research the domain

This is where a domain skill earns or loses its value. Generic material produces a skill
that tells the agent what it already knows.

**Prefer real sources over search results**, in this order:

1. **The user's own experience and artifacts** — how they actually work in this domain,
   what they had to correct, their runbooks, their code
2. **Official documentation and changelogs** for the libraries involved
3. **Real project code** — production repositories, not tutorials
4. **Search**, last, to find the above

Cover: the current ecosystem and how the main options differ; architecture patterns;
the development, testing, and shipping workflow; common pitfalls; and real-world usage.

For every major library or tool, check whether it is **actively maintained**, what it
should be compared against, and whether anything is deprecated or being replaced.
Describe the state of things rather than pinning a year — "actively maintained as of
the verification date below" ages better than "best library 2026".

Record a verification stamp so the next reader knows how much to trust it:

```markdown
<!-- Verified against upstream docs: YYYY-MM-DD. If today is more than ~60 days past
     this date, re-check before trusting version-specific claims. -->
```

## Step 5: Organize knowledge by domain concern

Structure `references/` around how a practitioner thinks, not by document type. For
game development, that might be `architecture.md`, `libraries.md`, `rendering.md`,
`physics.md`, `audio.md`, `input.md`, `game-loop.md`, `state-management.md`,
`asset-pipeline.md`, `testing-debugging.md`, `performance.md`, `packaging.md`,
`anti-patterns.md`.

Each reference file should carry:

- **Decision guidance** — "if X, use Y; if Z, use A instead"
- **Comparisons** — the real trade-offs between options, not a feature list
- **Working examples** — code that runs, not pseudocode
- **Anti-patterns** — what not to do, and what goes wrong when you do
- **Platform considerations**, where they differ

Markdown headings throughout. A contents list on anything over ~100 lines.

## Step 6: Write SKILL.md

Use `assets/router-skill.md`. Beyond the standard router pieces, a domain skill's
`SKILL.md` should carry a **verification loop** inline, because it applies after every
change regardless of workflow:

````markdown
## After every change

```bash
{build command}
{test command}
{run command}
```

Report: build status, test pass/fail counts, and what the user should check.
````

Keep it under 500 lines and 5,000 tokens. For a large domain that means the principles,
intake, routing, verification loop, and indexes — nothing else.

## Step 7: Write the workflows

Each one: required reading at the top, **actual implementation steps**, a verification
step, anti-patterns, and verifiable success criteria.

A workflow that only says "read the references" is not a workflow. If that is all it
does, delete it and let the reference index handle it.

## Step 8: Check completeness

Ask: **could someone build a professional result from scratch through shipping using
only this skill?**

- [ ] The main libraries and frameworks are covered, with comparisons
- [ ] Architectural approaches documented, with decision guidance
- [ ] Full lifecycle addressed: build, debug, test, optimize, ship
- [ ] Platform-specific considerations included where they matter
- [ ] "When to use X instead of Y" answered throughout
- [ ] Common pitfalls documented
- [ ] Workflows execute real tasks, each naming the references it needs
- [ ] Version-specific claims carry a verification date

Then check both callers work:

- **Direct invocation** — intake routes correctly, the workflow loads its references and
  gives implementation steps, success criteria are clear.
- **Knowledge loading** — another skill reading `references/` alone finds decision
  guidance, compared options, and architecture patterns without needing the workflows.

## Step 9: Validate

```bash
uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ~/.claude/skills/{skill-name}
```

Exit 0 required. Expect the reachability check to matter here: domain skills accumulate
reference files fastest, and are the most likely to grow orphans.

## Step 10: Test on real work

Use the skill for an actual task in the domain. Run the same task without it. If the
results are comparable, the skill is not yet adding value — the usual cause is that the
references restate general knowledge instead of domain specifics.

## Anti-patterns

- Copying tutorial content without verifying it
- Covering only "getting started" and calling it exhaustive
- Omitting "when NOT to use this" guidance
- Not checking whether a library is still maintained
- Organizing references by document type rather than domain concern
- Knowledge with no execution workflows — or workflows that only say "read the refs"
- Skipping verification steps
- Hardcoded years that silently rot
- Referencing skills, scripts, or paths that do not exist

## Success criteria

- [ ] Domain scoped as a coherent unit
- [ ] Skill lives flat in the skills directory; `name` matches its parent directory
- [ ] Research grounded in real sources, with maintenance status checked
- [ ] Knowledge organized by domain concern
- [ ] Principles, intake, routing, and verification loop inline in `SKILL.md`
- [ ] Each workflow: required reading, implementation steps, verification, criteria
- [ ] Each reference: decision guidance, comparisons, working examples, anti-patterns
- [ ] Full lifecycle covered
- [ ] `validate_skill.py` exits 0
- [ ] Passes the dual-purpose test and a real-task comparison
