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
   - Schemas, diagrams, or other visual representations
   - Step-by-step implementation tasks
   - Files that will need to be created or modified
   - Testing strategy
   - Potential risks or considerations

3. Present the plan using the ExitPlanMode tool

4. After the user approves the plan:
   - Generate a slug based on the user's request (i.e. "add user auth" -> "add-user-auth")
   - Run `date "+%Y-%m-%d"` to get today's date
   - Write the complete plan to `.claude/specs/{{date}}-{{slug}}.md` (or filename specified by user)
   - Stop immediately without implementing anything
   - Wait for further instructions

## Important Notes

- Use any relevant custom agents (e.g. `elixir-otp-expert`, `ruby-rails-expert`, etc.)
- The plan should include `[ ]` checkboxes so you can mark the tasks as done as you go
- The user may want to break down parts of the plan further
- Do not proceed with implementation unless explicitly instructed
- Focus on being thorough in research but concise in presentation
- Include specific file paths and code patterns discovered during research
