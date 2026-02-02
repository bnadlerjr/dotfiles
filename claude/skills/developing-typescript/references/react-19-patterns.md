# React 19 Patterns Reference

Type-safe patterns for React 19 features including Server Components, Server Actions, and new hooks.

## Quick Start

```typescript
// React 19: ref is now a regular prop
type ButtonProps = {
  ref?: React.Ref<HTMLButtonElement>;
} & React.ComponentPropsWithoutRef<'button'>;

function Button({ ref, children, ...props }: ButtonProps) {
  return <button ref={ref} {...props}>{children}</button>;
}
```

## Breaking Changes from React 18

| React 18 | React 19 | Migration |
|----------|----------|-----------|
| `forwardRef()` wrapper | `ref` as prop | Remove wrapper, add ref to props type |
| `useFormState` | `useActionState` | Rename, add `isPending` return |
| Await in effects | `use()` hook | Use `use()` for promise unwrapping |

## Ref as Prop (forwardRef Deprecated)

In React 19, refs become regular component props:

```typescript
// React 18 (deprecated)
const Button = forwardRef<HTMLButtonElement, ButtonProps>((props, ref) => {
  return <button ref={ref} {...props} />;
});

// React 19
type ButtonProps = {
  ref?: React.Ref<HTMLButtonElement>;
  variant?: 'primary' | 'secondary';
} & React.ComponentPropsWithoutRef<'button'>;

function Button({ ref, variant = 'primary', children, ...props }: ButtonProps) {
  return (
    <button ref={ref} className={variant} {...props}>
      {children}
    </button>
  );
}
```

### Migration Pattern

```typescript
// Before: forwardRef with separate type parameters
const Input = forwardRef<HTMLInputElement, InputProps>((props, ref) => (
  <input ref={ref} {...props} />
));

// After: ref in props type
type InputProps = {
  ref?: React.Ref<HTMLInputElement>;
  label: string;
} & React.ComponentPropsWithoutRef<'input'>;

function Input({ ref, label, ...props }: InputProps) {
  return (
    <label>
      {label}
      <input ref={ref} {...props} />
    </label>
  );
}
```

## useActionState Hook

Replaces `useFormState` with added pending state:

```typescript
type FormState = {
  errors?: string[];
  success?: boolean;
  data?: { id: string };
};

async function submitAction(
  prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const name = formData.get('name');
  if (!name) {
    return { errors: ['Name is required'] };
  }
  // Perform mutation...
  return { success: true, data: { id: '123' } };
}

function CreateForm() {
  const [state, formAction, isPending] = useActionState(submitAction, {});

  return (
    <form action={formAction}>
      <input name="name" disabled={isPending} />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create'}
      </button>
      {state.errors?.map(err => <p key={err}>{err}</p>)}
    </form>
  );
}
```

### With Server Actions

```typescript
'use server';

export async function createUser(
  prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const result = await db.user.create({
    data: { name: formData.get('name') as string }
  });
  revalidatePath('/users');
  return { success: true, data: { id: result.id } };
}
```

```typescript
'use client';

import { useActionState } from 'react';
import { createUser } from '@/actions/user';

function UserForm() {
  const [state, formAction, isPending] = useActionState(createUser, {});
  // ...
}
```

## use() Hook for Promise Unwrapping

Unwrap promises directly in components, triggering Suspense:

```typescript
type User = { id: string; name: string; email: string };

// Client component that consumes a promise
'use client';

import { use } from 'react';

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
    </div>
  );
}

// Parent wraps in Suspense
function UserPage({ userId }: { userId: string }) {
  const userPromise = fetchUser(userId);
  return (
    <Suspense fallback={<UserSkeleton />}>
      <UserProfile userPromise={userPromise} />
    </Suspense>
  );
}
```

### use() with Context

```typescript
const ThemeContext = createContext<'light' | 'dark'>('light');

function ThemedButton() {
  // use() works with context too
  const theme = use(ThemeContext);
  return <button className={theme}>Click</button>;
}
```

### Conditional use()

Unlike hooks, `use()` can be called conditionally:

```typescript
function MaybeUser({ userPromise }: { userPromise?: Promise<User> }) {
  if (!userPromise) {
    return <p>No user selected</p>;
  }
  const user = use(userPromise); // OK: conditional call allowed
  return <p>{user.name}</p>;
}
```

