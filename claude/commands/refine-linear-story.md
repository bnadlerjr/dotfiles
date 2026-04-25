---
description: Refine a Linear issue into a behavior-focused user story with BDD acceptance criteria through iterative review
argument-hint: "<Linear issue ID>"
model: opus
allowed-tools: Read, Bash, Task, AskUserQuestion
---

# Refine Linear Story

**Level 4 (Delegation)** - Orchestrates sub-agents for codebase research and independent review cycles.

Take a Linear issue, gather context from Linear and relevant codebases, then produce a behavior-focused user story with BDD acceptance criteria. Two independent review cycles ensure quality from different perspectives.

## Variables

- **ISSUE_KEY**: `$ARGUMENTS` - Linear issue ID (e.g., ENG-123)

## Dependencies

- **managing-linear skill**: Linear CLI operations via `npx -y linearis` (czottmann/linearis)
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
I'll help you refine a Linear issue into a behavior-focused user story with BDD acceptance criteria.

Please provide a Linear issue ID (e.g., ENG-123).

I'll guide you through:
1. Fetching Linear context (issue, parent, sub-issues)
2. Selecting a project for codebase research
3. Parallel codebase analysis across repositories
4. Story drafting with domain vocabulary
5. Two charter-aware review cycles
6. Final story with optional Linear update
```

---

## Decision Log

Maintain a structured `${DECISIONS}` block throughout the workflow. Reviewers receive this block alongside the story so they can distinguish real gaps from closed decisions. Append a decision when:

- The user answers an `AskUserQuestion` (project selection, draft adjustments, feedback acceptance/rejection).
- The user gives a free-form clarification or edit instruction.
- Codebase research surfaces a constraint that bounds the story.
- A reviewer suggestion is accepted (record what changed) or rejected (record why).

Format:

```
## DECISIONS

### Scope
- IN: [behavior covered by this story]
- OUT: [explicitly deferred] — Reason: [why]

### Domain Glossary
- [Canonical term] = [meaning]; rejected synonyms: [alternates NOT used]

### Constraints (from codebase research)
- [Fact]: [where it was found and what it implies for the story]

### User Clarifications
- [Decision]: [what was being chosen between, what the user picked, why if stated]

### Review Outcomes
- Review 1 — Accepted: [suggestion → resulting story change]
- Review 1 — Rejected: [suggestion] — Reason: [why]
- Review 2 — Accepted / Rejected: [same format, populated after Phase 7]
```

Only record decisions actually made — by user choice, research finding, or review outcome. Do NOT infer decisions. A missing entry means "not yet decided," which lets reviewers raise it. Pass the current `${DECISIONS}` block verbatim to every review sub-agent.

---

## Phase 1: Linear Context

### Authentication Check

```bash
npx -y linearis teams list
```

If this fails, inform the user:

```
Linear authentication failed. Please set up authentication:
1. Get a Personal API key from Linear: Settings > "Security & Access" > "Personal API keys"
2. Save the token to ~/.linear_api_token, or export LINEAR_API_TOKEN=<token>
Then try again.
```

### Fetch Issue Details

```bash
# All linearis output is JSON by default
npx -y linearis issues read ${ISSUE_KEY}
```

From the output, extract:
- **Identifier**: Issue identifier (e.g., ENG-123)
- **Title**: `.title`
- **Description**: `.description`
- **Status**: `.status.name`
- **Priority**: `.priority` — map to name: 0=None, 1=Urgent, 2=High, 3=Medium, 4=Low
- **Parent Issue**: `.parentIssue` (identifier and title, if any)
- **Sub-Issues**: `.subIssues` (identifiers and titles, if any)

### Fetch Parent Context (if parentIssue exists)

```bash
npx -y linearis issues read ${PARENT_IDENTIFIER}
```

### Fetch Sibling Issues (if parent exists)

From the parent's `.subIssues` array, read up to 5 siblings (excluding the current issue) to gather related-work context:

```bash
npx -y linearis issues read ${SIBLING_IDENTIFIER}
```

This compensates for Linear's lack of linked issues — siblings under the same parent provide similar "related work" context.

### Build Context Summary

Compile into a structured context block:

```
**Issue**: ${IDENTIFIER} - ${TITLE}
**Status**: ${STATUS} | **Priority**: ${PRIORITY_NAME}
**Description**: ${DESCRIPTION}
**Parent**: ${PARENT_IDENTIFIER} - ${PARENT_TITLE} (if any)
**Sub-Issues**: ${SUB_ISSUE_IDENTIFIERS_AND_TITLES} (if any)
**Sibling Issues**: ${SIBLING_IDENTIFIERS_AND_TITLES} (if parent exists)
**Comments**: Not available via CLI (linearis limitation)
**Domain Terms**: [Extract from description]
```

Present the context summary to the user before proceeding.

### Initialize DECISIONS

Create the `${DECISIONS}` block per the Decision Log format. Populate Scope IN/OUT only if the issue, parent, or sub-issues explicitly state what is or isn't included. Leave the rest empty until later phases produce real decisions.

---

## Phase 2: Repository Discovery

### Load Project Registry

Read `$CLAUDE_DOCS_ROOT/projects.yaml` to get the list of known projects.

### Project Selection

Present the project list and let the user choose.

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

### Record Project Selection

Append to `${DECISIONS}` → User Clarifications: which project was selected and which repositories will be researched. This locks the research scope so reviewers don't propose pulling in patterns from unrelated repos.

---

## Phase 3: Parallel Codebase Research

For each repository in the selected project, spawn a `codebase-analyzer` agent in parallel. Each agent gets a self-contained prompt with all context embedded (no references to parent conversation).

### Agent Prompt Template

For each `${REPO}`, use the Task tool to spawn a `codebase-analyzer` agent:

```markdown
# Codebase Analysis for Story Refinement

