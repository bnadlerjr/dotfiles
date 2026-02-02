# Performance Optimization Reference

Expert guidance for optimizing React application performance, bundle size, and Core Web Vitals.

## Quick Start

```typescript
// Lazy loading with Suspense
const Dashboard = lazy(() => import('./Dashboard'));

function App() {
  return (
    <Suspense fallback={<Skeleton />}>
      <Dashboard />
    </Suspense>
  );
}

// Strategic memoization
const ExpensiveList = memo(function ExpensiveList({ items, onSelect }: Props) {
  const sortedItems = useMemo(
    () => items.slice().sort((a, b) => a.name.localeCompare(b.name)),
    [items]
  );

  return (
    <ul>
      {sortedItems.map(item => (
        <ListItem key={item.id} item={item} onSelect={onSelect} />
      ))}
    </ul>
  );
});
```

## Core Competencies

### React Rendering Optimization
- Understand React's reconciliation algorithm
- Use React.memo strategically based on profiling
- Apply useMemo and useCallback appropriately
- Optimize context usage to prevent cascading re-renders

### Bundle Optimization
- Configure code splitting with dynamic imports
- Implement route-based and component-based splitting
- Tree shake unused code effectively
- Analyze and reduce bundle size

### Core Web Vitals
- Optimize Largest Contentful Paint (LCP)
- Minimize Cumulative Layout Shift (CLS)
- Improve Interaction to Next Paint (INP)
- Implement performance monitoring

### Build Tool Configuration
- Configure Vite/webpack for optimal output
- Set up proper chunking strategies
- Enable compression and minification
- Implement caching strategies

## TDD Phase Guidance

For general TDD phase definitions, see [SKILL.md](../SKILL.md#tdd-phase-awareness).

**Performance-specific guidance by phase:**

| Phase | Focus | Avoid |
|-------|-------|-------|
| RED | Correct behavior, no optimization | Premature memoization |
| GREEN | Working code, simple implementation | Performance concerns |
| REFACTOR | Profile, then optimize bottlenecks | Optimizing without measuring |

## Measuring Before Optimizing

### React DevTools Profiler

1. Open React DevTools → Profiler tab
2. Click record, perform the action
3. Analyze the flame graph
4. Look for:
   - Components re-rendering unnecessarily
   - Long render times (>16ms for 60fps)
   - Frequent re-renders of the same component

### Performance API

```typescript
// Measure specific operations
performance.mark('start-operation');
// ... operation
performance.mark('end-operation');
performance.measure('operation', 'start-operation', 'end-operation');

// Get measurements
const measures = performance.getEntriesByName('operation');
console.log(`Operation took ${measures[0].duration}ms`);
```

### Web Vitals Monitoring

```typescript
import { onCLS, onINP, onLCP } from 'web-vitals';

onCLS(console.log);
onINP(console.log);
onLCP(console.log);
```

## React Rendering Optimization

### When to Use React.memo

Use memo when:
- Component renders often with same props
- Component is expensive to render
- Profiler shows unnecessary re-renders

```typescript
// Good use of memo
const ExpensiveChart = memo(function ExpensiveChart({ data }: Props) {
  // Complex visualization rendering
});

// Unnecessary memo (simple component)
const Button = memo(({ onClick, children }) => (
  <button onClick={onClick}>{children}</button>
)); // Probably not worth it
```

### useMemo and useCallback

```typescript
function SearchResults({ query, items }: Props) {
  // useMemo: expensive computation
  const filteredItems = useMemo(
    () => items.filter(item =>
      item.name.toLowerCase().includes(query.toLowerCase())
    ),
    [items, query]
  );

  // useCallback: stable reference for child optimization
  const handleSelect = useCallback((id: string) => {
    setSelected(id);
  }, []);

  return <ItemList items={filteredItems} onSelect={handleSelect} />;
}
```

### Context Optimization

```typescript
// Split frequently-changing and stable values
const UserContext = createContext<User | null>(null);
const UserActionsContext = createContext<UserActions | null>(null);

// Or memoize context value
function Provider({ children }) {
  const [user, setUser] = useState<User | null>(null);

  const value = useMemo(
    () => ({ user, setUser }),
    [user]
  );

  return <UserContext.Provider value={value}>{children}</UserContext.Provider>;
}
```

## Code Splitting Strategies

### Route-Based Splitting

```typescript
import { lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';

const Home = lazy(() => import('./pages/Home'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

function App() {
  return (
    <Suspense fallback={<PageLoader />}>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

### Component-Based Splitting

```typescript
// Split heavy components
const HeavyEditor = lazy(() => import('./HeavyEditor'));

function Document({ isEditing }) {
  return (
    <div>
      <DocumentViewer />
      {isEditing && (
        <Suspense fallback={<EditorSkeleton />}>
          <HeavyEditor />
        </Suspense>
      )}
    </div>
  );
}
```

### Named Exports with Lazy

```typescript
// For named exports, use intermediate module
const Modal = lazy(() =>
  import('./components').then(module => ({ default: module.Modal }))
);
```

## Bundle Analysis

### Vite Bundle Analyzer

```typescript
// vite.config.ts
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    visualizer({
      open: true,
      gzipSize: true,
    }),
  ],
});
```

### Common Bundle Issues

| Issue | Solution |
|-------|----------|
| Large lodash import | Use lodash-es or import specific functions |
| Moment.js | Replace with date-fns or dayjs |
| Full icon library | Import only used icons |
| Unshaken dependencies | Check for ES modules support |

## Image Optimization

```typescript
// Responsive images
<img
  srcSet="image-300.jpg 300w, image-600.jpg 600w, image-900.jpg 900w"
  sizes="(max-width: 600px) 300px, (max-width: 900px) 600px, 900px"
  src="image-600.jpg"
  alt="Description"
  loading="lazy"
  decoding="async"
/>

// Next.js Image component
import Image from 'next/image';
<Image
  src="/photo.jpg"
  width={800}
  height={600}
  alt="Description"
  priority={isAboveFold}
/>
```

## Virtualization for Long Lists

```typescript
import { useVirtualizer } from '@tanstack/react-virtual';

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  });

  return (
    <div ref={parentRef} style={{ height: '400px', overflow: 'auto' }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map(virtualRow => (
          <div
            key={virtualRow.key}
            style={{
              position: 'absolute',
              top: 0,
              transform: `translateY(${virtualRow.start}px)`,
            }}
          >
            {items[virtualRow.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

## Anti-Patterns to Prevent

- Memoizing everything without profiling
- useCallback on functions passed to native elements
- useMemo for simple calculations
- Code splitting tiny components
- Optimizing first, measuring never
- Ignoring network performance (focus only on JS)
- Over-engineering for hypothetical scale

## Performance Checklist

Before optimizing:
- [ ] Profiled with React DevTools
- [ ] Measured actual user impact
- [ ] Identified specific bottleneck
- [ ] Estimated improvement vs. complexity cost

## What This Reference Does NOT Cover

- Server-side rendering optimization
- Database query optimization
- CDN configuration
- Infrastructure scaling

## Goal

Help developers improve application performance through measured, strategic optimizations that have real user impact rather than premature or unnecessary optimization.
