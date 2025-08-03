# Breakdown Use Case into Tasks

## Project Context
Read @README.md

## Use Case
$ARGUMENTS

## Task Breakdown Instructions

Given the above Use Case, create a hierarchical task breakdown following outside-in development principles. Generate tasks that:

1. **Start with the outermost layer** (UI for web apps, API endpoints for services)
2. **Create stubs for dependencies** in each task
3. **Size tasks for 1-4 hours of work** for optimal LLM effectiveness
4. **Include explicit success criteria** for each task
5. **Maintain traceability** to Use Case steps
6. **Ensure self-contained scope** with minimal external dependencies
7. **Keep context under 100,000 tokens** even if the LLM supports more

### Task Output Format

For each development layer, provide tasks in this structure:

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
        - [SERVICE_OR_COMPONENT_TO_STUB]
        - [SERVICE_OR_COMPONENT_TO_STUB]
      
      interface_contract: |
        # Input/Output specification
        [DEFINE_EXPECTED_INPUTS_AND_OUTPUTS]
      
      stub_implementation: |
        # Stub pattern to use
        [STUB_RETURN_VALUES_OR_BEHAVIOR]
    
    context_requirements:
      - [SPECIFIC_FILE_OR_DOCUMENTATION_NEEDED]
      - [RELATED_CODE_TO_REFERENCE]
      estimated_context_tokens: [NUMBER] # Keep under 100k
    
    estimated_hours: [1-4]  # Optimal for LLM assistance
    prerequisites: [LIST_TASK_IDS_THAT_MUST_BE_COMPLETE]
```

## Example Breakdown Structure

```
Layer 1: UI/API (Outermost)
├── Task 1.1: Create endpoint/form structure with stubbed logic (2 hrs)
├── Task 1.2: Add input validation with stubbed responses (1 hr)
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
```

## Task Sizing Guidelines by Type

Based on LLM effectiveness research, use these sizing guidelines:

### Feature Development
- **Simple CRUD operations**: 30-60 minutes
- **Basic UI components**: 1-2 hours
- **API endpoints with validation**: 2-3 hours
- **Complex business logic**: 3-4 hours (consider breaking down further)

### Bug Fixes
- **Single function repairs**: 15-30 minutes
- **Module-level fixes**: 30-60 minutes
- **Cross-component issues**: Split into multiple tasks

### Refactoring
- **Single class/module improvements**: 1-2 hours
- **Remove unused abstractions**: 30-60 minutes
- **Complex architectural changes**: Not suitable for LLM-primary work

### Testing
- **Unit tests for single class**: 15-45 minutes
- **Integration test scenarios**: 1-2 hours
- **End-to-end test flows**: 2-3 hours

### Documentation
- **API endpoint documentation**: 30-60 minutes
- **Component README**: 1-2 hours
- **Architecture diagrams**: 2-4 hours (with human review)

## Special Instructions for LLM Context

When generating tasks, ensure each task includes:

1. **Self-contained context**: Each task should be implementable without referring to other tasks
2. **Clear boundaries**: Explicitly state what is IN scope and OUT of scope
3. **Stub specifications**: Provide exact data/responses for stubs
4. **Testing requirements**: Include specific test scenarios derived from Use Case
5. **Integration points**: Clearly define interfaces between layers
6. **Context optimization**: Keep essential context under 100,000 tokens
7. **The 4-Hour Rule**: No task should require more than 4 hours of focused work

### Context Engineering Best Practices

- **Front-load critical information**: Place most important context at the beginning
- **Avoid the middle**: Don't bury critical details in the middle of long contexts
- **Use structured formats**: YAML, JSON, or markdown for clear information hierarchy
- **Reference don't duplicate**: Link to files rather than copying large code blocks
- **Summarize dependencies**: Provide interface signatures rather than full implementations

## Traceability Matrix Template

Generate a traceability matrix showing:

```markdown
| Use Case Step | Task IDs | Layer | Verification Method |
|---------------|----------|-------|-------------------|
| Step 1        | UI-UC1-01, SVC-UC1-01 | UI, Service | Unit test + Integration test |
| Step 2        | UI-UC1-02, SVC-UC1-02, DB-UC1-01 | UI, Service, DB | End-to-end test |
```

## Additional Prompting Guidelines

For each task, consider including:

- **CO-STAR elements**: Context, Objective, Style, Tone, Audience, Response format
- **Memory aids**: Links to previous related tasks or shared context documents
- **Validation steps**: How to verify the task meets Use Case requirements
- **Rollback plan**: How to revert if the implementation doesn't meet needs

## Output Request

Based on the provided Use Case, please:

1. Analyze the Main Success Scenario and identify distinct functional boundaries
2. Determine the appropriate starting layer (UI or API) based on the tech stack
3. Generate a complete task breakdown following the outside-in pattern
4. Ensure all tasks follow the 1-4 hour sizing guideline
5. Create a traceability matrix linking Use Case steps to tasks
6. Identify any Use Case elements that may need clarification for LLM implementation
7. Suggest an implementation order that minimizes blocked tasks
8. Flag any tasks that might exceed the 4-hour threshold and recommend splitting

After presenting the breakdown:
9. Ask for user feedback and iterate until approved
10. Upon approval, generate the file structure as specified below

## Measuring Task Effectiveness

Red flags indicating tasks are too large:
- LLM generates incomplete or off-target solutions
- Frequent context window errors or truncation
- Developer spends more time fixing than the LLM saves
- Tasks regularly exceed 4-hour estimates
- High cognitive load reported by developers

## Iterative Refinement Process

After generating the initial task breakdown:

1. **Present the breakdown** to the user with the question:
   ```
   I've generated a task breakdown for the Use Case "[USE_CASE_NAME]".
   
   Please review the breakdown above. Would you like me to:
   - Adjust task sizing (split or combine tasks)
   - Add more technical detail to specific tasks
   - Modify the layering approach
   - Change stub implementations
   - Refine acceptance criteria
   - Or any other modifications?
   
   Please describe any changes you'd like, or respond "breakdown is ok" if you're satisfied.
   ```

2. **Iterate on feedback** until the user indicates satisfaction
   - Apply requested changes
   - Re-present the updated breakdown
   - Continue until user responds with "breakdown is ok" or similar confirmation

3. **File Generation Instructions**

   When the user approves the breakdown, generate the following file structure specification:
   
   ```
   Creating task specification files...
   
   Directory structure:
   .claude/specs/{{USE_CASE_SLUG}}/
   ├── README.md           # Overview and traceability matrix
   ├── task-summary.yaml   # Complete breakdown in single file
   └── tasks/
       ├── {{TASK_ID_1}}.md
       ├── {{TASK_ID_2}}.md
       └── ...
   ```

   Where `{{USE_CASE_SLUG}}` is generated from the Use Case name (lowercase, spaces replaced with hyphens, special characters removed).

### Individual Task File Format

Each task file (`tasks/{{TASK_ID}}.md`) should contain:

```markdown
# {{TASK_ID}}: {{TASK_TITLE}}

