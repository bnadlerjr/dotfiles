# GraphQL Integration Reference

Expert guidance for integrating GraphQL with TypeScript React applications using Apollo Client and code generation.

## Quick Start

```typescript
// Generated types from GraphQL codegen
import { useGetUserQuery, useUpdateUserMutation } from './generated/graphql';

function UserProfile({ userId }: { userId: string }) {
  const { data, loading, error } = useGetUserQuery({
    variables: { id: userId },
  });

  const [updateUser] = useUpdateUserMutation({
    optimisticResponse: {
      updateUser: {
        __typename: 'User',
        id: userId,
        name: 'Updating...',
      },
    },
  });

  if (loading) return <Spinner />;
  if (error) return <ErrorMessage error={error} />;

  return <UserCard user={data.user} onUpdate={updateUser} />;
}
```

## Core Competencies

### Apollo Client Setup
- Configure Apollo Client with proper cache settings
- Set up authentication with Apollo Link
- Handle errors globally with error link
- Configure request batching and deduplication

### Code Generation
- Set up GraphQL Code Generator for TypeScript
- Generate typed hooks for queries and mutations
- Configure fragment colocation patterns
- Maintain schema types in sync with backend

### Query Patterns
- Write efficient queries with proper field selection
- Implement fragment colocation for maintainability
- Use variables and directives effectively
- Handle pagination with cursor-based patterns

### Cache Management
- Understand Apollo's normalized cache
- Implement cache updates after mutations
- Use optimistic responses for instant UI feedback
- Configure fetch policies appropriately

## TDD Phase Guidance

For general TDD phase definitions, see [SKILL.md](../SKILL.md#tdd-phase-awareness).

**GraphQL-specific guidance by phase:**

| Phase | Focus | Avoid |
|-------|-------|-------|
| RED | Mock queries, test loading/error states | Complex cache scenarios |
| GREEN | Basic queries work, types compile | Optimistic updates, pagination |
| REFACTOR | Fragment colocation, cache optimization | Over-engineering cache policies |

## Apollo Client Configuration

### Basic Setup

```typescript
import { ApolloClient, InMemoryCache, createHttpLink } from '@apollo/client';
import { setContext } from '@apollo/client/link/context';

const httpLink = createHttpLink({
  uri: '/graphql',
});

const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('token');
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : '',
    },
  };
});

export const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache({
    typePolicies: {
      Query: {
        fields: {
          // Custom field policies
        },
      },
    },
  }),
});
```

### Error Handling Link

```typescript
import { onError } from '@apollo/client/link/error';

const errorLink = onError(({ graphQLErrors, networkError }) => {
  if (graphQLErrors) {
    graphQLErrors.forEach(({ message, locations, path }) => {
      console.error(`[GraphQL error]: ${message}`);
    });
  }
  if (networkError) {
    console.error(`[Network error]: ${networkError}`);
  }
});
```

## Code Generator Setup

### codegen.yml

```yaml
schema: 'http://localhost:4000/graphql'
documents: 'src/**/*.graphql'
generates:
  src/generated/graphql.tsx:
    plugins:
      - typescript
      - typescript-operations
      - typescript-react-apollo
    config:
      withHooks: true
      withComponent: false
      withHOC: false
```

### Fragment Colocation

```typescript
// UserCard.tsx
export const USER_CARD_FRAGMENT = gql`
  fragment UserCard on User {
    id
    name
    email
    avatar
  }
`;

// Parent query uses fragment
const GET_USER = gql`
  ${USER_CARD_FRAGMENT}
  query GetUser($id: ID!) {
    user(id: $id) {
      ...UserCard
    }
  }
`;
```

## Query Patterns

### Fetch Policies

| Policy | Use Case |
|--------|----------|
| `cache-first` | Default, good for static data |
| `network-only` | Always fresh data, skip cache |
| `cache-and-network` | Show cached, then update |
| `no-cache` | Never cache this query |

### Pagination

```typescript
function useUserList() {
  const { data, fetchMore, loading } = useUsersQuery({
    variables: { first: 10 },
  });

  const loadMore = () => {
    if (!data?.users.pageInfo.hasNextPage) return;

    fetchMore({
      variables: {
        after: data.users.pageInfo.endCursor,
      },
    });
  };

  return { users: data?.users.edges, loadMore, loading };
}
```

## Mutation Patterns

### Optimistic Updates

```typescript
const [addTodo] = useAddTodoMutation({
  optimisticResponse: {
    addTodo: {
      __typename: 'Todo',
      id: 'temp-id',
      text: newTodoText,
      completed: false,
    },
  },
  update(cache, { data }) {
    cache.modify({
      fields: {
        todos(existingTodos = []) {
          const newTodoRef = cache.writeFragment({
            data: data.addTodo,
            fragment: TODO_FRAGMENT,
          });
          return [...existingTodos, newTodoRef];
        },
      },
    });
  },
});
```

### Refetch Queries

```typescript
const [deleteTodo] = useDeleteTodoMutation({
  refetchQueries: [
    { query: GET_TODOS },
    'GetTodoCount', // Refetch by query name
  ],
  awaitRefetchQueries: true,
});
```

## Testing GraphQL

### Mock Provider Setup

```typescript
import { MockedProvider } from '@apollo/client/testing';

const mocks = [
  {
    request: {
      query: GET_USER,
      variables: { id: '1' },
    },
    result: {
      data: {
        user: { id: '1', name: 'Test User', email: 'test@example.com' },
      },
    },
  },
];

render(
  <MockedProvider mocks={mocks} addTypename={false}>
    <UserProfile userId="1" />
  </MockedProvider>
);
```

### Testing Loading and Error States

```typescript
it('shows loading state', () => {
  render(
    <MockedProvider mocks={mocks}>
      <UserProfile userId="1" />
    </MockedProvider>
  );

  expect(screen.getByRole('progressbar')).toBeInTheDocument();
});

it('shows error state', async () => {
  const errorMocks = [
    {
      request: { query: GET_USER, variables: { id: '1' } },
      error: new Error('Failed to fetch'),
    },
  ];

  render(
    <MockedProvider mocks={errorMocks}>
      <UserProfile userId="1" />
    </MockedProvider>
  );

  expect(await screen.findByRole('alert')).toBeInTheDocument();
});
```

## Anti-Patterns to Prevent

- Over-fetching by selecting all fields
- Not using fragments for component data needs
- Ignoring cache and always using `network-only`
- Not handling loading and error states
- Putting queries in components instead of colocating
- Manual cache updates when `refetchQueries` suffices

## What This Reference Does NOT Cover

- Backend GraphQL implementation
- Schema design principles
- Advanced Apollo features (subscriptions, local state)
- Non-Apollo alternatives (urql, relay)

## Goal

Help developers integrate GraphQL with type safety, efficient caching, and maintainable query patterns in TypeScript React applications.
