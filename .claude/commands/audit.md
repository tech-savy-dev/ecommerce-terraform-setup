# /audit

Run a full Terraform security and quality audit across all modules and the specified environment.

## Usage
```
/audit         # audits all modules + envs/dev
/audit prod    # audits all modules + envs/prod
```

## Checks to perform

### Security
- IAM policies: flag any `*FullAccess` managed policies or `Resource = "*"` without a condition
- S3 buckets: flag any missing `aws_s3_bucket_public_access_block` or missing encryption
- Security groups: flag any `0.0.0.0/0` ingress rules that aren't on the ALB
- ECS: flag any `assign_public_ip = true` for non-auth services

### Code Quality
- Hardcoded account IDs, regions, or image digests in `.tf` files (not tfvars)
- Variables missing `description` or `type`
- Outputs missing `description`
- Resources missing standard tags (`Environment`, `Name`)
- `for_each` / `count` where applicable instead of repeated blocks

### State & Backend
- Confirm backend is configured and not local
- Confirm `prevent_destroy` on stateful resources (CodeArtifact domain, S3 buckets)

### Drift Detection
- Run `terraform plan` and flag any unexpected diffs

Report findings with severity: 🔴 CRITICAL | 🟠 HIGH | 🟡 MEDIUM | 🟢 LOW
