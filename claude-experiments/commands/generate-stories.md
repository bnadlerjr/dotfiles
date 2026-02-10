---
description: Transform product documents (ShapeUp Pitches, Product Canvas, PRDs) into behavior-focused user stories
model: opus
---

# Generate Stories from Source

Transform product specification documents into well-formed user stories using the `writing-agile-stories` skill methodology.

## Dependencies

- **writing-agile-stories skill**: `~/dotfiles/claude/skills/writing-agile-stories/SKILL.md`
- **Thinking patterns**: atomic-thought, skeleton-of-thought, tree-of-thoughts, chain-of-thought, self-consistency
- **MCP Servers** (optional):
  - Notion MCP - for fetching Notion pages directly
  - Jira MCP - alternative to `managing-jira` skill

## Initial Response

When this command is invoked:

1. **If a source was provided**: Detect source type and begin acquisition
2. **If no source provided**, respond with:

```
I'll help you transform a product document into user stories.

What's your source? You can provide:
- A file path: `~/docs/pitch.md`
- A Notion page: URL, page ID, or search by title
- A generic URL: `https://docs.example.com/pitch`
- A Jira epic: `PROJ-123`
- Or paste the content directly

Optional: Add `--format=pitch|canvas|prd` to specify the document type.
```

---

## Phase 1: Input Acquisition

### Source Detection

```
INPUT DETECTION RULES:

Path (starts with /, ~, or ./)
  → Use Read tool to get file contents

Notion source (URL, page ID, or title search)
  → PREFERRED: Use Notion MCP tools (see Notion MCP Integration below)
  → FALLBACK: WebFetch for public pages if MCP unavailable
  → LAST RESORT: Prompt for markdown export

