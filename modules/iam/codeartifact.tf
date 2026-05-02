resource "aws_iam_policy" "codeartifact_access" {
  name        = "codeartifact-access-${var.project}-${var.environment}"
  description = "Allows CodeBuild to authenticate and read/publish to CodeArtifact"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:PublishPackageVersion",
          "codeartifact:PutPackageMetadata",
          "codeartifact:ReadFromRepository"
        ],
        # Scoped to the ecommerce domain in this account/region
        Resource = "arn:aws:codeartifact:*:${data.aws_caller_identity.current.account_id}:domain/ecommerce-domain"
      },
      {
        # GetServiceBearerToken must target STS globally
        Effect   = "Allow",
        Action   = ["sts:GetServiceBearerToken"],
        Resource = "*",
        Condition = {
          StringEquals = {
            "sts:AWSServiceName" = "codeartifact.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codeartifact_policy" {
  for_each   = aws_iam_role.codebuild_role
  role       = each.value.name
  policy_arn = aws_iam_policy.codeartifact_access.arn
}
