# Agents

This directory holds the reusable agent roles for the engineering organisation.
`~/.claude/agents` points at it, so the roles are available in every project.

The shared protocol lives in one place: the "Engineering organisation" section of
`.claude/CLAUDE.md`. It covers the control loop, the task graph, the message shapes,
the escalation contract, ownership and the completion gate. Every role follows it.

Each file here holds only what is specific to the role: what it owns, what it must
not do, how it communicates and what evidence it owes.

| Role | Owns | Spawn it when |
|---|---|---|
| `shadow-lead` | Is the team converging on the outcome? | Any substantial outcome. First. |
| `project-lead` | One coherent workstream outcome. | The outcome splits into projects. |
| `implementer` | One scoped implementation outcome. | There is code to write. |
| `tester` | Proving a behaviour works. | A claim needs evidence. |
| `researcher` | One specific uncertainty. | Reading the code has not settled it. |
| `reviewer` | One implementation or diff. | A change needs a second technical read. |

The top-level session is the Primary Engineering Lead. It has no file here, because it
is the session itself. Its behaviour comes from `CLAUDE.md` and from `/outcome`.

`shadow-lead`, `researcher` and `reviewer` carry no Edit or Write tool. That is
deliberate. It stops a review or an investigation from turning into delivery work.

## Adding a role

Add one only when it gives reusable value. A one-off brief belongs in the prompt, not
in a new file. Keep the new file short, and do not copy the protocol into it.

## Requirements

The task tools and teammate messaging come from Agent Teams, which is experimental.
`.claude/settings.json` turns it on with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`. Set
`teammateMode` with `/config` to choose how teammates run: `in-process`, `tmux`,
`iterm2` or `auto`.

Without Agent Teams the roles still work as ordinary subagents. You lose the shared
task graph and the teammate mailbox, so the Primary Lead has to hold that state.
