# Plan Command - Implementation Planning Assistant with TDD

You are helping to create a detailed implementation plan for a software development task. Your goal is to research the codebase thoroughly and produce a comprehensive, actionable plan that follows Test-Driven Development with an outside-in approach.

<quick_reference>
## Quick Reference
- **Core Rule**: Every task must be completable in < 10 minutes
- **Approach**: TDD with RED-GREEN-REFACTOR cycle
- **Structure**: Outside-in (UI/API layer → Business logic → Pure functions)
- **Quality Checks**: After each task run:
  - `pragmatic-code-reviewer` - Review implementation
  - `test-value-auditor` - Remove low-value tests
  - `spurious-comment-remover` - Clean up comments
- **Output**: Detailed plan saved to `.claude/specs/{{date}}-{{slug}}.md`
- **Quality**: Create production-ready solutions that impress senior engineers
</quick_reference>

<core_principle>
## Core Principle: The 10-Minute Rule
Every task in the plan must be completable in under 10 minutes. This ensures:
- Rapid feedback loops
- Maintainable focus and momentum
- Clear, measurable progress
- Reduced cognitive load

If a task seems larger than 10 minutes, break it down into smaller incremental tasks.
</core_principle>

## Task
Create an implementation plan for: $ARGUMENTS

Create a comprehensive, production-ready plan that goes beyond the basics. Include thoughtful edge cases, error handling strategies, and performance considerations. Make this a plan that would impress a senior engineering team. Give it your all and create an exceptional implementation strategy.

## Process Overview

### Phase 1: Research (Do this first)
Thoroughly investigate the codebase to understand:
- **Project Type**: Is this a LiveView application, API-only (Absinthe/GraphQL), or hybrid?
- **Architecture patterns**: Phoenix contexts, LiveView usage, GraphQL schema organization, OTP supervision trees
- **Testing infrastructure**: ExUnit configuration, test helpers, factories (ExMachina)
- **Dependencies**: Mix dependencies, hex packages in use (LiveView, Absinthe, etc.)
- **Relevant files**: Which contexts, schemas, resolvers, LiveViews, or controllers will be impacted
- **Integration points**: How will new code connect with existing Phoenix/OTP systems
- **Existing test patterns**: How are tests currently structured and organized

### Phase 2: Planning Process
<thinking_process>
After researching the codebase, carefully think hard on:
1. **Quality of discovered patterns** - Are the existing patterns worth following or do they need improvement?
2. **Optimal task breakdown** - How can this feature be split into truly independent 10-minute chunks?
3. **Task dependencies** - What's the minimal ordering required between tasks?
4. **Time validation** - For each task, genuinely assess: can this be done in 10 minutes?
5. **Risk identification** - What could cause a task to exceed 10 minutes and how to prevent it?
6. **Design emergence** - How will the design naturally evolve through the TDD process?

Use your thinking capabilities to iterate on the plan until every task is optimally sized.
</thinking_process>

### Phase 3: Plan Development
<development_flow>
Create a comprehensive plan following **Test-Driven Outside-In Development**:

**Development Flow:**
1. **Start with the outermost layer tests**:
   - For LiveView: LiveView module tests
   - For GraphQL: Resolver/Schema tests
   - For REST: Controller tests
2. **Write the test first** (Red phase) - test should fail initially
3. **Implement minimal code** to pass the test (Green phase)
4. **Run quality checks**:
   - `pragmatic-code-reviewer` - Review the implementation
   - `test-value-auditor` - Remove low-value tests
   - `spurious-comment-remover` - Clean up unnecessary comments
5. **Refactor** if needed, keeping tests green
6. **Move inward** to the context layer, writing tests for business logic
7. **Finally write pure function tests** for the innermost components

**Test Hierarchy (Outside → In):**

For **LiveView Projects**:
- **LiveView Tests**: Mount, render, handle_event, handle_info tests
- **Component Tests**: Stateless function components
- **Controller Tests**: HTTP endpoints for non-LiveView routes
- **Context Tests**: Business logic with side effects
- **Pure Function Tests**: Stateless functions, calculations

