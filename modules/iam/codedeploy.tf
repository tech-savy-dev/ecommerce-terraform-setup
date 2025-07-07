resource "aws_iam_role" "codedeploy_role" {
name = "codedeploy-role-${var.project}-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codedeploy.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

   tags = {
    Name        = "codedeploy-role-${var.project}-${var.environment}"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy" "codedeploy_policy" {
  name   = "codedeploy-role-${var.project}-${var.environment}-policy"
  role   = aws_iam_role.codedeploy_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:CreateTaskSet",
          "ecs:DeleteTaskSet",
          "ecs:DescribeTaskSets",
          "ecs:UpdateTaskSet",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeTargetHealth",
          "cloudwatch:PutMetricAlarm",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DeleteAlarms",
          "autoscaling:CompleteLifecycleAction",
          "autoscaling:PutLifecycleHook",
          "autoscaling:DeleteLifecycleHook",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLifecycleHooks",
          "autoscaling:RecordLifecycleActionHeartbeat"
        ]
        Resource = "*"
      }
    ]
  })
}