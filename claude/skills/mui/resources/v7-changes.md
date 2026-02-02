# MUI v7 Breaking Changes

This document covers breaking changes and new features in MUI v7 (released March 2025).

## Breaking Changes from v6

### 1. Deep Imports Removed

Deep imports no longer work. Use package exports field:

```typescript
// ❌ v7: No longer works
import Button from '@mui/material/Button';

// ✅ v7: Use package-level imports
import { Button } from '@mui/material';
```

### 2. onBackdropClick Removed from Modal

Use `onClose` with reason checking instead:

```typescript
// ❌ v7: Removed
<Dialog onBackdropClick={handleBackdropClick} />

// ✅ v7: Use onClose with reason
<Dialog
  onClose={(event, reason) => {
    if (reason === 'backdropClick') {
      // Handle backdrop click
      return;
    }
    handleClose();
  }}
/>
```

### 3. Standardized slots/slotProps Pattern

All components now use `slots` and `slotProps`. The legacy `components`/`componentsProps` pattern is removed:

```typescript
// ❌ v7: Removed
<Autocomplete
  components={{ Paper: CustomPaper }}
  componentsProps={{ paper: { elevation: 8 } }}
/>

// ✅ v7: Required
<Autocomplete
  slots={{ paper: CustomPaper }}
  slotProps={{ paper: { elevation: 8 } }}
/>
```

### 4. Grid2 is Now Stable

Grid2 is the default Grid component. The `item` prop is removed:

```typescript
// ❌ v7: item prop removed
import { Grid } from '@mui/material';
<Grid container>
  <Grid item xs={6}>Content</Grid>
</Grid>

// ✅ v7: Use Grid2 pattern
import Grid from '@mui/material/Grid2';
<Grid container>
  <Grid xs={6}>Content</Grid>
</Grid>
```

---

## New Features

### CSS Layers Support

MUI v7 supports CSS layers via `enableCssLayer` config. This integrates well with Tailwind v4:

```typescript
import { createTheme, ThemeProvider } from '@mui/material/styles';

const theme = createTheme({
  cssVariables: {
    enableCssLayer: true
  }
});

// In your CSS, MUI styles are now in a layer:
// @layer mui { ... }
```

### Stable CSS Variables

CSS variables are now stable and recommended:

```typescript
const theme = createTheme({
  cssVariables: true
});

// Use in sx prop
<Box sx={{ color: 'var(--mui-palette-primary-main)' }} />

// Use in CSS
.custom-element {
  background-color: var(--mui-palette-background-paper);
  padding: var(--mui-spacing-2);
}
```

---

## Migration Checklist

When upgrading from v5/v6 to v7:

- [ ] Replace deep imports with package-level imports
- [ ] Replace `onBackdropClick` with `onClose` reason checking
- [ ] Replace `components`/`componentsProps` with `slots`/`slotProps`
- [ ] Update Grid usage to Grid2 pattern (remove `item` prop)
- [ ] Test all Modal/Dialog components for backdrop behavior
- [ ] Update any third-level imports (private API)

---

## Quick Reference

| v5/v6 Pattern | v7 Pattern |
|---------------|------------|
| `import Button from '@mui/material/Button'` | `import { Button } from '@mui/material'` |
| `onBackdropClick={fn}` | `onClose={(e, reason) => {...}}` |
| `components={{ X: Y }}` | `slots={{ x: Y }}` |
| `componentsProps={{ x: {...} }}` | `slotProps={{ x: {...} }}` |
| `<Grid item xs={6}>` | `<Grid xs={6}>` (Grid2) |
