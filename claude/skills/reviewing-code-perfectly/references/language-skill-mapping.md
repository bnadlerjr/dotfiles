# Language Skill Mapping

Map changed file extensions to language/framework skills. Load all matching skills before applying PERFECT principles.

## Extension-to-Skill Table

| File Extensions | Skill(s) to Load | Domain |
|---|---|---|
| `.ex`, `.exs` | `developing-elixir` | Elixir/Phoenix/OTP idioms, patterns, anti-patterns |
| `_test.exs` | `developing-elixir`, `testing-elixir` | ExUnit patterns, assertions, Ecto sandbox, Phoenix test helpers |
| `.ts`, `.tsx`, `.js`, `.jsx` | `developing-typescript` | TypeScript/React patterns, hooks, state management |
| `.test.ts`, `.test.tsx`, `.spec.ts`, `.spec.tsx` | `developing-typescript`, `testing-react-with-vitest` | React Testing Library, Vitest patterns, RTL query priority |
| `.sh`, `.bash`, `Makefile` | `developing-bash` | POSIX/Bash patterns, defensive scripting, portability |
| Files importing `@mui/material` | `mui` | MUI component patterns, sx prop, theme integration |

## Detection Rules

1. Collect all file paths from `gh pr view --json files --jq '.files[].path'`
2. Match each file against the table above using extension and filename patterns
3. For test files, load **both** the language skill and the testing skill
4. For MUI detection, check import statements in changed `.ts`/`.tsx` files after reading them in Step 2
5. Deduplicate — load each skill only once even if multiple files match

## When No Skill Matches

If changed files use a language without a matching skill (e.g., Python, Go, Ruby), proceed with the PERFECT principles using general programming knowledge. Note the unmatched language in the review output so the reviewer is aware no specialized skill was consulted.
