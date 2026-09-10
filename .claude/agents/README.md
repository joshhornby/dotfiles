# Agents

This directory holds the subagent roles. `~/.claude/agents` points at it, so the roles
are available in every project.

| Role | Owns | Model | Effort | Tools |
|---|---|---|---|---|
| `planner` | Decomposing a large requirement into briefs | Fable 5 | High | Read-only |
| `solver` | Building one hard or ambiguous task | Opus 5 | High | Full |
| `coder` | Building one well-defined task | Sonnet 5 | Medium | Full |
| `reviewer` | Testing the claim on one task | Opus 5 | Medium | Read-only |

The session itself is the Orchestrator. It has no file here, because it is the session.
Its behaviour comes from the "Orchestration" section of `.claude/CLAUDE.md` and from
`/outcome`.

The shared protocol lives in that section: the task brief, the control loop, the
message shapes, the escalation contract and the completion gate. Every role follows it.
Each file here holds only what is specific to the role.

`planner` and `reviewer` carry no Edit or Write tool. That is deliberate. It stops
planning or review turning into delivery work.

## Which role to dispatch

Start at the top of this list and take the first row that fits.

1. Exceptionally complex planning: a large PRD, a multi-system design, substantial
   architectural dependencies, or a plan that will drive many downstream agents.
   Dispatch `planner`. Ask the human first. Fable is expensive, so never dispatch it
   automatically.
2. Ambiguous, investigative or architecturally difficult work, work that spans several
   systems, or a task where a `coder` failed or became stuck. Dispatch `solver`.
3. Independent validation of a finished task, or review of a risky change. Dispatch
   `reviewer`.
4. Anything else: a clear ticket, routine refactoring, tests, documentation or
   straightforward debugging. Dispatch `coder`. This is the default.

## Do not add a fifth role

Four is the design, not a starting point. A need for a researcher means the brief went
out with an open question in it. A need for a tester means the coder skipped its own
evidence. Fix the brief.

A one-off instruction belongs in the brief, not in a new file.
