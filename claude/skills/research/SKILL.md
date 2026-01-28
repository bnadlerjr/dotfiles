---
name: research
description: "Document codebase as-is with thoughts directory for historical context. Use when exploring existing implementations, understanding architecture, or gathering context before changes. Produces structured research documents with code references."
---

# Research Codebase

Conduct comprehensive research across the codebase to answer user questions by spawning parallel sub-agents and synthesizing their findings.

## When This Skill Applies

- Exploring existing implementations before making changes
- Understanding architecture or system design
- Answering "how does X work?" questions about the codebase
- Documenting component interactions and data flows
- Gathering historical context from docs directory
- User asks to "research", "document", or "understand" something

## Invocation

**Command**: `/research` or `/research [topic]`

### Initial Response

When invoked:

1. **If a topic was provided**: Begin decomposing the research question

2. **If no topic provided**, respond with:
```
I'm ready to research the codebase. Please provide your research question or area of interest, and I'll analyze it thoroughly by exploring relevant components and connections.
```

## Critical Principle

**YOUR ONLY JOB IS TO DOCUMENT AND EXPLAIN THE CODEBASE AS IT EXISTS TODAY**

- DO NOT suggest improvements or changes unless explicitly asked
- DO NOT perform root cause analysis unless explicitly asked
- DO NOT propose future enhancements unless explicitly asked
- DO NOT critique the implementation or identify problems
- DO NOT recommend refactoring, optimization, or architectural changes
- ONLY describe what exists, where it exists, how it works, and how components interact
- You are creating a technical map/documentation of the existing system

---

## Phase 1: File Reading & Decomposition

**Goal**: Understand the research context and break down the question.

### Step 1: Read Mentioned Files

If the user mentions specific files (tickets, docs, JSON):
- Read them FULLY using the Read tool WITHOUT limit/offset parameters
- **CRITICAL**: Read these files yourself in the main context before spawning any sub-tasks
- This ensures you have full context before decomposing the research

### Step 2: Analyze and Decompose

- Break down the user's query into composable research areas
- Identify specific components, patterns, or concepts to investigate
- Consider which directories, files, or architectural patterns are relevant
- Create a research plan using TodoWrite to track all subtasks

### User Confirmation

Present your understanding of the research question and decomposition, then use **AskUserQuestion** to confirm:

- Header: "Research plan"
- Question: "Does this capture your research question correctly?"
- Options:
  - "Yes, proceed with research" → Continue to Phase 2
  - "Adjust the scope" → Ask what to adjust, then re-confirm
  - "Let me clarify" → Wait for clarification

---

## Phase 2: Parallel Research

**Goal**: Spawn specialized sub-agents to gather information concurrently.

### Specialized Agents

**For codebase research:**
- **serena-codebase-locator**: Find WHERE files and components live
- **codebase-analyzer**: Understand HOW specific code works (without critiquing it)
- **codebase-pattern-finder**: Find examples of existing patterns (without evaluating them)

**For docs directory:**
- **docs-locator**: Discover what documents exist about the topic
- **docs-analyzer**: Extract key insights from specific documents (only the most relevant ones)

**For web research (only if user explicitly asks):**
- **web-search-researcher**: External documentation and resources
- IF you use web-research agents, instruct them to return LINKS with their findings, and INCLUDE those links in your final report

### Agent Usage Guidelines

- Start with locator agents to find what exists
- Then use analyzer agents on the most promising findings
- Run multiple agents in parallel when they're searching for different things
- Each agent knows its job—just tell it what you're looking for
- Don't write detailed prompts about HOW to search—the agents already know
- **Remind agents they are documenting, not evaluating or improving**

### Important

- WAIT for ALL sub-agent tasks to complete before proceeding to Phase 3
- All agents are documentarians, not critics—they describe what exists without suggesting improvements

---

## Phase 3: Synthesis & Documentation

**Goal**: Compile findings and generate the research document.

### Step 1: Synthesize Findings

- Compile all sub-agent results (both codebase and docs findings)
- Prioritize live codebase findings as primary source of truth
- Use docs directory findings as supplementary historical context
- Connect findings across different components
- Include specific file paths and line numbers for reference
- Highlight patterns, connections, and architectural decisions
- Answer the user's specific questions with concrete evidence

### Step 2: Gather Metadata

**MUST** run the `git metadata` command to generate all relevant metadata.

Filename format: `$(claude-docs-path research)/YYYY-MM-DD-description.md`
- YYYY-MM-DD is today's date
- description is a brief kebab-case description of the research topic

Examples:
- `2025-01-08-parent-child-tracking.md`
- `2025-01-08-authentication-flow.md`

### Step 3: Generate Research Document

