---
name: typescript-strict
description: Strict TypeScript. Model state as discriminated unions so invalid states can't be constructed, then hold the line with branded types, schema-first trust boundaries and strict compiler flags. Use when defining types or schemas, when you see booleans or optionals that only make sense in certain combinations, when writing defensive "shouldn't happen" checks, when configuring tsconfig, or when reviewing type safety.
---

# Strict TypeScript

Two halves, in order of payoff. First design types so invalid states cannot be
written down. Then use the compiler, branded types and boundary schemas to keep raw
values out.

## Core rules

1. **No `any`.** Find the real type. Use `unknown` at untrusted boundaries. Contain
   unavoidable interop in a declaration file or a named shim, and explain it there.
2. **No type assertions** (`as Type`) without justification. The justified places
   are named below and nowhere else.
3. **Model state as a discriminated union**, not a bag of booleans and optionals.
4. **Follow the repository's `type` or `interface` convention.** Choose from
   language semantics when no convention exists.
5. **Validate at trust boundaries. Trust inward.**

---

## Making impossible states impossible

Most bugs are not exotic edge cases. They are "shouldn't be possible, but the code
allowed it". Design the type so the invalid state has no spelling, and the compiler
becomes the safety net.

When a set of fields is only valid in certain combinations, they belong in one
tagged union.

```typescript
// Representable but invalid: { isLoggedIn: false, username: 'alice' }
type UserSession = {
  isLoggedIn: boolean;
  username?: string;
};

// Each variant carries exactly the data that state needs, and nothing more
type UserSession =
  | { status: 'loggedOut' }
  | { status: 'loggedIn'; username: string };
```

The payoff scales with how many invalid combinations you delete. A booking with four
status booleans and three optional payload fields has over a hundred representable
shapes and four real states.

```typescript
type Booking =
  | { status: 'enquiry'; guest: EmailAddress }
  | { status: 'held'; guest: EmailAddress; holdExpiresAt: Date }
  | { status: 'confirmed'; guest: EmailAddress; reference: BookingReference; total: Money }
  | { status: 'cancelled'; guest: EmailAddress; reason: CancellationReason };
```

`holdExpiresAt` cannot be read on a confirmed booking. `reference` cannot be absent
on one. No guard is needed for either, because neither can be written.

### Exhaustiveness: let the compiler find every affected spot

Switch on the tag and assign the default to `never`. Add a variant later and every
unhandled `switch` becomes a compile error. Refactor by following the red.

```typescript
function describe(booking: Booking): string {
  switch (booking.status) {
    case 'enquiry':   return 'Awaiting availability';
    case 'held':      return `Held until ${booking.holdExpiresAt.toISOString()}`;
    case 'confirmed': return `Confirmed as ${booking.reference}`;
    case 'cancelled': return `Cancelled: ${booking.reason}`;
    default: {
      const unhandled: never = booking; // compile error if a case is missing
      return unhandled;
    }
  }
}
```

### Smells that signal a missing union

- Multiple booleans that cannot all be true at once, such as `isLoading`,
  `isError` and `isSuccess`.
- An optional field that is only meaningful when another field holds a specific value.
- A defensive `if` or `throw` for a case commented "this should never happen".
- A field you must null-check on every read because it is sometimes absent.

### When a union is not the answer

The payoff is proportional to the number of invalid combinations removed. When that
number is zero, a union adds ceremony and nothing else. Keep separate optional
fields for:

- Independent optionals, such as a draft form or a `PATCH` payload where any field
  can be absent on its own.
- An options bag or a config file.
- Fields that are always present together and never read apart. One optional nested
  object is clearer than two variants.
- A wire shape you do not own. See below.

### Who owns the union

Your union is a domain type, not a copy of someone else's payload. A supplier API
that returns `{ status, error?, data? }` keeps that shape at the edge. Parse it once
into your own union at the boundary, then pass the refined type inward.

Define a union once per owned contract, version and bounded context. Do not couple
two independently deployed consumers because their variants happen to match today.
Translate at each boundary, and use contract tests where drift would hurt.

### Where runtime checks are allowed to live

Exactly two places:

- **The trust boundary**, where a schema or a smart constructor rejects bad input.
- **The `never` default**, which is unreachable but still has to return.

Inward of those, a check for an impossible state means the type is still wrong. Fix
the type instead of adding the guard.

---

## Branded types and constrained primitives

When only some strings or numbers are valid, brand the primitive and give it one
validating constructor. This is the one place a type assertion is justified.

```typescript
type UserId = string & { readonly brand: unique symbol };
type PaymentMinorUnits = number & { readonly brand: unique symbol };
type Currency = 'GBP' | 'USD' | 'EUR';
type PaymentMoney = {
  readonly minorUnits: PaymentMinorUnits;
  readonly currency: Currency;
};

const processPayment = (userId: UserId, amount: PaymentMoney) => {
  // Implementation
};

// Cannot pass a raw string or number
processPayment('user-123', 100); // Error

const toUserId = (raw: string): UserId => {
  if (raw.length === 0) throw new Error('UserId cannot be empty');
  return raw as UserId;
};

const toPaymentMinorUnits = (raw: number): PaymentMinorUnits => {
  if (!Number.isSafeInteger(raw) || raw <= 0) {
    throw new Error('Payment minor units must be a positive safe integer');
  }
  return raw as PaymentMinorUnits;
};

const toPaymentMoney = (minorUnits: number, currency: Currency): PaymentMoney => ({
  minorUnits: toPaymentMinorUnits(minorUnits),
  currency,
});

processPayment(toUserId('user-123'), toPaymentMoney(2_500, 'GBP')); // £25.00
```

