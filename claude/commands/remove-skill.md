---
description: Remove a skill from claude/skills/ and purge references across claude/
argument-hint: "<skill-name>"
allowed-tools: Bash, Read, Edit, Glob, Grep, AskUserQuestion
---

# Remove Skill

**Level 3 (Control Flow)** — Locates a skill, finds every reference to it across `claude/`, confirms with the user, then deletes the skill directory and updates referencing files.

## Variables

- **SKILL_NAME**: `$ARGUMENTS` — the skill directory name under `claude/skills/` (e.g. `refactoring-code`)
- **DOTFILES_ROOT**: `/Users/bobnadler/dotfiles`
- **SKILL_DIR**: `${DOTFILES_ROOT}/claude/skills/${SKILL_NAME}`
- **CLAUDE_ROOT**: `${DOTFILES_ROOT}/claude`

## Instructions

- This command is **destructive**. Never skip the confirmation gate in Step 3.
- Only operate inside `${CLAUDE_ROOT}`. Do not touch files elsewhere in the repo.
- When editing a referencing file, preserve surrounding content — remove only the line(s) or phrase(s) that name the skill. If removal would leave a broken sentence or orphan bullet, rewrite the surrounding text minimally.
- Do not commit the change. Leave the working tree dirty so the user can review and commit themselves.

## Workflow

1. **Validate input**
   - If `SKILL_NAME` is empty, print usage and exit:
     ```
     Usage: /remove-skill <skill-name>
     Example: /remove-skill refactoring-code
     ```
   - If `SKILL_DIR` does not exist, list available skills (`ls ${CLAUDE_ROOT}/skills`) and exit.

2. **Find references**
   - Use Grep to search `${CLAUDE_ROOT}` (excluding `${SKILL_DIR}` itself) for the literal string `SKILL_NAME`.
   - Search these locations explicitly:
     - `claude/commands/**`
     - `claude/agents/**`
     - `claude/guidelines/**`
     - `claude/templates/**`
     - `claude/skills/**` (other skills that cross-reference this one)
     - `claude/CLAUDE-PERSONAL.md`
     - `claude/settings.json`
   - Collect each hit as `{file, line_number, line_content}`.

3. **Present plan and confirm** (gate)
   - Show the user:
     - The skill directory to be deleted (with file count from `ls -R ${SKILL_DIR} | wc -l` or similar).
     - Every reference found, grouped by file, with line numbers and the matching line.
   - Use **AskUserQuestion**:
     - Header: "Remove skill"
     - Question: "Remove `${SKILL_NAME}` and update the N referencing file(s)?"
     - Options:
       - "Proceed" — delete the directory and edit all referencing files
       - "Directory only" — delete the directory but leave references intact (useful if references are historical/intentional)
       - "Cancel" — do nothing
   - If "Cancel", exit.

4. **Remove the skill directory**
   - Run `rm -rf ${SKILL_DIR}`.

5. **Update referencing files** (skip if "Directory only")
   - For each file with hits, use Read + Edit to remove the references. Apply judgment per context:
     - **List item** (bullet, table row): delete the whole line.
     - **Inline mention in prose**: rewrite the sentence to omit the skill name cleanly, or delete the sentence if it has no other purpose.
     - **Structured config** (e.g. JSON in `settings.json`): remove the key/entry and preserve valid syntax.
   - After each edit, verify with a follow-up Grep that the file no longer contains `SKILL_NAME`.

6. **Verify**
   - Run a final Grep for `SKILL_NAME` across `${CLAUDE_ROOT}`. Expect zero hits (or only hits the user explicitly chose to keep).
   - Run `ls ${SKILL_DIR}` and expect "No such file or directory".

## Report

Print a summary:

```
Removed skill: ${SKILL_NAME}

Deleted:
  - ${SKILL_DIR}/ (N files)

Updated:
  - claude/commands/foo.md    (1 reference)
  - claude/CLAUDE-PERSONAL.md (2 references)
  ...

Remaining references: 0

Review with `git diff` and commit when ready.
```

If any step was skipped or any references remain, call them out explicitly in the report.
