output "role_arns" {
  description = "Map of CodeBuild role name => ARN"
  value = {
    for k, role in aws_iam_role.codebuild_role :
    k => role.arn
  }
}

output "role_names" {
  description = "Map of CodeBuild role name => name"
  value = {
    for k, role in aws_iam_role.codebuild_role :
    k => role.name
  }
}

output "role_arn_pipeline" {
  description = "ARN of the CodePipeline IAM role"
  value       = aws_iam_role.pipeline_role.arn
}

output "role_name_pipeline" {
  description = "Name of the CodePipeline IAM role"
  value       = aws_iam_role.pipeline_role.name
}

output "codeartifact_access_policy_arn" {
  description = "ARN of the CodeArtifact access IAM policy"
  value       = aws_iam_policy.codeartifact_access.arn
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "codedeploy_role_arn" {
  description = "ARN of the CodeDeploy IAM role"
  value       = aws_iam_role.codedeploy_role.arn
}
