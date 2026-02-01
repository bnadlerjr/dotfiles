# Core Principles

Core principles guide skill authoring decisions. These principles ensure skills are efficient, effective, and maintainable across different models and use cases.

## Standard Markdown Format

Skills use YAML frontmatter plus standard markdown for the body. This follows Anthropic's official specification.

### Why Markdown

**Familiarity:** Developers already know markdown. No learning curve.

**Tooling:** Markdown renders in GitHub, editors, documentation systems. XML requires special handling.

**Anthropic's standard:** The official skill specification uses markdown headings, not XML tags.

### Structure

```markdown
---
name: skill-name
description: What it does. Use when trigger conditions.
---

# Skill Name

## Quick Start
Immediate actionable guidance...

## Instructions
Step-by-step procedures...

## Examples
Concrete input/output pairs...
```

### Critical Rule

Use standard markdown headings (`#`, `##`, `###`) for section structure. Keep markdown formatting within content (bold, italic, lists, code blocks, links).

### Recommended Sections

Every skill should have:
- **Quick Start** - Immediate, actionable guidance
- **Instructions** or **Workflow** - Core procedures
- **Examples** - Concrete input/output pairs showing expected behavior

## Conciseness Principle

The context window is shared. Your skill shares it with the system prompt, conversation history, other skills' metadata, and the actual request.

### Guidance

Only add context Claude doesn't already have. Challenge each piece of information:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

Assume Claude is smart. Don't explain obvious concepts.

### Example

**Concise** (~50 tokens):
```markdown
## Quick Start

Extract PDF text with pdfplumber:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
```

**Verbose** (~150 tokens):
```markdown
## Quick Start

PDF files are a common file format used for documents. To extract text from them, we'll use a Python library called pdfplumber. First, you'll need to import the library, then open the PDF file using the open method, and finally extract the text from each page. Here's how to do it:

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

This code opens the PDF and extracts text from the first page.
```

The concise version assumes Claude knows what PDFs are, understands Python imports, and can read code. All those assumptions are correct.

### When to Elaborate

Add explanation when:
- Concept is domain-specific (not general programming knowledge)
- Pattern is non-obvious or counterintuitive
- Context affects behavior in subtle ways
- Trade-offs require judgment

Don't add explanation for:
- Common programming concepts (loops, functions, imports)
- Standard library usage (reading files, making HTTP requests)
- Well-known tools (git, npm, pip)
- Obvious next steps

## Degrees of Freedom Principle

Match the level of specificity to the task's fragility and variability. Give Claude more freedom for creative tasks, less freedom for fragile operations.

### High Freedom

**When:**
- Multiple approaches are valid
- Decisions depend on context
- Heuristics guide the approach
- Creative solutions welcome

**Example:**
```markdown
## Instructions

Review code for quality, bugs, and maintainability.

1. Analyze the code structure and organization
2. Check for potential bugs or edge cases
3. Suggest improvements for readability and maintainability
4. Verify adherence to project conventions

## Success Criteria

- All major issues identified
- Suggestions are actionable and specific
- Review balances praise and criticism
```

Claude has freedom to adapt the review based on what the code needs.

### Medium Freedom

**When:**
- A preferred pattern exists
- Some variation is acceptable
- Configuration affects behavior
- Template can be adapted

### Low Freedom

**When:**
- Operations are fragile and error-prone
- Consistency is critical
- A specific sequence must be followed
- Deviation causes failures

**Example:**
```markdown
## Workflow

Run exactly this command:

```bash
python scripts/migrate.py --verify --backup
```

**Do not modify the command or add additional flags.**
```

Claude must follow the exact command with no variation.

### Matching Specificity

The key is matching specificity to fragility:

- **Fragile operations** (database migrations, payment processing, security): Low freedom, exact instructions
- **Standard operations** (API calls, file processing, data transformation): Medium freedom, preferred pattern with flexibility
- **Creative operations** (code review, content generation, analysis): High freedom, heuristics and principles

Mismatched specificity causes problems:
- Too much freedom on fragile tasks → errors and failures
- Too little freedom on creative tasks → rigid, suboptimal outputs

## Model Testing Principle

Skills act as additions to models, so effectiveness depends on the underlying model. What works for Opus might need more detail for Haiku.

### Testing Across Models

Test your skill with all models you plan to use:

**Claude Haiku** (fast, economical)
- Does the skill provide enough guidance?
- Are examples clear and complete?
- Do implicit assumptions become explicit?
- Haiku benefits from more explicit instructions, complete examples, step-by-step workflows

**Claude Sonnet** (balanced)
- Is the skill clear and efficient?
- Does it avoid over-explanation?
- Sonnet benefits from balanced detail, progressive disclosure

**Claude Opus** (powerful reasoning)
- Does the skill avoid over-explaining?
- Can Opus infer obvious steps?
- Opus benefits from concise instructions, principles over procedures, high degrees of freedom

### Balancing Across Models

Aim for instructions that work well across all target models:

**Good balance:**
```markdown
## Quick Start

Use pdfplumber for text extraction:

```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

For scanned PDFs requiring OCR, use pdf2image with pytesseract instead.
```

This works for all models:
- Haiku gets complete working example
- Sonnet gets clear default with escape hatch
- Opus gets enough context without over-explanation

### Iterative Improvement

1. Start with medium detail level
2. Test with target models
3. Observe where models struggle or succeed
4. Adjust based on actual performance
5. Re-test and iterate

Don't optimize for one model. Find the balance that works across your target models.

## Progressive Disclosure Principle

SKILL.md serves as an overview. Reference files contain details. Claude loads reference files only when needed.

### Token Efficiency

Progressive disclosure keeps token usage proportional to task complexity:

- Simple task: Load SKILL.md only (~500 tokens)
- Medium task: Load SKILL.md + one reference (~1000 tokens)
- Complex task: Load SKILL.md + multiple references (~2000 tokens)

Without progressive disclosure, every task loads all content regardless of need.

### Implementation

- Keep SKILL.md under 500 lines
- Split detailed content into reference files
- Keep references one level deep from SKILL.md
- Link to references from relevant sections
- Use descriptive reference file names

See [skill-structure.md](skill-structure.md) for progressive disclosure patterns.

## Validation Principle

Validation scripts are force multipliers. They catch errors that Claude might miss and provide actionable feedback.

### Characteristics

Good validation scripts:
- Provide verbose, specific error messages
- Show available valid options when something is invalid
- Pinpoint exact location of problems
- Suggest actionable fixes
- Are deterministic and reliable

See [workflows-and-validation.md](workflows-and-validation.md) for validation patterns.

## Summary

| Principle | Key Point |
|-----------|-----------|
| Standard Markdown | Use YAML frontmatter + markdown headings per Anthropic spec |
| Conciseness | Only add context Claude doesn't have |
| Degrees of Freedom | Match specificity to fragility |
| Model Testing | Test with Haiku, Sonnet, and Opus |
| Progressive Disclosure | Keep SKILL.md concise, split details into references |
| Validation | Make scripts verbose and specific |
