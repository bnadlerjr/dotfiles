# Code-Level Documentation Workflow

Write module headers, function/method docs, and inline comments that serve both human developers and LLMs.

## Inputs

One or more of:
- File path(s) to document
- Module or function name(s)
- Natural language description of what needs documenting

## Output Placement

Code-level docs are co-located with source code:
- Module headers go at the top of the file (or in the language's module doc convention)
- Function/method docs go directly above the function signature
- Inline comments go next to the relevant code

**Do not create separate markdown files for code-level documentation.**

## Procedure

### Step 1: Examine the Code

Read the target file(s). For each module/function, answer:

1. What does this do? (interface — the WHAT)
2. Why does this exist? (motivation — not obvious from code)
3. What are the non-obvious behaviors? (edge cases, side effects, invariants)
4. What are the parameters, return values, and error conditions?
5. How does this interact with other modules? (cross-module relationships)

### Step 2: Determine Doc Scope

Not everything needs the same level of documentation. Use this decision matrix:

| Code Element | Always Document | Document If Non-Obvious |
|-------------|----------------|------------------------|
| Public module | Module header with purpose and key behaviors | Internal design rationale |
| Public function | Params, returns, errors, side effects | Algorithm choice, performance notes |
| Private function | Skip unless complex | Why it exists, edge cases |
| Constants | What the value represents | Why this specific value |
| Type definitions | What the type models | Constraints not expressed in the type |

### Step 3: Write Module Headers

Follow the language's convention. Include:

1. **One-line summary** — What this module is responsible for
2. **Key behaviors** — The 2-5 most important things callers should know
3. **Dependencies** — Other modules this one requires (use fully qualified names)
4. **Usage example** — A minimal example showing typical usage

**Template (adapt to language conventions)**:
```
Module: MyApp.Auth.SessionManager

Manages user sessions with configurable expiry and token refresh.

Key behaviors:
- Creates sessions from verified credentials (create_session/2)
- Validates and refreshes active sessions (validate/1)
- Expires sessions after configured idle timeout (default: 30min)

Depends on: MyApp.Auth.TokenValidator, MyApp.Repo
Used by: MyApp.Web.AuthPlug, MyApp.Web.SessionController
```

### Step 4: Write Function/Method Docs

For each public function:

1. **One-line description** — What it does (interface, not implementation)
2. **Parameters** — Name, type, description. Include units, ranges, nil semantics.
3. **Returns** — Type and description. Include possible shapes (ok/error tuples, etc.)
4. **Side effects** — State mutations, I/O, external calls
5. **Errors/Exceptions** — What can go wrong and how it surfaces
6. **Examples** — One typical usage, one edge case if relevant

Apply Ousterhout's interface vs. implementation rule: describe WHAT, not HOW.

| Leaky (avoid) | Clean (use) |
|---------------|------------|
| "Iterates the list and filters by predicate" | "Returns items matching the predicate" |
| "Uses bcrypt with 12 rounds" | "Hashes the password using a one-way hash" |
| "Queries the users table" | "Looks up a user by email, returns nil if not found" |

### Step 5: Write Inline Comments

Inline comments explain WHY, not WHAT. Add them for:

- **Design decisions**: Why this approach over the obvious alternative
- **Workarounds**: What bug or limitation this works around (include ticket/issue reference)
- **Non-obvious behavior**: Behavior a reader would not expect from scanning the code
- **Performance trade-offs**: Why the less readable option was chosen
- **Invariants**: Conditions that must hold but are not enforced by the type system

**Do not add inline comments that restate the code**:
```
# Bad: restates the code
count = count + 1  # increment count

# Good: explains the why
count = count + 1  # compensate for zero-indexed API response
```

### Step 6: Apply LLM Patterns

After writing the docs, check against LLM-friendly patterns from `references/llm-doc-patterns.md`:

- [ ] First reference to any entity uses its fully qualified name
- [ ] No ambiguous pronouns ("it", "this") across section boundaries
- [ ] Function doc sections follow a consistent order (description, params, returns, errors)
- [ ] Type specs use the language's standard format (Elixir `@spec`, TypeScript JSDoc, Python type hints)

### Step 7: Apply Ousterhout Checklist

Final validation against `references/ousterhout-principles.md`:

- [ ] Does this reduce cognitive load for the reader?
- [ ] Interface docs describe WHAT, not HOW?
- [ ] Non-obvious things are documented; obvious things are not?
- [ ] Cross-module interactions are mentioned?
- [ ] Low-level comments add precision (units, boundaries, nil meaning)?
- [ ] High-level comments provide intuition and reasoning?

## Language-Specific Conventions

Adapt the output format to the language:

### Elixir
- Use `@moduledoc` for module headers
- Use `@doc` for function docs
- Use `@spec` for type specifications
- Use `@typedoc` for type documentation

### TypeScript
- Use JSDoc `/** */` comments for functions and classes
- Use `@param`, `@returns`, `@throws`, `@example` tags
- Types are often self-documenting — document the semantics, not the shape

### Python
- Use module-level docstrings for module headers
- Use Google-style or NumPy-style docstrings for functions
- Include type hints in the signature, explain semantics in the docstring

### Bash
- Use a header comment block for the script purpose
- Document each function with a comment block above it
- Explain non-obvious flags and pipelines inline

## Post-Processing

Code-level docs do NOT go through `writing-for-humans` post-processing. They have different constraints (precision over scannability, co-located with code, language-specific formatting).

## Quality Check

A well-documented code file passes these tests:

1. A developer can use any public function without reading its implementation
2. A maintainer can understand WHY the code is structured this way
3. An LLM can accurately summarize the module's purpose and API from the docs alone
4. Searching for the module's fully qualified name finds its documentation
