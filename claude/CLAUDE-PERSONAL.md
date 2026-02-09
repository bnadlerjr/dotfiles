# Claude Code Guidelines for Bob Nadler

## Artifact Management

**ALWAYS APPLIES.** Whenever you produce a research document, plan, or handoff —
whether via a slash command, the built-in plan tool, or ad hoc — the rules below
govern where and how the file is written. No exceptions.

**ADRs are the exception** — they live in the repository, not the vault. See the
ADR section below.

### Paths

- **Artifact root:** `$CLAUDE_DOCS_ROOT` (resolves to `~/path-to/YourVault/claude-artifacts/`)
- **Research:** `$CLAUDE_DOCS_ROOT/research/`
- **Plans:** `$CLAUDE_DOCS_ROOT/plans/`
- **Handoffs:** `$CLAUDE_DOCS_ROOT/handoffs/`
- **Project registry:** `$CLAUDE_DOCS_ROOT/projects.yaml`

### Templates

Artifact body structure comes from the existing slash command skills (e.g.
`/plan`, `/research`, `/handoff`). The skill defines the content layout.
These CLAUDE.md rules define **where the file goes** and **what metadata it
carries**. Both layers always apply together.

### File naming

`<type>--<slug>.md` where type is `research`, `plan`, or `handoff` and slug is a
kebab-case name describing what this specific artifact covers (not the project
name). A project will have many artifacts.

Examples:
- `plan--auth-token-refresh-flow.md`
- `plan--auth-session-store-cutover.md`
- `research--token-expiry-current-state.md`
- `handoff--auth-migration-phase1-to-backend.md`

### Project context

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

### Required frontmatter

Every artifact MUST include the full frontmatter block. Populate it from the
project registry and the frontmatter schema below.

Key rules:
- `tags` must always include `claude-artifact` plus the artifact type tag (`research`, `plan`, or `handoff`).
- `area` must be one of: `Work`, `Side Projects`, `One-off`.
- `repositories` lists every repo this artifact touches (e.g. `["org/api", "org/web"]`).
- `updated` must be set to today's date on every edit.
- For work artifacts, `jira_epic` is required.

#### Frontmatter schema

```yaml
---
tags: [claude-artifact, resource, <type>] # type = research | plan | handoff
Area: [Work, Side Projects, One-off]  # from projects.yaml; can be a list
Created: [[2026-02-08]]                   # set once; formatted as Obsidian link
Modified: 2026-02-08                      # update on every edit
AutoNoteMover: disable                    # disable AutoNoteMover Obsidian plugin
Project: [[Auth Service Migration]]       # from projects.yaml; formatted as Obsidian link
ProjectSlug: auth-service-migration       # from projects.yaml
JiraEpic: PROJ-123                        # required when "Work" is in Area list
Repositories: ["org/api", "org/web"]      # from projects.yaml
Status: Active | Complete | Archived      # status of the artifact
---
```

### Using the plan tool

When using the built-in `/plan` tool or `--plan` flag, you MUST:
1. Read `projects.yaml` to determine project context.
2. Write the plan file to `$CLAUDE_DOCS_ROOT/plans/` (not `.claude/plans/`).
3. Use the full plan template frontmatter.
4. Follow the naming convention: `plan--<slug>.md` where the slug describes this
   specific plan's scope, not the project name.

### Finding existing artifacts

Before creating a new artifact, check for existing ones:
```bash
# List all artifacts for a project:
grep -rl "project_slug: auth-service-migration" $CLAUDE_DOCS_ROOT/

# List by type:
ls $CLAUDE_DOCS_ROOT/plans/
ls $CLAUDE_DOCS_ROOT/research/
ls $CLAUDE_DOCS_ROOT/handoffs/

# Search by content:
grep -rl "token refresh" $CLAUDE_DOCS_ROOT/
```

## ADRs

ADRs are NOT vault artifacts. They live in the repository, not in `$CLAUDE_DOCS_ROOT`.

- File naming: `adr-NNNN--<slug>.md` (sequential per repo).
- Use the ADR skill/template for content structure.
- For cross-cutting decisions, write the ADR in the primary repo and note
  affected repos in the ADR body.

## Code Style & Conventions

### Implementation Standards
- **MUST** Follow TDD: scaffold stub → write failing test → implement
- **MUST** Write correct, bug-free, fully functional, secure, performant code
- **MUST** Match existing code style in the file being edited
- **MUST** Include assertions to validate assumptions and catch errors early
- **NEVER** introduce new syntax variations (e.g., hash rockets vs colons)
- **NEVER** refactor unrelated code without explicit permission
- **NEVER** make cosmetic changes without explicit permission
- Prefer descriptive variable names over short ones
- Focus on readability over performance unless critical
- Leave NO todos, placeholders, or missing pieces

### Error Handling
- Implement robust error handling and logging
- Always handle edge cases explicitly

## Workflow Guidelines

### Development Workflow
For significant features or changes, invoke the `coding-workflow` skill which orchestrates:
1. **Research** → `atomic-thought` for gathering information
2. **Brainstorm** → `tree-of-thoughts` or `graph-of-thoughts` for approaches
3. **Plan** → `skeleton-of-thought` then `chain-of-thought` for details
4. **Implement** → `program-of-thoughts` + `self-consistency` for verification

