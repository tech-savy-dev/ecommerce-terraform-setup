module "vpc" {
  source   = "../../modules/vpc"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  ig_name  = var.ig_name
}

module "subnets" {
  source               = "../../modules/subnets"
  vpc_id               = module.vpc.vpc_id
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  subnet_name          = var.subnet_name
  internet_gateway_id  = module.vpc.internet_gateway_id
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

module "ecs" {
  source           = "../../modules/ecs"
  # ECS Cluster-related parameters
  cluster_name     = var.cluster_name
  subnet_ids       = module.subnets.private_subnet_ids
  security_groups  = var.security_groups
  ecs_tasks = var.ecs_tasks
  service_name = var.service_name
  vpc_id               = module.vpc.vpc_id
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  region             = var.region
 
}

module "vpcendpoint" {
  source             = "../../modules/vpcendpoint"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_id  = var.security_group_ids[0]
  route_table_ids    = module.subnets.private_route_table_ids
  region             = var.region
}

module "acm" {
  source                  = "../../modules/acm"
  domain_name             = var.website_name
  san_names               = var.san_names
}

module "alb" {
  source         = "../../modules/alb"
  alb_name           = var.alb_name
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.subnets.public_subnet_ids
  certificate_arn = module.acm.certificate_arn

  target_group_port = 80
  health_check_path = "/actuator/health"
  target_type       = "ip"
}
