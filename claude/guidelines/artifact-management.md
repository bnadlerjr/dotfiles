# Artifact Management

**ALWAYS APPLIES** when producing a research document, plan, or handoff —
whether via a slash command, the built-in plan tool, or ad hoc.
ADRs are the exception — see [ADRs](#adrs) below.

## Paths

- **Artifact root:** `$CLAUDE_DOCS_ROOT`
- **Research:** `$CLAUDE_DOCS_ROOT/research/`
- **Plans:** `$CLAUDE_DOCS_ROOT/plans/`
- **Handoffs:** `$CLAUDE_DOCS_ROOT/handoffs/`
- **Project registry:** `$CLAUDE_DOCS_ROOT/projects.yaml`

## Templates

Slash command skills (`/plan`, `/research`, `/handoff`) define body layout.
These rules define **where the file goes** and **what metadata it carries**.
Both layers always apply together.

## Markdown Body Formatting

Artifacts render in Obsidian, where a vault linter and the reading view can treat
a single newline *inside* a paragraph as a paragraph break. Hard-wrapped prose
then fragments into many one-line paragraphs (blank lines get inserted between
every wrapped line). Avoid this by never hard-wrapping.

Rules for the body of any `$CLAUDE_DOCS_ROOT` artifact:

- **Do not hard-wrap prose.** Write each paragraph as one physical line and let
  the editor soft-wrap. No fixed-column (e.g. 80-char) reflowing.
- **One list item = one physical line.** Don't wrap a bullet or numbered item
  across multiple lines.
- Separate block elements (paragraphs, list items, headings, code fences, tables)
  with a single blank line.
- This forbids breaks *within* a paragraph or list item — not newlines in
  general. Code fences, tables, and frontmatter keep their internal line breaks.

This applies only to Markdown written to the vault. In source code, keep matching
the surrounding file's wrapping conventions.

## Skills vs Commands

Skills must stay portable — they render output, they do not persist. Only
commands reference `$CLAUDE_DOCS_ROOT` or this guideline. A skill that hardcodes
a save path breaks anyone invoking it from a different environment.

## File Naming

`<type>--<slug>.md` where type is `research`, `plan`, or `handoff` and slug is a
kebab-case name describing what this specific artifact covers (not the project
name). A project will have many artifacts.

Examples:
- `plan--auth-token-refresh-flow.md`
- `research--token-expiry-current-state.md`
- `handoff--auth-migration-phase1-to-backend.md`

## Project Context

**Never hardcode project metadata. Always look it up.**

1. Read `$CLAUDE_DOCS_ROOT/projects.yaml` to get the list of known projects.
2. Determine which project this artifact belongs to:
   - If the user specifies a project, use that.
   - If the current repository appears in a project's `repositories` list, suggest
     that project but confirm with the user if multiple projects match.
   - If no project applies, use `area: One-off` with no project fields.
3. Copy the project's `name`, `area`, `jira_epic`, and `repositories` into the
   artifact's frontmatter.
4. If the user names a project that doesn't exist in the registry, ask whether to
   add it, then append the new entry to `projects.yaml`.

## Required Frontmatter

Every artifact MUST include the full frontmatter block. Populate it from the
project registry and the schema below.

Key rules:
- `tags` must always include `claude-artifact` plus the artifact type tag.
- `area` must be one of: `Work`, `Side Projects`, `One-off`.
- `repositories` lists every repo this artifact touches.
- `updated` must be set to today's date on every edit.
- For work artifacts, `jira_epic` is required.

```yaml
---
tags: [claude-artifact, resource, <type>] # type = research | plan | handoff
Area: [Work, Side Projects, One-off]
Created: [[2026-02-08]]                   # set once; Obsidian link format
Modified: 2026-02-08                      # update on every edit
AutoNoteMover: disable
Project: [[Auth Service Migration]]       # Obsidian link format
ProjectSlug: auth-service-migration
JiraEpic: PROJ-123                        # required when Area includes Work
Repositories: ["org/api", "org/web"]
Status: Active | Complete | Archived
---
```

## Plan Tool Integration

When using the built-in plan mode (via `EnterPlanMode`, `--plan`, or Shift+Tab):

**During plan mode:** Write plan content following the template. Skip vault frontmatter.

**After plan mode exits:** Save to `$CLAUDE_DOCS_ROOT/plans/plan--<slug>.md` with
full frontmatter. The `save-plan-artifact` hook reminds you.

## Finding Existing Artifacts

Before creating a new artifact, check for existing ones:
- `grep -rl "project_slug: <slug>" $CLAUDE_DOCS_ROOT/`
- `ls $CLAUDE_DOCS_ROOT/plans/`
- `ls $CLAUDE_DOCS_ROOT/research/`

## ADRs

ADRs live in the repository, not `$CLAUDE_DOCS_ROOT`.

- File naming: `adr-NNNN--<slug>.md` (sequential per repo).
- Use the ADR skill for content structure.
- For cross-cutting decisions, write in the primary repo and note affected repos.
