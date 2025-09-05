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
}

# Attach managed policies

resource "aws_iam_role_policy_attachment" "codebuild_ecr_access" {
  for_each   = aws_iam_role.codebuild_role
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_s3_access" {
  for_each   = aws_iam_role.codebuild_role
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_codepipeline_access" {
  for_each   = aws_iam_role.codebuild_role
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch_logs" {
  for_each   = aws_iam_role.codebuild_role
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# Add inline ECS access for task definition operations
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
          "ecs:ListTaskDefinitions",
          "iam:PassRole" 
        ],
        Resource = "*"
      }
    ]
  })
}

# Optional inline policy to allow CodeBuild roles to upload to the website bucket
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
          "s3:PutObjectAcl",
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
