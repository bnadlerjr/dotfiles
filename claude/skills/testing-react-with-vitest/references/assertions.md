# jest-dom Assertion Matchers

Custom matchers from `@testing-library/jest-dom` for asserting on DOM elements. These extend Vitest's `expect` with DOM-specific assertions.

## Setup

```typescript
// src/test/setup.ts
import '@testing-library/jest-dom/vitest';
```

This registers all matchers with Vitest's `expect`. Import once in your setup file.

## Presence and Visibility

### toBeInTheDocument

Asserts the element exists in the document.

```typescript
expect(screen.getByRole('button', { name: 'Submit' })).toBeInTheDocument();

// Assert absence (use queryBy* which returns null instead of throwing)
expect(screen.queryByRole('alert')).not.toBeInTheDocument();
```

### toBeVisible

Asserts the element is visible to the user. Checks CSS `display`, `visibility`, `opacity`, and whether parent elements are hidden.

```typescript
expect(screen.getByRole('dialog')).toBeVisible();

// Hidden element (e.g., display: none)
expect(screen.queryByRole('tooltip')).not.toBeVisible();
```

`toBeVisible` is stricter than `toBeInTheDocument`. An element can be in the document but not visible (e.g., `display: none`).

### toBeEmptyDOMElement

Asserts the element has no visible content (no text, no child elements).

```typescript
expect(screen.getByRole('status')).toBeEmptyDOMElement();
```

## Form Element State

### toBeDisabled / toBeEnabled

```typescript
expect(screen.getByRole('button', { name: 'Submit' })).toBeDisabled();
expect(screen.getByRole('button', { name: 'Cancel' })).toBeEnabled();

// Also works for fieldset, input, select, textarea, button
expect(screen.getByLabelText('Email')).toBeDisabled();
```

### toBeRequired

Asserts the element has `required` or `aria-required="true"`.

```typescript
expect(screen.getByLabelText('Email address')).toBeRequired();
expect(screen.getByLabelText('Phone (optional)')).not.toBeRequired();
```

### toBeValid / toBeInvalid

Asserts form element validity based on HTML5 constraint validation or `aria-invalid`.

```typescript
// Valid input
await user.type(screen.getByLabelText('Email'), 'alice@example.com');
expect(screen.getByLabelText('Email')).toBeValid();

// Invalid input (e.g., type="email" with bad value)
await user.type(screen.getByLabelText('Email'), 'not-an-email');
expect(screen.getByLabelText('Email')).toBeInvalid();
```

### toBeChecked

Asserts a checkbox or radio button is checked.

```typescript
expect(screen.getByRole('checkbox', { name: 'Remember me' })).toBeChecked();
expect(screen.getByRole('checkbox', { name: 'Newsletter' })).not.toBeChecked();

// Radio buttons
expect(screen.getByRole('radio', { name: 'Monthly' })).toBeChecked();
expect(screen.getByRole('radio', { name: 'Annual' })).not.toBeChecked();
```

Also works with elements that have `role="checkbox"` or `role="radio"` with `aria-checked`.

### toBePartiallyChecked

For indeterminate checkboxes (parent checkbox when some children are checked).

```typescript
expect(screen.getByRole('checkbox', { name: 'Select all' })).toBePartiallyChecked();
```

### toHaveValue

Asserts the current value of a form element (`input`, `textarea`, `select`).

```typescript
expect(screen.getByLabelText('Email')).toHaveValue('alice@example.com');
expect(screen.getByLabelText('Country')).toHaveValue('US');
expect(screen.getByLabelText('Message')).toHaveValue('Hello, world');

// Empty value
expect(screen.getByLabelText('Search')).toHaveValue('');
```

### toHaveDisplayValue

Asserts the visible displayed value (what the user sees), which may differ from the form value for `<select>` elements.

```typescript
// <select> shows option text, not value
expect(screen.getByRole('combobox', { name: 'Country' })).toHaveDisplayValue('United States');

// Multiple select
expect(screen.getByRole('listbox')).toHaveDisplayValue(['Apple', 'Banana']);
```

### toHaveFormValues

Asserts on the entire form's values at once.

```typescript
expect(screen.getByRole('form', { name: 'Registration' })).toHaveFormValues({
  name: 'Alice',
  email: 'alice@example.com',
  country: 'US',
  newsletter: true,
});
```

## Text Content

### toHaveTextContent

Asserts an element contains the specified text.

```typescript
expect(screen.getByRole('heading')).toHaveTextContent('Welcome, Alice');
expect(screen.getByRole('status')).toHaveTextContent('3 items in cart');

// Regex matching
expect(screen.getByRole('heading')).toHaveTextContent(/welcome/i);

// Exact match (normalizes whitespace by default)
expect(screen.getByRole('paragraph')).toHaveTextContent('Hello world');
```

## Focus

### toHaveFocus

Asserts the element currently has focus.

```typescript
await user.tab();
expect(screen.getByLabelText('Email')).toHaveFocus();

await user.tab();
expect(screen.getByLabelText('Password')).toHaveFocus();
```

## HTML Attributes

### toHaveAttribute

Asserts the element has a specific HTML attribute with an optional value.

