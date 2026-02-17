# Core Vitest Patterns

Foundational Vitest setup, test structure, spies, mocking utilities, and async patterns.

## Test Structure

```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('calculateTotal', () => {
  it('sums line item prices with quantities', () => {
    const items = [
      { price: 10_00, quantity: 2 },
      { price: 25_00, quantity: 1 },
    ];
    expect(calculateTotal(items)).toBe(45_00);
  });

  it('returns zero for empty cart', () => {
    expect(calculateTotal([])).toBe(0);
  });
});
```

`describe` groups related tests. `it` (aliased as `test`) defines a single test case. Nest `describe` blocks sparingly -- one level of nesting is usually enough.

## Setup and Teardown

### beforeEach / afterEach

Runs before/after each test in the enclosing `describe` block.

```typescript
describe('UserService', () => {
  let service: UserService;

  beforeEach(() => {
    service = new UserService();
  });

  afterEach(() => {
    service.dispose();
  });

  it('creates a user with valid data', () => {
    const user = service.create({ name: 'Alice', email: 'alice@example.com' });
    expect(user.name).toBe('Alice');
  });
});
```

### beforeAll / afterAll

Runs once before/after all tests in the block. Use for expensive, read-only setup.

```typescript
describe('DatabaseReport', () => {
  let fixtures: ReportFixtures;

  beforeAll(async () => {
    fixtures = await loadFixtures('reports');
  });

  afterAll(async () => {
    await cleanupFixtures(fixtures);
  });

  it('generates monthly summary', () => {
    const report = generateReport(fixtures.monthlyData);
    expect(report.totalRevenue).toBe(120_000);
  });
});
```

## Test Variants

### test.each -- Parameterized Tests

```typescript
it.each([
  { input: 'hello', expected: 'HELLO' },
  { input: 'world', expected: 'WORLD' },
  { input: '', expected: '' },
])('toUpperCase("$input") returns "$expected"', ({ input, expected }) => {
  expect(input.toUpperCase()).toBe(expected);
});
```

With array syntax:

```typescript
it.each([
  [0, 'zero'],
  [1, 'one'],
  [2, 'two'],
])('formats %i as "%s"', (num, word) => {
  expect(formatNumber(num)).toBe(word);
});
```

### test.todo -- Placeholder Tests

```typescript
it.todo('handles network timeout gracefully');
it.todo('retries failed requests up to 3 times');
```

### test.skip -- Skip a Test

```typescript
it.skip('flaky test pending investigation', () => {
  // ...
});
```

### test.only -- Focus on a Single Test

```typescript
it.only('the test I am debugging right now', () => {
  // Only this test runs in the file
});
```

Remove `only` before committing. Vitest can be configured to fail on `.only` in CI.

## Expect Matchers

### Equality

```typescript
expect(result).toBe(42);                     // Strict reference equality (===)
expect(result).toEqual({ name: 'Alice' });   // Deep equality
expect(result).toStrictEqual({ name: 'Alice' }); // Deep equality + no extra properties
```

### Truthiness

```typescript
expect(value).toBeTruthy();
expect(value).toBeFalsy();
expect(value).toBeNull();
expect(value).toBeUndefined();
expect(value).toBeDefined();
```

### Numbers

```typescript
expect(total).toBeGreaterThan(0);
expect(total).toBeGreaterThanOrEqual(100);
expect(total).toBeLessThan(1000);
expect(price).toBeCloseTo(10.33, 2);  // Floating point comparison
```

### Strings

```typescript
expect(message).toContain('success');
expect(message).toMatch(/order #\d+/);
```

### Arrays and Iterables

```typescript
expect(items).toContain('apple');
expect(items).toHaveLength(3);
expect(items).toEqual(expect.arrayContaining(['apple', 'banana']));
```

### Objects

```typescript
expect(user).toHaveProperty('name');
expect(user).toHaveProperty('address.city', 'Portland');
expect(user).toEqual(expect.objectContaining({ name: 'Alice' }));
```

