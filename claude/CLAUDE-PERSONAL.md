# Claude Code Guidelines for Bob Nadler

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
- **Codebase exploration**: codebase-search-navigator, serena-codebase-locator

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

## Claude Docs Git Metadata Resolution

When a command or agent needs to retrieve docs metadata, it **MUST** use the
custom `git metadata` command to resolve the correct metadata.

### Output Fields
- `Current Date/Time (TZ)` - Timestamp with timezone
- `Current Git Commit Hash` - Full commit SHA
- `Current Branch Name` - Active branch
- `Repository Name` - Project name
- `Area` - Project grouping
- `Timestamp For Filename` - Formatted for filenames (YYYY-MM-DD_HH-MM-SS)

### When to Use
**ALWAYS** run `git metadata` when:
1. Creating new plan/research/ticket documents (use `Timestamp For Filename`)
2. Including commit context in documents (use `Current Git Commit Hash`)
3. Referencing the current branch in documentation

### Example Usage
```bash
# Get metadata before creating a document
git metadata

# Parse specific field
TIMESTAMP=$(git metadata | grep "Timestamp For Filename" | cut -d: -f2 | tr -d ' ')
```

## Claude Docs Path Resolution

Research, plans, and tickets are stored in a centralized location outside of project repositories.

### Path Resolution
**MUST** use the `claude-docs-path` script to resolve docs locations:
```bash
claude-docs-path              # Base docs directory for current project
claude-docs-path plans        # Plans subdirectory
claude-docs-path research     # Research subdirectory
claude-docs-path tickets      # Tickets subdirectory
claude-docs-path architecture # Architecture subdirectory
claude-docs-path handoffs     # Handoffs subdirectory
```

### Usage in Commands
When reading or writing docs (plans, research, tickets):
1. Run `claude-docs-path <type>` to get the correct directory
2. Use the returned path for all file operations
3. **NEVER** hardcode `.claude/docs/` - always use the script

### Examples
```bash
# Get path for writing a new plan
PLANS_DIR=$(claude-docs-path plans)
# Write to: $PLANS_DIR/2025-01-15-feature-name.md

# Get path for reading research
RESEARCH_DIR=$(claude-docs-path research)
# Read from: $RESEARCH_DIR/2025-01-10-topic.md
```

### Environment Setup
The user has configured `CLAUDE_DOCS_ROOT` to point to their Obsidian vault.
If the variable is unset, the script falls back to `.claude/docs/` (project-local).
