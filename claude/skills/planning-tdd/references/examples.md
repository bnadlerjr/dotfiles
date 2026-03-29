# TDD Plan Examples

Concrete examples showing the expected output format for different scenarios.

## Example 1: New Feature -- Email Verification

**Input**: "Add email verification to user registration"

### Phase 1: Email Validation (2 TDD cycles)

#### Cycle 1: Valid email format

**RED -- Write Failing Test**

```elixir
test "rejects registration with invalid email format" do
  assert {:error, changeset} = Accounts.register_user(%{email: "not-an-email", password: "secret123"})
  assert "is not a valid email" in errors_on(changeset).email
end
```

**Expected failure**: `Accounts.register_user/1 is undefined`

**Structural context**: `lib/accounts/user.ex:12` (existing User schema), test at `test/accounts/user_test.exs`

#### Cycle 2: Unique email constraint

**RED -- Write Failing Test**

```elixir
test "rejects registration with duplicate email" do
  {:ok, _user} = Accounts.register_user(%{email: "taken@example.com", password: "secret123"})
  assert {:error, changeset} = Accounts.register_user(%{email: "taken@example.com", password: "other456"})
  assert "has already been taken" in errors_on(changeset).email
end
```

**Expected failure**: Uniqueness constraint not yet added; test passes when it should fail (no unique index)

**Structural context**: `lib/accounts/user.ex:12`, `priv/repo/migrations/` for new unique index

### Automated Testing

- [ ] Unit: rejects invalid email format -- `test/accounts/user_test.exs`
- [ ] Unit: rejects duplicate email -- `test/accounts/user_test.exs`

**Run**: `mix test test/accounts/user_test.exs`
**Expected**: 2 tests, 0 failures

### Manual Verification

- [ ] POST to `/api/register` with `email: "bad"` -- confirm 422 with validation error
- [ ] POST to `/api/register` with `email: "test@example.com"` twice -- confirm second returns 422

---

### Phase 2: Verification Token (3 TDD cycles)

#### Cycle 1: Token generation on registration

**RED -- Write Failing Test**

```elixir
test "generates a verification token on registration" do
  {:ok, user} = Accounts.register_user(%{email: "new@example.com", password: "secret123"})
  assert user.verification_token != nil
  assert user.verified_at == nil
end
```

**Expected failure**: `verification_token` field does not exist on User schema

**Structural context**: `lib/accounts/user.ex:12` (needs new fields), `priv/repo/migrations/` for migration

#### Cycle 2: Token verification

**RED -- Write Failing Test**

```elixir
test "verifies user with valid token" do
  {:ok, user} = Accounts.register_user(%{email: "new@example.com", password: "secret123"})
  assert {:ok, verified_user} = Accounts.verify_email(user.verification_token)
  assert verified_user.verified_at != nil
end
```

**Expected failure**: `Accounts.verify_email/1 is undefined`

**Structural context**: `lib/accounts.ex` (context module), test at `test/accounts_test.exs`

#### Cycle 3: Expired or invalid token

**RED -- Write Failing Test**

```elixir
test "rejects expired verification token" do
  {:ok, user} = Accounts.register_user(%{email: "new@example.com", password: "secret123"})
  expire_token(user)
  assert {:error, :token_expired} = Accounts.verify_email(user.verification_token)
end

test "rejects invalid verification token" do
  assert {:error, :invalid_token} = Accounts.verify_email("bogus-token")
end
```

**Expected failure**: No expiration logic exists yet

**Structural context**: `lib/accounts.ex`, test helper `expire_token/1` to add in `test/support/`

### Automated Testing

- [ ] Unit: generates verification token -- `test/accounts/user_test.exs`
- [ ] Unit: verifies with valid token -- `test/accounts_test.exs`
- [ ] Unit: rejects expired token -- `test/accounts_test.exs`
- [ ] Unit: rejects invalid token -- `test/accounts_test.exs`

**Run**: `mix test test/accounts/`
**Expected**: 6 tests (cumulative), 0 failures

