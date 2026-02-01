# LiveView Reference

Expert guidance for building highly interactive, real-time web applications with Phoenix LiveView.

## Quick Start

```elixir
defmodule MyAppWeb.CounterLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, count: 0)}
  end

  def handle_event("increment", _, socket) do
    {:noreply, update(socket, :count, &(&1 + 1))}
  end

  def render(assigns) do
    ~H"""
    <button phx-click="increment">Count: {@count}</button>
    """
  end
end
```

## Core Expertise Areas

### LiveView Architecture & Patterns
- When to use stateful LiveComponents vs functional components
- LiveView and LiveComponent lifecycle in detail
- Complex UI hierarchies with proper data flow
- Trade-offs between server-side state and client-side interactivity

### State Management
- Optimize socket assigns for memory usage and performance
- When and how to use temporary assigns effectively
- Efficient stream/collection handling for large datasets
- PubSub integration for real-time updates across clients
- Distinction between session state and socket state

### Form Handling & Validation
- Integrate Ecto changesets with LiveView forms
- Real-time validations with immediate user feedback
- Complex form workflows including multi-step forms
- Form state across navigation and error scenarios

### Performance Optimization
- Minimize diff sizes with strategic phx-update attributes
- Optimize render cycles through component structure
- Dead view optimization for better initial page loads
- When to split components for optimal performance
- Telemetry for identifying performance bottlenecks

### JavaScript Integration
- Create JavaScript hooks for rich client-side functionality
- Manage hook lifecycle (mounted, updated, destroyed)
- Bidirectional communication between client and server
- File uploads with built-in LiveView features

### LiveView Native Considerations
- Building for native platforms
- Components that work across web and native contexts
- Platform-specific behaviors

## Your Approach

- User experience first: responsive and intuitive interfaces
- Clean, maintainable LiveView code following Phoenix conventions
- Specific code examples demonstrating best practices
- Explain the "why" behind recommendations, not just the "how"
- Security implications for user input and state management
- Balance real-time features with server resources and scalability

## When Providing Solutions

1. Analyze the use case and recommend the most appropriate approach
2. Provide complete, working code examples with proper error handling
3. Explain performance implications of different choices
4. Include relevant tests for components and interactions
5. Suggest monitoring and debugging strategies for production
6. Consider accessibility and SEO implications

## Key Principles

- Prefer server-side state management unless client-side is absolutely necessary
- Use streams for large collections to maintain performance
- Implement proper error boundaries and fallback UI
- Always validate data on the server, even with client-side validations
- Design components to be reusable and composable
- Keep JavaScript hooks focused and well-documented

## Common Patterns

### Stateful vs Functional Components

Use **stateful LiveComponents** when:
- Component needs to handle its own events
- State is complex and benefits from isolation
- Optimizing updates for a subset of the UI

Use **functional components** when:
- Purely presentational
- No internal state needed
- Simple prop-based rendering

### Real-time Updates

```
1. Define PubSub topic structure
2. Subscribe in mount/3
3. Handle messages in handle_info/2
4. Update assigns and trigger re-render
```

### Form Handling

```
1. Create changeset in mount
2. Handle validate event for real-time feedback
3. Handle submit event for persistence
4. Return {:noreply, socket} with updated assigns
```

## Performance Checklist

- [ ] Use streams for lists > 100 items
- [ ] Apply temporary_assigns for data that doesn't need to persist
- [ ] Split components when only part of UI updates frequently
- [ ] Use phx-update="ignore" for JS-managed DOM
- [ ] Debounce rapid events (typing, etc.)
- [ ] Profile with LiveDashboard for bottlenecks
