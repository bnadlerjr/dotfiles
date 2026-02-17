# React Testing Library Patterns

Core RTL APIs for rendering, querying, waiting, and debugging React components.

## render

Renders a React component into a DOM container and returns utility functions.

```typescript
import { render, screen } from '@testing-library/react';

it('renders a greeting', () => {
  render(<Greeting name="Alice" />);
  expect(screen.getByText('Hello, Alice!')).toBeInTheDocument();
});
```

### render Return Value

```typescript
const { container, unmount, rerender } = render(<MyComponent />);
```

- `container` -- The DOM node wrapping the rendered output. Avoid using directly; prefer `screen` queries.
- `unmount()` -- Unmounts the component. Useful for testing cleanup effects.
- `rerender(<MyComponent newProp="value" />)` -- Re-renders with new props. Tests how the component responds to prop changes without remounting.

### Rendering with Providers

Wrap components that depend on context (router, theme, store):

```typescript
function renderWithProviders(ui: React.ReactElement) {
  return render(
    <QueryClientProvider client={new QueryClient()}>
      <ThemeProvider theme={defaultTheme}>
        <MemoryRouter>
          {ui}
        </MemoryRouter>
      </ThemeProvider>
    </QueryClientProvider>
  );
}

it('renders the dashboard', () => {
  renderWithProviders(<Dashboard />);
  expect(screen.getByRole('heading', { name: 'Dashboard' })).toBeInTheDocument();
});
```

### Custom render with wrapper option

```typescript
import { render, RenderOptions } from '@testing-library/react';

function AllProviders({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={new QueryClient()}>
      <ThemeProvider theme={defaultTheme}>
        {children}
      </ThemeProvider>
    </QueryClientProvider>
  );
}

function customRender(ui: React.ReactElement, options?: Omit<RenderOptions, 'wrapper'>) {
  return render(ui, { wrapper: AllProviders, ...options });
}

// Re-export everything from RTL but override render
export { screen, within, waitFor } from '@testing-library/react';
export { customRender as render };
```

## screen

The primary way to query rendered output. Prefer `screen` over destructuring queries from `render()`.

```typescript
// Preferred: screen queries
render(<UserCard user={alice} />);
expect(screen.getByRole('heading')).toHaveTextContent('Alice');

// Avoid: destructured queries
const { getByRole } = render(<UserCard user={alice} />);
expect(getByRole('heading')).toHaveTextContent('Alice');
```

`screen` is always bound to `document.body`, so it works regardless of render scope.

## Query Types

RTL provides three categories of queries with different behaviors:

| Query Type | No Match | 1 Match | Multiple Matches | Async? |
|------------|----------|---------|-----------------|--------|
| `getBy*` | Throws | Returns | Throws | No |
| `queryBy*` | `null` | Returns | Throws | No |
| `findBy*` | Throws | Returns | Throws | Yes |

Each has an `All` variant (`getAllBy*`, `queryAllBy*`, `findAllBy*`) that returns arrays instead of single elements.

### When to Use Each

- **`getBy*`** -- Default choice. Element should exist right now.
- **`queryBy*`** -- Assert that an element does NOT exist: `expect(screen.queryByText('Error')).not.toBeInTheDocument()`.
- **`findBy*`** -- Element will appear after an async operation (data fetch, animation, timer).

```typescript
// Element exists immediately
expect(screen.getByRole('button', { name: 'Submit' })).toBeInTheDocument();

// Element should NOT exist
expect(screen.queryByRole('alert')).not.toBeInTheDocument();

// Element appears after async operation
expect(await screen.findByText('Data loaded')).toBeInTheDocument();
```

## Query Priority

Queries are listed in order of preference. Use the highest-priority query that works.

### 1. Accessible Roles -- `getByRole`

The single most important query. Tests the component the way assistive technology sees it.

```typescript
screen.getByRole('button', { name: 'Submit Order' });
screen.getByRole('heading', { level: 2 });
screen.getByRole('textbox', { name: 'Email' });
screen.getByRole('checkbox', { name: 'Remember me' });
screen.getByRole('link', { name: 'View details' });
screen.getByRole('dialog', { name: 'Confirm deletion' });
screen.getByRole('navigation');
screen.getByRole('alert');
screen.getByRole('tab', { selected: true });
screen.getByRole('combobox', { name: 'Country' });
```

The `name` option matches the element's accessible name (from `aria-label`, `aria-labelledby`, visible text content, or associated `<label>`).

### 2. Label Text -- `getByLabelText`

For form elements associated with a `<label>`.

```typescript
screen.getByLabelText('Email address');
screen.getByLabelText('Password');
screen.getByLabelText(/phone number/i);
```

### 3. Placeholder Text -- `getByPlaceholderText`

When a label is not present (not ideal, but sometimes necessary).

```typescript
screen.getByPlaceholderText('Search products...');
```

### 4. Text Content -- `getByText`

For non-interactive elements whose text content identifies them.

```typescript
screen.getByText('No results found');
screen.getByText(/total: \$\d+\.\d{2}/i);
```

### 5. Display Value -- `getByDisplayValue`

For form elements by their current value.

```typescript
screen.getByDisplayValue('alice@example.com');
```

### 6. Alt Text -- `getByAltText`

For images and areas.

```typescript
screen.getByAltText('Company logo');
```

### 7. Title -- `getByTitle`

For elements with a `title` attribute. Rarely needed.

```typescript
screen.getByTitle('Close sidebar');
```

### 8. Test ID -- `getByTestId` (Last Resort)

When no accessible query works. Requires adding `data-testid` to the markup.

