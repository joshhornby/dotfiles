---
allowed-tools: Read(*), Bash(git status:*), Bash(git diff:*), Bash(git log:*)
description: Restore context from a previously saved session progress snapshot
---

## Context

- Current directory: !`pwd`
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`

## Task

Restore session context from the saved progress file:

1. **Read** `.claude/session-progress.md` to retrieve the saved state

2. **Summarize the restored context:**
   - What was the original goal?
   - What work has been completed?
   - What's the current state?
   - What are the next steps?

3. **Check current state** against the saved snapshot:
   - Are we on the expected branch?
   - Have any files changed since the save?
   - Is the working directory as expected?

4. **Present a clear recap** to the user:
   - "Here's where we left off..."
   - Highlight the immediate next action
   - Flag any discrepancies between saved state and current state

5. **Ask** if the user wants to continue from where they left off or if priorities have changed

If no session progress file exists, inform the user and suggest running `/save-progress` first.
