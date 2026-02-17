# Sociable Testing Philosophy

How and why to write sociable tests for React applications, and when stubbing is appropriate.

## What Are Sociable Tests?

Sociable tests exercise a component together with its real child components, hooks, and utilities. The component under test is not isolated from its collaborators.

```tsx
// Sociable: CheckoutPage renders real CartSummary, PaymentForm, and OrderTotal
it('shows order total after adding items', async () => {
  const user = userEvent.setup();
  render(<CheckoutPage />);

  await user.click(screen.getByRole('button', { name: 'Add Widget' }));
  await user.click(screen.getByRole('button', { name: 'Add Gadget' }));

  expect(screen.getByText('Total: $29.98')).toBeInTheDocument();
  expect(screen.getByRole('button', { name: 'Place Order' })).toBeEnabled();
});
```

Contrast with an isolated test that mocks every child:

```tsx
// Isolated: mocks everything, tests very little real behavior
vi.mock('./CartSummary', () => ({
  CartSummary: () => <div data-testid="cart-summary" />,
}));
vi.mock('./PaymentForm', () => ({
  PaymentForm: () => <div data-testid="payment-form" />,
}));
vi.mock('./useCart', () => ({
  useCart: () => ({ items: [], total: 0 }),
}));

it('renders cart summary and payment form', () => {
  render(<CheckoutPage />);
  expect(screen.getByTestId('cart-summary')).toBeInTheDocument();
  expect(screen.getByTestId('payment-form')).toBeInTheDocument();
});
```

The isolated test proves nothing about real behavior. The sociable test catches integration bugs, tests what users see, and survives refactors.

## Why Sociable Tests Win

**Catch integration bugs.** Mismatched prop types, wrong context values, or broken child components are caught immediately. A mocked child hides these failures.

**Survive refactors.** Rename a child component, extract a hook, or restructure internal state -- sociable tests keep passing as long as the user-visible behavior is preserved.

**Test real behavior.** You are testing what actually renders, not a simulated version. The user does not interact with mocks.

**Less test code.** No `vi.mock()` boilerplate, no mock return values to maintain, no test code that mirrors production code structure.

## When to Use Real Components

Use real child components for:

- **Your own components** -- `<CartSummary />`, `<UserAvatar />`, `<PriceDisplay />`
- **Your own hooks** -- `useCart()`, `useAuth()`, `useDebounce()`
- **Your own utilities** -- `formatCurrency()`, `validateEmail()`, `sortByDate()`
- **Context providers** -- render them in the test with real values
- **Pure presentational components** -- they are fast and deterministic

```tsx
// Good: real children, real hooks, real behavior
it('applies discount code to order total', async () => {
  const user = userEvent.setup();
  render(
    <CartProvider initialItems={[{ name: 'Widget', price: 9_99 }]}>
      <CheckoutPage />
    </CartProvider>
  );

  await user.type(screen.getByLabelText('Discount code'), 'SAVE20');
  await user.click(screen.getByRole('button', { name: 'Apply' }));

  expect(screen.getByText('Discount: -$2.00')).toBeInTheDocument();
  expect(screen.getByText('Total: $7.99')).toBeInTheDocument();
});
```

## When Stubbing Is Appropriate

Stub only at true system boundaries -- places where your application talks to the outside world:

- **HTTP requests** -- `fetch`, `axios`, API client wrappers
- **Browser APIs** -- `localStorage`, `sessionStorage`, `navigator.geolocation`, `IntersectionObserver`, `ResizeObserver`, `matchMedia`
- **Third-party services** -- analytics SDKs, auth providers, payment widgets
- **Timers** -- `setTimeout`, `setInterval`, `Date.now` (use `vi.useFakeTimers()`)
- **Random values** -- `Math.random()`, `crypto.randomUUID()`

```tsx
// Stub at the HTTP boundary -- everything else is real
vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
  ok: true,
  json: () => Promise.resolve({ items: [{ id: '1', name: 'Widget', price: 9_99 }] }),
}));

it('loads and displays products', async () => {
  render(<ProductCatalog />);

  expect(await screen.findByText('Widget')).toBeInTheDocument();
  expect(screen.getByText('$9.99')).toBeInTheDocument();
});
```

## Stubs vs Mocks

**Stubs** provide canned answers. They return predetermined data so the component under test has something to render.

