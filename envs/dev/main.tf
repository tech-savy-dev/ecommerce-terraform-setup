module "vpc" {
  source   = "../../modules/vpc"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
}

module "subnets" {
  source               = "../../modules/subnets"
  vpc_id               = module.vpc.vpc_id
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  subnet_name          = var.subnet_name
}

module "ecr" {
  source              = "../../modules/ecr"
  ecr_repository_name = var.ecr_repository_name
  environment         = var.environment
}

module "iam" {
  source                 = "../../modules/iam"
  codestar_connection_arn = var.codestar_connection_arn
  codebuild_role_names    = [
    "codebuild-role-dev-ecommerce-parent-pom-build",
    "codebuild-role-dev-ecommerce-product-service-build"
  ]
}

data "aws_caller_identity" "current" {}

module "artifact_bucket" {
  source      = "../../modules/artifact_bucket"
  bucket_name = "ecommerce-artifacts-${var.environment}-${data.aws_caller_identity.current.account_id}"
  environment = var.environment
}

resource "aws_codeartifact_domain" "ecommerce" {
  domain = "ecommerce-domain"
  lifecycle {
    prevent_destroy = true
  }
}

module "codeartifact" {
  for_each = {
    for repo in var.codeartifact_repos :
    repo.repository_name => repo
  }

  source                = "../../modules/codeartifact"
  domain_name           = aws_codeartifact_domain.ecommerce.domain
  repository_name       = each.value.repository_name
  upstream_repositories = lookup(each.value, "upstream_repositories", [])
  external_connections  = lookup(each.value, "external_connections", null)
}

module "codebuild_project" {
  for_each = {
    for cb in var.codebuild_projects :
    cb.build_project_name => cb
  }

  source                   = "../../modules/codebuild"
  build_project_name       = each.value.build_project_name
  buildspec_location       = each.value.buildspec_location
  service_role_arn         = module.iam.role_arns["codebuild-role-${each.key}"]
  codeartifact_policy_arn  = module.iam.codeartifact_access_policy_arn
}


module "codepipeline" {
  for_each = {
    for pipeline in var.pipelines :
    pipeline.pipeline_name => pipeline
  }

  source                  = "../../modules/codepipeline"
  github_token            = var.github_token
  artifact_bucket         = module.artifact_bucket.bucket_name
  build_project_name      = module.codebuild_project[each.value.build_project_name].name
  pipeline_name           = each.value.pipeline_name
  repo_name               = each.value.repo_name
  repo_owner              = var.repo_owner
  codestar_connection_arn = var.codestar_connection_arn
  service_role_arn        = module.iam.role_arn_pipeline
  codeartifact_policy_arn = module.iam.codeartifact_access_policy_arn
}
