# System Prompt Patterns

The body of an agent `.md` file (everything below the frontmatter `---`) is the system prompt. It defines the agent's identity, constraints, and behavior.

## Standard Structure

Follow this order. Not every section is required — use what the agent needs.

### 1. Role Statement (1-3 sentences)

Open with a clear identity statement. Tell the agent what it is and what its primary job is.

```markdown
You are a specialist at understanding HOW code works. Your job is to analyze
implementation details, trace data flow, and explain technical workings with
precise file:line references.
```

**Pattern**: "You are a [specialist type]. Your job is to [primary responsibility]."

### 2. CRITICAL Constraints (DO NOT rules)

Place constraints **immediately after** the role statement. Prominence matters — constraints at the top are harder to skip.

```markdown
## CRITICAL: YOUR ONLY JOB IS TO DOCUMENT AND EXPLAIN THE CODEBASE AS IT EXISTS TODAY
- DO NOT suggest improvements or changes unless the user explicitly asks
- DO NOT propose future enhancements
- DO NOT critique the implementation
- ONLY describe what exists, how it works, and how components interact
```

**Patterns**:
- Use `## CRITICAL:` heading to signal importance
- Use `DO NOT` for absolute prohibitions
- Use `ONLY` to reinforce the boundary
- List constraints as bullet points for scannability
- Keep to 4-7 constraints (more gets ignored)

### 3. Core Responsibilities (numbered list)

Define 2-4 primary things the agent does. Each responsibility gets a brief description and sub-bullets.

```markdown
## Core Responsibilities

1. **Analyze Implementation Details**
   - Read specific files to understand logic
   - Identify key functions and their purposes
   - Trace method calls and data transformations

2. **Trace Data Flow**
   - Follow data from entry to exit points
   - Map transformations and validations
   - Identify state changes and side effects
```

**Pattern**: Number the responsibilities. Bold the title. Sub-bullets for specifics.

### 4. Workflow / Strategy

Step-by-step procedure the agent follows. Use numbered steps with descriptive names.

```markdown
## Analysis Strategy

### Step 1: Read Entry Points
- Start with main files mentioned in the request
- Look for exports, public methods, or route handlers

### Step 2: Follow the Code Path
- Trace function calls step by step
- Read each file involved in the flow
- Note where data is transformed

### Step 3: Document Key Logic
- Document business logic as it exists
- Describe validation, transformation, error handling
```

**Pattern**: `### Step N: [Verb Phrase]` with bullet points under each step.

### 5. Output Format

Define the structure the agent should use when reporting results. Use a fenced code block showing the template.

```markdown
## Output Format

Structure your analysis like this:

\```
## Analysis: [Feature/Component Name]

### Overview
[2-3 sentence summary]

### Entry Points
- `file:line` - Description

### Core Implementation
#### 1. [Section Name] (`file:lines`)
- Detail about implementation
\```
```

**Pattern**: Show a complete template with placeholders in `[brackets]`. Include `file:line` reference patterns if the agent reports on code.

### 6. Guidelines (Do / Don't)

Reinforce desired behavior with paired do/don't lists.

```markdown
## Important Guidelines

- **Always include file:line references** for claims
- **Read files thoroughly** before making statements
- **Focus on "how"** not "what" or "why"

## What NOT to Do

- Don't guess about implementation
- Don't skip error handling or edge cases
- Don't make architectural recommendations
```

### 7. Closing Reminder

End with a strong restatement of the agent's role boundary. This anchors the prompt.

```markdown
## REMEMBER: You are a documentarian, not a critic or consultant

Your sole purpose is to explain HOW the code currently works, with surgical
precision and exact references. Think of yourself as a technical writer
documenting an existing system, not as an engineer evaluating it.
```

**Pattern**: `## REMEMBER:` heading with a metaphor that clarifies the role boundary.

## Token Economy

Agents are loaded in full every time they're spawned. Every line consumes context window space.

**Guidelines**:
- Keep agent definitions under ~200 lines
- Put workflow logic in skills (via `skills` frontmatter), not the agent body
- Put reference material in skills, not the agent body
- The agent defines *what it is* and *how it behaves*
- Skills carry the *detailed how-to*

**What belongs in the agent body**:
- Role statement and identity
- Constraints and boundaries
- Core responsibilities (brief)
- Workflow steps (high-level)
- Output format template
- Key guidelines

**What belongs in skills**:
- Detailed domain knowledge
- Step-by-step procedures with sub-steps
- Reference tables and specifications
- Example libraries
- Decision trees

## Anti-Patterns

### Bloated prompts
Agent definitions over 200 lines. Move detail to skills.

### Missing constraints
No `DO NOT` section. The agent drifts outside its intended role.

### Vague role statement
"You help with code." The agent doesn't know its boundaries.

### Buried constraints
Constraints at the bottom of the file. They get less attention from the model.

### Implementation in the prompt
Detailed code examples or reference tables. These belong in skills.

### Missing output format
The agent produces inconsistent output across invocations.

### No closing reminder
The agent loses focus on long tasks without a role anchor at the end.
