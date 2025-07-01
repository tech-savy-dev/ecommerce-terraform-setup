resource "aws_iam_role" "codebuild_role" {
  for_each = toset(var.codebuild_role_names)

  name = each.key

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "codebuild.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

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
