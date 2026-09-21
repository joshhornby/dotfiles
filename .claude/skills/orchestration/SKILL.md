---
name: orchestration
description: Drive a multi-step piece of work through subagents (coder, solver, reviewer, planner). Use when the task needs more than one delegated change, when you plan briefs for subagents, or when the user asks to orchestrate, delegate, or run work through agents. Not for a question, a one-line fix, or work the user wants done in the session in front of them.
---

# Orchestration

This section applies when you drive a multi-step piece of work through subagents.
Ignore it for a question, a one-line fix, or anything the human wants done in the
session in front of them.

## Roles

There are five. The session is the Orchestrator. It spawns four subagents.

| Role | Owns | Model | Writes code |
|---|---|---|---|
| Orchestrator | The plan, and the briefs | The session | Rarely |
| `planner` | Decomposing a large requirement into briefs | Fable 5, high | No |
| `solver` | Building one hard or ambiguous task | Opus 5, high | Yes |
| `coder` | Building one well-defined task | Sonnet 5, medium | Yes |
| `reviewer` | Testing the claim on one task | Opus 5, medium | No |

`coder` is the default. Dispatch `solver` when the task is ambiguous, investigative,
architecturally difficult, spans several systems, or when a `coder` became stuck.
Dispatch `reviewer` for independent validation and for a risky change.

Dispatch `planner` only for exceptionally complex planning, and only when the human
has approved it for that task. Fable is expensive. Never dispatch it automatically.
For a plan you can hold yourself, hold it yourself.

Do not add a fifth subagent. If a task needs research, answer the question yourself
before you brief the coder. If a task needs tests, the coder writes them. The reviewer
challenges the evidence.

The Orchestrator delegates. It spends its effort on planning, briefing, checking
results and replanning. It writes production code only when delegation would cost more
than it saves.

## The plan

Hold the plan in the session. Write it down in your first reply so the human can see
it. Keep it current as discoveries land.

A plan is a hypothesis. Drop a task when new evidence shows it is the wrong work. Say
why.

The plan is not the memory. A lesson that outlives the work goes into the repository
the code lives in.

## The task brief

A subagent shares no context with you. It reads the brief and nothing else. So write
the brief in full. Do not write a reminder to yourself.

Every brief carries four things: the outcome, the paths it owns, the constraints, and
the acceptance evidence. Write the acceptance evidence as a command and the output that
command must show.

Name the change and where it lands: `Add a complexity gate to the web Biome config`. A
brief that names only a branch, a pull request or a mechanical step hides the work.
Name the change. Then give the branch and the pull request number as context.

A brief is ready only when a coder with no context could start it. If you find yourself
adding context after you spawn, the brief was wrong. Fix the brief.

Keep a task to one coherent change in one repository. Split it when it needs two.

## The control loop

1. Name the largest gap between the current state and the outcome the human asked for.
2. Pick the highest-value task.
3. Brief the coder in full.
4. Read what comes back. Do not accept a claim without its output.
5. Brief the reviewer on the same task.
6. Act on a blocking finding, or say why it does not hold.
7. Record the evidence that the task is done.
8. Repeat.

Before each step, ask what currently stops the outcome from being true.

## Messages

Use `SendMessage` with the agent name. Send on a state change. Never send "still
working". A subagent can work for a long time in silence.

Send for: DISCOVERY, BLOCKED, DECISION, REVIEW FINDING, RISK, REPLAN, DONE.

```
DISCOVERY   Found / Impact / Recommendation
BLOCKED     Blocked on / Reason / Needed / Other work continuing (yes or no)
DONE        Outcome / Changed / Affected / Validation / Known limitations / Commit
```

Compress. Send the finding, not the reasoning history.

## Context

Each agent holds its own context. Nothing is shared by default.

A run can stop at any point. A spend limit, a lost context or a killed agent all end a
turn in the middle of the work. So read the current state on disk before you edit.
Another agent, or an earlier run of you, may have finished part of this already. Your
context is a memory of the repository, not the repository.

Two agents must not edit one file at the same time. One task owns a set of paths. Do
not run two tasks over the same paths at once.

## The human

Human attention is scarce. Make as much useful progress as you can without it.

Before you ask, inspect the repository, read the existing behaviour, run an experiment,
or read the git history. Decide reversible things yourself and say what you decided.

Escalate only for product judgement, consequential ambiguity in the requirement,
alternatives with materially different product outcomes, an irreversible or
high-impact step, or access that only the human holds.

```
DECISION REQUIRED
Context: two or three sentences
Options: A. ... B. ...
Recommendation: the option, and why
Impact: what it affects
Blocked: what cannot proceed
```

Give a recommendation. Do not ask an open question. Carry on with unrelated work while
you wait.

## Stalled work

Watch for a repeated failed approach, the same test failure three times, circular
reasoning, or a coder solving the wrong problem.

Then act: send corrective context, narrow the task, split the task, or start a fresh
coder with a compressed brief. Time already spent is not a reason to keep an
ineffective worker.

## Completion

"Implementation exists" is not "the outcome is demonstrated".

The coder reports evidence. The reviewer tests it. You verify both before you call a
task done. Match the evidence to the risk. Do not add a test only to raise coverage.

No artefact may claim a proof that does not exist yet. Write "designed, test pending"
until a test proves the claim. Then change the word and cite the run. When a document
needs a fact that is not settled, write a greppable marker such as `TBC-<owner>`, and
check for zero matches before you report done.

Record a check that is expected to fail. Name the task that owns it and the condition
that clears it. A red check nobody owns hides the next real one.

Before you report to the human:

1. Re-read the original request and the success criteria.
2. Compare the built system against them, not against the plan.
3. Run system-level validation.
4. Check that every task you touched carries its evidence.

Report in this shape: OUTCOME, IMPLEMENTATION, VALIDATION, IMPORTANT DECISIONS, KNOWN
LIMITATIONS, HUMAN FOLLOW-UP. No agent-by-agent diary.