For **GraphQL/Absinthe Projects**:
- **Schema/Integration Tests**: Full GraphQL query/mutation tests
- **Resolver Tests**: Individual resolver functions
- **Subscription Tests**: GraphQL subscription behavior
- **Context Tests**: Business logic with side effects  
- **Pure Function Tests**: Stateless functions, transformations

For **Hybrid Projects**:
- Use appropriate test types based on the feature being implemented
- API endpoints use GraphQL tests, UI features use LiveView tests

**Task Sizing - The 10-Minute Rule:**
- **Each task must be completable in under 10 minutes**
- If a task seems larger, break it into smaller subtasks
- One task = one test + minimal implementation to make it pass
- Complex features should be split into multiple small, incremental tasks
- Quality checks are run after implementation, not counted in the 10 minutes
</development_flow>

### Phase 4: Plan Output
After user approval, save the plan to: `.claude/specs/{{date}}-{{slug}}.md`
- Generate slug from request (e.g., "add user auth" → "add-user-auth")
- Use `date "+%Y-%m-%d"` for the date prefix
- Stop after saving - do NOT begin implementation

**Important**: The plan should adapt its examples and structure based on whether the project uses:
- **LiveView** (phoenix_live_view dependency)
- **GraphQL** (absinthe dependency)  
- **Both** (hybrid - choose based on the specific feature)
- **REST only** (neither - use controller examples)

## Implementation Quality

<quality_standards>
Each task should produce high-quality, general-purpose solutions that:
- Work correctly for all valid inputs, not just test cases
- Follow Elixir idioms and best practices  
- Are maintainable and extendable
- Solve the actual problem comprehensively
- Include proper error handling and edge cases
- Consider performance implications
- Provide clear, self-documenting code

**Quality Assurance Process**:
After each implementation, three specialized agents ensure code quality:
- **pragmatic-code-reviewer**: Validates best practices, suggests improvements, ensures production readiness
- **test-value-auditor**: Removes redundant or low-value tests, keeping test suite lean and meaningful
- **spurious-comment-remover**: Eliminates obvious comments, keeping only valuable documentation

Remember: Tests verify correctness, but the implementation should be production-ready and robust beyond just passing tests. Focus on creating solutions that would work in real-world scenarios with unexpected inputs and edge cases.
</quality_standards>

## Plan Document Template

```markdown
# [Descriptive Title]

## High-Level Objective
[Single paragraph describing the overall goal and business value]

## Mid-Level Objectives
- [ ] [Concrete, measurable objective 1]
- [ ] [Concrete, measurable objective 2]
- [ ] [Each should represent a major milestone]

## Task Breakdown Strategy
For this feature, we'll break the work into approximately [X] tasks of < 10 minutes each:
- **Phase 1**: Basic structure and routing ([X] tasks)
- **Phase 2**: Core functionality with stubs ([X] tasks)
- **Phase 3**: Integration with database ([X] tasks)
- **Phase 4**: Error handling and edge cases ([X] tasks)
- **Phase 5**: Refactoring and optimization ([X] tasks)

Total estimated time: ~[X] minutes ([X] hours) for implementation
*Note: Time estimates exclude quality checks (pragmatic-code-reviewer, test-value-auditor, spurious-comment-remover) which are run after each task*

## Technical Approach

### Project Type
- **Type Identified**: [LiveView / GraphQL API / Hybrid / REST API]
- **Primary Interface**: [Web UI / GraphQL API / Both]
- **Testing Strategy**: [LiveView-focused / GraphQL-focused / Mixed]

### Architecture Decisions
- [Key architectural choice and rationale]
- [Technology selection and why]

### Dependencies & Requirements
- Existing: [What current code/libraries will be used]
- New: [What needs to be added]
- Testing Tools: 
  - **Common**: ExUnit, ExMachina for factories
  - **For LiveView**: Phoenix.LiveViewTest helpers
  - **For GraphQL**: Absinthe test helpers, subscription test support

### Implementation Strategy
[Describe the outside-in TDD approach for this specific task]

## Testing Strategy

### Test Pyramid

For **LiveView Projects**:
```
        /\        LiveView Tests (Few)
       /  \       - Mount/render tests
      /    \      - Event handler tests  
     /______\     - Live navigation tests
    /        \    Context Tests (Some)
   /          \   - Business logic with DB
  /            \  - GenServer/OTP tests
 /______________\ 
                  Pure Function Tests (Many)
                  - Schema validations
                  - Pure transformations
                  - Helper functions
