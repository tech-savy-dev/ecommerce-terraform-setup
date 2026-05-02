resource "aws_iam_role" "pipeline_role" {
  name = "codepipeline-role-${var.project}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Effect = "Allow"
    }]
  })

  tags = {
    Name        = "codepipeline-role-${var.project}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy" "pipeline_codedeploy_policy" {
  name = "codedeploy-permissions-${var.project}-${var.environment}"
  role = aws_iam_role.pipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:StopDeployment"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codestar_policy" {
  name = "codestar-connection-${var.project}-${var.environment}"
  role = aws_iam_role.pipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["codestar-connections:UseConnection"],
        Resource = var.codestar_connection_arn
      }
    ]
  })
}

# Scoped S3 access: artifact bucket (rw) and website bucket (rw)
resource "aws_iam_role_policy" "pipeline_s3_policy" {
  name = "s3-access-${var.project}-${var.environment}"
  role = aws_iam_role.pipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:GetBucketVersioning",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.artifact_bucket}",
          "arn:aws:s3:::${var.artifact_bucket}/*",
          "arn:aws:s3:::${var.website_bucket}",
          "arn:aws:s3:::${var.website_bucket}/*"
        ]
      }
    ]
  })
}

# Scoped CodeBuild access: only start builds and read results
resource "aws_iam_role_policy" "pipeline_codebuild_policy" {
  name = "codebuild-access-${var.project}-${var.environment}"
  role = aws_iam_role.pipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:StopBuild"
        ],
        Resource = "*"
      }
    ]
  })
}

# Scoped ECR access: pipeline only needs to describe images, not push
resource "aws_iam_role_policy" "pipeline_ecr_policy" {
  name = "ecr-read-${var.project}-${var.environment}"
  role = aws_iam_role.pipeline_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories"
        ],
        Resource = "*"
      }
    ]
  })
}
