# Phoenix Testing

Testing Phoenix controllers, LiveView, and channels with their respective test helpers.

## ConnTest Basics

Phoenix.ConnTest provides helpers for testing HTTP endpoints through the router.

```elixir
defmodule MyAppWeb.OrderControllerTest do
  use MyAppWeb.ConnCase, async: true

  describe "GET /api/orders" do
    test "returns list of orders for authenticated user", %{conn: conn} do
      user = insert(:user)
      order = insert(:order, user: user)

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/api/orders")

      assert json_response(conn, 200) == %{
               "orders" => [%{"id" => order.id, "status" => "pending"}]
             }
    end

    test "returns 401 for unauthenticated requests", %{conn: conn} do
      conn = get(conn, ~p"/api/orders")
      assert json_response(conn, 401)
    end
  end
end
```

### HTTP verbs

```elixir
conn = get(conn, ~p"/api/orders")
conn = post(conn, ~p"/api/orders", %{order: %{product_id: 1, quantity: 2}})
conn = put(conn, ~p"/api/orders/#{order.id}", %{order: %{quantity: 3}})
conn = patch(conn, ~p"/api/orders/#{order.id}", %{order: %{status: "confirmed"}})
conn = delete(conn, ~p"/api/orders/#{order.id}")
```

### Testing JSON APIs

```elixir
test "creates an order and returns 201", %{conn: conn} do
  conn =
    conn
    |> log_in_user(insert(:user))
    |> post(~p"/api/orders", %{
      order: %{product_id: 1, quantity: 2}
    })

  assert %{"id" => id, "status" => "pending"} = json_response(conn, 201)
  assert is_integer(id)
end

test "returns 422 with validation errors", %{conn: conn} do
  conn =
    conn
    |> log_in_user(insert(:user))
    |> post(~p"/api/orders", %{order: %{}})

  assert %{"errors" => errors} = json_response(conn, 422)
  assert %{"product_id" => ["can't be blank"]} = errors
end
```

### Testing HTML responses

```elixir
test "renders the order show page", %{conn: conn} do
  order = insert(:order)

  conn =
    conn
    |> log_in_user(order.user)
    |> get(~p"/orders/#{order.id}")

  html = html_response(conn, 200)
  assert html =~ "Order ##{order.id}"
  assert html =~ "pending"
end

test "redirects to login when not authenticated", %{conn: conn} do
  conn = get(conn, ~p"/orders")
  assert redirected_to(conn) == ~p"/users/log_in"
end
```

## Authentication in Tests

Define a helper in `ConnCase` or `test/support/conn_case.ex`.

```elixir
defmodule MyAppWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint MyAppWeb.Endpoint
      use MyAppWeb, :verified_routes
      import Plug.Conn
      import Phoenix.ConnTest
      import MyAppWeb.ConnCase
    end
  end

  setup tags do
    MyApp.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def log_in_user(conn, user) do
    token = MyApp.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end
```

For API token auth:

```elixir
def authenticate(conn, user) do
  token = MyApp.Accounts.create_api_token(user)

  conn
  |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")
end
```

## Testing Plugs

```elixir
defmodule MyAppWeb.RequireAdminTest do
  use MyAppWeb.ConnCase, async: true

  describe "call/2" do
    test "allows admin users through", %{conn: conn} do
      admin = insert(:user, role: :admin)

      conn =
        conn
        |> log_in_user(admin)
        |> MyAppWeb.RequireAdmin.call([])

      refute conn.halted
    end

    test "halts and returns 403 for non-admin users", %{conn: conn} do
      user = insert(:user, role: :member)

      conn =
        conn
        |> log_in_user(user)
        |> MyAppWeb.RequireAdmin.call([])

      assert conn.halted
      assert conn.status == 403
    end
  end
end
```

## LiveViewTest

### Basic LiveView test

```elixir
defmodule MyAppWeb.OrderLiveTest do
  use MyAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "index" do
    test "lists orders for the current user", %{conn: conn} do
      user = insert(:user)
      order = insert(:order, user: user, status: :pending)

      {:ok, view, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/orders")

      assert html =~ "Your Orders"
      assert html =~ "Order ##{order.id}"
    end
  end
end
```

### Testing events

```elixir
test "cancelling an order updates the list", %{conn: conn} do
  user = insert(:user)
  order = insert(:order, user: user, status: :pending)

  {:ok, view, _html} =
    conn
    |> log_in_user(user)
    |> live(~p"/orders")

  html =
    view
    |> element("#order-#{order.id} button", "Cancel")
    |> render_click()

  assert html =~ "cancelled"
  refute html =~ "pending"
end
```

### Testing form submission

