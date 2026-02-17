# Component Testing Patterns

Common patterns for testing React components with Vitest and React Testing Library.

## Forms

### Text Input and Submission

```tsx
it('submits contact form with user data', async () => {
  const handleSubmit = vi.fn();
  const user = userEvent.setup();
  render(<ContactForm onSubmit={handleSubmit} />);

  await user.type(screen.getByLabelText('Full name'), 'Alice Johnson');
  await user.type(screen.getByLabelText('Email'), 'alice@example.com');
  await user.type(screen.getByLabelText('Message'), 'Hello, I have a question.');
  await user.click(screen.getByRole('button', { name: 'Send Message' }));

  expect(handleSubmit).toHaveBeenCalledWith({
    name: 'Alice Johnson',
    email: 'alice@example.com',
    message: 'Hello, I have a question.',
  });
});
```

### Validation Errors

```tsx
it('shows validation errors for empty required fields', async () => {
  const user = userEvent.setup();
  render(<ContactForm onSubmit={vi.fn()} />);

  await user.click(screen.getByRole('button', { name: 'Send Message' }));

  expect(screen.getByText('Name is required')).toBeInTheDocument();
  expect(screen.getByText('Email is required')).toBeInTheDocument();
});

it('shows email format error for invalid email', async () => {
  const user = userEvent.setup();
  render(<ContactForm onSubmit={vi.fn()} />);

  await user.type(screen.getByLabelText('Email'), 'not-an-email');
  await user.click(screen.getByRole('button', { name: 'Send Message' }));

  expect(screen.getByText('Please enter a valid email address')).toBeInTheDocument();
});
```

### Clearing Validation on Fix

```tsx
it('clears validation error when field is corrected', async () => {
  const user = userEvent.setup();
  render(<ContactForm onSubmit={vi.fn()} />);

  // Trigger validation error
  await user.click(screen.getByRole('button', { name: 'Send Message' }));
  expect(screen.getByText('Name is required')).toBeInTheDocument();

  // Fix the field
  await user.type(screen.getByLabelText('Full name'), 'Alice');

  // Error should clear
  expect(screen.queryByText('Name is required')).not.toBeInTheDocument();
});
```

### Select and Checkbox Inputs

```tsx
it('submits form with select and checkbox values', async () => {
  const handleSubmit = vi.fn();
  const user = userEvent.setup();
  render(<PreferencesForm onSubmit={handleSubmit} />);

  await user.selectOptions(
    screen.getByRole('combobox', { name: 'Language' }),
    'es'
  );
  await user.click(screen.getByRole('checkbox', { name: 'Subscribe to newsletter' }));
  await user.click(screen.getByRole('button', { name: 'Save Preferences' }));

  expect(handleSubmit).toHaveBeenCalledWith(
    expect.objectContaining({
      language: 'es',
      newsletter: true,
    })
  );
});
```

### Disabled Submit During Processing

```tsx
it('disables submit button while processing', async () => {
  const user = userEvent.setup();
  render(<ContactForm onSubmit={() => new Promise(() => {})} />); // Never resolves

  await user.type(screen.getByLabelText('Full name'), 'Alice');
  await user.type(screen.getByLabelText('Email'), 'alice@example.com');
  await user.click(screen.getByRole('button', { name: 'Send Message' }));

  expect(screen.getByRole('button', { name: /sending/i })).toBeDisabled();
});
```

## Modals and Dialogs

### Opening and Closing

```tsx
it('opens and closes a confirmation dialog', async () => {
  const user = userEvent.setup();
  render(<DeleteAccountSection />);

  // Dialog not present initially
  expect(screen.queryByRole('dialog')).not.toBeInTheDocument();

  // Open dialog
  await user.click(screen.getByRole('button', { name: 'Delete Account' }));

  const dialog = screen.getByRole('dialog', { name: 'Confirm Deletion' });
  expect(dialog).toBeInTheDocument();
  expect(within(dialog).getByText('This action cannot be undone.')).toBeInTheDocument();

  // Close dialog
  await user.click(within(dialog).getByRole('button', { name: 'Cancel' }));
  expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
});
```

### Dialog Confirmation Action

