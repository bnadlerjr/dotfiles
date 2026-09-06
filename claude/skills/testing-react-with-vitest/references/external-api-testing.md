# External API Testing

Stubbing HTTP at the network boundary with MSW (Mock Service Worker).

## Why MSW Over vi.mock

`vi.mock('../api/client')` replaces your own module, so the test never exercises your request building, response parsing, or error handling. MSW intercepts at the network layer instead: your real client code runs, and only the HTTP response is canned.

HTTP is a true system boundary (`sociable-testing.md`), so it is the right place to stub. Everything above it stays real.

```typescript
// Bad: your API client never runs -- parsing and error handling go untested
vi.mock('../api/client', () => ({ fetchUser: vi.fn().mockResolvedValue(user) }));

// Good: real client, real fetch, canned response
server.use(http.get('/api/user/:id', () => HttpResponse.json(user)));
```

## Server Setup

Create the server once and wire it into the suite lifecycle.

```typescript
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

const server = setupServer(
  http.get('/api/user/:id', ({ params }) => {
    return HttpResponse.json({ id: params.id, name: 'Test User' });
  })
);

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

`onUnhandledRequest: 'error'` fails the test on any request you did not stub. Without it, an unhandled request falls through to the real network and the failure surfaces somewhere far less obvious.

`resetHandlers()` in `afterEach` discards per-test overrides. Without it, a `server.use` override leaks into later tests and failures become order-dependent.

Put this block in your Vitest setup file (`core-vitest.md`) when most of the suite needs it, rather than repeating it per file.

## Handlers

### Path parameters and query strings

```typescript
http.get('/api/orders/:orderId', ({ params, request }) => {
  const url = new URL(request.url);
  const expand = url.searchParams.get('expand');

  return HttpResponse.json({
    id: params.orderId,
    items: expand === 'items' ? [{ sku: 'WIDGET', qty: 2 }] : undefined,
  });
});
```

### Reading a request body

Type the body with the second generic parameter so `request.json()` is not `unknown`.

```typescript
interface CreateOrderBody {
  sku: string;
  qty: number;
}

http.post<never, CreateOrderBody>('/api/orders', async ({ request }) => {
  const body = await request.json();

  return HttpResponse.json({ id: 'ord_123', ...body }, { status: 201 });
});
```

## Per-Test Overrides

Declare the happy path once in `setupServer`, then override for the specific case under test. `server.use` prepends handlers that win until the next `resetHandlers()`.

```tsx
it('shows an error when the profile fails to load', async () => {
  server.use(
    http.get('/api/user/:id', () => {
      return HttpResponse.json({ message: 'Not found' }, { status: 404 });
    })
  );

  render(<UserProfile userId="1" />);

  expect(await screen.findByRole('alert')).toHaveTextContent('Could not load profile');
});
```

### Network failure

```typescript
server.use(http.get('/api/user/:id', () => HttpResponse.error()));
```

### Slow responses

```typescript
import { delay } from 'msw';

server.use(
  http.get('/api/user/:id', async () => {
    await delay(100);
    return HttpResponse.json({ id: '1', name: 'Test User' });
  })
);
```

Prefer asserting on the loading state via `findBy*` over adding delays. Reach for `delay` only when the timing itself is the behavior under test.

## Asserting on Requests

MSW is a stub, not a mock -- assert on what the user sees, not on the request. The exception is a call with no observable result, such as analytics. Capture the payload in the handler:

```tsx
it('tracks the product view', async () => {
  let tracked: unknown;

  server.use(
    http.post('/api/events', async ({ request }) => {
      tracked = await request.json();
      return new HttpResponse(null, { status: 204 });
    })
  );

  render(<ProductPage productId="widget-1" />);

  await waitFor(() =>
    expect(tracked).toMatchObject({ event: 'product_view', productId: 'widget-1' })
  );
});
```

## Anti-Patterns

**Stubbing your own API client instead of the network:**
```typescript
// Bad: request building and response parsing never execute
vi.mock('../api/client');
```
Stub the HTTP response with MSW and let the client run.

**Asserting on requests when the UI already proves it:**
```typescript
// Bad: testing the call, not the outcome
expect(capturedOrderBody).toEqual({ coupon: 'SAVE20' });
```
The coupon produces a visible discount, so assert on the discount instead.

**Defining every handler inline per test:** duplicates the happy path everywhere. Declare defaults in `setupServer`, override with `server.use` only for the case under test.
