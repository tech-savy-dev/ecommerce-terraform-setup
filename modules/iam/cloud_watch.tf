data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_policy" "ecs_cloudwatch_logs_policy" {
  name        = "ecs-cloudwatch-logs-${var.project}-${var.environment}"
  description = "Allows ECS tasks and CodeBuild to write logs to the /ecs/* CloudWatch log group."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/*"
      }
    ]
  })
}