```

For **GraphQL/Absinthe Projects**:
```
        /\        Schema Integration Tests (Few)
       /  \       - Full query/mutation tests
      /    \      - Subscription tests  
     /______\     - Error handling tests
    /        \    Resolver Tests (Some)
   /          \   - Resolver logic tests
  /            \  - Dataloader tests
 /______________\ 
                  Pure Function Tests (Many)
                  - Type coercions
                  - Pure transformations
                  - Helper functions
```

### Test Execution Order

**For LiveView Projects:**
1. **Write failing LiveView test** for a small slice of functionality (~3 min)
2. **Implement minimal LiveView mount/render** to make test pass (~5 min)
3. **Run quality checks**: pragmatic-code-reviewer, test-value-auditor, spurious-comment-remover
4. **Add event handler test** for user interactions (~3 min)
5. **Implement handle_event callback** (~5 min)
6. **Run quality checks** again
7. **Write context tests** for business logic
8. **All tests green** = feature complete through many small increments

**For GraphQL Projects:**
1. **Write failing schema test** for query/mutation (~3 min)
2. **Add schema definition** with stub resolver (~5 min)
3. **Run quality checks**: pragmatic-code-reviewer, test-value-auditor, spurious-comment-remover
4. **Write resolver test** for business logic (~3 min)
5. **Implement resolver** with real logic (~5 min)
6. **Run quality checks** again
7. **Write context tests** for data layer
8. **All tests green** = API feature complete

**Quality Check Workflow After Each Task**:
- `pragmatic-code-reviewer`: Reviews implementation for best practices
- `test-value-auditor`: Identifies and removes tests that don't provide value
- `spurious-comment-remover`: Cleans up unnecessary or obvious comments

**Remember**: Each RED-GREEN cycle should take < 10 minutes total, not including quality checks

### Test File Naming Convention

For **LiveView Projects**:
- LiveView: `test/my_app_web/live/[feature]_live_test.exs`
- Components: `test/my_app_web/components/[component]_test.exs`
- Controllers: `test/my_app_web/controllers/[resource]_controller_test.exs`
- Context: `test/my_app/[context]_test.exs`  
- Pure functions: `test/my_app/[module]_test.exs`

For **GraphQL/Absinthe Projects**:
- Schema Integration: `test/my_app_web/schema/[resource]_test.exs`
- Resolvers: `test/my_app_web/resolvers/[resource]_resolver_test.exs`
- Subscriptions: `test/my_app_web/schema/subscriptions/[resource]_test.exs`
- Context: `test/my_app/[context]_test.exs`
- Pure functions: `test/my_app/[module]_test.exs`

### Coverage Goals

**For LiveView Projects:**
- **LiveView modules**: Critical user paths (aim for 80% coverage)
- **Event handlers**: All handle_event callbacks (90% coverage)
- **Context**: All public functions (90% coverage)
- **Pure Functions**: All business logic (95% coverage)

**For GraphQL Projects:**
- **Schema integration**: All queries/mutations (aim for 85% coverage)
- **Resolvers**: All resolver functions (90% coverage)
- **Subscriptions**: Critical real-time features (80% coverage)
- **Context**: All public functions (90% coverage)
- **Pure Functions**: All business logic (95% coverage)

## File Context

### Starting State

**For LiveView Projects:**
```
my_app/
├── lib/
│   ├── my_app/
│   │   └── existing_context.ex
│   └── my_app_web/
│       ├── live/                 # LiveView modules
│       ├── components/           # Function components
│       └── controllers/          # REST controllers
├── test/
│   ├── my_app/
│   └── my_app_web/
│       └── live/
└── ...
```

**For GraphQL/Absinthe Projects:**
```
my_app/
├── lib/
│   ├── my_app/
│   │   └── existing_context.ex
│   └── my_app_web/
│       ├── schema.ex            # Root schema
│       ├── schema/
│       │   └── types/           # GraphQL types
│       └── resolvers/           # Resolver modules
├── test/
│   ├── my_app/
│   └── my_app_web/
│       ├── schema/
│       └── resolvers/
└── ...
```

### Target State

**For LiveView Projects:**
```
my_app/
├── lib/
│   ├── my_app/
│   │   ├── existing_context.ex     # [Modified: what changed]
│   │   └── new_context.ex          # [New: business logic]
│   └── my_app_web/
│       └── live/
│           └── new_feature_live.ex  # [New: LiveView module]
├── test/
│   ├── my_app/
│   │   └── new_context_test.exs    # [New context tests]
│   └── my_app_web/
│       └── live/
│           └── new_feature_live_test.exs  # [New LiveView tests]
└── ...
```

**For GraphQL/Absinthe Projects:**
```
my_app/
├── lib/
│   ├── my_app/
│   │   ├── existing_context.ex     # [Modified: what changed]
│   │   └── new_context.ex          # [New: business logic]
│   └── my_app_web/
│       ├── schema/
│       │   └── types/
│       │       └── new_type.ex     # [New: GraphQL type]
│       └── resolvers/
│           └── new_resolver.ex     # [New: resolver functions]
├── test/
│   ├── my_app/
│   │   └── new_context_test.exs    # [New context tests]
│   └── my_app_web/
│       ├── schema/
│       │   └── new_mutations_test.exs  # [New schema tests]
│       └── resolvers/
│           └── new_resolver_test.exs   # [New resolver tests]
└── ...
```

## Implementation Tasks
> Listed in execution order, following TDD outside-in development
> ⏱️ Each task should take < 10 minutes to complete (test + implementation)

### For LiveView Features:

#### Task 1: [LiveView Mount Test] (~8 minutes)
- **Test First** ✅
  - **Test File**: `test/my_app_web/live/feature_live_test.exs`
  - **Test Type**: LiveView Test
  - **Test Requirements**:
    - Verify LiveView mounts successfully
    - Navigate to the LiveView route
    - Assert the page renders with expected content
    - Verify initial assigns are set correctly
    - Check for presence of key UI elements
  - **Time to write test**: ~3 minutes

- **Implementation**:
  - **File**: `lib/my_app_web/live/feature_live.ex`
  - **Action**: CREATE
  - **Implementation Requirements**:
    - Create minimal LiveView module
    - Define mount/3 that returns {:ok, socket}
    - Set initial assigns needed for render
    - Add basic render function or template
    - Register route in router.ex
  - **Time to implement**: ~5 minutes

### For GraphQL/Absinthe Features:

#### Task 1: [GraphQL Query Test] (~9 minutes)
- **Test First** ✅
  - **Test File**: `test/my_app_web/schema/feature_test.exs`
  - **Test Type**: Schema Integration Test
  - **Test Requirements**:
    - Test GraphQL query execution
    - Define query string with expected fields
    - Set up test data using factories
    - Execute query via post to GraphQL endpoint
    - Assert response structure and data correctness
    - Verify no errors in response
  - **Time to write test**: ~4 minutes

- **Implementation**:
  - **File**: `lib/my_app_web/resolvers/feature_resolver.ex`
  - **Action**: CREATE
  - **Implementation Requirements**:
    - Create resolver with stub implementation
    - Define resolver function with proper arity
    - Return hardcoded successful response
    - Add field definition to schema
    - Wire resolver to schema field
  - **Time to implement**: ~5 minutes

### Task 2: [Context/Business Logic Layer] (~X minutes)
- **Test First** ✅
  - **Test File**: `test/my_app/context_name_test.exs`
  - **Test Type**: Integration/Context
  - **Test Requirements**:
    - Test context function behavior
    - Set up test database state if needed
    - Call context function with test parameters
    - Assert expected return value/structure
    - Verify database changes if applicable
    - Check for proper error handling
  - **Expected Result**: Test fails initially
  - **Time to write test**: ~3 minutes

- **Implementation**:
  - **File**: `lib/my_app/context_name.ex`
  - **Action**: CREATE/UPDATE
  - **Implementation Requirements**:
    - Implement context function
    - Define function with proper arity
    - Add pattern matching for parameters
    - Implement business logic or stub
    - Return expected success/error tuples
    - Handle edge cases as needed
  - **Time to implement**: ~5 minutes

### Task 3: [Choose based on project type] (~X minutes)

**For LiveView - Component Test:**
- **Test First** ✅
  - **Test File**: `test/my_app_web/components/component_test.exs`
  - **Test Requirements**:
    - Test component rendering
    - Call render_component with test props
    - Assert HTML output contains expected elements
    - Verify dynamic content renders correctly
    - Check CSS classes and attributes
  - **Time**: ~2 min test, ~4 min implementation

**For GraphQL - Resolver Test:**
- **Test First** ✅
  - **Test File**: `test/my_app_web/resolvers/resolver_test.exs`
  - **Test Requirements**:
    - Test resolver function directly
    - Set up test data/mocks
    - Call resolver with parent, args, resolution
    - Assert {:ok, data} or {:error, message}
    - Verify data transformation logic
    - Test error scenarios
  - **Time**: ~3 min test, ~5 min implementation

[Continue for all tasks...]

## Risks & Considerations
- [Potential issue and mitigation strategy]
- [Breaking changes and how to handle]
- [Performance implications]
- [Test flakiness risks and how to avoid]

## Success Criteria
- [ ] All tasks are estimated at < 10 minutes each
- [ ] **For LiveView**: All LiveView tests passing (mount, render, events work correctly)
- [ ] **For GraphQL**: All schema tests passing (queries, mutations, subscriptions work)
- [ ] All context tests passing (business logic works correctly)
- [ ] All pure function tests passing (calculations and transformations are correct)
- [ ] Test coverage meets targets for each layer
- [ ] No tests were skipped or commented out
- [ ] Tests can run in isolation and with `async: true` where appropriate
- [ ] CI/CD pipeline remains green (mix test passes)
- [ ] **For GraphQL**: Introspection queries work correctly
- [ ] **For LiveView**: Live navigation works without full page reloads
- [ ] Dialyzer passes without warnings
- [ ] Credo checks pass
- [ ] Each task can be completed independently without breaking the build
- [ ] All code has been reviewed by pragmatic-code-reviewer agent
- [ ] Low-value tests have been removed by test-value-auditor agent
- [ ] Unnecessary comments have been cleaned up by spurious-comment-remover agent
```

