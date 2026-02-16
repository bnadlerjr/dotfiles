# External API Testing

Testing HTTP APIs and external services using Bypass, Req.Test, and behaviour-based stubs.

## Bypass

Bypass starts a real HTTP server on localhost that your code can hit. Use it when your code makes HTTP requests with any client (Req, Finch, :httpc, etc.).

### Starting Bypass

```elixir
defmodule MyApp.WeatherClientTest do
  use ExUnit.Case, async: true

  setup do
    bypass = Bypass.open()
    %{bypass: bypass}
  end

  test "fetches current weather", %{bypass: bypass} do
    Bypass.expect_once(bypass, "GET", "/api/weather", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, Jason.encode!(%{temp: 72, condition: "sunny"}))
    end)

    assert {:ok, %{temp: 72}} =
             MyApp.WeatherClient.fetch("Portland", base_url: endpoint_url(bypass))
  end

  defp endpoint_url(bypass), do: "http://localhost:#{bypass.port}"
end
```

### Bypass.expect_once vs Bypass.expect

- `Bypass.expect_once/4` -- Expects exactly one request matching the method and path. Fails if the request is not made or is made more than once.
- `Bypass.expect/4` -- Expects one or more requests. Fails only if no matching request is made.

```elixir
# Use expect_once when exactly one call should be made
Bypass.expect_once(bypass, "POST", "/api/charge", fn conn ->
  conn |> Plug.Conn.resp(200, ~s({"id": "ch_123"}))
end)

# Use expect when the code might retry or make multiple calls
Bypass.expect(bypass, "GET", "/api/status", fn conn ->
  conn |> Plug.Conn.resp(200, ~s({"status": "ok"}))
end)
```

### Matching on request body

```elixir
Bypass.expect_once(bypass, "POST", "/api/orders", fn conn ->
  {:ok, body, conn} = Plug.Conn.read_body(conn)
  params = Jason.decode!(body)

  assert params["amount"] == 42_00
  assert params["currency"] == "usd"

  conn
  |> Plug.Conn.put_resp_content_type("application/json")
  |> Plug.Conn.resp(201, Jason.encode!(%{id: "order_123"}))
end)
```

### Matching on headers

```elixir
Bypass.expect_once(bypass, "GET", "/api/me", fn conn ->
  assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer test_token"]

  conn
  |> Plug.Conn.put_resp_content_type("application/json")
  |> Plug.Conn.resp(200, Jason.encode!(%{name: "Alice"}))
end)
```

### Simulating errors

```elixir
test "handles server errors gracefully", %{bypass: bypass} do
  Bypass.expect_once(bypass, "GET", "/api/weather", fn conn ->
    Plug.Conn.resp(conn, 500, "Internal Server Error")
  end)

  assert {:error, :server_error} =
           MyApp.WeatherClient.fetch("Portland", base_url: endpoint_url(bypass))
end

test "handles connection failures", %{bypass: bypass} do
  Bypass.down(bypass)

  assert {:error, :connection_refused} =
           MyApp.WeatherClient.fetch("Portland", base_url: endpoint_url(bypass))
end
```

## Req.Test

Req.Test provides plug-based request/response stubs for code that uses the Req HTTP client. No real HTTP server needed -- requests are intercepted in-process.

### Basic stub

```elixir
defmodule MyApp.GitHubClientTest do
  use ExUnit.Case, async: true

  test "fetches repository info" do
    Req.Test.stub(MyApp.GitHubClient, fn conn ->
      assert conn.request_path == "/repos/elixir-lang/elixir"

      Req.Test.json(conn, %{
        name: "elixir",
        stargazers_count: 23000
      })
    end)

    assert {:ok, %{name: "elixir", stars: 23000}} =
             MyApp.GitHubClient.get_repo("elixir-lang/elixir")
  end
end
```

### Setting up the client to use Req.Test

In your HTTP client module, accept a plug option for testing:

```elixir
defmodule MyApp.GitHubClient do
  def get_repo(full_name) do
    case Req.get(base_req(), url: "/repos/#{full_name}") do
      {:ok, %{status: 200, body: body}} ->
        {:ok, %{name: body["name"], stars: body["stargazers_count"]}}

      {:ok, %{status: status}} ->
        {:error, {:unexpected_status, status}}

      {:error, exception} ->
        {:error, exception}
    end
  end

  defp base_req do
    Req.new(base_url: "https://api.github.com")
    |> Req.Request.put_header("accept", "application/json")
    |> attach_test_plug()
  end

  defp attach_test_plug(req) do
    if plug = Req.Test.transport_plug(__MODULE__) do
      Req.Request.put_option(req, :plug, plug)
    else
      req
    end
  end
end
```

### Req.Test with error simulation

```elixir
test "handles rate limiting" do
  Req.Test.stub(MyApp.GitHubClient, fn conn ->
    conn
    |> Plug.Conn.put_resp_header("retry-after", "60")
    |> Plug.Conn.send_resp(429, "")
  end)

  assert {:error, :rate_limited} = MyApp.GitHubClient.get_repo("elixir-lang/elixir")
end

test "handles network errors" do
  Req.Test.stub(MyApp.GitHubClient, fn _conn ->
    raise "connection reset"
  end)

  assert {:error, _} = MyApp.GitHubClient.get_repo("elixir-lang/elixir")
end
```