You are analyzing the repository `${REPO}` to gather context for refining a Linear issue into a user story.

## Linear Issue Context

- **Issue**: ${ISSUE_KEY} - ${TITLE}
- **Description**: ${DESCRIPTION}

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

### Capture Constraints and Glossary

From the consolidated research:

- Append concrete bounding facts to `${DECISIONS}` → Constraints. Only capture facts that *constrain the story* (e.g., "Payments routed through `PaymentGateway`", "Field is `accountId`, not legacy `userId`"). Skip generic observations.
- Append canonical domain terms to `${DECISIONS}` → Domain Glossary, including any rejected synonyms found in the codebase that should NOT be used.

---

## Phase 4: Story Drafting

### Synthesis

Invoke the `thinking-patterns` skill with atomic-thought (`/thinking atomic-thought`) to decompose Linear context + codebase research into story components:

```
Independent questions to answer from gathered context:

1. **Actor**: Who experiences this need? (from Linear description + domain models)
2. **Trigger**: What situation or event creates this need? (from Linear + current behavior)
3. **Outcome**: What observable result do they want? (from Linear description)
4. **Constraints**: What business rules apply? (from codebase research)
5. **Failure Modes**: What could go wrong? (from codebase research)
6. **Domain Terms**: What vocabulary should the story use? (from codebase + Linear)

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

When the user provides edit instructions, append each substantive change to `${DECISIONS}` → User Clarifications (the change made + the reason if stated). Trivial wording fixes can be skipped; anything that resolves ambiguity, adjusts scope, or picks one term over another must be recorded.

---

## Phase 5: First Review (Charter-Aware)

**CRITICAL**: Launch a sub-agent that does NOT see the orchestrator's reasoning (so it can't rubber-stamp), but DOES see the user's closed decisions (so it can't accidentally reverse them).

### Reviewer Agent Prompt

Use the Task tool to spawn a `general-purpose` agent (model: `sonnet`). Substitute `${DECISIONS}` with the current decision log block and `${STORY_CONTENT}` with the complete story text:

```markdown
# User Story Expert Review

You are a senior agile practitioner reviewing a user story for quality,
completeness, and testability.

You have NOT seen the orchestrator's reasoning that produced this draft —
that prevents you from echoing it back. You DO see the DECISIONS block
below: these are closed questions the user has already resolved. Do not
propose suggestions that reverse a decision. If you believe a decision
is unsafe, surface it as a CHARTER CHALLENGE in the dedicated section
with concrete justification — never as an ordinary suggestion.

Use `/writing-agile-stories` to guide your review.
Use `/thinking chain-of-thought` to work through each review criterion systematically.

