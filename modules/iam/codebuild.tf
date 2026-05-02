resource "aws_iam_role" "codebuild_role" {
  for_each = toset(var.codebuild_role_names)

  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# ECR: push images during build
resource "aws_iam_role_policy_attachment" "codebuild_ecr_access" {
  for_each   = aws_iam_role.codebuild_role
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# CloudWatch Logs: scoped via the shared cloudwatch policy (not FullAccess)
resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch_logs" {
  for_each   = aws_iam_role.codebuild_role
  role       = each.value.name
  policy_arn = aws_iam_policy.ecs_cloudwatch_logs_policy.arn
}

# Scoped S3: artifact bucket (rw) and website bucket (rw if set)
resource "aws_iam_role_policy" "codebuild_s3_access" {
  for_each = aws_iam_role.codebuild_role
  name     = "${each.key}-s3-access"
  role     = each.value.name

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
          "arn:aws:s3:::${var.artifact_bucket}/*"
        ]
      }
    ]
  })
}

# ECS task definition operations needed during build/deploy
resource "aws_iam_role_policy" "codebuild_ecs_access" {
  for_each = aws_iam_role.codebuild_role
  name     = "${each.key}-ecs-access"
  role     = each.value.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:ListTaskDefinitions"
        ],
        Resource = "*"
      },
      {
        # PassRole scoped to the ECS execution role only
        Effect   = "Allow",
        Action   = ["iam:PassRole"],
        Resource = aws_iam_role.ecs_execution_role.arn
      }
    ]
  })
}

# Optional: allow CodeBuild roles to upload to the website bucket
resource "aws_iam_role_policy" "codebuild_website_s3_access" {
  for_each = var.website_bucket != "" ? aws_iam_role.codebuild_role : {}
  name     = "${each.key}-website-s3-access"
  role     = each.value.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.website_bucket}",
          "arn:aws:s3:::${var.website_bucket}/*"
        ]
      }
    ]
  })
}
