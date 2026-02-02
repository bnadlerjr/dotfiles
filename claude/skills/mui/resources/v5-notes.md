# MUI v5-Specific Notes

This document covers patterns and considerations specific to MUI v5.x projects.

## Key v5 Characteristics

- **Grid2 is unstable** - Use the standard Grid component with `item` prop
- **Both customization patterns work** - `components`/`componentsProps` and `slots`/`slotProps`
- **CSS variables are experimental** - Use with caution or upgrade for stable support
- **Deep imports supported** - Second-level imports work (e.g., `@mui/material/Button`)

---

## Grid Component

MUI v5 uses the original Grid component. **Do not use Grid2** - it's unstable in v5.

```typescript
import { Grid } from '@mui/material';

// Always use container + item pattern
<Grid container spacing={2}>
  <Grid item xs={12} md={6}>
    Left half
  </Grid>
  <Grid item xs={12} md={6}>
    Right half
  </Grid>
</Grid>

// With alignment
<Grid container spacing={2} alignItems="center" justifyContent="center">
  <Grid item xs={6}>
    Centered content
  </Grid>
</Grid>

// Nested grids
<Grid container spacing={2}>
  <Grid item xs={12} md={8}>
    <Grid container spacing={1}>
      <Grid item xs={6}>Nested 1</Grid>
      <Grid item xs={6}>Nested 2</Grid>
    </Grid>
  </Grid>
  <Grid item xs={12} md={4}>
    Sidebar
  </Grid>
</Grid>
```

---

## Component Customization

Both patterns work in v5. Prefer `slots`/`slotProps` for easier migration:

```typescript
// Legacy pattern (still works in v5)
<Autocomplete
  components={{
    Paper: CustomPaper,
  }}
  componentsProps={{
    paper: { elevation: 8 },
  }}
/>

// Preferred pattern (easier migration to v6+)
<Autocomplete
  slots={{
    paper: CustomPaper,
  }}
  slotProps={{
    paper: { elevation: 8 },
  }}
/>
```

---

## CSS Variables (Experimental)

CSS variables support in MUI v5 is **experimental**. For stable support, upgrade to v6+.

```typescript
// Experimental CSS variables in v5
import { createTheme, ThemeProvider } from '@mui/material/styles';

const theme = createTheme({
  cssVariables: true  // Enable experimental CSS variables
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      {/* CSS variables like --mui-palette-primary-main are available */}
      <Box sx={{ color: 'var(--mui-palette-primary-main)' }} />
    </ThemeProvider>
  );
}
```

If you need stable CSS variables:
1. Use the experimental feature with caution
2. Upgrade to MUI v6+ for stable support
3. Define your own CSS custom properties separately

---

## Import Patterns

```typescript
// ✅ Good: First-level imports (tree-shakeable)
import { Button, Box, Typography } from '@mui/material';

// ✅ Good in v5: Second-level imports (smaller initial bundle)
import Button from '@mui/material/Button';
import Box from '@mui/material/Box';

// ❌ Avoid: Third-level imports (private API)
import createTheme from '@mui/material/styles/createTheme';
```

---

## Styling Engine

MUI v5 uses Emotion by default. You can optionally use styled-components:

```bash
# Default: Emotion (no extra setup needed)
npm install @mui/material @emotion/react @emotion/styled

# Optional: styled-components
npm install @mui/material @mui/styled-engine-sc styled-components
```

If using styled-components, add to package.json:

```json
{
  "dependencies": {
    "@mui/styled-engine": "npm:@mui/styled-engine-sc@latest"
  }
}
```

---

## Theme Type Extensions

When extending the theme in v5, also extend component prop overrides:

```typescript
declare module '@mui/material/styles' {
  interface Palette {
    tertiary: Palette['primary'];
  }
  interface PaletteOptions {
    tertiary?: PaletteOptions['primary'];
  }
}

// Also extend Button color options if needed
declare module '@mui/material/Button' {
  interface ButtonPropsColorOverrides {
    tertiary: true;
  }
}
```

---

## Migration Considerations

When planning to upgrade to v6+, note these changes:

| Feature | MUI v5 | MUI v6+ |
|---------|--------|---------|
| CSS Variables | Experimental | Stable |
| Grid | Grid with `item` prop | Grid2 stable, `item` prop removed |
| Component slots | Both patterns | Only `slots`/`slotProps` |
| Deep imports | Supported | Removed |

See [v7-changes.md](v7-changes.md) for v7 breaking changes.
