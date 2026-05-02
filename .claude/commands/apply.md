# /apply

Apply the saved `tfplan` for the specified environment.

## Usage
```
/apply         # defaults to dev
/apply dev
/apply stage
/apply prod
```

## Steps

1. `cd envs/$ARGUMENTS` (default: `dev`)
2. Confirm a `tfplan` file exists — if not, prompt to run `/plan` first
3. Run `terraform apply "tfplan"`
4. On success: display the Outputs block and summarise what was created/changed/destroyed
5. On error: show the full error, diagnose root cause, and suggest the fix before retrying
