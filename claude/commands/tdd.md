# TDD Development Flow

Decompose the following high-level software requirement into discrete, testable functionalities and implement them using the Test-Driven Development (TDD) methodology. Think hard.

$ARGUMENTS

## Guidelines

1. **Write Focused Tests**: Create precise unit tests for a single functionality or requirement, ensuring coverage of all possible scenarios, edge cases, and invalid inputs.
2. **Confirm Test Failure**: Execute the tests to verify they fail initially, confirming their validity before implementation begins.
3. **Implement Minimal Code**: Write the simplest code required to pass the tests, avoiding over-engineering or adding features not directly related to the current test cases.
4. **Verify Implementation**: Re-run the tests to confirm that the implemented code passes all test cases successfully. Debug and refine as necessary.
5. **Refactor**: Improve the code's structure, readability, and performance while maintaining functionality, ensuring no tests break during the process.
6. **Validate Refactoring**: Run the tests again after refactoring to ensure the updated code still passes all test cases without introducing regressions.

**IMPORTANT**: Write tests BEFORE implementation. The tests should fail initially. Only write implementation code after confirming test failure.

**IMPORTANT**: Write the SIMPLEST code that makes the test pass. 
Do not add:
- Extra methods not required by tests
- Optimizations not tested
- Features not in current test scope

**IMPORTANT**: During refactoring:
1. Run tests before any change
2. Make one refactoring change
3. Run tests again
4. Repeat for next refactoring

**IMPORTANT**: Always ask for confirmation before implementing if the tests look incomplete.

## Process

Follow these steps to implement the TDD process:

1. **DOMAIN EXPERT**: Choose appropriate domain expert agents (e.g. elixir-otp-expert, graphql-schema-architect, etc.).
2. **DOMAIN EXPERT**: Analyzes the requirement and identify single testable unit.
3. **TEST EXPERT**: Writes a comprehensive test for the unit.
4. Run the test and confirm it fails for the **EXPECTED** reason.
5. **DOMAIN EXPERT**: Implements minimal code to pass the test.
6. Run the test and confirm it passes.
7. **DOMAIN EXPERT**: Refactors while keeping tests green.
8. **CODE REVIEW**: Use pragmatic-code-reviewer agent to review implementation.
8. **CODE REVIEW**: Use spurious-comment-remover agent to remove unnecessary comments.
8. **CODE REVIEW**: Use test-value-auditor agent to remove low-value tests.
