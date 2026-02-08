---
name: researching-codebase
description: "Researches and documents existing codebase implementations. Use when exploring how code works, understanding architecture, answering 'how does X work?' questions, or gathering context before making changes. Produces structured research documents with code references."
---

# Research Codebase

Conduct comprehensive research across the codebase to answer user questions by spawning parallel agents and synthesizing their findings.

## When This Skill Applies

- Exploring existing implementations before making changes
- Understanding architecture or system design
- Answering "how does X work?" questions about the codebase
- Documenting component interactions and data flows
- Gathering historical context from docs directory
- User asks to "research", "document", or "understand" something

## Invocation

**Command**: `/researching-codebase` or `/researching-codebase [topic]`

### Initial Response

When invoked:

1. **If a topic was provided**: Begin decomposing the research question

2. **If no topic provided**, respond with:
```
I'm ready to research the codebase. Please provide your research question or area of interest, and I'll analyze it thoroughly by exploring relevant components and connections.
```

## Critical Principle

**Focus on documentation.** Your primary job is to explain the codebase as it exists today.

- Describe what exists, where it exists, how it works, and how components interact
- You are creating a technical map/documentation of the existing system
- Only suggest improvements or identify problems if explicitly asked

---

## Decomposition Phase

**Goal**: Understand the research context and break down the question.

### Step 1: Read Mentioned Files

If the user mentions specific files (tickets, docs, JSON):
- Read them FULLY using the Read tool WITHOUT limit/offset parameters
- **CRITICAL**: Read these files yourself in the main context before spawning any agents
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
  - "Yes, proceed with research" → Continue to Research Phase
  - "Adjust the scope" → Ask what to adjust, then re-confirm
  - "Let me clarify" → Wait for clarification

---

## Research Phase

**Goal**: Spawn specialized agents to gather information concurrently.

### Specialized Agents

**For codebase research:**
- **codebase-navigator**: Find WHERE files and components live
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

- WAIT for ALL agent tasks to complete before proceeding to Synthesis Phase
- All agents are documentarians, not critics—they describe what exists without suggesting improvements

---

## Synthesis Phase

**Goal**: Compile findings and generate the research document.

### Step 1: Synthesize Findings

- Compile all agent results (both codebase and docs findings)
- Prioritize live codebase findings as primary source of truth
- Use docs directory findings as supplementary historical context
- Connect findings across different components
- Include specific file paths and line numbers for reference
- Highlight patterns, connections, and architectural decisions
- Answer the user's specific questions with concrete evidence

### Step 2: Gather Metadata

Look up project context from `$CLAUDE_DOCS_ROOT/projects.yaml` following the
rules in the "Artifact Management" section of CLAUDE-PERSONAL.md. This
determines `Area`, `Project`, `ProjectSlug`, `JiraEpic`, and `Repositories`
for the frontmatter.

### Step 3: Generate Research Document

Write the document to `$CLAUDE_DOCS_ROOT/research/` using the naming convention
`research--<slug>.md` where slug describes what this research covers (not the
project name). If the project is ambiguous, ask the user.

Generate the document using the template at `templates/research-document.md`.

**Required sections**:
- YAML frontmatter per CLAUDE-PERSONAL.md artifact management schema
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
  - "Yes, looks good" → Continue to Follow-up Phase
  - "Add more detail on [area]" → Expand that section
  - "I have follow-up questions" → Address them and update document

---

## Follow-up Phase

**Goal**: Present findings and handle additional questions.

### Present Findings

- Present a concise summary of findings to the user
- Include key file references for easy navigation
- Ask if they have follow-up questions or need clarification

### Handle Follow-up Questions

If the user has follow-up questions:
- Append to the same research document
- Update `Modified` in the frontmatter to today's date
- Add a new section: `## Follow-up Research [timestamp]`
- Spawn new agents as needed for additional investigation
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
❌ Synthesizing findings before all agents return

✅ ALWAYS wait for ALL agents to complete before synthesizing
```

### Placeholder Values
```
❌ Writing document with "[TBD]" or placeholder metadata

✅ ALWAYS gather metadata before writing the document
```

---

## Troubleshooting

**Agent returns empty results:**
- Verify the search terms match what's in the codebase
- Try broader search terms with a different agent
- Check if the component exists at all using `codebase-navigator`

**Research scope too broad:**
- Narrow to specific components or files
- Break into multiple focused research sessions
- Ask user to prioritize which aspect to investigate first

---

## Example Session

**User**: `/researching-codebase How does user authentication work in this app?`

**Decomposition Phase output:**
```
I'll research the authentication flow by investigating:
1. Entry points (login routes, middleware)
2. Token/session management
3. User validation logic
4. Protected route enforcement

Spawning agents:
- codebase-navigator: "authentication login routes middleware"
- codebase-analyzer: "src/auth/" (after locator finds it)
```

**Synthesized finding excerpt:**
```
## Authentication Flow

### Entry Point
Login requests hit `src/routes/auth.ts:23-45`, which validates
credentials against the User model.

### Session Management
Sessions are stored in Redis via `src/lib/session.ts:12`. The
`createSession()` function generates a JWT with 24h expiry.

### Protected Routes
The `requireAuth` middleware (`src/middleware/auth.ts:8-34`)
checks the Authorization header and validates the JWT signature.
```

---

## Agent Selection

| Agent | Purpose |
|-------|---------|
| `codebase-navigator` | Find where files and components live |
| `codebase-analyzer` | Understand how specific code works |
| `codebase-pattern-finder` | Find usage examples |
| `docs-locator` | Discover relevant documents |
| `docs-analyzer` | Extract document insights |
| `web-search-researcher` | External resources (only if requested) |

**Critical rules:**
1. Read mentioned files before spawning agents
2. Wait for ALL agents to complete before synthesizing
3. Look up project context from projects.yaml before writing the document
4. Never use placeholder values

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

