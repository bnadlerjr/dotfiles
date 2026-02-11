---
description: Refine a Jira issue into a behavior-focused user story with BDD acceptance criteria through iterative review
argument-hint: "<Jira issue ID>"
model: opus
allowed-tools: Read, Bash, Task, AskUserQuestion
---

# Refine Jira Story

**Level 4 (Delegation)** - Orchestrates sub-agents for codebase research and independent review cycles.

Take a Jira issue, gather context from Jira and relevant codebases, then produce a behavior-focused user story with BDD acceptance criteria. Two independent review cycles ensure quality from different perspectives.

## Variables

- **ISSUE_KEY**: `$ARGUMENTS` - Jira issue ID (e.g., POPS-123)

## Dependencies

- **managing-jira skill**: Jira CLI operations via `jira` command (ankitpokhrel/jira-cli)
- **writing-agile-stories skill**: Story format, narrative principles, Given-When-Then criteria
- **thinking-patterns skill**: atomic-thought, chain-of-thought, self-consistency
- **codebase-analyzer agent**: Read + Serena + Grep + Glob + LS for deep code research
- **general-purpose agent** (model: sonnet): Review sub-agents — sonnet suits structured checklist evaluation; opus orchestrates synthesis and drafting
- **Project registry**: `$CLAUDE_DOCS_ROOT/projects.yaml`

## Initial Response

When invoked:

1. **If an issue key was provided**: Validate format and begin Phase 1
2. **If no issue key provided**, respond with:

```
I'll help you refine a Jira issue into a behavior-focused user story with BDD acceptance criteria.

Please provide a Jira issue ID (e.g., POPS-123).

I'll guide you through:
1. Fetching Jira context (issue, comments, linked issues)
2. Selecting a project for codebase research
3. Parallel codebase analysis across repositories
4. Story drafting with domain vocabulary
5. Two independent review cycles
6. Final story with optional Jira update
```

---

## Phase 1: Jira Context

### Authentication Check

```bash
jira me
```

If this fails, inform the user to run `jira init`.

### Fetch Issue Details

```bash
# Primary issue with comments
jira issue view ${ISSUE_KEY} --comments 10

# Get raw JSON for structured parsing
jira issue view ${ISSUE_KEY} --raw
```

From the raw output, extract:
- **Summary**: Issue title
- **Description**: Full description text
- **Comments**: All comment bodies
- **Status**: Current workflow state
- **Type**: Story, Bug, Task, etc.
- **Parent**: Epic or parent issue key (if any)
- **Links**: Related/blocked issues

### Fetch Parent Context (if parent exists)

```bash
jira issue view ${PARENT_KEY}
```

### Fetch Linked Issues (for each linked issue)

```bash
jira issue view ${LINKED_KEY}
```

### Build Context Summary

Compile into a structured context block:

```
**Issue**: ${ISSUE_KEY} - ${SUMMARY}
**Type**: ${TYPE} | **Status**: ${STATUS}
**Description**: ${DESCRIPTION}
**Parent**: ${PARENT_KEY} - ${PARENT_SUMMARY} (if any)
**Linked Issues**: ${LINKED_KEYS_AND_SUMMARIES} (if any)
**Comments**: ${COMMENT_SUMMARIES}
**Domain Terms**: [Extract from description and comments]
```

Present the context summary to the user before proceeding.

---

## Phase 2: Repository Discovery

### Load Project Registry

Read `$CLAUDE_DOCS_ROOT/projects.yaml` to get the list of known projects.

### Project Selection

Since `jira_epic` is only populated for 1 of the projects, auto-matching by Jira project key is unreliable. Present the project list and let the user choose.

**AskUserQuestion**:
- Header: "Project"
- Question: "Which project does ${ISSUE_KEY} belong to? I'll research the associated repositories for domain context."
- Options: Build from projects.yaml entries, showing project name and repository list for each. Include a "None of these" option description.

### Extract Repositories

From the selected project entry, extract the `repositories` list.

If user picks "None of these" (Other), ask:

```
Which repository paths should I research? Provide absolute paths or org/repo identifiers, separated by commas.
```

---

## Phase 3: Parallel Codebase Research

For each repository in the selected project, spawn a `codebase-analyzer` agent in parallel. Each agent gets a self-contained prompt with all context embedded (no references to parent conversation).

### Agent Prompt Template

For each `${REPO}`, use the Task tool to spawn a `codebase-analyzer` agent:

