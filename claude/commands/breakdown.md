# Breakdown Use Case into Tasks

## PROJECT CONTEXT:
- Read @README.md

## USE CASE
$ARGUMENTS

## TASK BREAKDOWN INSTRUCTIONS
Given the above Use Case, create a hierarchical task breakdown following
outside-in development principles. Generate tasks that:

1. Start with the outermost layer (UI for web apps, API endpoints for services)
2. Create stubs for dependencies in each task
3. Size tasks for 1-4 hours of work for optimal LLM effectiveness
4. Include explicit success criteria for each task
5. Maintain traceability to Use Case steps
6. Ensure self-contained scope with minimal external dependencies
7. Keep context under 100,000 tokens even if the LLM supports more

```yaml
layer: [UI|API|Service|Domain|Infrastructure|Database]
tasks:
  - id: [LAYER_ABBREVIATION]-[USE_CASE_ID]-[SEQUENTIAL_NUMBER]
    title: [DESCRIPTIVE_TASK_TITLE]
    type: [feature|bugfix|refactoring|testing|documentation]
    description: |
      Implement [SPECIFIC_FUNCTIONALITY] that handles [USE_CASE_STEP_NUMBERS].
      This task creates the [COMPONENT_TYPE] with stubs for [DEPENDENT_LAYER].
    
    use_case_steps: [1, 2, 3]  # Which steps this implements
    
    acceptance_criteria:
      - [ ] [SPECIFIC_TESTABLE_CRITERION]
      - [ ] [SPECIFIC_TESTABLE_CRITERION]
      - [ ] Stubs created for [DEPENDENT_SERVICES]
      - [ ] Unit tests cover [COVERAGE_REQUIREMENT]
    
    technical_details:
      component_name: [FILE_OR_COMPONENT_NAME]
      dependencies_to_stub:
        - [SERVICE_OR_COMPONENT_TO_MOCK]
        - [SERVICE_OR_COMPONENT_TO_MOCK]
      
      interface_contract: |
        # Input/Output specification
        [DEFINE_EXPECTED_INPUTS_AND_OUTPUTS]
      
      stub_implementation: |
        # Stub pattern to use
        [MOCK_RETURN_VALUES_OR_BEHAVIOR]
    
    context_requirements:
      - [SPECIFIC_FILE_OR_DOCUMENTATION_NEEDED]
      - [RELATED_CODE_TO_REFERENCE]
      estimated_context_tokens: [NUMBER] # Keep under 100k
    
    estimated_hours: [1-4]  # Optimal for LLM assistance
    story_points: [1-3]     # Following the 4-hour rule
    prerequisites: [LIST_TASK_IDS_THAT_MUST_BE_COMPLETE]
```

## EXAMPLE BREAKDOWN STRUCTURE
Layer 1: UI/API (Outermost)
├── Task 1.1: Create endpoint/form structure with stubbed logic (2 hrs)
├── Task 1.2: Add input validation with mocked responses (1 hr)
├── Task 1.3: Implement error handling UI (1.5 hrs)
└── Task 1.4: Add loading states and feedback (1 hr)

Layer 2: Service/Business Logic
├── Task 2.1: Core business logic with stubbed data access (2 hrs)
├── Task 2.2: Business validation rules (1.5 hrs)
├── Task 2.3: Service error handling and logging (1 hr)
└── Task 2.4: Response mapping and transformation (1 hr)

Layer 3: Domain/Repository
├── Task 3.1: Domain model implementation (1 hr)
├── Task 3.2: Repository interface with stub implementation (2 hrs)
├── Task 3.3: Query builders and filters (1.5 hrs)
└── Task 3.4: Caching layer setup (2 hrs)

Layer 4: Infrastructure/Database
├── Task 4.1: Database schema and migrations (2 hrs)
├── Task 4.2: Basic CRUD operations (1.5 hrs)
├── Task 4.3: Query optimization and indexes (1 hr)
└── Task 4.4: Connection pooling and error handling (1.5 hrs)

