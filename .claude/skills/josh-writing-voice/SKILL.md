---
name: josh-writing-voice
description: Apply Josh's personal writing voice to prose — blog posts, docs, talks, and anything published under his name. Simple plain language, prose over lists, active voice, British spelling. Use when drafting or editing Josh's own writing. Runs the humanizer skill for AI-pattern removal rather than duplicating it.
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Skill
---

# Josh's Writing Voice

Josh writes in the tradition of **Will Larson** (clear, structured, calm authority) and
**Eugene Yan** (concrete, example-led, generous with the reader) — but in **simpler
language than either**. The test for every sentence: could a smart, busy colleague skim it
once and get it?

This skill is a **voice profile plus orchestration**. It does not re-implement AI-pattern
detection — that lives in the `humanizer` skill. The flow is: apply the voice, then run
humanizer as the cleanup pass.

## The voice — positive rules

1. **Simple words.** Prefer the plain word every time: *use* not *utilise*, *help* not
   *facilitate*, *about* not *regarding*, *so* not *thus*. If a word would make a reader
   pause to parse it, swap it.
2. **Prose by default, not bullet lists.** Josh dislikes writing that collapses into
   lists. Only use a list when the items are genuinely parallel and discrete (e.g. steps,
   options). Never turn an argument or a narrative into bullets. Never format ideas into a
   table unless the data is genuinely tabular.
3. **Short sentences.** One idea each. Break long sentences in two. Vary rhythm so it
   doesn't read like a metronome.
4. **Active voice.** "We shipped it", not "it was shipped".
5. **British spelling.** Always (`realise`, `behaviour`, `colour`, `optimise`).
6. **Show, don't assert.** A concrete example or number beats an adjective. Cut
   "powerful", "seamless", "robust" — earn the claim or drop it.
7. **Links feel natural.** Weave relevant links into the sentence; don't always call them
   out explicitly ("see here"). Not every reference needs a signpost.
8. **No AI tells.** No "delve", "tapestry", "moreover", "it's worth noting", rule-of-three
   padding, or "not just X but Y" constructions.

## Process

1. **Read** the target text (or directory of posts, if doing a sweep).
2. **Rewrite for voice** — apply the eight rules above. Prefer surgical edits over
   wholesale rewrites; keep Josh's existing phrasing where it already works.
3. **Run the `humanizer` skill** on the result to catch any remaining AI patterns. Invoke
   it via the Skill tool — do not duplicate its checks here.
4. **For blog/Jekyll files**, bump `lastmod` in the front matter on anything you changed.
5. **Report** what you changed and why, briefly. Don't over-explain.

## When sweeping many files

For "review all posts and keep them simple" style requests, process files in a loop:
read → voice pass → humanizer → note the diff. Summarise the whole sweep at the end
(files touched, common issues fixed). Flag anything you were unsure about rather than
silently rewriting a passage whose meaning you couldn't preserve.