```tsx
it('calls onDelete when confirming deletion', async () => {
  const handleDelete = vi.fn();
  const user = userEvent.setup();
  render(<DeleteAccountSection onDelete={handleDelete} />);

  await user.click(screen.getByRole('button', { name: 'Delete Account' }));
  await user.click(
    within(screen.getByRole('dialog')).getByRole('button', { name: 'Delete Permanently' })
  );

  expect(handleDelete).toHaveBeenCalledTimes(1);
});
```

### Escape Key Closes Dialog

```tsx
it('closes dialog on Escape key', async () => {
  const user = userEvent.setup();
  render(<DeleteAccountSection />);

  await user.click(screen.getByRole('button', { name: 'Delete Account' }));
  expect(screen.getByRole('dialog')).toBeInTheDocument();

  await user.keyboard('{Escape}');
  expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
});
```

## Lists and Tables

### Rendering List Items

```tsx
it('renders all products in the list', () => {
  const products = [
    { id: '1', name: 'Widget', price: 9_99 },
    { id: '2', name: 'Gadget', price: 19_99 },
    { id: '3', name: 'Doohickey', price: 4_99 },
  ];
  render(<ProductList products={products} />);

  const items = screen.getAllByRole('listitem');
  expect(items).toHaveLength(3);
  expect(items[0]).toHaveTextContent('Widget');
  expect(items[1]).toHaveTextContent('Gadget');
  expect(items[2]).toHaveTextContent('Doohickey');
});
```

### Empty State

```tsx
it('shows empty state when no products exist', () => {
  render(<ProductList products={[]} />);

  expect(screen.getByText('No products found')).toBeInTheDocument();
  expect(screen.queryByRole('list')).not.toBeInTheDocument();
});
```

### Table with Actions

```tsx
it('removes item from table when delete is clicked', async () => {
  const handleRemove = vi.fn();
  const user = userEvent.setup();
  const items = [
    { id: '1', name: 'Widget', price: 9_99 },
    { id: '2', name: 'Gadget', price: 19_99 },
  ];
  render(<ItemsTable items={items} onRemove={handleRemove} />);

  const widgetRow = screen.getByRole('row', { name: /widget/i });
  await user.click(within(widgetRow).getByRole('button', { name: 'Remove' }));

  expect(handleRemove).toHaveBeenCalledWith('1');
});
```

### Sorting

```tsx
it('sorts products by price when column header is clicked', async () => {
  const user = userEvent.setup();
  const products = [
    { id: '1', name: 'Gadget', price: 19_99 },
    { id: '2', name: 'Widget', price: 9_99 },
    { id: '3', name: 'Doohickey', price: 4_99 },
  ];
  render(<ProductTable products={products} />);

  await user.click(screen.getByRole('columnheader', { name: 'Price' }));

  const rows = screen.getAllByRole('row').slice(1); // Skip header row
  expect(rows[0]).toHaveTextContent('Doohickey');
  expect(rows[1]).toHaveTextContent('Widget');
  expect(rows[2]).toHaveTextContent('Gadget');
});
```

## Conditional Rendering

### Show/Hide Based on State

```tsx
it('shows details panel when expand is clicked', async () => {
  const user = userEvent.setup();
  render(<ProductCard product={{ name: 'Widget', description: 'A fine widget' }} />);

  expect(screen.queryByText('A fine widget')).not.toBeInTheDocument();

  await user.click(screen.getByRole('button', { name: 'Show details' }));
  expect(screen.getByText('A fine widget')).toBeInTheDocument();

  await user.click(screen.getByRole('button', { name: 'Hide details' }));
  expect(screen.queryByText('A fine widget')).not.toBeInTheDocument();
});
```

### Conditional Elements Based on Props

```tsx
it('shows admin controls only for admin users', () => {
  render(<UserDashboard user={{ name: 'Alice', role: 'admin' }} />);

  expect(screen.getByRole('button', { name: 'Manage Users' })).toBeInTheDocument();
  expect(screen.getByRole('link', { name: 'Admin Settings' })).toBeInTheDocument();
});

it('hides admin controls for regular users', () => {
  render(<UserDashboard user={{ name: 'Bob', role: 'member' }} />);

  expect(screen.queryByRole('button', { name: 'Manage Users' })).not.toBeInTheDocument();
  expect(screen.queryByRole('link', { name: 'Admin Settings' })).not.toBeInTheDocument();
});
```

