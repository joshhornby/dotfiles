---
allowed-tools: Bash(git log:*), Bash(git diff:*), Bash(git show:*), Bash(gh pr list:*), Bash(gh pr view:*), Bash(gh issue view:*), Bash(basename:*), Bash(pwd:*), Read(*)
description: Summarise the week's product changes for non-technical stakeholders
argument-hint: "[period, e.g. 'last 7 days'] [--slack]"
---

## Context

- Directory: !`pwd`
- Merged pull requests: !`gh pr list --state merged --limit 40 --json number,title,mergedAt --jq '.[] | "\(.mergedAt) #\(.number) \(.title)"' 2>/dev/null || echo "gh unavailable"`
- Recent commits: !`git log --since="14 days ago" --pretty=format:'%ad %s' --date=short 2>/dev/null | head -60`

## Task

Period: $ARGUMENTS (default: the last 7 days).
Add a small number of tasteful emoji to the headings.
If the arguments contain `--slack`, output the update in a fenced block using Slack mrkdwn. Use single asterisks for bold. Use no headings and no tables.

# Weekly Product Change Summary

Review this GitHub repository and summarise the meaningful product changes made during the period above.

## Goal

Produce a short update for **non-technical stakeholders** explaining what changed from a product and customer perspective.

Do not write a developer changelog.

Use the available evidence across:

* merged pull requests;
* commits;
* linked GitHub issues;
* PR descriptions;
* issue acceptance criteria;
* relevant documentation changes.

Where several PRs or commits contribute to the same product outcome, combine them into a single item.

## What to focus on

Prioritise changes that affect:

* customers or end users;
* internal users or operational teams;
* product capabilities;
* user journeys;
* reliability or quality where the impact is meaningful;
* things the business can now do that it could not do before.

Ignore or heavily de-emphasise:

* dependency upgrades;
* refactoring;
* formatting;
* test changes;
* CI changes;
* implementation details;
* file names, classes, APIs or database changes;

unless they have a meaningful product or business impact.

Translate technical work into the **outcome it enabled**.

For example, instead of:

> Added an `inquiries:view` permission and updated the admin navigation.

Write:

> Properties can now give staff access to customer enquiries without granting them access to the wider administration system.

## Output

Start with:

# Product update — [date range]

Then give a **2–4 sentence executive summary** of the most important progress during the week.

Then:

## What changed

For each meaningful product change use:

### [Short product-focused title]

1–3 sentences covering:

* **What changed**
* **Who it affects**
* **Why it matters**

Where useful, mention whether something is now live, ready for release, or still being prepared.

Aim for roughly **3–7 meaningful changes**, depending on the activity in the repository.

Finish with:

## In summary

Give 2–3 sentences describing the overall direction of the week's work and what users or the business can now do as a result.

## Writing style

Write for people such as:

* Product Managers
* Account Managers
* Sales
* Operations
* senior leadership

Assume they have **no knowledge of the codebase**.

Use plain English and UK spelling.

Avoid:

* GitHub terminology where possible;
* PR and commit numbers;
* technical implementation details;
* jargon;
* overstating minor changes;
* claiming something is live unless the evidence supports it.

If the purpose or user impact of a change cannot be confidently determined, leave it out rather than guessing.

## Example of a good update

# Product update — 24–28 August

This week focused on preparing more properties to work with Good Spa Guide and improving how customer enquiries are managed. We also added additional protection against low-quality or spam enquiries.

## What changed

### Properties can now manage customer enquiries

Properties that are not using the full Journey booking platform can now receive and manage enquiries through Good Spa Guide.

This gives us a way to support properties that are listed on the site but are not yet connected to Journey's booking technology.

### More focused access for property teams

Staff can now be given access specifically to customer enquiries without also receiving access to unrelated Journey administration features.

This makes the experience simpler for Good Spa Guide properties and allows us to give them only the tools they need.

### Better protection against spam enquiries

Additional checks have been introduced when customers submit enquiries, including improved validation of email addresses.

This should reduce obviously invalid submissions reaching property teams.

## In summary

The changes this week make it easier to bring properties onto Good Spa Guide even when they are not using Journey's wider platform. The focus has been on giving those properties a simple way to receive genuine customer demand without exposing unnecessary complexity.
