# User Event

`@testing-library/user-event` simulates real user interactions. It fires the full sequence of browser events that a real user would trigger, unlike `fireEvent` which dispatches a single synthetic event.

## Setup

Always call `userEvent.setup()` before interacting. This creates a user-event instance with proper internal state tracking (keyboard modifiers, pointer position, etc.).

```typescript
import userEvent from '@testing-library/user-event';

it('submits the form', async () => {
  const user = userEvent.setup();
  render(<LoginForm />);

  await user.type(screen.getByLabelText('Email'), 'alice@example.com');
  await user.type(screen.getByLabelText('Password'), 'secret123');
  await user.click(screen.getByRole('button', { name: 'Sign in' }));

  expect(await screen.findByText('Welcome, Alice')).toBeInTheDocument();
});
```

### Setup Options

```typescript
// With fake timers (required when using vi.useFakeTimers())
const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });

// Custom delay between keystrokes (default: 0 in test environment)
const user = userEvent.setup({ delay: null });

// Skip pointer events validation (for elements that CSS hides from pointer)
const user = userEvent.setup({ pointerEventsCheck: 0 });
```

## Why user-event Over fireEvent

`fireEvent` dispatches a single DOM event. `user-event` simulates the full browser event sequence:

| Action | fireEvent | user-event |
|--------|-----------|------------|
| Click | `click` only | `pointerdown` -> `mousedown` -> `pointerup` -> `mouseup` -> `click` |
| Type "ab" | Two `change` events | `keydown` -> `keypress` -> `input` -> `keyup` (per key) |
| Tab | Nothing built-in | `keydown(Tab)` -> `focusout` -> `blur` -> `focusin` -> `focus` -> `keyup(Tab)` |

This matters because components often listen to intermediate events (e.g., `onKeyDown` for keyboard shortcuts, `onBlur` for validation).

```typescript
// Bad: fireEvent skips the full event sequence
fireEvent.change(input, { target: { value: 'hello' } });

// Good: user-event fires realistic events
await user.type(input, 'hello');
```

Use `fireEvent` only for events that `user-event` does not support, or for low-level testing of specific event handlers.

## All Interactions Are Async

Since `user-event` v14, all interaction methods return promises. Always `await` them.

```typescript
// Correct
await user.click(button);
await user.type(input, 'hello');

// Wrong: missing await causes race conditions
user.click(button);        // Promise ignored
user.type(input, 'hello'); // Runs before click finishes
```

## Click Interactions

### click

```typescript
await user.click(screen.getByRole('button', { name: 'Save' }));
```

### dblClick

```typescript
await user.dblClick(screen.getByText('Editable text'));

expect(screen.getByRole('textbox')).toBeInTheDocument();
```

### tripleClick

Selects an entire line of text (useful for select-and-replace patterns).

```typescript
await user.tripleClick(screen.getByRole('textbox'));
```

## Typing

### type

Types text character by character, firing the full keydown/keypress/input/keyup sequence per keystroke.

```typescript
await user.type(screen.getByLabelText('Name'), 'Alice Johnson');
expect(screen.getByLabelText('Name')).toHaveValue('Alice Johnson');
```

### Special Keys in type

Wrap special keys in braces:

```typescript
await user.type(input, 'Hello{Enter}');        // Types "Hello" then presses Enter
await user.type(input, '{Backspace}{Backspace}'); // Two backspaces
await user.type(input, '{selectall}{del}');     // Select all, then delete
```

### clear

Clears an input field (selects all text, then deletes it).

```typescript
await user.clear(screen.getByLabelText('Search'));
expect(screen.getByLabelText('Search')).toHaveValue('');
```

### Typing into an already-populated field

`type` appends to existing value. To replace:

```typescript
const input = screen.getByLabelText('Name');
await user.clear(input);
await user.type(input, 'New value');
```

## Keyboard

### keyboard

Low-level keyboard simulation for key combinations and shortcuts.

```typescript
// Ctrl+A to select all
await user.keyboard('{Control>}a{/Control}');

// Shift+Tab to navigate backwards
await user.keyboard('{Shift>}{Tab}{/Shift}');

// Type a key sequence
await user.keyboard('abc');

// Press Escape
await user.keyboard('{Escape}');
```

The `>` suffix holds the key down. `/KeyName` releases it.

### tab

Navigate focus between elements.

```typescript
await user.tab();  // Move focus to next focusable element

expect(screen.getByLabelText('Email')).toHaveFocus();

await user.tab();
expect(screen.getByLabelText('Password')).toHaveFocus();

// Shift+Tab to go backwards
await user.tab({ shift: true });
expect(screen.getByLabelText('Email')).toHaveFocus();
```

## Selection

### selectOptions

Select one or more options in a `<select>` element or listbox.

```typescript
// Single select
await user.selectOptions(
  screen.getByRole('combobox', { name: 'Country' }),
  'US'
);
expect(screen.getByRole('combobox', { name: 'Country' })).toHaveValue('US');

// Multi-select
await user.selectOptions(
  screen.getByRole('listbox', { name: 'Toppings' }),
  ['cheese', 'pepperoni']
);

// Select by visible text
await user.selectOptions(
  screen.getByRole('combobox', { name: 'Country' }),
  screen.getByRole('option', { name: 'United States' })
);
```

### deselectOptions

Deselect options in a multi-select.

```typescript
await user.deselectOptions(
  screen.getByRole('listbox', { name: 'Toppings' }),
  ['pepperoni']
);
```

