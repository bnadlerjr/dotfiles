# TDD Plan Examples

Concrete examples showing the expected output format for different scenarios.

Every cycle in a plan is behavioral — no test code anywhere. Exact RED test specs are produced just-in-time during execution; see "Execution-Time Detailing" below for the transformation.

## Example 1: New Feature -- Email Verification

**Input**: "Add email verification to user registration"

### Phase 1: Email Validation (2 TDD cycles)

#### Cycle 1: Valid email format

**Behavior**: Given a registration attempt with a malformed email, when the user is registered, then registration is rejected with an email validation error

**Assertion focus**: changeset error on `email` for malformed input

**Expected failure category**: function undefined (no registration operation exists yet)

**Structural context**: User schema at `lib/accounts/user.ex:12`; test in `test/accounts/`

#### Cycle 2: Unique email constraint

**Behavior**: Given an email already registered, when a second registration uses the same email, then registration is rejected with a uniqueness error

**Assertion focus**: "has already been taken" changeset error on duplicate email

**Expected failure category**: constraint missing (no unique index yet — test passes when it should fail)

**Structural context**: User schema at `lib/accounts/user.ex:12`; `priv/repo/migrations/` for new unique index

### Automated Testing

- [ ] Unit: rejects invalid email format -- path resolved at detailing time
- [ ] Unit: rejects duplicate email -- path resolved at detailing time

**Run**: `mix test test/accounts/`
**Expected**: 2 tests, 0 failures

---

### Phase 2: Verification Token (3 TDD cycles)

#### Cycle 1: Token generation on registration

**Behavior**: Given a valid registration, when the user is created, then the user has a non-nil verification token and is not yet verified

**Assertion focus**: token present, `verified_at` absent on a freshly registered user

**Expected failure category**: schema field missing

**Structural context**: User schema (`lib/accounts/user.ex`) gains token/verified fields via migration

#### Cycle 2: Token verification

**Behavior**: Given a registered user with a verification token, when the token is submitted, then the user becomes verified

**Assertion focus**: `verified_at` is set after verifying with a valid token

**Expected failure category**: function undefined (no verify operation exists yet)

**Structural context**: Accounts context module (`lib/accounts.ex`)

#### Cycle 3: Expired or invalid token

**Behavior**: Given an expired token (or a token that was never issued), when verification is attempted, then it is rejected with a distinct error per case

**Assertion focus**: `:token_expired` vs `:invalid_token` error discrimination

**Expected failure category**: missing expiration/validation logic

**Structural context**: Accounts context module; a test helper for aging tokens will be needed in `test/support/`

### Automated Testing

- [ ] Unit: generates verification token -- path resolved at detailing time
- [ ] Unit: verifies with valid token -- path resolved at detailing time
- [ ] Unit: rejects expired token -- path resolved at detailing time
- [ ] Unit: rejects invalid token -- path resolved at detailing time

**Run**: `mix test test/accounts/`
**Expected**: 6 tests (cumulative), 0 failures

---

## Execution-Time Detailing

Behavioral cycles are converted to detailed RED test specs by `/implement` as each phase starts, against the codebase as it exists at that moment. Phase 1's Cycle 1 above, once detailed, becomes:

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

This form exists only in plans under execution — never in a freshly planned artifact. The behavior and assertion focus carry over unchanged; the shape (function names, setup, file paths) reflects the current code.

---

## Example 2: Bug Fix -- Duplicate Webhook Deliveries

**Input**: "Webhooks fire twice when an order is updated concurrently"

### Phase 1: Reproduce the Bug (1 TDD cycle)

#### Cycle 1: Concurrent update triggers duplicate delivery

**Behavior**: Given an order with a registered "order.updated" webhook, when two updates to the order commit concurrently, then exactly one webhook delivery is recorded

**Assertion focus**: delivery count is exactly 1 under concurrent updates

**Expected failure category**: assertion mismatch — 2 deliveries observed where 1 is expected (this IS the bug)

**Structural context**: dispatch logic at `lib/webhooks/dispatcher.ex:45`

### Automated Testing

- [ ] Integration: exactly-once delivery under concurrency -- path resolved at detailing time

