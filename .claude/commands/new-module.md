# /new-module

Scaffold a new Terraform module following project conventions.

## Usage
```
/new-module <name>
```
Example: `/new-module rds`

## What to create

`modules/<name>/`:
- `main.tf` — resource definitions
- `variables.tf` — all inputs with `type`, `description`, and `default` where appropriate
- `outputs.tf` — all outputs with `description`

## Conventions to follow

- All resource names include `${var.environment}` or `${var.project}-${var.environment}`
- Tags block on every taggable resource: `Name`, `Environment`, `Project`
- No hardcoded account IDs, regions, or AMI IDs — use `data` sources or variables
- IAM policies must be least-privilege — no `*FullAccess` managed policies
- Add `lifecycle { prevent_destroy = true }` on stateful resources (databases, domains)
- Run `terraform fmt` on the new files before presenting them
