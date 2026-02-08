---
description: Generate a Product Brief from text, file, or Notion document with iterative review
argument-hint: "[source: text, file path, or Notion URL/title]"
model: opus
allowed-tools: Read, Write, Edit, Task, AskUserQuestion, Bash(git metadata, date)
---

# Generate Product Brief

**Level 4 (Delegation)** - Orchestrates sub-agents for independent review cycles.

Create a Product Brief using the `writing-product-briefs` skill with iterative multi-agent review. Each review happens in a clean context window to ensure unbiased evaluation.

## Variables

- **SOURCE**: `$ARGUMENTS` - Text, file path, or Notion URL/title
- **OUTPUT_PATH**: Determined in Phase 7 (user-specified)
- **MAX_REVIEW_CYCLES**: 2 (fixed - prevents infinite refinement loops)

## Dependencies

- **writing-product-briefs skill**: Core methodology for brief generation (read SKILL.md)
- **Thinking patterns** (invoke via `/thinking <pattern>`): atomic-thought, self-consistency
- **MCP Servers** (optional):
  - Notion MCP - for fetching Notion pages directly

## Initial Response

When invoked:

1. **If a source was provided**: Detect source type and begin acquisition
2. **If no source provided**, respond with:

```
I'll help you create a Product Brief with iterative expert review.

What's your source? You can provide:
- Text: Paste your product idea or problem statement directly
- File path: `~/docs/product-idea.md`
- Notion page: URL, page ID, or search by title

I'll guide you through:
1. Initial brief generation using the writing-product-briefs skill
2. First expert review (clean context)
3. Refinement based on feedback
4. Second expert review (clean context)
5. Final refinement and delivery
```

---

## Phase 1: Input Acquisition

### Source Detection

```
INPUT DETECTION RULES:

Path (starts with /, ~, or ./)
  → Use Read tool to get file contents

Notion source (URL, page ID, or title search)
  → PREFERRED: Use Notion MCP tools
  → FALLBACK: WebFetch for public pages if MCP unavailable
  → LAST RESORT: Prompt for markdown export

Raw text (no path indicators, no URL pattern)
  → Use provided text directly as source material
```

### Notion MCP Integration

When Notion MCP tools are available, use them to fetch page content directly.

**Detecting Notion MCP availability**:
Check if these MCP tools are available: `notion_search`, `notion_get_page`, `notion_get_block_children`

**Notion source formats**:
```
Full URL:       https://notion.so/workspace/Page-Title-abc123def456
Short URL:      https://notion.so/abc123def456
Page ID:        abc123def456 (32 character hex string)
Title search:   "My Product Idea" (quoted string, no URL pattern)
```

**Fetching with Notion MCP**:

1. **From URL or Page ID**:
   - Extract page_id from URL (last path segment, remove hyphens)
   - Use notion_get_page(page_id) to get page metadata
   - Use notion_get_block_children(page_id) to get page content
   - Recursively fetch nested blocks if needed

2. **From title search**:
   - Use notion_search(query="title text") to find matching pages
   - If multiple matches, present options via AskUserQuestion
   - Then fetch selected page using page_id

3. **Converting Notion blocks to markdown**:
   - Process block types appropriately (paragraphs, headings, lists, etc.)
   - Preserve rich text formatting

**Fallback when MCP unavailable**:
```
Notion MCP is not available. Alternative methods:
1. If the page is public, I can fetch it via WebFetch
2. Otherwise, please export the page from Notion:
   - Open the page in Notion
   - Click ••• menu → Export → Markdown & CSV
   - Provide the exported file path
```

---

## Phase 2: Initial Brief Generation

Read and follow the methodology in the `writing-product-briefs` skill (SKILL.md) to generate the first draft.

### Pre-Generation Analysis

Apply `/thinking atomic-thought` to decompose the source material:

```
Independent questions to answer:
1. What is the core problem or need being addressed?
2. Who are the target users/audiences?
3. What value does this product provide?
4. What constraints or risks exist?
5. What does success look like?

Answer each independently, then synthesize for the skill.
```

### Generation