Use **AskUserQuestion** to get the project name:
- Header: "Project"
- Question: "What project name should I use for this research document?"
- Options: [Provide 2-3 likely options based on repository name, or let user specify]

Generate the document using the template at `templates/research-document.md`.

**Required sections**:
- YAML frontmatter (tags, Area, Created, Modified, Project)
- Header metadata block (Date, Git Commit, Branch, Repository, Topic, Tags, Status)
- Research Question, Summary, Detailed Findings
- Code References with file:line format
- Architecture Documentation, Historical Context, Related Research
- Open Questions for areas needing follow-up

### Step 4: Add GitHub Permalinks (if applicable)

- Check if on main branch or if commit is pushed: `git branch --show-current` and `git status`
- If on main/master or pushed, generate GitHub permalinks:
  - Get repo info: `gh repo view --json owner,name`
  - Create permalinks: `https://github.com/{owner}/{repo}/blob/{commit}/{file}#L{line}`
- Replace local file references with permalinks in the document

### User Review

Present a summary of the document, then use **AskUserQuestion**:

- Header: "Document review"
- Question: "Here's the research document. Does it address your question?"
- Options:
  - "Yes, looks good" → Continue to Phase 4
  - "Add more detail on [area]" → Expand that section
  - "I have follow-up questions" → Address them and update document

---

## Phase 4: Presentation & Follow-up

**Goal**: Present findings and handle additional questions.

### Present Findings

- Present a concise summary of findings to the user
- Include key file references for easy navigation
- Ask if they have follow-up questions or need clarification

### Handle Follow-up Questions

If the user has follow-up questions:
- Append to the same research document
- Update the heading fields `Last Updated` to reflect the update
- Add `Last Updated Note: "Added follow-up research for [brief description]"` to headings
- Add a new section: `## Follow-up Research [timestamp]`
- Spawn new sub-agents as needed for additional investigation
- Continue updating the document

### Next Action

Use **AskUserQuestion** for next action:

- Header: "Next step"
- Question: "Research is complete. What would you like to do?"
- Options:
  - "Follow-up question" → Handle follow-up and update document
  - "Start related research" → Begin new research with shared context
  - "Done" → End workflow

---

## Anti-Patterns

### Suggesting Improvements
```
❌ "The authentication flow could be simplified by..."
❌ "This would benefit from refactoring..."

✅ "The authentication flow works by first checking..."
✅ "This module handles X by doing Y..."
```

### Critiquing Implementation
```
❌ "This is a problematic pattern because..."
❌ "The code has issues with..."

✅ "The current implementation uses this pattern..."
✅ "The code handles this case by..."
```

### Missing Concrete References
```
❌ "The system handles authentication somewhere in the codebase"

✅ "Authentication is handled in `src/auth/handler.ts:45-89`"
```

### Skipping Agent Completion
```
❌ Synthesizing findings before all sub-agents return

✅ ALWAYS wait for ALL sub-agents to complete before synthesizing
```

### Placeholder Values
```
❌ Writing document with "[TBD]" or placeholder metadata

✅ ALWAYS gather metadata before writing the document
```

---

## Quick Reference

**Phase 1 - File Reading & Decomposition**: Read mentioned files fully, decompose research question, confirm understanding

**Phase 2 - Parallel Research**: Spawn locator agents first, then analyzer agents, wait for ALL to complete

**Phase 3 - Synthesis & Documentation**: Compile findings, gather metadata via `git metadata`, generate document with frontmatter

**Phase 4 - Presentation & Follow-up**: Present summary, handle follow-ups by appending to document

**Agent Selection**:
- `serena-codebase-locator` → Find where things are
- `codebase-analyzer` → Understand how code works
- `codebase-pattern-finder` → Find usage examples
- `docs-locator` → Discover relevant documents
- `docs-analyzer` → Extract document insights
- `web-search-researcher` → External resources (only if requested)

**Critical Ordering**:
1. ALWAYS read mentioned files first before spawning sub-tasks
2. ALWAYS wait for all sub-agents to complete before synthesizing
3. ALWAYS gather metadata before writing the document
4. NEVER write the research document with placeholder values

**Remember**: You are a documentarian, not an evaluator. Document what IS, not what SHOULD BE.

---

## Integration with Other Skills

### Before Implementation
Research feeds into `/plan` or implementation workflows:
- Research documents WHAT exists
- Plan documents HOW to change it

### With Thinking Patterns
For complex research:
- `atomic-thought` → Decompose research question into parts
- `graph-of-thoughts` → Synthesize findings from multiple agents
- `chain-of-thought` → Trace execution paths through code

### Documentation Lifecycle
Research documents live in `$(claude-docs-path research)/` and provide:
- Historical context for future research
- Starting point for implementation planning
- Reference for understanding past decisions
