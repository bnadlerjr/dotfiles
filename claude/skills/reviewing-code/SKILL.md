---
name: reviewing-code
description: Pragmatic code review that balances quality with real-world constraints. Use when code has been written or modified and needs review - after implementing features, completing refactors, or before merging PRs. Focuses on catching actual problems rather than enforcing theoretical purity.
---

# Reviewing Code

Practical code review focused on maintainability, readability, and catching real problems.

## Invocation

**Always run code reviews in a separate agent** to avoid polluting the main context.

Use the Task tool with `subagent_type: "general-purpose"`:

```
Task tool:
  subagent_type: general-purpose
  description: "Review code changes"
  prompt: |
    Review the following code changes using the reviewing-code skill methodology.

    Read the skill at: ~/.claude/skills/reviewing-code/SKILL.md

    Files to review:
    - [list files or use "git diff" output]

    Plan reference (if applicable):
    - [path to implementation plan]

    Focus areas:
    - [specific concerns or "general review"]

    Return a structured review with:
    1. Summary (2-3 sentences)
    2. Critical Issues (must fix, with file:line references)
    3. Suggestions (nice to have)
    4. Questions (clarifications needed)
```

### Quick Invocation Examples

**Review staged changes:**
```
Task: general-purpose
prompt: "Review staged git changes. Run `git diff --cached` to see changes. Use reviewing-code skill methodology. Return Critical Issues and Suggestions only."
```

**Review specific files:**
```
Task: general-purpose
prompt: "Review src/auth/middleware.ts and src/auth/types.ts. Focus on security and error handling. Use reviewing-code skill methodology."
```

**Multi-agent review (complex PRs):**
```
Launch in parallel:
- Task: general-purpose, prompt: "Review using Kent Beck style (see ~/.claude/skills/reviewing-code/references/kent-beck.md)"
- Task: general-purpose, prompt: "Review test quality (see ~/.claude/skills/reviewing-code/references/test-quality.md)"
- Task: general-purpose, prompt: "Review for [stack-specific concerns]"

Then synthesize findings using graph-of-thoughts pattern.
```

---

## Review Methodology

The following sections define HOW to conduct reviews. Reviewer agents should read and follow this methodology.

### Core Principles

- **Readability trumps cleverness** - If the code is easy to follow, it's probably good enough
- **Be conservative with refactoring** - Only recommend changes with compelling, concrete benefits
- **Focus on actual problems** - Bugs, maintenance headaches, security issues
- **Respect existing patterns** - Consistency over imposing ideal patterns
- **Distinguish severity clearly** - "Must fix" vs "consider improving"

### Review Process

#### 1. Initial Assessment

Read through the code to understand its purpose. Ask yourself: Can I follow what this is doing without difficulty? If yes, lean toward approval while still checking for specific issues.

#### 2. Plan Alignment (When Applicable)

If there's an implementation plan or requirements document:
- Compare implementation against the original plan
- Identify deviations - are they justified improvements or problematic departures?
- Verify all planned functionality was implemented

#### 3. Function/Method Analysis

- **Complexity**: Flag excessive nesting (>3 levels) or too many branches
- **Data structures**: Would parsers, trees, stacks, queues, or state machines make it clearer?
- **Parameters**: Look for unused parameters that should be removed
- **Testability**: Can this be tested without mocking databases or external APIs?
- **Dependencies**: Identify hidden dependencies that should be explicit
- **Naming**: Clear and consistent with the codebase?

#### 4. Class/Module Review (OO Code)

- Single responsibility - does the class have one clear purpose?
- Method cohesion - do all methods belong together?
- Inheritance vs composition - appropriate choice?
- Dependency injection - are dependencies injected rather than created internally?
- Minimal public interface - well-defined API?

#### 5. Code Smell Detection

Flag these patterns:
- Functions over 50 lines (unless algorithmically necessary)
- Duplicate code appearing 3+ times
- Mixed levels of abstraction in the same function
- Comments explaining WHAT instead of WHY
- Magic numbers and strings
- Overly generic names (`handle_data`, `process_item`)

#### 6. Extraction Recommendations

Only suggest extracting when:
- Code is actually used in multiple places (true DRY violation)
- Extraction would make a complex function significantly easier to test
- Extensive comments are needed to follow the original
- A clear, reusable abstraction is waiting to emerge

#### 7. Language-Specific Patterns

- **Functional**: Missed opportunities for map/filter/reduce?
- **OO**: Anemic domain models or god objects?
- **Dynamic**: Runtime type safety issues?
- **All**: Consistent and complete error handling?

#### 8. Performance and Security

- Only flag obvious performance issues (N+1 queries, exponential algorithms)
- Look for common security mistakes (SQL injection, unvalidated input, exposed secrets)
- Avoid premature optimization - recommend profiling first

### Output Format

Structure reviews as follows:

### Summary
Brief overview of the code's purpose and overall quality.

### Critical Issues
Must-fix problems that could cause bugs, security issues, or severe maintenance problems. Include file path and line number.

### Suggestions
Improvements that would enhance readability or maintainability but aren't critical.

### Questions
Clarifications needed about business logic or design decisions.

### Positive Observations
What's done well (when applicable). Keep brief.

### Communication Style

- Start with what works well before addressing issues
- Provide specific, actionable examples when suggesting alternatives
- Acknowledge when multiple valid approaches exist
- Ask clarifying questions for complex business logic
- Focus feedback on the code, never make it personal
- Frame suggestions constructively: "Consider..." or "What if..."

### Issue Categories

| Category | Description | Action |
|----------|-------------|--------|
| **Critical** | Bugs, security vulnerabilities, data loss risks | Must fix before merge |
| **Important** | Significant maintenance burden, unclear logic | Should fix |
| **Suggestion** | Readability improvements, minor optimizations | Nice to have |

