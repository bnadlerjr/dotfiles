---
description: Write a Shape Up pitch (idea / draft / notes) and save it to $CLAUDE_DOCS_ROOT
argument-hint: "[rough idea | path to draft | path to notes | empty for interactive]"
model: opus
allowed-tools: Read, Write, Edit, Grep, Bash(date), Bash(test), Bash(mkdir), Bash(git config:*), Bash(git remote:*), Bash(git rev-parse:*), AskUserQuestion, Skill, Task
---

# Write A Shape Up Pitch

Invokes the `writing-pitches` skill to shape and draft a pitch, then saves the result to `$CLAUDE_DOCS_ROOT/pitches/` with canonical artifact frontmatter per `~/.claude/guidelines/artifact-management.md`.

## Variables

- **INPUT**: `$ARGUMENTS` — may be raw text (rough idea), a path to a draft pitch, a path to notes, or empty
- **CLAUDE_DOCS_ROOT**: environment variable for the docs vault. Fallback: `~/claude-docs`
- **REGISTRY**: `$CLAUDE_DOCS_ROOT/projects.yaml`
- **OUTPUT_DIR**: `$CLAUDE_DOCS_ROOT/pitches`
- **OUTPUT_FILENAME**: `YYYY-MM-DD-<slug>.md` — date from `date +%F`, slug derived from pitch title

## Phase 1 — Classify Input

Inspect `$ARGUMENTS`:

- **Empty** → invoke the skill with no input; it will ask the user what they have
- **Starts with `/`, `~`, or `./`** → path. Use `Read` to load it. Inspect contents to decide:
  - Has the standard pitch headers (Problem / Appetite / Solution / Rabbit Holes / No-gos) → this is a *draft to refine*
  - Lacks the standard pitch headers (Problem / Appetite / Solution / Rabbit Holes / No-gos) → treat as *notes to distill*
  - Ambiguous → ask via `AskUserQuestion` which it is
- **Otherwise** → treat as a rough idea (raw text)

## Phase 2 — Invoke The Skill

Invoke the `writing-pitches` skill via the Skill tool. Pass the classified input and the detected workflow hint if you have one. Example `args` values:

```
Shape this idea into a pitch: <text>                          (rough idea)
Refine this draft pitch: <file path + contents>               (draft)
Distill these notes into a pitch: <file path + contents>      (notes)
```

**Do not save anything yet.** Wait for the skill to return the full pitch.

## Phase 3 — Confirm With User Before Saving

Once the skill returns the pitch markdown, present it and confirm via `AskUserQuestion`:

- Header: "Save"
- Question: "Save this pitch to your docs vault?"
- Options:
  - "Save it" → proceed to Phase 4
  - "Make edits first" → for small wording changes, apply them directly via `Edit` on the pitch markdown in-conversation; for structural changes (missing rabbit holes, wrong appetite, wrong shape), re-invoke the `writing-pitches` skill with the user's feedback as `args`. Re-present, ask again.
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
TARGET_DIR="$TARGET_ROOT/pitches"
DATE=$(date +%F)
mkdir -p "$TARGET_DIR"
```

If `$CLAUDE_DOCS_ROOT` is unset, mention the fallback to the user before writing.

Build the filename:

1. Extract the pitch title from the first `# <title>` line of the returned markdown
2. Slugify: lowercase, spaces → `-`, strip non-alphanumeric-except-hyphens, collapse repeats
3. Filename: `$DATE-$SLUG.md` (e.g., `2026-04-24-stale-pr-visibility.md`)
4. On collision, suffix `-2`, `-3`, etc. Never overwrite silently.

## Phase 6 — Write With Canonical Frontmatter

Emit canonical artifact frontmatter per `~/.claude/guidelines/artifact-management.md` (section "Required Frontmatter"). Use artifact type `pitch` (i.e., `tags: [claude-artifact, resource, pitch]`). Populate `Area`, `Project`, `ProjectSlug`, `JiraEpic` (when Work), `Repositories` (when known), and `Status: Active` from the project context resolved in Phase 4.

Pitch-specific notes:

- Artifact type tag is `pitch` — the guideline's examples show `research | plan | handoff` but the schema accommodates `pitch` identically.
- Initial status is `Status: Active`.
- Preserve the frontmatter asymmetry the guideline already encodes: `Created` is a quoted Obsidian wikilink (e.g., `Created: "[[2026-04-24]]"`), `Modified` is a bare ISO date (e.g., `Modified: 2026-04-24`). On first save, both reflect today.

### Write

Write the frontmatter + a blank line + the pitch markdown body to the target path using the `Write` tool.

After writing, report the absolute path:

```
Pitch saved to: /absolute/path/to/YYYY-MM-DD-<slug>.md
```

If Phase 4 appended a new project to `projects.yaml`, also mention:

```
Registered new project in projects.yaml: <slug>
```

## Error Handling

### Path given but file doesn't exist

```
I couldn't find <path>. Did you mean a different file, or is this a rough
idea I should shape from scratch?
```

### Skill returns something that isn't a pitch

If the returned content lacks the expected sections (Problem / Appetite / Solution / Rabbit Holes / No-gos), surface this to the user rather than saving a malformed pitch. Offer to re-invoke the skill or edit manually.

### projects.yaml missing or unreadable

If `$CLAUDE_DOCS_ROOT/projects.yaml` does not exist, tell the user and offer to proceed as a One-off pitch. Do not silently skip project resolution.

### File already exists at target path

Suffix the filename with `-2`, `-3`, etc. Do not overwrite silently.

## Example Invocations

```bash
# Interactive — skill will ask what the user has
/shape-pitch

# Rough idea
/shape-pitch Engineering leads can't see which PRs are stale for >3 days

# Draft to refine
/shape-pitch ~/drafts/stale-pr-pitch.md

# Notes to distill
/shape-pitch ~/meetings/2026-04-22-pr-pain.md
```
