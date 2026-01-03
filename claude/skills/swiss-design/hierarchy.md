# Hierarchy: Controlling Attention

**Principle:** Control attention through contrast in size, weight, and position. If everything is emphasized, nothing is.

Hierarchy tells readers where to look first, second, third. It converts a collection of elements into a sequence. Without hierarchy, users must scan everything to find what matters.

## The Three Levers

Hierarchy is created through **contrast** in:

1. **Size** — Larger elements attract attention first
2. **Weight** — Bolder elements stand out from regular text
3. **Position** — Top-left (in LTR languages) is scanned first; isolation draws focus

Use one lever strongly. Using all three on every element flattens the hierarchy.

## The Squint Test

Blur your vision or step back from the screen. What do you see first? That's your primary element. What do you see second? That's your secondary.

If you see everything at once—or nothing stands out—your hierarchy is broken.

## Applying Hierarchy

### In Interfaces

**Define three levels maximum:**

| Level | Purpose | Treatment |
|-------|---------|-----------|
| Primary | The main action or message | Large, bold, prominent position |
| Secondary | Supporting actions or context | Regular size, normal weight |
| Tertiary | Metadata, auxiliary info | Smaller, lighter, peripheral |

```html
<!-- Clear hierarchy -->
<article>
  <h1 class="text-2xl font-bold">Article Title</h1>        <!-- Primary -->
  <p class="text-base">Article content goes here...</p>    <!-- Secondary -->
  <span class="text-sm text-gray-500">Jan 15, 2025</span>  <!-- Tertiary -->
</article>

<!-- Broken hierarchy: everything competes -->
<article>
  <h1 class="text-xl font-bold text-blue-600">Article Title</h1>
  <p class="text-lg font-medium">Article content goes here...</p>
  <span class="text-base font-semibold text-gray-800">Jan 15, 2025</span>
</article>
```

**Button hierarchy:**

```
Primary:    Filled, high contrast       [  Submit  ]
Secondary:  Outlined, lower contrast    [  Cancel  ]
Tertiary:   Text only, lowest contrast   Learn more
```

One primary action per view. If two things are equally important, neither is important.

### In Data Visualization

**Data is primary.** Everything else (axes, labels, legends) is secondary or tertiary.

```
Good: Data dominates, labels recede
┌─────────────────────────────────────┐
│ ████████████████████████████ 847    │  <- Bold data
│ █████████████████            512    │
│ █████████                    298    │
│                                     │
│ Revenue  ──────────────────────────→│  <- Light axis
└─────────────────────────────────────┘
  Q1     Q2     Q3     Q4               <- Subtle labels

Bad: Labels compete with data
┌─────────────────────────────────────┐
│ REVENUE (USD)                       │
│ ════════════════════════════════════│
│ ████████████████████████████ $847M  │
│ █████████████████            $512M  │
│ █████████                    $298M  │
│ ════════════════════════════════════│
│        Q1     Q2     Q3     Q4      │
└─────────────────────────────────────┘
```

**Highlight selectively.** If one data point matters most, make it visually distinct. If all points matter equally, make them uniform.

### In Documentation

**Heading hierarchy is literal hierarchy.** H1 > H2 > H3 in importance and scope.

```markdown
# API Reference                    <- Page scope

## Authentication                  <- Section scope

### Bearer Tokens                  <- Subsection scope

Use bearer tokens for API access.  <- Content (no heading)
```

**Body text is secondary.** Don't bold entire paragraphs. Bold individual terms that readers might scan for.

```markdown
Bad:
**Authentication is required for all endpoints. Include your API key in the Authorization header.**

Good:
Authentication is required for all endpoints. Include your **API key** in the `Authorization` header.
```

**Code is primary in technical docs.** When showing how to do something, the code example should be the most prominent element.

### In CLI Output

**Hierarchy through caps, symbols, and weight:**

```
ERROR: Connection refused           <- Primary (caps, symbol)
  Could not reach api.example.com   <- Secondary (context)
  Check your network connection     <- Tertiary (suggestion)
```

**Use whitespace as hierarchy:**

```
Build completed

  Compiled 142 files
  Bundle size: 1.2MB
  Time: 3.2s

Warnings: 2
  src/utils.js:42 - Unused variable 'temp'
  src/api.js:18 - Missing return type
```

Groups separated by blank lines. Primary info gets its own line.

## Hierarchy Failures

**Everything is bold:** When emphasis is everywhere, nothing is emphasized. Reserve bold for true primary elements.

**Rainbow highlighting:** Using color to distinguish 8 different things creates visual noise, not hierarchy. Color is one hierarchy lever—use it sparingly.

**Size escalation:** Each new feature gets "a bit bigger" until you have 47px headings and 22px body text. Set sizes once, use them consistently.

**Position chaos:** Important elements scattered across the page instead of anchored in high-attention zones (top, left, center).

## Establishing Hierarchy

1. **Rank your elements** — What's most important? What's second?
2. **Assign levels** — Primary, secondary, tertiary. No more.
3. **Choose one lever** — Size OR weight OR position. Not all three.
4. **Create contrast** — The gap between levels should be obvious, not subtle.
5. **Squint test** — Can you see the hierarchy at a glance?

Hierarchy is about sacrifice. To make something important, you must make other things less important. If you can't decide what's primary, you don't understand the content.
