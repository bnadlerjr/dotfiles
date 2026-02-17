---
name: testing-react-with-vitest
description: |
  Expert guidance for writing Vitest tests for React applications using React Testing Library.
  Covers component tests, custom hooks, utility tests, sociable testing philosophy, and the
  RTL query priority system. Favors sociable tests over heavy mocking, stubs over mocks.

  Use when working with .test.ts/.test.tsx files, vitest.config.ts, React Testing Library,
  @testing-library/user-event, @testing-library/jest-dom, renderHook, or when discussing
  React testing patterns, component testing, hook testing, or test organization.
---

# Testing React with Vitest

Expert guidance for writing great Vitest tests for React applications using React Testing Library.

## Quick Start

| Testing... | Reference File | Key Topics |
|------------|----------------|------------|
| Core Vitest setup, matchers, spies | [core-vitest](references/core-vitest.md) | describe, it, expect, vi.fn, vi.mock, timers |
| RTL queries, render, screen | [react-testing-library](references/react-testing-library.md) | render, screen, queries, waitFor, debug |
| User interactions | [user-event](references/user-event.md) | setup, click, type, keyboard, async events |
| Sociable tests, stubs, boundaries | [sociable-testing](references/sociable-testing.md) | Real components, stub boundaries, functional core |
| Custom hooks with renderHook | [custom-hooks](references/custom-hooks.md) | renderHook, act, providers, cleanup |
| Component testing patterns | [component-patterns](references/component-patterns.md) | Forms, modals, lists, error boundaries, a11y |
| jest-dom assertion matchers | [assertions](references/assertions.md) | toBeInTheDocument, toBeVisible, toHaveTextContent |

## Testing Philosophy

These principles are non-negotiable defaults for all React testing advice.

### Sociable Tests by Default

Use real child components. A test for `<CheckoutPage />` should render real `<CartSummary />` and `<PaymentForm />` components, not mocked replacements. Sociable tests catch integration bugs, survive refactors, and test actual behavior.

### Stubs Over Mocks

When you must replace a dependency, prefer stubs that return canned data over mocks that verify call sequences. A stubbed `fetch` that returns `{ items: [] }` is better than a mock that asserts `fetch` was called with specific arguments.

### Test Behavior, Not Implementation

Assert on what the user sees and can do. Never assert on internal state, hook return values observed from outside, or component instance methods. If a user cannot observe it, do not test it.

### Only Stub at True System Boundaries

Real boundaries: `fetch`/HTTP clients, browser APIs (`localStorage`, `navigator`, `IntersectionObserver`), third-party services, timers. Not boundaries: your own components, hooks, utilities, or context providers.

### Query Priority: role > label > text > testid

Prefer accessible queries. `getByRole('button', { name: 'Submit' })` is better than `getByTestId('submit-btn')`. Test IDs are a last resort when no accessible query works.

## Anti-Patterns

- **Mocking child components**: `vi.mock('./CartSummary')` hides integration bugs. Render real children unless they hit a system boundary.
- **Testing implementation details**: `expect(setState).toHaveBeenCalledWith(...)` couples tests to internals. Assert on rendered output instead.
- **Snapshot overuse**: Large snapshots break on every change and nobody reads the diffs. Prefer targeted assertions on specific elements.
- **Using `container.querySelector`**: Bypasses the accessibility-first query model. Use `screen.getByRole`, `screen.getByLabelText`, or `screen.getByText` instead.
- **Wrapping every action in `act()`**: RTL's `render`, `fireEvent`, and `user-event` already wrap in `act()`. Manual `act()` is only needed for direct state updates outside RTL.
- **Testing CSS classes or inline styles**: These are implementation details. Use `toBeVisible()`, `toHaveAccessibleName()`, or test the behavior the style enables.
- **Mocking your own hooks**: `vi.mock('./useCart')` tests the component in isolation from its real logic. Let the component use its real hooks.
- **`getByTestId` as a first choice**: Always try `getByRole`, `getByLabelText`, `getByText`, `getByPlaceholderText` first. Test IDs are a last resort.

## Reference File IDs

`core-vitest` . `react-testing-library` . `user-event` . `sociable-testing` . `custom-hooks` . `component-patterns` . `assertions`
