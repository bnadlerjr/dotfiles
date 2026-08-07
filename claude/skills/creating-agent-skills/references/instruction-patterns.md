# Instruction Patterns

Reusable structures for skill bodies. Not every skill needs all of them — use the ones
that fit the task.

## Contents

- [Gotchas sections](#gotchas-sections)
- [Templates for output format](#templates-for-output-format)
- [Examples](#examples)
- [Checklists](#checklists)
- [Validation loops](#validation-loops)
- [Plan-validate-execute](#plan-validate-execute)
- [Conditional workflows](#conditional-workflows)
- [Checkpoints and error recovery](#checkpoints-and-error-recovery)
- [Bundling repeated work](#bundling-repeated-work)
- [Anti-patterns](#anti-patterns)

## Gotchas sections

Often the highest-value content in a skill: environment-specific facts that defy
reasonable assumptions. Not general advice ("handle errors appropriately") but concrete
corrections to mistakes the agent *will* make otherwise.

```markdown
## Gotchas

- The `users` table uses soft deletes. Queries must include
  `WHERE deleted_at IS NULL` or results will include deactivated accounts.
- The user ID is `user_id` in the database, `uid` in the auth service,
  and `accountId` in the billing API. All three refer to the same value.
- The `/health` endpoint returns 200 as long as the web server is running,
  even if the database connection is down. Use `/ready` for full service health.
```

Keep gotchas **in `SKILL.md`**, where the agent reads them before hitting the
situation. A separate file works only if you say when to load it — and for non-obvious
issues the agent won't recognize the trigger.

**When the agent makes a mistake you have to correct, add the correction here.** This
is the most direct way to improve a skill over time.

## Templates for output format

When output must follow a specific shape, provide a template. Agents pattern-match
against concrete structures far more reliably than against prose descriptions.

Short templates live inline. Longer ones, or ones needed only in certain cases, go in
`assets/` and are referenced from `SKILL.md` so they load on demand.

Match strictness to need. **Strict** — for compliance reports, standardized formats,
anything machine-processed:

`````markdown
Use this exact structure:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data

## Recommendations
1. Specific actionable recommendation
```
`````

**Flexible** — for exploratory or creative work, say so explicitly: "Here is a sensible
default; adapt sections as needed for the specific analysis."

Template files use a consistent placeholder syntax (`{{PLACEHOLDER}}` or
`[PLACEHOLDER]`) with brief inline guidance where a section might be ambiguous. Keep
them focused on structure, not content — heavy example content gets copied verbatim.

## Examples

When output quality depends on nuances prose can't carry — exact spacing, tone, level
of detail — show input/output pairs.

`````markdown
## Commit message format

**Example 1**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**Example 2**
Input: Fixed bug where dates displayed incorrectly in reports
Output:
```
fix(reports): correct date formatting in timezone conversion
```

Follow this style: type(scope): brief description, then detailed explanation.
`````

Use examples when the format has nuances rules can't capture, when pattern recognition
beats rule-following, or when edge cases are easier to demonstrate than describe.

## Checklists

An explicit checklist helps the agent track progress and avoid skipping steps. Worth it
when a workflow has five or more ordered steps, or steps with validation gates.

````markdown
## Form processing workflow

Copy this checklist and check items off as you go:

- [ ] Step 1: Analyze the form (`scripts/analyze_form.py`)
- [ ] Step 2: Create field mapping (edit `fields.json`)
- [ ] Step 3: Validate mapping (`scripts/validate_fields.py`)
- [ ] Step 4: Fill the form (`scripts/fill_form.py`)
- [ ] Step 5: Verify output (`scripts/verify_output.py`)
````

Then document each step below the checklist.

## Validation loops

Do the work, run a validator, fix what it reports, repeat until it passes. One of the
highest-leverage patterns available.

```markdown
## Editing workflow

1. Make your edits
2. Run validation: `python scripts/validate.py output/`
3. If validation fails:
   - Review the error message
   - Fix the issues
   - Run validation again
4. Only proceed when validation passes
```

A reference document can serve as the validator — instruct the agent to check its work
against the reference before finalizing.

### What makes a validator useful

The error message shapes the agent's next attempt. An opaque error wastes a turn.

| Weak | Strong |
|---|---|
| "Invalid field" | "Field 'signature_date' not found. Available fields: customer_name, order_total, signature_date_signed" |
| "XML syntax error" | "Line 47: expected closing tag `</paragraph>` but found `</section>`" |
| "Missing required field" | "Required field 'customer_name' is missing. Add: `{\"customer_name\": \"value\"}`" |
| "Invalid status" | "Invalid status 'pending_review'. Valid statuses: active, paused, archived" |

Say what went wrong, what was expected, and what to try. Show the valid options.

## Plan-validate-execute

For batch or destructive operations: have the agent write an intermediate plan in a
structured format, validate it against a source of truth, and only then execute.

```markdown
## PDF form filling

1. Extract form fields: `python scripts/analyze_form.py input.pdf` → `form_fields.json`
   (every field name, type, and whether it's required)
2. Create `field_values.json` mapping each field name to its intended value
3. Validate: `python scripts/validate_fields.py form_fields.json field_values.json`
   (checks every field name exists, types are compatible, required fields present)
4. If validation fails, revise `field_values.json` and re-validate
5. Fill the form: `python scripts/fill_form.py input.pdf field_values.json output.pdf`
```

**Step 3 is the whole point**: a script that checks the plan against the source of
truth. Errors like "Field 'signature_date' not found — available fields: …" give the
agent enough to self-correct without touching the original.

Use this when operations are error-prone, changes are hard to undo, or the plan can be
verified independently of executing it.

## Conditional workflows

Guide the agent through decision points with explicit branching.

```markdown
## Document modification

Determine the modification type first:

**Creating new content?** → Creation workflow
**Editing existing content?** → Editing workflow

### Creation workflow
1. Use docx-js
2. Build the document from scratch
3. Export to .docx

### Editing workflow
1. Unpack the existing document
2. Modify the XML directly
3. Validate after each change
4. Repack
```

Use when task types need genuinely different approaches and the decision point is
clear. Don't use it to present equivalent options — see "provide defaults, not menus"
in [authoring-guidance.md](authoring-guidance.md).

## Checkpoints and error recovery

For long workflows, add checkpoints where the agent verifies progress before
continuing. This prevents cascading errors and makes failures easy to localize.

```markdown
### Phase 1: Data collection
1. Extract data from source
2. Transform to target format
3. **Checkpoint**: verify data completeness — do not continue until it passes
```

Give recoverable failures an explicit path, and cap retries:

```markdown
**If validation fails in step 2:**
- Input file corrupted → return to step 1 with different input
- Processing logic failed → fix the logic, return to step 1
- Output format wrong → fix the format, return to step 2

**If the error persists after 3 attempts:** document the error with full context,
save partial results, and report to the user with diagnostics.
```

Include error recovery when workflows touch external systems, file operations, or
network calls.

## Bundling repeated work

When iterating on a skill, compare execution traces across runs. If the agent keeps
reinventing the same logic — building a chart, parsing a format, validating output —
write a tested script once and bundle it in `scripts/`. See
[using-scripts.md](using-scripts.md).

## Anti-patterns

### Vague description

```yaml
description: Helps with documents          # the skill will never trigger reliably
```

### First or second person in the description

```yaml
description: I can help you process Excel files    # wrong
description: Processes Excel files and generates reports. Use when analyzing
             spreadsheets or .xlsx files.          # right
```

The description is injected into the system prompt. Write it in third person.

### Name that doesn't match the directory

`name` **must** equal the parent directory name. `facebook-ads/` with
`name: facebook-ads-manager` is invalid, not merely inconsistent.

### Too many options

Listing six libraries forces the agent to research and compare before it starts. Give
one default and one escape hatch.

### Deeply nested references

`SKILL.md → advanced.md → details.md → examples.md` — agents may only partially read
files reached indirectly. Keep the chain short; a router's `SKILL.md → workflow →
reference` is the practical limit.

### Windows-style paths

`scripts\helper.py` breaks cross-platform. Always `scripts/helper.py`.

### Time-sensitive content

Hardcoded years in search strings, "before August 2025, use…", and version-specific
advice with no "old patterns" section all rot silently.

### Unescaped dynamic-context syntax in examples

If a skill *documents* Claude Code's dynamic context injection **in its `SKILL.md`**, the
example itself executes at skill-load time. Writing an exclamation mark immediately
followed by a backticked command, or `@` immediately followed by a filename, triggers
execution or a file read while the skill is loading.

Insert a space and say so:

```markdown
Load current status with: ! `git status`   (remove the space before the backtick)
Review dependencies in: @ package.json     (remove the space after the @)
```

This applies to `SKILL.md`, which Claude Code renders on load. Bundled references and
workflows are opened with a file read rather than rendered, so they can show the syntax
verbatim — [claude-code-runtime.md](claude-code-runtime.md) does exactly that.
