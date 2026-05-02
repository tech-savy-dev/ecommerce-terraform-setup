output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.subnets.private_subnet_ids
}

output "ecr_repository_names" {
  description = "Names of all ECR repositories (existing + created)"
  value       = module.ecr.repository_names
}

output "ecr_repository_urls" {
  description = "Map of ECR repository name => URL"
  value       = module.ecr.repository_urls
}

output "iam_codebuild_role_arns" {
  description = "Map of CodeBuild role name => ARN"
  value       = module.iam.role_arns
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = module.acm.certificate_arn
}

output "dns_validation_records" {
  description = "DNS records required to validate the ACM certificate"
  value       = module.acm.validation_records
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.cloudfront.domain_name
}

output "website_bucket_name" {
  description = "Name of the S3 website bucket"
  value       = module.website_bucket.bucket_name
}

output "artifact_bucket_name" {
  description = "Name of the S3 artifact bucket"
  value       = module.artifact_bucket.bucket_name
}

output "codebuild_services" {
  description = "List of CodeBuild project names deployed"
  value       = [for name in keys(module.codebuild_project) : name]
}
