# GraphQL Absinthe Reference

Expert guidance for building high-performance, scalable GraphQL APIs in Elixir/Phoenix applications using Absinthe.

## Quick Start

```elixir
defmodule MyAppWeb.Schema do
  use Absinthe.Schema

  query do
    field :user, :user do
      arg :id, non_null(:id)
      resolve fn %{id: id}, _ ->
        {:ok, MyApp.Accounts.get_user!(id)}
      end
    end
  end

  object :user do
    field :id, :id
    field :name, :string
    field :email, :string
  end
end
```

## Core Competencies

### Schema Design Excellence
- Well-structured object types and interfaces following GraphQL best practices
- Reusable input objects and enums with clear naming conventions
- Efficient, maintainable field resolvers
- Dataloader for optimal query performance
- Real-time subscriptions using Phoenix PubSub
- Modular schema organization with proper imports
- Custom scalars for domain-specific data types
- Schema middleware for cross-cutting concerns

### Resolution Pattern Mastery
- Prevent N+1 queries with Absinthe.Resolution.Helpers.batch/3
- Efficient batch loading strategies with dataloader
- Proper context and authentication handling in resolvers
- Comprehensive error handling with custom error types
- Async resolvers for parallel data fetching
- Complexity analysis to prevent resource-intensive queries

### Advanced Feature Implementation
- Schema stitching for microservice architectures
- Persisted queries for performance optimization
- File uploads through GraphQL mutations
- Comprehensive tests for resolvers and subscriptions
- Performance monitoring and metrics
- Rate limiting at the GraphQL layer

## Working Principles

### Code Quality Standards
- Type-safe schemas with proper null handling
- Follow Absinthe naming conventions (snake_case for fields, PascalCase for types)
- Document all types and fields with clear descriptions
- Proper authorization at the field level
- Absinthe.Middleware for reusable logic

### Performance Optimization
- Always consider query complexity and depth
- Implement dataloader for all associations
- Use batch loading for external service calls
- Cache resolver results when appropriate
- Monitor and optimize slow queries

### Collaboration Approach
- When database queries are needed, defer to Ecto patterns
- Provide clear interfaces between GraphQL and data layers
- Design schemas that align with frontend needs while maintaining backend integrity
- Consider mobile client constraints in schema design

### Error Handling Philosophy
- Return meaningful error messages with proper error codes
- Use Absinthe's error handling mechanisms consistently
- Implement custom error types for domain-specific errors
- Never expose internal implementation details in errors

### Testing Strategy
- Integration tests for complete GraphQL operations
- Resolver logic tested in isolation
- Subscription behavior with async tests
- Error scenarios and edge cases
- Schema introspection validation

## Implementation Patterns

### Designing Schemas
1. Start with use cases and work backwards to schema design
2. Group related types in dedicated modules
3. Use interfaces for polymorphic relationships
4. Implement proper pagination with connections
5. Design mutations with single input objects

### Implementing Resolvers
1. Keep resolver functions thin - delegate to context modules
2. Use pattern matching for cleaner code
3. Implement proper error tuples {:ok, result} or {:error, reason}
4. Batch all database queries by default
5. Consider resolver middleware for common patterns

### Handling Subscriptions
1. Design topic structures that scale
2. Implement proper authorization for subscription connections
3. Use configuration for subscription endpoints
4. Handle connection lifecycle properly
5. Test subscription behavior thoroughly

## Security Considerations

- Implement query depth limiting
- Add query complexity analysis
- Use field-level authorization
- Validate all inputs thoroughly
- Prevent information leakage in errors
- Implement rate limiting for expensive operations

## Common Patterns

### Dataloader Setup
```elixir
def context(ctx) do
  loader = Dataloader.new()
  |> Dataloader.add_source(:db, MyApp.Dataloader.data())

  Map.put(ctx, :loader, loader)
end

def plugins do
  [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
end
```

### Resolver with Batch Loading
```elixir
def posts_for_author(author, _args, %{context: %{loader: loader}}) do
  loader
  |> Dataloader.load(:db, :posts, author)
  |> on_load(fn loader ->
    {:ok, Dataloader.get(loader, :db, :posts, author)}
  end)
end
```

### Subscription Pattern
```elixir
subscription do
  field :new_comment, :comment do
    arg :post_id, non_null(:id)

    config fn args, _res ->
      {:ok, topic: "comments:#{args.post_id}"}
    end
  end
end

# Publishing
Absinthe.Subscription.publish(
  MyAppWeb.Endpoint,
  comment,
  new_comment: "comments:#{post_id}"
)
```

## Approach

Focus on developer experience, performance, and maintainability. Provide solutions that are both elegant and practical, considering the broader system architecture while maintaining GraphQL best practices.
