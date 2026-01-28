---
name: thinking-patterns
description: "Structured reasoning patterns for complex tasks. Invoke with /thinking or /thinking <pattern>. Auto-selects appropriate pattern when context is clear."
---

# Thinking Patterns

Unified skill for structured reasoning that produces visible, auditable output. Use when complex reasoning benefits from explicit methodology rather than relying solely on extended thinking.

## Quick Start

- `/thinking` - Auto-select based on context
- `/thinking chain-of-thought` - Explicit pattern selection
- `/thinking cot` - Short alias works too

See PATTERNS.md for the selection guide.

## Pattern Selection

| Task Type | Pattern | Key Trigger |
|-----------|---------|-------------|
| Research/understanding | atomic-thought | Need to combine facts from multiple areas |
| Debugging/tracing logic | chain-of-thought | Step-by-step problem solving |
| Calculations/data processing | program-of-thoughts | Generate code instead of computing mentally |
| Planning/outlining | skeleton-of-thought | Need high-level structure before details |
| Comparing approaches | tree-of-thoughts | Multiple valid solutions exist |
| High-stakes decisions | self-consistency | Errors would be costly, need validation |
| Synthesizing findings | graph-of-thoughts | Combining multiple inputs/research |

## Auto-Selection Logic

When invoked without a specific pattern, analyze the task:

