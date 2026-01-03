---
allowed-tools: Bash(git add:*), Bash(git commit:*), Bash(git push:*), Bash(git status:*), Bash(git diff:*)
description: Commit all changes with auto-generated message and push
---

## Context

- Current changes: !`git diff HEAD`
- Current status: !`git status --short`
- Current branch: !`git branch --show-current`
- Recent commits for style reference: !`git log --oneline -5`

## Task

1. Review the changes above
2. Write a conventional commit message (feat:/fix:/chore:/refactor:/docs:) based on the changes
3. Run: git add -A && git commit -m "<your message>"
4. Run: git push origin HEAD
