# Agents

This directory holds the two subagent roles. `~/.claude/agents` points at it, so the
roles are available in every project.

| Role | Owns | Tools |
|---|---|---|
| `coder` | Building one task, and proving it | Full |
| `reviewer` | Testing the claim on one task | Read-only |

The session itself is the Orchestrator. It has no file here, because it is the session.
Its behaviour comes from the "Orchestration" section of `.claude/CLAUDE.md` and from
`/outcome`.

The shared protocol lives in that section: the task brief, the control loop, the
message shapes, the escalation contract and the completion gate. Both roles follow it.
Each file here holds only what is specific to the role.

`reviewer` carries no Edit or Write tool. That is deliberate. It stops a review turning
into delivery work.

## Do not add a third role

Two is the design, not a starting point. A need for a researcher means the brief went
out with an open question in it. A need for a tester means the coder skipped its own
evidence. Fix the brief.

A one-off instruction belongs in the brief, not in a new file.
