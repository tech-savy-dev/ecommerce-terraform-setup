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

module "vpcendpoint" {
  source                 = "../../modules/vpcendpoint"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.subnets.private_subnet_ids
  ecr_subnet_ids         = module.subnets.public_subnet_ids
  route_table_ids        = module.subnets.private_route_table_ids
  region                 = var.region
  ecs_security_group_id  = module.ecs_private.ecs_security_group_id
  auth_security_group_id = module.ecs_public_auth.ecs_security_group_id
  enable_ecs_telemetry   = false
}

locals {
  ecr_existing  = []
  ecr_to_create = ["${var.environment}-ecommerce-product-service", "${var.environment}-ecommerce-auth-service"]
}

module "ecr" {
  source        = "../../modules/ecr"
  ecr_existing  = local.ecr_existing
  ecr_to_create = local.ecr_to_create
  environment   = var.environment
}

data "aws_caller_identity" "current" {}

module "artifact_bucket" {
  source      = "../../modules/artifact_bucket"
  bucket_name = "ecommerce-artifacts-${var.environment}-${data.aws_caller_identity.current.account_id}"
  environment = var.environment
}

module "website_bucket" {
  source         = "../../modules/website_bucket"
  bucket_name    = "ecommerce-web-ui-${var.environment}-${data.aws_caller_identity.current.account_id}"
  environment    = var.environment
  enable_website = true
}

module "iam" {
  source                  = "../../modules/iam"
  codestar_connection_arn = var.codestar_connection_arn
  project                 = var.project
  environment             = var.environment
  artifact_bucket         = module.artifact_bucket.bucket_name
  website_bucket          = module.website_bucket.bucket_name
  codebuild_role_names = [
    "codebuild-role-${var.environment}-ecommerce-parent-pom-build",
    "codebuild-role-${var.environment}-ecommerce-shared-lib-pom-build",
    "codebuild-role-${var.environment}-ecommerce-product-service-build",
    "codebuild-role-${var.environment}-ecommerce-auth-service-build",
    "codebuild-role-${var.environment}-ecommerce-web-ui-build",
  ]
}

resource "aws_codeartifact_domain" "ecommerce" {
  domain = "ecommerce-domain"
  lifecycle {
    prevent_destroy = true
  }
}

module "codeartifact_base" {
  for_each = {
    for repo in var.codeartifact_repos :
    repo.repository_name => repo
    if length(try(repo.upstream_repositories, [])) == 0
  }

  source                = "../../modules/codeartifact"
  domain_name           = aws_codeartifact_domain.ecommerce.domain
  repository_name       = each.value.repository_name
  upstream_repositories = []
  external_connections  = lookup(each.value, "external_connections", null)
}

module "codeartifact_with_upstreams" {
  for_each = {
    for repo in var.codeartifact_repos :
    repo.repository_name => repo
    if length(try(repo.upstream_repositories, [])) > 0
  }

  source                = "../../modules/codeartifact"
  domain_name           = aws_codeartifact_domain.ecommerce.domain
  repository_name       = each.value.repository_name
  upstream_repositories = lookup(each.value, "upstream_repositories", [])
  external_connections  = lookup(each.value, "external_connections", null)

  depends_on = [module.codeartifact_base]
}

module "codebuild_project" {
  for_each = {
    for cb in var.codebuild_projects :
    cb.build_project_name => cb
  }

  source                  = "../../modules/codebuild"
  build_project_name      = each.value.build_project_name
  buildspec_location      = each.value.buildspec_location
  service_role_arn        = module.iam.role_arns["codebuild-role-${each.key}"]
  codeartifact_policy_arn = module.iam.codeartifact_access_policy_arn
  website_bucket          = module.website_bucket.bucket_name
}

module "codepipeline" {
  for_each = {
    for pipeline in var.pipelines :
    pipeline.pipeline_name => pipeline
  }

  source                  = "../../modules/codepipeline"
  artifact_bucket         = module.artifact_bucket.bucket_name
  build_project_name      = module.codebuild_project[each.value.build_project_name].name
  pipeline_name           = each.value.pipeline_name
  repo_name               = each.value.repo_name
  repo_owner              = var.repo_owner
  codestar_connection_arn = var.codestar_connection_arn
  service_role_arn        = module.iam.role_arn_pipeline
  codeartifact_policy_arn = module.iam.codeartifact_access_policy_arn
  website_bucket          = module.website_bucket.bucket_name
  enable_deploy_stage     = try(each.value.enable_deploy_stage, false)
  codedeploy_app_name     = try(each.value.codedeploy_app_name, "")
  codedeploy_group_name   = try(each.value.codedeploy_group_name, "")
}

module "acm" {
  source      = "../../modules/acm"
  domain_name = var.website_name
  san_names   = var.san_names
}

module "cloudfront" {
  source                  = "../../modules/cloudfront"
  website_bucket_name     = module.website_bucket.bucket_name
  website_bucket_endpoint = module.website_bucket.website_endpoint
  enabled                 = true
  comment                 = "CDN for ${module.website_bucket.bucket_name}"
  aliases                 = concat([var.website_name], var.san_names)
  acm_certificate_arn     = var.cloudfront_acm_certificate_arn
  price_class             = "PriceClass_100"
}