Generic URL (starts with http:// or https://, not Notion)
  → Use WebFetch to retrieve content

Jira Reference (matches [A-Z]+-[0-9]+)
  → Use `managing-jira` skill to fetch epic details
  → Command: jira issue view PROJ-123

No source provided
  → Prompt user to paste content
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
Title search:   "My Pitch Document" (quoted string, no URL pattern)
```

**Fetching with Notion MCP**:

1. **From URL or Page ID**:
   ```
   Extract page_id from URL (last path segment, remove hyphens)

   Use notion_get_page(page_id) to get page metadata
   Use notion_get_block_children(page_id) to get page content

   Recursively fetch nested blocks if needed
   ```

2. **From title search**:
   ```
   Use notion_search(query="title text") to find matching pages

   If multiple matches, present options via AskUserQuestion:
   - Header: "Notion page"
   - Question: "Multiple pages found. Which one?"
   - Options: [List of matching page titles]

   Then fetch selected page using page_id
   ```

3. **Converting Notion blocks to markdown**:
   ```
   Process block types:
   - paragraph → plain text
   - heading_1/2/3 → # / ## / ###
   - bulleted_list_item → - item
   - numbered_list_item → 1. item
   - to_do → - [ ] or - [x]
   - code → ```language\ncode\n```
   - quote → > text
   - callout → > [icon] text
   - divider → ---
   - toggle → convert to heading + nested content
   - child_page → note reference, optionally fetch recursively

   Preserve rich text formatting (bold, italic, links)
   ```

**Fallback when MCP unavailable**:
```
Notion MCP is not available. I'll try alternative methods:

1. If the page is public, I can fetch it via WebFetch
2. Otherwise, please export the page from Notion:
   - Open the page in Notion
   - Click ••• menu → Export → Markdown & CSV
   - Provide the exported file path
```

### Format Override

If `--format=X` is provided, use that format. Otherwise, auto-detect.

Supported formats:
- `pitch` - ShapeUp Pitch
- `canvas` - Product Canvas / Lean Canvas
- `prd` - Product Requirements Document
- `brief` - Product/Creative Brief
- `auto` - Auto-detect (default)

---

## Phase 2: Document Analysis

**Apply `atomic-thought` skill** to decompose the document.

### Decomposition Prompt

```
Apply atomic-thought to analyze this document:

Independent questions to answer:
1. What type of document is this? (pitch/canvas/prd/brief/other)
2. What is the core problem or need being addressed?
3. Who are the target users/actors?
4. What solution elements or features are proposed?
5. What constraints, risks, or no-gos are mentioned?
6. What does success look like? (metrics, outcomes)
7. What is the scope/appetite? (time, budget, boundaries)

Answer each independently, then synthesize into a structured summary.
```

### Document Type Detection

**ShapeUp Pitch indicators**:
- Sections: "Problem", "Appetite", "Solution", "Rabbit Holes", "No-gos"
- Time-boxing language: "6-week", "2-week", "small batch", "big batch"
- Fat marker sketch references

**Product Canvas indicators**:
- Sections: "Target Users", "User Problems", "Features", "Metrics"
- Grid/structured layout
- Business model elements: "Value Proposition", "Channels"

**PRD indicators**:
- Sections: "Requirements", "Specifications", "User Stories"
- Technical details: "Architecture", "API", "Data Model"
- Numbered requirements (REQ-001, FR-001)

**Generic/Brief**:
- No clear structure matching above
- Narrative description of a need or feature

### Present Analysis

After analysis, present findings:

```
## Document Analysis

**Type Detected**: [ShapeUp Pitch / Product Canvas / PRD / Generic]
**Title**: [Document title if found]
**Scope/Appetite**: [Time constraint if mentioned]

### Core Problem
[1-2 sentences summarizing the problem/need]

### Target Users
- [User type 1]
- [User type 2]

### Proposed Solution Elements
1. [Feature/capability 1]
2. [Feature/capability 2]
3. [Feature/capability 3]

### Constraints & Risks
- [Constraint 1]
- [Risk to avoid]

### Out of Scope (No-gos)
- [Explicit exclusion 1]
- [Explicit exclusion 2]

### Success Criteria
- [Metric or outcome 1]
- [Metric or outcome 2]
```

**AskUserQuestion**:
- Header: "Analysis"
- Question: "Is this analysis of the source document correct?"
- Options:
  - "Yes, continue to story breakdown" → Proceed to Phase 3
  - "Adjust the analysis" → Ask what to correct, re-analyze
  - "Wrong document type" → Ask for correct type, re-analyze

---

## Phase 3: Story Extraction

**Apply `skeleton-of-thought` skill** to outline stories before detailing.

### Extraction Prompt

```
Apply skeleton-of-thought to identify user stories:

Phase 1 - Skeleton only:
For each solution element or user need identified, create a story seed:
- Story title (behavior-focused, not feature-focused)
- Primary actor
- Core need being addressed
- Key acceptance criteria themes

Do NOT write full stories yet - just the skeleton.

Phase 2 - Dependency mapping:
- Which stories depend on others?
- What's the logical implementation order?
- Are any stories too large and need splitting?
```

### Story Slicing Guidance

**If document has "Appetite" (ShapeUp)**:
- 6-week cycle → Expect 4-8 stories
- 2-week cycle → Expect 2-4 stories
- Small batch → Expect 1-2 stories

**If stories seem too large**, apply `tree-of-thoughts`:
```
Apply tree-of-thoughts to explore story slicing options:

This story seems large. Explore three ways to split it:
1. By user workflow step (horizontal slice)
2. By feature depth (vertical slice - basic → advanced)
3. By user type (if multiple actors)

Evaluate each approach and recommend the best split.
```

### Present Story Outline

```
## Proposed Story Breakdown

Based on the document, I've identified these stories:

### Stories to Generate

1. **[Story Title 1]**
   - Actor: [Who]
   - Need: [What they need to do]
   - Key scenarios: [Happy path], [Failure case]

2. **[Story Title 2]**
   - Actor: [Who]
   - Need: [What they need to do]
   - Key scenarios: [Happy path], [Alternative], [Failure case]

3. **[Story Title 3]**
   - Actor: [Who]
   - Need: [What they need to do]
   - Key scenarios: [Happy path], [Edge case]

### Dependencies
- Story 2 depends on Story 1 (needs [X] to exist first)
- Stories 3 and 4 are independent

### Out of Scope (from source)
- [No-go 1 - will NOT generate stories for this]
- [No-go 2]

### Estimated Output
[N] stories covering the scope of this [pitch/canvas/document]
```

**AskUserQuestion**:
- Header: "Stories"
- Question: "Is this the right story breakdown?"
- Options:
  - "Yes, generate full stories" → Proceed to Phase 4
  - "Merge some stories" → Ask which to merge
  - "Split a story further" → Ask which to split, apply tree-of-thoughts
  - "Add missing stories" → Ask what's missing
  - "Remove stories" → Ask which to remove

---

## Phase 4: Story Generation

**Apply `writing-agile-stories` skill** for each story.

### Generation Process

For each story in the approved outline:

1. **Write the narrative** (NOT "As a user, I want...")
   - Describe the situation that creates the need
   - Focus on observable behavior
   - Use domain language from the source document

2. **Add context section**
   - When this behavior is relevant
   - Preconditions from a business perspective

3. **Write acceptance criteria** using Given-When-Then
   - Apply `chain-of-thought` for complex business logic
   - Include happy path, alternatives, and failure modes
   - Reference constraints from source document

4. **Add source traceability**
   - Which section of the original document this addresses
   - Link to original problem/solution element

### Quality Checklist (per story)

Apply the writing-agile-stories skill quality checks:
- [ ] Behavior-focused (no implementation details)
- [ ] Domain language throughout
- [ ] Narrative form (no "As a user" template)
- [ ] Small and testable
- [ ] Failure modes included
- [ ] Scenarios are independent

### Batch vs. Individual Review

**AskUserQuestion**:
- Header: "Generation"
- Question: "How would you like to review the generated stories?"
- Options:
  - "Generate all, review together" → Generate all stories, present batch
  - "Review each story individually" → Generate one at a time with feedback
  - "Generate all, no review needed" → Generate and proceed to output

### Present Generated Stories

If batch review:

```
## Generated Stories

---

### Story 1: [Title]

[Narrative - 2-4 sentences]

#### Context
[When this applies]

#### Acceptance Criteria

**Scenario: [Happy path]**
- Given [context]
- When [action]
- Then [outcome]

**Scenario: [Alternative/Failure]**
- Given [context]
- When [action]
- Then [outcome]

#### Source Traceability
- Derived from: [Section of original document]
- Addresses: [Problem/need from source]

---

### Story 2: [Title]
[...]

---

[Continue for all stories]
```

---

## Phase 5: Verification

**Apply `self-consistency` skill** to verify coverage.

### Verification Prompt

```
Apply self-consistency to verify story coverage:

Path 1 - Forward trace:
For each element in the original document's solution/features section,
verify at least one story addresses it.

Path 2 - Backward trace:
For each generated story, verify it maps to a stated need or solution
element in the original document.

Path 3 - Gap analysis:
Are there any user needs implied but not explicitly stated that we missed?

Synthesize: Do the paths agree? Any gaps or over-coverage?
```

### Present Verification

```
## Coverage Verification

### Forward Trace (Source → Stories)
| Source Element | Covered By |
|----------------|------------|
| [Solution element 1] | Story 1, Story 3 |
| [Solution element 2] | Story 2 |
| [Solution element 3] | Story 4 |

### Backward Trace (Stories → Source)
| Story | Addresses |
|-------|-----------|
| Story 1 | Problem statement, Solution element 1 |
| Story 2 | Solution element 2 |
| Story 3 | Solution element 1 (detail) |
| Story 4 | Solution element 3 |

### Gap Analysis
- ✅ All solution elements covered
- ✅ All stories trace to source
- ⚠️ [Any gaps or concerns]

### Out of Scope Confirmed
- [No-go 1] - Correctly excluded
- [No-go 2] - Correctly excluded
```

**AskUserQuestion**:
- Header: "Verification"
- Question: "Coverage looks complete. Ready to output?"
- Options:
  - "Yes, choose output destination" → Proceed to Phase 6
  - "Add more stories" → Return to Phase 4
  - "Adjust existing stories" → Ask which to adjust
  - "Re-verify" → Run self-consistency again

---

## Phase 6: Output

**AskUserQuestion**:
- Header: "Output"
- Question: "Where should I save these stories?"
- Options:
  - "Markdown file" → Write to a markdown file
  - "Jira tickets" → Create via `managing-jira` skill
  - "Both markdown and Jira" → Do both
  - "Display only" → End without saving

### Markdown Output

Write file with naming: `YYYY-MM-DD-[source-title]-stories.md`

**Output Template**:

```markdown
---
tags: [stories, generated, DOCUMENT_TYPE]
Source: "[[SOURCE_TITLE]]"
Generated: YYYY-MM-DD
Appetite: [If from ShapeUp]
---

# Stories: [Source Title]

## Source Summary
[2-3 sentence summary of the original document]

**Document Type**: [ShapeUp Pitch / Product Canvas / PRD]
**Appetite/Scope**: [If applicable]
**Target Users**: [User types]

## Out of Scope
[From No-gos or explicit exclusions]
- [Exclusion 1]
- [Exclusion 2]

## Risks to Avoid
[From Rabbit Holes or constraints]
- [Risk 1]
- [Risk 2]

---

## Story 1: [Title]

[Narrative]

### Context
[When this applies]

### Acceptance Criteria

#### Scenario: [Name]
- Given [context]
- When [action]
- Then [outcome]

[Additional scenarios...]

### Source Traceability
- **Derived from**: [Section]
- **Addresses**: [Problem/need]

---

## Story 2: [Title]
[...]

---

## Dependencies

[If stories have dependencies]
- Story 2 depends on Story 1
- Story 3 and 4 are independent

## Open Questions

[Anything unclear from the source]
- [Question 1]
- [Question 2]
```

### Jira Output

Use `managing-jira` skill:

1. **Create Epic** (if source is a pitch/canvas):
   ```
   Create a Jira epic with:
   - Title: [Source document title]
   - Description: [Source summary + out of scope]
   ```

2. **Create Stories** linked to epic:
   ```
   For each generated story, create a Jira issue:
   - Type: Story
   - Title: [Story title]
   - Description: [Narrative + Context]
   - Acceptance Criteria: [Given-When-Then scenarios]
   - Epic Link: [Epic created above]
   ```

3. **Report created tickets**:
   ```
   Created Jira tickets:
   - Epic: PROJ-100 - [Title]
     - PROJ-101 - Story 1: [Title]
     - PROJ-102 - Story 2: [Title]
     - PROJ-103 - Story 3: [Title]
   ```

---

## Thinking Pattern Summary

| Phase | Pattern | Purpose |
|-------|---------|---------|
| 2. Analysis | `atomic-thought` | Decompose document into independent concerns |
| 3. Extraction | `skeleton-of-thought` | Outline stories before detailing |
| 3. Extraction | `tree-of-thoughts` | Explore story slicing options when large |
| 4. Generation | `writing-agile-stories` skill | Full story methodology |
| 4. Generation | `chain-of-thought` | Trace complex business logic for AC |
| 5. Verification | `self-consistency` | Multi-path verification of coverage |

---

## Error Handling

### Notion MCP Not Available
```
Notion MCP tools are not available in this session.

Alternative options:
1. If the page is public, I can try fetching via WebFetch
2. Export the page from Notion (••• menu → Export → Markdown & CSV)
3. Copy and paste the content directly

To enable Notion MCP, configure the Notion MCP server in your Claude settings.
```

### Notion Page Not Found
```
I couldn't find a Notion page matching "[query]".

Please check:
1. The page ID or URL is correct
2. The Notion integration has access to this page
3. Try searching by exact title: /generate-stories "Exact Page Title"
```

### Notion Permission Denied
```
The Notion integration doesn't have access to this page.

To fix this:
1. Open the page in Notion
2. Click "Share" in the top right
3. Under "Connections", add the Claude integration
4. Try again
```

### Private Notion Page (WebFetch fallback)
```
This appears to be a private Notion page and Notion MCP is not available.

Please either:
1. Configure Notion MCP for direct access
2. Share the page with the Notion integration
3. Export the page as Markdown (••• menu → Export → Markdown)
4. Copy and paste the content here
```

### Unrecognized Format
```
I couldn't detect a standard document format (pitch, canvas, PRD).

I'll treat this as a generic product document and extract what I can.
You may want to manually identify:
- Which sections describe the problem
- Which sections describe the solution
- Any explicit exclusions or constraints
```

### Document Has Existing Stories
```
This document already contains user stories.

Would you like me to:
1. Refine the existing stories using the writing-agile-stories methodology
2. Generate new stories and compare to existing
3. Extract non-story content and generate fresh stories
```

### Very Large Document
```
This document describes [N] features/capabilities. Generating stories
for all of them would produce [M] stories.

Would you like to:
1. Generate all stories (may take a while)
2. Prioritize a subset - which features are most important?
3. Generate stories for the first [X] features only
```

---

## Examples

### Example 1: Local File

```bash
/generate-stories ~/pitches/notifications-redesign.md
```

Reads local markdown file, auto-detects format, generates stories.

### Example 2: Notion URL (via MCP)

```bash
/generate-stories https://notion.so/team/Q1-Feature-Pitch-abc123def456
```

Uses Notion MCP to fetch page content directly, including nested blocks.

### Example 3: Notion Title Search (via MCP)

```bash
/generate-stories "Q1 Feature Pitch"
```

Searches Notion for pages matching the title. If multiple matches found, prompts for selection.

### Example 4: Notion Page ID (via MCP)

```bash
/generate-stories abc123def456789...
```

Directly fetches Notion page by ID (useful for pages with complex titles).

### Example 5: Jira Epic

```bash
/generate-stories PROJ-500
```

Reads epic description and linked requirements, generates stories to add to the epic.

### Example 6: Generic URL

```bash
/generate-stories https://docs.google.com/document/d/abc123/export?format=txt
```

Fetches content via WebFetch for non-Notion URLs.

### Example 7: With Format Override

```bash
/generate-stories ~/docs/requirements.md --format=canvas
```

Forces interpretation as Product Canvas even if auto-detection suggests otherwise.

### Example 8: Interactive (Paste Content)

```bash
/generate-stories
```

Prompts for source, then accepts pasted content directly.
