# Testing Custom Hooks

How to test React custom hooks using `renderHook` from `@testing-library/react`.

## When to Use renderHook

Use `renderHook` when you need to test a hook in isolation -- typically for reusable hooks that are shared across components. For hooks that exist only inside a single component, test them through the component instead.

```typescript
// Shared, reusable hook -> test with renderHook
function useDebounce<T>(value: T, delay: number): T { /* ... */ }

// Single-component hook -> test through the component
function useCheckoutFormState() { /* ... */ }
```

## Basic renderHook

```typescript
import { renderHook, act } from '@testing-library/react';

it('initializes with the provided value', () => {
  const { result } = renderHook(() => useCounter(10));
  expect(result.current.count).toBe(10);
});
```

`result.current` always contains the latest return value of the hook. It updates after state changes.

## Testing State Changes

Use `act()` to wrap calls that trigger state updates.

```typescript
import { renderHook, act } from '@testing-library/react';

function useCounter(initial = 0) {
  const [count, setCount] = useState(initial);
  const increment = () => setCount((c) => c + 1);
  const decrement = () => setCount((c) => c - 1);
  const reset = () => setCount(initial);
  return { count, increment, decrement, reset };
}

describe('useCounter', () => {
  it('increments the count', () => {
    const { result } = renderHook(() => useCounter(0));

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });

  it('decrements the count', () => {
    const { result } = renderHook(() => useCounter(5));

    act(() => {
      result.current.decrement();
    });

    expect(result.current.count).toBe(4);
  });

  it('resets to initial value', () => {
    const { result } = renderHook(() => useCounter(10));

    act(() => {
      result.current.increment();
      result.current.increment();
      result.current.reset();
    });

    expect(result.current.count).toBe(10);
  });
});
```

## Testing Effects

Hooks with `useEffect` run their effects during `renderHook`. Async effects need `waitFor`.

```typescript
function useDocumentTitle(title: string) {
  useEffect(() => {
    document.title = title;
  }, [title]);
}

it('sets the document title', () => {
  renderHook(() => useDocumentTitle('Products'));
  expect(document.title).toBe('Products');
});

it('updates the document title on change', () => {
  const { rerender } = renderHook(
    ({ title }) => useDocumentTitle(title),
    { initialProps: { title: 'Products' } }
  );

  expect(document.title).toBe('Products');

  rerender({ title: 'Cart' });
  expect(document.title).toBe('Cart');
});
```

## Testing Async Hooks

For hooks that perform async operations (data fetching, debouncing).

```typescript
function useAsync<T>(asyncFn: () => Promise<T>) {
  const [state, setState] = useState<{
    data: T | null;
    error: Error | null;
    loading: boolean;
  }>({ data: null, error: null, loading: true });

  useEffect(() => {
    let cancelled = false;
    asyncFn()
      .then((data) => {
        if (!cancelled) setState({ data, error: null, loading: false });
      })
      .catch((error) => {
        if (!cancelled) setState({ data: null, error, loading: false });
      });
    return () => { cancelled = true; };
  }, [asyncFn]);

  return state;
}

describe('useAsync', () => {
  it('starts in loading state', () => {
    const asyncFn = () => new Promise<string>(() => {}); // Never resolves
    const { result } = renderHook(() => useAsync(asyncFn));

    expect(result.current.loading).toBe(true);
    expect(result.current.data).toBeNull();
  });

  it('resolves with data', async () => {
    const asyncFn = () => Promise.resolve('hello');
    const { result } = renderHook(() => useAsync(asyncFn));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.data).toBe('hello');
    expect(result.current.error).toBeNull();
  });

  it('handles errors', async () => {
    const asyncFn = () => Promise.reject(new Error('Network error'));
    const { result } = renderHook(() => useAsync(asyncFn));

    await waitFor(() => {
      expect(result.current.loading).toBe(false);
    });

    expect(result.current.error?.message).toBe('Network error');
    expect(result.current.data).toBeNull();
  });
});
```

## Rerendering with New Props

Use `rerender` to simulate prop changes.

```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

describe('useDebounce', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('returns initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('hello', 300));
    expect(result.current).toBe('hello');
  });

  it('debounces value changes', () => {
    const { result, rerender } = renderHook(
      ({ value, delay }) => useDebounce(value, delay),
      { initialProps: { value: 'hello', delay: 300 } }
    );

    rerender({ value: 'world', delay: 300 });

    // Value hasn't changed yet
    expect(result.current).toBe('hello');

    // Advance past debounce delay
    act(() => {
      vi.advanceTimersByTime(300);
    });

    expect(result.current).toBe('world');
  });

  it('resets timer on rapid changes', () => {
    const { result, rerender } = renderHook(
      ({ value, delay }) => useDebounce(value, delay),
      { initialProps: { value: 'a', delay: 300 } }
    );

    rerender({ value: 'ab', delay: 300 });
    act(() => { vi.advanceTimersByTime(100); });

    rerender({ value: 'abc', delay: 300 });
    act(() => { vi.advanceTimersByTime(100); });

    // Still shows original -- timer keeps resetting
    expect(result.current).toBe('a');

    act(() => { vi.advanceTimersByTime(300); });
    expect(result.current).toBe('abc');
  });
});
```

