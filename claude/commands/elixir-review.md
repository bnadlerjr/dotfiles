---
model: opus
---

## Changes Review - Multi-Agent Analysis

### Context

Conduct a comprehensive review of the current Git branch changes using sub-agent system to analyze different aspects in parallel. Synthesize all agent feedback into actionable recommendations.

### Execution Strategy

#### Phase 1: Parallel Analysis (Execute Simultaneously)

**IMPORTANT**: You MUST parallelize agent execution to optimize performance.

##### Code Quality Review Track

Deploy the following general code quality agents based on files changed in parallel:
- **kent-beck-reviewer**
- **pragmatic-code-reviewer**

Deploy the following Elixir specialist agents based on files changed in parallel:

- **absinthe-graphql-architect**: Review GraphQL schema changes, resolver patterns, subscription implementations
- **ecto-database-master**: Analyze database migrations, query optimizations, schema designs, changesets
- **elixir-functional-modeler**: Assess functional patterns, data transformations, pipeline compositions
- **elixir-otp-expert**: Evaluate supervision trees, GenServer implementations, fault tolerance patterns
- **liveview-interactive-expert**: Review LiveView components, hooks, real-time features, client-server state
- **phoenix-framework-specialist**: Check controller patterns, context boundaries, routing, plugs

Each specialist should produce:

1. Issues found (with severity: critical/high/medium/low)
2. Specific file:line references
3. Recommended fixes with code examples

##### Testing Track

- **exunit-testing-strategist**: Audit test coverage, identify missing test cases, review test quality and assertions

##### Documentation Track

Execute both in parallel:

- **documentation-craftsperson**: Review moduledocs, function docs, inline comments for accuracy and completeness
- **spurious-comment-remover**: Flag outdated, redundant, or misleading comments for removal

#### Phase 2: Synthesis (After Parallel Completion)

Consolidate all agent reports into a unified review with:

1. **Critical Issues Dashboard**
    
    - Security vulnerabilities
    - Runtime errors/bugs
    - Data integrity risks
    - Performance bottlenecks
2. **By-File Summary**

    ```
    path/to/file.ex:
      - [CRITICAL] Line 45: SQL injection risk (ecto-database-master)
      - [HIGH] Line 23: Missing supervision (elixir-otp-expert)
      - [MEDIUM] Line 67: Test coverage gap (exunit-testing-strategist)
    ```

3. **Cross-Agent Conflicts**
    
    - Identify where agents disagree
    - Resolve with explanation
4. **Improvement Roadmap**
    
    - Must fix before merge
    - Should fix soon
    - Consider for refactoring

### Agent Coordination Rules

- Agents work on overlapping files independently
- Duplicate findings should be merged, noting agreement between agents
- Conflicting recommendations should be highlighted for human review
- Performance-critical paths get priority from all relevant agents

### Output Format

Structure the final report in markdown with the following sections:

```markdown
# Git Changes Review Report

## Executive Summary
- Total issues found: X
- Critical: X | High: X | Medium: X | Low: X
- Merge recommendation: [Block/Proceed with fixes/Ready to merge]

## 🚨 Blocking Issues
### Issue 1: [Title]
- **File**: `path/to/file.ex:45`
- **Severity**: CRITICAL
- **Detected by**: ecto-database-master, pragmatic-code-reviewer
- **Problem**: Detailed description of the issue
- **Fix**: Description of the fix

#### Issue 2: [Title]

[Same format as above]

### 📋 Recommendations by Priority

#### High Priority

- **[Issue Title]** (`file.ex:23`) - Brief description
    - Suggested fix:...
    - Detected by: [agent names]

#### Medium Priority

- **[Issue Title]** (`file.ex:67`) - Brief description
    - Suggested fix:...
    - Detected by: [agent names]

#### Low Priority

- List of minor improvements...

### ✅ Positive Highlights

- **Excellent pattern in `file.ex:89`**: Description of what's done well
- **Strong test coverage in `test_file.exs`**: Specific praise
- Additional commendable implementations...

### 📊 Agent Coverage Report

| Agent                        | Files Reviewed | Issues Found       |
| ---------------------------- | -------------- | ------------------ |
| ecto-database-master         | 5 files        | 3 critical, 2 high |
| elixir-otp-expert            | 3 files        | 1 high, 4 medium   |
| [continue for all agents...] |                |                    |

### Conflicts & Resolutions

- **Disagreement on `file.ex:34`**:
    - Agent A suggests:...
    - Agent B suggests:...
    - Resolution:... [with rationale]
```
