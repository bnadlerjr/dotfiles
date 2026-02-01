# Grid: Mathematical Structure

**Principle:** Grids create visual order that reduces cognitive load. Alignment implies relationship. Rhythm creates predictability.

A grid is not a container—it's a set of relationships. Elements that share alignment are perceived as related. Consistent spacing creates rhythm that the eye follows without effort.

## Grid Fundamentals

### The Base Unit

Choose a base unit. Derive all spacing from multiples of it.

```
Base unit: 8px

Spacing scale:
- xs: 4px   (0.5×)
- sm: 8px   (1×)
- md: 16px  (2×)
- lg: 24px  (3×)
- xl: 32px  (4×)
- 2xl: 48px (6×)
```

Why 8? It divides evenly at common viewport sizes, works well with line heights, and is large enough to create visible rhythm.

### Alignment Points

Fewer alignment points = stronger grid.

**Weak grid:** Elements start at 12px, 16px, 24px, 32px, 40px (5 alignment points)

**Strong grid:** Elements start at 16px or 48px only (2 alignment points)

Every unique alignment point adds cognitive load. Each "exception" weakens the system.

## Applying Grids

### In Interfaces

**Column grids** for page layout:
```css
.layout {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 24px; /* 3× base unit */
}
```

**Baseline grids** for vertical rhythm:
```css
:root {
  --baseline: 8px;
}

p {
  line-height: 24px; /* 3× baseline */
  margin-bottom: 24px;
}

h2 {
  line-height: 32px; /* 4× baseline */
  margin-bottom: 16px;
}
```

**Component grids** for internal structure:
```css
.card {
  padding: 24px;
  gap: 16px;
}

.card-header {
  padding-bottom: 16px;
  border-bottom: 1px solid var(--border);
}
```

The card's internal spacing uses the same base unit as the page.

### In Data Visualization

**Axis alignment:** Data points should align to grid lines where possible. Jagged alignment makes comparison harder.

**Chart sizing:** Chart dimensions should be multiples of your base unit. A 400×300 chart fits a 100px grid cleanly.

**Label positioning:** Labels align to consistent positions. Don't float labels based on data position—anchor them.

```
Good: Labels at fixed y-positions
┌─────────────────────────┐
│ Revenue    ████████ 50k │
│ Costs      █████    30k │
│ Profit     ███      20k │
└─────────────────────────┘

Bad: Labels following bar ends
┌─────────────────────────┐
│ Revenue    ████████ 50k │
│ Costs      █████ 30k    │
│ Profit     ███ 20k      │
└─────────────────────────┘
```

### In Documentation

**Margin consistency:** All content blocks share the same left margin. Code blocks, quotes, lists—same starting point.

**Heading levels as grid:** Each heading level represents a structural tier. Don't skip levels. Don't use headings for styling.

```markdown
# Page Title (H1)

## Major Section (H2)

### Subsection (H3)

Content always at the same depth.
```

**Table alignment:** Columns align by data type. Numbers right-align. Text left-aligns. Headers match their column.

### In CLI Output

**Column alignment:** Related data shares columns.

```
Good:
NAME        STATUS    REPLICAS
api         Running   3/3
web         Running   2/2
worker      Failed    0/1

Bad:
api is Running with 3/3 replicas
web is Running with 2/2 replicas
worker is Failed with 0/1 replicas
```

**Indentation as structure:** Nested information indents by consistent amounts (2 or 4 spaces, not mixed).

```
Project: my-app
  Dependencies:
    react: 18.2.0
    next: 14.0.0
  Scripts:
    dev: next dev
    build: next build
```

## Grid Violations

Sometimes breaking the grid is correct. But treat violations as exceptional:

**Allowed violations:**
- Full-bleed images or backgrounds (intentional break)
- Pull quotes or callouts (offset for emphasis)
- Optical adjustments (icons that appear misaligned at mathematical center)

**Red flag violations:**
- "Just this once" positioning
- Pixel nudges to "make it look right"
- Different spacing in similar components

If you're nudging pixels, either your grid is wrong or your content doesn't fit your grid. Fix the system, don't patch around it.

## Building a Grid

1. **Choose your base unit** (8px is safe)
2. **Define your spacing scale** (multiples of base)
3. **Set your column grid** (12-column is flexible)
4. **Apply consistently** (no exceptions for 2 weeks)
5. **Evaluate and adjust** (the grid serves the content)

The grid is an aid, not a prison. But you must master the grid before you earn the right to break it.