### When NOT to Nitpick

Skip feedback on:
- Style preferences already handled by linters
- Minor naming variations within acceptable range
- Code that works and is readable, even if you'd write it differently
- Theoretical improvements with no practical benefit

### Test Quality Review

When reviewing test code, evaluate whether each test provides genuine value. Low-value tests slow down suites and create maintenance burden without preventing regressions.

**Quick Assessment:**
- Does this test prevent a real regression?
- Could this test ever catch a real bug?
- Is this testing behavior or implementation?

**Common Low-Value Patterns:**
- Tests that break on refactor without behavior change (implementation testing)
- Multiple tests covering the same behavior (duplicate coverage)
- Tests where everything is mocked except trivial logic (over-mocking)
- Tests of getters/setters, direct delegation, or framework behavior (trivial tests)

**Recommendations:**
- Flag for removal with specific reasoning
- Suggest combining into parameterized tests
- Convert implementation tests to behavior tests

For detailed patterns by language, see [test-quality.md](references/test-quality.md).

### Example Review

```markdown
### Summary
Authentication middleware implementation. Handles JWT validation and role-based access. Overall solid implementation with one security concern.

### Critical Issues
- **src/auth/middleware.ts:45**: Token expiry not checked before granting access. Expired tokens will pass validation.

### Suggestions
- **src/auth/middleware.ts:23-28**: The role checking logic has 4 levels of nesting. Consider early returns to flatten.
- **src/auth/types.ts:12**: `UserData` type could use more specific types instead of `any` for the `metadata` field.

### Questions
- Is there a reason the refresh token is stored in localStorage rather than an httpOnly cookie?

### Positive Observations
- Good separation between validation and authorization logic.
- Error messages don't leak sensitive information.
```

---

## Multi-Agent Review

For comprehensive PR reviews, launch multiple specialist agents in parallel via the Task tool, then synthesize findings.

### When to Use

- PR reviews with significant changes
- Pre-merge validation
- Complex features touching multiple domains

### Phase 1: Launch Specialist Agents

Launch agents in parallel based on files changed. Each agent reads the relevant reference file and reviews the diff.

**Agent Prompts:**

```
# Kent Beck design review
Task: general-purpose
prompt: |
  Review git diff using Kent Beck style.
  Read: ~/.claude/skills/reviewing-code/references/kent-beck.md
  Focus: Simplicity, TDD, incremental progress.
  Return: Issues with file:line references.

# Test quality review
Task: general-purpose
prompt: |
  Review test changes using test quality methodology.
  Read: ~/.claude/skills/reviewing-code/references/test-quality.md
  Focus: Duplicate coverage, over-mocking, implementation tests.
  Return: Low-value tests to remove or refactor.

# Stack-specific review (select one)
Task: general-purpose
prompt: |
  Review using developing-elixir skill expertise.
  Focus: OTP patterns, Ecto queries, Phoenix conventions.
  Return: Issues with file:line references.

Task: general-purpose
prompt: |
  Review using Kent C. Dodds style.
  Read: ~/.claude/skills/reviewing-code/references/kent-c-dodds.md
  Focus: React patterns, testing library usage, component design.
  Return: Issues with file:line references.
```

Each agent returns:
1. Issues with severity (critical/high/medium/low)
2. Specific `file:line` references
3. Recommended fixes

### Phase 2: Synthesize Findings

After agents complete, use `graph-of-thoughts` to consolidate:

1. **Extract**: Core findings from each agent
2. **Align**: Merge duplicates, note consensus (strengthens confidence)
3. **Conflict**: Document disagreements
4. **Resolve**: Use `tree-of-thoughts` for conflicts
5. **Integrate**: Unified findings with confidence levels

### Phase 3: Validate

Use `self-consistency` with 3 perspectives:

1. **Security & Safety**: Vulnerabilities? Runtime risks?
2. **Correctness**: Critical issues resolved?
3. **Maintainability**: Follows conventions?

Issue merge recommendation only if consensus achieved.

### Output Format

```markdown
# Git Changes Review Report

## Executive Summary
- Total issues: X (Critical: X | High: X | Medium: X | Low: X)
- Merge recommendation: [Block/Proceed with fixes/Ready]
- Confidence: [High/Medium/Low]

## Blocking Issues
### Issue 1: [Title]
- **File**: `path/to/file:45`
- **Severity**: CRITICAL
- **Detected by**: [agent names]
- **Problem**: Description
- **Fix**: Recommendation

## Recommendations by Priority

### High Priority
- **[Title]** (`file:23`) - Description
  - Fix: ...
  - Detected by: [agents]

### Medium Priority
- **[Title]** (`file:67`) - Description

## Positive Highlights
- **Strong pattern in `file:89`**: Description

## Agent Coverage Report
| Reviewer | Files | Issues |
|----------|-------|--------|
| ecto-database | 5 | 3 critical, 2 high |
| otp-patterns | 3 | 1 high, 4 medium |

## Conflicts & Resolutions
- **`file:34`**: Agent A vs Agent B → Resolution with reasoning

## Validation Summary
- Security: [Pass/Concern]
- Correctness: [Pass/Concern]
- Maintainability: [Pass/Concern]
- Consensus: [Achieved/Partial]
```

---

## Persona References

For focused reviews with specific philosophies, see:

- [Kent Beck style](references/kent-beck.md) - TDD, simplicity, XP principles. Use for design reviews or plan critiques.
- [Kent C. Dodds style](references/kent-c-dodds.md) - React/Testing Library philosophy, AHA programming. Use for React/TypeScript reviews.

---

## The Bottom Line

Every suggestion should have clear, concrete benefits that outweigh the cost of change. When in doubt, favor stability and consistency over theoretical perfection.
