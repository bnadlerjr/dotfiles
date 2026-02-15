# Phase 3: Categorize Instructions

Group all non-root instructions into 3-8 logical category files.

## Inputs

- Category content map from Phase 2
- Original file contents for context

## Procedure

### 1. Identify Natural Categories

Examine the instructions to find natural groupings. Categories should emerge from the actual content, not be forced into a template.

#### Core Category Reference

Use what fits the project, skip what does not. These are the standard categories with their scope:

| Category | Covers | Use When |
|----------|--------|----------|
| `code-style.md` | Formatting, naming, imports, general style | Language-agnostic style rules exist |
| `testing.md` | Test framework, conventions, patterns, coverage | Testing instructions exist |
| `git-workflow.md` | Branch naming, commit format, PR process, restrictions | Git conventions exist |
| `architecture.md` | Project structure, design patterns, boundaries, data flow | Architecture decisions exist |
| `typescript.md` | TS/JS types, components, hooks, async patterns | Project uses TypeScript |
| `elixir.md` | Modules, functions, OTP, Ecto, pipelines | Project uses Elixir |
| `python.md` | Python style, typing, package conventions | Project uses Python |
| `security.md` | Secrets, input validation, auth, session management | Security instructions exist |
| `api-design.md` | URL structure, HTTP methods, response format, versioning | API guidelines exist |
| `error-handling.md` | Error types, exception strategy, logging, boundaries | Error handling rules exist |
| `performance.md` | Caching, query optimization, bundle size, monitoring | Performance rules exist |
| `documentation.md` | Doc style, comments, READMEs, API docs | Documentation standards exist |

For full templates showing the sub-topic structure within each category, read `references/category-templates.md`.

### 2. Apply Sizing Rules

- **Minimum 3 categories**: Fewer means files are still too large
- **Maximum 8 categories**: More causes fragmentation and cognitive overhead
- **Target size per file**: 30-100 lines of actionable content
- **Merge small categories**: If a category has fewer than 10 lines, merge it into a related one
- **Split large categories**: If a category exceeds 150 lines, consider splitting

### 3. Assign Instructions to Categories

For each instruction in the category content map:
1. Identify the single best category
2. If an instruction spans categories, place it in the most specific one
3. Do NOT duplicate instructions across categories

### 4. Order Within Categories

Within each category file, order instructions by:
1. **Most impactful first** — rules that affect every interaction
2. **Frequency of relevance** — commonly triggered rules before rare ones
3. **Related items together** — group by sub-topic within the category

### 5. Present Category Plan

Show the user the proposed structure:

```
## Proposed Categories

### guidelines/typescript.md (N lines)
- Type inference preferences
- Import organization
- Component patterns
- [etc.]

### guidelines/testing.md (N lines)
- Test framework configuration
- Assertion style
- Mocking approach
- [etc.]

### guidelines/git-workflow.md (N lines)
- Branch naming
- Commit message format
- PR process
- [etc.]

[etc. for each category]

Total: N categories, M total lines across all files
```

## Outputs

- **Final category map**: `{category_filename: [ordered list of instructions with final wording]}`
- **Category count** and line estimates
- **User confirmation** of the structure

## Quality Checks

- No instruction appears in more than one category
- No category is empty
- Every instruction from Phase 2's "category content" list is accounted for
- Category names are lowercase, kebab-case, with `.md` extension

## Transition

When the user confirms the category plan, proceed to Phase 4: Create Structure.
