# Testing React Reference

Expert guidance for Test-Driven Development with React Testing Library in TypeScript applications.

## Quick Start

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

describe('LoginForm', () => {
  it('submits credentials and shows success message', async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();

    render(<LoginForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText(/email/i), 'test@example.com');
    await user.type(screen.getByLabelText(/password/i), 'password123');
    await user.click(screen.getByRole('button', { name: /sign in/i }));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });
  });
});
```

## Core Testing Expertise

- React Testing Library queries and assertions
- User event simulation with @testing-library/user-event
- Async testing patterns with waitFor and findBy
- Test organization and naming conventions
- Mock strategies for external dependencies
- Integration testing component interactions
- Accessibility testing with queries

## TDD Phase Guidance

For general TDD phase definitions, see [SKILL.md](../SKILL.md#tdd-phase-awareness).

**Testing-specific guidance by phase:**

| Phase | Focus | Avoid |
|-------|-------|-------|
| RED | Single user flow, concrete values | Multiple assertions, edge cases |
| GREEN | Make test pass, minimal implementation | Refactoring, test improvements |
| REFACTOR | Test readability, edge cases, helpers | Over-abstracting test utilities |

## Query Priority

Use queries in this order (most to least preferred):

1. **Accessible queries** (reflect user experience)
   - `getByRole` - buttons, headings, form elements
   - `getByLabelText` - form fields
   - `getByPlaceholderText` - inputs without labels
   - `getByText` - non-interactive elements
   - `getByDisplayValue` - filled form elements

2. **Semantic queries**
   - `getByAltText` - images
   - `getByTitle` - title attribute

3. **Test IDs** (last resort)
   - `getByTestId` - when nothing else works

## User Event Patterns

### Setup User Event

```typescript
import userEvent from '@testing-library/user-event';

it('handles user interactions', async () => {
  const user = userEvent.setup();
  render(<MyComponent />);

  // Type in input
  await user.type(screen.getByRole('textbox'), 'Hello');

  // Click button
  await user.click(screen.getByRole('button'));

  // Select from dropdown
  await user.selectOptions(screen.getByRole('combobox'), 'option1');

  // Keyboard navigation
  await user.tab();
  await user.keyboard('{Enter}');
});
```

### Pointer Events

```typescript
await user.hover(element);
await user.unhover(element);
await user.pointer({ target: element, keys: '[MouseRight]' });
```

## Async Testing Patterns

### waitFor

```typescript
// Wait for assertion to pass
await waitFor(() => {
  expect(screen.getByText('Success')).toBeInTheDocument();
});

// With options
await waitFor(
  () => expect(mockFn).toHaveBeenCalled(),
  { timeout: 3000, interval: 100 }
);
```

### findBy Queries

```typescript
// Combines getBy + waitFor
const element = await screen.findByText('Loaded content');
expect(element).toBeInTheDocument();
```

### waitForElementToBeRemoved

```typescript
render(<Modal />);
await user.click(screen.getByRole('button', { name: /close/i }));
await waitForElementToBeRemoved(screen.queryByRole('dialog'));
```

## Test Organization

### Describe Blocks

```typescript
describe('ShoppingCart', () => {
  describe('when empty', () => {
    it('shows empty message', () => { /* ... */ });
    it('disables checkout button', () => { /* ... */ });
  });

  describe('with items', () => {
    it('shows item count', () => { /* ... */ });
    it('calculates total correctly', () => { /* ... */ });
  });
});
```

### Setup and Cleanup

```typescript
describe('UserProfile', () => {
  const mockUser = { id: '1', name: 'Test User' };

  beforeEach(() => {
    vi.mocked(fetchUser).mockResolvedValue(mockUser);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('displays user name', async () => {
    render(<UserProfile userId="1" />);
    expect(await screen.findByText('Test User')).toBeInTheDocument();
  });
});
```

## Mocking Strategies

### Module Mocks

```typescript
// Mock entire module
vi.mock('./api', () => ({
  fetchUser: vi.fn(),
}));

// Mock specific function
vi.mock('./utils', async () => {
  const actual = await vi.importActual('./utils');
  return {
    ...actual,
    formatDate: vi.fn(() => 'Jan 1, 2024'),
  };
});
```

### Component Mocks

```typescript
// Mock child component
vi.mock('./ExpensiveChart', () => ({
  ExpensiveChart: () => <div data-testid="chart-mock" />,
}));
```

### API Mocks with MSW

```typescript
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

const server = setupServer(
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'Test User' });
  })
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

## Testing Hooks

```typescript
import { renderHook, act } from '@testing-library/react';

describe('useCounter', () => {
  it('increments counter', () => {
    const { result } = renderHook(() => useCounter());

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });
});
```

## Testing with Providers

```typescript
function renderWithProviders(
  ui: React.ReactElement,
  { initialState, ...options }: RenderOptions = {}
) {
  function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={queryClient}>
        <ThemeProvider>
          {children}
        </ThemeProvider>
      </QueryClientProvider>
    );
  }

  return render(ui, { wrapper: Wrapper, ...options });
}
```

## Accessibility Testing

```typescript
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

it('has no accessibility violations', async () => {
  const { container } = render(<MyComponent />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

## Anti-Patterns to Prevent

- Testing implementation details (state, hooks internals)
- Using `container.querySelector` instead of proper queries
- Not waiting for async operations
- Over-mocking to the point tests don't catch real bugs
- Testing React internals instead of user outcomes
- Creating elaborate test utilities too early
- Tests that pass with incorrect implementations
- Snapshot testing for logic (use for visual regressions only)

## What This Reference Does NOT Cover

- E2E testing with Playwright/Cypress
- Visual regression testing
- Performance testing
- Backend/API testing

## Goal

Help developers write tests that verify user behavior, catch real bugs, and remain resilient to refactoring by testing what users see and do rather than implementation details.
