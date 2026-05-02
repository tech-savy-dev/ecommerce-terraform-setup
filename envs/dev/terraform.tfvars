# terraform.tfvars for dev environment
# SECURITY: Never commit real credentials here. Use AWS SSM / Secrets Manager or
# environment variables (TF_VAR_*) for sensitive values.

vpc_cidr                = "10.0.0.0/16"
vpc_name                = "ecommerce-dev-vpc"
public_subnet_cidrs     = ["10.0.4.0/24", "10.0.5.0/24"]
private_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
availability_zones      = ["ap-southeast-1a", "ap-southeast-1b"]
subnet_name             = "ecommerce-subnet"
environment             = "dev"
repo_owner              = "tech-savy-dev"
branch                  = "main"
codestar_connection_arn = "arn:aws:codeconnections:ap-southeast-1:677450898543:connection/b64cf610-ff1d-4b6e-ae12-18f5ae34d8f0"

# ACM certificate for CloudFront (must be in us-east-1)
cloudfront_acm_certificate_arn = "arn:aws:acm:us-east-1:677450898543:certificate/88082d1c-9a77-4d82-8c4e-9a8e7127fd87"

# Initial ECS image URLs — CodeDeploy manages subsequent updates; Terraform ignores changes
# after first deploy (see lifecycle.ignore_changes in modules/ecs/main.tf)
auth_service_image_url    = "677450898543.dkr.ecr.ap-southeast-1.amazonaws.com/dev-ecommerce-auth-service:latest"
product_service_image_url = "677450898543.dkr.ecr.ap-southeast-1.amazonaws.com/dev-ecommerce-product-service:latest"

pipelines = [
  {
    pipeline_name      = "ecommerce-parent-service"
    repo_name          = "ecommerce-parent"
    build_project_name = "dev-ecommerce-parent-pom-build"
  },
  {
    pipeline_name      = "ecommerce-shared-lib"
    repo_name          = "ecommerce-shared-lib"
    build_project_name = "dev-ecommerce-shared-lib-pom-build"
  },
  {
    pipeline_name         = "ecommerce-product-service"
    repo_name             = "ecommerce-product-service"
    build_project_name    = "dev-ecommerce-product-service-build"
    enable_deploy_stage   = true
    codedeploy_app_name   = "ecommerce-product-service"
    codedeploy_group_name = "ecommerce-product-service-dg"
  },
  {
    pipeline_name         = "ecommerce-auth-service"
    repo_name             = "ecommerce-auth-service"
    build_project_name    = "dev-ecommerce-auth-service-build"
    enable_deploy_stage   = true
    codedeploy_app_name   = "ecommerce-auth-service"
    codedeploy_group_name = "ecommerce-auth-service-dg"
  },
  {
    pipeline_name         = "ecommerce-web-ui"
    repo_name             = "ecommerce-web-ui"
    build_project_name    = "dev-ecommerce-web-ui-build"
    enable_deploy_stage   = true
    codedeploy_app_name   = ""
    codedeploy_group_name = ""
  }
]

codebuild_projects = [
  { build_project_name = "dev-ecommerce-parent-pom-build", buildspec_location = "buildspec.yaml" },
  { build_project_name = "dev-ecommerce-shared-lib-pom-build", buildspec_location = "buildspec.yaml" },
  { build_project_name = "dev-ecommerce-product-service-build", buildspec_location = "buildspec.yaml" },
  { build_project_name = "dev-ecommerce-auth-service-build", buildspec_location = "buildspec.yaml" },
  { build_project_name = "dev-ecommerce-web-ui-build", buildspec_location = "buildspec.yaml" }
]

codeartifact_repos = [
  {
    repository_name       = "ecommerce-parent-artifacts"
    upstream_repositories = []
    external_connections  = ["public:maven-central"]
  },
  {
    repository_name       = "ecommerce-shared-lib-artifacts"
    upstream_repositories = []
    external_connections  = ["public:maven-central"]
  },
  {
    repository_name       = "ecommerce-product-artifacts"
    upstream_repositories = []
    external_connections  = ["public:maven-central"]
  },
  {
    repository_name       = "ecommerce-auth-artifacts"
    upstream_repositories = []
    external_connections  = ["public:maven-central"]
  },
  {
    repository_name       = "ecommerce-common-lib-artifacts"
    upstream_repositories = []
    external_connections  = ["public:maven-central"]
  },
  {
    repository_name = "ecommerce-shared"
    upstream_repositories = [
      "ecommerce-parent-artifacts",
      "ecommerce-shared-lib-artifacts",
      "ecommerce-product-artifacts",
      "ecommerce-auth-artifacts",
      "ecommerce-common-lib-artifacts"
    ]
    external_connections = null
  },
  {
    repository_name       = "ecommerce-web-ui-artifacts"
    upstream_repositories = []
    external_connections  = ["public:npmjs"]
  }
]

cluster_name = "dev-ecommerce-cluster"
service_name = "ecommerce-shared"
region       = "ap-southeast-1"
website_name = "shophealthysnacks.com"
san_names    = ["*.shophealthysnacks.com"]
alb_name     = "ecommerce"
ig_name      = "ecommerce"
project      = "ecommerce"
