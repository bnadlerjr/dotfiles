# TypeScript Core Reference

Expert guidance for advanced TypeScript type systems, generics, and type-level programming.

## Quick Start

```typescript
// Generic function with constraints
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// Discriminated union for state
type AsyncState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

// Conditional type for inference
type Unwrap<T> = T extends Promise<infer U> ? U : T;
```

## Core Competencies

### Generics & Type Parameters
- Design generic functions that infer types correctly
- Apply constraints with `extends` to limit acceptable types
- Use default type parameters for better ergonomics
- Leverage `infer` for type extraction in conditional types

### Advanced Type Features
- Conditional types for type-level branching
- Mapped types for transforming object types
- Template literal types for string manipulation
- Discriminated unions for exhaustive pattern matching

### Type Inference
- Understand when to annotate vs. rely on inference
- Use `satisfies` operator for type checking without widening
- Leverage `const` assertions for literal types
- Design APIs that enable good inference

### Module & Declaration Management
- Write and maintain declaration files (.d.ts)
- Handle module augmentation for extending libraries
- Resolve type conflicts between packages
- Configure path aliases and module resolution

## TDD Phase Guidance

For general TDD phase definitions, see [SKILL.md](../SKILL.md#tdd-phase-awareness).

**TypeScript-specific guidance by phase:**

| Phase | Focus | Avoid |
|-------|-------|-------|
| RED | Simple types, test compiles | Complex generics, utility types |
| GREEN | Make types work, use `any` if blocked | Type perfection, over-constraining |
| REFACTOR | Proper generics, narrowing, inference | Over-engineering type utilities |

## Type Design Principles

### Make Illegal States Unrepresentable

```typescript
// Bad: allows invalid combinations
type User = {
  isLoggedIn: boolean;
  username?: string;  // Could be undefined when logged in
};

// Good: type enforces valid states
type User =
  | { isLoggedIn: false }
  | { isLoggedIn: true; username: string };
```

### Prefer Unions Over Enums

```typescript
// Prefer: better inference, tree-shakeable
type Status = 'pending' | 'approved' | 'rejected';

// Avoid: runtime overhead, less flexible
enum Status { Pending, Approved, Rejected }
```

### Use Type Narrowing

```typescript
function handleResult(result: AsyncState<User>) {
  switch (result.status) {
    case 'success':
      // TypeScript knows result.data exists
      return result.data.name;
    case 'error':
      // TypeScript knows result.error exists
      throw result.error;
  }
}
```

## Common Patterns

### Builder Pattern with Types

```typescript
class QueryBuilder<T extends object> {
  select<K extends keyof T>(...keys: K[]): QueryBuilder<Pick<T, K>> {
    // Implementation
    return this as any;
  }

  where<K extends keyof T>(key: K, value: T[K]): this {
    // Implementation
    return this;
  }
}
```

### Branded Types for Type Safety

```typescript
type UserId = string & { readonly brand: unique symbol };
type OrderId = string & { readonly brand: unique symbol };

function createUserId(id: string): UserId {
  return id as UserId;
}

// Prevents mixing up IDs
function getUser(id: UserId): User { /* ... */ }
getUser(orderId); // Error: OrderId not assignable to UserId
```

### Utility Type Composition

```typescript
// Extract only function properties
type Methods<T> = {
  [K in keyof T as T[K] extends Function ? K : never]: T[K];
};

// Make specific properties required
type RequireFields<T, K extends keyof T> = T & Required<Pick<T, K>>;
```

## Strict Mode Configuration

Recommended tsconfig.json settings:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noPropertyAccessFromIndexSignature": true,
    "exactOptionalPropertyTypes": true
  }
}
```

## Anti-Patterns to Prevent

- Using `any` as a permanent solution (use `unknown` and narrow)
- Overusing type assertions (`as`) instead of proper narrowing
- Creating overly complex conditional types that hurt inference
- Fighting structural typing instead of embracing it
- Using `!` non-null assertion instead of proper null checks

## What This Reference Does NOT Cover

- React-specific types (see `react-architecture.md`)
- GraphQL type generation (see `graphql-integration.md`)
- Test type patterns (see `testing-react.md`)

## Goal

Help developers leverage TypeScript's type system to catch errors at compile time while maintaining code that is readable and maintainable.