## TASK SIZING GUIDELINES BY TYPE
Based on LLM effectiveness research, use these sizing guidelines:

### Feature Development
- Simple CRUD operations: 30-60 minutes
- Basic UI components: 1-2 hours
- API endpoints with validation: 2-3 hours
- Complex business logic: 3-4 hours (consider breaking down further)

### Bug Fixes
- Single function repairs: 15-30 minutes
- Module-level fixes: 30-60 minutes
- Cross-component issues: Split into multiple tasks

### Refactoring
- Single class/module improvements: 1-2 hours
- Remove unused abstractions: 30-60 minutes
- Complex architectural changes: Not suitable for LLM-primary work

### Testing
- Unit tests for single class: 15-45 minutes
- Integration test scenarios: 1-2 hours
- End-to-end test flows: 2-3 hours

### Documentation
- API endpoint documentation: 30-60 minutes
- Component README: 1-2 hours
- Architecture diagrams: 2-4 hours (with human review)

## SPECIAL INSTRUCTIONS FOR LLM CONTEXT
When generating tasks, ensure each task includes:

1. Self-contained context: Each task should be implementable without referring to other tasks
2. Clear boundaries: Explicitly state what is IN scope and OUT of scope
3. Stub specifications: Provide exact responses for stubs
4. Testing requirements: Include specific test scenarios derived from Use Case
5. Integration points: Clearly define interfaces between layers
6. Context optimization: Keep essential context under 100,000 tokens
7. The 4-Hour Rule: No task should require more than 4 hours of focused work

## CONTEXT ENGINEERING BEST PRACTICES
- Front-load critical information: Place most important context at the beginning
- Avoid the middle: Don't bury critical details in the middle of long contexts
- Use structured formats: YAML, JSON, or markdown for clear information hierarchy
- Reference don't duplicate: Link to files rather than copying large code blocks
- Summarize dependencies: Provide interface signatures rather than full implementations

## TRACEABILITY MATRIX TEMPLATE
Generate a traceability matrix showing:

```markdown
| Use Case Step | Task IDs | Layer | Verification Method |
|---------------|----------|-------|-------------------|
| Step 1        | UI-UC1-01, SVC-UC1-01 | UI, Service | Unit test + Integration test |
| Step 2        | UI-UC1-02, SVC-UC1-02, DB-UC1-01 | UI, Service, DB | End-to-end test |
```

## ADDITIONAL PROMPTING GUIDELINES
For each task, consider including:
- CO-STAR elements: Context, Objective, Style, Tone, Audience, Response format
- Memory aids: Links to previous related tasks or shared context documents
- Validation steps: How to verify the task meets Use Case requirements
- Rollback plan: How to revert if the implementation doesn't meet needs

## OUTPUT REQUEST
Based on the provided Use Case, please:

1. Analyze the Main Success Scenario and identify distinct functional boundaries
2. Determine the appropriate starting layer (UI or API) based on the tech stack
3. Generate a complete task breakdown following the outside-in pattern
4. Ensure all tasks follow the 1-4 hour sizing guideline (1-3 story points)
5. Create a traceability matrix linking Use Case steps to tasks
6. Identify any Use Case elements that may need clarification for LLM implementation
7. Suggest an implementation order that minimizes blocked tasks
8. Flag any tasks that might exceed the 4-hour threshold and recommend splitting

## MEASURING TASK EFFECTIVENESS
Red flags indicating tasks are too large:

- LLM generates incomplete or off-target solutions
- Frequent context window errors or truncation
- Developer spends more time fixing than the LLM saves
- Tasks regularly exceed 4-hour estimates
- High cognitive load reported by developers

Remember:

- Each task should be completable by an LLM in a single session with all necessary context
- Research shows 20-55% productivity gains when tasks are properly sized at 1-4 hours
- Tasks requiring more than 4 hours see less than 10% LLM success rates
