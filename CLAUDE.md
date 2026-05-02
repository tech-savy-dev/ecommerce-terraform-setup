# CLAUDE.md — ecommerce-terraform-setup

This file gives Claude Code context about this project so every session starts with full situational awareness.

---

## Project Overview

Infrastructure-as-Code for the **ecommerce** platform using Terraform on AWS.  
Owner: `tech-savy-dev` | Repo: `ecommerce-terraform-setup` | Branch: `main`

The stack includes: VPC, ECS Fargate, ALB, CodePipeline, CodeBuild, CodeDeploy (blue/green), CodeArtifact, ECR, ACM, CloudFront, S3 (artifacts + website), IAM, VPC Endpoints.

---

## Repository Layout

```
terraform-ecommerce-setup/
├── provider.tf                  # AWS provider + required_providers (~> 5.0)
├── envs/
│   ├── dev/                     # Active environment (ap-southeast-1)
│   │   ├── backend.tf           # S3 remote backend (use_lockfile=true)
│   │   ├── main.tf              # All module calls + locals
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars     # Dev-specific values (no secrets)
│   ├── stage/                   # Not yet wired (mirrors dev structure)
│   └── prod/                    # Not yet wired (mirrors dev structure)
└── modules/
    ├── vpc/                     # VPC + IGW (no route table — subnets module owns that)
    ├── subnets/                 # Public + private subnets, route tables, IGW routes
    ├── natgw/                   # NAT Gateway(s) — optional, not called in dev currently
    ├── vpcendpoint/             # ECR, ECS, STS, S3, CloudWatch VPC endpoints
    ├── alb/                     # ALB, HTTPS listener (TLS 1.3), HTTP→HTTPS redirect
    ├── target_groups/           # Blue + green TGs per service
    ├── acm/                     # ACM certificate (DNS validation)
    ├── cloudfront/              # CloudFront CDN for S3 website (custom origin)
    ├── ecr/                     # ECR repositories + lifecycle policies
    ├── ecs/                     # ECS task definitions, services, security group, log groups
    ├── codebuild/               # CodeBuild projects
    ├── codepipeline/            # CodePipeline (Source→Build→Deploy)
    ├── codedeploy/              # CodeDeploy app + blue/green deployment group
    ├── codeartifact/            # CodeArtifact repositories
    ├── artifact_bucket/         # S3 pipeline artifact bucket (versioned, KMS-SSE)
    ├── website_bucket/          # S3 static website bucket (public read)
    └── iam/                     # All IAM roles and policies (split by service)
```

---

## AWS Account & Region

- **Account ID**: `677450898543`
- **Primary region**: `ap-southeast-1` (Singapore)
- **CloudFront ACM cert region**: `us-east-1` (required by CloudFront)

---

## Key Architecture Decisions

### ECS
- **Two ECS module instances share one cluster** (`aws_ecs_cluster.main` in `envs/dev/main.tf`).
  The ECS module (`modules/ecs`) does NOT create a cluster — it accepts `cluster_arn`.
- `ecs_public_auth` — auth service in **public** subnets (`assign_public_ip = true`)
- `ecs_private` — product service in **private** subnets (uses VPC endpoints for AWS APIs)
- ECS services use `CODE_DEPLOY` deployment controller for blue/green deploys.
- `lifecycle { ignore_changes = [task_definition, desired_count, load_balancer] }` — CodeDeploy manages image updates after first deploy.

### ALB Listener Rules
- Listener rules (`aws_lb_listener_rule.service_routes`) are defined **in `main.tf`**, NOT inside the codedeploy module.
- This is intentional: rules must exist **before** ECS services are created so target groups have an ALB association (CodeDeploy deployment controller requirement).
- ECS modules have `depends_on = [aws_lb_listener_rule.service_routes]`.
- CodeDeploy module `depends_on = [module.ecs_public_auth, module.ecs_private]`.

### CodeDeploy Blue/Green
- Path routing: `/as*` → auth service (priority 1), `/ps*` → product service (priority 2)
- Target groups: `ecommerce-auth-blue-tg` / `ecommerce-auth-green-tg` (and product equivalents)
- Deployment group names: `ecommerce-auth-service-dg`, `ecommerce-product-service-dg`

