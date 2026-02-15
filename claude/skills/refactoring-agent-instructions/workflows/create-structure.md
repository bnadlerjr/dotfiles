# Phase 4: Create File Structure

Create the `guidelines/` directory and write all files — both category files and the refactored root file.

## Inputs

- Root content list from Phase 2
- Final category map from Phase 3
- Original root filename (e.g., `CLAUDE.md`, `AGENTS.md`)

## Procedure

### 1. Create Directory

```bash
mkdir -p guidelines
```

### 2. Write Category Files

For each category in the final category map, write a file in `guidelines/`.

Use the template from `references/category-templates.md`:

```markdown
# [Category Title]

[Instructions organized by sub-topic, each actionable and specific.]

## [Sub-topic 1]

- [Instruction]
- [Instruction]

## [Sub-topic 2]

- [Instruction]
- [Instruction]
```

Rules for category files:
- **No frontmatter** — these are plain markdown
- **Title matches filename** — `testing.md` has `# Testing`
- **Self-contained** — each file stands alone without needing other category files
- **No cross-references** between category files
- **Actionable only** — every line is a directive, not commentary
- **Sub-topic headings** when a category has distinct clusters (3+ instructions on a sub-topic)

### 3. Write Root File

Rewrite the root agent instruction file to be minimal. Preserve the original filename.

Root file template:

```markdown
# [Project Name]

[One-line project description.]

## Commands

- **Build**: `[command]`
- **Test**: `[command]`
- **Lint**: `[command]`
- **Format**: `[command]`

## Critical Rules

- [Universal rule 1]
- [Universal rule 2]
- [Critical override]

## Guidelines

Detailed guidelines are organized by topic:

- [Code Style](guidelines/code-style.md)
- [Testing](guidelines/testing.md)
- [Git Workflow](guidelines/git-workflow.md)
- [Architecture](guidelines/architecture.md)
- [etc.]
```

Rules for the root file:
- **Under 50 lines** — this is a hard limit
- **Links use relative paths** — `guidelines/testing.md`, not absolute paths
- **Commands section only if non-standard** — skip if project uses default commands
- **Critical Rules section only if there are genuine overrides**
- **No detailed instructions** — everything detailed lives in `guidelines/`

### 4. Handle Multiple Source Files

If instructions were gathered from multiple source files (e.g., `CLAUDE.md` + `AGENTS.md` + `.cursorrules`):

1. Choose the primary root file (prefer `CLAUDE.md` for Claude Code projects)
2. Consolidate into the single root file + `guidelines/`
3. **Do not delete** the other source files yet — that happens in Phase 5 with user approval

### 5. Verify Links

After writing all files, verify:

```
For each link in the root file:
  - Check that the target file exists in guidelines/
  - Check that the link text matches the file's title
```

Report any broken links before proceeding.

### 6. Verify Line Count

Count lines in the root file. If over 50:
1. Identify what can be moved to a category file
2. Tighten wording
3. Rewrite until under 50 lines

## Outputs

- `guidelines/` directory with all category files written
- Refactored root file written
- Link verification report
- Line count confirmation

## Transition

When all files are written and verified, proceed to Phase 5: Prune Redundant.
