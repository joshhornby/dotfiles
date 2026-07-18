---
allowed-tools: Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git status:*), Bash(git diff:*), Bash(git branch:*), Bash(git log:*), Bash(gh pr create:*), Bash(gh pr view:*), Bash(gh pr checks:*)
description: Commit, push, open a PR, then watch CI + review comments — never auto-merge
argument-hint: "[optional PR title/context]"
---

## Context

- Changes: !`git diff HEAD --stat`
- Status: !`git status --short`
- Branch: !`git branch --show-current`
- Recent commits for style: !`git log --oneline -5`

## Task

1. **Commit** all changes with a conventional message. **No Claude attribution** — no
   `Co-Authored-By` line, no Claude footer (Journey team norm). Follow CLAUDE.md rules.
   `git add -A && git commit -m "<message>"`

2. **Push**: `git push -u origin HEAD`

3. **Open a PR** (do not merge): `gh pr create --fill` (use $ARGUMENTS for the title if
   given). Print the PR URL.

4. **Watch CI to completion**: `gh pr checks --watch`. Report pass/fail per check.

5. **Check for review comments once CI settles**:
   `gh pr view --json reviewDecision,comments` and list any new review comments.

6. **Report back and stop.** Do **not** auto-merge. Summarise: PR URL, CI result, and any
   outstanding review comments. If there are comments to address, suggest running
   `/resolve-pr-comments`.
