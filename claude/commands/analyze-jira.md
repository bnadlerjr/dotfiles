---
description: Analyze a Jira issue into structured use cases using Cockburn's framework
argument-hint: "<Jira issue ID> [research document paths...]"
model: opus
allowed-tools: Read, Bash, Glob, Grep, Task, AskUserQuestion
---

# Analyze Jira

**Level 4 (Delegation)** - Fetches Jira context, combines with research documents, then delegates to use case analysis.

Take a Jira issue, gather context from Jira and any provided research documents, then produce a structured use case document using Cockburn's framework. The use case feeds directly into implementation planning and TDD.

## Variables

- **ARGUMENTS**: `$ARGUMENTS` - Jira issue ID followed by optional research document paths
- Parse ARGUMENTS:
  - First token: `ISSUE_KEY` (e.g., POPS-123)
  - Remaining tokens: `RESEARCH_DOCS` (space-separated file paths, may be empty)

## Dependencies

- **managing-jira skill**: Jira CLI operations via `jira` command (ankitpokhrel/jira-cli)
- **analyzing-use-cases skill**: Cockburn's use case framework at `~/dotfiles/claude/skills/analyzing-use-cases/SKILL.md`
- **Artifact management**: `$CLAUDE_DOCS_ROOT/projects.yaml` for metadata, output to `$CLAUDE_DOCS_ROOT/use-cases/`

## Initial Response

When invoked:

1. **If an issue key was provided**: Validate format and begin Phase 1
2. **If no issue key provided**, respond with:

```
I'll analyze a Jira issue into a structured use case using Cockburn's framework.

Usage: /analyze-jira POPS-123 [path/to/research-doc.md ...]

I'll guide you through:
1. Fetching Jira context (issue, comments, linked issues)
2. Reading any research documents you provide
3. Interactive use case analysis (classify, draft, discover extensions)
4. Writing the use case artifact
```

---

## Phase 1: Gather Jira Context

### Authentication Check

```bash
jira me
```

If this fails, inform the user to run `jira init`.

### Fetch Issue Details

```bash
# Primary issue with comments
jira issue view ${ISSUE_KEY} --comments 10

# Get raw JSON for structured parsing
jira issue view ${ISSUE_KEY} --raw
```

From the raw output, extract:
- **Summary**: Issue title
- **Description**: Full description text
- **Comments**: All comment bodies
- **Status**: Current workflow state
- **Type**: Story, Bug, Task, etc.
- **Parent**: Epic or parent issue key (if any)
- **Links**: Related/blocked issues

### Fetch Parent Context (if parent exists)

```bash
jira issue view ${PARENT_KEY}
```

### Fetch Linked Issues (for each linked issue)

```bash
jira issue view ${LINKED_KEY}
```

### Build Context Summary

Compile into a structured context block:

```
**Issue**: ${ISSUE_KEY} - ${SUMMARY}
**Type**: ${TYPE} | **Status**: ${STATUS}
**Description**: ${DESCRIPTION}
**Parent**: ${PARENT_KEY} - ${PARENT_SUMMARY} (if any)
**Linked Issues**: ${LINKED_KEYS_AND_SUMMARIES} (if any)
**Comments**: ${COMMENT_SUMMARIES}
```

---

## Phase 2: Gather Research Context

### Read Research Documents

If `RESEARCH_DOCS` is not empty, read each document FULLY using the Read tool.

For each research document, extract:
- Key discoveries and patterns
- Domain vocabulary
- Business rules and constraints
- Integration points
- Code locations referenced

### Combine Context

Merge Jira context and research findings into a single context block for use case analysis.

---

## Phase 3: Use Case Analysis

Read the `analyzing-use-cases` skill at `~/dotfiles/claude/skills/analyzing-use-cases/SKILL.md` and follow its interactive process with the combined context from Phases 1 and 2.

The skill's process is:

1. **Classify** the goal level (summary, user-goal, subfunction) — present to user, wait for confirmation
2. **Identify** scope, primary actor, stakeholders — present to user, wait for confirmation
3. **Draft** main success scenario — present to user, wait for feedback
4. **Discover** extensions at each step — present to user, ask for missing failure modes
5. **Define** preconditions and postconditions
6. **Map** stakeholder interests to non-functional concerns
7. **Verify** every acceptance criterion from the ticket is covered

**Follow the skill's interactive approach at each step. Do not dump a complete use case without interaction.**

---

## Phase 4: Write Use Case Artifact

### Gather Artifact Metadata

1. Read `$CLAUDE_DOCS_ROOT/projects.yaml` to find the matching project
2. Determine project from ISSUE_KEY's Jira project prefix or ask user
3. Populate frontmatter per artifact management guidelines

### Write the Document

1. Read the template at `~/dotfiles/claude/skills/analyzing-use-cases/templates/use-case-document.md`
2. Fill all sections from the interactive analysis — no placeholders, no TBD
3. Include TDD Mapping section (steps to tests, extensions to edge case tests)
4. Include Acceptance Criteria Coverage cross-reference
5. Add References section linking to the Jira ticket and any research documents
6. Write to `$CLAUDE_DOCS_ROOT/use-cases/use-case--${ISSUE_KEY}--<slug>.md`

### Present Final Artifact

Show the user the completed use case document path and a summary of:
- Goal level and scope
- Number of main scenario steps
- Number of extensions discovered
- Acceptance criteria coverage (all covered / gaps found)

---

## Error Handling

### Empty ISSUE_KEY

```
No Jira issue ID provided. Please provide an issue key.

Usage: /analyze-jira POPS-123 [path/to/research-doc.md ...]
```

### Authentication Failure

```
Jira authentication failed. Please run `jira init` to configure your credentials,
then try again.
```

### Issue Not Found

```
Issue ${ISSUE_KEY} was not found. Please check:
1. The issue key is correct (e.g., POPS-123, not pops-123)
2. You have permission to view this issue
3. The project key exists in your Jira instance
```

### Research Document Not Found

```
Research document not found: ${PATH}
Continuing with Jira context only. Provide a valid path to include research context.
```

---

## Example Session

```bash
# With just a Jira ticket
/analyze-jira POPS-456

# With a research document
/analyze-jira POPS-456 ~/Dropbox/vimwiki/claude-artifacts/research/research--patient-label-printing.md
```

1. Verifies Jira auth, fetches POPS-456 with comments and linked issues
2. Reads any provided research documents
3. Classifies goal level — presents to user, waits for confirmation
4. Identifies scope, actors, stakeholders — presents, waits
5. Drafts main success scenario — presents, waits for feedback
6. Discovers extensions at each step — presents, asks for missing paths
7. Defines preconditions and postconditions
8. Verifies acceptance criteria coverage
9. Writes use case artifact to `$CLAUDE_DOCS_ROOT/use-cases/`