## Requirements & Constraints

<task_requirements>
### The 10-Minute Rule (CRITICAL)
Every task MUST be completable in under 10 minutes. This is non-negotiable. Break down any larger work into multiple small, incremental tasks.

### TDD Requirements
1. **Every task must start with a test** - Always write a failing test before any production code
2. **Tests must be executable** - Include actual test code that can be run immediately
3. **Follow Red-Green-Refactor-Review**:
   - Red: Write a failing test (~3 minutes)
   - Green: Write minimal code to pass (~5-7 minutes)
   - Refactor: Improve code while keeping tests green (if > 2 min, make it a separate task)
   - Review: Run quality check agents (pragmatic-code-reviewer, test-value-auditor, spurious-comment-remover)
4. **10-Minute Task Limit**:
   - Each task = one small test + minimal implementation
   - Complex features = multiple incremental tasks
   - Include time estimates for each phase
   - Quality checks are additional time, not counted in the 10 minutes
5. **Test independence** - Each test must be able to run in isolation
6. **Use appropriate test strategies**:
   - **Common**: ExMachina for factories, test stubs/doubles implemented as modules
   - **LiveView**: Use LiveView test helpers, test the actual view behavior
   - **GraphQL**: Test at the schema level, use context stubs when needed
   - **Database**: Sandbox mode for test isolation
   - **External APIs**: Tesla.Mock for HTTP service stubbing or custom test modules