Work through the writing-product-briefs skill phases:
1. **Discovery**: Extract problem and context from source
2. **Thesis**: Develop claims and honest risks
3. **Audience & Metrics**: Define personas and success metrics
4. **Scenarios**: Create north star narrative stories

### Draft Presentation

Present the initial brief to the user:

```
## Initial Product Brief Draft

[Full brief content following the skill's output template]

---

This draft is ready for expert review. The review will happen in a clean
context window to ensure unbiased evaluation.
```

**AskUserQuestion**:
- Header: "Review"
- Question: "Ready to send this draft for expert review?"
- Options:
  - "Yes, proceed to review" → Continue to Phase 3
  - "Make adjustments first" → Ask user what to change, apply edits, then re-present draft with same question

---

## Phase 3: First Review (Clean Context)

**CRITICAL**: Launch a sub-agent with NO access to the generation context. The reviewer must evaluate the brief purely on its merits.

### Reviewer Agent Prompt

Use the Task tool to spawn a `general-purpose` agent (model: `sonnet` for speed, or `opus` for depth). When constructing the prompt, substitute `${BRIEF_CONTENT}` with the complete brief text:

```markdown
# Product Brief Expert Review

You are a senior product manager reviewing a Product Brief for quality,
completeness, and actionability. You have NOT seen how this brief was
created - evaluate it purely on its merits.

## The Brief to Review

${BRIEF_CONTENT}

## Review Criteria

Evaluate against these dimensions:

### 1. Thesis Strength
- Are claims specific and falsifiable?
- Do they explain WHY this will work?
- Are they too safe (obvious) or too risky (unfounded)?

### 2. Antithesis Honesty
- Are real risks acknowledged?
- Are they specific enough to act on?
- Is there anything conveniently omitted?

### 3. Audience Clarity
- Are personas specific and believable?
- Do they represent real user segments?
- Is the "who" clear enough to build for?

### 4. Metrics Quality
- Are metrics outcome-focused (not feature-focused)?
- Do they have baselines and targets?
- Can we actually measure these?

### 5. Scenario Strength
- Do scenarios tell compelling stories?
- Do they reveal requirements naturally?
- Is there at least one failure/escalation case?
- Is implementation absent from scenarios?

### 6. Overall Completeness
- Does the brief enable action?
- Would an engineer know what to build?
- Would a designer know who they're designing for?
- Are there obvious gaps?

## Output Format

Provide your review as:

### Strengths
[What's done well - be specific]

### Issues Found
For each issue:
- **Section**: [Which part of the brief]
- **Severity**: [Critical/Major/Minor]
- **Issue**: [What's wrong]
- **Suggestion**: [How to fix it]

### Overall Assessment
- **Quality Score**: [1-10]
- **Ready for PRD?**: [Yes/Yes with minor fixes/No - needs revision]
- **Top 3 Improvements Needed**: [Prioritized list]
```

### Collect Review Feedback

When the review agent completes:

1. Present review findings to user
2. Ask about incorporating feedback

**AskUserQuestion**:
- Header: "Review 1"
- Question: "How would you like to incorporate this feedback?"
- Options:
  - "Accept all suggestions" → Incorporate all feedback
  - "Accept some suggestions" → Ask which to accept
  - "Discuss specific feedback" → Explore particular issues
  - "Skip to second review" → Keep draft as-is

---

## Phase 4: First Refinement

Based on accepted feedback:

1. **Update the brief** with changes
2. **Apply `/thinking self-consistency`** to verify changes don't break coherence:

```
Verify the refined brief:

Path 1 - Thesis-Scenario Alignment:
Do scenarios still demonstrate the thesis claims?

Path 2 - Persona-Scenario Alignment:
Are personas represented in scenarios?

Path 3 - Metric-Outcome Alignment:
Do scenarios show how metrics would be captured?

Synthesize: Any inconsistencies introduced by refinements?
```

3. **Present refined brief** to user

---

## Phase 5: Second Review (Clean Context)

**CRITICAL**: Again, launch a fresh sub-agent with NO access to previous context. This ensures independent validation.

