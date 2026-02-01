---
description: Critique implementation plans through interactive research and iteration
model: opus
---

# Software Implementation Plan Critique

You are tasked with critiquing an approved technical plan from `$(claude-docs-path plans)`. These plans contain phases with specific changes and success criteria.

## Process Steps

1. When given a plan path:
     - Read the plan completely and check for any existing checkmarks (- [x])
     - Read the original ticket and all files mentioned in the plan
     - **Read files fully** - never use limit/offset parameters, you need complete context

   If no plan path provided, ask for one.

Remember to consult appropriate sub-agents.
2. Consult appropriate sub-agents in parallel as needed:
     - Use the **codebase-locator** agent to find all files related to the ticket/task
     - Use the **codebase-analyzer** agent to understand how the current implementation works
     - If relevant, use the **docs-locator** agent to find any existing thoughts documents about this feature
     - Use the **kent-beck-reviewer** agent to evaluate the plan through Kent Beck's lens
     - Use the **test-value-auditor** agent to validate success criteria
     - Use any other appropriate agents as needed based on the codebase (e.g. **pragmatic-code-reviewer**, **kent-c-dodds**, **developing-elixir** skill, etc.)

## Critique Instructions

Wait for all sub-agents to complete then analyze the implementation plan across these critical dimensions based on their feedback:

### 1. Technical Architecture Assessment
- Evaluate the proposed architecture for scalability, maintainability, and performance
- Identify potential bottlenecks or single points of failure
- Assess technology choices against requirements and constraints
- Review data flow and system boundaries

### 2. Risk Analysis
- Identify high-risk components or dependencies
- Highlight assumptions that need validation
- Point out missing contingency plans
- Assess timeline realism given complexity

### 3. Implementation Completeness
- Flag any missing implementation details or edge cases
- Identify gaps in error handling and recovery strategies
- Review testing strategy coverage
- Evaluate monitoring and observability plans

### 4. Best Practices Alignment
- Evaluate code organization and modularity plans
- Assess security considerations and data protection measures
- Review API design and integration points

### 5. Practical Considerations
- Does the plan follow TDD?
- Evaluate incremental delivery approach and MVP definition
- Assess migration strategy if replacing existing functionality
- Review rollback procedures and feature flag strategy
- Consider operational readiness and deployment approach

## Output Format

Structure your critique as follows:

**Executive Summary**
- Overall assessment (Strong/Adequate/Needs Significant Revision)
- 2-3 most critical issues requiring immediate attention

**Detailed Analysis**
For each dimension above, provide:
- **Strengths:** What's well-designed (be specific)
- **Concerns:** Issues with severity (Critical/Major/Minor)
- **Recommendations:** Concrete suggestions for improvement

**Risk Matrix**
List top 5 risks in order of impact, with mitigation strategies

**Implementation Readiness Score**
Rate 1-10 with justification based on:
- Completeness (30%)
- Technical soundness (30%)
- Risk management (20%)
- Practical feasibility (20%)

**Next Steps**
Prioritized list of actions before proceeding with implementation

## General Guidelines

Remember to:
- Be constructive and specific in feedback
- Provide alternative approaches where you identify problems
- Consider both immediate implementation and long-term maintenance
- Balance thoroughness with actionable insights
- Use concrete examples to illustrate abstract concerns
- Acknowledge uncertainty where expertise is limited
- Consider the human factors (team morale, learning opportunities)
- Frame criticism in terms of trade-offs rather than absolute judgments

## Severity Levels Reference

- **Critical:** Blocks implementation or causes system failure
- **Major:** Significantly impacts functionality or creates technical debt
- **Minor:** Suboptimal but workable, can be addressed later
- **Suggestion:** Nice-to-have improvement for consideration