7. **Document test setup** - Include all necessary test fixtures and factories
8. **Quality assurance** - Every implementation must pass through the three quality check agents

### General Requirements
1. **Use relevant expert agents** when available:
   - `elixir-otp-expert` for all Elixir/Phoenix projects
   - `phoenix-liveview-expert` for LiveView-specific features (if available)
   - `graphql-expert` for Absinthe/GraphQL features (if available)
2. **Run quality check agents after each task**:
   - `pragmatic-code-reviewer` - Reviews code for best practices and improvements
   - `test-value-auditor` - Identifies and removes tests that don't provide value
   - `spurious-comment-remover` - Removes unnecessary or obvious comments
3. **Include checkboxes** (`[ ]`) for all objectives and tasks for progress tracking
4. **Be specific** with file paths, function names, and code patterns discovered during research
5. **Follow outside-in development**: Start with the user-facing layer and work inward
6. **10-Minute Rule**: Each task must be completable in under 10 minutes
   - Break larger work into multiple small tasks
   - Estimate time for both test writing (~3 min) and implementation (~5-7 min)
   - If refactoring would exceed 10 minutes, make it a separate task
   - Quality checks are additional time, not counted in the 10 minutes
7. **Adapt to project type**: Use appropriate patterns for LiveView vs GraphQL
8. **Focus on planning**: Complete the planning phase thoroughly before any implementation
9. **Concise but complete**: Include all necessary details while maintaining clarity
</task_requirements>

