---
name: add-feature
description: Interview the user deeply about a feature idea and generate a comprehensive PRD that an autonomous agent can use to implement it. Use when adding a new feature, capability, or system component to pg-loop. Triggers on "add feature", "new feature", "build this", "I want to add".
allowed-tools: Read, Glob, Grep, AskUserQuestion, Write, Edit
argument-hint: [feature-idea]
---

# Add Feature

Take a rough feature idea and turn it into a detailed, agent-implementable PRD through exhaustive interviewing. The goal is to extract everything an autonomous agent needs to build the feature correctly on the first pass — no ambiguity, no guessing.

The feature idea: `$ARGUMENTS`

## Phase 1: Understand the Codebase Context

Before asking any questions, gather context on what exists now. Run these in parallel:

- Read `CLAUDE.md` — current routing map and source layout
- Read `docs/architecture/overview.md` — system architecture
- Read `docs/architecture/data-model.md` — current data model
- Read `docs/plans/v1-kickoff.md` — what we're building toward
- Glob `src/**/*.ts` — all source files that exist
- Read `src/db/schema.ts` — current schema

This context informs which questions to ask and helps identify dependencies and conflicts with existing code.

## Phase 2: The Interview

Conduct a thorough, multi-round interview using AskUserQuestion. This is the most important phase — the quality of the PRD depends entirely on the quality of the questions asked.

**Do NOT rush this.** Ask questions across multiple rounds. Each round should build on answers from previous rounds. Dig deeper when answers reveal complexity or ambiguity.

### Round 1: Problem & Purpose

Ask about:

- **The problem** — What specific problem does this feature solve? What's painful today without it?
- **The user** — Who benefits from this? (The autonomous agent? The human operator? Both?)
- **The trigger** — Why now? What makes this the right next thing to build?
- **Success** — How will we know this feature is working well? What does "done" look like in concrete terms?

### Round 2: Behavior & Scope

Ask about:

- **Core behavior** — Walk through the happy path step by step. What happens first, then what, then what?
- **Inputs** — What data does this feature need? Where does it come from?
- **Outputs** — What does this feature produce? Where does it go?
- **Boundaries** — What is explicitly NOT part of this feature? What are we deferring?
- **Interactions** — How does this feature interact with existing components (CLI, agents, database, tools)?

### Round 3: Edge Cases & Error Handling

Ask about:

- **What can go wrong?** — Network failures, invalid data, missing dependencies, race conditions
- **Partial failures** — What if step 3 of 5 fails? Is work lost? Can it resume?
- **Validation** — What inputs are invalid? What happens when they're provided?
- **Concurrency** — Can this run in parallel with other operations? What conflicts could arise?
- **Idempotency** — What happens if this runs twice with the same input?

### Round 4: Data & Storage

Ask about:

- **New tables or columns** — Does this need new database schema? What fields?
- **Relationships** — How does new data relate to existing tables (projects, etc.)?
- **Data lifecycle** — Is this data permanent? Should it be cleaned up? Versioned?
- **Querying** — How will this data be retrieved? What queries need to be fast?
- **Embeddings** — Does any of this data need semantic search via pgvector?

### Round 5: Technical Constraints & Preferences

Ask about:

- **Dependencies** — Does this need new npm packages? External APIs? Services?
- **Performance** — Are there latency or throughput requirements?
- **Configuration** — Does this need new env vars or config?
- **Testing** — What's the testing strategy? What must be verified?
- **Migration** — Does existing data need to change? Is there a migration path?

### Round 6: UX & Interface

Ask about:

- **CLI commands** — What new commands or flags are needed?
- **Output format** — What should the user see? Verbose or minimal? Structured or prose?
- **Feedback** — How does the user know something is happening? Progress indicators?
- **Errors to users** — What error messages should the user see?
- **Approval gates** — Does any step require human approval before proceeding?

### Round 7: Follow-ups & Depth

Based on everything learned so far, ask follow-up questions about:

- Anything that was vague or ambiguous in earlier answers
- Implications the user may not have considered
- Conflicts with existing architecture or conventions
- Sequencing — what needs to be built first?
- Anything that an implementing agent would get stuck on

**Keep asking follow-up rounds until confident there are no remaining ambiguities.** It is better to ask too many questions than too few. Each AskUserQuestion call can ask 1-4 questions — use multiple rounds.

## Phase 3: Generate the PRD

After the interview is complete, generate a comprehensive PRD. Write it to `docs/designs/prd-[feature-name].md` using a slugified version of the feature name.

### PRD Structure

```markdown
# PRD: [Feature Name]

> Status: draft
> Created: [date]
> Interview rounds: [N]

## Problem Statement

[1-2 paragraphs describing the problem this feature solves, derived from interview answers]

## Success Criteria

[Concrete, verifiable statements an agent can check. Written as "it should..." statements]

- It should ...
- It should ...
- It should NOT ...

## User Stories

[Who does what and why, derived from interview]

- As [who], I want [what] so that [why]

## Detailed Behavior

### Happy Path

[Step-by-step walkthrough of the core flow]

1. ...
2. ...
3. ...

### Alternative Paths

[Other valid flows]

### Error Handling

[What happens when things go wrong — each failure mode and the expected behavior]

| Failure | Expected Behavior |
|---------|-------------------|
| ... | ... |

## Scope

### In Scope

- ...

### Out of Scope (Deferred)

- ...

## Data Model

### New Tables

[If any — include column names, types, constraints, and reasoning]

### Schema Changes

[Changes to existing tables]

### Queries

[Key queries this feature needs to perform efficiently]

## Technical Design

### New Files

[Expected new files and their purpose]

### Modified Files

[Existing files that need changes and what changes]

### Dependencies

[New packages, APIs, or services needed]

### Configuration

[New env vars, config values]

## Interface Design

### CLI Commands

[New commands, flags, arguments, and expected output]

### Agent Integration

[How agents interact with this feature]

## Testing Strategy

### Unit Tests

[What to test in isolation]

### Integration Tests

[What to test end-to-end]

### Acceptance Tests

[How to verify the success criteria are met — these are the tests that determine "done"]

## Implementation Sequence

[Ordered list of steps to build this feature. Each step should be independently verifiable.]

1. ...
2. ...
3. ...

## Open Questions

[Anything that still needs resolution — ideally empty after a thorough interview]

## Appendix: Interview Transcript

[Summary of key Q&A from the interview, preserving the reasoning behind decisions]
```

## Phase 4: Review & Refine

After writing the PRD:

1. Present a summary of the PRD to the user
2. Ask if anything is missing, wrong, or needs more detail
3. Iterate on the PRD based on feedback
4. Mark the status as "draft" — the user can promote it to "approved" when ready

## Rules

- **Exhaust the questions.** The interview should feel thorough, not perfunctory. 5-8 rounds minimum. If unsure whether to ask another question, ask it.
- **No assumptions.** If something wasn't discussed in the interview, don't invent an answer. Put it in "Open Questions."
- **Acceptance criteria are king.** The success criteria and acceptance tests are the most important sections. An agent should be able to read those sections alone and know exactly what to build and how to verify it.
- **Match the project voice.** Write in the same tone as existing docs — direct, practical, no fluff.
- **Respect existing architecture.** Reference existing docs, conventions, and patterns. The PRD should feel like it belongs in this repo.
- **Think like an agent.** Every section should answer a question an implementing agent would have. If the agent would need to guess, the PRD is incomplete.
