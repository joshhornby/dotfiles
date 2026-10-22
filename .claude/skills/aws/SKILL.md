---
name: aws
description: Answers AWS questions about a named Journey app (logs, services, clusters, queues, databases) by finding where each environment runs in Backstage, then querying it with the read-only agent-* AWS profiles. Use when the user asks an AWS question about an app, such as "look up logs for oj api", "what is running in staging for good spa guide" or "check the queue for X".
---

# AWS

Find where the app runs first. Query AWS second. Do not guess the account or the region.

## Quick start

1. Find the app in Backstage:
   `catalog_query-catalog-entities` with `fullTextFilter.term` set to the app name. Use the `Component` entity.
2. Read its `journey.travel/<environment>-*` annotations. The environment is `production`, `staging` or `review`.

   | Annotation | Example | Use |
   |---|---|---|
   | `<env>-platform` | `aws-ecs`, `aws-eks`, `vercel` | Which tool to use |
   | `<env>-aws-account-id` | `"123456789012"` | Which profile to use |
   | `<env>-aws-region` | `eu-west-1` | Pass on every call |
   | `<env>-cluster` | `my-cluster` | ECS or EKS cluster |
   | `<env>-vercel-project` | `good-spa-guide` | Vercel tools, not AWS |

   `sentry.io/project-slug` names the Sentry project for errors.
3. Find the profile for the account:
   `grep -B1 -A3 'sso_account_id = <id>' ~/.aws/config` and use the `agent-*` profile.
4. Query with the profile and the region on every call:
   `aws <service> <command> --profile agent-<name> --region <region>`

If the user names no environment, use `production`.

## When the annotations are missing

Find the facts in the repository, then say what you assumed:

1. Read the repository `CLAUDE.md` or `AGENTS.md` for a deployment section.
2. Read the deploy workflows in `.github/workflows/`. Look for `aws-region`, `role-to-assume` (the account id is in the ARN) and the cluster name.
3. Do not trust a platform tag such as `aws-ecs` alone. Confirm with `aws ecs list-clusters` or `aws eks list-clusters`.

Then offer to add the annotations to the app's `catalog-info.yaml`.

## Platform notes

- **aws-ecs**: `aws ecs list-services --cluster <cluster>`, then `describe-task-definition` to find the `awslogs-group` of the container.
- **aws-eks**: the pod logs may not be in CloudWatch. Check for a kube context before you report "no logs".
- **vercel**: use the Vercel MCP tools (`get_runtime_logs`), not AWS.
- **Logs in a time window**: `aws logs filter-log-events --start-time <epoch ms>`. Write large output to the scratchpad and summarise it. Group by status, route or error, and do not dump raw lines.

## Errors

- **AccessDenied "explicit deny in a service control policy"**: check the region first. The SCP blocks regions that are not approved. A wrong region gives the same error as a missing permission.
- **A real SCP or IAM deny**: stop. Do not try a different account or role to get round it. Tell the user which permission is missing.
- **Expired SSO token**: tell the user to run `! aws sso login --sso-session <name>`. Read `<name>` from the `sso_session` line of the profile in `~/.aws/config`. Never ask for keys or tokens.

## Rules

- Use only the read-only `agent-*` profiles.
- Separate facts you read from assumptions you made in the answer.
- Do not print secrets, environment values or personal data from logs. Count them or summarise them.