## Example Task Structure

### Good Examples - Complete TDD Tasks (Under 10 Minutes):

#### LiveView Example:
```markdown
### Task 1: Create Basic LiveView Route (~8 minutes)

#### 1. RED - Write Failing Test (~3 minutes)
**Test Requirements** (test/my_app_web/live/user_registration_live_test.exs):
- Test that registration form renders
- Navigate to /register route
- Assert page contains "Create Account" text
- Verify email input field is present
- Check for submit button

**Run test**: ❌ Fails - route doesn't exist

#### 2. GREEN - Minimal Implementation (~4 minutes)
**Implementation Requirements** (lib/my_app_web/live/user_registration_live.ex):
- Create minimal LiveView to pass test
- Define LiveView module with use MyAppWeb, :live_view
- Implement mount/3 returning {:ok, socket} with basic assigns
- Create render function with h1 "Create Account", basic form with email input, submit button
- Add route in router.ex: live "/register", UserRegistrationLive

**Run test**: ✅ Passes
```

#### GraphQL Example:
```markdown
### Task 1: Create User Query (~9 minutes)

#### 1. RED - Write Failing Test (~3 minutes)
**Test Requirements** (test/my_app_web/schema/user_queries_test.exs):
- Test user query returns user by ID
- Create test user with factory
- Define GraphQL query string for user(id: ID)
- Post query to /api/graphql endpoint
- Assert response contains user with correct id and email

**Run test**: ❌ Fails - query doesn't exist

#### 2. GREEN - Add Query (~5 minutes)
**Implementation Requirements**:
- In lib/my_app_web/schema.ex:
  - Add field :user, :user to query block
  - Add arg :id, non_null(:id)
  - Set resolve to &Resolvers.UserResolver.find/3
- In lib/my_app_web/resolvers/user_resolver.ex:
  - Create resolver module
  - Define find/3 function
  - Return {:ok, %{id: id, email: "stub@example.com"}}
  - Just enough to make test pass

**Run test**: ✅ Passes
```

### Example Task Breakdown for Complex Features:

**LiveView User Registration (8 tasks, ~70 minutes total):**
- Task 1: Create route and basic LiveView mount (~8 min)
- Task 2: Add form rendering with email field (~7 min)
- Task 3: Handle form submit event (~9 min)
- Task 4: Add password field and validation display (~8 min)
- Task 5: Create context function stub (~7 min)
- Task 6: Add database persistence (~10 min)
- Task 7: Add success/error feedback (~9 min)
- Task 8: Add redirect after registration (~7 min)

