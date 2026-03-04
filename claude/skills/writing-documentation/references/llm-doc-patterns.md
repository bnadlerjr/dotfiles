# LLM-Friendly Documentation Patterns

Patterns that make documentation effective for LLM consumption. LLMs process docs differently than humans: they rely on consistent structure for retrieval, explicit references for context, and self-contained sections for chunking.

## 1. Consistent Structure

Use the same heading hierarchy and section order across all docs of the same type.

**Why**: LLMs learn to extract information by position. Consistent structure means reliable extraction across documents.

**Practice**:
- Define a template for each doc type (module header, ADR, README)
- Use the same heading levels for the same kinds of information
- Keep section order stable — if "Parameters" always comes before "Returns", maintain that everywhere

**Example — Function doc template**:
```
## function_name

Brief description of what it does.

### Parameters
- `param_name` (Type) — Description

### Returns
Type — Description

### Side Effects
Description of mutations, I/O, or state changes

### Errors
- ErrorType — When it occurs
```

## 2. Explicit, Keyword-Rich Headings

Use descriptive headings that contain searchable terms, not generic labels.

| Generic (bad) | Explicit (good) |
|---------------|----------------|
| Overview | What UserAuth Does |
| Details | How Session Tokens Are Validated |
| Notes | Edge Cases in Payment Processing |
| Miscellaneous | Known Limitations of the Cache Layer |

**Why**: LLMs find relevant sections through keyword matching in headings. "Overview" matches everything and nothing.

## 3. Front-Loaded Context (BLUF)

Put the most important information first in each section.

**Structure each section as**:
1. One-sentence summary of the key point
2. Supporting details
3. Examples or edge cases

**Why**: When context windows are limited or content is chunked, the first lines of each section carry the most weight.

**Example**:
```markdown
## Session Expiry

Sessions expire after 30 minutes of inactivity. The timer resets on any
authenticated API call. Expired sessions return HTTP 401 with error code
`session_expired`.

Background: We chose 30 minutes based on PCI-DSS requirements for payment
processing applications...
```

## 4. Self-Contained Sections

Each section should be understandable independently when extracted from the document.

**Rules**:
- Do not rely on "as mentioned above" or "see below" — these break when sections are extracted
- Repeat key context (module name, purpose) briefly at the start of each major section
- Include the full qualified name of any referenced entity, not just a short name

**Anti-pattern**:
```markdown
## Error Handling
As described in the previous section, when the connection fails...
```

**Good pattern**:
```markdown
## DatabasePool Error Handling
When DatabasePool.checkout/1 fails to acquire a connection within the
configured timeout (default: 5000ms), it raises DBConnection.ConnectionError.
```

## 5. Explicit Relationships

State dependencies, related modules, and cross-references by full name.

**Anti-patterns to avoid**:
- "see above" / "as mentioned earlier"
- "the other module" / "the related service"
- "it" / "this" / "that" when the referent is ambiguous

**Good patterns**:
- "Depends on: `MyApp.Auth.TokenValidator`"
- "Called by: `MyApp.Web.AuthPlug`"
- "Related: `MyApp.Accounts.User` (manages the user record that sessions reference)"

## 6. Structured Metadata

Use frontmatter, tags, or structured headers that tools can parse.

**For markdown docs**:
```yaml
---
module: MyApp.Auth.SessionManager
depends_on: [MyApp.Auth.TokenValidator, MyApp.Repo]
last_updated: <date>
tags: [auth, sessions, security]
---
```

**For code-level docs** — use the language's standard structured format:
- Elixir: `@moduledoc`, `@doc`, `@spec`
- TypeScript: JSDoc with `@param`, `@returns`, `@throws`
- Python: Google-style or NumPy-style docstrings with typed parameters

## 7. Grep-Friendly Identifiers

Use fully qualified names and consistent terminology throughout.

**Rules**:
- First reference to any module, function, or concept uses its full qualified name
- Subsequent references in the same section may use the short name
- Use the same term for the same concept everywhere (do not alternate between "user", "account", and "person" for the same entity)
- Use code formatting for identifiers: `ModuleName.function_name/2`

**Why**: LLMs and search tools rely on exact string matching. Consistent naming enables reliable cross-referencing.

## 8. Avoid Ambiguous Pronouns

Use explicit nouns instead of "it", "this", "that" when the referent could be unclear.

**Unclear**:
```
The service validates the token and stores it. If it expires, it retries.
```

**Clear**:
```
TokenValidator validates the JWT and stores the decoded claims in the
session map. If the JWT has expired, TokenValidator requests a refresh
token from the auth provider.
```

**Rule of thumb**: If a section were extracted and shown without surrounding context, would every pronoun have an unambiguous referent? If not, replace the pronoun with the noun.

## Applying These Patterns

When writing documentation for dual-audience consumption:

1. **Start with LLM patterns** — consistent structure, explicit headings, self-contained sections
2. **Add human value** — the "why", examples, mental models (from Ousterhout principles)
3. **Verify grep-friendliness** — search for key terms to confirm they appear consistently
4. **Check chunk boundaries** — read each section in isolation to confirm it stands alone
