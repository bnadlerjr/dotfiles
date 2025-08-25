# Refactor Command - Code Improvement Planning Assistant

You are helping plan a refactoring to improve code quality WITHOUT changing external behavior.

<quick_reference>
## Quick Reference
- **Golden Rule**: Existing tests must stay green without modification
- **Core Principle**: No behavior changes - only internal improvements
- **Approach**: Use existing tests as safety net
- **Structure**: Incremental steps that maintain green tests
- **PR Grouping**: By technical concern, not features
- **Quality Checks**: After each refactoring step:
  - `pragmatic-code-reviewer` - Review improvements
  - `test-value-auditor` - Ensure tests still valid
  - `spurious-comment-remover` - Clean up comments
- **Output**: Plan saved to `.claude/specs/{{date}}-{{slug}}.md`
- **CRITICAL**: Plans contain requirements only, NEVER actual code
</quick_reference>

<critical_instruction>
## CRITICAL: Refactoring vs Feature Development

**This is NOT for new features.** This is for improving existing code without changing behavior.

✅ **Refactoring Means**:
- Tests continue to pass WITHOUT changes
- External API/UI remains identical
- Only internal structure improves
- Each step keeps tests green

❌ **If You Need To**:
- Write new tests for new behavior → Use the feature plan template
- Change what the code does → Use the feature plan template
- Fix broken behavior → Use the feature plan template
- Modify test assertions → Probably not a pure refactoring

**Remember**: If existing tests need to change (except for testing implementation details), you're not refactoring - you're changing behavior.
</critical_instruction>

<core_principles>
## Core Principles

### The 10-Minute Rule
Each refactoring step must be completable in under 10 minutes. This ensures:
- Safe, incremental changes
- Easy rollback if needed
- Continuous integration stays green
- Clear progress tracking

### Test-Driven Refactoring
- **Before starting**: Run all tests - must be green
- **After each step**: Run all tests - must stay green
- **No test changes**: Unless they test implementation details
- **No new tests**: Unless adding missing coverage (separate PR)

### Incremental Safety
- Each step should have passing tests
- Each PR should be deployable
- No "big bang" refactoring
- Prefer many small PRs over one large PR
</core_principles>

## Task
Refactor: $ARGUMENTS

## Process Overview

### Phase 1: Pre-Refactoring Analysis
<analysis_phase>
Thoroughly analyze the code to understand:
- **Current structure**: How is the code organized now?
- **Code smells**: What specific problems need addressing?
  - Duplication
  - Long methods/modules
  - Poor naming
  - High coupling
  - Low cohesion
  - Complex conditionals
- **Test coverage**: Are the areas to refactor well-tested?
- **Dependencies**: What code depends on what we're refactoring?
- **Seams**: Where can we safely make changes?
- **Invariants**: What behavior must remain unchanged?
</analysis_phase>

### Phase 2: Planning Process
<thinking_process>
Before creating tasks, think carefully about:
1. **Refactoring strategy** - What sequence of steps is safest?
2. **Risk assessment** - What could break? How do we prevent it?
3. **Test adequacy** - Do we have enough tests as a safety net?
4. **Intermediate states** - Will the code work at each step?
5. **Rollback points** - Can we easily revert if needed?
6. **Performance impact** - Will refactoring affect performance?

Remember: Every single step must keep all tests green.
</thinking_process>

