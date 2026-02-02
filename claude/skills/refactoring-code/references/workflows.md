# Refactoring Workflows

Six workflow types from Martin Fowler, each suited to different situations.

## TDD Refactoring

**When**: Third step of Red-Green-Refactor cycle.

**Context**: You just made a test pass. The code works but may be messy.

**Process**:
1. Tests are green—you have permission to refactor
2. Look at the code you just wrote and recently touched code
3. Apply small refactorings: rename, extract, inline
4. Keep tests green after each change
5. Stop when the code is clear enough

**Scope**: Limited to code touched in current TDD cycle. Don't wander.

**Trigger**: "The test passes, but this code is ugly."

## Litter-Pickup Refactoring

**When**: Passing through code while working on something else.

**Context**: You're adding a feature and encounter a small mess.

**Process**:
1. Notice something that could be cleaner
2. If it's quick (< 5 minutes), fix it now
3. If longer, note it and continue with your task
4. Apply Boy Scout Rule: leave code better than you found it

**Scope**: Opportunistic, small improvements only.

**Trigger**: "While I'm here, I'll clean this up."

## Comprehension Refactoring

**When**: Trying to understand unfamiliar code.

**Context**: You're reading code and it's hard to follow.

**Process**:
1. Start reading the code
2. When confused, refactor to clarify
   - Rename variables to what they actually represent
   - Extract functions to name confusing blocks
   - Inline indirection that obscures meaning
3. Your understanding improves as you refactor
4. Commit the clarifications—they help future readers

**Scope**: Code you're trying to understand.

**Trigger**: "What does this even do?"

## Preparatory Refactoring

**When**: About to add a feature, but the code isn't ready.

**Context**: The feature would be easy if the code were structured differently.

**Process**:
1. Identify where the new feature will go
2. Refactor to create a clean insertion point
3. Commit the preparatory refactoring separately
4. Add the feature (now easy)
5. Commit the feature

**Scope**: Code that will receive the new feature.

**Trigger**: "Make the change easy, then make the easy change."

**Example**:
```
# Before: Feature would require changes in 5 places
# Preparatory: Extract shared logic into one place
# After: Feature requires change in 1 place
```

## Planned Refactoring

**When**: Team allocates dedicated time for refactoring.

**Context**: Technical debt has accumulated; focused cleanup is needed.

**Process**:
1. Identify high-impact refactoring targets
2. Time-box the effort (don't gold-plate)
3. Work systematically through the targets
4. Test after each refactoring
5. Stop when time runs out or targets complete

**Scope**: Defined by team planning. Can be larger than other workflows.

**Trigger**: "We need to spend time cleaning up the order module."

**Caution**: Planned refactoring is often a sign that other workflows aren't being used enough. Prefer continuous small refactorings.

## Long-Term Refactoring

**When**: Large structural change needed over weeks or months.

**Context**: Major architecture change that can't be done in one sitting.

**Process**:
1. Define the target state
2. Identify incremental steps that keep the system working
3. Apply changes gradually alongside regular work
4. Use Branch by Abstraction or Parallel Change patterns
5. Each intermediate state must be deployable

**Scope**: Architectural. May span multiple components or services.

**Trigger**: "We need to replace the persistence layer."

**Patterns**:
- **Branch by Abstraction**: Create abstraction, implement new version behind it, migrate callers, remove old
- **Parallel Change**: Add new, migrate callers one by one, remove old
- **Strangler Fig**: New system handles more traffic over time until old can be removed

## Workflow Selection Guide

| Situation | Workflow |
|-----------|----------|
| Test just passed | TDD Refactoring |
| Noticed small issue while working | Litter-Pickup |
| Code is confusing to read | Comprehension |
| Feature would be hard to add | Preparatory |
| Accumulated debt needs attention | Planned |
| Major architecture change | Long-Term |

## Integration with Development

### With Feature Work
```
1. Start feature
2. [Preparatory] Refactor to make feature easy
3. Add feature (easy now)
4. [TDD] Refactor after tests pass
5. [Litter-Pickup] Clean anything noticed along the way
```

### With Bug Fixes
```
1. Write failing test for bug
2. [Comprehension] Refactor to understand the code
3. Fix the bug
4. [TDD] Refactor after fix
```

### With Code Review
```
1. See confusing code in PR
2. [Comprehension] Suggest refactoring for clarity
3. Reviewer and author discuss
4. Apply agreed refactorings
```

## Anti-Patterns

**Big Bang Refactoring**: Attempting large refactoring all at once. Prefer incremental.

**Refactoring Without Tests**: No safety net. Add tests first, or use very safe mechanical refactorings.

**Mixing Refactoring with Features**: Violates Two Hats Rule. Do one or the other.

**Gold-Plating**: Refactoring past "good enough." Stop when the immediate goal is met.

**Not Committing Incrementally**: Large refactoring commits are hard to review and risky to deploy. Commit after each refactoring.
