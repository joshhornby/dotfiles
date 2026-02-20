---
description: Analyze recent learnings and create PR to improve Claude setup
argument-hint: [hours to look back, default 8]
---

# Improve Setup - Meta-Learning Agent

Scans auto memory for recent corrections, mistakes, and learnings, then creates a PR with suggested improvements to CLAUDE.md, skills, hooks, and configuration.

## Arguments

- `$ARGUMENTS` - Hours to look back (default: 8)

## Process

### Step 1: Gather Recent Observations

Examine all available sources of recent learnings:

1. **Auto memory files** - Read all files in `~/.claude/projects/*/memory/` for recent patterns, mistakes, and corrections
2. **Git history** - Check recent commits across projects for patterns (last N hours based on argument)
3. **Current session context** - Note any corrections, retries, or friction observed in the current conversation history

Collect every instance of:
- Corrections the user made ("no, do it this way", "that's wrong", "I meant...")
- Repeated mistakes or friction patterns
- Workarounds that suggest missing configuration
- Things that worked well and should be reinforced
- User preferences that were stated but may not be captured in config

### Step 2: Categorize Findings

Group observations into categories:

| Category | Description | Target File |
|----------|-------------|-------------|
| **Coding conventions** | Style, patterns, naming the user prefers | CLAUDE.md |
| **Workflow preferences** | How the user likes to work (commit style, PR flow, etc.) | CLAUDE.md |
| **Tool usage** | Preferred tools, flags, commands | CLAUDE.md |
| **Missing skills** | Repeated manual processes that could be a skill | `.claude/skills/*/SKILL.md` |
| **Hook improvements** | Pre/post command automation opportunities | `.claude/settings.local.json` |
| **Memory gaps** | Important context that should persist | `memory/MEMORY.md` |

### Step 3: Draft Improvements

For each finding, draft a specific, actionable improvement:

- **Be precise**: Don't write vague rules. Write exact instructions Claude can follow.
- **Be minimal**: Only add what's clearly needed. Don't speculate or over-engineer.
- **Preserve existing**: Never remove existing rules unless they directly contradict a learning.
- **Show evidence**: For each proposed change, cite the specific observation that motivated it.

Format each improvement as:

```
## [Category]: [Short Title]

**Observation**: [What happened / what was learned]
**Source**: [Where this was observed - memory file, git commit, session]
**Proposed change**: [Exact text to add/modify]
**Target file**: [Which file to modify]
```

### Step 4: Present Plan to User

Before making any changes, present ALL proposed improvements to the user using `AskUserQuestion`. Group them by target file and let the user approve/reject each one.

Display a summary like:

```
Found N improvements across M files:

CLAUDE.md (X changes):
  1. [title] - [one-line summary]
  2. [title] - [one-line summary]

memory/MEMORY.md (Y changes):
  1. [title] - [one-line summary]

New skill (Z):
  1. [title] - [one-line summary]
```

Ask the user which changes to apply. Do NOT proceed without explicit approval.

### Step 5: Apply Changes

Apply only the approved changes:

1. Create a new git branch: `claude-doctor/improvements-YYYY-MM-DD`
2. Make the approved edits to each target file
3. Commit with a clear message summarizing what was improved and why
4. Create a PR with:
   - Summary of all changes
   - Evidence/reasoning for each change
   - Before/after for any modified rules

### Step 6: Summary

Output a final summary:

```
Doctor's Report
===============
Examined: [sources checked]
Found: [N observations]
Applied: [M improvements]
Skipped: [K rejected by user]
PR: [link]
```

## Important Rules

- **Never remove existing configuration** unless the user explicitly approves removal
- **Never guess** - only propose changes backed by concrete observations
- **Ask before acting** - always get user approval before modifying any files
- **Keep it small** - prefer several small, focused PRs over one massive change
- **Cite your sources** - every proposed change must reference what motivated it
- **Respect scope** - only modify Claude configuration files, never application code
