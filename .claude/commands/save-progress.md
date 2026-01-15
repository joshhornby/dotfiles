---
allowed-tools: Write(*), Read(*), Bash(git status:*), Bash(git diff:*), Bash(git log:*)
description: Save current session context to prevent losing track of progress
---

## Context

- Current directory: !`pwd`
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Recent changes: !`git diff --stat HEAD~3..HEAD 2>/dev/null || echo "No recent commits"`

## Task

Create a session progress snapshot by writing to `.claude/session-progress.md`:

1. **Summarize the current session:**
   - What was the original task/goal?
   - What decisions were made and why?
   - What files were created, modified, or deleted?
   - What's the current state of the work?
   - What are the next steps?

2. **Capture open questions or blockers** that need resolution

3. **Record any important context** that would be lost if the session ended

4. **Write the file** with this structure:

```markdown
# Session Progress

**Saved:** [timestamp]
**Branch:** [current branch]
**Working Directory:** [path]

## Original Goal
[What the user asked for]

## Decisions Made
- [Decision 1]: [Rationale]
- [Decision 2]: [Rationale]

## Work Completed
- [x] [Task 1]
- [x] [Task 2]
- [ ] [Incomplete task]

## Files Changed
- `path/to/file.ext` - [what was done]

## Current State
[Where things stand right now]

## Next Steps
1. [Next action]
2. [Following action]

## Open Questions / Blockers
- [Any unresolved issues]

## Important Context
[Anything that would be lost without saving]
```

5. **Confirm** the save was successful and summarize what was captured
