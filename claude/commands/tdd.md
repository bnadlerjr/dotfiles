# TDD Development Flow

Decompose the following high-level software requirement into discrete, testable functionalities and implement them using the Test-Driven Development (TDD) methodology. 

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

1. Analyze the requirement and identify single testable unit
2. Write a comprehensive test for the unit
3. Run the test and confirm it fails for the **EXPECTED** reason
4. Implement minimal code to pass the test
5. Run the test and confirm it passes
6. Refactor while keeping tests green
