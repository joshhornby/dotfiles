# Global rules

## How to write

Write all output in ASD-STE100 Simplified Technical English:

- One idea per sentence. Keep sentences short (20 words or fewer).
- Active voice. Present tense. Give one instruction per sentence.
- One word, one meaning. Do not change words for variety.
- No idioms, metaphors, filler, or AI-tell phrases.
- British spelling.

Write prose, not bullet lists, unless a list earns its place. Run the **humanizer**
skill on long prose. Use the **josh-writing-voice** skill for text published under
Josh's name.

## Code

- Do not write comments that repeat what the code does. Write a comment only to
  explain why. Delete the comments you added that fail this test.
- Never use `any`. Find the real type.
- Use one object parameter for a function with two or more arguments.
- Use British spelling in identifiers and strings. Keep platform API names as
  specified (CSS `color`).
- Pin dependency versions exactly. Do not use ranges.

## Commits

- Do not add Claude attribution unless asked.
- Make a new commit. Do not amend unless told to.
- Use conventional prefixes: `feat`, `fix`, `chore`, `refactor`, `docs`.

## Tests

- Test behaviour, not mocks. Use a real database for database code.
- Run only the tests for the files you changed.