locals {
  code_deploy_tasks = [
    {
      service_name            = "ecommerce-auth-service"
      blue_target_group_name  = "ecommerce-auth-blue-tg"
      green_target_group_name = "ecommerce-auth-green-tg"
      health_check_path       = "/actuator/health"
      path_pattern            = "/as*"
      priority                = 1
    },
    {
      service_name            = "ecommerce-product-service"
      blue_target_group_name  = "ecommerce-product-blue-tg"
      green_target_group_name = "ecommerce-product-green-tg"
      health_check_path       = "/actuator/health"
      path_pattern            = "/ps*"
      priority                = 2
    }
  ]

  codedeploy_enabled_services = {
    for t in local.ecs_tasks : t.service_name => t
    if try(t.use_codedeploy, false)
  }

  services_map = {
    for svc in local.code_deploy_tasks : svc.service_name => {
      path_pattern            = svc.path_pattern
      priority                = svc.priority
      blue_target_group_name  = svc.blue_target_group_name
      green_target_group_name = svc.green_target_group_name
      blue_target_group_arn   = module.target_groups.blue_target_group_arns[svc.service_name]
      green_target_group_arn  = module.target_groups.green_target_group_arns[svc.service_name]
      health_check_path       = svc.health_check_path
    }
    if contains(keys(local.codedeploy_enabled_services), svc.service_name)
  }
}

module "target_groups" {
  source   = "../../modules/target_groups"
  vpc_id   = module.vpc.vpc_id
  alb_name = var.alb_name
  services = local.code_deploy_tasks
}

locals {
  blue_target_group_arns = {
    for svc in local.code_deploy_tasks :
    svc.service_name => module.target_groups.blue_target_group_arns[svc.service_name]
  }
  green_target_group_arns = {
    for svc in local.code_deploy_tasks :
    svc.service_name => module.target_groups.green_target_group_arns[svc.service_name]
  }
  blue_target_group_names = {
    for svc in local.code_deploy_tasks :
    svc.service_name => module.target_groups.blue_target_group_names[svc.service_name]
  }
  green_target_group_names = {
    for svc in local.code_deploy_tasks :
    svc.service_name => module.target_groups.green_target_group_names[svc.service_name]
  }
}

module "alb" {
  source                     = "../../modules/alb"
  alb_name                   = var.alb_name
  vpc_id                     = module.vpc.vpc_id
  public_subnets             = module.subnets.public_subnet_ids
  certificate_arn            = module.acm.certificate_arn
  environment                = var.environment
  blue_target_group_arns     = local.blue_target_group_arns
  enable_deletion_protection = false
}

# Listener rules must exist before ECS services are created so the target
# groups have an ALB association (required by CodeDeploy deployment controller).
resource "aws_lb_listener_rule" "service_routes" {
  for_each = local.services_map

  listener_arn = module.alb.https_listener_arn
  priority     = each.value.priority

  condition {
    path_pattern {
      values = [each.value.path_pattern]
    }
  }

  action {
    type             = "forward"
    target_group_arn = each.value.blue_target_group_arn
  }
}

module "codedeploy" {
  for_each = local.services_map

  source                  = "../../modules/codedeploy"
  app_name                = each.key
  ecs_cluster_name        = var.cluster_name
  ecs_service_name        = each.key
  codedeploy_role_arn     = module.iam.codedeploy_role_arn
  https_listener_arn      = module.alb.https_listener_arn
  blue_target_group_name  = each.value.blue_target_group_name
  green_target_group_name = each.value.green_target_group_name

  depends_on = [
    module.ecs_public_auth,
    module.ecs_private
  ]
}

locals {
  ecs_tasks = [
    {
      task_name        = "ecommerce-auth-service"
      task_family      = "ecommerce-auth-service-task-family"
      container_name   = "ecommerce-auth-service-container"
      image_url        = var.auth_service_image_url
      container_port   = 8080
      service_name     = "ecommerce-auth-service"
      cpu              = "512"
      memory           = "1024"
      assign_public_ip = true
      desired_count    = 1
      use_codedeploy   = true
    },
    {
      task_name        = "ecommerce-product-service"
      task_family      = "ecommerce-product-service-task-family"
      container_name   = "ecommerce-product-service-container"
      image_url        = var.product_service_image_url
      container_port   = 8080
      service_name     = "ecommerce-product-service"
      cpu              = "512"
      memory           = "1024"
      assign_public_ip = false
      desired_count    = 1
      use_codedeploy   = true
    }
  ]
}

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

module "ecs_public_auth" {
  source                 = "../../modules/ecs"
  cluster_arn            = aws_ecs_cluster.main.arn
  subnet_ids             = module.subnets.public_subnet_ids
  vpc_id                 = module.vpc.vpc_id
  region                 = var.region
  service_name           = "ecommerce-auth"
  ecs_tasks              = [for t in local.ecs_tasks : t if t.service_name == "ecommerce-auth-service"]
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  alb_sg_id              = module.alb.alb_sg_id
  blue_target_group_arns = local.blue_target_group_arns

  # Listener rules must exist first so TGs have an ALB association
  depends_on = [aws_lb_listener_rule.service_routes]
}

module "ecs_private" {
  source                 = "../../modules/ecs"
  cluster_arn            = aws_ecs_cluster.main.arn
  subnet_ids             = module.subnets.private_subnet_ids
  vpc_id                 = module.vpc.vpc_id
  region                 = var.region
  service_name           = "ecommerce-private"
  ecs_tasks              = [for t in local.ecs_tasks : t if t.service_name != "ecommerce-auth-service"]
  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  alb_sg_id              = module.alb.alb_sg_id
  blue_target_group_arns = local.blue_target_group_arns

  depends_on = [aws_lb_listener_rule.service_routes]
}
