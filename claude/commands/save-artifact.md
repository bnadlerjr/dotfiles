---
description: Save the document approved in this session into its artifact folder, with standard frontmatter.
argument-hint: "[ISSUE-ID | artifact path | \"one-line description\"] [type] [--qualifier <name>]"
---

# Save Artifact

Write the last document the human approved in this session to the artifact vault. `artifact-dir` finds or creates the folder, and `artifact-save` writes the file and its frontmatter. You choose the folder, the type and, when asked, the project. You never write frontmatter yourself.

## Rules

1. **Save the approved text exactly.** Use the final document as the human approved it, with every approved revision applied, word for word. Do not edit, summarize, reformat or add frontmatter to it.
2. **Approved only.** A draft, an in-progress round, or a document still waiting for review is not saved. If nothing in this session was approved, reply `Nothing approved in this session to save.` and stop.
3. **Arguments override inference.** Anything given in `$ARGUMENTS` beats what you would infer from the session.

## Workflow

### 1. Find the document

Take the most recent document the human approved in this session: a final document from a review round, or a plan approved in plan mode. Note the command or step that produced it.

### 2. Pick the type

Use the type from `$ARGUMENTS` if one is given. Otherwise infer it from what produced the document:

| Producer | Type |
|---|---|
| `interview-me` | `design` |
| `structure-solution` | `structure` |
| `outline-pull-requests` | `outline` |
| `plan-feature`, `plan-task`, a plan-mode plan | `plan` |
| `explore-codebase` | `research` |

For anything else, ask the human for the type and wait.

### 3. Pick the folder

Resolve the folder from the first of these that applies:

1. `$ARGUMENTS` holds an issue ID (`POPS-2172`): run `artifact-dir POPS-2172`.
2. `$ARGUMENTS` holds a path inside `$CLAUDE_DOCS_ROOT` (default `~/Dropbox/vimwiki/claude-artifacts`): a folder is the folder, and a file means the folder it sits in.
3. `$ARGUMENTS` holds a quoted description: run `artifact-dir --describe "<description>"`.
4. The session's input included an issue ID: run `artifact-dir <ISSUE-ID>`.
5. The session's input included the path of an existing artifact in a ticket or dated folder: use that artifact's folder.
6. Nothing applies: ask the human for a ticket ID or a one-line description of the work, wait, then use step 1 or 3.

Pass `--linear` to `artifact-dir` when the issue lives in Linear rather than Jira. Do not derive the folder from the git branch.

### 4. Check for a second artifact of the same type

List the folder. If it already holds a file of this type and the approved document is a different artifact rather than a revision of that file (for example, a plan for a second repository), use the `--qualifier` from `$ARGUMENTS`, or ask the human for one and wait. A revision is saved without a qualifier and replaces the old file.

### 5. Save

1. Create a temporary file with `mktemp --suffix=.md` and write the approved document into it with your file-writing tool.
2. Run from the repository the work belongs to:

   ```sh
   artifact-save "<folder>" <type> [--qualifier <name>] < "<temp file>"
   ```

3. If it fails with `several projects list <repo>: a, b`, ask the human which project this work belongs to, wait, and rerun with `--project <slug>`. For any other error, report it and stop.
4. Delete the temporary file.

## Report

Reply with:

- The saved path (the last line `artifact-save` printed).
- `Replaced an existing file.` when it printed a `replaced` line.
- When `artifact-dir --describe` created the folder: `New folder <name>; rename it if the slug is wrong.`
- Any warning it printed, such as a missing `JiraEpic`.
