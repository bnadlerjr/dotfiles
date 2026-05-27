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

## Critical Principles

### Focus on Documentation

Your primary job is to explain the codebase as it exists today.

- Describe what exists, where it exists, how it works, and how components interact
- You are creating a technical map/documentation of the existing system
- Only suggest improvements or identify problems if explicitly asked

### Completeness

Research must be complete. Partial reads, skimming, or leaving gaps unmarked is a failure mode of this skill.

- Read files in full. Do not use `limit`/`offset` to skim the top of a file unless the file exceeds a stated size threshold — in that case, read it in chunks and report having done so.
- When enumerating a **finite set** (struct fields, enum variants, function parameters, config keys, schema columns, route handlers, exported module symbols, etc.), the enumeration must be either:
  1. **Complete** — every member listed, with type and `file:line` reference, OR
  2. **Explicitly truncated with a reason** — name the members you covered, state the count of members you skipped, and point to the source for the full definition.
- `...`, "etc.", "and so on", "and others", "among others" are NOT acceptable substitutes for either of the above. In enumeration contexts they are an admission of incomplete research and are forbidden.

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

Flow control (whether to confirm the decomposition with the user before
proceeding) is the caller's responsibility. For direct skill invocations,
present the decomposition and proceed unless the user objects.

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

### Completeness Expectations for Agent Prompts

The "agents know their job" guidance covers search strategy, not completeness. Completeness must be stated explicitly in the prompt:

- **For finite structures** (struct, enum, config, route table, exported symbols, schema columns, etc.) — explicitly require complete enumeration in the agent's prompt. Example: "Enumerate every field of the `User` struct with type and `file:line`. Do not abbreviate with `...` or `etc.` — if you skip any, state which and why."
- **For file summaries** — require the agent to read the entire file. No `limit`/`offset` truncation unless the file exceeds a stated size threshold (e.g. >1000 lines), in which case the agent must read it in chunks and report having done so.
- **Treat completion as "complete findings", not "agent returned"** — see Important below.

### Important

- WAIT for ALL agent tasks to complete before proceeding to Synthesis Phase
- "Complete" means the agent returned **complete findings**, not just that it returned. If an agent's result contains `...`, "etc.", "and others", or otherwise signals incompleteness in an enumeration, **re-spawn the agent with a corrective prompt** rather than passing the gap through to the user.
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

### Step 2: Completeness Check

Before rendering, scan all agent findings for incompleteness:

- Search the combined findings for `...`, "etc.", "and so on", "and others", "among others", or any other ellipsis-shaped admission of incomplete research.
- Check every enumeration (struct fields, enum variants, config keys, route handlers, exported symbols, etc.) — does it either list every member, or explicitly mark which members were skipped, the count skipped, and why?
- Check for partial file reads — if an agent summarized a file but only read part of it without stating why, treat the summary as incomplete.

If any gap is found, **re-spawn the relevant agent with a corrective prompt to fill the gap** before rendering. Do not render a document with unmarked gaps.

### Step 3: Render Research Document

Render the full research document inline in the conversation using the
structure in `templates/research-document.md`. The skill's deliverable is the
rendered document; persistence is the caller's responsibility (e.g., a wrapper
command may save it to disk under environment-specific conventions).

**Required sections**:
- Research Question, Summary, Detailed Findings
- Code References with file:line format
- Architecture Documentation, Historical Context, Related Research
- Open Questions for areas needing follow-up

If a calling command specifies a save path or frontmatter schema, follow that
guidance after rendering.

### Step 4: Add GitHub Permalinks (if applicable)

- Check if on main branch or if commit is pushed: `git branch --show-current` and `git status`
- If on main/master or pushed, generate GitHub permalinks:
  - Get repo info: `gh repo view --json owner,name`
  - Create permalinks: `https://github.com/{owner}/{repo}/blob/{commit}/{file}#L{line}`
- Replace local file references with permalinks in the rendered document

---

## Follow-up Phase

**Goal**: Present findings and handle additional questions.

### Present Findings

- Present a concise summary of findings to the user
- Include key file references for easy navigation
- Ask if they have follow-up questions or need clarification

### Handle Follow-up Questions

If the user asks follow-up questions:
- Spawn new agents as needed for additional investigation
- Re-render the document with the additions
- Add a new section: `## Follow-up Research [timestamp]`

If a calling command persisted the document, defer file updates and frontmatter
changes to the caller — do not modify the persisted file directly.

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

### Ellipsis in Enumeration

Using `...`, "etc.", or "and several others" inside a finite enumeration is an admission of incomplete research. Either enumerate fully, or state explicitly what was skipped and why.

**Struct fields:**
```
❌ "The `User` struct has fields `name`, `email`, `id`, ..."
❌ "The `User` struct has `name`, `email`, `id` and several other fields"

✅ Full enumeration:
   "The `User` struct (`src/models/user.rs:12-28`) has fields:
    - `id: Uuid` (`src/models/user.rs:13`)
    - `name: String` (`src/models/user.rs:14`)
    - `email: String` (`src/models/user.rs:15`)
    - `created_at: DateTime<Utc>` (`src/models/user.rs:16`)
    - `updated_at: DateTime<Utc>` (`src/models/user.rs:17`)"

✅ Explicit truncation:
   "Fields `name`, `email`, `id` documented here; remaining 12 fields
    (`created_at`, `updated_at`, `last_login`, `role`, `tenant_id`,
    `is_active`, `mfa_secret`, `password_hash`, `avatar_url`,
    `locale`, `timezone`, `deleted_at`) deferred — see
    `src/models/user.rs:1-200` for the full struct definition."
```

**Enum variants:**
```
❌ "`Status` has variants `Pending`, `Active`, `Suspended`, etc."

✅ "`Status` (`src/types.ts:5-11`) has 5 variants: `Pending`,
   `Active`, `Suspended`, `Cancelled`, `Archived`."
```

**Function signatures / parameters:**
```
❌ "`createOrder(userId, items, ...)` builds an order"

✅ "`createOrder(userId: string, items: LineItem[],
   shippingAddress: Address, paymentMethodId: string,
   couponCode?: string)` (`src/orders/create.ts:34`) builds an order"
```

**Exported module symbols:**
```
❌ "`src/lib/auth.ts` exports `login`, `logout`, `verifyToken`, and more"

✅ "`src/lib/auth.ts` exports 7 symbols: `login`, `logout`,
   `verifyToken`, `refreshToken`, `requireAuth`, `AuthError`,
   `SessionStore`. (verified by reading the full file)"
```

**Config keys:**
```
❌ "`config/app.yml` has keys for database, redis, ..."

✅ "`config/app.yml` has 4 top-level keys: `database`, `redis`,
   `mailer`, `feature_flags`. Nested keys under each are
   enumerated in the Detailed Findings section."
```

### Skipping Agent Completion
```
❌ Synthesizing findings before all agents return

✅ ALWAYS wait for ALL agents to complete before synthesizing
```

### Placeholder Values
```
❌ Leaving "[TBD]" or guesses in findings to fill in later

✅ Investigate further with another agent, or note as an Open Question
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

**User**: `How does user authentication work in this app?`

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
3. Never use placeholder values — investigate or note as an Open Question
4. Enumerations must be complete or explicitly truncated with a reason — no `...`, `etc.`, or unmarked gaps

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

