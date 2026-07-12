---
name: impossible-states
description: Model data with discriminated unions so invalid states can't be constructed, moving whole bug categories from runtime to compile time. Use when defining types that carry state, when you see booleans/optionals that only make sense in certain combinations, when writing defensive "shouldn't happen" checks, or when reviewing type/data-model design.
---

# Making Impossible States Impossible

Design types and APIs so invalid program states are **unrepresentable**. Most bugs
aren't exotic edge cases — they're "shouldn't be possible, but the code allowed it".
Push those into the type system and the compiler becomes the safety net.

Primary examples are TypeScript (Journey's stack); the discipline is the same in any
language with sum types (Rust/Swift enums, F# unions). Pairs with [[typescript-strict]]
for `no-any`, branded types, and strict-mode config.

## The core move: booleans/optionals → discriminated union

When a set of fields is only valid in certain combinations, they belong in one tagged union.

```typescript
// ❌ Representable but invalid: { isLoggedIn: false, username: 'alice' }
interface UserSession {
  isLoggedIn: boolean;
  username?: string;
}

// ✅ Each variant carries exactly the data that state needs — nothing more
type UserSession =
  | { status: 'loggedOut' }
  | { status: 'loggedIn'; username: string };
```

The classic case is async data. Three parallel fields allow `isLoading: true` *with* an
error *and* data — a meaningless state you then have to write guards for.

```typescript
// ❌ 2^3 = 8 combinations, most nonsensical
type Fetch<T> = { isLoading: boolean; data?: T; error?: Error };

// ✅ Exactly 4 real states, each self-contained
type Fetch<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };
```

## Exhaustiveness: let the compiler find every affected spot

Switch on the tag and assign the default to `never`. Add a variant later and every
unhandled `switch` becomes a compile error — refactoring by following the red.

```typescript
function render(s: Fetch<User>): string {
  switch (s.status) {
    case 'idle':    return '';
    case 'loading': return 'Spinner';
    case 'success': return s.data.name;   // `data` only exists here
    case 'error':   return s.error.message;
    default: {
      const _exhaustive: never = s;       // compile error if a case is missing
      return _exhaustive;
    }
  }
}
```

## Smells that signal a missing union

- Multiple booleans that can't all be true at once (`isLoading`/`isError`/`isSuccess`).
- An optional field that's only meaningful when another field holds a specific value.
- Defensive `if`/`throw` for cases commented "this should never happen".
- A `data` field you must null-check on every read because it's sometimes absent.

## Related tightenings

- **Non-empty collections**: if empty is invalid, model it — `type NonEmptyArray<T> = [T, ...T[]]` — instead of checking `.length` everywhere.
- **Constrained primitives**: if only some strings/numbers are valid, use a branded type with a validating constructor (see [[typescript-strict]]) so raw values can't leak in.
- **Parse, don't validate**: at trust boundaries return the *refined* type once, then pass it inward — don't re-check the same invariant at every call site.

## Where it earns its keep — and where it doesn't

Reach for this when state combinations encode real business rules (auth, payments,
workflow steps, request lifecycles). Don't over-engineer a bag of genuinely independent
optional fields into a union — the payoff is proportional to how many *invalid*
combinations you're eliminating.

## Checklist

- [ ] No boolean/optional combo can represent a state that shouldn't exist
- [ ] Each union variant carries only the data valid in that state
- [ ] `switch` on the tag is exhaustive via a `never` default
- [ ] No defensive checks for "impossible" cases remain — they're unrepresentable
- [ ] Empty/constrained values modelled in the type, not re-checked at each use
