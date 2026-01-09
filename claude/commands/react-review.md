---
model: opus
---

## Changes Review - Multi-Agent Analysis

### Context

Conduct a comprehensive review of the current Git branch changes using sub-agent system to analyze different aspects in parallel. Synthesize all agent feedback into actionable recommendations using structured thinking patterns.

### Execution Strategy

#### Phase 1: Parallel Analysis (Execute Simultaneously)

**IMPORTANT**: You MUST parallelize agent execution to optimize performance.

##### Agent Review Methodology

Each agent should apply appropriate thinking patterns during analysis:

- **`chain-of-thought`**: When tracing execution bugs, render cycles, or state flow issues ("why does this re-render?")
- **`atomic-thought`**: When reviewing complex multi-component changes that can be decomposed into independent units

##### Code Quality Review Track

Deploy the following TypeScript/React specialist agents based on files changed in parallel:

- **kent-c-dodds**: Review testing patterns, component design, accessibility, and React best practices
- **pragmatic-code-reviewer**: Assess code maintainability, readability, and practical concerns
- **kent-beck-reviewer**: Evaluate design simplicity, TDD adherence, and incremental progress
- **test-value-auditor**: Identify low-value tests, redundant coverage, and testing anti-patterns
- **typescript-react-expert**: Analyze type safety, hook patterns, performance, and architecture

Each specialist should produce:

1. Issues found (with severity: critical/high/medium/low)
2. Specific file:line references
3. Recommended fixes with code examples

#### Phase 2: Synthesis (Using Graph of Thoughts)

**INVOKE `graph-of-thoughts` skill** to consolidate all agent reports into a unified review.

##### Synthesis Process

```
Step 1 - Extract: From each agent report, identify:
   - Core findings (issues, recommendations)
   - Severity assessments
   - File:line references

Step 2 - Align: Identify where agents agree
   - Merge duplicate findings, noting consensus
   - Strengthen confidence for multi-agent agreement

Step 3 - Conflict: Identify where agents disagree
   - Document each conflict with both positions
   - Analyze why the disagreement exists

Step 4 - Resolve: For each conflict, invoke `tree-of-thoughts`:
   - Generate 2-3 interpretations
   - Evaluate against project context and constraints
   - Select resolution with explicit reasoning

Step 5 - Integrate: Produce unified output with:
   - Synthesized findings with provenance (which agents found what)
   - Confidence levels based on agent agreement
   - Remaining uncertainties flagged for human review
```

##### Consolidated Output Structure

1. **Critical Issues Dashboard**

    - Security vulnerabilities
    - Runtime errors/bugs
    - Data integrity risks
    - Performance bottlenecks
2. **By-File Summary**

    ```
    path/to/file.tsx:
      - [CRITICAL] Line 45: XSS vulnerability (pragmatic-code-reviewer)
      - [HIGH] Line 23: Missing error boundary (kent-c-dodds)
      - [MEDIUM] Line 67: Test coverage gap (test-value-auditor)
    ```

3. **Cross-Agent Conflicts**

    - Identify where agents disagree
    - Resolution with `tree-of-thoughts` reasoning
4. **Improvement Roadmap**

    - Must fix before merge
    - Should fix soon
    - Consider for refactoring

#### Phase 3: Final Validation (Using Self-Consistency)

**INVOKE `self-consistency` skill** before issuing the merge recommendation.

Verify through 3 independent perspectives:

```
Perspective 1 (Security & Safety):
- Are all security vulnerabilities addressed?
- Are there runtime error risks remaining?
- [Analysis → Recommendation]

Perspective 2 (Correctness & Quality):
- Are all critical/high issues resolved?
- Does the code behave as intended?
- [Analysis → Recommendation]

Perspective 3 (Maintainability & Standards):
- Does this follow project conventions?
- Will this be maintainable long-term?
- [Analysis → Recommendation]

Consensus Check:
- Do all perspectives agree on merge readiness?
- If disagreement, which perspective raises valid blockers?
- Final recommendation with confidence level
```

### Agent Coordination Rules

- Agents work on overlapping files independently
- Duplicate findings should be merged, noting agreement between agents
- Conflicting recommendations trigger `tree-of-thoughts` exploration
- Performance-critical paths get priority from all relevant agents

### Output Format

Structure the final report in markdown with the following sections:

```markdown
# Git Changes Review Report

## Executive Summary
- Total issues found: X
- Critical: X | High: X | Medium: X | Low: X
- Merge recommendation: [Block/Proceed with fixes/Ready to merge]
- Recommendation confidence: [High/Medium/Low] (based on self-consistency check)

## 🚨 Blocking Issues
### Issue 1: [Title]
- **File**: `path/to/file.tsx:45`
- **Severity**: CRITICAL
- **Detected by**: typescript-react-expert, pragmatic-code-reviewer
- **Problem**: Detailed description of the issue
- **Fix**: Description of the fix

#### Issue 2: [Title]

[Same format as above]

### 📋 Recommendations by Priority

#### High Priority

- **[Issue Title]** (`file.tsx:23`) - Brief description
    - Suggested fix:...
    - Detected by: [agent names]

#### Medium Priority

- **[Issue Title]** (`file.ts:67`) - Brief description
    - Suggested fix:...
    - Detected by: [agent names]

#### Low Priority

- List of minor improvements...

### ✅ Positive Highlights

- **Excellent pattern in `file.tsx:89`**: Description of what's done well
- **Strong test coverage in `test_file.ts`**: Specific praise
- Additional commendable implementations...

### 📊 Agent Coverage Report

| Agent                        | Files Reviewed | Issues Found       |
| ---------------------------- | -------------- | ------------------ |
| typescript-react-expert      | 5 files        | 3 critical, 2 high |
| pragmatic-code-reviewer      | 3 files        | 1 high, 4 medium   |
| [continue for all agents...] |                |                    |

### Conflicts & Resolutions

- **Disagreement on `file.tsx:34`**:
    - Agent A suggests:...
    - Agent B suggests:...
    - Resolution:... [with tree-of-thoughts rationale]

### Validation Summary

Self-consistency check results:
- Security perspective: [Pass/Concern]
- Correctness perspective: [Pass/Concern]
- Maintainability perspective: [Pass/Concern]
- Consensus: [Achieved/Partial - details]
```
