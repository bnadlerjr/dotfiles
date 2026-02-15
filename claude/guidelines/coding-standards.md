# Coding Standards

Critical style and discipline rules are in the root CLAUDE.md. This file
covers additional standards not listed there.

## Development

- Make changes file by file for review opportunity
- Consider security implications for all changes
- Prefer descriptive variable names over short ones

## Testing

Invoke the `practicing-tdd` skill for TDD methodology.

Additional project-level rules:
- **SHOULD** prefer sociable unit tests over heavy mocking
- **MUST** parameterize test inputs — no unexplained literals (42, "foo")
- **MUST** write tests that can fail for real defects
- **MUST** ensure test descriptions match final expect statements
- **MUST** compare to pre-computed expectations, not function output
- **MUST** follow same lint/style rules as production code
- **ALWAYS** use strong assertions: `expect(x).toEqual(1)` not
  `expect(x).toBeGreaterThanOrEqual(1)`
- Test edge cases, boundaries, and unexpected input
- Skip conditions already caught by the type checker