```markdown
# Codebase Analysis for Story Refinement

You are analyzing the repository `${REPO}` to gather context for refining a Jira issue into a user story.

## Jira Issue Context

- **Issue**: ${ISSUE_KEY} - ${SUMMARY}
- **Description**: ${DESCRIPTION}
- **Comments**: ${COMMENT_SUMMARIES}

## Research Focus

Investigate the codebase for information relevant to this issue. Focus on:

### 1. Existing Behavior
- How does the system currently handle the functionality described in the issue?
- What code paths are involved?
- What is the current user-facing behavior?

### 2. Domain Vocabulary
- What terms does the codebase use for the concepts in this issue?
- Are there domain models, value objects, or named patterns related to this feature?
- Note any ubiquitous language from module names, function names, or comments.

### 3. Business Rules & Constraints
- What validations, guards, or business rules exist in related code?
- What invariants does the system enforce?
- Are there configuration-driven constraints?

### 4. Failure Modes
- What errors or edge cases does the existing code handle?
- What happens when things go wrong in related flows?
- Are there retry mechanisms, fallbacks, or error states?

### 5. Integration Points
- What other systems or services does this code interact with?
- Are there API contracts, message formats, or event schemas?
- What dependencies exist?

## Output Format

Provide a structured research report:

### Domain Vocabulary
[Terms and their meanings as used in the codebase]

### Current Behavior
[How the system works today in the relevant area]

### Business Rules
[Rules and constraints found in the code]

### Failure Modes
[Error handling and edge cases]

### Integration Points
[External dependencies and contracts]

### Key Code Locations
[File paths and brief descriptions of the most relevant code]
```

### Wait for All Agents

Collect research results from all repositories before proceeding.

### Present Research Summary

Combine findings from all repositories into a consolidated summary. Present to user before drafting.

---

## Phase 4: Story Drafting

### Synthesis

Invoke the `thinking-patterns` skill with atomic-thought (`/thinking atomic-thought`) to decompose Jira context + codebase research into story components:

```
Independent questions to answer from gathered context:

1. **Actor**: Who experiences this need? (from Jira description + domain models)
2. **Trigger**: What situation or event creates this need? (from Jira + current behavior)
3. **Outcome**: What observable result do they want? (from Jira description + comments)
4. **Constraints**: What business rules apply? (from codebase research)
5. **Failure Modes**: What could go wrong? (from codebase research)
6. **Domain Terms**: What vocabulary should the story use? (from codebase + Jira)

Answer each independently, then synthesize.
```

### Draft Story

Read the `writing-agile-stories` skill (SKILL.md) for format and principles, but do NOT invoke its interactive AskUserQuestion flow — this command controls all user interaction. Apply the skill's story structure and drafting guidelines directly:

**Story structure** (from the skill):
```markdown
## Story: [Descriptive Title]

[2-4 sentence narrative describing:
 - The user's situation
 - The behavior they need
 - The value they get
Written in domain language, present tense]

### Context
[When this behavior is relevant - the business preconditions]

### Acceptance Criteria

#### Scenario: [Happy path description]
- Given [business context/state]
- When [user action or system event]
- Then [observable outcome]
- And [additional outcomes if needed]

#### Scenario: [Alternative path description]
- Given [different context/state]
- When [user action or system event]
- Then [different outcome]

#### Scenario: [Failure mode description]
- Given [context leading to failure]
- When [action that triggers failure]
- Then [graceful handling]
```

**Drafting principles** (from the skill):
- Behavior over implementation: describe what users experience, not how it's built
- Narrative over template: use prose, NOT "As a [user], I want..."
- Concrete over abstract: use specific examples (Specification by Example)
- Domain language throughout: use terms from the codebase and business
- Include happy path, alternative paths, AND failure modes

### Present Draft

Show the complete story draft to the user.

**AskUserQuestion**:
- Header: "Draft"
- Question: "Here's the initial story draft. Ready to send it for expert review?"
- Options:
  - "Yes, proceed to review" - Continue to Phase 5
  - "Make adjustments first" - Ask what to change, apply edits, re-present

---

## Phase 5: First Review (Clean Context)

**CRITICAL**: Launch a sub-agent with NO access to the generation context. The reviewer evaluates the story purely on its merits.

### Reviewer Agent Prompt

Use the Task tool to spawn a `general-purpose` agent (model: `sonnet`). Substitute `${STORY_CONTENT}` with the complete story text:

```markdown
# User Story Expert Review

You are a senior agile practitioner reviewing a user story for quality,
completeness, and testability. You have NOT seen how this story was
created - evaluate it purely on its merits.

Use `/thinking chain-of-thought` to work through each review criterion systematically.

## The Story to Review

${STORY_CONTENT}

## Quality Checklist

Evaluate against each criterion:

| Check | What to Look For | Anti-Pattern |
|-------|------------------|--------------|
| Behavior-focused | Describes user experience, not implementation | "API returns", "database stores", "button triggers" |
| Domain language | Uses business terms consistently | Technical jargon, generic terms |
| Narrative form | Prose description, not template | "As a [user], I want [X], so that [Y]" |
| Small & testable | One iteration of work, clear scope | Epic-sized, vague boundaries |
| Failure modes | Error scenarios with graceful handling | Only happy path |
| Scenarios independent | Each stands alone | Scenarios requiring sequence |

## Review Questions

Answer each explicitly:

1. **Testability**: Can a developer write automated tests directly from these scenarios without asking clarifying questions?
2. **Stakeholder clarity**: Can a non-technical business stakeholder understand every term and scenario?
3. **Independence**: Is each scenario independently verifiable without running others first?
4. **Failure coverage**: Are all realistic failure modes covered? What's missing?
5. **Scope**: Is this story small enough for one iteration? If not, where would you split it?
6. **Conversation readiness**: What questions would a developer ask in a story refinement session? (Fewer = better)

## Output Format

### Checklist Results
[Pass/Concern/Fail for each checklist item with explanation]

### Review Question Answers
[Detailed answer for each of the 6 questions]

### Strengths
[What's done well - be specific]

### Issues Found
For each issue:
- **Location**: [Which part of the story]
- **Severity**: [Critical/Major/Minor]
- **Issue**: [What's wrong]
- **Suggestion**: [Specific fix]

### Overall Assessment
- **Quality Score**: [1-10]
- **Ready for development?**: [Yes / Yes with minor fixes / No - needs revision]
- **Top 3 Improvements**: [Prioritized list]
```

### Present Review Findings

When the review agent completes, present findings to the user.

**AskUserQuestion**:
- Header: "Review 1"
- Question: "How would you like to incorporate this feedback?"
- Options:
  - "Accept all suggestions" - Incorporate all feedback
  - "Accept some suggestions" - Ask which to accept
  - "Discuss specific feedback" - Explore particular issues
  - "Skip to second review" - Keep draft as-is

---

## Phase 6: First Refinement

Based on accepted feedback:

1. **Update the story** with changes
2. **Invoke `/thinking self-consistency`** to verify coherence:

```
Verify the refined story for internal consistency:

Path 1 - Narrative-Criteria Alignment:
Does the narrative description match what the acceptance criteria test?

Path 2 - Domain Language Consistency:
Are terms used identically in narrative, context, and all scenarios?

Path 3 - Failure Coverage:
Do failure scenarios correspond to real constraints found in codebase research?

Synthesize: Any inconsistencies introduced by refinements?
```

3. **Present refined story** to user

---

## Phase 7: Second Review (Clean Context)

**CRITICAL**: Fresh sub-agent with NO access to previous context. Different perspective from first review.

### Reviewer Agent Prompt (Skeptical Product Owner)

Use the Task tool to spawn a `general-purpose` agent (model: `sonnet`). Substitute `${STORY_CONTENT}` with the complete refined story text:

```markdown
# User Story Validation - Product Owner Perspective

You are a skeptical product owner reviewing a user story before it enters
a sprint. Your job is to find gaps that would cause problems during
development or acceptance testing. You have NOT seen previous versions -
evaluate this story fresh.

Use `/thinking chain-of-thought` to work through each validation area systematically.

## The Story to Review

${STORY_CONTENT}

## Validation Focus

### 1. Testability
- Can QA write acceptance tests from these scenarios alone?
- Are Given-When-Then steps specific enough to automate?
- Would two testers interpret these scenarios the same way?

### 2. Completeness
- Are there user actions or system events not covered by any scenario?
- What happens at the boundaries of each Given condition?
- Are there time-based, permission-based, or state-based gaps?

### 3. Scope
- Is this one story or several bundled together?
- Could any scenario be deferred without breaking the core value?
- Would a developer estimate this confidently, or ask "how big is this really?"

### 4. Clarity
- Are there ambiguous terms that different team members might interpret differently?
- Is the "why" clear enough to survive scope negotiation?
- Could someone unfamiliar with the codebase understand the intent?

### 5. Conversation Readiness
- What questions would come up in a refinement session?
- What assumptions need to be validated with stakeholders?
- Is there enough context to start development without a follow-up meeting?

## Output Format

### Validation Results
For each focus area:
- **Status**: [Pass/Concern/Fail]
- **Finding**: [What you observed]
- **Risk**: [If concern/fail, what could go wrong]
- **Recommendation**: [How to address]

### Missing Scenarios
[Any scenarios that should exist but don't]

### Ambiguities
[Terms or conditions that could be interpreted multiple ways]

### Final Verdict
- **Story Quality**: [Strong/Adequate/Weak]
- **Sprint Ready?**: [Yes/Yes with minor edits/No - needs revision]
- **Confidence Level**: [High/Medium/Low that development could start]
- **Top 3 Risks**: [If story ships as-is, what could go wrong]
```

