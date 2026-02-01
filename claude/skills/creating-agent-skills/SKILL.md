---
name: creating-agent-skills
description: Expert guidance for creating, writing, and refining Claude Code Skills. Use when working with SKILL.md files, authoring new skills, improving existing skills, or understanding skill structure and best practices.
---

# Creating Agent Skills

This skill teaches how to create effective Claude Code Skills following Anthropic's official specification.

## Quick Start

Create a new skill in `~/.claude/skills/`:

```bash
mkdir -p ~/.claude/skills/my-skill-name
```

```markdown
# ~/.claude/skills/my-skill-name/SKILL.md
---
name: my-skill-name
description: Generates weekly status reports from git logs. Use when the user asks for status updates, weekly reports, or standup summaries.
---

# My Skill Name

## Quick Start
Run `git log --since="1 week ago"` and summarize changes by author.

## Instructions
1. Gather commits from the past week
2. Group by author and category (feature, fix, chore)
3. Summarize in bullet points

## Examples
**Input:** "Generate my weekly status"
**Output:**
- **Features:** Added user authentication (3 commits)
- **Fixes:** Resolved login timeout issue
- **Chores:** Updated dependencies
```

## Relationship to Prompt Writing

Skills are prompts packaged for Claude Code. For foundational prompt engineering—including the seven levels of complexity, composable sections, and the Input→Workflow→Output pattern—see the [writing-prompts](../writing-prompts/SKILL.md) skill.

This skill focuses on *packaging* prompts as skills:
- YAML frontmatter for discovery
- Progressive disclosure via reference files
- Claude Code tool integration

## Core Principles

### 1. Skills Are Prompts

All prompting best practices apply. Be clear, be direct. Assume Claude is smart - only add context Claude doesn't have.

### 2. Standard Markdown Format

Use YAML frontmatter + markdown body. **No XML tags** - use standard markdown headings.

```markdown
---
name: my-skill-name
description: What it does and when to use it
---

# My Skill Name

## Quick Start
Immediate actionable guidance...

## Instructions
Step-by-step procedures...

## Examples
Concrete usage examples...
```

### 3. Progressive Disclosure

Keep SKILL.md under 500 lines. Split detailed content into reference files. Load only what's needed.

```
my-skill/
├── SKILL.md              # Entry point (required)
├── reference.md          # Detailed docs (loaded when needed)
├── examples.md           # Usage examples
└── scripts/              # Utility scripts (executed, not loaded)
```

### 4. Effective Descriptions

The description field enables skill discovery. Include both what the skill does AND when to use it. Write in third person.

**Good:**
```yaml
description: Extracts text and tables from PDF files, fills forms, merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Bad:**
```yaml
description: Helps with documents
```

## Skill Structure

### Required Frontmatter

| Field | Required | Max Length | Description |
|-------|----------|------------|-------------|
| `name` | Yes | 64 chars | Lowercase letters, numbers, hyphens only |
| `description` | Yes | 1024 chars | What it does AND when to use it |
| `allowed-tools` | No | - | Tools Claude can use without asking |
| `model` | No | - | Specific model to use |

### Naming Conventions

Use **gerund form** (verb + -ing) for skill names:

- `processing-pdfs`
- `analyzing-spreadsheets`
- `generating-commit-messages`
- `reviewing-code`

Avoid: `helper`, `utils`, `tools`, `anthropic-*`, `claude-*`

### Body Structure

Use standard markdown headings:

```markdown
# Skill Name

## Quick Start
Fastest path to value...

## Instructions
Core guidance Claude follows...

## Examples
Input/output pairs showing expected behavior...

## Advanced Features
Additional capabilities (link to reference files)...

## Guidelines
Rules and constraints...
```

## What Would You Like To Do?

1. **Create new skill** - Build from scratch
2. **Audit existing skill** - Check against best practices
3. **Add component** - Add workflow/reference/example
4. **Get guidance** - Understand skill design

## Creating a New Skill

### Step 1: Choose Type

**Simple skill (single file):**
- Under 500 lines
- Self-contained guidance
- No complex workflows

**Progressive disclosure skill (multiple files):**
- SKILL.md as overview
- Reference files for detailed docs
- Scripts for utilities

### Step 2: Create SKILL.md

```markdown
---
name: formatting-sql
description: Formats SQL queries with consistent style and indentation. Use when the user has messy SQL, asks to format queries, or mentions SQL style.
---

