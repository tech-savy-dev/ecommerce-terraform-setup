resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name        = "ecs-cloudwatch-logs-policy"
  description = "Policy to allow ECS tasks to create log streams and put log events to CloudWatch logs."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:ap-southeast-1:${data.aws_caller_identity.current.account_id}:log-group:/ecs/*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
