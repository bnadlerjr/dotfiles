# Workflow: Audit a Skill

**Read these first** — they are the authority this audit enforces:

1. `../SKILL.md` — Core Principles (markdown format, no XML tags; gerund naming)
2. `../references/best-practices.md` — concise-is-key, descriptions, progressive disclosure, checklist
3. `../references/official-spec.md` — frontmatter fields, lifecycle, the 1,536-char description cap

## Step 1: List Available Skills

**Do NOT use AskUserQuestion** — there may be many skills.

```bash
ls ~/.claude/skills/
```

Present them as a numbered list, then ask: "Which skill would you like to audit? (enter number or name)"

## Step 2: Read the Skill

```bash
cat ~/.claude/skills/{skill-name}/SKILL.md
ls ~/.claude/skills/{skill-name}/
ls ~/.claude/skills/{skill-name}/references/ 2>/dev/null
ls ~/.claude/skills/{skill-name}/workflows/ 2>/dev/null
```

Read the reference and workflow files too — the audit covers the whole skill, not just SKILL.md.

## Step 3: Run the Audit Checklist

Evaluate against each criterion.

### YAML Frontmatter

- [ ] `description` present, third person ("Use when…"), states what it does AND when to use it
- [ ] Description front-loads trigger keywords; combined `description` + `when_to_use` within the 1,536-char cap
- [ ] If `name` is set: lowercase letters, numbers, hyphens only, ≤64 chars, matches the directory
- [ ] Name uses gerund form (`processing-pdfs`, `reviewing-code`) — not `helper`/`utils`/`tools`/`anthropic-*`/`claude-*`

### Body Structure

- [ ] SKILL.md body under 500 lines
- [ ] **Standard markdown headings in the body — no XML tags** (`#`/`##`, not `<objective>`/`<process>`)
- [ ] Examples are concrete (input/output pairs), not abstract
- [ ] Consistent terminology throughout
- [ ] No time-sensitive information (use an "old patterns" section instead)
- [ ] Forward-slash paths only (`scripts/helper.py`, never backslashes)

### Progressive Disclosure (multi-file skills)

- [ ] SKILL.md is an overview that navigates to detail; heavy content lives in references
- [ ] References are one level deep from SKILL.md (no SKILL.md → a.md → b.md chains)
- [ ] Reference files over 100 lines have a table of contents
- [ ] No redundant content duplicated across files (intentional repetition of a hard safety constraint is acceptable)
- [ ] Reference files also use markdown headings, not XML tags

### Scripts (if present)

- [ ] Handle errors explicitly
- [ ] No unexplained "voodoo constants"
- [ ] Required packages listed
- [ ] Clear documentation

### Content Quality

- [ ] Instructions are actionable (not vague platitudes like "handle it appropriately")
- [ ] Steps are specific (not "do the thing")
- [ ] Any success criteria are verifiable (not "user is satisfied")

### Invocation Surface

- [ ] No single-skill `/{skill-name}` command wrapper in `~/.claude/commands/` — skills are auto-discovered via their `description`; a wrapper that only invokes one skill is duplicate surface to keep in sync

## Step 4: Generate the Report

```
## Audit Report: {skill-name}

### Passing
- [list passing items]

### Issues Found
1. **[Issue]** (severity: critical | major | minor): [description]
   → Fix: [specific action]

### Score: X/Y criteria passing
```

## Step 5: Offer Fixes

If issues found, ask: "Would you like me to fix these issues?"

1. **Fix all** — apply all recommended fixes
2. **Fix critical/major only** — apply the highest-severity fixes
3. **Just the report** — no changes

If fixing: make each change, confirm the file is still valid, and report what was fixed.

## Anti-Patterns to Flag

- **XML tags in the body** — use markdown headings instead (the most common stale-skill defect)
- **Monolithic skill** — single SKILL.md over 500 lines that should be split
- **Mixed concerns** — step-by-step procedures and reference knowledge crammed into one file
- **Vague steps** — "Handle the error appropriately"
- **Untestable criteria** — "User is satisfied"
- **Deep nesting** — references more than one level from SKILL.md
- **Broken references** — files linked but absent
- **Redundant content** — the same information repeated across files
- **Single-skill command wrapper** — a `/foo` shim that only forwards to one skill
- **Windows paths** — backslashes instead of forward slashes
- **Time-sensitive info** — "before August 2025, use…" instead of an "old patterns" section

## Success Criteria

The audit is complete when:

- [ ] The whole skill (SKILL.md + references + workflows) has been read
- [ ] Every checklist item has been evaluated
- [ ] The report, with a score and severity-tagged issues, has been presented
- [ ] Fixes have been applied if requested
