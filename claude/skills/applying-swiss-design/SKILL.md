---
name: applying-swiss-design
description: Applies Swiss/International Typographic Style principles to create clear, functional output. Use when designing interfaces, data visualizations, documentation, CLI output, or any output where clarity matters. Recognizes requests like "make it cleaner", "reduce clutter", "too busy", "improve readability", "visual hierarchy", "simplify the layout".
---

# Applying Swiss Design

**Core principle:** Clarity through reduction. Every element must earn its place. Remove until removing more would harm understanding.

## Quick Start

Before finalizing any output, run the **Swiss Test**:

1. **Reduction:** Can I remove anything without losing meaning?
2. **Grid:** Does alignment create rhythm and relationships?
3. **Hierarchy:** Is there a clear reading order through size/weight/position?
4. **Typography:** Is type doing the structural work (not color or decoration)?

If any answer is "no," revise before shipping.

## Instructions

Apply these four principles in order:

### Step 1: Reduce
Strip to essentials. For each element, ask: "If I remove this, what do users lose?"
- If "nothing" or "beauty" → remove it
- If "they won't understand X" → keep it

See [reduction.md](reduction.md) for detailed guidance.

### Step 2: Establish Grid
Create mathematical structure using a base unit (8px recommended).
- Derive all spacing from multiples of base unit
- Minimize alignment points (fewer = stronger grid)
- Apply consistently—no "just this once" exceptions

See [grid.md](grid.md) for detailed guidance.

### Step 3: Create Hierarchy
Control attention through contrast. Define exactly three levels:
- **Primary:** Main action or message (large, bold, prominent)
- **Secondary:** Supporting content (regular size, normal weight)
- **Tertiary:** Metadata, auxiliary info (smaller, lighter)

Use ONE lever strongly: size OR weight OR position. Not all three.

See [hierarchy.md](hierarchy.md) for detailed guidance.

### Step 4: Apply Typography
Type carries content and creates structure. It's the only ornament needed.
- One typeface family, two weights (regular + bold)
- 4-5 sizes maximum, following a ratio (1.25× recommended)
- Line height: 1.4-1.6 for body, 1.2 for headings

See [typography.md](typography.md) for detailed guidance.

## Examples

**Example 1: Interface Component**

Input: Card with decorative elements
```html
<div class="card shadow-lg rounded-xl border border-gray-200 p-6">
  <div class="flex items-center gap-2 mb-4">
    <UserIcon class="w-5 h-5 text-blue-500" />
    <h3 class="text-lg font-semibold text-gray-800">User Profile</h3>
  </div>
  <div class="divider border-t border-gray-100 my-4"></div>
  <p class="text-gray-600 text-sm">View and edit your profile below.</p>
</div>
```

Output: Reduced to essentials
```html
<section>
  <h3>User Profile</h3>
  <!-- actual content -->
</section>
```

**Example 2: CLI Output**

Input: Decorated terminal output
```
╔═══════════════════════════════════╗
║  ⚠️  ERROR: Build failed  ⚠️      ║
╚═══════════════════════════════════╝
```

Output: Typography as structure
```
ERROR: Build failed

  src/app.js:42
  SyntaxError: Unexpected token

  > npm run build
```

**Example 3: Documentation**

Input: Verbose intro
```markdown
## Overview

This section provides a comprehensive overview of the authentication
system. Authentication is a critical component of any web application,
and our implementation follows industry best practices.

## Getting Started

To get started with authentication, you'll need to configure...
```

Output: Direct to value
```markdown
## Authentication

Configure in `config/auth.rb`:
```

## Common Failures

**Decoration creep:** Adding elements "to look better" rather than aid comprehension. Each gradient, shadow, icon must justify its presence.

**Hierarchy collapse:** When everything is bold, nothing is. When there are twelve font sizes, there's no system.

**Grid abandonment:** "Just this once" exceptions accumulate into visual chaos.

**Color as crutch:** Using color to create hierarchy that should exist in type. If it doesn't work in grayscale, the structure is weak.

## Philosophy

Swiss design is not a style—it's a discipline. The goal isn't to "look Swiss." The goal is to remove everything that doesn't serve comprehension.

Müller-Brockmann: "The grid system is an aid, not a guarantee. It permits a number of possible uses and each designer can look for a solution appropriate to his personal style. But one must learn how to use the grid; it is an art that requires practice."

## Success Criteria

Application of Swiss design principles is complete when:

- [ ] Every element serves comprehension (reduction applied)
- [ ] All spacing derives from a consistent base unit (grid applied)
- [ ] Clear primary → secondary → tertiary reading order exists (hierarchy applied)
- [ ] Type creates structure without decorative elements (typography applied)
- [ ] The Swiss Test passes on all four questions
- [ ] Output works in grayscale (color is not a crutch)
