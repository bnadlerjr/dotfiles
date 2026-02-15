# Deletion Criteria

Criteria for identifying instructions that should be flagged for removal. Every flagged item requires user approval before deletion.

## Category 1: Agent Already Knows

Instructions that restate behavior LLM agents exhibit by default. These waste tokens without changing behavior.

**Flag when the instruction:**
- Tells the agent to "write clean code", "be thorough", or "think carefully"
- Tells the agent to "follow best practices" without specifying which ones
- Tells the agent to use a language's standard library features (it already will)
- Restates how standard tools work ("use git to track changes")
- Tells the agent to "read the code before making changes" (default behavior)
- Tells the agent to "understand the requirements" (default behavior)

**Examples to DELETE:**
- "Write clean, maintainable code"
- "Make sure to handle edge cases"
- "Think step by step"
- "Read existing code before modifying it"
- "Use descriptive variable names" (default for all LLMs)
- "Follow the DRY principle" (known by default)

**Examples to KEEP (these look similar but are specific enough):**
- "Use snake_case for all database columns" (specific naming rule)
- "Handle timeout errors by retrying 3 times with exponential backoff" (specific behavior)
- "Use Zod for runtime validation at API boundaries" (specific tool choice)

## Category 2: Too Vague

Instructions that are not actionable because they do not specify what behavior to change.

**Flag when the instruction:**
- Uses words like "appropriate", "suitable", "proper", "good" without defining them
- Says "follow best practices" without listing the practices
- Says "use the right tool" without specifying which tool
- Could mean different things to different people
- Would not change the agent's output if removed

**Examples to DELETE or REWRITE:**
- "Follow best practices" -> DELETE or rewrite as specific practices
- "Use appropriate error handling" -> Rewrite: "Return Result types from fallible functions; reserve exceptions for truly exceptional cases"
- "Write good tests" -> Rewrite: "Each test must have a single assertion and a descriptive name matching the behavior being tested"
- "Keep code organized" -> DELETE (too vague) or rewrite with specific organization rules

## Category 3: Overly Obvious

Instructions that any competent developer (or agent) would follow without being told.

**Flag when the instruction:**
- States something that is universally accepted practice
- Would be followed by default in any professional context
- Adds no information beyond "do your job well"

**Examples to DELETE:**
- "Test your code before committing"
- "Use version control"
- "Review your changes before submitting"
- "Make sure the code compiles"
- "Don't introduce syntax errors"
- "Keep dependencies up to date" (too vague and obvious)

## Category 4: Duplicates Built-in Behavior

Instructions that restate what the agent's tools already do by default.

**Flag when the instruction:**
- Tells the agent to use a tool the way it already uses it
- Restates default tool configuration
- Describes standard IDE/editor behavior

**Examples to DELETE:**
- "Use git for version control" (agent already does)
- "Run linters before committing" (if pre-commit hooks handle this)
- "Format code with Prettier" (if formatOnSave or pre-commit is configured)

## Category 5: Outdated

Instructions referencing deprecated tools, old versions, or abandoned patterns.

**Flag when the instruction:**
- References a tool version that is no longer current (and the project has moved on)
- Describes a pattern the project no longer uses
- Mentions a dependency that has been replaced

**Note:** Only flag if you can confirm the instruction is outdated from the current codebase. When unsure, keep it and let the user decide.

## Category 6: Aspirational

Instructions that describe an ideal state rather than an actionable rule.

**Flag when the instruction:**
- Uses "strive for", "aim to", "ideally", "when possible"
- Describes a goal rather than a concrete behavior
- Cannot be objectively verified

**Examples to DELETE or REWRITE:**
- "Strive for 100% test coverage" -> Rewrite: "Minimum 80% line coverage; 100% coverage for payment and auth modules"
- "Aim for small functions" -> Rewrite: "Functions should not exceed 20 lines; extract when they do"
- "Try to keep PRs small" -> Rewrite: "PRs should change fewer than 300 lines; split larger changes"

## Presentation Format

When flagging items, use this format for each:

```
**"[Quoted instruction]"** (from [file:line])
- Category: [Agent Already Knows | Too Vague | Overly Obvious | Duplicates Built-in | Outdated | Aspirational]
- Why: [One sentence explaining why this adds no value]
- Recommendation: DELETE | REWRITE as: "[suggested specific version]"
```

## Decision Rule

When unsure whether to flag an instruction:
- If removing it would NOT change the agent's behavior -> flag it
- If removing it WOULD change the agent's behavior -> keep it
- When in doubt, keep it and let the user decide