## Server Components

Async components that run server-side:

```typescript
// app/users/[id]/page.tsx
type PageProps = {
  params: Promise<{ id: string }>;
};

export default async function UserPage({ params }: PageProps) {
  const { id } = await params;
  const user = await fetchUser(id);

  return (
    <main>
      <h1>{user.name}</h1>
      <UserPosts userId={user.id} />
    </main>
  );
}

async function UserPosts({ userId }: { userId: string }) {
  const posts = await fetchUserPosts(userId);
  return (
    <ul>
      {posts.map(post => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  );
}
```

### Typing Server Component Props

```typescript
// Props can include Promises for streaming
type DashboardProps = {
  userPromise: Promise<User>;
  statsPromise: Promise<Stats>;
};

async function Dashboard({ userPromise, statsPromise }: DashboardProps) {
  const [user, stats] = await Promise.all([userPromise, statsPromise]);
  return <DashboardContent user={user} stats={stats} />;
}
```

## Server Actions

Mark server-side mutations with `'use server'`:

```typescript
// actions/user.ts
'use server';

import { revalidatePath } from 'next/cache';

export async function updateUser(userId: string, formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;

  await db.user.update({
    where: { id: userId },
    data: { name, email }
  });

  revalidatePath(`/users/${userId}`);
}

export async function deleteUser(userId: string) {
  await db.user.delete({ where: { id: userId } });
  revalidatePath('/users');
}
```

### Inline Server Actions

```typescript
async function UserSettings({ userId }: { userId: string }) {
  async function updateName(formData: FormData) {
    'use server';
    await db.user.update({
      where: { id: userId },
      data: { name: formData.get('name') as string }
    });
    revalidatePath(`/users/${userId}`);
  }

  return (
    <form action={updateName}>
      <input name="name" />
      <button type="submit">Update</button>
    </form>
  );
}
```

## Client/Server Integration Patterns

### Promise Handoff Pattern

Pass promise from server to client without awaiting:

```typescript
// Server Component
async function Page() {
  // Start fetch but don't await
  const userPromise = fetchUser('123');

  return (
    <Suspense fallback={<Skeleton />}>
      <UserCard userPromise={userPromise} />
    </Suspense>
  );
}

// Client Component
'use client';

import { use } from 'react';

function UserCard({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);
  return <div>{user.name}</div>;
}
```

### Action with Optimistic Updates

```typescript
'use client';

import { useOptimistic, useActionState } from 'react';

type Message = { id: string; text: string; pending?: boolean };

function Chat({ messages }: { messages: Message[] }) {
  const [optimisticMessages, addOptimistic] = useOptimistic(
    messages,
    (state, newMessage: string) => [
      ...state,
      { id: crypto.randomUUID(), text: newMessage, pending: true }
    ]
  );

  async function sendMessage(formData: FormData) {
    const text = formData.get('message') as string;
    addOptimistic(text);
    await createMessage(text);
  }

  return (
    <>
      {optimisticMessages.map(msg => (
        <p key={msg.id} style={{ opacity: msg.pending ? 0.5 : 1 }}>
          {msg.text}
        </p>
      ))}
      <form action={sendMessage}>
        <input name="message" />
        <button type="submit">Send</button>
      </form>
    </>
  );
}
```

## TDD Phase Guidance

| Phase | Focus | Avoid |
|-------|-------|-------|
| RED | Test user outcomes, mock server actions | Testing React internals |
| GREEN | Basic action implementation | Complex streaming patterns |
| REFACTOR | Add optimistic updates, improve types | Over-engineering caching |

## Anti-Patterns

- Using `forwardRef` in new React 19 code
- Awaiting promises in client components instead of using `use()`
- Calling Server Actions directly without form or transition
- Mixing client and server code in same file without directives
- Using `useEffect` for data fetching when Server Components work

## What This Reference Does NOT Cover

- General React patterns (see `react-architecture.md`)
- TypeScript fundamentals (see `typescript-core.md`)
- Testing patterns (see `testing-react.md`)

## Goal

Enable confident adoption of React 19 features with full type safety and proper Server/Client boundaries.
