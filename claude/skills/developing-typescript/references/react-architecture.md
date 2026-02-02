# React Architecture Reference

Expert guidance for React component architecture, hooks patterns, state management, and composition strategies.

## Quick Start

```typescript
// Custom hook extracting logic
function useAsync<T>(asyncFn: () => Promise<T>) {
  const [state, setState] = useState<AsyncState<T>>({ status: 'idle' });

  const execute = useCallback(async () => {
    setState({ status: 'loading' });
    try {
      const data = await asyncFn();
      setState({ status: 'success', data });
    } catch (error) {
      setState({ status: 'error', error: error as Error });
    }
  }, [asyncFn]);

  return { ...state, execute };
}

// Component using composition
function UserProfile({ userId }: { userId: string }) {
  const { status, data, error, execute } = useAsync(
    () => fetchUser(userId)
  );

  useEffect(() => { execute(); }, [execute]);

  if (status === 'loading') return <Spinner />;
  if (status === 'error') return <ErrorMessage error={error} />;
  if (status === 'success') return <UserCard user={data} />;
  return null;
}
```

## Core Competencies

### Component Patterns
- Design components using composition over inheritance
- Implement compound components for related UI elements
- Use render props and children-as-function when appropriate
- Apply container/presentational separation strategically

## Component Props Typing

### Extending HTML Elements

Use `ComponentPropsWithoutRef` to inherit native element props:

```typescript
type ButtonProps = {
  variant: 'primary' | 'secondary';
  isLoading?: boolean;
} & React.ComponentPropsWithoutRef<'button'>;

function Button({ variant, isLoading, children, ...props }: ButtonProps) {
  return (
    <button className={variant} disabled={isLoading} {...props}>
      {isLoading ? <Spinner /> : children}
    </button>
  );
}
```

### Children Typing Patterns

```typescript
type Props = {
  children: React.ReactNode;              // Anything renderable
  icon: React.ReactElement;               // Single React element
  render: (data: User) => React.ReactNode; // Render prop
};
```

### Discriminated Union Props

Type-safe variant handling with mutually exclusive props:

```typescript
type ButtonProps =
  | { variant: 'link'; href: string; onClick?: never }
  | { variant: 'button'; onClick: () => void; href?: never };

function ActionButton(props: ButtonProps) {
  if (props.variant === 'link') {
    return <a href={props.href}>Link</a>;
  }
  return <button onClick={props.onClick}>Button</button>;
}
```

## Event Handler Types

Quick reference for React event types:

| Event | Type | Use Case |
|-------|------|----------|
| Click | `React.MouseEvent<HTMLButtonElement>` | Button clicks |
| Submit | `React.FormEvent<HTMLFormElement>` | Form submission |
| Change | `React.ChangeEvent<HTMLInputElement>` | Input changes |
| KeyDown | `React.KeyboardEvent<HTMLInputElement>` | Keyboard input |
| Focus | `React.FocusEvent<HTMLInputElement>` | Focus/blur |
| Drag | `React.DragEvent<HTMLDivElement>` | Drag and drop |

```typescript
function Form() {
  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);
  }

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    console.log(e.target.value);
  }

  function handleKeyDown(e: React.KeyboardEvent<HTMLInputElement>) {
    if (e.key === 'Enter') e.currentTarget.blur();
  }

  return (
    <form onSubmit={handleSubmit}>
      <input onChange={handleChange} onKeyDown={handleKeyDown} />
    </form>
  );
}

### Hooks Mastery
- Create custom hooks that encapsulate complex logic
- Understand hook rules and dependency arrays deeply
- Use useReducer for complex state transitions
- Leverage useRef for values that don't trigger re-renders

### State Management
- Choose appropriate state location (local, lifted, context)
- Implement Context API for truly global state
- Design reducers with discriminated union actions
- Avoid prop drilling through composition, not just context

### Component Composition
- Build flexible APIs with compound components
- Use React.cloneElement and context for implicit communication
- Design slot patterns for layout flexibility
- Implement controlled and uncontrolled component variants

## TDD Phase Guidance

For general TDD phase definitions, see [SKILL.md](../SKILL.md#tdd-phase-awareness).

**React-specific guidance by phase:**

| Phase | Focus | Avoid |
|-------|-------|-------|
| RED | Test user interactions, simple components | Complex hooks, context providers |
| GREEN | Inline logic, direct state | Custom hooks, premature abstraction |
| REFACTOR | Extract hooks, improve composition | Over-engineering, unnecessary context |

## Component Design Principles

### Single Responsibility

```typescript
// Bad: component does too much
function UserDashboard() {
  // Fetching, filtering, sorting, rendering all in one
}