### Manual Verification

- [ ] Register via API, inspect DB row for `verification_token` and `verified_at: nil`
- [ ] Hit verification endpoint with the token, confirm `verified_at` is set
- [ ] Hit verification endpoint with a garbage token, confirm 404

---

## Example 2: Bug Fix -- Duplicate Webhook Deliveries

**Input**: "Webhooks fire twice when an order is updated concurrently"

### Phase 1: Reproduce the Bug (1 TDD cycle)

#### Cycle 1: Concurrent update triggers duplicate delivery

**RED -- Write Failing Test**

```elixir
test "delivers webhook exactly once for concurrent order updates" do
  order = insert(:order)
  webhook = insert(:webhook, event: "order.updated", url: "https://example.com/hook")

  # Simulate two concurrent updates
  task1 = Task.async(fn -> Orders.update(order, %{status: "shipped"}) end)
  task2 = Task.async(fn -> Orders.update(order, %{status: "shipped"}) end)
  Task.await_many([task1, task2])

  deliveries = Webhooks.list_deliveries(webhook.id)
  assert length(deliveries) == 1
end
```

**Expected failure**: `assert length(deliveries) == 1` fails with `2` (this IS the bug)

**Structural context**: `lib/webhooks/dispatcher.ex:45` (dispatch logic), `test/webhooks/dispatcher_test.exs`

### Automated Testing

- [ ] Integration: exactly-once delivery under concurrency -- `test/webhooks/dispatcher_test.exs`

**Run**: `mix test test/webhooks/dispatcher_test.exs`
**Expected**: 1 test, 1 failure (this test captures the bug)

### Done When

- [ ] Test fails, confirming the bug is reproducible

### Manual Verification

- [ ] Not applicable for this phase -- bug reproduction only

---

### Phase 2: Fix and Regression Tests (2 TDD cycles)

#### Cycle 1: Idempotency guard

**RED -- Write Failing Test** (already written in Phase 1 -- now make it pass)

The test from Phase 1 is the RED test. Implementation makes it GREEN.

**Structural context**: `lib/webhooks/dispatcher.ex:45` (add idempotency key or advisory lock)

#### Cycle 2: Regression -- rapid sequential updates

**RED -- Write Failing Test**

```elixir
test "delivers separate webhooks for distinct status changes" do
  order = insert(:order, status: "pending")

  Orders.update(order, %{status: "shipped"})
  Orders.update(order, %{status: "delivered"})

  deliveries = Webhooks.list_deliveries_for(order.id)
  assert length(deliveries) == 2
  assert Enum.map(deliveries, & &1.payload["status"]) == ["shipped", "delivered"]
end
```

**Expected failure**: Depends on fix approach -- if the fix is too aggressive it may deduplicate legitimate updates

**Structural context**: `lib/webhooks/dispatcher.ex`, `test/webhooks/dispatcher_test.exs`

### Automated Testing

- [ ] Integration: exactly-once delivery under concurrency -- `test/webhooks/dispatcher_test.exs`
- [ ] Integration: distinct updates deliver separately -- `test/webhooks/dispatcher_test.exs`

**Run**: `mix test test/webhooks/dispatcher_test.exs`
**Expected**: 3 tests (cumulative), 0 failures

### Done When

- [ ] All tests pass: `mix test test/webhooks/`
- [ ] Original bug test (concurrent updates) passes
- [ ] Regression test (sequential distinct updates) passes

### Manual Verification

- [ ] Update an order twice in rapid succession via API, check webhook logs for exactly one delivery per distinct change
- [ ] Confirm no duplicate entries in `webhook_deliveries` table

---

## Example 3: Refactoring -- Extract Pricing Module

**Input**: "Extract pricing logic from OrderController into a dedicated Pricing module"

### Phase 1: Characterization Tests (3 TDD cycles)

These tests document CURRENT behavior before any structural changes.

#### Cycle 1: Base price calculation

**RED -- Write Failing Test**