### Exceptions

```typescript
expect(() => parseConfig(null)).toThrow();
expect(() => parseConfig(null)).toThrow('config is required');
expect(() => parseConfig(null)).toThrow(ConfigError);
```

### Negation

```typescript
expect(result).not.toBe(0);
expect(items).not.toContain('expired');
```

## vi.fn() -- Spy Functions

Create a standalone spy function. Use for callbacks, event handlers, or function props.

```typescript
import { vi } from 'vitest';

it('calls onSubmit with form data', async () => {
  const handleSubmit = vi.fn();
  render(<ContactForm onSubmit={handleSubmit} />);

  const user = userEvent.setup();
  await user.type(screen.getByLabelText('Name'), 'Alice');
  await user.click(screen.getByRole('button', { name: 'Send' }));

  expect(handleSubmit).toHaveBeenCalledWith(
    expect.objectContaining({ name: 'Alice' })
  );
});
```

### Controlling Return Values

```typescript
const getId = vi.fn();
getId.mockReturnValue('user-123');
getId.mockReturnValueOnce('first-call');
getId.mockImplementation((prefix: string) => `${prefix}-456`);
```

### Spy Assertions

```typescript
expect(handler).toHaveBeenCalled();
expect(handler).toHaveBeenCalledTimes(2);
expect(handler).toHaveBeenCalledWith('arg1', 'arg2');
expect(handler).toHaveBeenLastCalledWith('final-arg');
```

### When to Use vi.fn()

Use `vi.fn()` for **callback props** passed into components -- `onSubmit`, `onChange`, `onClose`. These are genuine boundaries between parent and child. Do NOT use `vi.fn()` to replace internal module functions.

## vi.spyOn() -- Spy on Existing Methods

Wraps an existing method with a spy, preserving the original implementation by default.

```typescript
it('logs errors to console', () => {
  const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

  renderWithError();

  expect(consoleSpy).toHaveBeenCalledWith(
    expect.stringContaining('Failed to load')
  );

  consoleSpy.mockRestore();
});
```

Prefer `vi.spyOn` when you want to observe calls to a real method without replacing its behavior. Use `.mockImplementation()` or `.mockReturnValue()` only when you need to control the return value.

## vi.mock() -- Module Mocking

Replaces an entire module. **Use sparingly -- only at true system boundaries.**

```typescript
// Stub the fetch-based API client at the HTTP boundary
vi.mock('../api/client', () => ({
  fetchProducts: vi.fn().mockResolvedValue([
    { id: '1', name: 'Widget', price: 9_99 },
    { id: '2', name: 'Gadget', price: 19_99 },
  ]),
}));
```

### Auto-mocking

```typescript
// All exports become vi.fn() that return undefined
vi.mock('../api/client');
```

### Restoring Mocks

```typescript
afterEach(() => {
  vi.restoreAllMocks();  // Restores all spies to original implementations
});

// Or in vitest.config.ts:
export default defineConfig({
  test: {
    restoreMocks: true,
  },
});
```

### When vi.mock() Is Appropriate

Only mock modules that cross a true system boundary:

- HTTP clients (`fetch`, `axios`, custom API wrappers)
- Browser APIs that are unavailable or nondeterministic in tests
- Third-party SDK calls (analytics, auth providers)

Never mock your own components, hooks, or utility modules.

## vi.stubGlobal() -- Global Stubs

Replace global values like `fetch`, `window.location`, `navigator`.

```typescript
it('fetches user data on mount', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve({ name: 'Alice' }),
  }));

  render(<UserProfile userId="123" />);

  expect(await screen.findByText('Alice')).toBeInTheDocument();

  vi.unstubAllGlobals();
});
```

## vi.useFakeTimers() -- Timer Control

Control `setTimeout`, `setInterval`, `Date.now`, and related APIs.

