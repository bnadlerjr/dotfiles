---
model: opus
---

# Apply Code Review Suggestions

The following suggestions were made during a code review. Your objective is to use the appropriate agents to evaluate the suggestions and implement the changes.

$ARGUMENTS

## Process
1. **DOMAIN EXPERT**: Choose appropriate domain expert agents (e.g., elixir-otp-expert, graphql-schema-architect, etc.).
2. **DOMAIN EXPERT**: Analyzes the suggestion.
3. Implement the suggestion **ONLY IF IT MAKES SENSE**.
4. Run tests to confirm the suggestion works as expected.
5. **CODE REVIEW**: Use pragmatic-code-reviewer agent to review implementation.
6. **CODE REVIEW**: Use spurious-comment-remover agent to remove unnecessary comments.
7. **CODE REVIEW**: Use test-value-auditor agent to remove low-value tests.