<critical_thinking>
Ask yourself these critical questions:
- "Do existing tests cover all the code I'm refactoring?" (if not, add coverage first)
- "Are the tests testing behavior or implementation?" (refactor implementation tests first)
- "Can I break this into smaller, safer steps?" (always prefer smaller)
- "What's the smallest change that adds value?" (start there)
- "Am I changing behavior?" (if yes, STOP - this isn't refactoring)
</critical_thinking>

### Phase 3: Refactoring Plan Development
<refactoring_types>
Common refactoring patterns and their approaches:

**Extract Function/Module**:
1. Copy code to new location
2. Original delegates to new
3. Update all callers
4. Remove old code

**Move Function/Module**:
1. Copy to new location  
2. Add forwarding from old
3. Update callers one by one
4. Remove forwarding

**Rename**:
1. Add new name as alias
2. Update callers gradually
3. Remove old name

**Remove Duplication**:
1. Identify common pattern
2. Extract to shared location
3. Update each duplicate
4. Verify behavior unchanged

**Simplify Conditionals**:
1. Extract conditional to function
2. Simplify boolean logic
3. Consider polymorphism
4. Remove nested conditions

**Split Module**:
1. Identify cohesive groups
2. Extract first group
3. Update dependencies
4. Repeat for other groups
</refactoring_types>

### Phase 4: Plan Output
After approval, save the plan to: `.claude/specs/{{date}}-{{slug}}.md`
- Generate slug from request (e.g., "extract user service" → "extract-user-service")
- Use `date "+%Y-%m-%d"` for the date prefix
- Focus exclusively on planning improvements
- **Ensure the plan contains ONLY requirements and descriptions, NO actual code**

## Plan Document Template

```markdown
# Refactoring: [Description]

## Refactoring Objective
[Single paragraph describing what code is being improved and why]

## Code Smells Addressed
- [ ] [Specific smell 1: e.g., Duplicated logic in 3 places]
- [ ] [Specific smell 2: e.g., Module doing too many things]
- [ ] [Specific smell 3: e.g., Poor naming making code hard to understand]

## Refactoring Strategy
- **Type**: [Extract Method/Move Module/Remove Duplication/etc.]
- **Approach**: [Inside-out/Outside-in/Parallel change/etc.]
- **Risk Level**: [Low/Medium/High]
- **Estimated Total Time**: ~[X] minutes ([Y] hours)

## Prerequisites
- [ ] All tests passing
- [ ] Test coverage adequate (>[X]% for affected code)
- [ ] No pending changes in affected files

## Success Criteria
- [ ] All existing tests pass without modification
- [ ] No behavior changes (verified by tests)
- [ ] Code quality metrics improved:
  - [ ] Reduced duplication
  - [ ] Improved cohesion
  - [ ] Reduced coupling
  - [ ] Better naming
  - [ ] Simpler logic
- [ ] Performance unchanged or improved
- [ ] Documentation updated if needed
```

## Low-Level Tasks
> Each step keeps tests green
> Each task < 10 minutes
> Use plain English requirements, not Elixir code

### Pre-Refactoring Checklist
- [ ] Run full test suite - all green
- [ ] Run coverage analysis on target code
- [ ] Note any flaky tests to watch

<task_creation_thinking>
For EACH refactoring task, think:
- "Will tests stay green after this step?" (must be yes)
- "Is this the smallest safe change?" (prefer smaller)
- "Can I verify the behavior hasn't changed?" (tests must confirm)
- "Did I include a checkbox in the task title?" (required for tracking)
- "Am I describing WHAT to change, not HOW to code it?" (requirements only)
</task_creation_thinking>

---

## PR 0: Add Missing Test Coverage (if needed) (~[X] tasks, ~[Y] lines)
**Purpose**: Ensure adequate test coverage before refactoring
**Note**: Skip this PR if coverage is already adequate

### [ ] Task 0.1: Analyze test coverage (~5 min)
- [ ] Run coverage tool on target modules
- [ ] Identify gaps in coverage
- [ ] List untested edge cases
- [ ] Determine minimum coverage needed for safe refactoring
- **Files to analyze**: [List target modules]
- **Current coverage**: [X]%
- **Target coverage**: [Y]%

### [ ] Task 0.2: Add missing test cases (~10 min)
- [ ] Write tests for uncovered paths
- [ ] Focus on behavior, not implementation
- [ ] Verify new tests pass
- [ ] Re-run coverage to confirm improvement
- **Test file**: `test/my_app/[module]_test.exs`
- **Cases to add**: [List specific scenarios]
- **Estimated new tests**: [X] test cases

---

## PR 1: [First Refactoring Goal] (~[X] tasks, ~[Y] lines changed)
**Purpose**: [What this PR accomplishes]
**Refactoring Type**: [Extract/Move/Rename/etc.]
**Risk Level**: [Low/Medium/High]

### [ ] Task 1.1: [First incremental step] (~X min)
- [ ] Run tests - verify all green
- [ ] Perform refactoring step
- [ ] Run tests - verify still green
- [ ] Run pragmatic-code-reviewer
- [ ] Run test-value-auditor
- [ ] Run spurious-comment-remover
- **Refactoring approach**: [Describe the specific change]
- **Files affected**: [List files]
- **Verification method**: [How to confirm behavior unchanged]
- **Estimated diff**: ~X lines modified/moved

### [ ] Task 1.2: [Second incremental step] (~X min)
- [ ] Run tests - verify all green
- [ ] Perform refactoring step
- [ ] Run tests - verify still green
- [ ] Run quality checks
- **Refactoring approach**: [Describe the specific change]
- **Files affected**: [List files]
- **Dependencies updated**: [What needs to change]
- **Estimated diff**: ~X lines modified

[Continue with incremental tasks...]

---

## PR 2: [Second Refactoring Goal] (~[X] tasks, ~[Y] lines changed)
**Purpose**: [What this PR accomplishes]
**Depends on**: PR 1 (must be merged first)

### [ ] Task 2.1: [Refactoring step] (~X min)
[Same structure as above...]

---

## Rollback Plan
If refactoring causes issues:
1. **Immediate**: Stop and reassess if tests fail
2. **PR Level**: Defer PR if subtle issues found
3. **Full Rollback**: Return to pre-refactoring state if major issues

## Risk Mitigation
- **Performance Testing**: Run benchmarks before/after
- **Gradual Rollout**: Deploy to staging first
- **Feature Flags**: Consider flag for large refactoring
- **Monitoring**: Watch error rates after deployment

---

**Remember: Every task uses plain text requirements. If you write any Elixir code, delete it and replace with requirements.**

## Requirements & Constraints

<task_requirements>
### The Refactoring Golden Rule
Every single step MUST keep all existing tests green without modifying them.

### Refactoring-Specific Requirements
1. **No new tests** unless adding missing coverage (separate PR)
2. **No test modifications** unless they test implementation details
3. **Every step keeps tests green** - run before and after each change
4. **Incremental changes only** - no big-bang refactoring
5. **Behavior unchanged** - external API/UI remains identical
6. **10-minute rule** - each task completable in < 10 minutes
7. **Requirements only** - never include actual code in the plan
8. **PR independence** - each PR should be deployable alone
9. **Clear rollback points** - easy to revert if needed
</task_requirements>

### General Requirements
1. **NEVER include actual code** - Use only plain text requirements
2. **Group tasks into PRs** - Each PR 100-500 lines for optimal review
3. **Run quality check agents after each task**:
   - `pragmatic-code-reviewer` - Reviews refactoring quality
   - `test-value-auditor` - Ensures tests still appropriate
   - `spurious-comment-remover` - Removes unnecessary comments
4. **Include checkboxes (`[ ]`)** for all tasks and steps
5. **Be specific** about what to refactor and why
6. **Document invariants** - what must not change
7. **Estimate carefully** - refactoring often takes longer than expected

## Common Refactoring Patterns

### Extract Function/Module Pattern
```markdown
### [ ] Task X.1: Copy to new location (~8 min)
- [ ] Run tests - all green
- [ ] Copy code to new module/function
- [ ] Keep original in place (don't delete yet)
- [ ] Run tests - still green
- **New location**: `lib/my_app/new_module.ex`
- **Code to extract**: [Description of logic]

### [ ] Task X.2: Delegate from original (~5 min)
- [ ] Run tests - all green
- [ ] Replace original code with delegation to new
- [ ] Run tests - still green
- **Delegation approach**: Call new function/module
- **Parameters to pass**: [List what needs passing]

### [ ] Task X.3: Update callers (~7 min)
- [ ] Run tests - all green
- [ ] Find all callers of original
- [ ] Update to use new location directly
- [ ] Run tests - still green
- **Callers to update**: [List locations]

### [ ] Task X.4: Remove original (~3 min)
- [ ] Run tests - all green
- [ ] Delete old code (now unused)
- [ ] Run tests - still green
- **Code to remove**: [What to delete]
```

### Rename Pattern
```markdown
### [ ] Task X.1: Add alias with new name (~5 min)
- [ ] Run tests - all green
- [ ] Add new name as alias to old
- [ ] Run tests - still green
- **Old name**: `poorly_named_function`
- **New name**: `descriptive_function_name`
- **Alias strategy**: [How to create alias]

### [ ] Task X.2: Update internal references (~7 min)
- [ ] Run tests - all green
- [ ] Update references within module
- [ ] Run tests - still green
- **References to update**: [List locations]

### [ ] Task X.3: Update external callers (~8 min)
- [ ] Run tests - all green
- [ ] Update all external callers
- [ ] Run tests - still green
- **External callers**: [List modules]

### [ ] Task X.4: Remove old name (~3 min)
- [ ] Run tests - all green
- [ ] Remove alias/old name
- [ ] Run tests - still green
```

### Remove Duplication Pattern
```markdown
### [ ] Task X.1: Identify common pattern (~5 min)
- [ ] Analyze duplicated code sections
- [ ] Identify parameters that differ
- [ ] Design common abstraction
- **Duplicated in**: [List locations]
- **Common logic**: [Description]
- **Variations**: [What differs]

### [ ] Task X.2: Extract to shared location (~8 min)
- [ ] Run tests - all green
- [ ] Create shared function/module
- [ ] Implement common logic
- [ ] Run tests - still green
- **Shared location**: `lib/my_app/shared/[module].ex`
- **Parameters needed**: [List]

### [ ] Task X.3: Replace first duplicate (~7 min)
- [ ] Run tests - all green
- [ ] Replace first instance with call to shared
- [ ] Run tests - still green
- **Location**: [File and function]
- **Parameters to pass**: [Specific values]

### [ ] Task X.4: Replace remaining duplicates (~8 min each)
- [ ] Run tests - all green
- [ ] Replace next instance
- [ ] Run tests - still green
- [ ] Repeat for all duplicates
- **Remaining locations**: [List]
```

## Important Notes

<planning_guidelines>
- **No Code Principle**:
  - Plans contain ZERO implementation code
  - Use plain text descriptions of changes
  - Describe WHAT to refactor, not HOW to code it
  - If you write any Elixir syntax, immediately replace with requirements

- **Safety First**:
  - Every step must keep tests green
  - Never skip running tests
  - If tests fail, stop and reassess
  - Prefer smaller, safer steps

- **PR Organization**:
  - Group by technical concern, not features
  - Each PR should have one clear purpose
  - Dependencies between PRs should be explicit
  - Keep PRs under 500 lines for reviewability

- **Risk Management**:
  - Identify risky refactoring upfront
  - Have rollback plan ready
  - Consider feature flags for large changes
  - Monitor after deployment

- **Test Considerations**:
  - Tests are your safety net - trust them
  - If tests are brittle, fix them first (separate PR)
  - If coverage is low, add tests first (separate PR)
  - Implementation tests may need updating - that's OK
</planning_guidelines>

<success_behavior>
## What Success Looks Like
When complete, you will have produced a plan where:
- **Every step keeps all tests green**
- **No behavior changes occur**
- **The plan contains NO actual code, only requirements**
- **Each task is achievable in under 10 minutes**
- **PRs are organized by technical concern**
- **Rollback is possible at any point**
- **Code quality measurably improves**
- **Performance is maintained or improved**
- **The codebase is more maintainable**
</success_behavior>

### Phase 5: Final Validation
<think_before_saving>
Before saving the plan, STOP and think:
- "Will every step keep tests green?" (must be yes for all)
- "Am I changing any behavior?" (must be no)
- "Have I included ANY actual code?" (must be no)
- "Is each task under 10 minutes?" (be realistic)
- "Are PRs well-organized?" (technical cohesion)
- "Is the rollback plan clear?" (safety first)

Really validate each point. Don't just assume - think it through.
</think_before_saving>

Final checklist:
- [ ] **NO actual code blocks appear anywhere**
- [ ] **Every task includes "Run tests - verify green" steps**
- [ ] **No new tests are being written** (unless adding coverage)
- [ ] **Each task title includes a checkbox**
- [ ] **Refactoring type is clear for each PR**
- [ ] **Risk level is assessed**
- [ ] **Rollback plan is documented**
- [ ] **All tasks < 10 minutes**

**If you find ANY code, replace it with requirement descriptions immediately.**
