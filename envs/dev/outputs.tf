# outputs.tf for dev environment
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}


output "ecr_repository_names" {
  value = module.ecr.repository_names
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "debug_role_arns" {
  value = module.iam.role_arns
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "certificate_arn" {
  value = module.acm.certificate_arn
}

output "dns_validation_records" {
  value = module.acm.validation_records
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}


output "public_route_table_id" {
  value = module.vpc.public_route_table_id
}

output "codebuild_services" {
  description = "List of CodeBuild project names deployed"
  value       = [for name in keys(module.codebuild_project) : name]
}


