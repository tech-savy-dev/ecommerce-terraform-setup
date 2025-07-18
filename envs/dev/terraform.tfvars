# terraform.tfvars for dev environment
vpc_cidr = "10.0.0.0/16"
vpc_name = "ecommerce-dev-vpc"
public_subnet_cidrs = [
  "10.0.4.0/24",
  "10.0.5.0/24"
]
private_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
subnet_name  = "ecommerce-subnet"
environment = "dev"
github_token = "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"
repo_owner = "tech-savy-dev"
branch = "main"
build_project_name  = "ecommerce-product-service-build"
buildspec_location  = "buildspec.yaml"
codestar_connection_arn = "arn:aws:codeconnections:ap-southeast-1:677450898543:connection/18e78ce7-7400-422b-bbcb-a771a52e8d65"
pipelines = [
  {
    pipeline_name = "ecommerce-parent-service"
    repo_name     = "ecommerce-parent"
    build_project_name  = "dev-ecommerce-parent-pom-build"
  },
  {
    pipeline_name = "ecommerce-product-service"
    repo_name     = "ecommerce-product-service"
    build_project_name  = "dev-ecommerce-product-service-build"
    enable_deploy_stage   = true
    codedeploy_app_name   = "ecommerce-product-service"
    codedeploy_group_name = "ecommerce-product-service-dg"
  },
  {
    pipeline_name = "ecommerce-auth-service"
    repo_name     = "ecommerce-auth-service"
    build_project_name  = "dev-ecommerce-auth-service-build"
    enable_deploy_stage   = true
    codedeploy_app_name   = "ecommerce-auth-service"
    codedeploy_group_name = "ecommerce-auth-service-dg"
  } 
]

codebuild_projects = [
  {
    build_project_name = "dev-ecommerce-parent-pom-build"
    buildspec_location = "buildspec.yaml"
  },
  {
    build_project_name = "dev-ecommerce-product-service-build"
    buildspec_location = "buildspec.yaml"
  },
  {
    build_project_name = "dev-ecommerce-auth-service-build"
    buildspec_location = "buildspec.yaml"
  }
]

codeartifact_repos = [
  {
    repository_name       = "ecommerce-parent-artifacts"
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
    repository_name       = "ecommerce-shared"
    upstream_repositories = ["ecommerce-parent-artifacts", "ecommerce-product-artifacts","ecommerce-auth-artifacts"]
    external_connections  = null
  }
]


domain_name = "ecommerce-domain"
cluster_name = "dev-ecommerce-cluster"


service_name = "ecommerce-shared"
region = "ap-southeast-1"
website_name = "shophealthysnacks.com"
san_names = ["*.shophealthysnacks.com"]
alb_name = "ecommerce"
ig_name = "ecommerce"

project = "ecommerce"







