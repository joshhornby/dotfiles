# Agents

This directory holds the subagent roles. `~/.claude/agents` points at it, so the roles
are available in every project.

| Role | Owns | Model | Effort | Tools |
|---|---|---|---|---|
| `coder` | Building one task | Opus 5 | Medium | Full |
| `reviewer` | Testing the claim on one task | Opus 5 | Medium | Read-only |

The session itself is the Orchestrator. It has no file here, because it is the session.
Its behaviour comes from the `orchestration` skill and from `/outcome`.

The shared protocol lives in that skill: the task brief, the control loop, the
message shapes, the escalation contract and the completion gate. Every role follows it.
Each file here holds only what is specific to the role.

`reviewer` carries no Edit or Write tool. That is deliberate. It stops review turning
into delivery work.

## Which role to dispatch

1. Independent validation of a finished task, or review of a risky change. Dispatch
   `reviewer`.
2. Anything else. Dispatch `coder`. This is the default.

The Orchestrator holds the plan itself. When a `coder` fails or becomes stuck, narrow
the brief and start a fresh `coder`.

## Do not add a third role

Two is the design, not a starting point. A need for a researcher means the brief went
out with an open question in it. A need for a tester means the coder skipped its own
evidence. Fix the brief.

A one-off instruction belongs in the brief, not in a new file.