## Loading States

### Spinner During Data Fetch

```tsx
it('shows spinner while loading and content when done', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve({ name: 'Alice' }),
  }));

  render(<UserProfile userId="123" />);

  // Loading state
  expect(screen.getByRole('progressbar')).toBeInTheDocument();

  // Content after loading
  expect(await screen.findByText('Alice')).toBeInTheDocument();
  expect(screen.queryByRole('progressbar')).not.toBeInTheDocument();
});
```

### Skeleton Loading

```tsx
it('replaces skeleton with content after load', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve([
      { id: '1', name: 'Widget' },
      { id: '2', name: 'Gadget' },
    ]),
  }));

  render(<ProductGrid />);

  // Skeleton placeholders while loading
  expect(screen.getAllByRole('article')).toHaveLength(6); // 6 skeleton cards

  // Real content after load
  await waitFor(() => {
    expect(screen.getAllByRole('article')).toHaveLength(2);
  });
  expect(screen.getByText('Widget')).toBeInTheDocument();
});
```

## Error Boundaries

```tsx
function ThrowingComponent(): React.ReactElement {
  throw new Error('Component crashed');
}

it('renders fallback UI when child component throws', () => {
  // Suppress console.error for expected errors
  const consoleSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

  render(
    <ErrorBoundary fallback={<p>Something went wrong</p>}>
      <ThrowingComponent />
    </ErrorBoundary>
  );

  expect(screen.getByText('Something went wrong')).toBeInTheDocument();

  consoleSpy.mockRestore();
});

it('renders children when no error occurs', () => {
  render(
    <ErrorBoundary fallback={<p>Something went wrong</p>}>
      <p>Working content</p>
    </ErrorBoundary>
  );

  expect(screen.getByText('Working content')).toBeInTheDocument();
  expect(screen.queryByText('Something went wrong')).not.toBeInTheDocument();
});
```

## Error States

### API Error Display

```tsx
it('shows error message when API request fails', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
    ok: false,
    status: 500,
    statusText: 'Internal Server Error',
  }));

  render(<ProductList />);

  expect(await screen.findByRole('alert')).toHaveTextContent(
    'Failed to load products. Please try again.'
  );
});
```

### Retry After Error

```tsx
it('retries loading when retry button is clicked', async () => {
  const fetchMock = vi.fn()
    .mockResolvedValueOnce({ ok: false, status: 500, statusText: 'Error' })
    .mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve([{ id: '1', name: 'Widget' }]),
    });
  vi.stubGlobal('fetch', fetchMock);

  const user = userEvent.setup();
  render(<ProductList />);

  // Error state with retry
  await screen.findByRole('alert');
  await user.click(screen.getByRole('button', { name: 'Try Again' }));

  // Successful retry
  expect(await screen.findByText('Widget')).toBeInTheDocument();
  expect(screen.queryByRole('alert')).not.toBeInTheDocument();
});
```

## Testing with Context Providers

### Direct Provider Wrapping

```tsx
it('shows current theme', () => {
  render(
    <ThemeContext.Provider value={{ mode: 'dark', toggle: vi.fn() }}>
      <ThemeIndicator />
    </ThemeContext.Provider>
  );

  expect(screen.getByText('Dark mode')).toBeInTheDocument();
});
```

### Shared Render Helper

```tsx
function renderWithAuth(
  ui: React.ReactElement,
  { user = null }: { user?: User | null } = {}
) {
  return render(
    <AuthContext.Provider value={{ user, login: vi.fn(), logout: vi.fn() }}>
      {ui}
    </AuthContext.Provider>
  );
}

it('shows login button when not authenticated', () => {
  renderWithAuth(<NavBar />);
  expect(screen.getByRole('link', { name: 'Sign In' })).toBeInTheDocument();
});

it('shows user name when authenticated', () => {
  renderWithAuth(<NavBar />, {
    user: { id: '1', name: 'Alice', email: 'alice@example.com' },
  });
  expect(screen.getByText('Alice')).toBeInTheDocument();
});
```

