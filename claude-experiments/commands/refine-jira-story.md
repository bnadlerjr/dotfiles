---
description: Refine a Jira issue into a behavior-focused user story with BDD acceptance criteria through iterative review
argument-hint: "<Jira issue ID>"
model: opus
allowed-tools: Read, Bash, Task, AskUserQuestion
---

# Refine Jira Story

**Level 4 (Delegation)** - Orchestrates sub-agents for capability research and independent review cycles.

Take a Jira issue, gather context from Jira and relevant codebases, then produce a behavior-focused user story with BDD acceptance criteria. Two independent review cycles ensure quality from different perspectives.

## Variables

- **ISSUE_KEY**: `$ARGUMENTS` - Jira issue ID (e.g., POPS-123)

## Dependencies

- **managing-jira skill**: Jira CLI operations via `jira` command (ankitpokhrel/jira-cli)
- **writing-agile-stories skill**: Story format, narrative principles, Given-When-Then criteria
- **thinking-patterns skill**: atomic-thought, chain-of-thought, self-consistency
- **capability-locator agent**: Inventories user-facing entry points (routes, pages, CLI commands, public APIs) at the capability level — primary research agent for Phase 3
- **codebase-analyzer agent**: Reserved for narrow fallback only (user-visible strings — error messages, status names, label text). NEVER for code paths, integration points, services, schemas, or file locations.
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
2. Selecting a project for capability research
3. Parallel capability research across repositories
4. Story drafting with domain vocabulary
5. Two charter-aware review cycles
6. Final story with optional Jira update
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

### Constraints (from capability research)
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

### Initialize DECISIONS

Create the `${DECISIONS}` block per the Decision Log format. Populate Scope IN/OUT only if the issue, parent, or comments explicitly state what is or isn't included. Leave the rest empty until later phases produce real decisions.

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

### Record Project Selection

Append to `${DECISIONS}` → User Clarifications: which project was selected and which repositories will be researched. This locks the research scope so reviewers don't propose pulling in patterns from unrelated repos.

---

## Phase 3: Parallel Capability Research

### Research Depth Contract

Story refinement operates on user-observable behavior, not implementation. This phase mirrors the research-depth guardrail in `writing-agile-stories` (see SKILL.md "Research Depth"). Code-level research — call graphs, internal services, schemas, file paths, integration points — biases the synthesis in Phase 4 even when individual scenarios pass the leak hunt. Stay at the capability level by default.

Allowed research, in order of preference:

1. **Capability inventory** via `capability-locator` (default) — reads entry points only (routes, pages, CLI commands, public APIs).
2. **User-visible string scan** via narrowly-scoped `codebase-analyzer` (fallback only) — reserved for surfacing error messages, status names, validation messages, and label/help text when capability inventory alone yields insufficient domain vocabulary or failure-mode signal. NEVER ask this fallback for code paths, services, schemas, integration points, or file locations.

If both layers return thin results, push back to the user for behavior-level input rather than reverse-engineering behavior from implementation.

### Layer 1: Capability Inventory (default)

For each repository in the selected project, spawn a `capability-locator` agent in parallel. Each agent gets a self-contained prompt with all context embedded (no references to parent conversation).

For each `${REPO}`, use the Task tool to spawn a `capability-locator` agent:

```markdown
# Capability Inventory for Story Refinement

You are inventorying the user-facing capability surface of `${REPO}` to ground a Jira issue refinement in what users can currently see and do.

## Jira Issue Context

- **Issue**: ${ISSUE_KEY} - ${SUMMARY}
- **Description**: ${DESCRIPTION}
- **Comments**: ${COMMENT_SUMMARIES}

## Research Focus

Read entry points ONLY (routes, page/screen components, CLI command definitions, public API methods). Do not read internals, trace call graphs, or describe how things are built.

### 1. Relevant Capabilities
- What user-facing entry points relate to the concepts in this issue?
- What can a user currently see or do in this area?

### 2. Domain Vocabulary
- What terms appear in route paths, page titles, CLI command names, or public API method names that relate to this issue?
- Note the language the user actually encounters — not internal class names.

### 3. Observable Boundaries
- What entry points are gated, hidden, or absent that suggest current scope limits?
- What status values, modes, or states are visible at the entry-point level?

## Output Format

### Capability Inventory [Story input]
[List of relevant user-facing entry points with one-line capability statements — what a user can see or do. Never describe internal mechanisms.]

### Domain Vocabulary [Story input]
[Terms visible in user-facing surface — routes, labels, command names. Note rejected synonyms if you spot legacy terms that have been replaced.]

### Observable Boundaries [Story input]
[Visible status values, modes, gating signals at the entry-point level.]
```

### Layer 2: User-Visible String Scan (fallback only)

Invoke this layer only if Layer 1 returned insufficient signal for drafting (no relevant entry points found, or domain vocabulary too thin to support scenario writing). Skip otherwise.

For each `${REPO}` that needs the fallback, use the Task tool to spawn a `codebase-analyzer` agent with this **narrowly-scoped** prompt:

```markdown
# User-Visible String Scan

You are scanning `${REPO}` for user-facing strings to surface domain vocabulary and observable failure modes for story refinement. This is NOT a full code analysis.

## Jira Issue Context

- **Issue**: ${ISSUE_KEY} - ${SUMMARY}
- **Description**: ${DESCRIPTION}

## Strict Scope

Return ONLY user-visible strings. Do NOT report:
- File paths, line numbers, function names, class names, service names
- Code paths, call graphs, integration points, schemas, dependencies
- How any of this is implemented or structured

Return ONLY:

### Error and Validation Messages [Story input]
[Strings shown to users when something goes wrong — error text, validation copy, rejection reasons]

### Status and State Names [Story input]
[Status values, modes, or state names as they appear to users — labels, badges, displayed states]

### Label, Help, and Confirmation Text [Story input]
[Button text, field labels, help text, confirmation prompts visible to users]

If you cannot answer without referencing internal code structures, say "Insufficient user-visible signal" and stop.
```

### Wait for All Agents

Collect research results from all repositories (and any fallback scans) before proceeding.

### Present Research Summary

Combine findings from all repositories into a consolidated summary. Present to user before drafting.

### Capture Constraints and Glossary

From the consolidated research:

- Append concrete bounding facts to `${DECISIONS}` → Constraints. Only capture facts that *constrain the story* in observable terms (e.g., "Cancellation only available while order is in 'confirmed' or 'processing' status", "Refund button hidden once shipment leaves warehouse"). Skip generic observations and any internal-architecture notes.
- Append canonical domain terms to `${DECISIONS}` → Domain Glossary, including any rejected synonyms surfaced in the research that should NOT be used.

---

## Phase 4: Story Drafting

### Synthesis

Invoke the `thinking-patterns` skill with atomic-thought (`/thinking atomic-thought`) to decompose Jira context + capability research into story components:

```
Independent questions to answer from gathered context:

1. **Actor**: Who experiences this need? (from Jira description + capability surface)
2. **Trigger**: What situation or event creates this need? (from Jira + capability inventory)
3. **Outcome**: What observable result do they want? (from Jira description + comments)
4. **Constraints**: What user-observable rules apply? (from observable boundaries + Jira)
5. **Failure Modes**: What could go wrong? (from error/validation messages + Jira)
6. **Domain Terms**: What vocabulary should the story use? (from capability vocabulary + Jira)

Answer each independently, then synthesize.
```

### Draft Story

Load the `writing-agile-stories` skill for the story format, drafting principles, and the implementation-leak prohibition. Apply the skill's guidance directly. Then add the flow-specific classification step below before drafting any scenario.

#### Pre-write classification (specific to this flow)

Classify every gathered fact from this flow:

| Bucket | Source | Use in story? |
|--------|--------|---------------|
| Domain language | Domain Vocabulary (research) + Jira terms | YES — as the story's vocabulary |
| Observable business rule | Observable Boundaries + Jira description | YES — as Given/Then conditions |
| Observable failure mode | Error/Validation Messages (fallback scan) + Jira | YES — as failure scenarios |
| Technical constraint | Anything referencing services, schemas, code paths, or file locations | NO — defense-in-depth: research is no longer asked for these, but reject any leakage |

If a fact lives in the last bucket, it does NOT belong in the story even when it bounds the implementation. It belongs in the downstream implementation plan, not here.

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

Use `/thinking chain-of-thought` to work through each review criterion systematically.

## DECISIONS (already settled — treat as fixed unless you can justify a Charter Challenge)

${DECISIONS}

## The Story to Review

${STORY_CONTENT}

## Step 1 — Leak Hunt (do this BEFORE the general checklist)

Scan each Given / When / Then in every scenario for any of these implementation leaks:

- HTTP/API references ("the API returns", "endpoint", status codes)
- Database or storage references ("row inserted", "cache cleared", named tables)
- UI element references ("button clicked", "modal appears", "page loads")
- Code paths or named services/classes ("OrderService", "handler", "controller")
- Technical mechanisms ("retries", "queue", "Kafka", "Redis", "polling")

Any leak found is a **Critical** issue. The required fix is a *rewrite* of the scenario in observable-behavior terms — not a wording tweak. Propose the rewritten Given/When/Then explicitly in your suggestion.

Apply the Farley test to anything ambiguous: would this scenario still make sense if the system were replaced with a different implementation that fulfills the same behavior? If no, it leaks.

Record leak findings in **Issues Within Scope** with severity Critical, location pointing to the specific Given/When/Then line, and a concrete rewritten scenario as the suggestion.

## Step 2 — Quality Checklist

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
Do failure scenarios correspond to real constraints found in capability research?

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
Without capability research, the story will rely solely on Jira context.

Would you like to:
1. Provide repository paths
2. Continue without capability research
```

### Research Agent Timeout

```
Capability research for ${REPO} is taking longer than expected. Options:
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
3. Shows project list from projects.yaml, user selects the relevant project
4. Spawns capability-locator agents for the project's repositories in parallel (Layer 1); falls back to a narrowly-scoped user-visible string scan only if capability inventory is thin
5. Synthesizes Jira + capability context using atomic-thought
6. Drafts story with narrative + Given-When-Then scenarios
7. User approves draft for review
8. Review 1: Agile practitioner evaluates quality and testability
9. User incorporates feedback, self-consistency check
10. Review 2: Skeptical product owner validates completeness and scope
11. User finalizes, self-consistency check
12. Presents final story, user chooses to update Jira description