### Reviewer Agent Prompt (Different Perspective)

Use the Task tool to spawn a `general-purpose` agent (model: `sonnet` for speed, or `opus` for depth). When constructing the prompt, substitute `${BRIEF_CONTENT}` with the complete refined brief text:

```markdown
# Product Brief Validation Review

You are a skeptical stakeholder reviewing a Product Brief. Your job is
to find holes that would cause problems downstream. You have NOT seen
previous versions - evaluate this brief fresh.

## The Brief to Review

${BRIEF_CONTENT}

## Validation Focus

### 1. Feasibility Check
- Are the claims realistic given typical constraints?
- Do any scenarios assume capabilities that might not exist?
- Are there hidden technical assumptions?

### 2. Scope Creep Risk
- Is the scope well-bounded?
- Are there sections that hint at more than stated?
- Would stakeholders agree on what's in/out?

### 3. Measurability
- Can the proposed metrics actually be tracked?
- Are baselines established or assumed?
- How would we know if we succeeded?

### 4. Stakeholder Alignment
- Would different teams interpret this the same way?
- Are there ambiguous statements that could cause conflict?
- Is the "why" clear enough to survive pushback?

### 5. Readiness for Next Steps
- Is this actionable for writing requirements?
- Could someone create user stories from this?
- What questions would remain after reading this?

## Output Format

### Validation Results
For each focus area:
- **Status**: [Pass/Concern/Fail]
- **Finding**: [What you observed]
- **Risk**: [If concern/fail, what could go wrong]
- **Recommendation**: [How to address]

### Remaining Questions
[Questions this brief doesn't answer that should be addressed]

### Final Verdict
- **Brief Quality**: [Strong/Adequate/Weak]
- **Confidence Level**: [High/Medium/Low]
- **Recommendation**: [Proceed/Minor revisions/Major revisions]
```

### Collect Validation Feedback

When the validation agent completes:

1. Present findings to user
2. Ask about final refinements

**AskUserQuestion**:
- Header: "Review 2"
- Question: "Final feedback received. How would you like to proceed?"
- Options:
  - "Accept and finalize" → Incorporate feedback, proceed to output
  - "Selective incorporation" → Ask which feedback to use
  - "Brief is ready as-is" → Skip refinement, proceed to output

---

## Phase 6: Final Refinement

1. **Incorporate any final feedback**
2. **Final coherence check** with `/thinking self-consistency`
3. **Prepare final brief**

---

## Phase 7: Output

**AskUserQuestion**:
- Header: "Output"
- Question: "Where should I save the final Product Brief?"
- Options:
  - "Display only" → Show but don't save
  - "Custom path" → Ask for path

### Final Output Format

```markdown
---
type: product-brief
created: YYYY-MM-DD
source: "[Original source type and reference]"
---

# Product Brief: [Product Name]

[Full refined brief content]

---

## Review History

### Review 1
- Score: [X/10]
- Key improvements made: [List]

### Review 2
- Verdict: [Strong/Adequate/Weak]
- Final adjustments: [List]

---

## Next Steps

Based on this brief, consider:
1. Create PRD using `/writing-prds` skill
2. Generate user stories using `/generate-stories`
3. Begin discovery with engineering/design stakeholders
```

---

## Error Handling

### Empty Source
```
I didn't receive any source material. Please provide:
- Text describing your product idea or problem
- A file path to existing documentation
- A Notion page URL or title
```

### Notion Access Failed
```
I couldn't access the Notion page. Options:
1. Check if the page is shared with the Notion integration
2. Export the page as Markdown and provide the file path
3. Copy and paste the content directly
```

### Review Agent Timeout
```
The review is taking longer than expected. Options:
1. Wait for completion (recommended)
2. Skip this review and proceed with current draft
3. Cancel and save current state
```

---

## Example Session

```bash
/product-brief ~/ideas/notification-system.md
```

1. Reads the file
2. Generates initial brief using writing-product-briefs skill
3. Launches Review 1 agent (clean context)
4. Incorporates feedback
5. Launches Review 2 agent (clean context)
6. Finalizes and presents the brief