```typescript
// Has attribute with value
expect(screen.getByRole('link', { name: 'Docs' })).toHaveAttribute('href', '/docs');
expect(screen.getByRole('img')).toHaveAttribute('alt', 'Company logo');

// Has attribute (any value)
expect(screen.getByRole('link', { name: 'External' })).toHaveAttribute('target');

// Attribute with specific value
expect(screen.getByRole('link', { name: 'External' })).toHaveAttribute('target', '_blank');
expect(screen.getByRole('link', { name: 'External' })).toHaveAttribute('rel', 'noopener noreferrer');
```

### toHaveClass

Asserts the element has the specified CSS class(es).

```typescript
expect(screen.getByRole('button')).toHaveClass('primary');
expect(screen.getByRole('button')).toHaveClass('primary', 'large');

// Exact match (no extra classes allowed)
expect(screen.getByRole('button')).toHaveClass('primary large', { exact: true });
```

Use sparingly. Prefer asserting on behavior or accessible properties over CSS classes.

### toHaveStyle

Asserts the element has specific inline styles or computed styles.

```typescript
expect(screen.getByText('Error')).toHaveStyle({ color: 'red' });
expect(screen.getByTestId('sidebar')).toHaveStyle({ display: 'none' });

// String syntax
expect(screen.getByText('Error')).toHaveStyle('color: red');
```

Use sparingly. Prefer `toBeVisible()` over `toHaveStyle({ display: 'none' })`. Prefer semantic assertions over style assertions.

## Accessibility

### toHaveAccessibleName

Asserts the element's accessible name (computed from `aria-label`, `aria-labelledby`, visible text, or `<label>`).

```typescript
expect(screen.getByRole('button')).toHaveAccessibleName('Submit Order');
expect(screen.getByRole('textbox')).toHaveAccessibleName('Email address');
expect(screen.getByRole('navigation')).toHaveAccessibleName('Main navigation');
```

### toHaveAccessibleDescription

Asserts the element's accessible description (from `aria-describedby`).

```typescript
expect(screen.getByLabelText('Password')).toHaveAccessibleDescription(
  'Must be at least 8 characters with one uppercase letter'
);

// After validation error
expect(screen.getByLabelText('Email')).toHaveAccessibleDescription('Please enter a valid email');
```

### toHaveAccessibleErrorMessage

Asserts the element's accessible error message (from `aria-errormessage`).

```typescript
expect(screen.getByLabelText('Email')).toHaveAccessibleErrorMessage('Email is required');
```

Requires the element to have `aria-invalid="true"` and an `aria-errormessage` attribute pointing to the error element.

### toHaveRole

Asserts the element has the specified ARIA role.

```typescript
expect(screen.getByText('Click me')).toHaveRole('button');
expect(screen.getByText('Important notice')).toHaveRole('alert');
```

## Containment

### toContainElement

Asserts a DOM element contains another DOM element.

```typescript
const list = screen.getByRole('list');
const item = screen.getByText('First item');
expect(list).toContainElement(item);
```

### toContainHTML

Asserts the element contains specific HTML markup. Use sparingly -- prefer semantic queries.

```typescript
expect(screen.getByTestId('rich-text')).toContainHTML('<strong>bold</strong>');
```

## Choosing the Right Matcher

| Want to Assert... | Use |
|---|---|
| Element exists | `toBeInTheDocument()` |
| Element is visible to users | `toBeVisible()` |
| Element is absent | `not.toBeInTheDocument()` (with `queryBy*`) |
| Button is disabled | `toBeDisabled()` |
| Input has a value | `toHaveValue('...')` |
| Checkbox is checked | `toBeChecked()` |
| Text is displayed | `toHaveTextContent('...')` |
| Element has focus | `toHaveFocus()` |
| Link points somewhere | `toHaveAttribute('href', '...')` |
| Form field is required | `toBeRequired()` |
| Input passes validation | `toBeValid()` / `toBeInvalid()` |
| Screen reader label | `toHaveAccessibleName('...')` |
| Screen reader description | `toHaveAccessibleDescription('...')` |
| Validation error for assistive tech | `toHaveAccessibleErrorMessage('...')` |

## Anti-Patterns

**Using toBeTruthy/toBeFalsy for DOM assertions:**
```typescript
// Bad: vague, no semantic meaning
expect(screen.queryByRole('alert')).toBeFalsy();
```
Instead, use `expect(screen.queryByRole('alert')).not.toBeInTheDocument()`. The matcher name communicates intent.

**Checking style when a semantic matcher exists:**
```typescript
// Bad: testing implementation detail
expect(element).toHaveStyle({ display: 'none' });
```
Instead, use `expect(element).not.toBeVisible()`.

**Using toHaveClass for behavior assertions:**
```typescript
// Bad: CSS class is an implementation detail
expect(button).toHaveClass('is-loading');
```
Instead, test the behavior: `expect(button).toBeDisabled()` or `expect(screen.getByRole('progressbar')).toBeInTheDocument()`.

**Checking innerHTML instead of accessible content:**
```typescript
// Bad: brittle, depends on exact markup
expect(container.innerHTML).toContain('Welcome');
```
Instead, use `expect(screen.getByText('Welcome')).toBeInTheDocument()` or `expect(element).toHaveTextContent('Welcome')`.
