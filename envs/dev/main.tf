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
  project     = var.project
  environment = var.environment
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

locals{
  ecs_tasks = [
  {
    task_name        = "ecommerce-product-service"
    task_family      = "ecommerce-task-family"
    container_name   = "ecommerce-product-service-container"
    image_url        = "677450898543.dkr.ecr.ap-southeast-1.amazonaws.com/ecommerce-product-service-dev:a5b303a" 
    container_port   = 8080  # Port exposed by the container
    service_name     = "ecommerce-product-service"
    cpu              = "512"  
    memory           = "1024"
    assign_public_ip = false   # Add this attribute
    desired_count    = 1
  
  }
]
}

module "ecs" {
  source                  = "../../modules/ecs"
  cluster_name            = var.cluster_name
  subnet_ids              = module.subnets.private_subnet_ids
  vpc_id                  = module.vpc.vpc_id
  region                  = var.region

  service_name            = var.service_name
  ecs_tasks               = local.ecs_tasks
  ecs_execution_role_arn  = module.iam.ecs_execution_role_arn
  alb_sg_id               = module.alb.alb_sg_id

  # ✅ Now pass both target groups
  blue_target_group_arn   = module.alb.target_group_blue_arn
  green_target_group_arn  = module.alb.target_group_green_arn
}



module "vpcendpoint" {
  source             = "../../modules/vpcendpoint"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.subnets.private_subnet_ids
  route_table_ids    = module.subnets.private_route_table_ids
  region             = var.region
  ecs_security_group_id = module.ecs.ecs_security_group_id

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
  environment         = var.environment 

  target_group_port = 8080
  health_check_path = "/actuator/health"
  target_type       = "ip"
}

module "codedeploy" {
  for_each = {
    for cd in var.codedeploy_configs :
    cd.app_name => cd
  }
  source                = "../../modules/codedeploy"
  app_name              = each.value.app_name
  ecs_cluster_name      = each.value.ecs_cluster_name
  ecs_service_name      = each.value.ecs_service_name
  codedeploy_role_arn   = module.iam.codedeploy_role_arn
  # ✅ Now pass both target groups
  blue_target_group_name = module.alb.target_group_blue_name
  green_target_group_name = module.alb.target_group_green_name
  listener_arn          = module.alb.https_listener_arn
  tags = {
    Environment = "dev"
    Project     = "shop-snacks"
    Owner       = "dev-team"
    Terraform   = "true"
  }
}


