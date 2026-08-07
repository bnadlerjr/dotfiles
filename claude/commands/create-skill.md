---
description: Create or improve a Claude Code skill through guided requirements gathering and delegated authoring
argument-hint: "[skill description | existing skill name | 'audit <skill-name>[: <focus>]' | 'verify <skill-name>']"
model: opus
allowed-tools: Read, Bash, Agent, AskUserQuestion, Glob
---

# Create Skill

**Level 4 (Delegation)** — This command wraps a single skill, justified by the two things it adds. **Interactive intake**: sub-agents cannot use AskUserQuestion, so requirements are gathered here, in the orchestrator, and embedded in the delegation prompt. **Context isolation**: `creating-agent-skills` is a large router that pulls in workflows and references; running it in a sub-agent keeps the main thread clean and returns only the report.

## Variables

- **INPUT**: `$ARGUMENTS` — A description of a new skill, an existing skill name, `audit <skill-name>[: <focus>]`, or `verify <skill-name>`
- **AUDIT_FOCUS**: For audit intent only — optional free-text hypothesis or emphasis after the skill name (e.g., `audit foo: I think its references have drifted`). Empty if not provided.
- **SKILL_PATH**: Absolute path to the target skill directory (e.g. `~/.claude/skills/${SKILL_NAME}`). Set for improve, audit, and verify.
- **WORKFLOW_FILE**: The `creating-agent-skills` workflow the sub-agent must follow.

## Dependencies

- **creating-agent-skills skill**: Core skill-authoring methodology (invoked by sub-agent)
- **thinking-patterns skill**: atomic-thought, self-consistency
- **general-purpose agent** (model: opus): Sub-agent that invokes the skill and writes files

## Initial Response

When invoked:

1. **If input was provided**: Detect intent and begin Phase 1
2. **If no input provided**, respond with:

```
I'll help you create or improve a Claude Code skill.

You can provide:
- A description of what the skill should do (creates new)
- An existing skill name (offers improve, audit, or verify)
- `audit <skill-name>[: <focus>]` (quality audit against the spec)
- `verify <skill-name>` (checks whether the skill's claims are still true)

Usage: /create-skill "Format and lint Terraform files"
```

---

## Phase 1: Intent Detection

Determine what the user wants by examining `INPUT`.

### Detection Logic

1. **Check for audit prefix**: If INPUT starts with "audit " (case-insensitive):
   - Set intent to **audit**
   - Split the remainder on the first `:`, `.`, or newline. The first segment is the skill name (trimmed of quotes/punctuation); anything after is captured as `AUDIT_FOCUS`.
   - Example: `audit create-skill: I think it duplicates the skill` → name=`create-skill`, focus=`I think it duplicates the skill`

2. **Check for verify prefix**: If INPUT starts with "verify " (case-insensitive), the remainder is the skill name and intent is **verify**.

3. **Check for existing skill**: Run `ls ~/.claude/skills/` and `ls .claude/skills/ 2>/dev/null` and check if INPUT matches a directory name **exactly**. If it matches, set intent to **improve**. Substring/typo matches do NOT count — fall through to create.

4. **Otherwise**: Set intent to **create**.

Set `SKILL_PATH` from the matched directory for improve, audit, and verify.

### Confirm Intent (improve only)

If intent is **improve**, read the existing skill's SKILL.md and present a summary, then confirm:

**AskUserQuestion**:
- Header: "Intent"
- Question: "I found the `${SKILL_NAME}` skill. What would you like to do?"
- Options:
  - "Improve it" — Enhance or extend this existing skill
  - "Audit it" — Run a quality audit against the spec and best practices
  - "Verify it" — Check whether its claims about external tools are still true
  - "Create something new" — The name match was coincidental

---

## Phase 2: Requirements Gathering (create/improve only)

Skip this phase for **audit** and **verify** — go directly to Phase 4.

### Identify the gaps

Read `~/.claude/skills/creating-agent-skills/workflows/create-new-skill.md` (Steps 1-2) and `~/.claude/skills/creating-agent-skills/references/authoring-guidance.md`. Those files define what an author must settle before writing — work from them rather than from a list restated here.

Reason in the style of the `atomic-thought` pattern from the `thinking-patterns` skill: for each thing they call for, **commit to an answer first**, then mark it RESOLVED if the user's input forces that answer, or GAP if it does not. Pay particular attention to Step 2's grounding question — whether real expertise, artifacts, or docs exist to build from. A skill with no grounding source will be thin, and the user should hear that before it is built.

