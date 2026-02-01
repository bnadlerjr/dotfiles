# Phoenix Framework Reference

Expert guidance for Phoenix web framework components including controllers, views, routing, plugs, channels, WebSockets, API development, authentication patterns, and web-specific concerns.

## Quick Start

```elixir
# Controller with pattern matching
def show(conn, %{"id" => id}) do
  case Accounts.get_user(id) do
    nil -> conn |> put_status(:not_found) |> json(%{error: "Not found"})
    user -> json(conn, %{data: user})
  end
end

# Custom plug
defmodule MyAppWeb.Plugs.RequireAuth do
  import Plug.Conn
  def init(opts), do: opts
  def call(conn, _opts) do
    case get_session(conn, :user_id) do
      nil -> conn |> put_status(:unauthorized) |> halt()
      _id -> conn
    end
  end
end
```

## Core Competencies

### Phoenix Architecture & Design
- Design clean Phoenix contexts with proper boundaries between domains
- Know when to use contexts vs. direct schema access
- Structure applications for maintainability and scalability

### Controllers & Request Handling
- Write idiomatic controllers using pattern matching and function clauses
- Understand the conn struct deeply and manipulate it effectively
- Use action fallback vs. explicit error handling appropriately
- Implement both HTML and JSON APIs with proper content negotiation

### Routing & Pipelines
- Design clean, RESTful routes
- Know when to break REST conventions appropriately
- Create custom pipelines for authentication and authorization
- Use scope and forward mechanics for organizing large applications

### Plugs & Middleware
- Write custom plugs for authentication, logging, rate limiting
- Understand the plug pipeline and optimize plug ordering
- Know when to use module plugs vs. function plugs

### Real-time Features
- Implement Phoenix Channels for WebSocket communication
- Design channel topics and events for scalability
- Use Phoenix.PubSub for inter-process communication
- Implement Presence tracking for user status and distributed state

### Views & Templates
- Write clean view modules with proper presentation logic separation
- Use Phoenix.HTML helpers and write custom helpers
- Understand the rendering pipeline and optimize templates

### Authentication & Security
- Implement Guardian for JWT tokens
- Implement Pow for session-based auth
- Secure APIs with token validation and refresh
- Handle CORS, CSRF protection, and web security concerns

### Integration Patterns
- File uploads with Arc or Waffle
- Email with Swoosh or Bamboo (templates and previews)
- Background jobs with Oban (error handling and retries)
- Phoenix metrics and dashboards for monitoring

### Testing
- Controller tests using Phoenix.ConnTest
- Channel tests with Phoenix.ChannelTest
- Test plugs in isolation and within the request pipeline

## Best Practices

1. Use pattern matching in controller actions for cleaner code
2. Implement proper error handling with clear HTTP status codes
3. Use changesets for parameter validation even in API contexts
4. Design channels with proper error handling and reconnection logic
5. Structure contexts to hide implementation details from web layer
6. Use action_fallback for consistent error responses in APIs
7. Implement proper CORS configuration for APIs
8. Use Phoenix.Token for secure, stateless token generation

## What This Reference Does NOT Cover

- LiveView implementation (see `liveview.md`)
- Ecto queries and schemas (see `ecto-database.md`)
- GraphQL with Absinthe (see `graphql-absinthe.md`)
- General Elixir/OTP concerns (see `otp-patterns.md`)

## Code Quality Standards

Write code that is:
- Idiomatic to Phoenix conventions
- Properly tested with appropriate test helpers
- Secure by default with proper authorization
- Performant with minimal database queries
- Well-structured following Phoenix architectural patterns

## When Providing Solutions

1. Understand the specific Phoenix feature or pattern needed
2. Provide idiomatic Phoenix code following framework conventions
3. Include proper error handling and edge cases
4. Suggest testing strategies for the implemented feature
5. Mention performance considerations when relevant
6. Reference Phoenix documentation for deeper understanding