```typescript
screen.getByTestId('custom-chart-canvas');
```

If you reach for `getByTestId`, first ask: can I add an `aria-label`, a `<label>`, or use `getByRole` instead?

## within -- Scoped Queries

Query within a specific container. Essential for lists, tables, and repeated structures.

```typescript
import { within } from '@testing-library/react';

it('shows product details in the correct row', () => {
  render(<ProductTable products={products} />);

  const widgetRow = screen.getByRole('row', { name: /widget/i });
  expect(within(widgetRow).getByText('$9.99')).toBeInTheDocument();
  expect(within(widgetRow).getByRole('button', { name: 'Remove' })).toBeInTheDocument();
});
```

```typescript
it('renders each todo with a checkbox', () => {
  render(<TodoList todos={['Buy milk', 'Walk dog']} />);

  const items = screen.getAllByRole('listitem');
  expect(items).toHaveLength(2);

  expect(within(items[0]).getByRole('checkbox')).not.toBeChecked();
  expect(within(items[0]).getByText('Buy milk')).toBeInTheDocument();
});
```

## waitFor -- Async Assertions

Retries a callback until it passes or times out (default 1000ms).

```typescript
import { waitFor } from '@testing-library/react';

it('displays validation error after submission', async () => {
  const user = userEvent.setup();
  render(<LoginForm />);

  await user.click(screen.getByRole('button', { name: 'Sign in' }));

  await waitFor(() => {
    expect(screen.getByRole('alert')).toHaveTextContent('Email is required');
  });
});
```

### waitFor Best Practices

Put a single assertion inside `waitFor`. Multiple assertions cause confusing failures.

```typescript
// Good: single assertion per waitFor
await waitFor(() => {
  expect(screen.getByRole('alert')).toHaveTextContent('Saved');
});

// Bad: multiple assertions -- if the second fails, the first keeps re-running
await waitFor(() => {
  expect(screen.getByRole('alert')).toHaveTextContent('Saved');
  expect(screen.getByRole('button')).toBeEnabled();
});
```

If you need multiple assertions after an async operation, use `findBy*` for the first, then `getBy*` for the rest:

```typescript
await screen.findByRole('alert'); // Wait for the async operation to complete
expect(screen.getByRole('alert')).toHaveTextContent('Saved');
expect(screen.getByRole('button')).toBeEnabled();
```

## waitForElementToBeRemoved

Waits for an element to be removed from the DOM.

```typescript
import { waitForElementToBeRemoved } from '@testing-library/react';

it('hides loading spinner after data loads', async () => {
  render(<Dashboard />);

  expect(screen.getByRole('progressbar')).toBeInTheDocument();
  await waitForElementToBeRemoved(() => screen.queryByRole('progressbar'));

  expect(screen.getByRole('heading', { name: 'Dashboard' })).toBeInTheDocument();
});
```

Note: Pass a callback (not a resolved element) if the element might already be gone when `waitForElementToBeRemoved` runs.

## Cleanup

RTL automatically calls `cleanup()` after each test when using Vitest. You should not need to call it manually.

If you see stale DOM between tests, ensure your Vitest config includes `globals: true` or that you are importing from `@testing-library/react` correctly.

## Debugging

### screen.debug()

Prints the current DOM tree to the console.

```typescript
render(<MyComponent />);
screen.debug();                          // Logs entire document.body
screen.debug(screen.getByRole('form'));  // Logs just the form element
```

### screen.logTestingPlaygroundURL()

Generates a Testing Playground URL for interactive query discovery.

```typescript
render(<MyComponent />);
screen.logTestingPlaygroundURL();
// Logs: https://testing-playground.com/gist/...
```

Open the URL in a browser to interactively find the best query for each element.

### prettyDOM

Format a specific DOM node for logging.

```typescript
import { prettyDOM } from '@testing-library/react';

const button = screen.getByRole('button');
console.log(prettyDOM(button));
```

## Common Query Patterns

### Regex for Flexible Matching

```typescript
// Case-insensitive match
screen.getByText(/welcome/i);

// Partial match
screen.getByText(/error/i);

// Exact match (default for string arguments)
screen.getByText('Welcome to the Dashboard');
```

### Custom Function Matcher

```typescript
screen.getByText((content, element) => {
  return element?.tagName === 'SPAN' && content.startsWith('Total:');
});
```

### Querying Hidden Elements

By default, `getByRole` ignores hidden elements. To include them:

```typescript
screen.getByRole('dialog', { hidden: true });
```

## Anti-Patterns

**Using container.querySelector:**
```typescript
// Bad: bypasses accessibility queries
const button = container.querySelector('.submit-btn');
```
Instead, use `screen.getByRole('button', { name: 'Submit' })`.

**Destructuring queries from render:**
```typescript
// Unnecessary: screen is simpler and more consistent
const { getByText, getByRole } = render(<MyComponent />);
```
Instead, use `screen.getByText(...)` and `screen.getByRole(...)`.

**Using getByTestId when accessible queries work:**
```typescript
// Bad: test ID when a role query is available
screen.getByTestId('submit-button');
```
Instead, use `screen.getByRole('button', { name: 'Submit' })`.

**Side effects in waitFor:**
```typescript
// Bad: clicking inside waitFor causes repeated clicks
await waitFor(async () => {
  await user.click(screen.getByRole('button'));
  expect(screen.getByText('Done')).toBeInTheDocument();
});
```
Instead, perform the action outside `waitFor`, then wait for the result:
```typescript
await user.click(screen.getByRole('button'));
await waitFor(() => {
  expect(screen.getByText('Done')).toBeInTheDocument();
});
```