If you cannot form a recommendation on more than half of them, the input is too vague — say so rather than asking many naked questions:

> "Your description leaves these open: <list>. Can you say more about <the most load-bearing one>?"

### Ask About Gaps with Committed Recommendations

For each GAP, ask via AskUserQuestion. The recommended answer goes **first** and is labeled `(Recommended)`; each option's `description` carries a one-sentence rationale for the trade-off. Never ask a naked question ("Should this skill handle Terragrunt?") — if you cannot mark one option recommended, the gap isn't ready to ask about.

```
Question: "What should this skill's scope cover?"
Options:
  - "HCL formatting and linting only (Recommended)" — Your description names two concrete operations; a narrow skill triggers more reliably than a broad one.
  - "Add Terragrunt support" — Use if you actually run Terragrunt; it changes file discovery and adds a second toolchain.
  - "Full Terraform lifecycle (plan/apply)" — Use only if you want the skill to run state-changing commands.
```

Cap at 4 questions. Skip any GAP whose answer is low-stakes.

### Decision Gate

**AskUserQuestion**:
- Header: "Ready?"
- Question: "I have enough context to build the skill. Shall I proceed, or is there more to clarify?"
- Options:
  - "Proceed to building" — Start building the skill
  - "Let me add details" — I want to provide additional context

---

## Phase 3: Structure Decision (create only)

Skip this phase for **improve**, **audit**, and **verify**.

### Route domain-expertise shapes first

If the request is **mostly knowledge with procedures attached** — a whole practice area across its lifecycle (build, debug, test, ship), or a reference library other skills will read — set `WORKFLOW_FILE` to `workflows/create-domain-expertise-skill.md` and **skip the structure question**. That workflow fixes the structure itself (always a router) and organizes references by domain concern.

Otherwise set `WORKFLOW_FILE` to `workflows/create-new-skill.md` and choose the structure below.

### Choose single file or router

Read `~/.claude/skills/creating-agent-skills/references/skill-structure.md` ("The two shapes") and commit to a recommendation before asking. Default to single file — growing to a router later is easy; an over-structured skill nobody maintains is not.

**AskUserQuestion**:
- Header: "Structure"
- Question: "Based on the requirements, I recommend a ${RECOMMENDED} skill. Does this sound right?"
- Options:
  - "${RECOMMENDED} (Recommended)" — One sentence tying the recommendation to the requirements gathered
  - "${ALTERNATIVE}" — One sentence on what it buys and what it costs

---

## Phase 4: Delegation

Every intent spawns the same agent: use the **Agent tool with `subagent_type: general-purpose`** (model: `opus`). Each prompt is the shared contract below, followed by the intent-specific block. Embed all gathered context so the sub-agent never needs the user.

### Shared contract (include verbatim in every prompt)

````markdown
## Contract

- Invoke the `creating-agent-skills` skill using the Skill tool. You are a
  **non-interactive caller**: per its "Non-interactive callers" section, skip the intake
  question and follow `${WORKFLOW_FILE}` directly.
- AskUserQuestion will NOT reach the user from a sub-agent. Do not use it. Derive every
  answer the workflow asks for from the context in this prompt.
- Run the validator and paste its output verbatim, including the exit code, under a
  `### Validator` heading in your report:

  ```bash
  uv run ~/.claude/skills/creating-agent-skills/scripts/validate_skill.py ${SKILL_PATH}
  ```

  Exit 0 is the definition of done for **create** and **improve**: fix every error, re-run
  until it exits 0, and never report success on a non-zero exit. For **audit** and
  **verify**, which change nothing, its output is a finding to report.
- Use the report headings given below, in the order given.
````

### For create intent

`SKILL_PATH` is `~/.claude/skills/${SKILL_NAME}`. Prompt body after the contract:

````markdown
# Build a New Claude Code Skill

Build a new skill. All requirements are gathered — proceed without asking the user anything.

## Requirements

${REQUIREMENTS_SUMMARY}

- **Skill name**: ${SKILL_NAME}
- **Purpose**: ${PURPOSE}
- **Scope**: ${SCOPE}
- **Inputs**: ${INPUTS}
- **Outputs**: ${OUTPUTS}
- **Grounding sources**: ${GROUNDING}
- **Structure**: ${STRUCTURE_CHOICE} (single file | router)

