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
1. For ANY new feature/fix:
   - First: Research with general-purpose agent if needed
   - Second: Consult domain expert agent for approach
   - Third: Implement with TDD
   - Fourth: Review with pragmatic-code-reviewer

2. NEVER skip the expert consultation or code review steps

### Before Coding
- **MUST** Ask clarifying questions for complex work
- **SHOULD** Draft and confirm approach if ≥ 2 solutions exist
- **SHOULD** List pros/cons for multiple approaches
- Confirm requirements, then write code
- Think hard through all considerations before implementation

### During Development
- Make changes file by file for review opportunity
- Be concise - minimize prose
- Never use apologies
- Consider security implications for all changes
- Copy exact style from surrounding code

### Information Handling
- Verify information before presenting
- If unsure, say so instead of guessing
- Check context files for current implementations
- Don't ask for confirmation of already-provided info
- Don't verify implementations visible in context
- Suggest solutions beyond initial requirements

## Agent Usage Guidelines

### MUST Use Specialized Agents
- **Before implementing**: Use domain-specific expert agents (e.g., elixir-phoenix-expert, typescript-react-expert) to plan approach
- **After implementing**: Use pragmatic-code-reviewer for all code changes
- **For complex tasks**: Use general-purpose agent for multi-step research

### Agent Selection
- Elixir/Phoenix work → elixir-phoenix-expert
- TypeScript/React work → typescript-react-expert
- Ruby/Rails work → ruby-rails-expert
- Python scripting → python-automation-expert
- Shell scripting → bash-scripting-expert
- Code review → pragmatic-code-reviewer (ALWAYS after implementation)
- GraphQL schema design → graphql-schema-architect

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
- **SHOULD NOT** Reference Claude or Anthropic in commits
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