## Testing Context-Dependent Hooks

Hooks that use `useContext` need a provider wrapper.

```typescript
interface AuthState {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

function useAuth(): AuthState {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
}

describe('useAuth', () => {
  it('throws when used outside AuthProvider', () => {
    expect(() => {
      renderHook(() => useAuth());
    }).toThrow('useAuth must be used within AuthProvider');
  });

  it('returns the current user from context', () => {
    const wrapper = ({ children }: { children: React.ReactNode }) => (
      <AuthProvider initialUser={{ id: '1', name: 'Alice', email: 'alice@example.com' }}>
        {children}
      </AuthProvider>
    );

    const { result } = renderHook(() => useAuth(), { wrapper });

    expect(result.current.user).toEqual(
      expect.objectContaining({ name: 'Alice' })
    );
  });

  it('clears user on logout', async () => {
    const wrapper = ({ children }: { children: React.ReactNode }) => (
      <AuthProvider initialUser={{ id: '1', name: 'Alice', email: 'alice@example.com' }}>
        {children}
      </AuthProvider>
    );

    const { result } = renderHook(() => useAuth(), { wrapper });

    act(() => {
      result.current.logout();
    });

    expect(result.current.user).toBeNull();
  });
});
```

### Reusable Wrapper Factory

```typescript
function createWrapper(overrides?: Partial<ProviderProps>) {
  return function Wrapper({ children }: { children: React.ReactNode }) {
    return (
      <QueryClientProvider client={new QueryClient()}>
        <AuthProvider initialUser={overrides?.user ?? null}>
          <ThemeProvider theme={overrides?.theme ?? defaultTheme}>
            {children}
          </ThemeProvider>
        </AuthProvider>
      </QueryClientProvider>
    );
  };
}

it('uses dark theme', () => {
  const { result } = renderHook(() => useTheme(), {
    wrapper: createWrapper({ theme: darkTheme }),
  });
  expect(result.current.mode).toBe('dark');
});
```

## Testing Hook Cleanup

Verify that hooks clean up subscriptions, timers, and event listeners.

```typescript
function useWindowResize() {
  const [size, setSize] = useState({
    width: window.innerWidth,
    height: window.innerHeight,
  });

  useEffect(() => {
    const handler = () => setSize({
      width: window.innerWidth,
      height: window.innerHeight,
    });
    window.addEventListener('resize', handler);
    return () => window.removeEventListener('resize', handler);
  }, []);

  return size;
}

describe('useWindowResize', () => {
  it('removes event listener on unmount', () => {
    const removeSpy = vi.spyOn(window, 'removeEventListener');

    const { unmount } = renderHook(() => useWindowResize());
    unmount();

    expect(removeSpy).toHaveBeenCalledWith('resize', expect.any(Function));
    removeSpy.mockRestore();
  });
});
```

## When act() Is Needed

`act()` ensures that all state updates, effects, and re-renders complete before assertions run.

### You Need act() When

- Calling a function returned by the hook that triggers a state update
- Manually advancing timers with `vi.advanceTimersByTime()`
- Triggering DOM events outside of RTL/user-event helpers

```typescript
// State update from hook function -> wrap in act()
act(() => {
  result.current.increment();
});

// Timer advancement -> wrap in act()
act(() => {
  vi.advanceTimersByTime(1000);
});
```

### You Do NOT Need act() When

- Using `renderHook` (initial render is already wrapped)
- Using `rerender` (already wrapped)
- Using `waitFor` (already wrapped)
- Using RTL's `render`, `fireEvent`, or `user-event` (already wrapped)

### The act() Warning

If you see `Warning: An update to X inside a test was not wrapped in act(...)`, it means a state update happened outside of `act()`. Common causes:

1. An async effect resolved after the test ended -- add `await waitFor()` or `unmount()` before the test ends.
2. A timer fired unexpectedly -- use `vi.useFakeTimers()` for deterministic control.
3. A promise resolved between assertions -- use `await waitFor()` to wait for it.

## Anti-Patterns

**Testing hooks through renderHook when a component test would be better:**
```typescript
// Bad: testing a single-use hook in isolation
const { result } = renderHook(() => useCheckoutFormState());
act(() => { result.current.setEmail('alice@example.com'); });
expect(result.current.email).toBe('alice@example.com');
```
Instead, render `<CheckoutForm />` and type into the email input. The hook exists to serve the component.

**Asserting on hook internals that users cannot see:**
```typescript
// Bad: testing internal state shape
expect(result.current.internalState).toEqual({ step: 2, validated: true });
```
Instead, assert on what the hook's consumer observes: rendered output or returned values that affect rendering.

**Forgetting to wrap state updates in act:**
```typescript
// Bad: causes act() warning
result.current.increment();
expect(result.current.count).toBe(1);
```
Instead, wrap in `act(() => { result.current.increment(); })`.

**Not cleaning up after hooks with side effects:**
```typescript
// Bad: event listener leaks between tests
renderHook(() => useWindowResize());
// Test ends without unmounting
```
Instead, call `unmount()` or rely on RTL's automatic cleanup, which calls unmount after each test.