**Mocks** verify interactions. They assert that specific functions were called with specific arguments.

**Prefer stubs.** They test what your component does with the data, not whether it made the right call.

```typescript
// Stub: provides canned data, lets you test rendered output
vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
  ok: true,
  json: () => Promise.resolve({ user: { name: 'Alice', role: 'admin' } }),
}));

// Test behavior: what does the component DO with the data?
it('shows admin badge for admin users', async () => {
  render(<UserProfile userId="123" />);
  expect(await screen.findByText('Admin')).toBeInTheDocument();
});
```

```typescript
// Mock: verifies the call was made correctly
// Less valuable -- tests HOW, not WHAT
it('fetches with the correct user ID', async () => {
  render(<UserProfile userId="123" />);

  expect(fetch).toHaveBeenCalledWith('/api/users/123');
});
```

The stub test verifies that admin users see an admin badge. The mock test only verifies that a fetch call happened. The stub test catches more real bugs.

### When Mock Assertions Are Acceptable

Sometimes you need to verify that a side effect occurred at a system boundary:

```typescript
// Acceptable: verifying that analytics was called is the observable behavior
it('tracks page view on mount', async () => {
  const trackSpy = vi.spyOn(analytics, 'trackPageView');
  render(<ProductPage productId="widget-1" />);

  expect(trackSpy).toHaveBeenCalledWith('product_view', { productId: 'widget-1' });
});
```

This is acceptable because:
1. Analytics is a true system boundary
2. The call itself IS the behavior (there is no rendered output to assert on)
3. You cannot verify analytics through the DOM

## Functional Core / UI Shell

The most powerful pattern for testable React code. Pure business logic in hooks and utilities, side effects at the component boundary.

### Functional Core: Pure Logic

```typescript
// Pure logic -- easy to test sociably, no mocking needed
function calculateCartTotals(
  items: CartItem[],
  discountCode?: string
): CartTotals {
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const discount = applyDiscount(subtotal, discountCode);
  const tax = calculateTax(subtotal - discount);
  const shipping = subtotal - discount >= 50_00 ? 0 : 5_99;

  return { subtotal, discount, tax, shipping, total: subtotal - discount + tax + shipping };
}

// Custom hook with pure logic
function useCartTotals(items: CartItem[], discountCode?: string): CartTotals {
  return useMemo(
    () => calculateCartTotals(items, discountCode),
    [items, discountCode]
  );
}
```

### UI Shell: Side Effects at the Boundary

```tsx
// UI shell -- orchestrates side effects, renders pure components
function CheckoutPage() {
  const { items } = useCart();
  const [discountCode, setDiscountCode] = useState('');
  const totals = useCartTotals(items, discountCode);

  // Side effect at boundary: HTTP request
  const handlePlaceOrder = async () => {
    const response = await fetch('/api/orders', {
      method: 'POST',
      body: JSON.stringify({ items, discountCode }),
    });
    // ...
  };

  return (
    <div>
      <CartSummary items={items} />
      <DiscountInput value={discountCode} onChange={setDiscountCode} />
      <OrderTotal totals={totals} />
      <button onClick={handlePlaceOrder}>Place Order</button>
    </div>
  );
}
```

### Testing Strategy

Test the functional core with simple unit tests -- no rendering, no mocking:

```typescript
describe('calculateCartTotals', () => {
  it('applies percentage discount', () => {
    const items = [{ price: 100_00, quantity: 1 }];
    const totals = calculateCartTotals(items, 'SAVE20');
    expect(totals.discount).toBe(20_00);
    expect(totals.total).toBe(100_00 - 20_00 + totals.tax + totals.shipping);
  });

  it('offers free shipping above $50', () => {
    const items = [{ price: 60_00, quantity: 1 }];
    const totals = calculateCartTotals(items);
    expect(totals.shipping).toBe(0);
  });
});
```

Test the UI shell sociably with stubs only at the HTTP boundary:

```tsx
it('submits order with correct items', async () => {
  vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve({ orderId: 'ord-123' }),
  }));

  const user = userEvent.setup();
  render(
    <CartProvider initialItems={[{ name: 'Widget', price: 9_99, quantity: 2 }]}>
      <CheckoutPage />
    </CartProvider>
  );

  await user.click(screen.getByRole('button', { name: 'Place Order' }));
  expect(await screen.findByText('Order confirmed')).toBeInTheDocument();
});
```

