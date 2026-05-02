# /plan

Run `terraform fmt`, `terraform validate`, then `terraform plan` for the specified environment.

## Usage
```
/plan          # defaults to dev
/plan dev
/plan stage
/plan prod
```

## Steps

1. `cd envs/$ARGUMENTS` (default: `dev`)
2. Run `terraform fmt -recursive` from repo root — fail if any file changes
3. Run `terraform validate` — fail on any warning or error
4. Run `terraform plan -out=tfplan`
5. Report: summary line (N to add / change / destroy), list any force-replacements, and flag any unexpected destroys before proceeding
