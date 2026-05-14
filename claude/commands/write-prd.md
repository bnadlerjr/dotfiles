---
description: Write a PRD from a Product Brief (or refine a draft) and save it to $CLAUDE_DOCS_ROOT
argument-hint: "[Product Brief path | PRD draft path | rough text | empty for interactive]"
model: opus
allowed-tools: Read, Write, Edit, Grep, Bash(date), Bash(test), Bash(mkdir), Bash(git config:*), Bash(git remote:*), Bash(git rev-parse:*), AskUserQuestion, Skill, Task
---

# Write A Product Requirements Document

Invokes the `writing-prds` skill to produce a PRD from a Product Brief (or refine an existing PRD draft), then saves the result to `$CLAUDE_DOCS_ROOT/prds/` with canonical artifact frontmatter per `~/.claude/guidelines/artifact-management.md`.

## Variables

- **INPUT**: `$ARGUMENTS` — may be empty (interactive), a path to a Product Brief, a path to an existing PRD draft, or raw text describing the product vision
- **CLAUDE_DOCS_ROOT**: environment variable for the docs vault. Fallback: `~/claude-docs`
- **REGISTRY**: `$CLAUDE_DOCS_ROOT/projects.yaml`
- **OUTPUT_DIR**: `$CLAUDE_DOCS_ROOT/prds`
- **OUTPUT_FILENAME**: `YYYY-MM-DD-<slug>.md` — date from `date +%F`, slug derived from PRD product name

## Phase 1 — Classify Input

Inspect `$ARGUMENTS`:

- **Empty** → invoke the skill with no input; it will ask the user for a Product Brief
- **Starts with `/`, `~`, or `./`** → path. Use `Read` to load it. Inspect contents to decide:
  - Has PRD section headers (`## High-Level Requirements`, `## Use Case Compendium`, `## Milestone Definitions`) → this is a *draft PRD to refine*
  - Has Product Brief structure (north star scenarios, personas, thesis/antithesis) → this is a *brief to convert*
  - Ambiguous → ask via `AskUserQuestion` which it is
- **Otherwise** → treat as a rough product description (raw text)

## Phase 2 — Invoke The Skill

Invoke the `writing-prds` skill via the Skill tool. Pass the classified input and the detected workflow hint. Example `args` values:

```
Build a PRD from this Product Brief: <file path + contents>     (brief to convert)
Refine this draft PRD: <file path + contents>                   (draft to refine)
Build a PRD from this rough product description: <text>         (rough idea)
```

**Do not save anything yet.** Wait for the skill to return the full PRD.

## Phase 3 — Confirm With User Before Saving

Once the skill returns the PRD markdown, present it and confirm via `AskUserQuestion`:

- Header: "Save"
- Question: "Save this PRD to your docs vault?"
- Options:
  - "Save it" → proceed to Phase 4
  - "Make edits first" → for small wording changes, apply them directly via `Edit` on the PRD markdown in-conversation; for structural changes (missing milestones, wrong scoping, missing personas, milestone over-prioritization), re-invoke the `writing-prds` skill with the user's feedback as `args`. Re-present, ask again.
  - "Don't save" → end without writing

## Phase 4 — Resolve Project Context

Resolve project context per `~/.claude/guidelines/artifact-management.md` (sections "Project Context" and "File Naming"). Use the standard procedure: detect current repo via git, match against `$CLAUDE_DOCS_ROOT/projects.yaml`, confirm with the user, offer create-new or one-off if no match.

Implementation notes specific to this command:

- **Repo-detection guard**: before running `git config --get remote.origin.url`, verify the cwd is inside a git work tree via `git rev-parse --is-inside-work-tree` (nonzero exit → no repo, skip straight to the "no remote" branch of the guideline).
- **Creating a new project**: when the guideline calls for collecting project name / area / jira_epic, gather all three in a single multi-question `AskUserQuestion` call rather than three sequential ones.
- **One-off**: when no project applies, the output frontmatter sets `Area: One-off` and omits `Project`, `ProjectSlug`, and `JiraEpic`.

Outputs needed for Phase 6 frontmatter: project name, slug, area, jira_epic (optional), repositories (optional).

## Phase 5 — Determine Output Path

Resolve the target directory:

```bash
TARGET_ROOT="${CLAUDE_DOCS_ROOT:-$HOME/claude-docs}"
TARGET_DIR="$TARGET_ROOT/prds"
DATE=$(date +%F)
mkdir -p "$TARGET_DIR"
```

If `$CLAUDE_DOCS_ROOT` is unset, mention the fallback to the user before writing.

Build the filename:

1. Extract the product name from the first `# Product Requirements Document: <name>` line of the returned markdown. Take everything after the colon as `<name>`.
2. Slugify `<name>`: lowercase, spaces → `-`, strip non-alphanumeric-except-hyphens, collapse repeats
3. Filename: `$DATE-$SLUG.md` (e.g., `2026-05-14-helpy.md`)
4. On collision, suffix `-2`, `-3`, etc. Never overwrite silently.

## Phase 6 — Write With Canonical Frontmatter

Emit canonical artifact frontmatter per `~/.claude/guidelines/artifact-management.md` (section "Required Frontmatter"). Use artifact type `prd` (i.e., `tags: [claude-artifact, resource, prd]`). Populate `Area`, `Project`, `ProjectSlug`, `JiraEpic` (when Work), `Repositories` (when known), and `Status: Active` from the project context resolved in Phase 4.

PRD-specific notes:

- Artifact type tag is `prd` — the guideline's examples show `research | plan | handoff` but the schema accommodates `prd` identically.
- Initial status is `Status: Active`.
- Preserve the frontmatter asymmetry the guideline already encodes: `Created` is a quoted Obsidian wikilink (e.g., `Created: "[[2026-05-14]]"`), `Modified` is a bare ISO date (e.g., `Modified: 2026-05-14`). On first save, both reflect today.

### Write

Write the frontmatter + a blank line + the PRD markdown body to the target path using the `Write` tool.

After writing, report the absolute path:

```
PRD saved to: /absolute/path/to/YYYY-MM-DD-<slug>.md
```

If Phase 4 appended a new project to `projects.yaml`, also mention:

```
Registered new project in projects.yaml: <slug>
```

## Error Handling

### Path given but file doesn't exist

```
I couldn't find <path>. Did you mean a different file, or is this a rough
product description I should build a PRD from?
```

### Skill returns something that isn't a PRD

If the returned content lacks the expected sections (specifically `## Use Case Compendium`, plus typically `## High-Level Requirements` and `## Milestone Definitions`), surface this to the user rather than saving a malformed PRD. Offer to re-invoke the skill or edit manually.

### projects.yaml missing or unreadable

If `$CLAUDE_DOCS_ROOT/projects.yaml` does not exist, tell the user and offer to proceed as a One-off PRD. Do not silently skip project resolution.

### File already exists at target path

Suffix the filename with `-2`, `-3`, etc. Do not overwrite silently.

## Example Invocations

```bash
# Interactive — skill will ask for the Product Brief
/write-prd

# From a rough product description
/write-prd Helpy is an AI assistant embedded on the Kabletown support page

# From a Product Brief
/write-prd ~/claude-docs/briefs/2026-05-01-helpy.md

# Refine an existing PRD draft
/write-prd ~/drafts/helpy-prd.md
```