**Run**: `mix test test/webhooks/`
**Expected**: 1 test, 1 failure (this test captures the bug)

### Done When

- [ ] Test fails, confirming the bug is reproducible

---

### Phase 2: Fix and Regression Tests (2 TDD cycles)

#### Cycle 1: Idempotency guard

**Behavior**: Given the failing reproduction test from Phase 1, when the fix is applied, then concurrent updates deliver exactly one webhook

**Assertion focus**: the Phase 1 test passes (it is this cycle's RED test — no new test is written)

**Expected failure category**: already failing from Phase 1

**Structural context**: dispatch logic in `lib/webhooks/dispatcher.ex` (idempotency key or advisory lock)

#### Cycle 2: Regression -- rapid sequential updates

**Behavior**: Given an order updated twice in quick succession with distinct statuses, when both updates commit, then two separate webhooks deliver with the correct payloads in order

**Assertion focus**: legitimate distinct updates are NOT deduplicated by the fix

**Expected failure category**: depends on fix approach -- an over-aggressive fix deduplicates legitimate updates

**Structural context**: dispatch logic in `lib/webhooks/dispatcher.ex`

### Automated Testing

- [ ] Integration: exactly-once delivery under concurrency -- written in Phase 1
- [ ] Integration: distinct updates deliver separately -- path resolved at detailing time

**Run**: `mix test test/webhooks/`
**Expected**: 3 tests (cumulative), 0 failures

### Done When

- [ ] All tests pass: `mix test test/webhooks/`
- [ ] Original bug test (concurrent updates) passes
- [ ] Regression test (sequential distinct updates) passes

---

## Example 3: Refactoring -- Extract Pricing Module

**Input**: "Extract pricing logic from OrderController into a dedicated Pricing module"

### Phase 1: Characterization Tests (3 TDD cycles)

These tests document CURRENT behavior before any structural changes.

#### Cycle 1: Base price calculation

**Behavior**: Given a line item with a unit price and quantity, when the price is calculated through the new `Pricing` module, then the total equals unit price times quantity (matching current controller behavior)

**Assertion focus**: single-item total equals `unit_price * quantity`

**Expected failure category**: module undefined (`Pricing` does not exist yet)

**Structural context**: Logic currently lives in `lib/web/controllers/order_controller.ex:78-95`; new module and new test file

#### Cycle 2: Discount application

**Behavior**: Given line items and a percentage discount, when the price is calculated, then the discount is applied to the total (matching current controller behavior)

**Assertion focus**: a 10% discount reduces the total by exactly 10%

**Expected failure category**: function clause missing (no discount option handled yet)

**Structural context**: Discount logic at `lib/web/controllers/order_controller.ex:97-110`

#### Cycle 3: Tax calculation

**Behavior**: Given line items, a discount, and a tax rate, when the price is calculated, then tax applies to the discounted total, not the original (matching current controller behavior)

**Assertion focus**: tax computed on the post-discount amount

**Expected failure category**: option not handled (`tax_rate`)

**Structural context**: Tax logic at `lib/web/controllers/order_controller.ex:112-120`

### Automated Testing

- [ ] Unit: base price calculation -- path resolved at detailing time
- [ ] Unit: discount application -- path resolved at detailing time
- [ ] Unit: tax calculation -- path resolved at detailing time

**Run**: `mix test test/pricing_test.exs`
**Expected**: 3 tests, 0 failures

### Done When

- [ ] All characterization tests pass against the NEW `Pricing` module
- [ ] `OrderController` delegates to `Pricing` (no pricing logic remains inline)
- [ ] Existing controller tests still pass: `mix test test/web/controllers/order_controller_test.exs`

---

## Anti-Example: Implementation Leakage

Two leakage mistakes to avoid:

1. **Planning-time leakage**: any test code in a plan. Plans carry behavioral cycles only — the detailed form is produced during execution.
2. **Execution-time leakage**: GREEN implementation code or REFACTOR commentary in a detailed cycle. Even when `/implement` details a phase, the cycle contains ONLY the RED test spec.

The example below shows the second mistake, in a cycle that has been detailed during execution.

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
