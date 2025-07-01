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

output "repository_url" {
  value  = module.ecr.repository_url
}

output "repository_name" {
  value  = module.ecr.repository_name
}

output "debug_role_arns" {
  value = module.iam.role_arns
}


