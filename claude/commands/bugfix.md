# TDD Debug Fix
Fix bug described in $ARGUMENTS using test-driven development with comprehensive analysis.

## Phase 1: Understanding and Reproduction
1. **Analyze the issue**
   - Read error messages and stack traces
   - Understand expected vs actual behavior
   - Search codebase for relevant context
   - Check git history for recent changes

2. **Write failing test first**
   - Create test that reproduces the exact bug
   - Include edge cases and boundary conditions
   - Run test to confirm it fails appropriately

## Phase 2: Root Cause Analysis
3. **Think deeply about the problem**
   - Use extended reasoning to analyze potential causes
   - Trace execution paths leading to the bug
   - Consider interactions with other components
   - Identify any violated assumptions or invariants

4. **Develop fix hypothesis**
   - Propose specific code changes needed
   - Explain why these changes address root cause
   - Consider potential side effects
   - Plan verification approach

## Phase 3: Implementation and Verification
5. **Implement the fix**
   - Make minimal changes to pass the test
   - Preserve existing functionality
   - Follow project coding standards
   - Add defensive programming where appropriate

6. **Verify comprehensively**
   - Run the specific test to confirm it passes
   - Run full test suite to prevent regressions
   - Check edge cases and error conditions
   - Perform manual testing if needed

## Phase 4: Completion and Prevention
7. **Refactor if necessary**
   - Improve code clarity and maintainability
   - Extract common patterns
   - Update documentation
   - Ensure all tests still pass

## Guidelines:
- Always write tests before fixes (TDD discipline)
- Use git history and logs for context
- Think systematically about root causes
- Consider long-term code health
- Document findings for future reference