For all implementations:
- **MUST** consult domain-specific expert agent before implementing
- **MUST** review with `reviewing-code` skill after implementing
- **NEVER** skip the expert consultation or code review steps

### Plan Mode
Use `EnterPlanMode` for:
- New features requiring architectural decisions
- Changes affecting multiple files
- Tasks with multiple valid approaches
- Unclear requirements needing exploration

Skip plan mode only for:
- Single-line fixes, typos, obvious bugs
- Tasks with explicit, detailed instructions from user

### Before Coding
- **MUST** Ask clarifying questions for complex work
- Confirm requirements, then write code
- Think through all considerations before implementation

### During Development
- Make changes file by file for review opportunity
- Be concise - minimize prose
- Never use apologies
- Consider security implications for all changes
- Copy exact style from surrounding code

### Post-Edit Review
After completing code changes, invoke the `code-simplifier` sub-agent to review and refine the modified code for clarity and consistency.

### Information Handling
- Verify information before presenting
- If unsure, say so instead of guessing
- Check context files for current implementations
- Don't ask for confirmation of already-provided info
- Don't verify implementations visible in context
- Suggest solutions beyond initial requirements

## Agent Usage Guidelines

### Principle
Use domain-specific expert agents matching the technology stack. Agent descriptions indicate when to use each. When uncertain which agent applies, check available agents via the Task tool.

### Common Patterns
- **Elixir/Phoenix**: Use the `developing-elixir` skill (covers Phoenix, LiveView, Ecto, OTP, functional modeling, Absinthe GraphQL, ExUnit testing)
- **TypeScript/React**: Use the `developing-typescript` skill (covers TypeScript core, React architecture, GraphQL integration, testing, performance optimization), `reviewing-code` skill (Kent C. Dodds reference)
- **Shell scripting**: bash-scripting-expert
- **Code review**: `reviewing-code` skill (ALWAYS after implementation; Kent Beck reference for design review)
- **Test quality**: `reviewing-code` skill (test-quality reference), `developing-elixir` skill (testing-exunit reference)
- **Codebase exploration**: codebase-navigator

### User-Invocable Commands
- `/bugfix` - TDD-based debugging workflow
- `/plan` - Interactive implementation planning
- `/elixir-review`, `/react-review` - Multi-agent code review
- `/research` - Document codebase context
- `/implement` - Execute technical plans with verification

## Thinking Pattern Skills

### When to Invoke
**MUST** check if a thinking pattern applies before complex reasoning tasks.
Use `/thinking` to auto-select or `/thinking <pattern>` for explicit selection.

### Pattern Selection by Task Type

| Task Type | Pattern | Trigger |
|-----------|---------|---------|
| Research/understanding | `atomic-thought` | Need to combine facts from multiple areas |
| Debugging/tracing logic | `chain-of-thought` | Step-by-step problem solving |
| Calculations/data processing | `program-of-thoughts` | Generate code instead of computing mentally |
| Planning/outlining | `skeleton-of-thought` | Need high-level structure before details |
| Comparing approaches | `tree-of-thoughts` | Multiple valid solutions exist |
| High-stakes decisions | `self-consistency` | Errors would be costly, need validation |
| Synthesizing findings | `graph-of-thoughts` | Combining multiple inputs/research |

### Integration with Existing Workflow

1. **Before implementation planning**: `/thinking skeleton-of-thought` or `/thinking tree-of-thoughts`
2. **During research phase**: `/thinking atomic-thought` for decomposition
3. **When debugging**: `/thinking chain-of-thought` for systematic tracing
4. **Before finalizing approach**: `/thinking self-consistency` for validation
5. **After brainstorming**: `/thinking graph-of-thoughts` to synthesize

### Key Principle
Extended thinking handles internal reasoning. These patterns produce **visible structured output** that you can review and validate. When in doubt, invoke `/thinking` - structured reasoning is always preferable to hidden reasoning for non-trivial problems.

## Testing

### Test Requirements
- **SHOULD** Prefer sociable unit tests over heavy mocking
- **SHOULD** Unit-test complex algorithms thoroughly
- **MUST** Parameterize test inputs - no unexplained literals (42, "foo")
- **MUST** Write tests that can fail for real defects
- **MUST** Ensure test descriptions match final expect statements
- **MUST** Compare to pre-computed expectations, not function output
- **MUST** Follow same lint/style rules as production code
- **ALWAYS** Use strong assertions: `expect(x).toEqual(1)` not `expect(x).toBeGreaterThanOrEqual(1)`
- Test edge cases, boundaries, and unexpected input
- Skip conditions caught by type checker

## Git Conventions
- **MUST NOT** Reference Claude, Anthropic, or AI in commits - no "Co-Authored-By" lines, no "Claude suggested", no AI attribution of any kind
- Create feature branches like `feature/[description]`
- Never commit directly to main/master
- For commit message formatting, use the `writing-git-commits` skill (Tim Pope style)

## Communication Style
- Treat user as expert
- No feedback about understanding in comments/docs
- Focus on facts and solutions
- Encourage modular design principles
- Don't summarize changes made
- Don't suggest updates when none needed

## Key Principles
- Every rule must be actionable and specific
- Anticipate user needs proactively
- Maintain compatibility with project versions
- Don't remove unrelated functionality
- Fully implement all requested features