## Instructions

1. Follow `${WORKFLOW_FILE}` to create `~/.claude/skills/${SKILL_NAME}/` and write SKILL.md
   plus whatever workflow and reference files the chosen structure calls for.
2. **Do not create a slash command for this skill** — see the "Do not create a slash
   command" section in `workflows/create-new-skill.md`; the rule applies equally on the
   domain-expertise route, which has no such section of its own.
3. Reason in the style of the `self-consistency` pattern from the `thinking-patterns`
   skill: **user** (does it trigger from the description alone?), **author** (does each
   file earn its place?), **execution** (are the instructions specific enough to follow
   without the author present?).

## Report

Headings in order: `### Files Created` (absolute paths), `### Skill Structure` (what and
why), `### Validator`, `### Self-Consistency Check` (all three perspectives),
`### Suggestions for Testing` (2-3 example invocations).
````

### For improve intent

Read the skill's full content first. `WORKFLOW_FILE` is whichever `creating-agent-skills` workflow matches the change — `add-workflow.md`, `add-reference.md`, `add-script.md`, `add-template.md`, `upgrade-to-router.md`, or `create-new-skill.md` for a rewrite. Prompt body after the contract:

````markdown
# Improve an Existing Claude Code Skill

Improve the `${SKILL_NAME}` skill at `${SKILL_PATH}`. All requirements are gathered —
proceed without asking the user anything.

## Current Skill Content

${EXISTING_SKILL_CONTENT}

## Requested Changes

${REQUIREMENTS_SUMMARY}

## Instructions

1. Read the whole tree first — `${SKILL_PATH}/SKILL.md` and every file under
   `workflows/` and `references/`. Editing only `SKILL.md` is how a router starts
   contradicting its own workflows.
2. Apply the requested changes while preserving existing behavior. Strip anything that no
   longer earns its place; do not add files "just in case".
3. Reason in the style of the `self-consistency` pattern from the `thinking-patterns`
   skill: **user** (do existing invocations still work?), **author** (is the structure
   still clean?), **execution** (are the new instructions specific enough to follow?).

## Report

Headings in order: `### Files Modified` (absolute paths + what changed), `### Files
Created`, `### Validator`, `### Self-Consistency Check`, `### Before/After` (key
differences in skill behavior).
````

### For audit intent

`WORKFLOW_FILE` is `workflows/audit-skill.md`. Prompt body after the contract:

````markdown
# Audit a Claude Code Skill

Audit the `${SKILL_NAME}` skill at `${SKILL_PATH}` for quality and spec compliance.

## User's Audit Focus (optional)

${AUDIT_FOCUS}

If non-empty, treat this as a hypothesis the user wants pressure-tested: report an explicit
verdict (accept / partially accept / reject) with rationale tied to the skill's actual
content, then run the standard checklist. If empty, run the standard checklist only.

## Instructions

1. Run the validator **first** — it settles every mechanical question before you spend
   attention on judgment calls, and everything it reports is a finding.
2. **Read the whole tree**: start with `ls -R ${SKILL_PATH}`, then read `SKILL.md` and
   every file under `workflows/` and `references/`. The audit covers the whole skill, not
   just `SKILL.md`; the most damaging defects live in the disagreements *between* files.
3. Work the workflow's full checklist and its anti-pattern list. Do not offer to apply
   fixes — return the report only.
4. Assign severity on the workflow's scale, verbatim: **critical** = invalid per the spec,
   or two files that contradict each other; **major** = the skill will misfire or mislead;
   **minor** = quality and consistency.

## Report

### Validator
{output verbatim, including the exit code}

### Audit Report: ${SKILL_NAME}

Then the report format from `workflows/audit-skill.md` Step 5: `#### Passing`,
`#### Issues` (each tagged critical | major | minor, naming the file, with a specific fix),
`#### Score: X/Y criteria passing`, `#### Recommended Fixes` (prioritized). If AUDIT_FOCUS
was non-empty, put `#### On the user's focus` — verdict plus rationale — ahead of them.
````

### For verify intent

`WORKFLOW_FILE` is `workflows/verify-skill.md`. Prompt body after the contract:

````markdown
# Verify a Claude Code Skill's Content

