# Level 1: High-Level Prompt

Static, ad-hoc prompts for repeat work. Contains 1-3 sections: Title, Purpose, and a simple instruction.

**When to use:** One-off tasks you repeat. "Three times marks a pattern—copy whatever you're doing and write it as a high-level prompt."

**Builds on:** Nothing—this is the foundation.

## Example

```markdown
# Start Development Server

Start the application for development.

1. Navigate to the application directory: `cd apps/my_app`
2. Install dependencies (if needed): `bun install`
3. Start the development server: `bun run dev`
4. Open your browser to: http://localhost:5173/
```

## Characteristics

- No dynamic variables
- No metadata section needed
- Direct, actionable instructions
- Great place to start, terrible place to end

## When to Level Up

Move to Level 2 (Workflow) when:
- You need inputs that change between runs
- You want structured output format
- The task has distinct phases