## Behaviours for Non-HTTP Dependencies

For external services that are not HTTP-based (or when you want a simpler approach than Bypass), use behaviours with stub implementations.

### Define the behaviour

```elixir
defmodule MyApp.EmailSender do
  @callback send_email(to :: String.t(), subject :: String.t(), body :: String.t()) ::
              {:ok, String.t()} | {:error, atom()}
end
```

### Real implementation

```elixir
defmodule MyApp.EmailSender.Postmark do
  @behaviour MyApp.EmailSender

  @impl true
  def send_email(to, subject, body) do
    # Real Postmark API call via Req
    case Req.post(base_req(), json: %{To: to, Subject: subject, HtmlBody: body}) do
      {:ok, %{status: 200, body: %{"MessageID" => id}}} -> {:ok, id}
      _ -> {:error, :send_failed}
    end
  end
end
```

### Stub implementation

```elixir
defmodule MyApp.EmailSender.Stub do
  @behaviour MyApp.EmailSender

  @impl true
  def send_email(_to, _subject, _body) do
    {:ok, "msg_test_#{System.unique_integer([:positive])}"}
  end
end
```

### Stub that records calls (when you need to verify)

```elixir
defmodule MyApp.EmailSender.TestStub do
  @behaviour MyApp.EmailSender

  @impl true
  def send_email(to, subject, body) do
    send(self(), {:email_sent, %{to: to, subject: subject, body: body}})
    {:ok, "msg_test_#{System.unique_integer([:positive])}"}
  end
end
```

```elixir
test "sends welcome email on registration" do
  # Config or parameter injection points to TestStub
  {:ok, _user} = Accounts.register(%{name: "Alice", email: "alice@example.com"})

  assert_receive {:email_sent, %{to: "alice@example.com", subject: "Welcome!"}}
end
```

### Application config for swapping

```elixir
# config/config.exs
config :my_app, :email_sender, MyApp.EmailSender.Postmark

# config/test.exs
config :my_app, :email_sender, MyApp.EmailSender.Stub

# In application code
defmodule MyApp.Accounts do
  def register(attrs) do
    sender = Application.fetch_env!(:my_app, :email_sender)

    with {:ok, user} <- create_user(attrs) do
      sender.send_email(user.email, "Welcome!", welcome_body(user))
      {:ok, user}
    end
  end
end
```

## Testing Retry Logic

```elixir
describe "fetch_with_retry/1" do
  test "retries on 503 and succeeds", %{bypass: bypass} do
    # Track call count with an Agent
    {:ok, counter} = Agent.start_link(fn -> 0 end)

    Bypass.expect(bypass, "GET", "/api/data", fn conn ->
      call_num = Agent.get_and_update(counter, fn n -> {n + 1, n + 1} end)

      if call_num < 3 do
        Plug.Conn.resp(conn, 503, "Service Unavailable")
      else
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{data: "success"}))
      end
    end)

    assert {:ok, %{data: "success"}} =
             MyApp.Client.fetch_with_retry(base_url: endpoint_url(bypass))

    assert Agent.get(counter, & &1) == 3
  end
end
```

## Testing Timeouts

```elixir
test "times out after configured duration", %{bypass: bypass} do
  Bypass.expect(bypass, "GET", "/api/slow", fn conn ->
    Process.sleep(5_000)
    Plug.Conn.resp(conn, 200, "too late")
  end)

  assert {:error, :timeout} =
           MyApp.Client.fetch(base_url: endpoint_url(bypass), timeout: 100)
end
```

## Anti-Patterns

**Hitting real APIs in tests:**
```elixir
# Bad: flaky, slow, requires credentials, costs money
test "creates a real Stripe charge" do
  Stripe.Charge.create(%{amount: 100, source: "tok_visa"})
end
```
Instead, use Bypass, Req.Test, or a behaviour stub.

**Not testing error paths:**
```elixir
# Bad: only tests the happy path
test "fetches weather" do
  # Only stubs 200 response, never tests 500, timeout, malformed JSON
end
```
Instead, test at least: success, server error, network failure, and malformed response.

**Brittle URL matching:**
```elixir
# Bad: breaks if query params change order
Bypass.expect_once(bypass, "GET", "/api/weather?city=Portland&units=f", fn conn ->
  # ...
end)
```
Instead, match on path only and assert query params separately:
```elixir
Bypass.expect_once(bypass, "GET", "/api/weather", fn conn ->
  params = Plug.Conn.fetch_query_params(conn).query_params
  assert params["city"] == "Portland"
  # ...
end)
```

**Leaking test configuration into production:**
```elixir
# Bad: hardcoding test URL in the client module
defmodule MyApp.Client do
  @base_url System.get_env("API_URL", "http://localhost:#{bypass.port}")
end
```
Instead, inject the base URL via config or function parameter, with Bypass providing the port dynamically.
