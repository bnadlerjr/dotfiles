---
description: Write a Shape Up pitch (idea / draft / notes) and save it to $CLAUDE_DOCS_ROOT
argument-hint: "[rough idea | path to draft | path to notes | empty for interactive]"
model: opus
allowed-tools: Read, Write, Edit, Bash(date), Bash(test), Bash(mkdir), Bash(echo), Bash(git config:*), Bash(git remote:*), Bash(grep), AskUserQuestion, Skill
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
  - Looks like a pitch (has Problem / Appetite / Solution sections or similar) → this is a *draft to refine*
  - Looks like notes/transcript/research → this is *notes to distill*
  - Ambiguous → ask via `AskUserQuestion` which it is
- **Otherwise** → treat as a rough idea (raw text)

## Phase 2 — Invoke The Skill

Invoke the `writing-pitches` skill via the Skill tool. Pass the classified input and the detected workflow hint if you have one. Example `args` values:

```
Shape this idea into a pitch: <text>                          (rough idea)
Refine this draft pitch: <file path + contents>               (draft)
Distill these notes into a pitch: <file path + contents>      (notes)
```

The skill will:

1. Route to the appropriate workflow (shape-from-idea / refine-draft / distill-notes)
2. Shape the concept
3. Actively invoke `grilling-ideas` to stress-test the shape (this is mandatory in the skill)
4. Return the pitch as markdown in the conversation

**Do not save anything yet.** Wait for the skill to return the full pitch.

## Phase 3 — Confirm With User Before Saving

Once the skill returns the pitch markdown, present it and confirm via `AskUserQuestion`:

- Header: "Save"
- Question: "Save this pitch to your docs vault?"
- Options:
  - "Save it" → proceed to Phase 4
  - "Make edits first" → ask what to change, apply, re-present, ask again
  - "Don't save" → end without writing

## Phase 4 — Resolve Project Context

Pitches require canonical project metadata. Determine which project this pitch belongs to following `~/.claude/guidelines/artifact-management.md`.

### 4a. Detect current repository

```bash
# May or may not succeed — user might be running from a non-repo directory
CURRENT_REMOTE=$(git config --get remote.origin.url 2>/dev/null || true)
```

Normalize the remote URL to `org/repo`:

- `git@github.com:org/repo.git` → `org/repo`
- `https://github.com/org/repo.git` → `org/repo`
- `https://github.com/org/repo` → `org/repo`

If no remote detected, skip to 4c with no current-repo match.

### 4b. Match against registry

Read `$CLAUDE_DOCS_ROOT/projects.yaml`. For each project entry, check whether its `repositories` list contains the detected `org/repo`.

- **Exactly 1 match** → use that project. Present via `AskUserQuestion` for confirmation:
  - Header: "Project"
  - Question: "Save this pitch under `<Project Name>`?"
  - Options:
    - `<Project Name>` (Recommended) → use it
    - "Pick a different project" → go to multi-choice picker (see below)
    - "Create new project" → go to 4d
    - "One-off (no project)" → go to 4e

- **Multiple matches** → present all matches plus "Create new project" and "One-off" via `AskUserQuestion`. User picks.

- **Zero matches** → present `AskUserQuestion`:
  - Header: "Project"
  - Question: "No registered project matches this repo. What should I do?"
  - Options:
    - "Create new project" (Recommended) → go to 4d
    - "Pick an existing project" → list up to 4 most recently mentioned projects
    - "One-off (no project)" → go to 4e

### 4c. Fallback when no remote detected

If no git remote was detected, ask the user which project via `AskUserQuestion`: list existing projects (top 4) plus "Create new project" and "One-off".

### 4d. Create new project

Collect the following via sequential `AskUserQuestion` calls (one question at a time — these aren't independent):

1. **Project name** — free text (via "Other" on a question with placeholder options)
2. **Area** — options: `Work` / `Side Projects` / `One-off`. If `Work`, also include `Instinct` as a second tag (match existing pattern: `Area: [Work, Instinct]`).
3. **Jira epic** — only if Area includes Work. Options: "Enter epic ID" (free text via Other) / "Skip — no epic yet".

Derive `ProjectSlug` from the project name: lowercase, non-alphanumeric → `-`, collapse repeats, strip leading/trailing `-`.

Append the new entry to `$CLAUDE_DOCS_ROOT/projects.yaml` using the `Edit` tool. Append at the end of the `projects:` map, preserving 2-space indentation and a blank line before the new block:

```yaml
  <slug>:
    name: "<Project Name>"
    area: <Work | Side Projects | One-off>    # or list form: [Work, Instinct]
    jira_epic: <EPIC-ID>                        # only if provided
    repositories:
      - "<org/repo>"                            # current repo, if detected
```

Omit `jira_epic` line entirely if none; omit the `repositories` block if no current repo detected.

After appending, re-read to confirm the write succeeded.

### 4e. One-off (no project)

Skip project frontmatter fields. The output frontmatter will set `Area: One-off` and omit `Project`, `ProjectSlug`, and `JiraEpic`.

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

Prepend the canonical artifact frontmatter block to the pitch markdown before writing.

### Frontmatter schema

Use YAML list form for `tags`, `Area` (when multi-valued), and `Repositories`. Use `"[[...]]"` (quoted Obsidian links) for `Created` and `Project`. Always include `AutoNoteMover: disable`.

**For a Work pitch with a registered project:**

```yaml
---
tags:
  - claude-artifact
  - resource
  - pitch
Area:
  - Work
  - Instinct
Created: "[[YYYY-MM-DD]]"
Modified: YYYY-MM-DD
AutoNoteMover: disable
Project: "[[<Project Name>]]"
ProjectSlug: <slug>
JiraEpic: <EPIC-ID>
Repositories:
  - <org/repo>
Status: Active
---
```

**For a Side Projects pitch:**

```yaml
---
tags:
  - claude-artifact
  - resource
  - pitch
Area: Side Projects
Created: "[[YYYY-MM-DD]]"
Modified: YYYY-MM-DD
AutoNoteMover: disable
Project: "[[<Project Name>]]"
ProjectSlug: <slug>
Repositories:
  - <org/repo>
Status: Active
---
```

**For a One-off pitch:**

```yaml
---
tags:
  - claude-artifact
  - resource
  - pitch
Area: One-off
Created: "[[YYYY-MM-DD]]"
Modified: YYYY-MM-DD
AutoNoteMover: disable
Status: Active
---
```

### Rules

- `Area` is a single string for `Side Projects` and `One-off`; a YAML list for `Work` pitches (match the existing convention: `- Work` and `- Instinct`).
- `JiraEpic` is included only when the project has one registered or the user supplied one during Phase 4d. Omit the line entirely otherwise.
- `Repositories` is included when at least one repo is known (from registry or current repo). Omit the block entirely otherwise.
- `Modified` equals `Created` on first save.

### Write

Write the frontmatter + a blank line + the pitch markdown body to the target path using the `Write` tool.

After writing, report the absolute path:

```
Pitch saved to: /absolute/path/to/YYYY-MM-DD-<slug>.md
```

If Phase 4d appended a new project to `projects.yaml`, also mention:

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