Verify whether the `${SKILL_NAME}` skill at `${SKILL_PATH}` still tells the truth. This
checks **content accuracy**, not structure — claims about APIs, CLI tools, frameworks,
paths, and bundled scripts that may have changed since the skill was written.

## Instructions

1. Follow the workflow: categorize the skill by dependency type, extract and count the
   verifiable claims, then check each with the method that type calls for. Prefer official
   docs and changelogs over search results.
2. Report expired freshness stamps as findings.
3. Do not apply updates — return the report only.

## Report

### Validator
{output verbatim, including the exit code}

### Verification Report: ${SKILL_NAME}

Then the report format from `workflows/verify-skill.md` Step 5 exactly: `#### Verified
current` (claim + evidence), `#### May be outdated` (claim + what changed + what the docs
now say), `#### Broken or invalid` (claim + why + the fix), `#### Could not verify` (claim
+ why not), then **Overall:** Fresh | Needs updates | Significantly stale and
**Verified on:** {today's date}. Close with the re-verify cadence from Step 7's table.
````

---

## Phase 5: Results

Display the sub-agent's report verbatim, then offer the next step. This is the only place fixes can be authorized, since the sub-agent cannot ask.

### For create/improve

**AskUserQuestion**:
- Header: "Next steps"
- Question: "The skill is written and the validator passed. What next?"
- Options:
  - "Run an audit" — Check it against the spec and the quality checklist
  - "Verify its claims" — Check whether its external claims are still true
  - "Test it now" — Try invoking the skill to see if it triggers
  - "Done" — Everything looks good

Re-enter Phase 4 with the corresponding intent if audit or verify is chosen.

### For audit/verify

**AskUserQuestion**:
- Header: "Fixes"
- Question: "Would you like me to apply the recommended fixes?"
- Options:
  - "Fix all issues" — Apply every recommended fix
  - "Fix critical and major only" — Skip the minor quality items
  - "No fixes needed" — Just wanted the report

If fixes are requested, re-enter Phase 4 with **improve** intent, embedding the findings as `REQUIREMENTS_SUMMARY`. The improve prompt's validator gate is what confirms the fixes landed.

---

## Error Handling

### No Input Provided

```
No input provided. Please specify what you'd like to do:

Usage:
  /create-skill "Format and lint Terraform files"     — create a new skill
  /create-skill developing-elixir                     — improve an existing skill
  /create-skill audit reviewing-code                  — audit an existing skill
  /create-skill audit reviewing-code: check the refs  — audit with a specific hypothesis
  /create-skill verify datadog-cli                    — check whether its claims still hold
```

### Skill Not Found (improve/audit/verify)

```
Skill "${SKILL_NAME}" not found in ~/.claude/skills/ or .claude/skills/.

Available skills:
${SKILL_LIST}

Did you mean one of these, or would you like to create a new skill named "${SKILL_NAME}"?
```

### Sub-Agent Failure

```
The skill-building sub-agent encountered an issue:
${ERROR_DETAILS}

Options:
1. Retry with the same parameters
2. Adjust requirements and try again
3. Build manually using the creating-agent-skills skill directly
```

---

## Example Sessions

### Create a new skill

```bash
/create-skill "Format and lint Terraform files"
```

1. Detects **create** (no exact directory match)
2. Reads `create-new-skill.md` Steps 1-2, commits to answers, asks only about real gaps (scope, grounding sources) with a recommended option first
3. Recommends single file over router, confirms
4. Delegates with `WORKFLOW_FILE = workflows/create-new-skill.md`; the sub-agent writes the files and must exit 0 on the validator
5. Presents the report, offers audit / verify / test

### Audit with a focus

```bash
/create-skill audit reviewing-code: I think the checklist contradicts the workflow
```

1. Detects **audit**, splits on `:` → name=`reviewing-code`, focus=the hypothesis
2. Skips Phases 2 and 3
3. Sub-agent runs the validator, reads the whole tree, works the checklist, and rules on the hypothesis
4. Presents validator output plus the severity-tagged report and score
5. Offers to apply fixes via the improve intent

### Verify a skill's claims

```bash
/create-skill verify datadog-cli
```

1. Detects **verify**
2. Sub-agent follows `workflows/verify-skill.md`: categorizes the skill as CLI-based, extracts claims, runs the documented commands
3. Presents claims as verified current / may be outdated / broken / could not verify, with a dated overall status and a re-verify cadence
