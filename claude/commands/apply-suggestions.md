---
model: opus
---

# Apply Code Review Suggestions

The following suggestions were made during a code review. Your objective is to use the appropriate agents to evaluate the suggestions and implement the changes.

$ARGUMENTS

## Process

1. **DOMAIN EXPERT**: Choose appropriate domain expertise (e.g., `developing-elixir` skill, graphql-schema-architect, etc.).
2. **DOMAIN EXPERT**: Analyzes the suggestion.
3. **EVALUATE** before implementing (see `receiving-code-review` skill for edge cases):
   - Is this technically correct for THIS codebase?
   - Does it break existing functionality?
   - Is it a YAGNI violation (unused feature)?
   - Does the reviewer have full context?

   If evaluation fails: **Push back with technical reasoning**, don't implement blindly.

4. **IMPLEMENT** the suggestion **ONLY IF EVALUATION PASSES**.
5. Run tests to confirm the suggestion works as expected.
6. **CODE REVIEW**: Use `reviewing-code` skill to review implementation.
7. **CODE REVIEW**: Use code-simplifier agent to simplify code and remove unnecessary comments.
8. **CODE REVIEW**: Use test-value-auditor agent to remove low-value tests.