## DECISIONS (already settled — treat as fixed unless you can justify a Charter Challenge)

${DECISIONS}

## The Story to Review

${STORY_CONTENT}

## Quality Checklist

Evaluate against each criterion:

| Check | What to Look For | Anti-Pattern |
|-------|------------------|--------------|
| Behavior-focused | Describes user experience, not implementation | "API returns", "database stores", "button triggers" |
| Domain language | Uses business terms consistently with the Domain Glossary | Technical jargon, generic terms, rejected synonyms |
| Narrative form | Prose description, not template | "As a [user], I want [X], so that [Y]" |
| Small & testable | One iteration of work *as scoped* in DECISIONS | Epic-sized, vague boundaries |
| Failure modes | Error scenarios for IN-scope behaviors | Only happy path; OR failures for OUT-of-scope behaviors |
| Scenarios independent | Each stands alone | Scenarios requiring sequence |

## Review Questions

Answer each explicitly. Evaluate *within* the DECISIONS scope:

1. **Testability**: Can a developer write automated tests directly from these scenarios without asking clarifying questions?
2. **Stakeholder clarity**: Can a non-technical business stakeholder understand every term and scenario?
3. **Independence**: Is each scenario independently verifiable without running others first?
4. **Failure coverage (within scope)**: Are realistic failure modes for the IN-scope behaviors covered? Failures of OUT-of-scope behavior are not gaps.
5. **Sized as scoped**: Given the DECISIONS scope, is this story small enough for one iteration?
6. **Conversation readiness**: What questions would a developer ask in refinement that aren't already answered by the story or DECISIONS?

## Output Format

### Checklist Results
[Pass/Concern/Fail for each checklist item with explanation]

### Review Question Answers
[Detailed answer for each of the 6 questions]

