# Ecto Database Reference

Expert guidance for all aspects of data persistence and retrieval using Ecto in Elixir applications.

## Quick Start

```elixir
# Schema with changeset
defmodule MyApp.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    has_many :posts, MyApp.Post
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end

# Query with preload
Repo.all(from u in User, where: u.active, preload: [:posts])
```

## Core Expertise Areas

### Schema Design & Associations
- Normalized schemas with proper associations (belongs_to, has_many, has_one, many_to_many)
- Embedded schemas for nested data structures
- Schemaless queries for flexible data access
- Comprehensive changeset pipelines with validations and constraints
- Virtual fields for computed values
- Multi-tenancy patterns (prefix-based or foreign-key approaches)
- Polymorphic associations using discriminator columns or join tables

### Query Mastery
- Complex queries using Ecto's query DSL with joins, preloads, subqueries
- Window functions and Common Table Expressions (CTEs)
- Raw SQL fragments when Ecto's DSL isn't sufficient
- Dynamic queries based on runtime conditions with type safety
- Aggregations and grouping for performance
- Database-specific features (PostgreSQL arrays, JSONB, MySQL full-text search)

### Advanced Implementation Patterns
- Ecto.Multi for atomic transactions
- Optimistic locking for concurrent updates
- Soft delete systems with proper query scoping
- Audit trail solutions tracking data changes
- Migration strategies for schema evolution — see [safe-ecto-migrations](safe-ecto-migrations.md) for lock-safe patterns
- Connection pooling and repo configuration optimization

## Your Approach

1. Understand data relationships and access patterns first
2. Design schemas balancing normalization with query performance
3. Write queries that are efficient and maintainable
4. Consider database constraints and indexes
5. Provide migration code when schema changes are needed
6. Include comprehensive changeset validations for data integrity

## Key Principles

- Prioritize data integrity through proper constraints and validations
- Optimize for common query patterns while maintaining flexibility
- Use database features appropriately (don't reinvent what the database provides)
- Write queries that minimize N+1 problems through proper preloading
- Consider transaction boundaries and isolation levels
- Always validate data at the boundary (changesets) before persistence

## Output Guidelines

- Complete, working code examples with proper module structure
- Migration code when introducing schema changes
- Both schema definition and example usage
- Performance implications of different approaches
- Appropriate indexes for query optimization
- Error handling for database operations

## Common Patterns

### Changeset Pipelines

```elixir
def changeset(struct, attrs) do
  struct
  |> cast(attrs, [:field1, :field2])
  |> validate_required([:field1])
  |> validate_length(:field1, min: 3, max: 100)
  |> unique_constraint(:email)
  |> foreign_key_constraint(:user_id)
end
```

### Preloading Strategies

```elixir
# Avoid N+1 with preload
Repo.all(from p in Post, preload: [:author, :comments])

# Or explicit join for filtering
from p in Post,
  join: a in assoc(p, :author),
  where: a.active == true,
  preload: [author: a]
```

### Ecto.Multi for Transactions

```elixir
Multi.new()
|> Multi.insert(:user, User.changeset(%User{}, attrs))
|> Multi.insert(:profile, fn %{user: user} ->
  Profile.changeset(%Profile{user_id: user.id}, profile_attrs)
end)
|> Repo.transaction()
```

### Soft Deletes

```elixir
# Schema
field :deleted_at, :utc_datetime

# Query helper
def not_deleted(query) do
  from q in query, where: is_nil(q.deleted_at)
end

# Soft delete
def soft_delete(struct) do
  struct
  |> change(deleted_at: DateTime.utc_now())
  |> Repo.update()
end
```

## Performance Checklist

- [ ] Preload associations to avoid N+1 queries
- [ ] Add indexes for frequently queried columns
- [ ] Use `select` to limit columns when not all data is needed
- [ ] Consider pagination for large result sets
- [ ] Use database constraints over application-level validation where appropriate
- [ ] Profile queries with `Ecto.Adapters.SQL.explain/3`

## Focus Area

This reference focuses exclusively on the data layer: schemas, queries, changesets, and database operations. It does not cover web controllers, views, or Phoenix-specific concerns.
