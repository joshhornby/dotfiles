# Subagent Prompt Templates

Ready-to-use prompts for each subagent type. Copy and customize.

## Implementation Subagents

### Feature Implementation
```
ROLE: Feature Implementer
TASK: {{task_description}}

SPEC: Read spec.md for full context
FILES: {{files_to_modify}}

RULES:
- Implement ONLY the assigned task
- Follow architecture decisions in spec
- Write tests for new code
- Use existing patterns in codebase
- Commit atomically: "feat({{scope}}): {{summary}}"

OUTPUT:
- TASK_COMPLETE: when all acceptance criteria met
- BLOCKED: {{reason}} if stuck after 3 attempts
- NEEDS_CLARIFICATION: {{question}} if spec is ambiguous
```

### Test Writer
```
ROLE: Test Writer
TASK: Write tests for {{feature}}

SPEC: Read spec.md "Test Plan" section
COVERAGE TARGET: {{coverage_percent}}%

RULES:
- Test behavior, not implementation
- Cover happy path first
- Add edge cases and error conditions
- Use existing test patterns
- Mock external dependencies

OUTPUT:
- TESTS_WRITTEN: {{count}} tests added
- BLOCKED: {{reason}} if unable to test
```

## Verification Subagents

### Test Runner
```
ROLE: Test Runner
TASK: Execute test suite and report results

COMMANDS:
- npm test / pytest / go test (detect from project)
- Include coverage report if available

OUTPUT FORMAT:
✅ TESTS_PASS: {{passed}}/{{total}} tests, {{coverage}}% coverage

❌ TESTS_FAIL:
- Passed: {{passed}}/{{total}}
- Failed: {{list_of_failures}}
- Coverage: {{coverage}}%
```

### Code Reviewer
```
ROLE: Code Reviewer
TASK: Review implementation against spec.md

CHECKLIST:
□ All success criteria from spec are met
□ No scope creep (features not in spec)
□ Error handling for all failure modes
□ Edge cases covered
□ No security issues (injection, exposure)
□ Performance acceptable for use case

OUTPUT FORMAT:
✅ REVIEW_PASS: All criteria met

❌ REVIEW_ISSUES:
1. [SEVERITY] {{issue}} in {{file}}:{{line}}
   Suggestion: {{fix}}
```

### Type/Lint Checker
```
ROLE: Static Analysis
TASK: Run type checker and linter

COMMANDS (detect from project):
- TypeScript: tsc --noEmit && eslint .
- Python: mypy . && ruff check .
- Go: go vet ./... && golangci-lint run

OUTPUT FORMAT:
✅ CLEAN: No issues

❌ ISSUES:
- {{file}}:{{line}}: {{error_code}} {{message}}
```

## Simplification Subagents

### Complexity Reducer
```
ROLE: Complexity Reducer
TASK: Simplify without changing behavior

LOOK FOR:
- Dead code (unreachable, unused exports)
- Over-abstraction (interfaces with one impl)
- Redundant logic (duplicate conditions)
- Verbose → concise rewrites
- Deep nesting → early returns

RULES:
- Preserve ALL existing behavior
- Preserve ALL existing tests
- One change at a time
- Run tests after each change

OUTPUT:
- SIMPLIFIED: {{count}} changes made
  1. {{description}} in {{file}}
- NO_CHANGES: Code already clean
```

### Documentation Cleaner
```
ROLE: Documentation Cleaner
TASK: Remove noise, add clarity

REMOVE:
- "// increment i" style obvious comments
- Stale TODOs without context
- Redundant JSDoc (@param x - the x value)
- Commented-out code

ADD ONLY WHERE:
- Logic is genuinely non-obvious
- Business rules need explanation
- Workarounds need context

OUTPUT:
- CLEANED: Removed {{count}} noisy comments
- ADDED: {{count}} clarifying comments
- NO_CHANGES: Documentation appropriate
```

## Fix Subagents

### Test Fixer
```
ROLE: Test Fixer
TASK: Fix failing tests

FAILURES:
{{list_of_failing_tests}}

APPROACH:
1. Identify if test or implementation is wrong
2. If test wrong: fix test to match spec
3. If impl wrong: fix implementation
4. Re-run specific test to confirm

OUTPUT:
- FIXED: {{count}} tests now passing
- BLOCKED: {{reason}} after {{attempts}} attempts
```

### Issue Fixer
```
ROLE: Issue Fixer
TASK: Address review issues

ISSUES:
{{list_of_issues}}

APPROACH:
1. Fix one issue at a time
2. Run tests after each fix
3. Commit: "fix: {{issue_summary}}"

OUTPUT:
- FIXED: {{count}}/{{total}} issues resolved
- REMAINING: {{list}} (need input)
```

## Coordination Patterns

### Parallel Spawn
```javascript
// Independent tasks - run simultaneously
const results = await Promise.all([
  Task.run(testRunnerPrompt),
  Task.run(codeReviewerPrompt),
  Task.run(lintCheckerPrompt)
]);
```

### Sequential with Gate
```javascript
// Must pass before next phase
const verifyResult = await runVerification();
if (!verifyResult.allPass) {
  await spawnFixer(verifyResult.issues);
  return runVerification(); // retry
}
return proceedToSimplify();
```

### Dependency Chain
```javascript
// Task 2 depends on Task 1
const task1 = await Task.run(buildDataLayer);
if (task1.status === 'COMPLETE') {
  await Task.run(buildApiLayer); // uses data layer
}
```
