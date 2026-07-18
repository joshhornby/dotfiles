# Josh's global working rules

These are standing preferences distilled from thousands of past sessions. They apply
everywhere unless a project's own CLAUDE.md overrides them. Keep this file thin — put
project-specific conventions (domain terms, service layout) in the project's CLAUDE.md,
not here.

## Code

- **Never use `any`** (`: any`, `as any`, `any[]`, `<any>`). Find the real type — look at
  how it's typed elsewhere in the repo first. Prefer exhaustive `switch`/discriminated
  unions over functions that "shouldn't" return undefined.
- **Object params for any function with 2+ arguments.** Positional args are only for
  single-argument functions. When editing a function that has (or grows to) 2+ params,
  convert it to a single object param — and do the same for sibling functions in the diff.
- **No gratuitous comments.** Don't narrate what the code already says. A comment must
  earn its place by explaining *why*, not *what*. Before finishing, sweep out any comments
  added in the change that don't add value.
- **British spelling in code too** (identifiers, strings): `randomise`, `colour`,
  `initialise`, `cancelled`. Exception: don't fight platform APIs that are American by
  spec (CSS `color`, `text-align: center`, DOM properties).
- **Pin dependency versions exactly.** Never `*`, `&`, or open ranges — in `composer.json`,
  `package.json`, anywhere. Use the actual installed version.

## Commits

- **Default to NO Claude attribution** in Journey work repos — no `Co-Authored-By` line,
  no "Generated with Claude Code" footer. This is the team norm ("commit no claude" is the
  most frequent commit instruction). Only add attribution if explicitly asked.
- **Make a new commit; don't amend** unless told to.
- Conventional commit prefixes (`feat:`/`fix:`/`chore:`/`refactor:`/`docs:`).

## Testing

- **Test behaviour, not mocks.** Don't assert that a mock was called — assert the real
  outcome. For DB code, use a real/dockerised database as an integration test rather than
  mocking the data layer.
- When changing code, add tests for the new behaviour and run **only the tests for the
  files changed** (diff against `main`), not the whole suite.

## Writing (prose, docs, comments-that-do-ship)

- Simple, plain language. Short sentences. Active voice.
- **No default bullet-point lists** — write prose unless a list genuinely earns it.
- No AI-tell phrases. When editing any substantial prose, run the **humanizer** skill.
- Personal voice is codified in the **josh-writing-voice** skill — use it for blog posts
  and anything published under Josh's name.
