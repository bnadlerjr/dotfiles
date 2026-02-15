# Claude Code Guidelines for Bob Nadler

## Critical Rules

- **MUST** follow TDD: write failing test first, then implement
- **MUST** match existing code style in the file being edited
- **MUST** include assertions to validate assumptions
- **NEVER** introduce new syntax variations (e.g., hash rockets vs colons)
- **NEVER** refactor unrelated code without explicit permission
- **NEVER** make cosmetic changes without explicit permission
- **MUST NOT** reference Claude, Anthropic, or AI in commits
- **MUST** consult domain-specific expert skill before implementing
- **MUST** review with `reviewing-code` skill after implementing
- Leave NO todos, placeholders, or missing pieces

## Skill Delegation

Use the matching skill for domain-specific work:

- Significant features/changes: `coding-workflow` skill
- TDD methodology: `practicing-tdd` skill
- Structured reasoning: `thinking-patterns` skill (or `/thinking`)
- Code review (always post-implementation): `reviewing-code` skill
- Commit messages: `writing-git-commits` skill
- Post-edit simplification: `code-simplifier` agent
- Language skills: `developing-elixir`, `developing-typescript`, `developing-bash`

## Artifacts

All research, plans, and handoffs go to `$CLAUDE_DOCS_ROOT`.
ADRs live in the repository, not the vault.
See [Artifact Management](guidelines/artifact-management.md).

## Guidelines

- [Coding Standards](guidelines/coding-standards.md)
- [Git](guidelines/git.md)
- [Communication](guidelines/communication.md)
