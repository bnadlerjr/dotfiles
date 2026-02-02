---
name: developing-typescript
description: |
  Comprehensive TypeScript/React development expertise covering advanced type systems, React component architecture, hooks patterns, state management, GraphQL integration with Apollo, performance optimization, and React Testing Library.

  Use when working with .ts/.tsx files, React components, or when the user mentions TypeScript, React, hooks, Context, Apollo, GraphQL codegen, React Testing Library, Vite, or Next.js. Also use for generic types, component patterns, or bundle optimization.
---

# Developing TypeScript

Expert guidance for building robust, type-safe TypeScript and React applications.

## Quick Start

For immediate help, identify your task type and consult the relevant reference:

| Working On | Reference File | Key Topics |
|------------|----------------|------------|
| Generics, conditional types, inference | [typescript-core](references/typescript-core.md) | Type system, utility types, declarations |
| Components, hooks, state management | [react-architecture](references/react-architecture.md) | Composition, Context, reducers |
| React 19, Server Components, Actions | [react-19-patterns](references/react-19-patterns.md) | ref as prop, useActionState, use(), Server Actions |
| Apollo Client, codegen, type safety | [graphql-integration](references/graphql-integration.md) | Queries, mutations, cache |
| React Testing Library, integration tests | [testing-react](references/testing-react.md) | User behavior testing, async |
| Bundle size, memoization, Core Web Vitals | [performance-optimization](references/performance-optimization.md) | Code splitting, profiling |

## TDD Phase Awareness

All guidance in this skill is phase-aware. Identify your current phase:

### RED Phase (Writing Failing Tests)
- Write the smallest test that captures intent
- Use concrete values directly in tests
- Focus on user behavior, not implementation
- Skip edge cases and complex mocking initially

### GREEN Phase (Making Tests Pass)
- RESIST over-engineering at all costs
- Start with simple implementations
- Use `any` temporarily if types block progress
- Focus only on making the current test pass

### REFACTOR Phase (Improving Design)
- NOW apply proper type constraints
- Extract custom hooks from components
- Add comprehensive type definitions
- Improve component composition patterns

## Cross-Cutting Principles

These principles apply across all TypeScript/React development:

### Type Safety First
1. Prefer compile-time errors over runtime errors
2. Use strict mode and appropriate compiler options
3. Leverage type inference where it improves readability
4. Create discriminated unions for state management

### Component Architecture
1. Prefer composition over prop drilling
2. Keep components focused on single responsibilities
3. Use custom hooks to extract reusable logic
4. Push side effects to dedicated hooks or boundaries

### Testing Philosophy
- Test user behavior, not implementation details
- Write tests that can fail for real defects
- Avoid over-mocking; prefer integration tests
- Use React Testing Library queries by accessibility

### Performance Mindset
- Measure before optimizing
- Understand React's rendering model
- Use memoization strategically, not reflexively
- Consider bundle size for every dependency

## Examples

**Creating a type-safe form component:**
```
User: "I need a reusable form that handles different data types"
→ Consult typescript-core.md for generics, react-architecture.md for patterns
```

**Optimizing re-renders:**
```
User: "My component re-renders too often"
→ Consult performance-optimization.md for profiling and memoization strategies
```

**Setting up GraphQL with type safety:**
```
User: "Integrate Apollo Client with TypeScript codegen"
→ Consult graphql-integration.md for setup and patterns
```

**Writing component tests:**
```
User: "Test this form submission flow"
→ Consult testing-react.md for user behavior testing patterns
```

## Anti-Patterns to Avoid

### Premature Abstraction
- Creating generic components before you have 3 similar cases
- Building complex type utilities for one-off uses
- Over-engineering state management with Context
- Adding dependency injection patterns unnecessarily

### Type System Misuse
- Using `any` to silence errors instead of fixing types
- Over-constraining types that limit legitimate use cases
- Creating deep type hierarchies that confuse inference
- Ignoring TypeScript's structural typing strengths

### Testing Anti-Patterns
- Testing implementation details
- Over-mocking to the point tests don't catch real bugs
- Testing React internals instead of user outcomes
- Creating elaborate test utilities prematurely

### Performance Anti-Patterns
- Premature memoization without measurement
- useCallback/useMemo on every function/value
- Splitting code before you have bundle size problems
- Optimizing renders that aren't causing issues

## Reference File IDs

For programmatic access (e.g., parallel reviews), use these identifiers:

`typescript-core` · `react-architecture` · `react-19-patterns` · `graphql-integration` · `testing-react` · `performance-optimization`
