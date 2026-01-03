# Typography: The Primary Tool

**Principle:** Type carries content and creates structure. It's the only ornament you need.

Swiss designers chose sans-serif typefaces not because they were trendy, but because they were neutral—the type disappears, the content remains. Typography in Swiss design is not decorative. It's structural.

## Type as Structure

Good typography does three things:

1. **Delivers content** — Readable, scannable, comprehensible
2. **Creates hierarchy** — Size and weight signal importance
3. **Establishes rhythm** — Consistent spacing creates visual flow

It should NOT:

- Draw attention to itself
- Require decoration to "look finished"
- Fight with the content

## The Typography Stack

### One Typeface, Two Weights

The Swiss tradition: one sans-serif typeface, regular and bold weights.

```css
:root {
  --font-family: Inter, -apple-system, sans-serif;
  --font-weight-normal: 400;
  --font-weight-bold: 600;
}
```

Why just one? Typeface variety is decoration. It adds personality, not clarity. For software, personality is noise.

Why just two weights? Regular and bold create sufficient hierarchy. Light weights reduce readability. Extra-bold weights shout.

### A Type Scale

Sizes should follow a ratio. The classic is 1.25× (major third):

```css
:root {
  --text-xs: 0.64rem;   /* 10px */
  --text-sm: 0.8rem;    /* 13px */
  --text-base: 1rem;    /* 16px */
  --text-lg: 1.25rem;   /* 20px */
  --text-xl: 1.563rem;  /* 25px */
  --text-2xl: 1.953rem; /* 31px */
  --text-3xl: 2.441rem; /* 39px */
}
```

Use 4-5 sizes maximum in any interface. More sizes = weaker system.

### Line Height and Measure

**Line height:** 1.4-1.6 for body text. Tighter (1.2) for headings.

**Measure:** 45-75 characters per line. Wider loses tracking. Narrower feels choppy.

```css
.prose {
  max-width: 65ch;
  line-height: 1.5;
}

h1, h2, h3 {
  line-height: 1.2;
  max-width: 25ch; /* Headlines can be shorter */
}
```

## Applying Typography

### In Interfaces

**Limit type treatments:**

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Page title | text-2xl | bold | primary |
| Section head | text-lg | bold | primary |
| Body | text-base | normal | primary |
| Caption | text-sm | normal | secondary |
| Label | text-sm | normal | secondary |

Five treatments. That's enough for most interfaces.

**Don't use type for decoration:**

```html
<!-- Bad: Type as decoration -->
<h1 class="text-5xl font-black uppercase tracking-widest
           bg-gradient-to-r from-purple-500 to-pink-500
           bg-clip-text text-transparent">
  Welcome
</h1>

<!-- Good: Type as structure -->
<h1 class="text-2xl font-bold">Welcome</h1>
```

### In Data Visualization

**Data labels must be readable.** Don't sacrifice legibility for aesthetics.

- Minimum 11px for data labels
- Sans-serif, regular weight
- High contrast against background
- Aligned consistently (see grid.md)

**Use tabular figures for numbers.** Monospace numerals align in columns:

```css
.data-value {
  font-variant-numeric: tabular-nums;
}
```

**Axis labels are secondary.** Smaller, lighter than data labels.

### In Documentation

**Monospace for code.** All of it. Inline and blocks.

```markdown
Run `npm install` to install dependencies.
```

**Body text is the workhorse.** Don't stylize it. 16px minimum, comfortable measure, good line height.

**Headings signal structure, not importance.** An H2 isn't "more important" than body text—it's a different structural tier.

### In CLI Output

**Monospace by default.** CLI is a typographic medium—embrace it.

**Create hierarchy with whitespace and caps, not special characters:**

```
Good:
ERROR: Build failed

  src/app.js:42
  SyntaxError: Unexpected token

  > npm run build

Bad:
╔═══════════════════════════════════╗
║  ⚠️  ERROR: Build failed  ⚠️      ║
╚═══════════════════════════════════╝
```

**Fixed-width columns for tables:**

```
NAME        STATUS      UPTIME
api         running     3d 4h
worker      stopped     -
scheduler   running     1d 12h
```

## Typography Failures

**Too many fonts:** Each typeface is a decision the user must process. One family, maybe two (sans + mono for code).

**Too many sizes:** If you have 12px, 13px, 14px, 15px, and 16px in one view, you have no system.

**Weight as emphasis:** Don't bold entire paragraphs. Bold specific terms. Weight is scarce—spend it wisely.

**Color as typography:** Using color to distinguish text levels (blue for links, gray for captions, red for errors) is fine. Using 8 colors for "visual interest" is decoration.

**Tight line height:** Body text below 1.4 line height strains reading. Don't sacrifice readability for density.

## Choosing Typefaces

For software and interfaces, choose:

- **Sans-serif** (Helvetica, Inter, SF Pro, Roboto)
- **Neutral** (no distinctive personality)
- **Wide character set** (supports internationalization)
- **Readable at small sizes** (clear at 12-14px)

Don't choose:
- Display fonts (designed for headlines)
- Serif fonts (unless you have a specific reason)
- Trendy fonts (personality dates quickly)

The best typeface is one nobody notices.

## Building a Type System

1. **Pick one sans-serif family** — Inter, SF Pro, or system stack
2. **Define your scale** — 4-5 sizes max, based on ratio
3. **Set your weights** — Regular and bold. Maybe medium.
4. **Establish line heights** — 1.2 for headings, 1.5 for body
5. **Set max widths** — 65ch for prose, shorter for headings
6. **Apply consistently** — Don't invent new treatments

Typography is the foundation. If your type system is solid, half your design work is done.