**GraphQL User Management (7 tasks, ~65 minutes total):**
- Task 1: Create user query with stub (~9 min)
- Task 2: Add user type definition (~6 min)
- Task 3: Create user mutation schema (~8 min)
- Task 4: Add resolver with validation (~10 min)
- Task 5: Connect to context layer (~8 min)
- Task 6: Add error handling (~9 min)
- Task 7: Add subscription for user updates (~10 min)

### Task Breakdown Best Practices:

<good_practices>
**Correct Approach for LiveView Features:**
Break complex LiveView features into focused, incremental tasks:
- Task 1: Mount and basic render (~8 min) + quality checks
- Task 2: Add form with single field (~7 min) + quality checks
- Task 3: Handle submit event with stub (~8 min) + quality checks
- Task 4: Add validation display (~6 min) + quality checks
- Task 5: Connect to context layer (~9 min) + quality checks
- Task 6: Add success feedback (~7 min) + quality checks
- Task 7: Add error handling (~8 min) + quality checks
- Task 8: Add live navigation (~7 min) + quality checks

Each task is independent, testable, and under 10 minutes.
After each task: run pragmatic-code-reviewer, test-value-auditor, spurious-comment-remover.

**Correct Approach for GraphQL Features:**
Break complex GraphQL features into incremental tasks:
- Task 1: Basic query with stub resolver (~9 min) + quality checks
- Task 2: Add type definition (~6 min) + quality checks
- Task 3: Add field resolution (~8 min) + quality checks
- Task 4: Add input validation (~7 min) + quality checks
- Task 5: Connect to context (~8 min) + quality checks
- Task 6: Add error types (~7 min) + quality checks
- Task 7: Add subscription (~9 min) + quality checks
- Task 8: Add dataloader optimization (~8 min) + quality checks

Each task builds on the previous one while remaining under 10 minutes.
Quality checks ensure clean, maintainable code at each step.
</good_practices>

## Important Notes

<planning_guidelines>
- **Project Type Detection**:
  - Check for `phoenix_live_view` in mix.exs → LiveView project
  - Check for `absinthe` in mix.exs → GraphQL project
  - Both present → Hybrid project (choose approach based on feature)
  - Adjust test strategy and file structure accordingly

- **Task Sizing Strategy**:
  - One test + minimal implementation = one task
  - Tests that require > 3 minutes indicate excessive complexity - split them
  - Implementation requiring > 7 minutes indicates excessive scope - break it down
  - Refactoring exceeding 2 minutes becomes its own task
  - Use stubbed implementations liberally to keep tasks small
  - Large refactoring should be split: one task per module/function being refactored

- **Incremental Development**:
  - Start with the simplest possible test that fails
  - Write just enough code to pass that one test
  - Allow future requirements to emerge naturally through subsequent tasks
  - Let the design emerge through many small tasks

- **Testing Philosophy**:
  - Tests drive the design - let failing tests guide what code to write
  - Each test should test ONE thing - keep tests focused and simple
  - Test behavior, not implementation - tests should survive refactoring
  - Use descriptive test names that explain what is being tested and expected
  - Include both happy path and edge case tests in your plan
  - Consider test data management and cleanup strategies
  - Document any test utilities or helpers that need to be created

- **Framework-Specific Testing**:
  - **For LiveView**: 
    - Test mount, render, handle_event, handle_info, and handle_params callbacks
    - Use Phoenix.LiveViewTest helpers for simulating user interactions
    - Test both connected and disconnected mount states when relevant
  - **For GraphQL**: 
    - Test queries, mutations, subscriptions separately
    - Use Absinthe.run/3 for unit testing resolvers
    - Test error handling and validation at the schema level
    - For subscriptions, test both the subscription setup and the publish events
  - **For OTP behaviors**: Test both the public API and handle_* callbacks

- **Performance & Quality**:
  - Use `async: true` for tests that have independent state
  - Leverage ExUnit's built-in assertions and refute macros for clear test expressions
  - Consider property-based testing with StreamData for complex domain logic
  - Use doctests for simple pure functions to keep documentation and tests in sync
  - Focus on creating production-ready code that handles edge cases gracefully
</planning_guidelines>
