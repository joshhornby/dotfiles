# Global rules

## How to write

Default to ASD-STE100 Simplified Technical English for anything written to be
followed rather than read: docs, code comments, commit messages, PRs, plans and
runbooks.

- One idea per sentence. Keep sentences short. Give one instruction per sentence.
- Active voice. Present tense.
- One word, one meaning. Do not change words for variety.
- No idioms, metaphors, filler, or AI-tell phrases.
- British spelling.

Prose written to be read is looser. Essays, blog posts, talks and long replies keep
the plain words, the active voice and the British spelling, and drop the sentence
length limit. Vary the rhythm instead. Let a sentence run when it carries one
thought whose parts have to arrive together, and save the short ones for the turns
in the argument. Writing where every sentence is the same length reads as
machine-made however plain the words are, and nothing lands because everything is
emphasised equally.

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

## Commits

- Make a new commit. Do not amend unless told to.
- Use conventional prefixes: `feat`, `fix`, `chore`, `refactor`, `docs`.

## Tests

- Test behaviour, not mocks. Use a real database for database code.
- Run only the tests for the files you changed.