```typescript
import { vi, beforeEach, afterEach } from 'vitest';

describe('SessionTimeout', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('shows warning after 25 minutes of inactivity', () => {
    render(<SessionTimeout />);

    vi.advanceTimersByTime(25 * 60 * 1000);

    expect(screen.getByText('Your session will expire soon')).toBeInTheDocument();
  });

  it('resets timer on user activity', async () => {
    render(<SessionTimeout />);
    const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });

    vi.advanceTimersByTime(20 * 60 * 1000);
    await user.click(document.body);
    vi.advanceTimersByTime(20 * 60 * 1000);

    expect(screen.queryByText('Your session will expire soon')).not.toBeInTheDocument();
  });
});
```

**Important**: When combining fake timers with `user-event`, pass `advanceTimers: vi.advanceTimersByTime` to `userEvent.setup()` so user-event's internal delays work correctly.

## Snapshot Testing

### File Snapshots

```typescript
it('renders the product card', () => {
  const { container } = render(
    <ProductCard product={{ name: 'Widget', price: 9_99 }} />
  );
  expect(container.firstChild).toMatchSnapshot();
});
```

### Inline Snapshots

```typescript
it('formats currency correctly', () => {
  expect(formatCurrency(9_99)).toMatchInlineSnapshot(`"$9.99"`);
  expect(formatCurrency(0)).toMatchInlineSnapshot(`"$0.00"`);
});
```

### Snapshot Philosophy

Use snapshots sparingly. They work well for:
- Small, stable output (formatted strings, serialized data)
- Inline snapshots for pure utility functions

Avoid snapshots for:
- Full component trees (too large, break on every change, nobody reads diffs)
- Anything with dynamic data (timestamps, IDs)

Prefer targeted assertions: `expect(screen.getByRole('heading')).toHaveTextContent('Products')` is more meaningful than a snapshot of the entire component.

## Async Testing

### Async/Await

```typescript
it('loads user data', async () => {
  const user = await fetchUser('123');
  expect(user.name).toBe('Alice');
});
```

### Resolved/Rejected Values

```typescript
await expect(fetchUser('123')).resolves.toEqual(
  expect.objectContaining({ name: 'Alice' })
);

await expect(fetchUser('bad-id')).rejects.toThrow('User not found');
```

### Combining with RTL

```typescript
it('displays loaded data', async () => {
  render(<UserProfile userId="123" />);

  // findBy* queries are async -- they wait for the element to appear
  expect(await screen.findByText('Alice')).toBeInTheDocument();

  // Or use waitFor for more complex conditions
  await waitFor(() => {
    expect(screen.getByRole('heading')).toHaveTextContent('Alice');
    expect(screen.getByText('alice@example.com')).toBeInTheDocument();
  });
});
```

## Configuration (vitest.config.ts)

```typescript
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,                    // Optional: makes describe/it/expect global
    setupFiles: ['./src/test/setup.ts'],
    restoreMocks: true,               // Restore spies after each test
    css: false,                       // Skip CSS processing for speed
  },
});
```

### Test Setup File

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom/vitest';
```

This imports all jest-dom matchers and registers them with Vitest's `expect`.

## Anti-Patterns

**Mocking everything in sight:**
```typescript
// Bad: three mocks for one component test
vi.mock('./useCart');
vi.mock('./CartItem');
vi.mock('../utils/format');
```
Instead, render the real component with real hooks and children. Only mock at system boundaries.

**Not cleaning up mocks:**
```typescript
// Bad: mock leaks into other tests
vi.spyOn(console, 'error').mockImplementation(() => {});
// Forgot mockRestore()
```
Instead, use `restoreMocks: true` in config or call `vi.restoreAllMocks()` in `afterEach`.

**Using vi.fn() for everything:**
```typescript
// Bad: vi.fn() replacing a utility function
const format = vi.fn().mockReturnValue('$10.00');
```
Instead, call the real `formatCurrency` function. It is fast, pure, and deterministic.