## Overview
- **Layer**: {{LAYER}}
- **Type**: {{TASK_TYPE}}
- **Estimated Hours**: {{HOURS}}
- **Use Case Steps**: {{STEPS}}

## Description
{{TASK_DESCRIPTION}}

## Acceptance Criteria
{{ACCEPTANCE_CRITERIA_AS_MARKDOWN_CHECKLIST}}

## Technical Details

### Component
- **Name**: {{COMPONENT_NAME}}
- **Location**: {{EXPECTED_FILE_PATH}}

### Dependencies to Stub
{{DEPENDENCIES_LIST}}

### Interface Contract
```{{LANGUAGE}}
{{INTERFACE_SPECIFICATION}}
```

### Stub Implementation
```{{LANGUAGE}}
{{STUB_CODE}}
```

## Context Requirements
- **Required Files**:
  {{REQUIRED_FILES_LIST}}
- **Estimated Context Tokens**: {{TOKEN_COUNT}}

## Prerequisites
- {{PREREQUISITE_TASKS}}

## Implementation Notes
{{ANY_ADDITIONAL_NOTES}}

---
*Generated from Use Case: {{USE_CASE_NAME}}*
*Task ID: {{FULL_TASK_ID}}*
```

### README.md Format

The README.md file should contain:

```markdown
# {{USE_CASE_NAME}} - Task Breakdown

Generated on: {{DATE}}

## Use Case Summary
{{USE_CASE_GOAL}}

## Tech Stack
- **Frontend**: {{FRONTEND_TECH}}
- **Backend**: {{BACKEND_TECH}}
- **Database**: {{DATABASE_TECH}}

## Task Overview
Total Tasks: {{TASK_COUNT}}
Total Estimated Hours: {{TOTAL_HOURS}}

## Traceability Matrix
{{TRACEABILITY_MATRIX_AS_MARKDOWN_TABLE}}

## Implementation Order
{{ORDERED_TASK_LIST_WITH_DEPENDENCIES}}

## Layer Summary
{{TASKS_GROUPED_BY_LAYER}}
```

### task-summary.yaml Format

The task-summary.yaml file should contain the complete breakdown in a single file:

```yaml
use_case:
  name: {{USE_CASE_NAME}}
  slug: {{USE_CASE_SLUG}}
  goal: {{USE_CASE_GOAL}}
  generated_date: {{ISO_DATE}}
  total_hours: {{TOTAL_HOURS}}

layers:
  - name: {{LAYER_NAME}}
    tasks:
      {{COMPLETE_TASK_OBJECTS_AS_ORIGINALLY_GENERATED}}
```

Remember: 
- Each task should be completable by an LLM in a single session with all necessary context
- Research shows 20-55% productivity gains when tasks are properly sized at 1-4 hours
- Tasks requiring more than 4 hours see less than 10% LLM success rates
