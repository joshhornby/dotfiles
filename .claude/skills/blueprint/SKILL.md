---
name: blueprint
description: Iterative spec-driven development workflow using subagents. Use when user wants to build a feature from scratch, needs help writing a detailed spec, or asks for implementation with verification. Triggers on phrases like "build this feature", "implement and verify", "spec this out", "develop with tests", or requests involving multi-phase development with quality gates.
---

# Blueprint

A spec-first development workflow that iterates through spec → implement → verify → simplify phases using subagents.

## Philosophy

- **Spec first**: A detailed spec prevents wasted iterations
- **Parallel work**: Subagents handle discrete tasks concurrently  
- **Verification built-in**: Every implementation gets tested and reviewed
- **Simplify last**: Reduce complexity only after correctness is proven

## Workflow Overview

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌─────────────┐
│  1. SPEC    │ ──▶ │  2. IMPLEMENT   │ ──▶ │   3. VERIFY     │ ──▶ │ 4. SIMPLIFY │
│  (with user)│     │  (subagents)    │     │   (subagents)   │     │ (subagents) │
└─────────────┘     └─────────────────┘     └─────────────────┘     └─────────────┘
      │                     │                       │                      │
      ▼                     ▼                       ▼                      ▼
  spec.md            implementation           test results           simplified
  approved              complete              + review notes            code
```

## Phase 1: Spec Writing

Collaborate with user to produce a detailed spec. Write to `spec.md` in project root.

### Spec Template

```markdown
# Feature: [Name]

## Problem Statement
[What problem does this solve? Why now?]

## Success Criteria
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]

## Scope
### In Scope
- [Feature/behavior 1]

### Out of Scope  
- [Explicitly excluded item]

## Technical Approach
### Architecture
[How components fit together]

### Key Decisions
| Decision | Choice | Rationale |
|----------|--------|-----------|
| [Decision] | [Choice] | [Why] |

## Implementation Tasks
- [ ] Task 1: [Description] (~estimate)
- [ ] Task 2: [Description] (~estimate)

## Test Plan
- [ ] Unit: [What to test]
- [ ] Integration: [What to test]

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| [Risk] | [Mitigation] |
```

**Ask clarifying questions** until spec is complete. Get explicit user approval before Phase 2.

## Phase 2: Implementation (Subagents)

Spawn subagents for each implementation task. Use `Task.run()` or equivalent subagent API.

### Subagent Prompt Template

```
You are implementing a specific task from a spec.

TASK: [Task description from spec]
CONTEXT: [Relevant architecture/decisions from spec]
FILES TO CREATE/MODIFY: [Specific files]
SUCCESS CRITERIA: [How to know this task is done]

Instructions:
1. Read the full spec at spec.md first
2. Implement ONLY the assigned task
3. Write tests alongside implementation
4. Commit with message: "feat: [task summary]"
5. Output TASK_COMPLETE when done, or BLOCKED: [reason] if stuck
```

### Parallelization Strategy

- Independent tasks → spawn in parallel
- Tasks with dependencies → spawn sequentially or chain
- Shared state → spawn serially with explicit handoff

Track progress:
```markdown
## Implementation Progress
- [x] Task 1 - COMPLETE (agent-1)
- [ ] Task 2 - IN_PROGRESS (agent-2)  
- [ ] Task 3 - BLOCKED: waiting on Task 2
```

## Phase 3: Verification (Subagents)

Spawn verification subagents in parallel:

### Test Runner Subagent
```
Run all tests for the implementation.
1. Execute test suite
2. Report: TESTS_PASS or TESTS_FAIL with details
3. If failing, list specific failures
```

### Code Reviewer Subagent
```
Review implementation against spec.md.
Check:
- All success criteria met
- No scope creep beyond spec
- Error handling present
- Edge cases covered

Output: REVIEW_PASS or REVIEW_ISSUES: [list]
```

### Type/Lint Checker Subagent
```
Run type checker and linter.
Report any errors or warnings.
Output: CLEAN or ISSUES: [list]
```

### Verification Gate

All three must pass to proceed. If any fail:
1. Spawn fix subagent with specific issues
2. Re-run failed verification
3. Repeat until all pass (max 5 iterations)

## Phase 4: Simplification (Subagents)

Only after verification passes. Spawn simplification subagents:

### Complexity Reducer
```
Review implementation for unnecessary complexity.
Look for:
- Dead code
- Over-abstraction
- Redundant logic
- Verbose patterns with simpler alternatives

Propose specific simplifications. Do not change behavior.
```

### Documentation Cleaner
```
Review comments and docs.
Remove:
- Obvious comments
- Stale TODOs
- Redundant docstrings

Add only where genuinely unclear.
```

After simplification: **re-run Phase 3 verification** to ensure nothing broke.

## Completion

When all phases complete:
1. Summarize what was built
2. List any deferred items for future
3. Output: BLUEPRINT_COMPLETE

## Iteration Limits

| Phase | Max Iterations | On Limit |
|-------|---------------|----------|
| Spec | N/A (user-driven) | - |
| Implement | 3 per task | Mark BLOCKED, continue |
| Verify | 5 total | Report remaining issues |
| Simplify | 2 | Accept current state |

## Quick Reference

```bash
# Check spec exists and is approved
cat spec.md | head -50

# Spawn implementation subagent
Task.run("Implement [task] per spec.md...")

# Run verification suite
Task.run("Run tests...") & Task.run("Review code...") & Task.run("Check types...")

# Simplification pass  
Task.run("Simplify implementation, preserve behavior...")
```