# Formatting SQL

## Quick Start

Paste your SQL and I'll format it with consistent indentation, uppercase keywords, and aligned clauses.

## Instructions

1. Uppercase all SQL keywords (SELECT, FROM, WHERE, JOIN)
2. Place each major clause on its own line
3. Indent subqueries by 2 spaces
4. Align column lists vertically
5. Add blank lines between CTEs

## Examples

**Input:**
```sql
select u.id,u.name,o.total from users u join orders o on u.id=o.user_id where o.total>100
```

**Output:**
```sql
SELECT
  u.id,
  u.name,
  o.total
FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.total > 100
```

## Guidelines

- Preserve existing comments
- Don't change query logic, only formatting
```

### Step 3: Add Reference Files (If Needed)

Link from SKILL.md to detailed content:

```markdown
For API reference, see [REFERENCE.md](REFERENCE.md).
For form filling guide, see [FORMS.md](FORMS.md).
```

Keep references **one level deep** from SKILL.md.

### Step 4: Add Scripts (If Needed)

Scripts execute without loading into context:

```markdown
## Utility Scripts

Extract fields:
```bash
python scripts/analyze.py input.pdf > fields.json
```
```

### Step 5: Test With Real Usage

1. Test with actual tasks, not test scenarios
2. Observe where Claude struggles
3. Refine based on real behavior
4. Test with Haiku, Sonnet, and Opus

## Auditing Existing Skills

Check against this rubric:

- [ ] Valid YAML frontmatter (name + description)
- [ ] Description includes trigger keywords
- [ ] Uses standard markdown headings (not XML tags)
- [ ] SKILL.md under 500 lines
- [ ] References one level deep
- [ ] Examples are concrete, not abstract
- [ ] Consistent terminology
- [ ] No time-sensitive information
- [ ] Scripts handle errors explicitly

## Common Patterns

### Template Pattern

Provide output templates for consistent results:

```markdown
## Report Template

# Code Review: {filename}

## Summary
{One paragraph describing overall code quality and main concerns}

## Issues Found
- **Line {n}:** {description of issue}
- **Line {n}:** {description of issue}

## Recommendations
1. Extract {function_name} to reduce complexity
2. Add error handling for {edge_case}
```

### Workflow Pattern

For complex multi-step tasks:

```markdown
## Database Migration Workflow

1. **Backup the database**
   ```bash
   pg_dump -Fc mydb > backup_$(date +%Y%m%d).dump
   ```

2. **Run migration in a transaction**
   ```bash
   psql mydb -c "BEGIN; \i migration.sql; -- verify results before COMMIT"
   ```

3. **Validate data integrity**
   ```bash
   psql mydb -c "SELECT COUNT(*) FROM users WHERE email IS NULL"
   ```
   Expected: 0 rows

4. **Commit or rollback**
   - If validation passes: `COMMIT;`
   - If validation fails: `ROLLBACK;` and restore from backup
```

### Conditional Pattern

Guide through decision points:

```markdown
## Choose Your Approach

**Creating new content?** Follow "Creation workflow" below.
**Editing existing?** Follow "Editing workflow" below.
```

## Anti-Patterns to Avoid

- **XML tags in body** - Use markdown headings instead
- **Vague descriptions** - Be specific with trigger keywords
- **Deep nesting** - Keep references one level from SKILL.md
- **Too many options** - Provide a default with escape hatch
- **Windows paths** - Always use forward slashes
- **Punting to Claude** - Scripts should handle errors
- **Time-sensitive info** - Use "old patterns" section instead

## Reference Files

For detailed guidance, see:

- [official-spec.md](references/official-spec.md) - Anthropic's official skill specification
- [best-practices.md](references/best-practices.md) - Skill authoring best practices

## Success Criteria

A well-structured skill:
- Has valid YAML frontmatter with descriptive name and description
- Uses standard markdown headings (not XML tags)
- Keeps SKILL.md under 500 lines
- Links to reference files for detailed content
- Includes concrete examples with input/output pairs
- Has been tested with real usage

Sources:
- [Agent Skills - Claude Code Docs](https://code.claude.com/docs/en/skills)
- [Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [GitHub - anthropics/skills](https://github.com/anthropics/skills)
