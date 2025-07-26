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