## The Testing Pyramid for React

```
        /  E2E  \          Few: Playwright/Cypress browser tests
       /----------\
      / Integration \      Some: full page with providers and stubbed fetch
     /----------------\
    /  Sociable Units   \  Most: components with real children, hooks, utils
   /______________________\
```

- **Sociable unit tests**: The bulk of your suite. Fast, reliable, test real behavior. Render components with real children and hooks.
- **Integration tests**: Full page render with all providers. Stub only HTTP/external boundaries. Test complete user flows.
- **E2E tests**: Browser-based tests with Playwright. Sparingly, for critical user flows that span multiple pages.

## Dependency Injection in React

When you need to swap an implementation at a boundary, use dependency injection instead of `vi.mock`.

### Props

```tsx
// Component accepts the API client as a prop with a default
interface ProductListProps {
  fetchProducts?: () => Promise<Product[]>;
}

function ProductList({ fetchProducts = defaultFetchProducts }: ProductListProps) {
  const [products, setProducts] = useState<Product[]>([]);

  useEffect(() => {
    fetchProducts().then(setProducts);
  }, [fetchProducts]);

  return (
    <ul>
      {products.map((p) => (
        <li key={p.id}>{p.name} - {formatCurrency(p.price)}</li>
      ))}
    </ul>
  );
}

// Test: inject a stub via props
it('renders products from the API', async () => {
  const stubFetch = () => Promise.resolve([
    { id: '1', name: 'Widget', price: 9_99 },
  ]);

  render(<ProductList fetchProducts={stubFetch} />);

  expect(await screen.findByText('Widget - $9.99')).toBeInTheDocument();
});
```

### Context

```tsx
// Context provides the boundary dependency
const ApiContext = createContext<ApiClient>(defaultApiClient);

function useApi() {
  return useContext(ApiContext);
}

// Test: wrap with a stub API context
function renderWithStubApi(ui: React.ReactElement, overrides?: Partial<ApiClient>) {
  const stubClient: ApiClient = {
    fetchProducts: () => Promise.resolve([]),
    fetchUser: () => Promise.resolve({ name: 'Alice' }),
    ...overrides,
  };

  return render(
    <ApiContext.Provider value={stubClient}>
      {ui}
    </ApiContext.Provider>
  );
}

it('shows empty state when no products', async () => {
  renderWithStubApi(<ProductList />);
  expect(await screen.findByText('No products found')).toBeInTheDocument();
});
```

## Anti-Patterns

**Mocking child components:**
```tsx
// Bad: CartSummary is your own code, not an external boundary
vi.mock('./CartSummary', () => ({
  CartSummary: () => <div>mocked cart</div>,
}));
```
Instead, render real `<CartSummary />`. It is fast, deterministic, and catches integration bugs.

**Mocking your own hooks:**
```typescript
// Bad: useCart is your own code, you want to test it works
vi.mock('./useCart', () => ({
  useCart: () => ({ items: [{ name: 'Widget' }], total: 9_99 }),
}));
```
Instead, provide the hook's dependencies (context, props) and let it run for real.

**Verifying fetch call signatures instead of rendered output:**
```typescript
// Bad: tests HOW, not WHAT
expect(fetch).toHaveBeenCalledWith('/api/products', {
  method: 'GET',
  headers: { 'Content-Type': 'application/json' },
});
```
Instead, assert on what the user sees: `expect(screen.getByText('Widget')).toBeInTheDocument()`.

**Mocking pure utility functions:**
```typescript
// Bad: why mock a pure function?
vi.mock('../utils/format', () => ({
  formatCurrency: (amount: number) => `$${(amount / 100).toFixed(2)}`,
}));
```
Instead, call the real `formatCurrency`. It is fast, has no side effects, and your mock might have bugs the real function does not.

**Creating mocks that mirror production structure:**
```typescript
// Bad: your mock IS the implementation, duplicated
vi.mock('./CartSummary', () => ({
  CartSummary: ({ items }: { items: Item[] }) => (
    <ul>
      {items.map((i) => <li key={i.id}>{i.name}</li>)}
    </ul>
  ),
}));
```
Instead, use the real `CartSummary`. If you find yourself rewriting a component inside a mock, the mock is pointless.
