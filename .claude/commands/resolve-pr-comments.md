---
allowed-tools: Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh api:*), Bash(gh pr checks:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git status:*), Bash(git diff:*), Bash(git branch:*), Bash(git log:*)
description: Fetch PR + Copilot review comments, triage, apply fixes, and resolve threads
argument-hint: "[PR number or URL — defaults to the PR for the current branch]"
---

## Context

- Target PR: $ARGUMENTS (if empty, use the PR for the current branch)
- Current branch: !`git branch --show-current`
- PR overview: !`gh pr view $ARGUMENTS --json number,title,url,headRefName,reviewDecision 2>/dev/null || gh pr view --json number,title,url,headRefName,reviewDecision`

## Task

1. **Gather every open review comment**, including bot/Copilot comments:
   - Review threads + inline comments:
     `gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate`
   - Top-level review summaries:
     `gh api repos/{owner}/{repo}/pulls/{number}/reviews --paginate`
   - Issue-style comments on the PR:
     `gh api repos/{owner}/{repo}/issues/{number}/comments --paginate`
   Derive `{owner}/{repo}/{number}` from `gh pr view --json url`.

2. **Present a triaged action list** — one row per comment: file:line, who raised it
   (human vs Copilot/bot), the ask, and your recommendation (**apply** / **discuss** /
   **skip** with a one-line reason). Group trivial/duplicate bot nits together.

3. **Wait for Josh to choose** which to action (e.g. "1,2,4 — leave the dynamo one").
   Do not apply anything before he picks unless the fixes are purely mechanical and
   unambiguous.

4. **Apply the chosen fixes**, following the global rules in CLAUDE.md (object params,
   no `any`, no gratuitous comments, British spelling).

5. **Commit as a fresh commit with NO Claude attribution** and push:
   - `git add -A && git commit -m "<conventional message>"` — no `Co-Authored-By`, no
     Claude footer. Do **not** amend.
   - `git push origin HEAD`

6. **Resolve the addressed threads** on GitHub via the GraphQL API
   (`resolveReviewThread` mutation) for each thread you fixed, and reply briefly to any
   thread you chose *not* to action, explaining why. Report a summary: fixed / skipped /
   left for discussion.