// Good: separated concerns
function UserDashboard() {
  const users = useUsers();
  const filtered = useUserFilter(users);
  return <UserList users={filtered} />;
}
```

### Composition Over Configuration

```typescript
// Bad: prop-heavy configuration
<Table
  sortable
  filterable
  pagination
  columns={columns}
  data={data}
  onSort={handleSort}
  // ... many more props
/>

// Good: composable parts
<Table data={data}>
  <Table.Header>
    <Table.SortableColumn field="name" />
    <Table.Column field="email" />
  </Table.Header>
  <Table.Body />
  <Table.Pagination />
</Table>
```

### Colocation

Keep related code together:
- Styles with components (CSS modules, styled-components)
- Types with the code that uses them
- Tests near the components they test
- Hooks in the same file if only used once

## State Management Patterns

### When to Use What

| Scenario | Solution |
|----------|----------|
| UI state (open/closed) | useState in component |
| Form state | React Hook Form or useState |
| Server cache | React Query, SWR, Apollo |
| Shared UI state | Lift state or Context |
| Complex transitions | useReducer |
| Global app state | Zustand, Jotai, or Context |

### Reducer Pattern

```typescript
type Action =
  | { type: 'FETCH_START' }
  | { type: 'FETCH_SUCCESS'; payload: User[] }
  | { type: 'FETCH_ERROR'; error: Error };

function userReducer(state: State, action: Action): State {
  switch (action.type) {
    case 'FETCH_START':
      return { ...state, loading: true, error: null };
    case 'FETCH_SUCCESS':
      return { ...state, loading: false, users: action.payload };
    case 'FETCH_ERROR':
      return { ...state, loading: false, error: action.error };
  }
}
```

### Context Best Practices

```typescript
// Split context by update frequency
const UserContext = createContext<User | null>(null);
const UserActionsContext = createContext<UserActions | null>(null);

// Custom hook with null-guard pattern
function useUser(): User {
  const context = useContext(UserContext);
  if (!context) {
    throw new Error('useUser must be used within UserProvider');
  }
  return context; // Type is User, not User | null
}

// For optional context, return the nullable type
function useOptionalUser(): User | null {
  return useContext(UserContext);
}
```

### Context with Actions Pattern

```typescript
type UserActions = {
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
  updateProfile: (data: Partial<User>) => Promise<void>;
};

const UserActionsContext = createContext<UserActions | null>(null);

function useUserActions(): UserActions {
  const context = useContext(UserActionsContext);
  if (!context) {
    throw new Error('useUserActions must be used within UserProvider');
  }
  return context;
}
```

## Custom Hook Patterns

### Data Fetching Hook

```typescript
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const controller = new AbortController();

    fetch(url, { signal: controller.signal })
      .then(res => res.json())
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false));

    return () => controller.abort();
  }, [url]);

  return { data, error, loading };
}
```

### Tuple Returns with as const

Use `as const` to preserve tuple typing for hooks returning arrays:

```typescript
function useToggle(initial = false) {
  const [value, setValue] = useState(initial);
  const toggle = useCallback(() => setValue(v => !v), []);
  return [value, toggle] as const;
  // Type: readonly [boolean, () => void]
}

function useCounter(initial = 0) {
  const [count, setCount] = useState(initial);
  const increment = useCallback(() => setCount(c => c + 1), []);
  const decrement = useCallback(() => setCount(c => c - 1), []);
  return [count, increment, decrement] as const;
  // Type: readonly [number, () => void, () => void]
}
```

### Event Handler Hook

```typescript
function useEventCallback<T extends (...args: any[]) => any>(fn: T): T {
  const ref = useRef(fn);
  useLayoutEffect(() => { ref.current = fn; });
  return useCallback((...args: Parameters<T>) => ref.current(...args), []) as T;
}
```

## Accessibility Defaults

- Use semantic HTML elements first
- Implement proper ARIA attributes when needed
- Ensure keyboard navigation works
- Test with screen readers
- Manage focus appropriately

## Anti-Patterns to Prevent

- Prop drilling more than 2-3 levels
- Using Context for frequently-changing values
- Putting everything in global state
- useEffect for derived state (use useMemo)
- Inline object/array props causing re-renders
- Mixing concerns in a single component

## What This Reference Does NOT Cover

- TypeScript advanced types (see `typescript-core.md`)
- React 19 features, Server Components (see `react-19-patterns.md`)
- Performance optimization (see `performance-optimization.md`)
- Testing patterns (see `testing-react.md`)
- GraphQL integration (see `graphql-integration.md`)

## Goal

Help developers build maintainable React applications through proper component architecture, effective state management, and thoughtful composition patterns.
