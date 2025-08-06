# Plan Command

Enter plan mode to research and develop an implementation plan for:

$ARGUMENTS

## Instructions

1. Research the codebase thoroughly to understand:
   - Current implementation patterns
   - Existing dependencies and tools
   - Relevant files and modules
   - Potential impacts and dependencies

2. Develop a comprehensive implementation plan that includes:
   - High-level approach and architecture decisions
   - Schemas, diagrams, and other visual representations
   - Step-by-step implementation tasks that use an outside-in development approach (e.g. start with the highest level of abstraction and work down, using stubs or placeholders as needed)
   - Files that will need to be created or modified
   - Potential risks or considerations

3. Present the plan using the ExitPlanMode tool

4. After the user approves the plan:
   - Generate a slug based on the user's request (i.e. "add user auth" -> "add-user-auth")
   - Run `date "+%Y-%m-%d"` to get today's date
   - Write the complete plan to `.claude/specs/{{date}}-{{slug}}.md` (or filename specified by user) using the Plan Output Format
   - Stop immediately without implementing anything
   - Wait for further instructions

## Plan Output Format

```markdown
# {{Specification Title}}

## High-Level Objective

- [High level goal goes here - what do you want to build?]

## Mid-Level Objective

- [List of mid-level objectives - what are the steps to achieve the high-level objective?]
- [Each objective should be concrete and measurable]
- [But not too detailed - save details for implementation notes]

## Implementation Notes
- [Important technical details - what are the important technical details?]
- [Dependencies and requirements - what are the dependencies and requirements?]
- [Coding standards to follow - what are the coding standards to follow?]
- [Other technical guidance - what are other technical guidance?]

## Context

### Beginning context
- [List of files that exist at start - what files exist at start?]

### Ending context
- [List of files that will exist at end - what files will exist at end?]

## Low-Level Tasks
> Ordered from start to finish beginning at the outermost level

1. [First task - what is the first task?]
What prompt would you run to complete this task?
What file do you want to CREATE or UPDATE?
What function do you want to CREATE or UPDATE?
What are details you want to add to drive the code changes?

2. [Second task - what is the second task?]
What prompt would you run to complete this task?
What file do you want to CREATE or UPDATE?
What function do you want to CREATE or UPDATE?
What are details you want to add to drive the code changes?

3. [Third task - what is the third task?]
What prompt would you run to complete this task?
What file do you want to CREATE or UPDATE?
What function do you want to CREATE or UPDATE?
What are details you want to add to drive the code changes?

...

```

## Important Notes

- Use any relevant custom agents (e.g. `elixir-otp-expert`, `ruby-rails-expert`, etc.)
- The plan should include `[ ]` checkboxes so you can mark the tasks as done as you go
- The user may want to break down parts of the plan further
- Do not proceed with implementation unless explicitly instructed
- Focus on being thorough in research but concise in presentation
- Include specific file paths and code patterns discovered during research
- The generated tasks **MUST** reflect an outside-in development approach (e.g. start with the highest level of abstraction and work down, using stubs or placeholders as needed)
- The plan **MUST** use the given Plan Output Format