### IAM — Least Privilege
All roles use scoped inline policies. No `*FullAccess` managed policies anywhere.
- CodeBuild: ECR PowerUser + scoped S3 (artifact + website buckets only) + scoped ECS (RegisterTaskDefinition) + `iam:PassRole` → ECS execution role only
- CodePipeline: scoped S3 + scoped CodeBuild (StartBuild/StopBuild/BatchGetBuilds) + scoped ECR read + CodeDeploy actions
- CodeDeploy: scoped ELB (8 specific actions) + scoped ECS + `iam:PassRole` → ECS execution role only
- ECS execution role: `AmazonECSTaskExecutionRolePolicy` + `AmazonEC2ContainerRegistryReadOnly` + scoped CloudWatch logs (`/ecs/*`)
- All role/policy names include `${var.project}-${var.environment}` suffix to prevent cross-env conflicts.

### Remote State
- **Backend**: S3 bucket `ecommerce-terraform-state-dev-677450898543` (ap-southeast-1)
- **Locking**: S3 native lock file (`use_lockfile = true` — AWS provider v6+ style, no DynamoDB)
- **Encryption**: AES-256, versioning enabled, all public access blocked

### VPC Endpoints
Private subnets reach AWS services without internet via:
`ecr.api`, `ecr.dkr`, `sts`, `s3` (gateway), `ecs`, `ecs-agent`, `logs`  
ECR endpoints are placed in **public** subnets (`ecr_subnet_ids`) so the auth service (public subnet) can also pull images.

---

## Services

| Service | Repo | Pipeline | ECR Repo | Cluster |
|---------|------|----------|----------|---------|
| auth-service | `ecommerce-auth-service` | `ecommerce-auth-service` | `dev-ecommerce-auth-service` | `dev-ecommerce-cluster` |
| product-service | `ecommerce-product-service` | `ecommerce-product-service` | `dev-ecommerce-product-service` | `dev-ecommerce-cluster` |
| web-ui | `ecommerce-web-ui` | `ecommerce-web-ui` | — (deploys to S3) | — |
| parent-pom | `ecommerce-parent` | `ecommerce-parent-service` | — | — |
| shared-lib | `ecommerce-shared-lib` | `ecommerce-shared-lib` | — | — |

---

## CodeArtifact

Domain: `ecommerce-domain`  
Repos (base, no upstreams): `ecommerce-parent-artifacts`, `ecommerce-shared-lib-artifacts`, `ecommerce-product-artifacts`, `ecommerce-auth-artifacts`, `ecommerce-common-lib-artifacts`, `ecommerce-web-ui-artifacts`  
Repo with upstreams: `ecommerce-shared` (aggregates all base repos)  
External connections: Maven Central (Java repos), npmjs (web-ui)

---

## Domain & CDN

- **Domain**: `shophealthysnacks.com` + `*.shophealthysnacks.com`
- **ALB**: `ecommerce-alb-562719216.ap-southeast-1.elb.amazonaws.com`
- **CloudFront**: `dcjwjh60ltbu2.cloudfront.net`
- **Website bucket**: `ecommerce-web-ui-dev-677450898543`
- **ACM cert (ap-southeast-1)**: `arn:aws:acm:ap-southeast-1:677450898543:certificate/b8665e66...`
- **ACM cert (us-east-1/CloudFront)**: `arn:aws:acm:us-east-1:677450898543:certificate/88082d1c...`

---

## Terraform Conventions

- **Version**: `>= 1.5.0` (currently running 1.12.2)
- **Provider**: `hashicorp/aws ~> 5.0` (currently v6.14.1)
- **Formatting**: always run `terraform fmt -recursive` before committing
- **Validation**: always run `terraform validate` — must pass with zero warnings
- **Naming**: `snake_case`, all resource names include `${var.environment}` or `${var.project}-${var.environment}`
- **No hardcoded**: account IDs, regions, or image digests in module code — use `data` sources or variables
- **`prevent_destroy`**: set on `aws_codeartifact_domain.ecommerce`

## Development Workflow

```bash
# From envs/dev/
terraform fmt -recursive          # format
terraform validate                 # validate
terraform plan -out=tfplan         # plan
terraform apply "tfplan"           # apply
```

**State surgery (if needed):**
```bash
terraform state list               # list all resources
terraform state mv <src> <dst>     # move resource (no destroy)
terraform state rm <addr>          # remove from state only
terraform import <addr> <id>       # import existing resource
```

---

## Important: Do NOT commit

- `tfplan`, `*.tfplan` — binary plan files
- `*.tfstate`, `*.tfstate.backup` — state files (remote backend is source of truth)
- `state.json`, `plan_output*.txt` — local snapshots
- Any file containing credentials or tokens

The GitHub PAT that was previously in `terraform.tfvars` has been removed. Use `TF_VAR_*` env vars or AWS Secrets Manager for sensitive values.