```elixir
test "calculates base price for a single item" do
  item = build(:line_item, unit_price: Money.new(1000), quantity: 2)
  assert Money.new(2000) == Pricing.calculate([item])
end
```

**Expected failure**: `Pricing` module does not exist yet

**Structural context**: Logic currently lives in `lib/web/controllers/order_controller.ex:78-95`. Test at `test/pricing_test.exs` (new file).

#### Cycle 2: Discount application

**RED -- Write Failing Test**

```elixir
test "applies percentage discount to total" do
  items = [build(:line_item, unit_price: Money.new(1000), quantity: 1)]
  discount = %Discount{type: :percentage, value: 10}
  assert Money.new(900) == Pricing.calculate(items, discount: discount)
end
```

**Expected failure**: `Pricing.calculate/2` clause does not exist

**Structural context**: Discount logic at `lib/web/controllers/order_controller.ex:97-110`

#### Cycle 3: Tax calculation

**RED -- Write Failing Test**

```elixir
test "adds tax to discounted total" do
  items = [build(:line_item, unit_price: Money.new(1000), quantity: 1)]
  discount = %Discount{type: :percentage, value: 10}
  assert Money.new(954) == Pricing.calculate(items, discount: discount, tax_rate: 0.06)
end
```

**Expected failure**: `tax_rate` option not handled

**Structural context**: Tax logic at `lib/web/controllers/order_controller.ex:112-120`

### Automated Testing

- [ ] Unit: base price calculation -- `test/pricing_test.exs`
- [ ] Unit: discount application -- `test/pricing_test.exs`
- [ ] Unit: tax calculation -- `test/pricing_test.exs`

**Run**: `mix test test/pricing_test.exs`
**Expected**: 3 tests, 0 failures

### Done When

- [ ] All characterization tests pass against the NEW `Pricing` module
- [ ] `OrderController` delegates to `Pricing` (no pricing logic remains inline)
- [ ] Existing controller tests still pass: `mix test test/web/controllers/order_controller_test.exs`

### Manual Verification

- [ ] Create an order via API with items, discount, and tax -- verify total matches expected calculation
- [ ] Compare API response before and after refactor (should be identical)

---

## Anti-Example: Implementation Leakage

This shows a common mistake -- including GREEN implementation code and REFACTOR commentary in a plan cycle. The plan should contain ONLY the RED test spec.

### Wrong -- includes implementation code

#### Cycle 1: HTML Response Returns Error

**RED -- Write Failing Test**

```elixir
test "returns error tuple for HTML response body" do
  html_body = "<html><body>Service Unavailable</body></html>"
  assert {:error, %ParseError{reason: :invalid_json}} = ResponseParser.parse(html_body)
end
```

**Expected failure**: `ResponseParser.parse/1 is undefined`

**Structural context**: `lib/client/response_parser.ex:18` (existing module), test at `test/client/response_parser_test.exs`

**GREEN -- Make It Pass**

```elixir
def parse(body) when is_binary(body) do
  case Jason.decode(body) do
    {:ok, decoded} -> {:ok, decoded}
    {:error, _} -> {:error, %ParseError{reason: :invalid_json}}
  end
end
```

**REFACTOR:** None needed -- single clause, no duplication.

### Correct -- test spec only

#### Cycle 1: HTML Response Returns Error

**RED -- Write Failing Test**

```elixir
test "returns error tuple for HTML response body" do
  html_body = "<html><body>Service Unavailable</body></html>"
  assert {:error, %ParseError{reason: :invalid_json}} = ResponseParser.parse(html_body)
end
```

**Expected failure**: `ResponseParser.parse/1 is undefined`

**Structural context**: `lib/client/response_parser.ex:18` (existing module, needs new clause handling non-JSON input), test at `test/client/response_parser_test.exs`

The GREEN and REFACTOR steps emerge during execution when the `practicing-tdd` and `refactoring-code` skills are applied. The plan specifies only the RED test and enough structural context to know where to work.