Never scatter `as UserId` through application code. The assertion lives only inside
the constructor, or in a schema's `transform`, so every branded value has passed
validation.

The payment boundary above takes already-rounded integer minor units, so `NaN`,
infinities and binary-float fractions are rejected. A boundary that instead takes
decimal major-unit text must parse with the currency's minor-unit exponent and a
named rounding policy, or reject the excess precision. Never use
`Math.round(rawNumber * 100)`.

Non-empty collections follow the same principle. If empty is invalid, model it as
`type NonEmptyArray<T> = [T, ...T[]]` rather than checking `.length` at every use.

---

## Type or interface

### Use `type` for unions, tuples, mapped types and closed aliases

```typescript
export type User = {
  readonly id: string;
  readonly email: string;
  readonly name: string;
  readonly roles: ReadonlyArray<string>;
};
```

Type aliases can name unions, intersections, tuples, primitives, mapped types and
object shapes. They cannot be reopened by declaration merging. A discriminated union
needs a `type`.

### Use `interface` for extendable object contracts

```typescript
export interface BookingRepository {
  findById(id: BookingId): Promise<Booking | undefined>;
  save(booking: Booking): Promise<void>;
}
```

Interfaces describe object shapes, work with `implements`, extend with conflict
checking and support declaration merging. They suit behaviour contracts and
deliberate extension points. They are not forbidden for data shapes.

---

## Schema-first at trust boundaries

### When a runtime schema is required

A runtime schema is required when untrusted data crosses a boundary and the
programme must check its shape or constraints before use:

- HTTP, queue, file, environment or third-party data entering the system.
- A data contract exchanged between independently deployed systems.
- Contract-shaped test fixtures, where reusing a production schema adds evidence.

```typescript
const BookingResponseSchema = z.object({
  id: z.uuid(),
  guest: z.email(),
});
type BookingResponse = z.infer<typeof BookingResponseSchema>;

const response = BookingResponseSchema.parse(apiResponse);
```

Internal invariants do not need a schema by default. A smart constructor, branded
type or domain union is the clearer owner when values are created and consumed
inside one trusted process.

### When a schema is not required

- Pure internal types, such as utilities and state.
- `Result` and `Option` types. There is nothing to validate.
- TypeScript utility types such as `Partial<T>` and `Pick<T>`.
- Behaviour contracts. Interfaces are structural, not validated.
- Component props, unless they come from a URL or an API.

```typescript
// A discriminated union, not a validated shape. See "impossible states" above.
type Result<T, E> =
  | { success: true; data: T }
  | { success: false; error: E };
```

### Schema ownership

Define a schema once per owned contract, version and bounded context, then import it
within that boundary. Do not couple independently deployed consumers because their
fields match today. Validate and translate at each trust boundary.

Prefer libraries implementing [Standard Schema](https://standardschema.dev), such as
Zod 4+, Valibot and ArkType, so validation tooling stays interchangeable.

---

## Strict mode configuration

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "forceConsistentCasingInFileNames": true,
    "allowUnusedLabels": false
  }
}
```

**Strict baseline:**

- **`strict: true`** enables the strict type-checking family, including
  `noImplicitAny` and `strictNullChecks`.

**Further project checks:**

- **`noUnusedLocals`** errors on an unused local variable.
- **`noUnusedParameters`** errors on an unused function parameter.
- **`noImplicitReturns`** errors when not all code paths return a value.
- **`noFallthroughCasesInSwitch`** errors on a fallthrough case.

**Further safety flags to assess against the codebase:**

- **`noUncheckedIndexedAccess`** makes array and object access return
  `T | undefined`, which stops code assuming an element exists.
- **`exactOptionalPropertyTypes`** separates `property?: T` from
  `property: T | undefined`.
- **`noPropertyAccessFromIndexSignature`** requires bracket notation for index
  signature properties, which forces awareness of dynamic access.
- **`forceConsistentCasingInFileNames`** prevents case sensitivity problems across
  operating systems.
- **`allowUnusedLabels`** set to false errors on an unused label.

Prefer a narrow, justified `@ts-expect-error` over `@ts-ignore` when an upstream
typing defect cannot yet be fixed. `@ts-expect-error` fails once the defect is
fixed, so it cannot rot in place.

Apply the same type-safety policy to tests. Use a deliberate test-only shim rather
than weakening the global configuration.

`noUnusedParameters` also finds design problems. An unused parameter often means the
parameter belongs in a different layer.

---

## Immutability

- Use `readonly` and `ReadonlyArray<T>` where immutability is part of the contract,
  especially for shared domain values.
- The compiler enforces shallow property immutability. It does not make nested
  runtime values deeply immutable.
- Choose factories or classes from invariant, lifecycle and project-convention
  needs. Dependency injection does not require either form.

---

## Checklist

Data modelling:

- [ ] No boolean or optional combination can represent a state that should not exist
- [ ] Each union variant carries only the data valid in that state
- [ ] Every `switch` on a tag is exhaustive via a `never` default
- [ ] Runtime checks appear only at a boundary or in a `never` default
- [ ] Unions and schemas are owned per contract, version and context. External wire
      shapes are translated, not adopted
- [ ] Empty and constrained values are modelled in the type, not re-checked at each use

Type safety:

- [ ] No `any`. Unavoidable interop is narrow, named and explained
- [ ] No type assertions outside a validating constructor or a schema `transform`
- [ ] `type` and `interface` follow repository convention, or the required semantics
- [ ] `strict` is enabled, and further flags follow the repository's policy
- [ ] `readonly` and `ReadonlyArray` used where immutability is part of the contract