### Present Validation Findings

When the validation agent completes, present findings to the user.

**AskUserQuestion**:
- Header: "Review 2"
- Question: "Final feedback received. How would you like to proceed?"
- Options:
  - "Accept and finalize" - Incorporate feedback, proceed to output
  - "Selective incorporation" - Ask which feedback to use
  - "Story is ready as-is" - Skip refinement, proceed to output

---

## Phase 8: Final Refinement

1. **Incorporate any final feedback**
2. **Invoke `/thinking self-consistency`** for final coherence check:

```
Final verification of the complete story:

Path 1 - Read as developer: Could I implement this without asking questions?
Path 2 - Read as tester: Could I write acceptance tests from scenarios alone?
Path 3 - Read as product owner: Does this deliver the value described in the narrative?

Synthesize: Is the story ready for sprint planning?
```

3. **Prepare final story**

---

## Phase 9: Output

### Present Final Story

Display the complete refined story with quality check results:

```
## Final Story

[Complete story content]

---

## Quality Summary

### Review 1 (Agile Practitioner)
- Score: [X/10]
- Key improvements made: [List]

### Review 2 (Product Owner)
- Verdict: [Strong/Adequate/Weak]
- Final adjustments: [List]

### Quality Checks
[Pass/Fail for each checklist item from writing-agile-stories skill:
 - Behavior-focused
 - Domain language
 - Narrative form
 - Small & testable
 - Failure modes included
 - Scenarios independent]
```

### Jira Update

**AskUserQuestion**:
- Header: "Jira update"
- Question: "How should I update ${ISSUE_KEY} in Jira?"
- Options:
  - "Update description" - Replace issue description with the story
  - "Add as comment" - Add the story as a comment
  - "Both" - Update description AND add a comment with the story
  - "Don't update Jira" - Display only, no Jira changes

### Jira Update Execution

For multi-line story content, write to `/tmp` first (the CLI chokes on inline multi-line strings):

```bash
# Write story to temp file
cat > /tmp/jira_story.md <<'EOF'
${FINAL_STORY_CONTENT}
EOF
```

**Update description**:
```bash
jira issue edit ${ISSUE_KEY} --no-input --body "$(cat /tmp/jira_story.md)"
```

**Add as comment**:
```bash
jira issue comment add ${ISSUE_KEY} --no-input -b"$(cat /tmp/jira_story.md)"
```

---

## Error Handling

### Empty ISSUE_KEY

```
No Jira issue ID provided. Please provide an issue key (e.g., POPS-123).

Usage: /refine-jira-story POPS-123
```

### Authentication Failure

```
Jira authentication failed. Please run `jira init` to configure your credentials,
then try again.
```

### Issue Not Found

```
Issue ${ISSUE_KEY} was not found. Please check:
1. The issue key is correct (e.g., POPS-123, not pops-123)
2. You have permission to view this issue
3. The project key exists in your Jira instance
```

### No Matching Project

When user selects "None of these" and doesn't provide repository paths:

```
I need at least one repository path to research for domain context.
Without codebase research, the story will rely solely on Jira context.

Would you like to:
1. Provide repository paths
2. Continue without codebase research
```

### Research Agent Timeout

```
Codebase research for ${REPO} is taking longer than expected. Options:
1. Wait for completion (recommended)
2. Skip this repository and proceed with available research
3. Cancel research and draft from Jira context only
```

---

## Example Session

```bash
/refine-jira-story POPS-456
```

1. Verifies Jira auth, fetches POPS-456 with comments and linked issues
2. Presents Jira context summary
3. Shows project list from projects.yaml, user selects "EMR Automations"
4. Spawns codebase-analyzer agents for kong-fu and chunky-kong in parallel
5. Synthesizes Jira + codebase context using atomic-thought
6. Drafts story with narrative + Given-When-Then scenarios
7. User approves draft for review
8. Review 1: Agile practitioner evaluates quality and testability
9. User incorporates feedback, self-consistency check
10. Review 2: Skeptical product owner validates completeness and scope
11. User finalizes, self-consistency check
12. Presents final story, user chooses to update Jira description
