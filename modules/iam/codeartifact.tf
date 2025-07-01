resource "aws_iam_policy" "codeartifact_access" {
 name = "CodeArtifactAccessPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "codeartifact:GetAuthorizationToken",
          "codeartifact:GetRepositoryEndpoint",
          "codeartifact:PublishPackageVersion",
          "codeartifact:PutPackageMetadata", 
          "codeartifact:ReadFromRepository",
          "sts:GetServiceBearerToken"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_codeartifact_policy" {
  for_each   = aws_iam_role.codebuild_role
  role       = each.value.name
  policy_arn = aws_iam_policy.codeartifact_access.arn
}