## File Upload

### upload

```typescript
it('uploads a profile picture', async () => {
  const user = userEvent.setup();
  const file = new File(['avatar'], 'avatar.png', { type: 'image/png' });

  render(<ProfileSettings />);

  const input = screen.getByLabelText('Profile picture');
  await user.upload(input, file);

  expect(input.files).toHaveLength(1);
  expect(input.files![0].name).toBe('avatar.png');
});
```

### Multiple files

```typescript
const files = [
  new File(['doc1'], 'report.pdf', { type: 'application/pdf' }),
  new File(['doc2'], 'invoice.pdf', { type: 'application/pdf' }),
];
await user.upload(input, files);
expect(input.files).toHaveLength(2);
```

## Hover

### hover / unhover

```typescript
it('shows tooltip on hover', async () => {
  const user = userEvent.setup();
  render(<IconButton icon="help" tooltip="Get help" />);

  await user.hover(screen.getByRole('button'));
  expect(screen.getByRole('tooltip')).toHaveTextContent('Get help');

  await user.unhover(screen.getByRole('button'));
  expect(screen.queryByRole('tooltip')).not.toBeInTheDocument();
});
```

## Pointer

Low-level pointer events for drag-and-drop or custom pointer interactions.

```typescript
await user.pointer([
  { target: element, keys: '[MouseLeft>]' },   // mousedown
  { target: dropZone },                         // mousemove to target
  { keys: '[/MouseLeft]' },                     // mouseup
]);
```

For most tests, `click`, `dblClick`, and `hover` are sufficient. Use `pointer` only for drag-and-drop or complex multi-step pointer sequences.

## Paste

### paste

```typescript
it('handles pasted content', async () => {
  const user = userEvent.setup();
  render(<TagInput />);

  const input = screen.getByRole('textbox');
  await user.click(input);
  await user.paste('tag1, tag2, tag3');

  expect(screen.getByText('tag1')).toBeInTheDocument();
  expect(screen.getByText('tag2')).toBeInTheDocument();
  expect(screen.getByText('tag3')).toBeInTheDocument();
});
```

## Clipboard

### copy / cut

```typescript
// Select text and copy
await user.tripleClick(screen.getByText('Copy this text'));
await user.copy();

// Or cut
await user.tripleClick(screen.getByText('Cut this text'));
await user.cut();
```

## Common Patterns

### Form Submission

```typescript
it('submits a complete form', async () => {
  const handleSubmit = vi.fn();
  const user = userEvent.setup();
  render(<RegistrationForm onSubmit={handleSubmit} />);

  await user.type(screen.getByLabelText('Full name'), 'Alice Johnson');
  await user.type(screen.getByLabelText('Email'), 'alice@example.com');
  await user.type(screen.getByLabelText('Password'), 'Str0ng!Pass');
  await user.selectOptions(screen.getByRole('combobox', { name: 'Country' }), 'US');
  await user.click(screen.getByRole('checkbox', { name: /terms/i }));
  await user.click(screen.getByRole('button', { name: 'Register' }));

  expect(handleSubmit).toHaveBeenCalledWith(
    expect.objectContaining({
      name: 'Alice Johnson',
      email: 'alice@example.com',
      country: 'US',
    })
  );
});
```

### Keyboard Navigation

```typescript
it('navigates dropdown with keyboard', async () => {
  const user = userEvent.setup();
  render(<Dropdown options={['Apple', 'Banana', 'Cherry']} />);

  await user.click(screen.getByRole('combobox'));
  await user.keyboard('{ArrowDown}');
  await user.keyboard('{ArrowDown}');
  await user.keyboard('{Enter}');

  expect(screen.getByRole('combobox')).toHaveTextContent('Banana');
});
```

### Search with Debounce

```typescript
it('searches after user stops typing', async () => {
  vi.useFakeTimers();
  const user = userEvent.setup({ advanceTimers: vi.advanceTimersByTime });
  render(<SearchBar />);

  await user.type(screen.getByRole('searchbox'), 'react testing');

  // Results don't appear during debounce period
  expect(screen.queryByRole('listbox')).not.toBeInTheDocument();

  // Advance past debounce delay
  vi.advanceTimersByTime(300);

  expect(await screen.findByRole('listbox')).toBeInTheDocument();

  vi.useRealTimers();
});
```

## Anti-Patterns

**Using fireEvent when user-event works:**
```typescript
// Bad: single synthetic event, skips the real event sequence
fireEvent.click(button);
fireEvent.change(input, { target: { value: 'hello' } });
```
Instead, use `await user.click(button)` and `await user.type(input, 'hello')`.

**Forgetting to await:**
```typescript
// Bad: race condition -- assertion runs before interaction completes
user.click(button);
expect(screen.getByText('Done')).toBeInTheDocument();
```
Instead, `await user.click(button)`.

**Creating user-event instance inside the test body without setup:**
```typescript
// Bad: missing setup, no state tracking
await userEvent.click(button);
```
Instead, `const user = userEvent.setup()` at the start of each test.

**Not configuring advanceTimers with fake timers:**
```typescript
// Bad: user-event hangs because internal delays never resolve
vi.useFakeTimers();
const user = userEvent.setup();  // Missing advanceTimers option
await user.type(input, 'hello'); // Hangs
```
Instead, `userEvent.setup({ advanceTimers: vi.advanceTimersByTime })`.