### Strengths
[What's done well — be specific]

### Issues Within Scope
Gaps inside the DECISIONS scope that need fixing. For each:
- **Location**: [Which part of the story]
- **Severity**: [Critical/Major/Minor]
- **Issue**: [What's wrong]
- **Suggestion**: [Specific fix that does NOT contradict any DECISION]

### Charter Challenges
Disagreements with closed DECISIONS. Surface only with concrete justification — these reopen settled questions and must not be raised speculatively. If you have none, write "None." For each:
- **Decision being challenged**: [Quote the relevant entry from DECISIONS verbatim]
- **Why it may be unsafe**: [Evidence-based argument citing the story content or a known constraint]
- **Alternative**: [What you'd propose if the decision were reopened]

### Out of Scope (FYI)
Items that look like gaps but are already excluded by DECISIONS. List for awareness only; not actionable. If none, write "None."

### Overall Assessment
- **Quality Score (within charter)**: [1-10]
- **Ready for development?**: [Yes / Yes with minor fixes / No — needs revision]
- **Top 3 Improvements (within charter)**: [Prioritized list — exclude charter challenges]
```

### Pre-filter Reviewer Output

Before presenting findings to the user, audit the reviewer's categorization:

1. For each item in **Issues Within Scope**, check whether applying the suggestion would contradict any DECISIONS entry. If yes, move it to **Charter Challenges** (the reviewer mis-categorized it).
2. For each **Charter Challenge**, pair it with the original DECISIONS entry verbatim so the user sees exactly what would be reopened.
3. Do not modify the reviewer's text — only re-categorize.

### Present Review Findings

Present in three labeled groups, in this order:

- **Issues Within Scope** — each with severity and suggested fix; default action is to address.
- **Charter Challenges (default: keep decision)** — each shown with the DECISIONS entry it would override and the reviewer's justification side-by-side. Default action is to ignore.
- **Out of Scope (FYI)** — one-line list, no action implied.

**AskUserQuestion**:
- Header: "Review 1"
- Question: "How would you like to incorporate this feedback?"
- Options:
  - "Accept all in-scope suggestions" — Apply all Issues Within Scope; ignore charter challenges
  - "Accept some" — Ask which Issues Within Scope to accept
  - "Reopen a decision" — Identify which Charter Challenge to consider; user must explicitly confirm reopening
  - "Discuss specific feedback" — Explore particular issues
  - "Skip to second review" — Keep draft as-is

---

## Phase 6: First Refinement

Based on accepted feedback:

1. **Update the story** with accepted changes
2. **Append to `${DECISIONS}` → Review Outcomes**: list each accepted Issue (briefly: what changed in the story) and each rejected suggestion (with the reason). If a Charter Challenge was reopened and a DECISION was changed, update that DECISION entry in place AND note the change in Review Outcomes (so Review 2 sees it).
3. **Invoke `/thinking self-consistency`** to verify coherence:

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

4. **Present refined story** to user

---

## Phase 7: Second Review (Charter-Aware)

**CRITICAL**: Fresh sub-agent that has NOT seen the orchestrator's reasoning or the first reviewer's report — but DOES see the current `${DECISIONS}` block (now including Review 1 outcomes), so it cannot accidentally reverse what was just settled.

### Reviewer Agent Prompt (Skeptical Product Owner)

Use the Task tool to spawn a `general-purpose` agent (model: `sonnet`). Substitute `${DECISIONS}` with the updated decision log (post-Phase 6) and `${STORY_CONTENT}` with the complete refined story text:

```markdown
# User Story Validation — Product Owner Perspective

You are a skeptical product owner reviewing a user story before it enters
a sprint. Your job is to find gaps that would cause problems during
development or acceptance testing.

You have NOT seen previous review reports or the orchestrator's reasoning,
so you cannot rubber-stamp them. You DO see the DECISIONS block below —
including which Review 1 suggestions were accepted or rejected. Do not
re-litigate decisions. If you believe a closed decision is unsafe, raise
it as a CHARTER CHALLENGE in the dedicated section, with concrete
justification — never as an ordinary suggestion.

Use `/writing-agile-stories` to guide your review.
Use `/thinking chain-of-thought` to work through each validation area systematically.

## DECISIONS (already settled — treat as fixed unless you can justify a Charter Challenge)

${DECISIONS}

## The Story to Review

${STORY_CONTENT}

## Validation Focus

Evaluate within the DECISIONS scope.

### 1. Testability
- Can QA write acceptance tests from these scenarios alone?
- Are Given-When-Then steps specific enough to automate?
- Would two testers interpret these scenarios the same way?

### 2. Completeness (within scope)
- Are there IN-scope user actions or system events not covered by any scenario?
- What happens at the boundaries of each Given condition?
- Are there time-based, permission-based, or state-based gaps inside scope?

### 3. Scope (as decided)
- Given the DECISIONS scope, is this one story or several bundled together?
- Could any IN-scope scenario be deferred without breaking the core value?
- Would a developer estimate this confidently?

### 4. Clarity
- Are there ambiguous terms? (Cross-check against the Domain Glossary in DECISIONS.)
- Is the "why" clear enough to survive scope negotiation?
- Could someone unfamiliar with the codebase understand the intent?

### 5. Conversation Readiness
- What questions would come up in refinement that aren't answered by the story or DECISIONS?
- Is there enough context to start development without a follow-up meeting?

## Output Format

### Validation Results
For each focus area:
- **Status**: [Pass/Concern/Fail]
- **Finding**: [What you observed]
- **Risk**: [If concern/fail, what could go wrong]
- **Recommendation**: [How to address — must not contradict DECISIONS]

### Issues Within Scope
Real gaps that need fixing without changing any DECISION. For each:
- **Location**, **Severity**, **Issue**, **Suggestion**

### Charter Challenges
Disagreements with closed DECISIONS. Surface only with concrete justification. If none, write "None." For each:
- **Decision being challenged**: [Quote verbatim from DECISIONS]
- **Why it may be unsafe**: [Evidence-based]
- **Alternative**: [What you'd propose if reopened]

### Out of Scope (FYI)
Items that look like gaps but are excluded by DECISIONS. List for awareness; not actionable. If none, write "None."

### Final Verdict
- **Story Quality (within charter)**: [Strong/Adequate/Weak]
- **Sprint Ready?**: [Yes / Yes with minor edits / No — needs revision]
- **Confidence Level**: [High/Medium/Low]
- **Top 3 Risks (within charter)**: [If story ships as-is and DECISIONS hold, what could go wrong]
```

### Pre-filter Reviewer Output

Audit the reviewer's categorization the same way as Phase 6: anything in **Issues Within Scope** that contradicts a DECISIONS entry must be moved to **Charter Challenges** before presenting.

### Present Validation Findings

Present in three labeled groups: Issues Within Scope, Charter Challenges (default: keep decision, paired with the original DECISIONS entry), Out of Scope (FYI).

**AskUserQuestion**:
- Header: "Review 2"
- Question: "Final feedback received. How would you like to proceed?"
- Options:
  - "Accept all in-scope suggestions" — Apply all Issues Within Scope; ignore charter challenges
  - "Accept some" — Ask which Issues Within Scope to accept
  - "Reopen a decision" — Pick a Charter Challenge to consider; user must explicitly confirm reopening
  - "Story is ready as-is" — Skip refinement, proceed to output

---

## Phase 8: Final Refinement

1. **Incorporate any final feedback**
2. **Append to `${DECISIONS}` → Review Outcomes**: log Review 2 acceptances and rejections (with reasons). Update any DECISION whose challenge was reopened.
3. **Invoke `/thinking self-consistency`** for final coherence check:

```
Final verification of the complete story:

Path 1 - Read as developer: Could I implement this without asking questions?
Path 2 - Read as tester: Could I write acceptance tests from scenarios alone?
Path 3 - Read as product owner: Does this deliver the value described in the narrative?

Synthesize: Is the story ready for sprint planning?
```

4. **Prepare final story**

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

### Linear Update

**AskUserQuestion**:
- Header: "Linear update"
- Question: "How should I update ${ISSUE_KEY} in Linear?"
- Options:
  - "Update description" - Replace issue description with the story
  - "Add as comment" - Add the story as a comment
  - "Both" - Update description AND add a comment with the story
  - "Don't update Linear" - Display only, no Linear changes

### Linear Update Execution

For multi-line story content, write to `/tmp` first (the CLI chokes on inline multi-line strings):

```bash
# Write story to temp file
cat > /tmp/linear_story.md <<'EOF'
${FINAL_STORY_CONTENT}
EOF
```

**Update description**:
```bash
npx -y linearis issues update ${ISSUE_KEY} --description "$(cat /tmp/linear_story.md)"
```

**Add as comment**:
```bash
npx -y linearis comments create ${ISSUE_KEY} --body "$(cat /tmp/linear_story.md)"
```

---

## Error Handling

### Empty ISSUE_KEY

```
No Linear issue ID provided. Please provide an issue key (e.g., ENG-123).

Usage: /refine-linear-story ENG-123
```

### Authentication Failure

```
Linear authentication failed. Please set up authentication:
1. Get a Personal API key from Linear: Settings > "Security & Access" > "Personal API keys"
2. Save the token to ~/.linear_api_token, or export LINEAR_API_TOKEN=<token>
Then try again.
```

### Issue Not Found

```
Issue ${ISSUE_KEY} was not found. Please check:
1. The issue key is correct (e.g., ENG-123)
2. You have permission to view this issue
3. The team prefix exists in your Linear workspace
```

### No Matching Project

When user selects "None of these" and doesn't provide repository paths:

```
I need at least one repository path to research for domain context.
Without codebase research, the story will rely solely on Linear context.

Would you like to:
1. Provide repository paths
2. Continue without codebase research
```

### Research Agent Timeout

```
Codebase research for ${REPO} is taking longer than expected. Options:
1. Wait for completion (recommended)
2. Skip this repository and proceed with available research
3. Cancel research and draft from Linear context only
```

---

## Example Session

```bash
/refine-linear-story ENG-456
```

1. Verifies Linear auth, fetches ENG-456 with parent and sub-issues
2. Presents Linear context summary (notes comments unavailable via CLI)
3. Shows project list from projects.yaml, user selects "EMR Automations"
4. Spawns codebase-analyzer agents for kong-fu and chunky-kong in parallel
5. Synthesizes Linear + codebase context using atomic-thought
6. Drafts story with narrative + Given-When-Then scenarios
7. User approves draft for review
8. Review 1: Agile practitioner evaluates quality and testability
9. User incorporates feedback, self-consistency check
10. Review 2: Skeptical product owner validates completeness and scope
11. User finalizes, self-consistency check
12. Presents final story, user chooses to update Linear description