## Accessible Component Testing

### ARIA Roles and Labels

```tsx
it('has accessible navigation landmarks', () => {
  render(<AppLayout />);

  expect(screen.getByRole('banner')).toBeInTheDocument();     // <header>
  expect(screen.getByRole('navigation')).toBeInTheDocument();
  expect(screen.getByRole('main')).toBeInTheDocument();
  expect(screen.getByRole('contentinfo')).toBeInTheDocument(); // <footer>
});
```

### Form Accessibility

```tsx
it('associates labels with inputs', () => {
  render(<RegistrationForm />);

  // getByLabelText proves the label-input association exists
  expect(screen.getByLabelText('Email address')).toBeRequired();
  expect(screen.getByLabelText('Password')).toBeRequired();
  expect(screen.getByLabelText('Confirm password')).toBeRequired();
});

it('describes validation errors with aria-describedby', async () => {
  const user = userEvent.setup();
  render(<RegistrationForm onSubmit={vi.fn()} />);

  await user.click(screen.getByRole('button', { name: 'Register' }));

  const emailInput = screen.getByLabelText('Email address');
  expect(emailInput).toBeInvalid();
  expect(emailInput).toHaveAccessibleDescription('Email is required');
});
```

### Keyboard Navigation

```tsx
it('is fully navigable with keyboard', async () => {
  const user = userEvent.setup();
  render(<NavigationMenu items={['Home', 'Products', 'About']} />);

  await user.tab();
  expect(screen.getByRole('link', { name: 'Home' })).toHaveFocus();

  await user.tab();
  expect(screen.getByRole('link', { name: 'Products' })).toHaveFocus();

  await user.tab();
  expect(screen.getByRole('link', { name: 'About' })).toHaveFocus();
});
```

### Live Regions

```tsx
it('announces status updates to screen readers', async () => {
  const user = userEvent.setup();
  render(<SaveButton onSave={() => Promise.resolve()} />);

  await user.click(screen.getByRole('button', { name: 'Save' }));

  const status = await screen.findByRole('status');
  expect(status).toHaveTextContent('Changes saved successfully');
});
```

## Testing with Router

```tsx
import { MemoryRouter, Route, Routes } from 'react-router-dom';

it('navigates to product detail on click', async () => {
  const user = userEvent.setup();

  render(
    <MemoryRouter initialEntries={['/products']}>
      <Routes>
        <Route path="/products" element={<ProductList products={products} />} />
        <Route path="/products/:id" element={<ProductDetail />} />
      </Routes>
    </MemoryRouter>
  );

  await user.click(screen.getByRole('link', { name: 'Widget' }));

  expect(screen.getByRole('heading', { name: 'Widget' })).toBeInTheDocument();
});
```

## Testing Portals

Components rendered via `createPortal` appear in the DOM but outside the component's container. `screen` queries still find them.

```tsx
it('renders modal content via portal', async () => {
  const user = userEvent.setup();
  render(<ModalTrigger />);

  await user.click(screen.getByRole('button', { name: 'Open' }));

  // screen queries the entire document, including portals
  expect(screen.getByRole('dialog')).toBeInTheDocument();
  expect(screen.getByText('Modal content')).toBeInTheDocument();
});
```

## Anti-Patterns

**Testing internal state instead of rendered output:**
```tsx
// Bad: inspecting component internals
expect(component.state.isOpen).toBe(true);
```
Instead, assert on what the user sees: `expect(screen.getByRole('dialog')).toBeInTheDocument()`.

**Using container.innerHTML for assertions:**
```tsx
// Bad: fragile string matching on raw HTML
expect(container.innerHTML).toContain('<button class="primary">');
```
Instead, use `screen.getByRole('button')` and `toHaveClass('primary')` if the class matters behaviorally.

**Reaching into child component implementation:**
```tsx
// Bad: testing a child's internal behavior from parent test
expect(screen.getByTestId('cart-item-count-internal')).toHaveTextContent('3');
```
Instead, test the same thing a user would see: `expect(screen.getByText('3 items')).toBeInTheDocument()`.