```elixir
test "creating an order with valid data", %{conn: conn} do
  user = insert(:user)
  product = insert(:product)

  {:ok, view, _html} =
    conn
    |> log_in_user(user)
    |> live(~p"/orders/new")

  assert view
         |> form("#order-form", order: %{product_id: product.id, quantity: 2})
         |> render_submit() =~ "Order created successfully"
end

test "shows validation errors for invalid data", %{conn: conn} do
  user = insert(:user)

  {:ok, view, _html} =
    conn
    |> log_in_user(user)
    |> live(~p"/orders/new")

  html =
    view
    |> form("#order-form", order: %{product_id: nil, quantity: 0})
    |> render_submit()

  assert html =~ "can&#39;t be blank"
end
```

### Testing form validation (change events)

```elixir
test "validates quantity on change", %{conn: conn} do
  user = insert(:user)

  {:ok, view, _html} =
    conn
    |> log_in_user(user)
    |> live(~p"/orders/new")

  html =
    view
    |> form("#order-form", order: %{quantity: -1})
    |> render_change()

  assert html =~ "must be greater than 0"
end
```

### Testing LiveView assigns

```elixir
test "loads the order into assigns", %{conn: conn} do
  user = insert(:user)
  order = insert(:order, user: user)

  {:ok, view, _html} =
    conn
    |> log_in_user(user)
    |> live(~p"/orders/#{order.id}")

  assert %Order{id: id} = view |> element("#order-detail") |> render() |> Floki.parse_document!()
  # Or assert on the rendered HTML directly
end
```

### Testing LiveView streams

```elixir
test "appends new orders via stream", %{conn: conn} do
  user = insert(:user)

  {:ok, view, _html} =
    conn
    |> log_in_user(user)
    |> live(~p"/orders")

  # Simulate a PubSub event that triggers a stream insert
  order = insert(:order, user: user)
  Phoenix.PubSub.broadcast(MyApp.PubSub, "user:#{user.id}:orders", {:new_order, order})

  # Give LiveView time to process
  html = render(view)
  assert html =~ "Order ##{order.id}"
end
```

### Testing LiveView components

```elixir
test "renders order card component" do
  order = build(:order, id: 1, status: :confirmed, total: 42_00)

  html = render_component(MyAppWeb.OrderComponents, :order_card, order: order)

  assert html =~ "Order #1"
  assert html =~ "confirmed"
  assert html =~ "$42.00"
end
```

## ChannelTest

### Setup

```elixir
defmodule MyAppWeb.OrderChannelTest do
  use MyAppWeb.ChannelCase, async: true

  setup do
    user = insert(:user)

    {:ok, _, socket} =
      MyAppWeb.UserSocket
      |> socket("user:#{user.id}", %{user_id: user.id})
      |> subscribe_and_join(MyAppWeb.OrderChannel, "order:lobby", %{})

    %{socket: socket, user: user}
  end

  test "ping replies with pong", %{socket: socket} do
    ref = push(socket, "ping", %{})
    assert_reply ref, :ok, %{"response" => "pong"}
  end

  test "broadcasts new orders to the lobby", %{socket: socket, user: user} do
    order = insert(:order, user: user)
    push(socket, "new_order", %{"order_id" => order.id})

    assert_broadcast "order_created", %{"order_id" => id}
    assert id == order.id
  end

  test "handles invalid messages gracefully", %{socket: socket} do
    ref = push(socket, "unknown_event", %{})
    assert_reply ref, :error, %{"reason" => "unhandled event"}
  end
end
```

### Testing PubSub subscriptions

```elixir
test "receives updates when order status changes", %{socket: _socket, user: user} do
  order = insert(:order, user: user, status: :pending)

  # Trigger the status change through the context
  {:ok, _updated} = Orders.confirm(order)

  assert_push "order_updated", %{"id" => id, "status" => "confirmed"}
  assert id == order.id
end
```

## ConnCase and DataCase Setup

### ConnCase

```elixir
defmodule MyAppWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint MyAppWeb.Endpoint
      use MyAppWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import MyAppWeb.ConnCase
      import MyApp.Factory
    end
  end

  setup tags do
    MyApp.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
```

### ChannelCase

```elixir
defmodule MyAppWeb.ChannelCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ChannelTest
      import MyApp.Factory

      @endpoint MyAppWeb.Endpoint
    end
  end

  setup tags do
    MyApp.DataCase.setup_sandbox(tags)
    :ok
  end
end
```

## Anti-Patterns

**Testing controller logic directly instead of through the router:**
```elixir
# Bad: bypasses plugs, middleware, and routing
MyAppWeb.OrderController.create(conn, params)
```
Instead, use `post(conn, ~p"/api/orders", params)` to test the full request pipeline.

**Asserting on exact HTML structure:**
```elixir
# Bad: breaks on any markup change
assert html =~ "<div class=\"order-card\"><span class=\"status\">pending</span></div>"
```
Instead, assert on meaningful content: `assert html =~ "pending"` or use `element/3` selectors.

**Not testing authentication boundaries:**
```elixir
# Bad: every test logs in, but no test checks what happens without auth
```
Instead, always include tests for unauthenticated and unauthorized access.
