output "role_arns" {
  value = {
    for k, role in aws_iam_role.codebuild_role :
    k => role.arn
  }
}

output "role_names" {
  description = "Map of CodeBuild role names"
  value = {
    for k, role in aws_iam_role.codebuild_role :
    k => role.name
  }
}

output "role_arn_pipeline" {
  value = aws_iam_role.pipeline_role.arn
}

output "role_name_pipeline" {
  value = aws_iam_role.pipeline_role.name
}

output "codeartifact_access_policy_arn" {
  value = aws_iam_policy.codeartifact_access.arn
}
