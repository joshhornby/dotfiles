---
allowed-tools: Read(*), Write(*), Bash(git log:*), Bash(git diff:*), Bash(basename:*), Bash(pwd:*)
description: Accumulate learnings and insights across multiple sessions into persistent knowledge
---

## Context

- Current directory: !`pwd`
- Project name: !`basename "$PWD"`
- Recent commits: !`git log --oneline -10 2>/dev/null || echo "Not a git repo"`

## Task

Compound learnings from the current session into `.claude/compounded-knowledge.md`:

1. **Read existing knowledge** from `.claude/compounded-knowledge.md` if it exists

2. **Extract learnings from this session:**
   - Patterns discovered in the codebase
   - Architectural decisions and their rationale
   - Gotchas, edge cases, or quirks encountered
   - User preferences observed (code style, conventions, workflow)
   - Useful commands or workflows specific to this project
   - Domain knowledge gained

3. **Merge new learnings** with existing knowledge:
   - Don't duplicate existing entries
   - Update outdated information
   - Add timestamps to new entries
   - Organize by category

4. **Write the compounded knowledge** with this structure:

```markdown
# Compounded Knowledge

> Accumulated learnings across sessions for this project

**Last Updated:** [timestamp]

## Project Architecture
- [Key architectural insight]
- [Important pattern]

## Code Conventions
- [Naming conventions]
- [File organization patterns]
- [Testing patterns]

## User Preferences
- [Preferred workflow]
- [Style preferences]

## Gotchas & Edge Cases
- [Thing that caused issues]
- [Non-obvious behavior]

## Useful Commands
- `command` - [what it does]

## Domain Knowledge
- [Business logic insight]
- [Domain-specific terminology]

## Session Log
| Date | Key Learnings |
|------|---------------|
| [date] | [brief summary] |
```

5. **Summarize** what was added to the knowledge base

6. **Suggest** reviewing the compounded knowledge periodically to keep it relevant
