---
name: harness
description: Add harness engineering scaffolding to any project — CLAUDE.md, docs structure, invariants, plan templates
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# Harness

Apply harness engineering principles to this project. The goal is to make the repository legible and navigable for agents — the repo becomes the system of record.

Work through these steps in order. Adapt everything to the specific project — do not produce generic boilerplate.

## Context

- Current directory: !`pwd`
- Project name: !`basename "$PWD"`
- Recent commits: !`git log --oneline -10 2>/dev/null || echo "Not a git repo"`
- Existing files at root: !`ls -1 2>/dev/null`

## Step 1: Analyze the project

Before writing anything, understand:

- **Language and framework** — read package.json, Gemfile, requirements.txt, go.mod, Cargo.toml, or equivalent
- **Directory structure** — glob for key directories and files
- **Existing documentation** — check for README, CLAUDE.md, AGENTS.md, docs/, any markdown files
- **Build/test/lint commands** — read config files, scripts, Makefile, etc.
- **Architecture patterns** — read key source files to understand how the code is organized: entry points, core abstractions, data flow
- **Existing mechanical checks** — CI config, linters, type checkers, test frameworks

Spend real time here. Read source files. The quality of everything downstream depends on understanding the project.

## Step 2: Create `docs/` structure

```
docs/
  architecture/       # How the system works
  plans/              # Implementation plans (written before code)
  references/         # External docs, schemas, API guides
  quality/            # Quality scores, audit results, verification artifacts
```

Create the directories. Then populate:

### `docs/architecture/` — at minimum, write:

1. **`system-overview.md`** — The core architecture: what the system does, how data flows, key abstractions, how components relate. Include text-based diagrams where they help. This is what an agent reads first.

2. **`invariants.md`** — Non-negotiable rules of the codebase. Split into:
   - **Structural invariants** — things that must always be true about code organization
   - **Runtime invariants** — things that must always be true at runtime
   - **Quality invariants** — mechanical checks that must pass, with exact commands

   Only include invariants that are actually true today. Don't write aspirational rules.

3. **Additional architecture docs** as warranted by complexity. Only create if the project has enough substance to justify them.

### `docs/plans/README.md` — the plan template:

```markdown
# Plans

Plans are written **before** implementation begins. Every non-trivial change starts here.

A plan must be specific enough that an agent can execute it without further clarification. If a plan requires follow-up questions, it isn't ready.

## Plan format

    # Plan: <title>

    ## Goal
    What we're trying to achieve and why. One paragraph max.

    ## Current state
    What exists today that's relevant. File paths, current behavior, data shapes.

    ## Changes
    Specific files to create/modify, in order. For each:
    - File path
    - What changes and why
    - Any new dependencies or schema changes

    ## Acceptance criteria
    Concrete, verifiable checks. Each must be pass/fail.
    - [ ] (list exact commands and expected results)

    ## Out of scope
    What this plan intentionally does NOT cover.

## Naming

Use `YYYY-MM-DD-<slug>.md`. Completed plans stay as decision records.
```

### `docs/references/README.md` and `docs/quality/README.md` — brief descriptions of what belongs in each.

## Step 3: Create or update `CLAUDE.md`

CLAUDE.md is the **index, not the manual**. Follow this structure:

1. **One-paragraph project description** — what this is, in plain language
2. **Docs** — bullet list pointing to each doc in `docs/`, one line each
3. **Commands** — exact build/test/lint/run commands from the project config
4. **Code conventions** — only things not already enforced by linters. Short bullet list.
5. **Where to find things** — lookup table mapping common tasks to file paths
6. **Principles** — harness engineering principles, adapted to this project:
   - Repo is the system of record
   - Map, not manual (this file is an index, depth lives in docs/)
   - Parse at boundaries, trust internally
   - Enforce mechanically over documentation-only rules
   - Agent legibility — if an agent can't inspect it, it doesn't exist
   - When something fails, ask "what capability is missing?"
   - Learnings compound — encode fixes so they persist
7. **Environment** — required env vars, setup steps

**CLAUDE.md rules:**
- Do NOT include architecture details — that's what `docs/architecture/` is for
- Do NOT restate what linters already enforce
- Do NOT include the source directory tree — agents can read the filesystem
- Keep it under 80 lines
- Every section is either a pointer elsewhere or info needed on every task

## Step 4: Verify

1. Read back CLAUDE.md — is it a concise index, not a manual?
2. Do docs reference real files and paths that exist?
3. Are invariants actually true? (If you list `npm test`, does the project have tests?)
4. Is there duplicated content between CLAUDE.md and docs/?

## What NOT to do

- Don't write generic docs that could apply to any project. Every sentence must be specific to this codebase.
- Don't invent patterns that aren't in the code. Document what exists.
- Don't add aspirational invariants. Only what's enforced today.
- Don't bloat CLAUDE.md past 80 lines. Move overflow to docs/.
- Don't create a README.md — that's a different concern.
