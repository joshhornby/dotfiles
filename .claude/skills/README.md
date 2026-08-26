# Skills

This directory holds the agent skills for Claude Code. `~/.claude/skills` is a
symlink to it, so every skill here is available in every session.

Claude loads a skill on its own when your request matches the skill's
`description`. You can also load one by name with `/<skill-name>`.

Most skills in this directory came from [citypaul/.dotfiles][upstream]. They
form one connected system: each skill names the skills that come before and
after it. Read this file to learn the order.

[upstream]: https://github.com/citypaul/.dotfiles

## The delivery pipeline

Use the earliest skill that matches your uncertainty. Do not skip ahead.

| Your problem | Skill | You stop when you have |
|---|---|---|
| The idea has no agreed rules or examples. | `specification` | Acceptance criteria and an example map. |
| You do not know which decision branch is right. | `grill-me` | A resolved decision tree, or a named open decision. |
| The requirement is too broad or solution-shaped. | `story-splitting` | Small child stories, each valuable on its own. |
| The story, plan or mock has holes. | `find-gaps` | A tightened artefact with testable wording. |
| A child story needs implementation sequencing. | `planning` | Vertical slices with per-slice delivery shapes. |
| One slice is too large for a single review. | `stack-pull-requests` | An ordered stack of dependent pull requests. |
| You are ready to change behaviour. | `tdd` | RED-GREEN-REFACTOR increments with real tests. |
| The code needs cleaning after GREEN. | `refactoring` | Behaviour preserved, mechanism improved. |
| You need to prove the tests are strong. | `mutation-testing` | A mutation run at the PR-readiness gate. |

`front-end-testing` covers the UI side of that work: Vitest Browser Mode,
Playwright evidence boundaries and DOM Testing Library queries. Load it when
the behaviour you are proving is browser-observable. `react-testing` adds the
React-specific patterns on top of it.

`story-splitting` splits the product. `planning` sequences the build. Never let
the two swap jobs. Never turn database, API and UI into separate stories.

## Review and verification

Run these after the work exists, not before.

- `panel-review` fans out sub-agents, each loading one skill as a review lens,
  then merges the findings into one ranked report. Start here for any branch,
  diff or pull request.
- `acceptance-review` proves a change against an authoritative issue or spec,
  criterion by criterion. It returns a verdict, not suggestions.
- `double-check` gets a read-only second opinion, preferably from a different
  model provider. Use it before you ship high-stakes work.
- `graph-engineering` is the machinery under `panel-review`. Use it directly
  only when you are composing a new multi-skill orchestration.

## Working with existing code

- `characterisation-tests` pins down what untested code does today, before you
  change it.
- `finding-seams` finds substitution points so tightly-coupled code becomes
  testable.
- `reduce-system-complexity` removes mechanism while conserving behaviour. It
  governs any whole-path reduction programme.
- `improve-codebase-architecture` audits a whole repository and ranks where
  architecture investment would pay off.

## Design and architecture

Load these when you are designing, not by habit.

- `codebase-design` designs one module's contract and depth.
- `structure-codebase` decides the physical file and package tree.
- `api-design` covers consumer-facing and versioned contracts.
- `ubiquitous-language` keeps one glossary as the naming authority.
- `functional` covers immutability and composition.

`domain-driven-design` and `hexagonal-architecture` apply **only** to projects
that have explicitly adopted them. Do not infer either from a generic adapter
or an interface.

## Support

- `find-skills` discovers and installs skills from the wider ecosystem.
- `evaluate-existing-solutions` compares libraries and services against a
  bespoke baseline before you commit to building.
- `storyboard` puts related UX mocks on one page with audit checklists.

## Provenance and licensing

Each skill taken from an external source carries a `LICENSE` file. The file
records the upstream repository and the pinned commit. Some skills carry two
notices. The upper notice covers material the upstream author adapted from an
earlier source, and it takes precedence.

Skills with no `LICENSE` file are our own work.

## Updating a skill

Fetch the file from the pinned path in that skill's `LICENSE`, then update the
commit hash in the notice. Check the `description` afterwards. An upstream
change can widen a trigger and make the skill fire when you do not want it.

## Known gaps

`storyboard` refers to `critique`, `polish` and `shape`. Those skills do not
exist upstream, so those paths dead-end.

`react-testing` refers to `react-performance` and `xstate`. We have not
installed either.

`tdd` overlaps our `testing` and `mutation-testing` skills. Confirm the three
agree on when the mutation run happens before you trust the gate.