1. **Keywords**: Match trigger words to patterns (see each pattern's "MUST Invoke When")
2. **Task structure**: Sequential → CoT, Branching → ToT, Convergent → GoT
3. **Risk level**: High stakes → Self-Consistency verification
4. **Ask if unclear**: When multiple patterns could apply, ask user preference

---

# Patterns

## Chain of Thought (CoT)

Linear reasoning that makes intermediate steps explicit.

### Aliases
`chain-of-thought`, `cot`, `chain`

### MUST Invoke When

- Debugging code or tracing execution flow
- User asks to "walk through", "explain", or "show your work"
- Solving problems with clear sequential dependencies
- Causal analysis ("why does this happen?")
- Math problems or logical deductions
- Any task requiring an auditable reasoning trail

### Output Commitment

This pattern produces **visible structured output**:
- Numbered steps, each building on the previous
- Explicit state at each step
- Verification against original question

Do NOT use extended thinking alone—invoke this pattern to show your step-by-step trace.

### Core Mechanism

Instead of jumping to an answer, generate a sequence of reasoning steps:
```
Problem → Step 1 → Step 2 → Step 3 → ... → Answer
```

Each step:
- Builds explicitly on previous steps
- Is independently verifiable
- Creates an audit trail for debugging

### Activation Methods

**Zero-shot**: Append trigger phrase
```
[Problem statement]
Let's work through this step by step.
```

**Few-shot**: Provide worked examples
```
Example 1: [problem] → [step 1] → [step 2] → [answer]
Example 2: [problem] → [step 1] → [step 2] → [answer]
Now solve: [new problem]
```

### Process

```
1. Restate the problem in own words
2. Identify what is given and what is asked
3. Break into sequential sub-steps
4. Execute each step, showing work
5. Verify the final answer against the original question
```

### Key Principles

- **Explicitness**: Every reasoning step is visible
- **Forward-only**: Once committed, cannot revise earlier steps
- **Context accumulation**: Full chain remains in context
- **Transparency**: Reasoning is traceable and debuggable

### When to Apply

- Mathematical calculations
- Logical deductions
- Code debugging (trace execution)
- Causal reasoning
- Any problem with clear sequential dependencies
- When interpretability/auditability matters

### Enhanced Variants

**Structured CoT**: Force specific step format
```
Given: [extract knowns]
Find: [state goal]
Step 1: [first operation]
Step 2: [second operation]
...
Therefore: [conclusion]
```

**Verification CoT**: Add self-check
```
[Normal CoT steps]
Verification: Does this answer satisfy the original constraints?
```

### Anti-Patterns

- Using for problems requiring exploration (use ToT instead)
- Very long chains without intermediate verification (errors propagate)
- Skipping steps that seem "obvious" (defeats transparency goal)
- Using when decomposition would be cleaner (use AoT for multi-hop)

---

## Atomic Thought (AoT)

Decomposes problems into independent atomic units that can be reasoned about without historical context dependency.

### Aliases
`atomic-thought`, `aot`, `atomic`

### MUST Invoke When

- Researching a topic before implementation
- Combining facts from 2+ independent knowledge areas
- User asks to "understand", "research", "investigate", or "look into" something
- Gathering information to inform a decision
- Multi-hop queries requiring information from multiple sources

### Output Commitment

This pattern produces **visible structured output**:
- Dependency graph of sub-questions
- Explicit answers to each atomic unit
- Contracted final answer with clear provenance

Do NOT use extended thinking alone—invoke this pattern to show your decomposition.

### Core Mechanism

Apply a two-phase cycle until the problem is directly solvable:

1. **Decomposition**: Break the current question into a dependency graph of sub-questions
2. **Contraction**: Solve independent sub-questions, then contract answers into a simplified atomic question

### Process

```
1. Identify the question's component parts
2. Map dependencies: which sub-questions require answers from others?
3. Solve independent (leaf) sub-questions first—each answer must be self-contained
4. Contract: Reformulate the original question using obtained answers
5. Repeat until directly answerable
```

### Key Principles

- **Markov property**: Each atomic state contains everything needed to solve it
- **No context accumulation**: Solved sub-problems contract into the question, not into growing context
- **Independence first**: Prioritize sub-questions that don't depend on others

### When to Apply

- Multi-hop factual queries requiring information from multiple sources
- Research tasks with distinct knowledge areas
- Problems where irrelevant context degrades reasoning quality
- Tasks parallelizable across independent sub-problems

### Example Pattern

```
Original: "What is the GDP difference between the birthplace of the inventor of the telephone and the country where pizza originated?"

Decomposition:
├── Q1: Who invented the telephone? [independent]
├── Q2: Where was [Q1 answer] born? [depends on Q1]
├── Q3: Where did pizza originate? [independent]
├── Q4: What is GDP of [Q2 answer]? [depends on Q2]
└── Q5: What is GDP of [Q3 answer]? [depends on Q3]

Solve Q1, Q3 → Contract → Solve Q2, Q5 → Contract → Compute difference
```

### Anti-Patterns

- Using for simple single-hop questions (overhead not justified)
- Maintaining full reasoning history across atomic units
- Creating dependencies where none exist

---

## Tree of Thoughts (ToT)

Explores multiple reasoning paths as a tree, evaluating candidates and backtracking from dead ends.

### Aliases
`tree-of-thoughts`, `tot`, `tree`

### MUST Invoke When

- Multiple valid implementation approaches exist
- User asks "what are my options" or "how should I approach this"
- Comparing alternatives or trade-offs
- Brainstorming where diverse options are valuable
- The first solution might not be optimal
- Design decisions with significant consequences

### Output Commitment

This pattern produces **visible structured output**:
- 2-4 distinct approaches with reasoning
- Evaluation of each (feasibility, trade-offs, risks)
- Clear recommendation with justification

Do NOT pick the first approach—invoke this pattern to explore alternatives visibly.

### Core Mechanism

At each reasoning step:
1. **Generate**: Produce multiple candidate thoughts/approaches
2. **Evaluate**: Assess each candidate (promising / uncertain / dead-end)
3. **Search**: Pursue promising paths, abandon dead ends, backtrack when stuck

### Process

```
1. Frame the problem and identify the decision space
2. Generate 2-4 distinct initial approaches
3. For each approach, evaluate:
   - Feasibility: Can this work given constraints?
   - Progress: Does this move toward the goal?
   - Reversibility: Can we recover if wrong?
4. Expand the most promising path(s)
5. If stuck, backtrack to last branch point and try alternative
6. Continue until solution or all paths exhausted
```

### Evaluation Heuristics

Rate each candidate thought:
- **Sure** (pursue): Clear progress, no obvious blockers
- **Maybe** (explore cautiously): Potential but uncertain
- **Impossible** (abandon): Violates constraints or leads nowhere

### When to Apply

- Problems where >60% of failures occur at the first step (puzzles, planning)
- Design decisions with multiple valid approaches
- Brainstorming where diverse options are valuable
- Tasks requiring strategic lookahead (games, negotiations)

### Three Experts Pattern

```
Imagine three experts with different perspectives approaching this problem:

Expert A (prioritizes simplicity): [approach + reasoning]
Expert B (prioritizes performance): [approach + reasoning]
Expert C (prioritizes extensibility): [approach + reasoning]

Each expert evaluates their approach:
- What are the key trade-offs?
- What could go wrong?
- [If fatal flaw discovered, expert acknowledges and withdraws]

Synthesis: Which approach (or hybrid) best fits the constraints?
```

### Search Strategies

- **BFS**: When solution depth is unknown, explore breadth first
- **DFS**: When deep exploration is needed before switching paths
- **Best-first**: When evaluation function reliably ranks candidates

### Anti-Patterns

- Using for simple sequential problems (CoT is simpler)
- Generating too many branches (3-4 is usually optimal)
- Failing to actually backtrack when paths fail
- Shallow evaluation that doesn't catch fatal flaws early

---

## Skeleton of Thought (SoT)

Generates structure before content—outline first, then parallel expansion.

### Aliases
`skeleton-of-thought`, `sot`, `skeleton`

### MUST Invoke When

- Planning implementation of a feature
- User asks for a "plan", "outline", or "roadmap"
- Creating multi-section documents or responses
- Structuring complex output before writing
- Breaking work into phases or components

### Output Commitment

This pattern produces **visible structured output**:
- Phase 1: Skeleton only (major sections, no details)
- Phase 2: Expansion of each skeleton point
- Clear separation between structure and content

Do NOT jump to implementation—invoke this pattern to show skeleton first.

### Core Mechanism

Two distinct phases:
1. **Skeleton phase**: Generate only the high-level structure (headers, key points, sequence)
2. **Expansion phase**: Flesh out each skeleton point independently

### Process

```
Phase 1 - Skeleton:
1. Identify the major components/sections needed
2. Determine logical ordering and dependencies
3. Output ONLY the skeleton (no details yet)
4. Validate: Does this structure cover the full scope?

Phase 2 - Expansion:
1. Take each skeleton point in order
2. Expand with full detail
3. Maintain coherence with adjacent sections
4. Check: Does expansion stay true to skeleton's intent?
```

### Key Principles

- **Separation of concerns**: Structure and content are distinct cognitive tasks
- **Parallelization potential**: Skeleton points can be expanded concurrently
- **Drift prevention**: Skeleton constrains expansion, preventing tangents
- **Dependency visibility**: Structure reveals what must come before what

### When to Apply

- Implementation planning (see full scope before diving in)
- Document/report creation
- Presentations and structured communication
- Any multi-part output where order matters
- Complex responses that need organization

### Skeleton Pattern

```
Phase 1 - Generate skeleton only:

For [TASK], create a skeleton outline:
- Major sections/components only
- One line per item (no elaboration)
- Include sequencing/dependencies
- Do NOT expand yet

[Generate skeleton]

---

Phase 2 - Expand sequentially:

Now expand each skeleton point:
- Full detail for this section only
- Stay within the skeleton's scope
- Note dependencies on prior sections
- [Process in dependency order]
```

### Planning Application

```
Skeleton:
1. Database schema changes
2. API endpoint modifications
3. Frontend component updates
4. Integration tests
5. Migration script

Expansion (each becomes detailed task list with acceptance criteria)
```

### Anti-Patterns

- Expanding during skeleton phase (defeats the purpose)
- Skeleton too detailed (it's not a full outline, just structure)
- Skeleton too vague (should still capture all major components)
- Ignoring dependencies during expansion
- Not validating skeleton covers full scope before expanding

---

## Program of Thoughts (PoT)

Delegates computation to code execution, keeping reasoning in natural language.

### Aliases
`program-of-thoughts`, `pot`, `program`

### MUST Invoke When

- Any calculation with more than 2 operations
- Large numbers or complex formulas
- User asks to "calculate", "compute", or "analyze data"
- Financial calculations (interest, amortization, etc.)
- Statistics or probability computations
- Data transformations requiring precision

### Output Commitment

This pattern produces **visible structured output**:
- Natural language explanation of the approach
- Executable code with clear variable names
- Executed results with interpretation

Do NOT compute mentally—invoke this pattern to generate and run code.

### Core Mechanism

Split the cognitive task:
- **LLM handles**: Understanding, decomposition, logic, code generation
- **Interpreter handles**: Actual computation, arithmetic, data manipulation

```
Problem → [LLM: Generate Python] → [Execute] → Result
```

### Process

```
1. Understand the problem in natural language
2. Identify computations needed
3. Generate executable code (Python typically)
4. Execute the code
5. Interpret and present results
```

### Key Principles

- **Separation of concerns**: Reasoning ≠ calculation
- **Precision**: Code execution is deterministic
- **Verifiability**: Code can be inspected and tested
- **Scalability**: Handles large numbers, complex formulas without degradation

### When to Apply

- Numerical calculations (especially with large numbers)
- Multi-step mathematical problems
- Data transformations and analysis
- Financial calculations (compound interest, amortization)
- Any task where arithmetic errors are costly
- Statistics and probability computations

### Implementation Pattern

```
First, let me understand what we need to calculate:
[Natural language reasoning about the problem]

Now I'll write code to compute this precisely:

```python
# [Code with clear variable names and comments]
# Matches the reasoning above
result = ...
print(f"The answer is: {result}")
```

[Execute and present result with interpretation]
```

### Example

Problem: "What is 15% compound interest on $10,000 over 7 years?"

```
Reasoning: Compound interest formula is A = P(1 + r)^t
- P = 10000 (principal)
- r = 0.15 (rate)
- t = 7 (years)

```python
principal = 10000
rate = 0.15
years = 7
final_amount = principal * (1 + rate) ** years
interest_earned = final_amount - principal
print(f"Final amount: ${final_amount:,.2f}")
print(f"Interest earned: ${interest_earned:,.2f}")
```

[Execute → Present results]
```

### Hybrid with CoT

Combine reasoning trace with code execution:
```
Step 1: [Reasoning] → Step 2: [Code for calculation] → Step 3: [Interpret result] → ...
```

### Anti-Patterns

- Writing code for simple arithmetic (overhead not justified)
- Generating code without explaining the logic
- Not executing the code (defeats the purpose)
- Complex code that's harder to verify than manual calculation

---

## Self-Consistency

Samples multiple reasoning paths and aggregates for reliability.

### Aliases
`self-consistency`, `sc`, `verify`

### MUST Invoke When

- Verifying important conclusions before finalizing
- User asks to "double-check", "verify", or "make sure this is right"
- High-stakes implementations where errors are costly
- Single-path confidence is insufficient
- Edge case detection is important
- Critical decisions that need validation

### Output Commitment

This pattern produces **visible structured output**:
- 3-5 independent reasoning paths
- Answer from each path
- Consensus check and discrepancy analysis
- Final answer with confidence assessment

Do NOT trust single reasoning path—invoke this pattern to verify through multiple approaches.

### Core Mechanism

Instead of one reasoning chain, generate several independent chains and vote:
```
Problem → Chain A → Answer A
        → Chain B → Answer B
        → Chain C → Answer C
        → Majority vote → Final Answer
```

### Process

```
1. Generate multiple diverse reasoning paths (3-5 typically)
2. Ensure independence: each path should approach differently
3. Extract the answer from each path
4. Aggregate:
   - Majority vote for categorical answers
   - Consensus check for open-ended responses
   - Flag significant disagreements for review
```

### Key Principles

- **Independence**: Paths should not influence each other
- **Diversity**: Different approaches, not just different wordings
- **Aggregation**: The wisdom of crowds, but for reasoning
- **Discrepancy detection**: Disagreements surface edge cases or errors

### When to Apply

- High-stakes decisions where errors are costly
- Problems with multiple valid solution approaches
- Verification of important conclusions
- When single-path confidence is insufficient
- Edge case detection

### Implementation Patterns

#### Simple Multi-Path
```
Solve this problem three different ways:

Approach 1 (algebraic):
[reasoning → answer]

Approach 2 (geometric/visual):
[reasoning → answer]

Approach 3 (estimation/sanity check):
[reasoning → answer]

Consensus check: Do all approaches agree? If not, identify the discrepancy.
```

#### Implementation Verification
```
Generate two implementations:

Implementation A (optimize for clarity):
[code]

Implementation B (optimize for efficiency):
[code]

Verification:
- Do they produce the same output for test cases?
- If different, which is correct and why?
```

#### Decision Verification
```
Evaluate this decision from three perspectives:

Perspective 1 (short-term impact):
[analysis → recommendation]

Perspective 2 (long-term impact):
[analysis → recommendation]

Perspective 3 (risk assessment):
[analysis → recommendation]

Synthesis: What does the consensus suggest?
```

### Handling Disagreements

When paths disagree:
1. Identify where the reasoning diverges
2. Check each path for errors at the divergence point
3. If both seem valid, the problem may be ambiguous
4. Report the disagreement and reasoning for each

### Anti-Patterns

- Paths that aren't actually independent (just rephrased)
- Ignoring disagreements (they're the valuable signal)
- Too many paths (diminishing returns after 5)
- Using for simple problems where one path suffices

---

## Graph of Thoughts (GoT)

Models reasoning as an arbitrary graph with aggregation, refinement, and feedback operations.

### Aliases
`graph-of-thoughts`, `got`, `graph`

### MUST Invoke When

- Synthesizing research from multiple sources
- Combining brainstormed ideas into a coherent plan
- User asks to "combine", "synthesize", or "integrate" findings
- Merging partial solutions from different approaches
- After divergent exploration (ToT) when convergence is needed
- Multiple inputs need to become one coherent output

### Output Commitment

This pattern produces **visible structured output**:
- Extracted insights from each source
- Identified agreements and conflicts
- Resolution of conflicts with reasoning
- Unified synthesis with provenance

Do NOT just pick one input—invoke this pattern to show synthesis process.

### Core Mechanism

Unlike trees (divergent) or chains (linear), graphs support:
- **Aggregation**: Combining multiple thoughts into one
- **Refinement**: Iteratively improving a thought
- **Splitting**: Breaking a thought into components for parallel processing
- **Loops**: Feedback cycles for iterative improvement

### Process

```
1. Identify input thoughts/sources to synthesize
2. For each input, extract key insights and constraints
3. Identify conflicts or tensions between inputs
4. Aggregate compatible insights into unified positions
5. Resolve conflicts through:
   - Prioritization (which source is more authoritative?)
   - Synthesis (can both be true in different contexts?)
   - Refinement (iterate until coherent)
6. Output synthesized result with clear provenance
```

### Operations

#### Aggregate
Combine multiple reasoning chains into a single coherent output:
```
Chain A conclusion: X
Chain B conclusion: Y
Chain C conclusion: Z
→ Aggregated insight: [unified position incorporating X, Y, Z]
```

#### Refine
Iteratively improve a thought through feedback:
```
Draft 1 → Critique → Draft 2 → Critique → Final
```

#### Split-then-Aggregate
Parallelize then recombine:
```
Complex problem → Split into A, B, C → Solve each → Aggregate solutions
```

### When to Apply

- Synthesizing research from multiple sources
- Combining brainstormed ideas into a coherent plan
- Merging partial solutions from different approaches
- Iterative refinement through self-critique
- Any task where insights must converge rather than diverge

### Synthesis Pattern

```
I have these inputs to synthesize:
- Source 1: [insight]
- Source 2: [insight]
- Source 3: [insight]

Step 1 - Extract: What is the core claim/finding from each?
Step 2 - Align: Where do they agree?
Step 3 - Conflict: Where do they disagree? Why?
Step 4 - Resolve: For each conflict, determine resolution
Step 5 - Integrate: Produce unified output with:
   - Synthesized position
   - Confidence level
   - Remaining uncertainties
```

### Anti-Patterns

- Using when inputs don't need integration (just present separately)
- Forcing false synthesis when sources genuinely conflict
- Losing provenance (which insight came from where)
- Aggregating without resolving contradictions

---

## Integration with Workflow

### Combining Patterns

Patterns can be composed for complex tasks:

1. **Research phase**: AoT for gathering → GoT for synthesis
2. **Planning phase**: SoT for structure → ToT for approach selection
3. **Implementation phase**: CoT for step-by-step → PoT for calculations
4. **Verification phase**: Self-Consistency for validation

### Workflow Integration

| Phase | Primary Pattern | Purpose |
|-------|-----------------|---------|
| Before planning | SoT or ToT | Structure or explore options |
| During research | AoT | Decompose and gather |
| When debugging | CoT | Systematic tracing |
| Before finalizing | Self-Consistency | Validate approach |
| After brainstorming | GoT | Synthesize findings |

### Key Principle

Extended thinking handles internal reasoning. These patterns produce **visible structured output** that can be reviewed and validated. When in doubt, invoke a pattern—structured reasoning is always preferable to hidden reasoning for non-trivial problems.
